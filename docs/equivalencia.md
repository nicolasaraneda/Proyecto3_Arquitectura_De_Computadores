# Equivalencia formal entre el RTL y los netlists de la corrida final

Comprueba con métodos formales (eqy, sby y los pases `equiv_*` y `sat` de Yosys) que el
netlist de celdas estándar que entrega LibreLane implementa la misma función que el RTL de
`asic_top`, para todas las entradas y no solo para el escenario de `make post-synth`. Todo lo
que hay aquí salió de corridas reales; los comandos se repiten con `bash asic/eqy/correr.sh`
(sección 8).

**Este documento es el de la corrida final de D23** (el RTL del pipeline con `EarlyRead`, el banco
write-through y B2, más el modelo de cable del resizer). El del diseño anterior se conserva en
`docs/equivalencia_v1.md` y sus reportes en `asic/eqy/resultados_v1/`. El método no cambió: lo que
cambió son los resultados, y uno de ellos cambió de PASS a no concluyente, lo que está explicado en
las secciones 4.5 y 6 y es el hallazgo principal de esta vuelta.

**Lo importante en una línea: el RTL y los dos netlists de la corrida final son equivalentes, y
quien lo prueba es el flujo clásico de Yosys (976 de 976 celdas `$equiv`, inducción temporal) más el
miter completo desde reset; eqy prueba 29 de sus 30 particiones y deja sin decidir la grande, por un
motivo estructural que se explica abajo y que no es un error del diseño.**

Fechas: las corridas de eqy, del flujo clásico y de los BMC de este documento son del 28-10-2026;
la documentación del paso `Yosys.EQY` del flujo (sección 3) y de las pruebas de `read_liberty` es
del 27 y 28-10-2026 y no se repitió, porque no depende del diseño.

## 1. Resumen

| Comparación | Método | Resultado | Archivo de origen |
|---|---|---|---|
| RTL contra netlist de síntesis (`asic/rom/runs/final/06-yosys-synthesis/asic_top.nl.v`) | eqy 0.68, 30 particiones cortadas en registros, estrategias `sat` (inducción temporal, 5 pasos) y `pdr` (sby, abc pdr) | **29 de 30 particiones probadas** (las 29 por `sat`, cada una en menos de 2 s de CPU); la partición grande `asic_top.led.0` (807 salidas) queda sin decidir: `sat` agota sus 5 pasos ("equivalence unknown", 69 s) y `pdr` responde "partitions not equivalent" con un contraejemplo que parte de un estado inicial inalcanzable (sección 4.5). 106 s de reloj, 122 s de CPU y 3.301.276 KB de memoria máxima | `asic/eqy/resultados/sint_v1ff/eqy_resumen.md`, `eqy_particiones.md`, `eqy_tiempo.txt` |
| RTL contra netlist post-PnR sin celdas físicas (`asic/rom/runs/final/final/nl/asic_top.nl.v` sin fill, decap, tap ni endcap) | ídem | **29 de 30 probadas**, con la misma partición grande (799 salidas) sin decidir y por la misma razón. 152 s de reloj, 168 s de CPU y 3.312.736 KB de memoria | `asic/eqy/resultados/pnr_v1ff/eqy_resumen.md`, `eqy_particiones.md`, `eqy_tiempo.txt` |
| RTL contra netlist de síntesis, **flujo clásico de Yosys** (`equiv_make`, `equiv_simple -seq 2`, `equiv_induct -seq 4`) | yosys 0.68 | **PASS, y es la prueba que cierra el caso**: 976 celdas `$equiv` (de los 984 nombres comunes: 28 puertos y 961 salidas de flip-flop emparejadas), 5 probadas por `equiv_simple` y las 971 restantes por `equiv_induct`, 0 sin probar. 518 s de reloj y 598.144 KB de memoria | `asic/eqy/resultados/sint_v1ff/equiv_resumen.txt` |
| RTL contra netlist **post-PnR**, flujo clásico de Yosys | yosys 0.68 | **PASS**: 968 celdas `$equiv`, 5 probadas por `equiv_simple` y 963 por `equiv_induct`, 0 sin probar. 654 s de reloj y 606.844 KB | `asic/eqy/resultados/pnr_v1ff/equiv_resumen.txt` |
| RTL contra netlist de síntesis, miter completo desde reset, solo salidas | sby 0.68, `smtbmc yices`, BMC acotado | **PASS a 24 pasos** (26 s de reloj, 189.376 KB) y **PASS a 100 pasos** (1.731 s, 28 min 51 s, 971.392 KB), sin emparejar ningún nombre | `asic/eqy/resultados/sint_v1ff/bmc_24_resumen.txt` y `asic/eqy/resultados/sint_v1/bmc_100_resumen.txt` |
| **Control negativo** por `eqy`: netlist de síntesis con una celda cambiada en la ALU (`nand2_1` por `nor2_1` en la instancia `_0586_`) | eqy | **no discrimina**: da el mismo 29 de 30 que el netlist sin mutar, porque la partición que contiene la ALU es justamente la que queda sin decidir | `asic/eqy/resultados/mut_v1ff/eqy_resumen.md`, `gate_mut_diff.txt` |
| **Control negativo** por BMC desde reset, 24 pasos | sby | **no discrimina**: PASS. El bit del sumador que la mutación rompe no se ejercita en 24 ciclos desde reset | `asic/eqy/resultados/mut_v1ff/bmc_24_resumen.txt` |
| **Control negativo** por el flujo clásico de Yosys | yosys | **FAIL, como corresponde, y es el control que sí discrimina**: prueba 776 de las 976 celdas y deja **200 sin probar**, contra 976 de 976 en el netlist sin mutar | `build/eqy/mut_v1ff/equiv.log` (líneas 8988 y 8992) |
| Gold `v2` (`synth -flatten -noabc`) contra el netlist de síntesis | eqy | **no sirve como referencia**, igual que en v1: particiona en 978 trozos de una salida cada uno y prueba 193; 638 s de reloj y 3.694 s de CPU | `asic/eqy/resultados/sint_v2ff/eqy_resumen.md` |
| Paso `Yosys.EQY` de LibreLane 3.0.16 con su guion genérico (corridas `d2_eqy` y `d2_eqy_pnr`) | eqy 0.62 en la imagen | falla al leer el RTL: `ERROR: Can't open include file 'game_image.vh'!` | `asic/eqy/runs/d2_eqy/01-yosys-eqy/yosys-eqy.log`, `asic/logs/d2_eqy.log` |
| Paso `Yosys.EQY` con guion propio (`asic/eqy/flujo.eqy`, corrida `d2_eqy_script`) | eqy 0.62 en la imagen, RTLIL canónicos del anfitrión | lee los dos lados, combina y particiona igual que en el anfitrión y falla al correr las estrategias: la imagen no trae `make`, que eqy necesita para su `strategies.mk` | `asic/eqy/runs/d2_eqy_script/01-yosys-eqy/scratch/logfile.txt`, `asic/logs/d2_eqy_script.log` |

Qué significa cada resultado:

- **El flujo clásico de Yosys prueba la equivalencia completa.** `equiv_induct -seq 4` es una
  inducción temporal sobre todo el diseño: si el paso base y el paso inductivo cierran, las dos
  descripciones coinciden en todo estado **alcanzable** y toda secuencia de entradas, sin límite de
  profundidad. Cerró para las 976 celdas `$equiv`, que son 28 puertos y salidas de flip-flop emparejadas.
- **El miter desde reset lo confirma sin emparejar nombres**: fuerza `rst_n = 0` dos ciclos y
  compara solo `led`, `seg1`, `seg2` y `spi_miso` desde el ciclo 2.
- **Lo que eqy deja sin decidir no es un error del diseño, es el precio del método.** eqy corta el
  diseño en particiones por los registros con nombre común y prueba cada partición **para todo
  estado inicial**, incluidos los inalcanzables. El RTL de D23 tiene 41 bits de registro que la
  síntesis aplanada elimina (28 del registro de instrucción y 12 de `imm_target`, entre otros:
  `asic/eqy/resultados/sint_v1ff/ff_gold_sin_par.txt`), porque con la lectura anticipada el
  decodificador trabaja sobre la salida de la ROM y casi ningún bit del registro de instrucción se
  vuelve a leer. Esos registros quedan dentro de la partición grande con un valor libre en el lado
  del RTL y ninguno en el del netlist, y `pdr` encuentra un estado inicial donde los bits 20 y 21
  de la dirección de la ROM (es decir del PC, que se carga de `imm_target`) difieren en el paso 3.
  En v1 esos registros sin par eran 17 y la misma partición cerraba por `pdr` en 80 s
  (`asic/eqy/resultados_v1/sint_v1ff/eqy_particiones.md`). Detalle en 4.5.
- **El control negativo hay que leerlo con cuidado.** La mutación de una celda ya no la detecta
  eqy, porque cae dentro de la partición que no se decide, ni el BMC de 24 pasos, porque rompe el
  acarreo del bit 30 del sumador y el programa no genera operandos tan grandes en 24 ciclos desde
  reset. Sí la detecta el flujo clásico, que deja 200 celdas sin probar. O sea que **el método que
  prueba la equivalencia es también el que discrimina**, y los otros dos quedan como evidencia
  parcial.

## 2. Qué se compara y con qué herramientas

- Gold: el RTL de `rtl/*.v`, `rtl/espino_core/*.v` y `rtl/gen/pochoco_rom.v` con
  `MemStrategy = 1` y `DataWords = 4` (los parámetros de `asic/rom/config.yaml`), leído con
  `read_verilog -sv -I rtl/gen` y `hierarchy -top asic_top -chparam MemStrategy 1 -chparam DataWords 4`.
  Variante v1 (la de todos los resultados de la tabla): `proc; flatten; memory_map` y nada más,
  es decir el RTL tal como está escrito, sin optimizar: 2.614 celdas de alto nivel, 60 celdas de
  flip-flop (23 `$adff` y 37 `$dff`) con 1.004 bits de estado (`asic/eqy/resultados/stat_gold_v1.txt`).
  Variante v2: `synth -flatten -noabc` de Yosys (sección 5.3).
- Gate: el netlist de síntesis de la corrida final (5.118 instancias de celdas,
  `asic/rom/runs/final/06-yosys-synthesis/asic_top.nl.v`, con los módulos `espino_alu`,
  `espino_register_file` y `pochoco_cycle_counter` conservados por D12) y el netlist post-PnR
  (`asic/rom/runs/final/final/nl/asic_top.nl.v`, 20.822 instancias, de las que 14.932 son celdas
  sin función lógica: `fill_*`, `fillcap_*`, `filltie` y `endcap`, que se quitan con un filtro de
  texto; quedan 5.890: las 5.118 de síntesis más 772 buffers, inversores y celdas redimensionadas
  por el resizer, el CTS y el arreglo de hold: `buf_2/3/4`, `clkbuf_1/2/4/8/16`, `clkinv_2/3/8/12`,
  `inv_1/2/3/4` y `nor3_2`; `build/eqy/gate_pnr_filtro.txt`). El separador de jerarquía `/` de
  OpenROAD se cambia por `.` para que `u_soc.u_core.u_rf/regs[7][26]` case con el RTL.
- Modelos de las celdas: los modelos Verilog del PDK (`gf180mcu_fd_sc_mcu7t5v0.v`) usan primitivas
  UDP de `primitives.v`, que Yosys no lee. Las celdas se construyen con `read_liberty` (sin `-lib`)
  del liberty de la esquina típica,
  `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib`:
  Yosys crea un módulo por celda con la función lógica del atributo `function` de cada pin de
  salida y un `$_DFF_*` por cada grupo `ff()`. El liberty tiene 229 grupos `cell(` y se importan
  223 módulos; las 6 que faltan son exactamente las celdas de clock gating `icgtn_1/2/4` e
  `icgtp_1/2/4`, que no declaran función en sus salidas y no se usan en ninguno de los dos
  netlists de la corrida final (0 instancias de `icgt` en los dos `asic_top.nl.v`). Por eso
  `-ignore_miss_func` es imprescindible: sin él `read_liberty` corta con
  `ERROR: Missing function on output IQ3 of cell gf180mcu_fd_sc_mcu7t5v0__icgtn_1` y código 1.
  Con solo esa opción ya importa las 223, así que `-ignore_miss_dir` y `-ignore_miss_data_latch`,
  que el script pasa por seguridad, no hacen falta con Yosys 0.68+195 (las cuatro combinaciones
  probadas y el diferencial de celdas, en `build/eqy/prueba_sin_ignore_latch.log`, 28-10-2026).
  Después de `flatten`, el netlist de síntesis queda en 6.877 `$_AND_`, 4.602 `$_OR_`,
  11.821 `$_NOT_`, 186 `$_XOR_`, 804 `$_DFF_P_` y 186 `$_DFF_PP0_` (990 flip-flops, los mismos que
  cuenta `asic/final.md`); `asic/eqy/resultados/stat_gate_sint.txt`. Esto es independiente de
  los modelos UDP que usa `make post-synth`, así que las dos verificaciones no comparten el
  modelo de celda.
- Herramientas del anfitrión (oss-cad-suite, `~/herramientas/oss-cad-suite/bin`;
  `asic/eqy/resultados/versiones.txt`, que lo imprime `bash asic/eqy/correr.sh versiones`):
  Yosys 0.68+195 (git 435977e97), EQY v0.68-2-g4a72eb9, SBY v0.68, Yices 2.7.0, ABC 1.01
  (yosys-abc), `yosys-smtbmc` y el `make` de `/usr/bin/make`; también trae z3, boolector y
  bitwuzla, que no hicieron falta.
- Herramientas de la imagen `ghcr.io/librelane/librelane:3.0.16` (para el paso del flujo):
  EQY v0.62, SBY v0.62, Yosys 0.62, yosys-abc y yosys-smtbmc; no trae yices, z3, boolector ni
  bitwuzla, y tampoco `make` (`asic/eqy/resultados/imagen_herramientas.txt`, con el comando y la
  salida), así que ahí solo servirían las estrategias `sat` (yosys) y `pdr` (sby con abc), y ni esas
  llegan a correr (sección 3.2).

## 3. El paso Yosys.EQY de LibreLane

LibreLane 3.0.16 trae el paso experimental `Yosys.EQY` (`librelane/steps/yosys.py`, clase
`EQY`; variables `RUN_EQY`, `EQY_SCRIPT`, `EQY_FORCE_ACCEPT_PDK`), que en el flujo clásico va
después de `Netgen.LVS` y compara `VERILOG_FILES` con el netlist del estado de entrada. Solo
soporta sky130A; con `EQY_FORCE_ACCEPT_PDK: true` preprocesa los modelos del PDK con
`iverilog -E -DFUNCTIONAL` y, sin `EQY_SCRIPT`, genera un guion genérico (gold:
`read_verilog -formal -sv` de los archivos de RTL; gate: modelos preprocesados más netlist;
`prep -flatten`, `memory -nomap`, `async2sync`; estrategias `sat` depth 5, `pdr` con
`abc pdr -rfi` y `bitwuzla`). Configuración usada: `asic/eqy/config.yaml` (copia de
`asic/rom/config.yaml` con `RUN_EQY: true` y `EQY_FORCE_ACCEPT_PDK: true`).

### 3.1 Corridas d2_eqy y d2_eqy_pnr (guion genérico): fallan al leer el RTL

- `d2_eqy`: `bash asic/encolar.sh . asic/eqy/config.yaml d2_eqy 100 --from Yosys.EQY --to Yosys.EQY --with-initial-state .../asic/rom/runs/final/06-yosys-synthesis/state_out.json`
  (solo el paso, con el netlist de síntesis de la corrida final). Lanzada 14:10:10, fallida
  14:11:00 (`asic/logs/cola_estado.txt`).
- `d2_eqy_pnr`: `bash asic/encolar.sh . asic/eqy/config.yaml d2_eqy_pnr 100 --to Yosys.EQY`.
  Como el paso está después del LVS, `--to Yosys.EQY` corrió el flujo completo (71 pasos, 3 min,
  `asic/eqy/runs/d2_eqy_pnr/01-...71-checker-lvs`) y comparó contra el netlist post-PnR
  (`52-openroad-fillinsertion/asic_top.nl.v`). Lanzada 14:11:00, fallida 14:14:10.
- Las dos fallan en el mismo punto, al leer el RTL del lado gold
  (`asic/eqy/runs/d2_eqy/01-yosys-eqy/yosys-eqy.log` y `.../d2_eqy_pnr/72-yosys-eqy/yosys-eqy.log`):

      read_gold: ERROR: Can't open include file `game_image.vh'!
      read_gold: finished (returncode=1)
      read_gold: job failed. ERROR.
      read_gate: terminating process
      ERROR: Reading sources failed.

  y LibreLane termina con `Equivalence Check: subprocess (1, ['eqy', '-f', '.../asic_top.eqy', '-d', '.../scratch']) failed`.
  Causa: el guion genérico escribe `read_verilog -formal -sv <VERILOG_FILES>` sin el `-I` de
  `VERILOG_INCLUDE_DIRS` (`rtl/gen`), y `rtl/pochoco_mem_ff.v` incluye `game_image.vh`
  (`scratch/gold.log`: "Executing Verilog-2005 frontend: .../rtl/pochoco_mem_ff.v ... ERROR: Can't
  open include file `game_image.vh'!"). El guion generado está en
  `asic/eqy/runs/d2_eqy/01-yosys-eqy/asic_top.eqy` y los `gold.ys`/`gate.ys` que eqy deriva de él
  en `.../scratch/`.
- Aunque se corrigiera el include, el lado gate no podría leerse: `formal_pdk.v` (la salida de
  `iverilog -E -DFUNCTIONAL`, 345.990 bytes) conserva las cuatro primitivas UDP del PDK
  (`gf180mcu_fd_sc_mcu7t5v0__udp_hn_iq_ff`, `udp_hn_iq_latch`, `udp_n_iq_ff`, `udp_n_iq_latch`,
  líneas 39.811 a 39.944), y Yosys no soporta `primitive`. Por eso el paso dice en su propia
  documentación que con un PDK distinto de sky130A "will likely result in a failure".

### 3.2 Corrida d2_eqy_script (guion propio): particiona bien y se detiene por falta de make

Con `EQY_SCRIPT: dir::flujo.eqy` (`asic/eqy/flujo.eqy`), el paso copia el guion tal cual a
`asic/eqy/runs/d2_eqy_script/01-yosys-eqy/asic_top.eqy` y lo ejecuta con el eqy 0.62 de la imagen.
El guion lee los RTLIL canónicos de la variante `sint_v1ff` que deja
`bash asic/eqy/correr.sh preparar` en el anfitrión (sección 4), con rutas absolutas porque el
contenedor monta `$HOME` en la misma ruta, y usa las estrategias `sat` y `pdr`, las únicas posibles
en la imagen. Así se evitan de entrada los dos problemas de la sección 3.1: el `-I` que falta (el
RTL ya está leído y aplanado) y las primitivas UDP (las celdas vienen del liberty). Comando:
`bash asic/encolar.sh . asic/eqy/config.yaml d2_eqy_script 100 --from Yosys.EQY --to Yosys.EQY --with-initial-state .../asic/rom/runs/final/06-yosys-synthesis/state_out.json`.
Encolada 21:09:16, lanzada 22:31:08 y fallida con código 2 a las 22:31:58 del 27-10-2026
(`asic/logs/cola_estado.txt`, entrada 83); el flujo se detuvo en "Classic - Stage 75 - Equivalence
Check", 74 de 80 pasos (`asic/logs/d2_eqy_script.log`).

Las cuatro primeras fases de eqy terminan bien, con `returncode=0` y en 3 s de reloj
(`asic/eqy/runs/d2_eqy_script/01-yosys-eqy/scratch/logfile.txt`): `read_gold`, `read_gate`,
`combine` y `partition`. El particionado da exactamente lo mismo que en el anfitrión: 22
particiones en `scratch/partition.list` y 1.015 pares de señales en `scratch/matched.ids`, los
mismos dos números que `build/eqy/sint_v1ff/eqy/partition.list` y `matched.ids` de la corrida del
anfitrión (sección 4.5). La quinta fase, la que corre las estrategias, falla:

    run: starting process "make -C .../d2_eqy_script/01-yosys-eqy/scratch -f strategies.mk"
    run: bash: line 1: make: command not found
    run: finished (returncode=127)
    run: COMMAND NOT FOUND. ERROR.
    summary: Elapsed clock time [H:MM:SS (secs)]: 0:00:03 (3)
    DONE (ERROR, rc=16)

y LibreLane termina con
`Equivalence Check: subprocess (16, ['eqy', '-f', '.../asic_top.eqy', '-d', '.../scratch']) failed`.

Causa: eqy no corre las estrategias por sí mismo, sino con un Makefile que escribe él
(`strategies.mk`, que está en el directorio del paso); su tarea `run` es literalmente
`make{kopt}{jopt} -C {args.workdir} -f strategies.mk` (línea 1157 de
`~/herramientas/oss-cad-suite/libexec/eqy`, el eqy 0.68 del anfitrión; el 0.62 de la imagen hace lo
mismo, como se ve en el comando del log). Y la imagen `ghcr.io/librelane/librelane:3.0.16` no trae
`make`, ni `gmake`, ni `bmake`: un `command -v` de doce herramientas dentro de la imagen
(28-10-2026, comando y salida completa en `asic/eqy/resultados/imagen_herramientas.txt`) solo
encuentra `eqy` (EQY v0.62), `sby` (SBY v0.62), `yosys` (Yosys 0.62, git 7326bb7d6), `yosys-smtbmc`
y `yosys-abc`, todos del mismo paquete de nix; no están `make`, `gmake`, `bmake`, `yices`, `z3`,
`boolector` ni `bitwuzla`.
No hay manera de sortearlo desde la configuración: eqy no tiene opción para correr las estrategias
sin make (`-m/--setup` solo genera las particiones y los Makefiles y termina; `eqy --help`) y el
paso lo invoca sin opciones, `eqy -f <guion> -d <scratch>`
(`~/herramientas/librelane/lib/python3.14/site-packages/librelane/steps/yosys.py`, clase `EQY`).

Conclusión de los tres intentos por el flujo: en LibreLane 3.0.16 el paso `Yosys.EQY` no puede
completar una comprobación de equivalencia con esta imagen y este PDK, ni con su guion genérico
(falla al leer el RTL, y aunque se corrigiera el `-I` el lado gate tiene primitivas UDP que Yosys no
lee, sección 3.1) ni con un guion propio que le entregue los dos lados ya preparados (hace la parte
de Yosys y se detiene al llamar a make). Lo único aprovechable del paso es que su particionado
coincide con el del anfitrión. La prueba de equivalencia se hace, entonces, en el anfitrión con
`bash asic/eqy/correr.sh` (sección 4), donde están make, eqy 0.68 y yices. Hacerla correr dentro
del flujo pediría cambiar la imagen de LibreLane (agregar make), cosa que no se probó.

## 4. Método en el anfitrión (`asic/eqy/correr.sh`)

### 4.1 Preparación (`bash asic/eqy/correr.sh preparar`)

Genera en `build/eqy/` los dos lados en RTLIL y JSON: `gold_v1`, `gold_v2`, `gate_sint` y
`gate_pnr` (sección 2), todos con el mismo cierre `opt_clean; splitnets -ports; opt_clean`
(un wire por bit, como ya vienen los nombres del netlist: `\u_soc.u_core.u_rf.regs[7][26]`).
Después canoniza las variantes de la lista `VARIANTES`: existen las siete combinaciones
`sint_v1`, `sint_v2`, `pnr_v1`, `pnr_v2`, `sint_v1ff`, `sint_v2ff` y `pnr_v1ff`
(`asic/eqy/resultados/<variante>/canon_resumen.txt`), más `mut_v1ff` del control negativo.
De ellas se corrió eqy en cinco (`sint_v1`, `sint_v1ff`, `sint_v2ff`, `pnr_v1ff` y `mut_v1ff`:
son las que tienen `eqy_resumen.md`); de `sint_v2` y `pnr_v2` solo está la canonización, porque
las variantes sin el sufijo `ff` cortan en señales combinacionales y eso ya se mostró inservible
con `sint_v1` (sección 4.2), y el gold v2 quedó descartado con `sint_v2ff` (sección 5.3).

### 4.2 Canonización de nombres (`asic/eqy/canonizar.py`)

eqy empareja señales por nombre y usa las emparejadas como puntos de corte de las
particiones. Dos problemas aparecieron en los primeros intentos:

1. Alias. En el RTL aplanado una misma red tiene varios nombres (`u_soc.u_core.lsu_addr[2]` y
   `u_soc.u_core.u_id.u_alu.result_o[2]` son la misma red; 690 redes del gold y 5.108 del gate
   tienen más de un nombre). eqy empareja cada nombre por separado y los mete a la partición como
   entradas libres independientes, y el solver encuentra contraejemplos falsos (en
   `build/eqy/sint`, la primera corrida sin canonizar, `led.0` falla con `lsu_addr[2] = 0` y
   `result_o[2] = 1` en el mismo paso). Resultado de esa corrida: 432 particiones, 277 probadas,
   155 no probadas (96 contraejemplos de `sat`, 59 "equivalence unknown"), FAIL en 35 s
   (`build/eqy/eqy_sint.log`).
   `canonizar.py` lee los JSON, agrupa los nombres por red y deja un solo nombre público por red
   común a los dos lados (primero los puertos, después los que son salida de flip-flop en los
   dos lados, después el más corto); los demás pasan a nombres privados (`$alias_N`), que eqy no
   empareja.
2. Cortes inconsistentes. Con todos los nombres comunes como cortes (variante `sint_v1`: 48
   particiones, 43 probadas, 5 no, FAIL en 25 s, `asic/eqy/resultados/sint_v1/eqy_resumen.md`),
   señales combinacionales intermedias como `stall` o `lsu_busy` entran a otras particiones como
   entradas libres, y el solver elige combinaciones imposibles: en la partición de `rf_we` el
   contraejemplo tiene `instr_valid_id = 1`, `rf_ready = 0` y `stall = 0`, cuando en el diseño
   `stall = (instr_valid_id & ~rf_ready) | lsu_busy` vale 1; en la de `stall`, `lsu_busy = 1` con
   `busy_q = 1`, imposible porque `lsu_busy = is_load & ~busy_q`
   (`build/eqy/sint_v1/eqy/strategies/asic_top.u_soc.u_core.rf_we/sat/run.log`, línea
   "model found for base case: FAIL!" y la tabla de señales que sigue). Las otras tres
   (`pc_id.0`, `per_rdata.0`, `led.0`) quedan "unknown" en `sat` y FAIL en `pdr` por lo mismo.
   La opción `--solo-ff` oculta además todo nombre común que no sea puerto ni salida de
   flip-flop en los dos lados (132 nombres en `sint_v1ff`), de modo que eqy corta solo en
   registros y cada partición es el cono combinacional completo entre registros.

Para `sint_v1ff` (`asic/eqy/resultados/sint_v1ff/canon_resumen.txt`): 1.402 nombres comunes
antes de canonizar, 1.010 después (puertos y salidas de flip-flop); 987 de los 1.004 bits de
estado del gold y 987 de los 990 del gate quedan emparejados. Los 17 del gold sin par
(`ff_gold_sin_par.txt`) son registros que la síntesis eliminó o fusionó legítimamente:
`imm_target[20]` a `[31]` (doce copias del bit de signo, iguales entre sí y a
`imm_operand[31]`), `imm_target[0]` (siempre 0 en inmediatos de salto), `instr_rdata[1]`
(el bit 1 de toda instrucción RV32 vale 1; la síntesis lo convirtió en un flip-flop con set
sincrónico, `yosys-synthesis.log` línea 2912), y `lsu_type[1]`, `alu_op_a_sel[0]` y
`rf_wd_sel[0]`, bits de tres registros de 2 bits que el pase `fsm` de la síntesis recodificó
a one-hot de 3 bits (`yosys-synthesis.log`, líneas 1005 a 1147: "Found FSM state register
asic_top.u_soc.u_core.u_id.alu_op_a_sel / lsu_type_dec / rf_wd_sel", "mapping auto encoding
to one-hot", `00 -> --1`, `10 -> -1-`, `01 -> 1--`; `alu_operator` no se recodificó: "Users
of register don't seem to benefit from recoding"). Los 3 del gate sin par
(`ff_gate_sin_par.txt`: `_2047_.I`, `_2115_.I` y `_4191_.Q`) son los bits nuevos de esa
recodificación: las redes `u_soc.u_core.u_id.lsu_type_dec[2]`, `u_soc.u_core.u_id.rf_wd_sel[2]`
y `u_soc.u_core.u_id.alu_op_a_sel[2]` del netlist de síntesis (líneas 2754, 3026 y 14964 de
`asic/rom/runs/final/06-yosys-synthesis/asic_top.nl.v`; en los dos primeros el nombre que quedó
es el del pin de entrada del inversor `clkinv_1` que cuelga de la salida del flip-flop).
Estos registros quedan como estado interno de la partición que los contiene, que por eso es
grande (sección 4.5) y necesita `pdr`.

### 4.3 Configuración de eqy (`asic/eqy/plantilla.eqy`)

`[gold] read_rtlil build/eqy/<variante>/gold.il`, `[gate] read_rtlil .../gate.il` y tres
estrategias en orden (eqy se detiene en la primera que prueba cada partición):
`sat` (`use sat`, `depth 5`, que eqy traduce al comando de Yosys
`sat -tempinduct -set-init-undef -set-def-formal -set-def-inputs -maxsteps 5 -set-assumes
-prove-asserts -show-public -dump_vcd trace.vcd miter` sobre el miter de la partición;
`build/eqy/sint_v1ff/eqy/strategies/<partición>/sat/run.ys`), `pdr` (`use sby`,
`engine abc pdr`: prueba no acotada por IC3/PDR) y `smt` (`use sby`, `engine smtbmc yices`,
`depth 5`). Se corre con `eqy -j 8 -f build/eqy/<variante>/asic_top.eqy -d build/eqy/<variante>/eqy`
(las dos corridas principales, `sint_v1ff` y `pnr_v1ff`, se lanzaron con `J=8`:
`build/eqy/sint_v1ff_canon_eqy.out` y `build/eqy/pnr_v1ff_sint_v2ff.out`; el valor por omisión
del script es 6, que es el que usaron `sint_v1` y `mut_v1ff`).

### 4.4 Qué prueba exactamente eqy

Para cada partición eqy arma un miter con las dos copias del cono (gold y gate), cuyas
entradas son los puntos de corte (puertos y salidas de registros emparejados, libres pero
iguales en los dos lados, y supuestas definidas: módulo `miter_def_prop`), y afirma por cada
salida comparada `okay = (in_gold === 1'bx) || (in_gold === in_gate)` (módulo
`miter_cmp_prop`, `build/eqy/<variante>/eqy/partitions/<partición>.sv`). En el lado gate los
flip-flops parten en un valor libre (`formalff -ff2anyinit`, `setundef -anyseq`); en el gold
los registros sin reset parten en x (`sat -set-init-undef`; en `pdr`, `xprop -formal
-split-ports -assume-def-inputs`). Así la equivalencia es: para cualquier estado inicial y
cualquier secuencia de entradas, cada salida de la partición coincide en todo ciclo en que su
valor en el RTL está definido. Es la semántica correcta para este diseño, cuyo banco de
registros, registro de instrucción, pre-decodificación y salida de la RAM no tienen reset
(decisiones D4 y D18): un registro sin reset se compara desde el ciclo en que se carga.
`sat` hace inducción temporal de hasta 5 pasos; `pdr` prueba un invariante inductivo sin
límite de profundidad.

### 4.5 Resultado de sint_v1ff: 29 de 30 particiones, y por qué la que falta no cierra

30 particiones. **29 probadas por `sat`**, cada una en menos de 2 s de CPU. La que falta es la
grande, `asic_top.led.0`, que compara **807 salidas**: los LEDs y, por los registros recodificados y
los que no tienen par, también el banco de registros, el registro de instrucción, el decode
registrado, el PC, la RAM, `digit_q`, `per_rdata` y las demás señales del core. Con ella, `sat`
agota sus 5 pasos sin decidir ("Reached maximum number of time steps -> proof failed", 69,3 s de
reloj y 3.223,9 MB de pico, `build/eqy/sint_v1ff/eqy/strategies/asic_top.led.0/sat/run.log`) y
`pdr` responde "partitions not equivalent" en 32 s, con un contraejemplo
(`.../pdr/asic_top.led.0/engine_0/{trace.vcd,trace_tb.v,logfile.txt}`) que falla en el **paso 3**
sobre dos asserts: los bits **20 y 21 de `u_soc.g_mem_rom.u_mem.a_addr_i`**, es decir del PC.
Total 106 s de reloj y 122 s de CPU según eqy; 106,32 s y 3.301.276 KB según `/usr/bin/time`.
Tabla por partición en `asic/eqy/resultados/sint_v1ff/eqy_particiones.md`.

**La causa es estructural y está medida.** La canonización informa que el gold tiene **1.005 bits de
flip-flop y el gate 964**, con **961 emparejados**: quedan **44 bits del gold sin par** y 3 del gate
(`canon_resumen.txt`, `ff_gold_sin_par.txt`, `ff_gate_sin_par.txt`). En v1 los del gold sin par eran
17. Los 27 nuevos son **28 bits de `u_soc.instr_rdata`** (el registro de instrucción) menos uno que
ya estaba: con `EarlyRead = 1` el decodificador trabaja sobre `instr_next_i`, la salida combinacional
de la ROM, y del registro de instrucción solo se siguen leyendo los bits de `rd` y los que usa el
write-back, así que la síntesis aplanada elimina el resto propagando constantes. Los otros que ya
estaban en v1 son `imm_target[0]` y `imm_target[20..31]`, `lsu_type[1]`, `alu_op_a_sel[0]` y
`rf_wd_sel[0]`.

Y ahí está el contraejemplo: **el PC se carga de `pc_target_i`, que es `imm_target`**, y los bits 20
y 21 de `imm_target` son dos de los registros que el gate no tiene. En el lado del RTL parten con un
valor libre, en el del netlist no existen, así que `pdr` puede elegir un estado inicial en que el PC
del RTL tiene el bit 20 en 1 y el del netlist no. **Ese estado es inalcanzable**: el programa ocupa
115 palabras (460 bytes) y el PC nunca pasa de 0x1CC, así que los bits 20 y 21 del PC valen 0 en
todo estado que se alcance desde reset. Por eso el resultado no es un error del diseño sino el
límite de comparar partición por partición sin restringir el estado inicial, y por eso la prueba que
vale es la de la sección 5.5 (inducción sobre estados alcanzables) junto con la de la 5.4 (desde
reset).

Para que quede dicho sin ambigüedad: **eqy no encontró ningún contraejemplo alcanzable**; lo que
encontró es que no puede probar esa partición para todo estado inicial. Las otras 29 particiones son
los contadores (`cycles_q` de 32 bits, `u_tick.cnt` de 15), `pc_id`, `imm_operand`, `waddr_i`, los
sincronizadores y el debounce de los botones, `rst_sync_q`, `seg1`, `seg2`, las señales de control
del decode (`lsu_sign`, `lsu_we`, `alu_op_b_sel`, `is_branch`, `is_jal`, `is_jalr`, `lsu_req_dec`,
`rf_we_dec`), `busy_q` y `spi_miso`.

## 5. Las demás corridas

### 5.1 Netlist post-PnR sin celdas físicas (pnr_v1ff)

Mismo gold v1 y misma canonización `--solo-ff` contra `build/eqy/gate_pnr_sin_fisicas.nl.v`
(sección 2). Quedan 976 nombres comunes; **953 de los 1.005 bits de estado del gold y 953 de los
964 del gate tienen par**, así que hay 52 del gold sin par y 11 del gate
(`asic/eqy/resultados/pnr_v1ff/canon_resumen.txt`): a los 44 del gold de la síntesis se suman 8 más,
cuyas redes de salida de flip-flop OpenROAD renombró al insertar buffers. Resultado: **29 de 30
particiones probadas por `sat`**, y la misma partición grande `asic_top.led.0` (799 salidas) sin
decidir, por la misma razón de la sección 4.5. Total 152 s de reloj, 168 s de CPU y 3.312.736 KB de
memoria máxima (`eqy_resumen.md`, `eqy_tiempo.txt`). Las celdas que el PnR redimensionó y los
buffers que insertó quedan dentro de los conos y se comprueban como lógica.

### 5.2 Control negativo (mut_v1ff): cuál de los tres métodos discrimina

`bash asic/eqy/correr.sh mutar`: copia el netlist de síntesis cambiando **una sola celda**, la
instancia `_0586_` del módulo `espino_alu`, de `gf180mcu_fd_sc_mcu7t5v0__nand2_1` a
`gf180mcu_fd_sc_mcu7t5v0__nor2_1` (mismos pines `A1`, `A2`, `ZN`; `diff` de 2 líneas en
`asic/eqy/resultados/mut_v1ff/gate_mut_diff.txt`). La celda calcula
`nand(operand_b_i[30], operand_a_i[30])`, que es parte del acarreo del bit 30 del sumador: la
mutación cambia el resultado de la suma para todos los operandos en que esos dos bits valen lo
mismo. Es un error real de una celda entre 5.577 (`asic/rom/resultados/final/sintesis_stat.json`,
`num_cells`).

Los tres métodos se corrieron sobre el diseño mutado y dieron tres respuestas distintas, que es la
información útil de este control:

| método | sobre el netlist sin mutar | sobre el netlist mutado | ¿discrimina? |
|---|---|---|---|
| eqy (30 particiones) | 29 probadas, `led.0` sin decidir | 29 probadas, `led.0` sin decidir (77 s) | **no**: la mutación cae dentro de la única partición que no se decide, así que el resultado es idéntico |
| BMC desde reset, 24 pasos | PASS (26 s) | PASS (27 s) | **no**: el acarreo del bit 30 no se ejercita en 24 ciclos desde reset, porque el programa no usa operandos tan grandes |
| flujo clásico de Yosys (`equiv_simple -seq 2` más `equiv_induct -seq 4`) | **976 de 976 probadas** | **776 de 976 probadas, 200 sin probar** | **sí** |

Archivos: `asic/eqy/resultados/mut_v1ff/eqy_resumen.md` y `bmc_24_resumen.txt`;
`build/eqy/mut_v1ff/equiv.log`, líneas 8988 ("Proved 771 previously unproven $equiv cells") y 8992
("Of those cells 776 are proven and 200 are unproven").

Lo que hay que concluir, dicho entero: **el control negativo pasa, pero solo con el método que
también da la prueba**. En v1 el control funcionaba con eqy (22 de 22 sin mutar contra 21 de 22
mutado) y eso ya no sirve, porque con este RTL la partición grande no se decide en ninguno de los
dos casos. El BMC acotado es un método de profundidad fija y este control muestra justamente su
límite: 24 ciclos desde reset no alcanzan a mover el bit 30 del sumador. El flujo clásico, que es
el que prueba la equivalencia por inducción, es el que detecta el cambio de una celda, y la
diferencia es grande y sin ambigüedad: 0 celdas sin probar contra 200.

### 5.3 Gold v2 (synth -flatten -noabc): sigue sin servir como referencia

La variante v2 pasa el RTL por `synth -flatten -noabc` para que el gold tenga las mismas
optimizaciones de alto nivel que la síntesis de LibreLane (`fsm`, `opt_dff`, `opt_merge`,
`wreduce`, `alumacc`), y en efecto alinea casi todos los registros: quedan 9 bits del gold sin par
contra los 44 de la variante v1 (`asic/eqy/resultados/sint_v2ff/canon_resumen.txt` y
`ff_gold_sin_par.txt`). Se volvió a probar en esta vuelta justamente por eso, porque alinear los
registros es lo que haría cerrar la partición grande. **No sirve, por el mismo motivo que en v1**:
el pase `fsm` recodifica `alu_operator` a one-hot, cosa que la síntesis de LibreLane no hace porque
la ALU es un módulo con jerarquía conservada, así que `alu_operator[0]` a `[3]` existen en los dos
lados con distinto significado y todo lo que está aguas abajo de la ALU da contraejemplos falsos.
El resultado medido es peor que con el gold v1: **978 particiones de una salida cada una (eqy no
agrupa los bits de un registro con este gold) y solo 193 probadas**, con 785 en "equivalence
unknown" por `sat` y "partitions not equivalent" por `pdr`, en 638 s de reloj y 3.694 s de CPU
(`asic/eqy/resultados/sint_v2ff/eqy_resumen.md`, `eqy_particiones.md`, `eqy_tiempo.txt`).
Conclusión, igual que en v1: el gold tiene que ser el RTL sin optimizar.

### 5.4 Miter completo desde reset (BMC acotado)

`asic/eqy/miter_reset.py` genera un módulo que instancia el gold y el gate canónicos, fuerza
`rst_n = 0` en los ciclos 0 y 1 y lo deja libre después, deja libres los botones y las entradas
SPI, y desde el ciclo 2 afirma que `led`, `seg1`, `seg2` y `spi_miso` coinciden; ningún flip-flop
tiene valor inicial, así que cada registro parte con un valor libre e independiente en cada lado.
El miter está en `asic/eqy/resultados/<variante>/miter_reset.sv` y la configuración de sby, en la
primera parte de cada `bmc_<profundidad>_resumen.txt`. sby en modo `bmc` con el motor
`smtbmc yices`:

| variante | gate | profundidad | resultado | reloj | memoria máxima (KB) | archivo de origen |
|---|---|---|---|---|---|---|
| `sint_v1ff` | netlist de síntesis | 24 pasos | **PASS** | 26,8 s | 189.376 | `asic/eqy/resultados/sint_v1ff/bmc_24_resumen.txt` |
| `pnr_v1` | post-PnR sin celdas físicas | 24 pasos | **PASS** | 26,5 s | 189.372 | `asic/eqy/resultados/pnr_v1/bmc_24_resumen.txt` |
| `mut_v1ff` | síntesis con una celda cambiada | 24 pasos | **PASS, o sea que no detecta la mutación** | 26,5 s | 197.772 | `asic/eqy/resultados/mut_v1ff/bmc_24_resumen.txt` |
| `sint_v1` | netlist de síntesis | **100 pasos** | **PASS** | 1.731 s (28 min 51 s) | 971.392 | `asic/eqy/resultados/sint_v1/bmc_100_resumen.txt` |

Es una comprobación acotada y de salidas solamente (en 24 ciclos el programa recién pasa sus
primeras instrucciones); su valor es que **no depende de ningún emparejamiento de nombres** entre
los dos lados, así que confirma el resultado del flujo clásico sin compartir su supuesto más
delicado. Su límite lo muestra la tercera fila, y conviene decirlo con todas las letras: a 24
pasos no alcanza a distinguir un netlist con una celda mal puesta en el acarreo del bit 30 del
sumador, porque el programa no genera operandos tan grandes tan pronto. El costo por paso crece
rápido con la profundidad, así que llevar el BMC a los miles de ciclos que simula
`make post-synth` no es practicable por esta vía.

### 5.5 Flujo clásico de Yosys (equiv_make, equiv_simple, equiv_induct): la prueba que cierra el caso

`bash asic/eqy/correr.sh equiv sint_v1ff` (`build/eqy/sint_v1ff/equiv.ys`): lee los dos RTLIL
canónicos, `async2sync`, `equiv_make gold gate equiv` (una celda `$equiv` por cada señal con el
mismo nombre en los dos lados y con driver en los dos: **976**, de los 984 nombres comunes que deja
la canonización, que son los 28 puertos y 961 salidas de flip-flop emparejadas,
`asic/eqy/resultados/sint_v1ff/canon_resumen.txt`), `equiv_simple -seq 2` (SAT por celda sobre su cono desenrollado 2 pasos, con las
demás `$equiv` supuestas iguales) y `equiv_induct -seq 4` (inducción temporal sobre todo el
diseño).

Resultado (`asic/eqy/resultados/sint_v1ff/equiv_resumen.txt`): `equiv_simple` probó **5** de las
976 (las que se resuelven con un cono de 2 pasos) y `equiv_induct` probó **las 971 restantes**: la
inducción falla en los pasos 1 y 2 y **se cumple en el paso 3** (1.922.811 cláusulas sobre 739.832
variables, `build/eqy/sint_v1ff/equiv.log` líneas 8012 y 8013). `equiv_status` final: **976
probadas, 0 sin probar**. 518,26 s de reloj, 510,77 s de CPU y 598.144 KB de memoria máxima
(`/usr/bin/time`).

Qué significa, según la propia ayuda de `equiv_induct`: los dos circuitos no divergen una vez que
han producido valores iguales en los 976 puntos observables durante 3 ciclos ("weak definition of
equivalence"); combinado con el miter desde reset de la sección 5.4, que muestra que arrancan
sincronizados desde el reset sin emparejar ningún nombre, es la prueba de que siguen iguales para
siempre. **Es el resultado que sostiene la equivalencia de este diseño**, y el control negativo de
la sección 5.2 muestra que discrimina: sobre el netlist con una celda cambiada deja 200 de las 976
sin probar.

**Lo mismo contra el netlist post-PnR sin celdas físicas** (`TMAX=1500 bash asic/eqy/correr.sh
equiv pnr_v1ff`): **PASS, 968 de 968 celdas `$equiv` probadas**, 5 por `equiv_simple` y 963 por
`equiv_induct`, 0 sin probar, en 654,28 s de reloj y 606.844 KB de memoria máxima
(`asic/eqy/resultados/pnr_v1ff/equiv_resumen.txt`). Son 968 y no 976 porque el PnR renombró ocho
salidas de flip-flop al insertar buffers (sección 5.1). Con eso **los dos netlists de la corrida
final quedan probados equivalentes al RTL por inducción**, no solo el de síntesis.

Lo único que no se repitió en esta vuelta es el primer intento sin canonizar, que está documentado
en `docs/equivalencia_v1.md` y no depende del diseño.

## 6. Qué queda probado y qué no

**Probado.** **Los dos netlists de la corrida final, el de síntesis y el post-PnR sin celdas
físicas, son equivalentes al RTL** de `asic_top` con `MemStrategy = 1`, `DataWords = 4` y
`EarlyRead = 1`, y lo prueba el flujo clásico de Yosys: contra el de síntesis, las 976 celdas
`$equiv` (los 28 puertos del chip y las salidas de flip-flop emparejadas) quedan probadas, 5 por
`equiv_simple -seq 2` y 971 por `equiv_induct -seq 4`, que cierra la inducción en el paso 3; contra
el post-PnR, las 968 celdas `$equiv`, 5 y 963, también todas. Eso quiere decir que, una vez que los dos circuitos coinciden en esos 976 puntos durante
tres ciclos, no vuelven a divergir nunca, para cualquier secuencia de entradas. El miter completo
desde reset lo confirma por otra vía y sin emparejar nombres: a 24 pasos las cuatro salidas del chip
coinciden contra el netlist de síntesis y contra el post-PnR, y **a 100 pasos** contra el de
síntesis, con `rst_n` forzado dos ciclos y los botones y el SPI libres. Y eqy prueba 29 de sus 30 particiones, entre
ellas todos los contadores, el PC de la etapa ID, el inmediato, los sincronizadores, el debounce,
los displays y todas las señales de control del decode.

**Lo que esta vuelta NO logra probar, y por qué.** eqy deja sin decidir su partición grande
(`asic_top.led.0`, 807 salidas contra el netlist de síntesis y 799 contra el post-PnR), que
contiene el banco de registros, la memoria, la ALU y el PC. El motivo es estructural y está medido
en la sección 4.5: el RTL tiene 44 bits de registro que el netlist no tiene, 27 más que en v1,
porque con la lectura anticipada el decodificador trabaja sobre la salida de la ROM y la síntesis
elimina los bits del registro de instrucción que ya nadie lee. eqy prueba cada partición para
**todo** estado inicial, incluidos los inalcanzables, y con esos registros libres de un solo lado
`pdr` encuentra un estado inicial en que los bits 20 y 21 del PC difieren en el paso 3. Ese estado
no se alcanza desde reset: el programa ocupa 115 palabras y el PC nunca pasa de 0x1CC. Dicho de
otro modo: **no hay ningún contraejemplo alcanzable; hay una partición que este método no puede
cerrar**. En v1 esa misma partición cerraba, así que esto es una pérdida de cobertura respecto de
v1 que hay que informar, no esconder.

**Lo que hay que decir en la defensa si preguntan.** La equivalencia formal del diseño nuevo se
sostiene en la inducción temporal (flujo clásico) más el miter desde reset, no en eqy; eqy aporta
29 particiones probadas y una que no cierra por el estado inicial libre. Y el control negativo
confirma que el método que prueba es el que discrimina: con una sola celda de la ALU cambiada, el
flujo clásico deja 200 celdas sin probar, mientras eqy da el mismo resultado que sin mutar y el BMC
de 24 pasos pasa igual.

**No cubierto por ningún método de este documento**: el árbol de reloj y la polaridad del reloj
(los pases `sat`, `pdr` e `induct` avanzan todos los flip-flops a la vez e ignoran la señal de
reloj), la temporización (la cubre el STA de las 9 esquinas,
`asic/rom/resultados/final/cierre.md`, y la simulación con retardos anotados,
`asic/sim/resultado_sdf.md`) y las celdas físicas que se quitan del netlist post-PnR (las cubre el
LVS). Los modelos de celda son las funciones del liberty típico, no los modelos Verilog con UDP del
PDK.

**Supuestos**: que `read_liberty` de Yosys interpreta bien los atributos `function` y `ff` del
liberty, y que la canonización de nombres solo renombra wires sin cambiar lógica. Lo segundo lo
respalda el control negativo, que detecta un cambio de una celda a través de la misma canonización.

## 7. Comparación con la verificación por simulación

| | `make post-synth` / `make post-synth-final` (`asic/sim/README.md`) | `make post-pnr-sdf` / `make post-pnr-cvc` | `make equiv` | Esta equivalencia formal |
|---|---|---|---|---|
| Qué compara | RTL contra netlist (síntesis o post-PnR) con un escenario de estímulos | ídem con retardos SDF | RTL actual contra el RTL de otro commit con `sw/isa_test.s` | RTL contra netlist para todas las entradas y estados |
| Modelo de celda | Verilog del PDK con UDP (`-DFUNCTIONAL`) | Verilog del PDK con `specify` | no aplica | funciones del liberty típico |
| Cobertura | 4.500 ciclos (sim, 17 cambios de salida) o 320.000 (final, 3 líneas de traza) | 4.500 ciclos por esquina | 46 escrituras al banco, 22 accesos al bus y 2 salidas por estrategia con `isa_test`; 348 / 63 / 2 con `hazard_test` | exhaustiva por inducción con el flujo clásico; eqy deja una partición sin decidir (sección 6) |
| Temporización | no | sí (Icarus anota, CVC además evalúa los checks) | no | no |
| Tiempo | minutos | minutos por esquina | minutos | eqy 1,8 min (síntesis) y 2,5 min (post-PnR); flujo clásico 8,6 min; miter desde reset 27 s |

Las dos verificaciones se complementan: la simulación usa los modelos del fabricante con
retardos y un escenario real; la equivalencia formal cubre todos los escenarios con otro modelo
de celda y sin tiempo. Y con este diseño hay una tercera cosa que decir: **el control negativo de
la sección 5.2 muestra que ni eqy ni el BMC acotado detectan una celda mal puesta en el acarreo del
bit 30 del sumador, y la simulación del juego tampoco la detectaría**, porque el programa no genera
operandos tan grandes. La única de las cuatro que la detecta es la inducción del flujo clásico. Es
el argumento de por qué vale la pena correr los métodos formales además de simular.

Origen de los números de la fila "Cobertura": 4.500 y 320.000 ciclos y los 17 cambios de salida,
`asic/sim/README.md` y `asic/sim/resultado.md`; los eventos de `make equiv`,
`docs/verificacion/integracion_03_equiv_isa_v1.txt` y `_04_equiv_hazard_test_v1.txt`; los tiempos
de la última fila, `eqy_tiempo.txt` de `sint_v1ff` y `pnr_v1ff`, `equiv_tiempo.txt` y
`bmc_24_resumen.txt`.

## 8. Reproducción

    export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH   # lo hace el propio script
    bash asic/eqy/correr.sh versiones         # versiones y rutas de las herramientas (resultados/versiones.txt)
    bash asic/eqy/correr.sh preparar          # gold v1/v2, gate sint/pnr y las variantes canónicas (build/eqy/)
    J=8 bash asic/eqy/correr.sh eqy sint_v1ff # RTL contra síntesis, cortes en registros (el resultado principal)
    J=8 bash asic/eqy/correr.sh eqy pnr_v1ff  # RTL contra post-PnR sin celdas físicas
    bash asic/eqy/correr.sh mutar             # aplica la mutacion y corre eqy (con este RTL NO discrimina)
    bash asic/eqy/correr.sh equiv mut_v1ff    # el control negativo que si discrimina (200 de 976 sin probar)
    BMC_PROF=24 bash asic/eqy/correr.sh bmc mut_v1ff   # el BMC acotado tampoco discrimina (seccion 5.2)
    BMC_PROF=24 bash asic/eqy/correr.sh bmc sint_v1     # miter desde reset, 24 pasos (y pnr_v1)
    BMC_PROF=100 bash asic/eqy/correr.sh bmc sint_v1    # el mismo miter a 100 pasos (23 min)
    bash asic/eqy/correr.sh equiv sint_v1ff   # flujo clásico equiv_*, tope TMAX=2400 s
    bash asic/eqy/correr.sh equiv pnr_v1ff    # el mismo flujo contra el post-PnR (8 min)
    bash asic/eqy/correr.sh todo              # preparar, eqy de todas las variantes, equiv y bmc
    # paso del flujo (cola de LibreLane, desde la raíz del repo):
    bash asic/encolar.sh . asic/eqy/config.yaml d2_eqy_script 100 --from Yosys.EQY --to Yosys.EQY \
        --with-initial-state $PWD/asic/rom/runs/final/06-yosys-synthesis/state_out.json

El objetivo `todo` no es exactamente la lista de arriba: corre `preparar`, eqy de todas las
variantes de `VARIANTES`, `equiv sint_v1ff` y `bmc sint_v1ff` (el BMC de la tabla se corrió sobre
`sint_v1`; da lo mismo, porque el miter solo usa los puertos).

Variables: `J` (hilos de eqy, 6), `TMAX` (2400), `SEQ_SIMPLE` (2), `SEQ` (4), `BMC_PROF` (24),
`VARIANTES`. Los resúmenes quedan en `asic/eqy/resultados/<variante>/`; los logs completos en
`build/eqy/` (no se versionan). Archivos: `asic/eqy/correr.sh`, `canonizar.py`,
`plantilla.eqy`, `resumir_eqy.py`, `miter_reset.py`, `config.yaml`, `flujo.eqy`; resultados
sueltos: `asic/eqy/resultados/versiones.txt`, `imagen_herramientas.txt`, `stat_gold_v1.txt`,
`stat_gold_v2.txt`, `stat_gate_sint.txt` y `stat_gate_pnr.txt`.
