# Frente B: frecuencia máxima con el core actual (rama exp/fmax)

Rama `exp/fmax` = main 50f8a39 + B2 (f053dec, offset de byte de la carga registrado en la
LSU) + B5 (73f1d72 y 210b6a7, banco de registros con latches `latq_1` y clock gating
`icgtp_1`). Worktree `build/exp_fmax`. Todas las corridas con `FP_CORE_UTIL = 40 %` y la
configuración final de main (`asic/rom/config.yaml`: D15, D20, D21 más
`LINTER_ERROR_ON_LATCH: false` de B5). Tablas completas en `asic/barrido_exp.md`; criterios de
cierre de cada corrida en `asic/rom/resultados/<tag>/cierre.md`; prefijo de tags `fb_`.

## 1. Verificación de la base B2 + B5 (paso 1)

`asic/verificacion_exp.txt` (copia de la salida de `make check` y `make equiv` del 27-10-2026,
Icarus 14.0-devel):

- `make check`: 80 pruebas del assembler OK; los seis testbenches PASS (game_top_tb, game_tb y
  game_tb con RONDAS=4, con las dos estrategias de memoria). CPI del juego completo (game_tb,
  10 rondas): 1.599.759 ciclos / 600.218 instrucciones = **2,665**, igual que main (B2 y B5
  no cambian los ciclos). Con RONDAS=4: 2,682.
- `make equiv` (ciclo a ciclo contra 116fa20, `sw/isa_test.s`): trazas idénticas en las dos
  estrategias (1.018 eventos); CPI 2,953 en las dos versiones.

## 2. Cómo se lee el cierre con latches (B5)

Con los 480 latches del banco, OpenSTA aplica préstamo de tiempo (time borrowing): un endpoint
de latch "cumple" con slack 0,000 mientras le quede préstamo, y como el WNS de `metrics.json`
es el peor slack de todos los endpoints, **toda corrida con B5 reporta setup WNS = 0,000**
aunque las rutas a flip-flop tengan 67 ns de margen. El criterio de cierre no cambia
(`asic/verificar_cierre.py`: WNS >= 0 y TNS = 0 en las 9 esquinas; una ruta a flip-flop que
viole aparece con WNS negativo, como en fb_t23), pero para comparar variantes a 100 ns hay que
leer el margen real: `asic/margen_latch.py` recorre `max.rpt` de `max_ss_125C_4v50`
(una ruta por endpoint) y reporta la peor ruta cuyo endpoint es un flip-flop o un puerto
("slack FF" en las tablas de abajo) y el mayor préstamo real de los latches con el préstamo
máximo disponible (`asic/rom/resultados/<tag>/margen_latch.md`). Con `--ruta` escribe el
bloque de esa ruta para `asic/layout/anotar.sh <run> -rd rpt=<archivo>` (opción nueva de
`anotar.py`: la primera ruta de `max.rpt` es siempre la de un latch).

En todas las corridas el préstamo de los latches es de 3,3 a 3,9 ns (la ruta `wdata_q` ->
buffer de fanout -> latch, dentro de la fase alta del reloj gated) contra 49 ns disponibles
a 100 ns y 10 a 11 ns a 22 a 24 ns: los latches no limitan el período.

## 3. Base a 100 ns y barrido de período

| corrida | T (ns) | cierra | slack FF max_ss (ns) | hold peor (ns) | área stdcell (µm²) | slew / cap | préstamo latch (ns) |
|---|---|---|---|---|---|---|---|
| fb_t100 | 100 | sí | 67,622 | 0,161 | 165.358 | 327 / 1 | 3,52 de 49,32 |
| fb_t24 | 24 | sí | 0,434 | 0,152 | 171.289 | 351 / 2 | 3,53 de 11,33 |
| fb_t23p5 | 23,5 | sí | 0,053 | 0,154 | 172.185 | 340 / 2 | 3,53 de 11,08 |
| fb_t23 | 23 | no (WNS -0,447, TNS -3,639, 17 endpoints) | -0,447 | 0,136 | 172.185 | 340 / 2 | 3,53 de 10,83 |
| fb_t22 | 22 | no (WNS -1,670; hold -0,077 en max_ss) | -1,670 | -0,077 | 171.594 | 368 / 1 | 3,51 de 10,32 |

Fuentes: `asic/rom/resultados/fb_*/metrics.json`, `cierre.md` y `margen_latch.md`.

- Área a 100 ns: 165.358 µm² contra 182.265 de main (-9,3 %; B5 sola daba 165.369): muy por
  debajo del límite de 191.378 µm². Die 353.921 µm² (main 408.957). DRC 0, LVS 0, antena 0.
- fb_t22 terminó con código 2 de LibreLane por la violación de hold en max_ss (error diferido
  `Hold violations found`); dejó `metrics.json` y se cuenta como "no cierra". La violación
  (`55-openroad-stapostpnr/max_ss_125C_4v50/min.rpt`, 2 rutas, -0,077 ns) es el chequeo de
  removal del puerto `rst_n` sobre los flip-flops del sincronizador de reset: la SDC genérica
  pone el retardo de entrada en 20 % del período (4,4 ns a 22 ns, `IO_DELAY_CONSTRAINT`), y
  con la latencia del árbol de reloj de unos 4 ns en max_ss el reset llega antes del flanco.
  No tiene que ver con el core y a 23 ns o más no aparece (hold 0,136 ns o más).
- Ruta crítica a flip-flop de fb_t24 (`asic/rom/resultados/fb_t24/layout/ruta_critica.txt`,
  figura `ruta_critica.png`; la ruta del latch quedó en `ruta_latch.txt`): parte del registro
  de pre-decodificación `u_soc.u_core.u_id.alu_operator[1]` (`_4668_`, llega a 6,40 ns),
  atraviesa la ALU (10 celdas, selección de la operación y suma de la dirección, hasta
  `u_soc.u_core.lsu_addr[2]` a 17,80 ns) y termina en la lógica aplanada de la RAM de datos
  de 4 palabras (D9): `lsu_addr[2]` es el bit que elige la palabra (`b_word`), la decodificación
  del enable de escritura y el mux de retención llegan al flip-flop
  `u_soc.g_mem_rom.u_mem.g_ram.ram[3][21]` (`_4394_`) a 26,59 ns; slack 0,434 ns. Es la
  escritura de un `sw` a la RAM de datos. Los 17 endpoints negativos de fb_t23 son de dos
  familias: 11 flip-flops `ram[3][*]` y `ram[1][*]` por esta ruta, y 6 bits del registro de
  instrucción `u_soc.g_mem_rom.u_mem.a_rdata_o[*]` por la ruta `rf_ready` -> `stall` -> mux
  de retención del registro de instrucción (la ruta que limitaba a B2 a 24 ns, con el banco
  de registros ya fuera por B5).
- A 100 ns la peor ruta a flip-flop (67,6 ns de slack) es `alu_op_a_sel[2]` -> mux de
  operando A -> ALU -> `lsu_addr[31]` (selección de periféricos) -> `u_soc.u_periph.digit_q[2]`:
  la escritura de un `sw` a un periférico.

## 4. Perillas del flujo a 100 ns, de a una sobre la base

Cada perilla a 100 ns y 40 % sobre la base B2 + B5; las del resizer van como `VAR=VAL` al
encolar y las de `SYNTH_STRATEGY` en copias de `config.yaml` (`asic/rom/config_a1.yaml` a
`config_a3.yaml`, `config_d0.yaml` a `config_d4.yaml`) porque la cola no conserva las comillas de
un valor con espacio. "slack FF" es el margen real de la peor ruta a flip-flop o puerto en
`max_ss_125C_4v50` (`margen_latch.md`); el WNS de `metrics.json` es 0,000 en todas por los
latches. Área de referencia: base 165.358 µm²; límite de la sesión 191.378 µm² (105 % de main).

| perilla | corrida | slack FF max_ss (ns) | hold peor (ns) | área stdcell (µm²) | slew / cap | comentario |
|---|---|---|---|---|---|---|
| base (AREA 0, margen 10) | fb_t100 | 67,622 | 0,161 | 165.358 | 327 / 1 | 16 min |
| RUN_POST_GRT_RESIZER_TIMING=true | fb_pgrt_t100 | 67,962 | 0,169 | 165.358 | 326 / 2 | +0,34 ns; agrega el paso ResizerTimingPostGRT, 27 min |
| PL_RESIZER_SETUP_SLACK_MARGIN=5 | fb_m5_t100 | 67,622 | 0,161 | 165.358 | 327 / 1 | idéntica a la base |
| PL_RESIZER_SETUP_SLACK_MARGIN=15 | fb_m15_t100 | 67,622 | 0,161 | 165.358 | 327 / 1 | idéntica a la base |
| SYNTH_STRATEGY AREA 1 | fb_a1_t100 | 61,353 | 0,142 | 163.160 (-1,3 %) | 380 / 1 | menos área, menos margen |
| SYNTH_STRATEGY AREA 2 | fb_a2_t100 | 64,471 | 0,172 | 161.540 (-2,3 %) | 345 / 3 | la menor área |
| SYNTH_STRATEGY AREA 3 | fb_a3_t100 | 67,845 | 0,175 | 178.768 (+8,1 %) | 1152 / 3 | préstamo de latch 5,1 ns; 1.152 pines con slew |
| SYNTH_STRATEGY DELAY 0 | fb_d0_t100 | 64,036 | 0,146 | 175.410 (+6,1 %) | 539 / 1 | |
| SYNTH_STRATEGY DELAY 1 | fb_d1_t100 | 63,959 | 0,172 | 179.082 (+8,3 %) | 430 / 3 | |
| SYNTH_STRATEGY DELAY 2 | fb_d2_t100 | 61,974 | 0,172 | 179.969 (+8,8 %) | 482 / 11 | |
| SYNTH_STRATEGY DELAY 3 | fb_d3_t100 | 68,192 | 0,173 | 174.518 (+5,5 %) | 499 / 7 | el mejor slack a 100 ns (+0,57 ns) |
| SYNTH_STRATEGY DELAY 4 | fb_d4_t100 | 66,992 | 0,177 | 184.948 (+11,8 %) | 1073 / 13 | |
| STD_CELL_LIBRARY=gf180mcu_fd_sc_mcu9t5v0 | fb_9t_t100 | falló | | | | ver abajo; repetida como fb_9tb_t100 |

Fuentes: `asic/rom/resultados/<tag>/metrics.json`, `cierre.md` y `margen_latch.md`; tablas
completas en `asic/barrido_exp.md`. Todas cierran (DRC 0, LVS 0, antena 0, hold >= 0,142 ns) y
todas quedan bajo el límite de área.

Lectura: a 100 ns ninguna perilla cambia el margen en más de 0,6 ns sobre 67,6, y las
diferencias son del orden del ruido de mapeo (la peor ruta a flip-flop a 100 ns es la escritura
de un `sw` a un periférico, no la que limita el período). El margen del resizer (5, 10 o 15 ns)
no cambia nada a 100 ns porque el resizer llega a la holgura pedida sin agotar sus movimientos.
Por eso la selección de candidatas no se hizo con el WNS a 100 ns (como pedía el brief) sino al
límite de período (sección 5): la única forma de saber si una perilla acorta la ruta que limita
es correrla donde esa ruta no cierra.

Biblioteca de 9 pistas (`asic/rom/config_9t.yaml`): `fb_9t_t100` falló al cargar la
configuración del PDK (`asic/logs/fb_9t_t100.log`: "Path provided for variable
'PNR_EXCLUDED_CELL_FILE' is invalid: .../libs.tech/openlane/gf180mcu_fd_sc_mcu9t5v0/drc_exclude.cells
does not exist"). El PDK instalado trae `config.tcl`, `no_synth.cells` y `tracks.info` para la 9t
pero no `drc_exclude.cells`, y `libs.tech/openlane/config.tcl` (línea 61) lo apunta igual con
`DRC_EXCLUDE_CELL_LIST`; LibreLane valida las variables del PDK antes de aplicar la
configuración del diseño (`config/config.py`, `__get_pdk_config`), así que no se puede corregir
desde `config_9t.yaml`. Solución aplicada: se creó
`$PDK_ROOT/gf180mcuD/libs.tech/openlane/gf180mcu_fd_sc_mcu9t5v0/drc_exclude.cells` con las
mismas dos celdas de la 7t renombradas (`gf180mcu_fd_sc_mcu9t5v0__mux2_1` y `__oai33_2`); es un
archivo nuevo fuera del repo, en una biblioteca que ningún otro frente usa, y se puede borrar.
Magic ya tiene la ruta de la 9t en `gf180mcuD.magicrc` (línea 53) y Netgen y KLayout no
dependen de la biblioteca. `rtl/gf180_cells.v` elige las celdas `latq_1` e `icgtp_1` de la 9t
con el define `SCL_gf180mcu_fd_sc_mcu9t5v0` que pone Yosys (`scripts/pyosys/synthesize.py`).
Corrida repetida como `fb_9tb_t100`.

## 5. Perillas al límite de período (23 ns)

La base cierra a 23,5 ns (slack FF 0,053) y no a 23 (-0,447, 17 endpoints, TNS -3,639), así que
cada perilla se corrió a 23 ns para ver si cierra o cuánto acerca.

| perilla | corrida | slack FF max_ss (ns) | TNS (ns) | endpoints negativos | hold peor (ns) | área stdcell (µm²) | slew / cap | tiempo |
|---|---|---|---|---|---|---|---|---|
| base | fb_t23 | -0,447 | -3,639 | 17 | 0,136 | 172.185 | 340 / 2 | 9 min |
| PL_RESIZER_SETUP_SLACK_MARGIN=15 | fb_m15_t23 | -0,447 | -3,639 | 17 | 0,136 | 172.185 | 340 / 2 | 9 min; idéntica a la base |
| RUN_POST_GRT_RESIZER_TIMING=true | fb_pgrt_t23 | -0,211 | -1,077 | 8 | 0,152 | 172.211 | 324 / 3 | 23 min |
| SYNTH_STRATEGY DELAY 3 | fb_d3_t23 | -3,089 | -307,4 | muchos | 0,173 | 180.445 | 482 / 9 | 7 min; mucho peor |

Por qué el margen del resizer no cambia nada al límite (`37-openroad-resizertimingpostcts/`
de fb_t23): con `-setup_margin 10` a 23 ns, 834 endpoints "violan"; el repair los ataca todos
(33 buffers, 388 celdas agrandadas) y termina con "Unable to repair all setup violations": se
agotan los movimientos útiles sobre la ruta crítica, no el margen. Con margen 15 el resultado es
el mismo layout. El repair post-GRT (`43-openroad-resizertimingpostgrt/` de fb_pgrt_t23, margen
0,025 ns) encuentra 480 endpoints y recupera 0,24 ns en el STA final, a costa de 14 minutos más.
DELAY 3, que tenía el mejor slack a 100 ns, es la peor al límite: confirma que el slack a 100 ns
no predice el período mínimo.

Los endpoints negativos de fb_t23 y fb_pgrt_t23 son de dos familias (`max.rpt` de max_ss):
flip-flops `ram[3][*]` y `ram[1][*]` de la RAM de datos (`_4394_`, `_4396_`, `_4395_`,
`_4389_`, `_4390_`: la ruta `alu_operator[1]` -> ALU -> `lsu_addr[2]` -> decodificación del
enable de escritura y mux de retención, sección 3) y bits del registro de instrucción
(`_4585_`, `_4587_`, `_4593_`, `_4594_`: `rf_ready` -> `stall` -> mux de retención). Ninguna
perilla del flujo cambia esas rutas; solo las acorta o las agranda.

Corridas encoladas a 23 ns (resultados en la sección 6 cuando terminen): `fb_pgrt_t23p25`
(post-GRT a 23,25 ns), `fb_pgrt2_t23` (post-GRT con `GRT_RESIZER_SETUP_SLACK_MARGIN=2`),
`fb_d0_t23`, `fb_d1_t23`, `fb_d2_t23`, `fb_d4_t23`, `fb_a1_t23`, `fb_a2_t23`, `fb_alu_t23`
(`config_alu.yaml`: no conserva la jerarquía de la ALU, que la ruta crítica cruza dos veces) y
`fb_flat_t23` (`config_flat.yaml`: todo aplanado, mide el costo total de D12).

## 6. Candidatas barridas y mejor base de B

PENDIENTE (se completa con los resultados de la sección 5).
