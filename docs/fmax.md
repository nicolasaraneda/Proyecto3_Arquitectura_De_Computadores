# Frente B: frecuencia máxima con el core actual (rama exp/fmax)

Rama `exp/fmax` = main 50f8a39 + B2 (f053dec, offset de byte de la carga registrado en la
LSU) + B5 (73f1d72 y 210b6a7, banco de registros con latches `latq_1` y clock gating
`icgtp_1`). Worktree `build/exp_fmax`. Todas las corridas con `FP_CORE_UTIL = 40 %` y la
configuración final de main (`asic/rom/config.yaml`: D15, D20, D21 más
`LINTER_ERROR_ON_LATCH: false` de B5). Aviso de reproducibilidad: al cerrar el frente se agregó
`RUN_POST_GRT_RESIZER_TIMING: true` a `asic/rom/config.yaml` (la mejor combinación, sección 6.4),
así que las corridas de las secciones 3 a 5 que no llevan esa perilla se reproducen con el
`asic/rom/config.yaml` de los commits anteriores a `e8eee90`, o con
`RUN_POST_GRT_RESIZER_TIMING=false` en la línea de `asic/encolar.sh`. Tablas completas en `asic/barrido_exp.md`; criterios de
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
- Simulación post-síntesis con el netlist de la rama (28-10-2026): el netlist sale de la corrida
  `fb_sim_rom` (`asic/sim/config.yaml` hasta `Yosys.Synthesis`, pedida por la cola porque
  `make sim-netlist` invoca `librelane` directo) y los tres pasos de `make post-synth` se corrieron
  a mano contra ese netlist: **PASS**, 17 cambios de salida en los dos lados, trazas idénticas y
  0 valores X ni en el RTL ni en el netlist. El control negativo (`asic/sim/atrasar.py`, pulsación
  atrasada 6 ciclos) da FAIL como corresponde. `asic/sim/resultado.md` regenerado queda idéntico
  al de main: el netlist de B2 + B5 da la misma traza de salidas que el de main en el mismo
  escenario.

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
| STD_CELL_LIBRARY=gf180mcu_fd_sc_mcu9t5v0 | fb_9t_t100 | falló al cargar el PDK | | | | ver abajo |
| STD_CELL_LIBRARY=gf180mcu_fd_sc_mcu9t5v0 (segundo intento) | fb_9tb_t100 | 70,544 | 0,108 | 207.271 (+25,3 %) | 186 / 42 | NO cierra: 30 errores de DRC de Magic; pasa el límite de área |

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
Con ese archivo creado, `fb_9tb_t100` llega al final del flujo (código 2 de LibreLane por error
diferido) y da el mejor margen de toda la sesión a 100 ns, 70,544 ns de slack a flip-flop (+2,9 ns
sobre la base) con 186 pines con violación de slew (el menor de todas las corridas, contra 327 de
la base), pero **no cierra** por dos razones independientes:

- 30 errores de DRC de Magic (`asic/rom/runs/fb_9tb_t100/64-magic-drc/reports/drc.magic.rpt`),
  todos de la misma regla, "MV N-Diffusion overlap of contact < 13 (CO.4)". `asic/drc_celdas.py`
  (nuevo: ubica cada rectángulo de error en la instancia del DEF final que lo contiene, con el
  SIZE de los LEF) los asigna a las 15 instancias de `gf180mcu_fd_sc_mcu9t5v0__icgtp_1`, dos
  errores por instancia, una por registro del banco: son los clock gating de B5
  (`asic/rom/resultados/fb_9tb_t100/drc_celdas.md`). El error está dentro del layout de la celda
  de la biblioteca, no en el diseño ni en el enrutado, así que no se puede arreglar desde el
  flujo; la misma celda en la 7t (`gf180mcu_fd_sc_mcu7t5v0__icgtp_1`, 15 instancias iguales) da
  DRC 0 en todas las demás corridas de la rama. Es un defecto de la biblioteca de 9 pistas del
  PDK instalado.
- Área de celdas estándar 207.271 µm², 25,3 % sobre la base y 13,7 % sobre main: pasa el límite
  de la sesión (191.378 µm²). La 9t es más alta (9 pistas de rutado contra 7) y cada celda ocupa
  más; el área secuencial sube de 36.673 a 45.090 µm² y el banco de registros de 52.426 a
  66.702 µm² (`asic/rom/resultados/fb_9tb_t100/sintesis_stat.rpt`).

Conclusión de la 9t: queda descartada por el DRC de la celda de clock gating y por el área, no
por el tiempo. Si en algún momento se quisiera usar, habría que renunciar al clock gating de B5
(o arreglar el GDS de la celda, que está fuera del alcance del proyecto) y aceptar el área.

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

El resto de las perillas al límite se corrió en una segunda tanda, con los resultados en la
sección 6.1: `fb_pgrt_t23p25` (post-GRT a 23,25 ns), `fb_pgrt2_t23` (post-GRT con
`GRT_RESIZER_SETUP_SLACK_MARGIN=2`), `fb_d0_t23`, `fb_d1_t23`, `fb_d2_t23`, `fb_d4_t23`,
`fb_a1_t23`, `fb_a2_t23`, `fb_alu_t23` (`config_alu.yaml`: no conserva la jerarquía de la ALU,
que la ruta crítica cruza dos veces) y `fb_flat_t23` (`config_flat.yaml`: todo aplanado, mide el
costo total de D12).

## 6. Candidatas barridas y mejor base de B

### 6.1 Resto de las perillas al límite de período (23 ns)

Segunda tanda a 23 ns, el período donde la base no cierra por 0,447 ns. "slack FF" es el margen
real de la peor ruta a flip-flop o puerto en `max_ss_125C_4v50` (`margen_latch.md`); el WNS de
`metrics.json` es 0,000 en todas por los latches. Límite de área de la sesión: 191.378 µm².

| perilla | corrida | slack FF max_ss (ns) | TNS ss (ns) | hold peor (ns) | área stdcell (µm²) | slew / cap | comentario |
|---|---|---|---|---|---|---|---|
| base (AREA 0, margen 10) | fb_t23 | -0,447 | -3,639 | 0,136 | 172.185 | 340 / 2 | referencia |
| PL_RESIZER_SETUP_SLACK_MARGIN=15 | fb_m15_t23 | -0,447 | -3,639 | 0,136 | 172.185 | 340 / 2 | mismo layout que la base |
| RUN_POST_GRT_RESIZER_TIMING=true | fb_pgrt_t23 | **-0,211** | -1,077 | 0,152 | 172.211 | 324 / 3 | la única que acerca; +0,236 ns |
| post-GRT con GRT_RESIZER_SETUP_SLACK_MARGIN=2 | fb_pgrt2_t23 | -0,211 | -1,077 | 0,152 | 172.211 | 324 / 3 | mismo layout que fb_pgrt_t23 |
| SYNTH_STRATEGY AREA 1 | fb_a1_t23 | -4,401 | -625,951 | 0,142 | 167.634 | 402 / 1 | |
| SYNTH_STRATEGY AREA 2 | fb_a2_t23 | -2,141 | -68,150 | 0,104 | 167.595 | 349 / 3 | la menor área, peor tiempo |
| SYNTH_STRATEGY DELAY 0 | fb_d0_t23 | -1,534 | -25,699 | 0,149 | 184.408 | 485 / 3 | la mejor de DELAY, aún lejos |
| SYNTH_STRATEGY DELAY 1 | fb_d1_t23 | -3,817 | -129,297 | 0,172 | 185.764 | 367 / 2 | |
| SYNTH_STRATEGY DELAY 2 | fb_d2_t23 | -2,795 | -97,065 | 0,172 | 185.650 | 427 / 5 | |
| SYNTH_STRATEGY DELAY 3 | fb_d3_t23 | -3,089 | -307,366 | 0,173 | 180.445 | 482 / 9 | mejor slack a 100 ns, peor al límite |
| SYNTH_STRATEGY DELAY 4 | fb_d4_t23 | -2,342 | -174,290 | 0,158 | 192.326 | 1102 / 13 | pasa el límite de área y deja 1 net con violación de antena |
| sin conservar la jerarquía de la ALU | fb_alu_t23 | -1,522 | -66,123 | 0,142 | 171.529 | 346 / 4 | |
| todo aplanado (sin D12) | fb_flat_t23 | -4,388 | -219,112 | 0,132 | 171.915 | 400 / 5 | |

Fuentes: `asic/rom/resultados/<tag>/metrics.json`, `cierre.md` y `margen_latch.md`; tablas
completas en `asic/barrido_exp.md` (sección "Resto de las perillas al límite de período").

Lecturas:

- **Solo el repair post-GRT acorta la ruta que limita el período.** Recupera 0,236 ns (de -0,447
  a -0,211) porque corre `repair_timing` después del enrutado global, con las capacitancias y
  resistencias del enrutado estimado en vez de las del modelo de placement; en esta ruta los
  nets con más carga son `net93` y `net94`, con 10 de fanout cada uno
  (`max_ss_125C_4v50_ruta_ff.rpt`). Cuesta unos 14 minutos más por corrida.
- **El margen del resizer no cambia nada, ni en placement ni post-GRT.** `fb_pgrt2_t23` pasa
  `-setup_margin 2.0` en vez de `0.025` (`resolved.json`) y el log del paso
  `43-openroad-resizertimingpostgrt` muestra los mismos 480 endpoints atacados, los mismos
  conteos finales de celdas (14 buffers, 142 buffers de reloj, 626 buffers de reparación de
  tiempo) y el mismo aviso `RSZ-0062 Unable to repair all setup violations`: el resizer agota
  sus movimientos útiles sobre la ruta crítica, no el margen pedido. Igual que con
  `PL_RESIZER_SETUP_SLACK_MARGIN` 5, 10 o 15 (sección 4).
- **Ninguna estrategia de síntesis ayuda al límite**, ni las de retardo. La mejor, DELAY 0, queda
  a -1,534 ns con 7,1 % más de área que la base al mismo período (184.408 contra 172.185 µm²); DELAY 3, que daba el mejor slack a 100 ns (68,192 ns), es una
  de las peores a 23 ns (-3,089 ns). La razón es la de la sección 4: a 100 ns la peor ruta a
  flip-flop es la escritura de un `sw` a un periférico, una ruta distinta de la que limita el
  período, así que el slack a 100 ns no sirve para elegir candidatas.
- **Aplanar no ayuda y conservar la jerarquía no cuesta.** `fb_flat_t23` (todo aplanado, sin D12)
  queda a -4,388 ns y `fb_alu_t23` (jerarquía de la ALU no conservada) a -1,522 ns, los dos peor
  que la base con la jerarquía de D12 conservada (-0,447 ns). D12 no es un costo de frecuencia.

### 6.2 Candidatas barridas en período

Dos candidatas llegaron al barrido completo de período (el plan del frente permitía hasta tres): la base B2 + B5 y la
base con el repair post-GRT. No se barrió una tercera porque ninguna otra perilla quedó a menos de
1,5 ns de cerrar a 23 ns, es decir ninguna otra tenía posibilidad de bajar de 23,5 ns. Las dos
cumplen la regla de 0,5 ns. CPI del juego completo (game_tb, 10 rondas): 2,665 en las dos, igual
que main, porque ni B2 ni B5 cambian el número de ciclos (`make check` de la sección 1, verificado
con `make equiv` ciclo a ciclo); MIPS = f_max / 2,665.

| candidata | último T que cierra | primer T que no | f_max (MHz) | MIPS | área a 100 ns (µm²) | área al T mínimo (µm²) | slew / cap al T mínimo | fuente |
|---|---|---|---|---|---|---|---|---|
| main (referencia) | 24,5 ns (f1_t24p5) | 24 ns (f1_t24, -0,004) | 40,82 | 15,32 | 182.265 | 189.817 | 532 / 36 | `asic/rom/resultados/f1_t24p5/` de main |
| B: B2 + B5 | 23,5 ns (fb_t23p5) | 23 ns (fb_t23, -0,447) | 42,55 | 15,97 | 165.358 | 172.185 | 340 / 2 | `asic/rom/resultados/fb_t23p5/` |
| **B + post-GRT** | **23,25 ns (fb_pgrt_t23p25)** | 23 ns (fb_pgrt_t23, -0,211) | **43,01** | **16,14** | **165.358** | **172.211** | **324 / 3** | `asic/rom/resultados/fb_pgrt_t23p25/` |

Las dos candidatas cierran en las nueve esquinas con DRC de Magic 0, LVS 0 y 0 nets con violación
de antena (`cierre.md` de cada corrida), y las dos quedan muy por debajo del límite de área
(165.358 µm² a 100 ns, 86,4 % de los 191.378 permitidos). Área de die 353.921 µm² en las dos, con
utilización 0,505 a 100 ns y 0,526 al período mínimo.

Segundo signoff de la candidata elegida: `bash asic/drc_klayout.sh asic/rom/runs/fb_pgrt_t23p25`
(el deck de KLayout de GF180MCU sobre el GDS final, el mismo que usa el paso `KLayout.DRC`, que
LibreLane salta en gf180mcuD) da **0 marcadores en 0 reglas de las 684 que evalúa el deck**, en
324 segundos: `asic/rom/resultados/fb_pgrt_t23p25/drc_klayout/resumen.md`, `drc.log` y
`drc.lyrdb`. Igual que la corrida final de main.

Ganancia de la mejor candidata contra main: período mínimo de 24,5 a 23,25 ns (-5,1 %), f_max de
40,82 a 43,01 MHz (+5,4 %), MIPS de 15,32 a 16,14 (+5,4 %), área a 100 ns -9,3 %, área al período
mínimo -9,3 %, y, al período mínimo de cada una, violaciones de max slew de 532 a 324 (-39 %) y
de max capacitancia de 36 a 3 (-92 %).

### 6.3 Ruta crítica del período mínimo (fb_pgrt_t23p25)

`asic/rom/resultados/fb_pgrt_t23p25/layout/ruta_critica.txt` y `ruta_critica.png`
(`bash asic/layout/anotar.sh asic/rom/runs/fb_pgrt_t23p25 -rd figuras=ruta -rd rpt=asic/rom/resultados/fb_pgrt_t23p25/max_ss_125C_4v50_ruta_ff.rpt`,
sobre el bloque de la peor ruta a flip-flop que extrae `asic/margen_latch.py --ruta`); el reporte
completo está en `max_ss_125C_4v50_ruta_ff.rpt` y la ruta del latch, que es la primera de
`max.rpt`, en `ruta_latch.txt` y `ruta_latch.png`.

- **Inicio**: `_4668_` (`dffq_1`), el bit 1 del registro de pre-decodificación
  `u_soc.u_core.u_id.alu_operator[1]`; el dato sale a los 6,31 ns (3,94 ns de latencia del árbol
  de reloj más 2,38 ns del flip-flop con 1,66 ns de slew de reloj).
- **Recorrido**: 20 celdas. Diez dentro de la ALU (`u_soc.u_core.u_id.u_alu`: `clkinv_1`,
  `nand2_1`, `nor3_1`, dos `aoi211_1`, `aoi22_1` y tres buffers de fanout o de capacidad máxima)
  que seleccionan la operación y suman la dirección, hasta `u_soc.u_core.lsu_addr[2]` a los
  17,48 ns. Diez más en la lógica aplanada de la RAM de datos de 4 palabras (D9): `lsu_addr[2]`
  es el bit que elige la palabra, y la decodificación del enable de escritura y el mux de
  retención (`buf_2`, `clkinv_1`, `nor2_1`, tres `buf_2` de fanout, dos `nand2_1`, `oai21_1`)
  llegan a los 26,20 ns.
- **Fin**: `_4396_` (`dffq_1`) = `u_soc.g_mem_rom.u_mem.g_ram.ram[3][23]`, el bit 23 de la
  palabra 3 de la RAM de datos (`asic/rom/runs/fb_pgrt_t23p25/final/nl/asic_top.nl.v`, línea
  27018). Tiempo requerido 26,24 ns, **slack +0,039 ns**.
- **Función**: la escritura de un `store` a la RAM de datos en el mismo ciclo en que la ALU
  calcula la dirección. Es la misma familia de rutas que limitaba a fb_t24 (sección 3), con otro
  bit de destino.
- **Margen real con latches** (`margen_latch.md`): de las 1.186 rutas de `max.rpt`, 706 terminan
  en flip-flop o puerto y 480 en los latches del banco. El mayor préstamo de tiempo real es de
  3,578 ns sobre 10,950 ns disponibles, en `u_soc.u_core.u_rf/g_reg[6].g_bit[2].u_lat.u_lat`
  (ruta `_2016_` -> `fanout334` -> latch, tres celdas): los latches de B5 usan un tercio del
  préstamo disponible y no limitan el período ni a 23,25 ns.
- Reparto del área del layout (`layout/bloques.png`): banco de registros 56.254 µm² (34,8 %),
  ALU 13.584 µm² (8,4 %), contador de ciclos 3.995 µm² (2,5 %).

### 6.4 MEJOR BASE DE B (para los frentes C y E)

- **Rama**: `exp/fmax`, commit `e8eee90` (worktree `build/exp_fmax`).
- **RTL**: main `50f8a39` más B2 (`f053dec`, offset de byte de la carga registrado en la LSU) y
  B5 (`73f1d72` y `210b6a7`, banco de registros con latches `latq_1` y clock gating `icgtp_1`
  por registro). El RTL no cambió más en el frente B: `210b6a7` es el último commit que toca
  `rtl/`. Mismo CPI que main (2,665 en el juego completo, 2,953 en `sw/isa_test.s`), mismas
  trazas ciclo a ciclo.
- **Configuración**: `asic/rom/config.yaml` de la rama, que es la de main (D15, D20, D21) más
  `LINTER_ERROR_ON_LATCH: false` (necesario por los latches de B5) y
  `RUN_POST_GRT_RESIZER_TIMING: true` (la única perilla del flujo que ayuda, sección 6.1). No se
  cambia `SYNTH_STRATEGY` (sigue en el `AREA 0` implícito), ni el margen del resizer (10 ns de
  D20), ni la biblioteca (7 pistas).
- **Qué da**: cierre completo a 100 ns y 40 % con 165.358 µm² de celdas estándar; período mínimo
  23,25 ns (43,01 MHz), 16,14 MIPS con el CPI 2,665 del juego; 326 violaciones de max slew y 2 de
  max capacitancia a 100 ns (fb_pgrt_t100), 324 y 3 al período mínimo (fb_pgrt_t23p25).
- **Cuánto cuesta en área**: nada; **ahorra**. 165.358 µm² contra 182.265 de main a 100 ns, es
  decir -16.907 µm² (-9,3 %), y 172.211 contra 189.817 al período mínimo de cada una (-9,3 %).
  El ahorro viene de B5: el área de síntesis del módulo `espino_register_file` baja de
  73.655,5 µm² en main (`asic/rom/resultados/final/sintesis_stat.rpt`) a 52.425,8 µm²
  (`asic/rom/resultados/fb_t100/sintesis_stat.rpt`), -28,8 %, al cambiar 480 flip-flops por 480
  latches `latq_1` con 15 clock gating `icgtp_1`. En el layout final, las celdas secuenciales
  pasan de 990 celdas y 65.065,7 µm² en main a 1.024 celdas (544 flip-flops más 480 latches) y
  57.746,9 µm² (`design__instance__*__class:sequential_cell` de cada `metrics.json`). El die mide
  353.921 µm² en todas las corridas de esta base, con y sin post-GRT y de 100 a 23 ns, contra
  408.957 de main a 100 ns (-13,5 %): con la
  misma `FP_CORE_UTIL` del 40 %, menos área de celdas da un die más chico
  (`design__die__area` de cada `metrics.json`). Las dos únicas
  contrapartidas son de flujo, no de área: el linter necesita `LINTER_ERROR_ON_LATCH: false` y
  cada corrida tarda unos 14 minutos más por el paso post-GRT (27 min a 100 ns contra 16 min).
- **Advertencia para quien la tome**: con los latches, el WNS de setup de `metrics.json` es
  siempre 0,000 (sección 2). Para comparar variantes hay que usar `asic/margen_latch.py`; para
  decidir si cierra, `asic/verificar_cierre.py`, que sigue siendo válido. Y el STA final de la
  corrida queda en `56-openroad-stapostpnr` (no en `55-`) porque el paso post-GRT corre antes.

### 6.5 Lo que no se probó

- Períodos entre 23 y 23,25 ns: la regla de 0,5 ns se cumple con 0,25 ns de separación, así que
  no se gastaron corridas en afinar más.
- Combinación de post-GRT con `SYNTH_STRATEGY`: ninguna estrategia quedó a menos de 1,5 ns de
  cerrar a 23 ns, y el post-GRT da 0,236 ns, así que la combinación no puede cerrar a 23 ns.
- La 9t sin el clock gating de B5: quitaría del diseño la celda que causa los 30 errores de DRC,
  pero no se probó, y de todos modos el área de la 9t ya está 8,3 % sobre el límite de la sesión
  (207.271 contra 191.378 µm²), así que no habría cambiado la decisión (sección 4).
- Potencia con actividad real de la candidata: es el desempate de la regla de selección y solo se
  usa si dos candidatas empatan en MIPS, slew y capacitancia, lo que no ocurre aquí. El frente de
  potencia (D) la mide sobre main.
