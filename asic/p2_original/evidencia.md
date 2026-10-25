# Evidencia de construcciones dependientes de la FPGA (sección 3.1)

Corridas de LibreLane 3.0.16 sobre el RTL del Proyecto 2, aplicando los reemplazos de a uno. Los logs completos quedan en runs/ (no versionado); en evidencia/ se copian los que cita el informe.

## c0a: RTL sin cambios (1227fa5)

- Construcción: `SB_RAM40_4K` (BRAM del iCE40) instanciado en `rtl/espino_core/espino_register_file.v`, líneas 22 y 33.
- Paso del flujo: `Verilator.Lint`, que detiene el flujo en `Checker.LintErrors`.
- Log: `runs/c0a/01-verilator-lint/verilator-lint.log`, líneas 1 y 13 (copia en `evidencia/c0a-verilator-lint.txt`).
- Mensaje: `%Error-MODMISSING: ... Cannot find file containing module: 'SB_RAM40_4K'`.
- Reemplazo: banco de registros en flip-flops con lectura sincrónica (decisiones D3 y D4).

## c0b: banco de registros en flip-flops (RTL de bc10dcf)

- `por_cnt` con valor inicial (`reg [11:0] por_cnt = 12'b0;`, `rtl/pochoco_soc.v:39`)
  - Linter: `%Warning-PROCASSINIT ... 'por_cnt'`, línea 7 de `evidencia/c0b/verilator-lint.txt`.
  - Síntesis: `Set init value: \por_cnt = 12'000000000000`, línea 324 de `evidencia/c0b/yosys-synthesis.txt`.
  - Problema: los flip-flops de la biblioteca no tienen valor inicial, así que ese valor se descarta sin otro aviso. En silicio el contador parte en cualquier valor: el reset interno dura entre 0 y 4095 ciclos, y con 0 el core nunca se resetea.
  - Reemplazo: puerto rst_n externo con sincronizador en asic_top (D6).
- `$readmemh` dentro de un bloque `initial` (`rtl/pochoco_ram.v:36`)
  - Linter: sin mensaje.
  - Síntesis: `Removed top 23 address bits (of 32) from memory init port ... u_ram ... pochoco_ram.v:36`, línea 992 de `evidencia/c0b/yosys-synthesis.txt`: Yosys carga sw/game.hex como valor inicial de la memoria.
  - Problema: al pasar la memoria a flip-flops, ese valor inicial también se descarta sin aviso. En silicio la RAM partiría con valores arbitrarios y el core ejecutaría instrucciones arbitrarias.
  - Reemplazo: sección 3.2.
- Inferencia de BRAM para la RAM de 512 palabras
  - Síntesis: sin BRAM, Yosys convierte la memoria en flip-flops; por ejemplo, línea 1469 de `evidencia/c0b/yosys-synthesis.txt`: `Adding EN signal on $memory\u_soc.u_ram.mem[93]...`.
  - Resultado (`evidencia/c0b/stat.rpt`): 17.188 flip-flops de 68.612 celdas y 2.327.825 µm² de área de celdas. Solo la RAM son 512 × 32 = 16.384 flip-flops.
  - Reemplazo: sección 3.2.
- SPI sin instanciar
  - Linter: `%Warning-UNUSEDSIGNAL ... 'spi_req'` (`rtl/pochoco_soc.v:73`), línea 18 de `evidencia/c0b/verilator-lint.txt`.
  - En el Proyecto 2 se dejó sin instanciar para ahorrar LCs; en el ASIC sigue así porque el juego no lo usa (D7).

## Sin mensaje propio del flujo

- `x0` valía 0 solo porque la BRAM partía en cero (`INIT_0(256'h0)`) y nunca se escribía. En silicio un flip-flop arranca en cualquier valor, así que el nuevo banco no almacena x0 y entrega 0 por hardware al leer la dirección 0. El flujo no lo reclama porque es una propiedad del valor inicial, no de la sintaxis.
- La inversión de los 7 segmentos (`~seg1` y `~seg2` en `pochoco_soc.v`) era la convención del display activo en bajo de la Go Board. Para el flujo no es un error. En el macro los puertos quedan activos en alto (D8).
- `CYCLES_PER_TENTH = 2500000` en `sw/game.s` supone el oscilador de 25 MHz de la Go Board. Es una constante del programa, así que el flujo no la ve. Se corrige en la sección 3.4 para el período del macro.
