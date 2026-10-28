# Equivalencia formal entre el RTL y los netlists de la corrida final (frente D2)

Comprueba con métodos formales (eqy, sby y los pases `equiv_*` y `sat` de Yosys) que el
netlist de celdas estándar que entrega LibreLane implementa la misma función que el RTL de
`asic_top`, para todas las entradas y no solo para el escenario de `make post-synth`. Todo lo
que hay aquí salió de corridas reales; los comandos se repiten con `bash asic/eqy/correr.sh`
(sección 8). Fechas: las corridas de eqy, del flujo clásico de Yosys y del paso del flujo son del
27-10-2026; el BMC de 24 y de 100 ciclos de `sint_v1`, las pruebas de `read_liberty` y la
inspección de la imagen de LibreLane, del 28-10-2026.

## 1. Resumen

| Comparación | Método | Resultado | Archivo de origen |
|---|---|---|---|
| RTL contra netlist de síntesis (`asic/rom/runs/final/06-yosys-synthesis/asic_top.nl.v`) | eqy 0.68, 22 particiones cortadas en registros, estrategias `sat` (inducción temporal, 5 pasos) y `pdr` (sby, abc pdr) | **PASS**: las 22 particiones probadas (21 por `sat`, 1 por `pdr`), 118 s de reloj y 125 s de CPU según eqy, 2.640.744 KB de memoria máxima | `asic/eqy/resultados/sint_v1ff/eqy_resumen.md`, `eqy_particiones.md`, `eqy_tiempo.txt` |
| RTL contra netlist post-PnR sin celdas físicas (`asic/rom/runs/final/final/nl/asic_top.nl.v` sin fill, decap, tap ni endcap) | ídem | **PASS**: las 21 particiones probadas (20 por `sat`, 1 por `pdr`), 387 s de reloj y 394 s de CPU según eqy, 3.021.192 KB de memoria máxima | `asic/eqy/resultados/pnr_v1ff/eqy_resumen.md`, `eqy_particiones.md`, `eqy_tiempo.txt` |
| Control negativo: netlist de síntesis con una celda cambiada en la ALU (`nand2_1` por `nor2_1`) | ídem | **FAIL, como corresponde**: `pdr` encuentra un contraejemplo de 12 ciclos en la partición que contiene la ALU (`led[2]`, `led[3]` y 10 bits de la RAM difieren); las otras 21 particiones pasan | `asic/eqy/resultados/mut_v1ff/eqy_resumen.md`, `gate_mut_diff.txt` |
| RTL contra netlist de síntesis y contra el post-PnR, miter completo desde reset, solo salidas | sby 0.68, `smtbmc yices`, BMC acotado | **PASS**: 24 pasos contra los dos netlists (24,4 s y 33,6 s) y 100 pasos contra el de síntesis (1.394 s, 932.200 KB), sin emparejar nombres | `asic/eqy/resultados/sint_v1/bmc_24_resumen.txt` y `bmc_100_resumen.txt`, `asic/eqy/resultados/pnr_v1/bmc_24_resumen.txt` |
| RTL contra los dos netlists, flujo clásico de Yosys (`equiv_make`, `equiv_simple -seq 2`, `equiv_induct -seq 4`) | yosys 0.68 | **PASS** en los dos: contra la síntesis, 1.002 celdas `$equiv` (puertos y registros), 3 probadas por `equiv_simple` y 999 por `equiv_induct` (la inducción cierra en el paso 4), 515 s de CPU; contra el post-PnR, 994 celdas, 3 y 991, 495 s de CPU | `asic/eqy/resultados/sint_v1ff/equiv_resumen.txt`, `asic/eqy/resultados/pnr_v1ff/equiv_resumen.txt` |
| Paso `Yosys.EQY` de LibreLane 3.0.16 con su guion genérico (corridas `d2_eqy` y `d2_eqy_pnr`) | eqy 0.62 en la imagen | falla al leer el RTL: `ERROR: Can't open include file 'game_image.vh'!` | `asic/eqy/runs/d2_eqy/01-yosys-eqy/yosys-eqy.log`, `asic/logs/d2_eqy.log` |
| Paso `Yosys.EQY` con guion propio (`asic/eqy/flujo.eqy`, corrida `d2_eqy_script`) | eqy 0.62 en la imagen, RTLIL canónicos del anfitrión | lee los dos lados, combina y particiona igual que en el anfitrión (22 particiones, 1.015 señales emparejadas) y falla al correr las estrategias: la imagen no trae `make`, que eqy necesita para su `strategies.mk` | `asic/eqy/runs/d2_eqy_script/01-yosys-eqy/scratch/logfile.txt`, `asic/logs/d2_eqy_script.log` |

Qué significa el PASS de eqy (sección 4.4): para cualquier estado inicial de los flip-flops y
cualquier secuencia de entradas, cada salida y cada registro del netlist toma el mismo valor
que en el RTL en todo ciclo en que el valor del RTL está definido (los registros sin reset del
RTL parten en x y se comparan desde que se cargan). No se verifica el árbol de reloj ni la
temporización (eso lo hacen STA y la simulación con SDF, `asic/sim/resultado_sdf.md`).

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

### 4.5 Resultado de sint_v1ff

22 particiones, todas probadas: 21 por `sat` en menos de 1 s de CPU cada una y la partición
`asic_top.led.0` por `pdr` en 80 s de CPU (`sat` llegó a los 5 pasos sin cerrar la inducción:
"Reached maximum number of time steps -> proof failed", 38,8 s, problema de 455.708 variables y
1.200.815 cláusulas en el caso base 1). Total 118 s de reloj y 125 s de CPU según eqy
(`eqy_resumen.md`); 118,71 s de reloj y 2.640.744 KB de memoria máxima según `/usr/bin/time`
(`eqy_tiempo.txt`; el `%M` de `time` está en KB de 1.024 bytes, o sea 2,5 GiB). Tabla por
partición en `asic/eqy/resultados/sint_v1ff/eqy_particiones.md`.

La partición `led.0` compara 816 salidas: los LEDs y, por los registros recodificados y los
fusionados que no tienen par, también el banco de registros, el registro de instrucción, la
pre-decodificación, el PC, la RAM, `digit_q`, `per_rdata` y las demás señales del core; su lado
gate tiene 23.708 celdas (740 `$_DFF_P_` y 79 `$_DFF_PP0_`, 4.041 AND, 3.251 OR, 8.214 NOT,
151 XOR y 7.232 `$_BUF_`) y su lado gold 2.952 (35 `$dff` y 7 `$adff`, 1.208 `$mux`, 1.055
`$and`, 108 `$eq`, 22 `$pmux`, 475 `$_BUF_`); los dos totales están en el campo `cellcount` de
`build/eqy/sint_v1ff/eqy/partitions/asic_top.led.0.json` y el desglose sale de
`yosys -p "read_rtlil build/eqy/sint_v1ff/eqy/partitions/asic_top.led.0.il; stat"`. Las otras 21 son los contadores (`cycles_q`, 32 bits; `u_tick.cnt`, 15 bits), los
registros de lectura del banco (`rf_rdata_a`, `lsu_wdata`), `pc_id`, los sincronizadores y el
debounce de los botones, `rst_sync_q`, `seg1`, `seg2`, `rf_ready`, `busy_q` y `spi_miso`.

## 5. Las demás corridas

### 5.1 Netlist post-PnR sin celdas físicas (pnr_v1ff)

Mismo gold v1 y misma canonización `--solo-ff` contra `build/eqy/gate_pnr_sin_fisicas.nl.v`
(sección 2). Quedan 1.002 nombres comunes; 979 de los 1.004 bits de estado del gold y 979 de
los 990 del gate tienen par (`asic/eqy/resultados/pnr_v1ff/canon_resumen.txt`): a los 17 del
gold sin par de la síntesis se suman los 8 de `lsu_wdata[7:0]`, cuyas redes de salida de
flip-flop OpenROAD renombró a `net428` a `net435` al insertar buffers (los 11 del gate sin par
son `net428` a `net435`, `net576`, `net627` y `net628`). Por eso hay 21 particiones en vez de
22: `lsu_wdata.8` se fundió con `led.0`, que pasa a comparar 840 salidas. Resultado: PASS,
20 particiones por `sat` (menos de 1 s cada una) y `led.0` por `pdr` en 337 s de CPU (`sat`
agotó los 5 pasos en 51,6 s; caso base 1 de 521.806 variables y 1.375.232 cláusulas). Total
387 s de reloj y 394 s de CPU según eqy (`eqy_resumen.md`); 387,96 s de reloj y 3.021.192 KB
de memoria máxima según `/usr/bin/time` (`eqy_tiempo.txt`). Los 772 buffers, inversores y celdas
redimensionadas del PnR quedan dentro de los conos y se comprueban como lógica.

### 5.2 Control negativo (mut_v1ff)

`bash asic/eqy/correr.sh mutar`: copia el netlist de síntesis cambiando una sola celda, la
instancia `_0586_` del módulo `espino_alu`, de `gf180mcu_fd_sc_mcu7t5v0__nand2_1` a
`gf180mcu_fd_sc_mcu7t5v0__nor2_1` (mismos pines `A1`, `A2`, `ZN`; `diff` de 2 líneas en
`asic/eqy/resultados/mut_v1ff/gate_mut_diff.txt`), y repite la canonización y eqy.
Resultado: FAIL en 111 s (`eqy_resumen.md`). Las 21 particiones que no contienen la ALU pasan
igual que antes; en `led.0`, `sat` agota sus 5 pasos sin decidir ("equivalence unknown",
56,8 s) y `pdr` responde "partitions not equivalent" en 57 s de CPU con un contraejemplo de 12
ciclos (`build/eqy/mut_v1ff/eqy/strategies/asic_top.led.0/pdr/asic_top.led.0/engine_0/trace.vcd`,
`trace_tb.v`): en el ciclo 12 difieren `led[2]`, `led[3]` y los bits 2, 3, 5, 6, 10, 14, 22,
24, 30 y 31 de `ram[1]` (12 asserts fallidos en `logfile.txt`). La celda cambiada altera un
resultado de la ALU que recién se observa cuando una instrucción lo escribe en un registro o
en la RAM; una inducción de 5 pasos no alcanza a verlo, PDR sí. El método distingue, por lo
tanto, un error de una sola celda entre 5.118.

### 5.3 Gold v2 (synth -flatten -noabc): no sirve como referencia

La variante v2 pasa el RTL por `synth -flatten -noabc` para que el gold tenga las mismas
optimizaciones de alto nivel que la síntesis de LibreLane (`fsm`, `opt_dff`, `opt_merge`,
`wreduce`, `alumacc`), y en efecto fusiona y recodifica igual los registros de la sección 4.2
(quedan 989 de 998 bits emparejados, `asic/eqy/resultados/sint_v2ff/canon_resumen.txt`). Pero
su pase `fsm` también recodifica `alu_operator` a one-hot de 16 bits (`alu_operator[0]` a
`[15]`; los 9 sin par en `ff_gold_sin_par.txt` son `[4]`, `[5]`, `[7]`, `[8]`, `[9]`, `[11]`,
`[12]`, `[13]` y `[15]`), cosa que la síntesis de LibreLane no hizo porque la ALU es un módulo
con jerarquía conservada ("Users of register don't seem to benefit from recoding"). Así,
`alu_operator[0]` a `[3]` existen en los dos lados con distinto significado (bit one-hot contra
bit binario) y todo registro aguas abajo de la ALU da contraejemplos falsos. La corrida
`sint_v2ff` (1.004 particiones, una por bit, porque con este gold eqy no agrupa los bits de un
registro) se detuvo a mano a los 12 min con 285 particiones probadas por `sat`, 719 "unknown" en
`sat` (entre ellas todo el banco de registros) y 173 "not equivalent" en `pdr`, en la RAM,
`b_rdata_o`, el PC (`a_addr_i`) y `led` (`asic/eqy/resultados/sint_v2ff/NOTA.txt`).
Conclusión: el gold tiene que ser el RTL sin optimizar (v1); las diferencias de registros las
absorbe la partición grande y las prueba `pdr`.

### 5.4 Miter completo desde reset (BMC acotado)

`asic/eqy/miter_reset.py` genera un módulo que instancia el gold y el gate canónicos de
`sint_v1`, fuerza `rst_n = 0` en los ciclos 0 y 1 y lo deja libre después, deja libres los
botones y las entradas SPI, y desde el ciclo 2 afirma que `led`, `seg1`, `seg2` y `spi_miso`
coinciden; ningún flip-flop tiene valor inicial, así que cada registro parte con un valor libre
e independiente en cada lado. El miter está en
`asic/eqy/resultados/<variante>/miter_reset.sv` y la configuración de sby, en la primera parte
de cada `bmc_<profundidad>_resumen.txt`. sby en modo `bmc` con el motor `smtbmc yices`, tres
corridas:

| variante | gate | profundidad | resultado | reloj | memoria máxima (KB) | archivo de origen |
|---|---|---|---|---|---|---|
| `sint_v1` | netlist de síntesis | 24 pasos | PASS | 24,4 s | 179.980 | `asic/eqy/resultados/sint_v1/bmc_24_resumen.txt` |
| `pnr_v1` | post-PnR sin celdas físicas | 24 pasos | PASS | 33,6 s | 179.788 | `asic/eqy/resultados/pnr_v1/bmc_24_resumen.txt` |
| `sint_v1` | netlist de síntesis | 100 pasos | PASS | 1.394 s (23 min 14 s) | 932.200 | `asic/eqy/resultados/sint_v1/bmc_100_resumen.txt` |

La corrida de 100 pasos (`BMC_PROF=100 bash asic/eqy/correr.sh bmc sint_v1`, 28-10-2026) cubre
los pasos de tiempo 0 a 99, con la comparación activa desde el ciclo 2: las cuatro salidas del
chip coinciden en los 98 ciclos comparados para cualquier estado inicial de los 1.004 bits del
RTL y de los 990 del netlist y para cualquier secuencia de botones y de SPI. Tiempo: 1.394 s de
reloj y 1.415 s de proceso según sby, 1.379,52 s de usuario y 35,98 s de sistema según
`/usr/bin/time`, 932.200 KB de memoria máxima (`build/eqy/sint_v1/bmc_100/bmc_tiempo.txt` y
`miter_reset/logfile.txt`). El costo por paso crece rápido con la profundidad: los pasos 0 a 23
se resuelven en 20 s en total, el 50 se alcanza a los 138 s y del paso 90 (991 s) al 99
(1.332 s) pasan 341 s, unos 38 s por paso (líneas "Checking assertions in step" de
`build/eqy/sint_v1/bmc_100/bmc.out`). Llevar el BMC a los miles de ciclos que simula
`make post-synth` no es practicable por esta vía; para eso están las particiones de eqy, que
prueban sin límite de profundidad.

Es una comprobación acotada y de salidas solamente (en 100 ciclos el programa recién pasa sus
primeras instrucciones); su valor es que no depende de ningún emparejamiento de nombres entre
los dos lados, así que confirma el resultado de eqy sin compartir su supuesto más delicado.

### 5.5 Flujo clásico de Yosys (equiv_make, equiv_simple, equiv_induct)

`bash asic/eqy/correr.sh equiv sint_v1ff` (`build/eqy/sint_v1ff/equiv.ys`): lee los dos RTLIL
canónicos, `async2sync`, `equiv_make gold gate equiv` (una celda `$equiv` por cada señal con el
mismo nombre: 1.002, puertos y salidas de flip-flop; 28.282 celdas en el módulo combinado),
`equiv_simple -seq 2` (SAT por celda sobre su cono desenrollado 2 pasos, con las demás `$equiv`
supuestas iguales) y `equiv_induct -seq 4` (inducción temporal sobre todo el diseño).
Resultado (`asic/eqy/resultados/sint_v1ff/equiv_resumen.txt`): `equiv_simple` probó solo 3 de
las 1.002 (`spi_miso`, que es constante, y los dos bits de `rst_sync_q`; en las demás el cono
aislado de 2 pasos no basta, por ejemplo porque la señal depende de su propio valor anterior a
través de un enable o de los registros sin `$equiv`); `equiv_induct` probó
las 999 restantes: la inducción falla en los pasos 1, 2 y 3 y se cumple en el paso 4
(2.354.663 cláusulas sobre 905.108 variables); `equiv_status` final: 1.002 probadas, 0 sin
probar. 515,02 s de CPU y 679.580 KB de memoria máxima (`/usr/bin/time`).
Qué significa, según la propia ayuda de `equiv_induct`: los dos circuitos no divergen una vez
que han producido valores iguales en los 1.002 puntos observables durante 4 ciclos
("weak definition of equivalence"); combinado con la simulación, que muestra que arrancan
sincronizados (`make post-synth`), es una prueba de que siguen iguales para siempre. Es un
resultado independiente del de eqy (otro particionado, otra formulación) que lo confirma.

Lo mismo contra el netlist post-PnR sin celdas físicas
(`TMAX=1500 bash asic/eqy/correr.sh equiv pnr_v1ff`, 28-10-2026): 994 celdas `$equiv` (28.274
celdas en el módulo combinado), las mismas 3 probadas por `equiv_simple` y 991 por
`equiv_induct`, que vuelve a cerrar en el paso 4 (2.353.863 cláusulas sobre 904.828 variables);
`equiv_status` final: 994 probadas, 0 sin probar. 496,25 s de reloj, 495,27 s de CPU y
688.160 KB de memoria máxima (`asic/eqy/resultados/pnr_v1ff/equiv_resumen.txt`). Son 994 y no
1.002 porque el PnR renombró las 8 salidas de flip-flop de `lsu_wdata[7:0]` (sección 5.1).

Primer intento (14:20, gold v1 sin canonizar, `build/eqy/equiv_yosys_sint.log`): 1.394 celdas
`$equiv`, `equiv_simple` sin `-seq` no probó ninguna en los 2.400 s del tope (`timeout`, código
124; `build/eqy/equiv_yosys_sint.out`).

## 6. Qué queda probado y qué no

- Probado (eqy, sin límite de profundidad en las particiones que cerró `pdr`): el netlist de
  síntesis y el netlist post-PnR sin celdas físicas de la corrida final son equivalentes al RTL
  de `asic_top` con `MemStrategy = 1` y `DataWords = 4`, en el sentido de la sección 4.4: para
  todo estado inicial y toda secuencia de entradas, cada puerto de salida y cada uno de los
  registros emparejados (987 bits de estado en síntesis, 979 en post-PnR) toma en el netlist el
  mismo valor que en el RTL en todo ciclo en que el RTL lo tiene definido; los registros que la
  síntesis fusionó, eliminó o recodificó, y los que el PnR renombró (17 bits del RTL contra el
  netlist de síntesis, 25 contra el post-PnR; secciones 4.2 y 5.1) están dentro de las
  particiones y se comprueban a través de lo que alimentan. Además, el miter completo desde reset
  (sección 5.4) coincide en las cuatro salidas del chip durante los primeros 100 pasos contra el
  netlist de síntesis y los primeros 24 contra el post-PnR, sin ningún emparejamiento de
  nombres, y el control negativo (sección 5.2) muestra que el método detecta un cambio de una
  celda. El flujo clásico de Yosys prueba lo mismo con otra formulación y otro particionado en
  los dos netlists (sección 5.5).
- No cubierto por este método: el árbol de reloj y la polaridad del reloj (los pases `sat` y
  `pdr` avanzan todos los flip-flops a la vez e ignoran la señal de reloj), la temporización
  (STA de LibreLane en las 9 esquinas, `asic/rom/resultados/final/cierre.md`) y las celdas
  físicas quitadas del netlist post-PnR (las comprueba el LVS). Los modelos de celda son las
  funciones del liberty típico, no los modelos Verilog con UDP del PDK.
- Supuestos: el pase `read_liberty` de Yosys interpreta bien los atributos `function` y `ff` del
  liberty; la canonización de nombres solo renombra wires (no cambia la lógica), y lo verifica
  el control negativo, que detecta un cambio de una celda.

## 7. Comparación con la verificación por simulación

| | `make post-synth` / `make post-synth-final` (`asic/sim/README.md`) | `make post-pnr-sdf` / `make post-pnr-cvc` | `make equiv` | Esta equivalencia formal |
|---|---|---|---|---|
| Qué compara | RTL contra netlist (síntesis o post-PnR) con un escenario de estímulos | ídem con retardos SDF | RTL actual contra el RTL de otro commit con `sw/isa_test.s` | RTL contra netlist para todas las entradas y estados |
| Modelo de celda | Verilog del PDK con UDP (`-DFUNCTIONAL`) | Verilog del PDK con `specify` | no aplica | funciones del liberty típico |
| Cobertura | 4.500 ciclos (sim) o 320.000 (final), 17 cambios de salida | 4.500 ciclos por esquina | 1.018 eventos por estrategia | exhaustiva por construcción, salvo lo de la sección 6 |
| Temporización | no | sí (Icarus anota, CVC además evalúa los checks) | no | no |
| Tiempo | minutos | minutos por esquina | minutos | 2 min (síntesis) y 6,5 min (post-PnR) de reloj, más 1 min de preparación |

Las dos verificaciones se complementan: la simulación usa los modelos del fabricante con
retardos y un escenario real; la equivalencia formal cubre todos los escenarios con otro modelo
de celda y sin tiempo. Origen de los números de la fila "Cobertura": 4.500 y 320.000 ciclos y los
17 cambios de salida, `asic/sim/README.md` y `asic/sim/resultado_sdf.md`; los 1.018 eventos de
`make equiv`, las trazas `build/traza_{ref,act}_m1.txt` y `_m2.txt` de la corrida del 26-10-2026
(1.018 líneas cada una, que `tb/comparar_trazas.py` imprime como "trazas identicas ciclo a ciclo
(1018 eventos)"); los tiempos de la última fila, `eqy_tiempo.txt` de `sint_v1ff` y `pnr_v1ff`.

## 8. Reproducción

    export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH   # lo hace el propio script
    bash asic/eqy/correr.sh versiones         # versiones y rutas de las herramientas (resultados/versiones.txt)
    bash asic/eqy/correr.sh preparar          # gold v1/v2, gate sint/pnr y las variantes canónicas (build/eqy/)
    J=8 bash asic/eqy/correr.sh eqy sint_v1ff # RTL contra síntesis, cortes en registros (el resultado principal)
    J=8 bash asic/eqy/correr.sh eqy pnr_v1ff  # RTL contra post-PnR sin celdas físicas
    bash asic/eqy/correr.sh mutar             # control negativo (tiene que dar FAIL)
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
