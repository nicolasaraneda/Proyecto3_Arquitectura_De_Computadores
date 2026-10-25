# Evidencia de construcciones dependientes de la FPGA (sección 3.1)

Corridas de LibreLane 3.0.16 sobre el RTL del Proyecto 2, aplicando los reemplazos de a uno. Los logs completos quedan en runs/ (no versionado); en evidencia/ se copian los que cita el informe.

## c0a: RTL sin cambios (1227fa5)

- Construcción: `SB_RAM40_4K` (BRAM del iCE40) instanciado en `rtl/espino_core/espino_register_file.v`, líneas 22 y 33.
- Paso del flujo: `Verilator.Lint`, que detiene el flujo en `Checker.LintErrors`.
- Log: `runs/c0a/01-verilator-lint/verilator-lint.log`, líneas 1 y 13 (copia en `evidencia/c0a-verilator-lint.txt`).
- Mensaje: `%Error-MODMISSING: ... Cannot find file containing module: 'SB_RAM40_4K'`.
- Reemplazo: banco de registros en flip-flops con lectura sincrónica (decisiones D3 y D4).

## Sin mensaje propio del flujo

- `x0` valía 0 solo porque la BRAM partía en cero (`INIT_0(256'h0)`) y nunca se escribía. En silicio un flip-flop arranca en cualquier valor, así que el nuevo banco no almacena x0 y entrega 0 por hardware al leer la dirección 0. El flujo no lo reclama porque es una propiedad del valor inicial, no de la sintaxis.
