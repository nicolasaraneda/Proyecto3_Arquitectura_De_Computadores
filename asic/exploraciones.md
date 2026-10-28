# Exploraciones en ramas exp/*

Cada exploración vive en su rama `exp/<nombre>`, creada desde `main` y no fusionada, con sus
corridas y sus datos. Acá queda el resumen y el commit de cada rama. Las corridas de cada rama se
lanzan desde su worktree (`git worktree add build/exp_<nombre> exp/<nombre>`) con la configuración
final (`asic/rom/config.yaml`) de esa rama, y se verifican con `make check` (80 pruebas del
assembler y seis testbenches) y `make equiv` (traza de `sw/isa_test.s` contra el commit 116fa20:
idéntica ciclo a ciclo, o en el modo funcional, misma secuencia de escrituras al banco, accesos al
bus y salidas).

Hay dos bloques de exploraciones:

- **Bloque B (26-10-2026):** B1 a B5, ramas `exp/signoff`, `exp/lsu-offset`, `exp/branch-cmp`,
  `exp/lsu-branch`, `exp/cpi` y `exp/rf-latch`. Ninguna entró en la corrida final (D22).
- **Sesión del 27 y 28-10-2026:** ramas `exp/pipeline` (y sus variantes `exp/pipeline-b2` y
  `exp/pipeline-b5`), `exp/fmax`, `exp/signoff0` y `exp/candidata`, con la regla de selección fija
  de la sesión: métrica principal MIPS = f máx / CPI del juego completo, período barrido hasta
  dejar 0,5 ns o menos entre el último período que cierra y el primero que no, límite de área de
  celdas estándar a 100 ns de 105 por ciento de la de `main` (191.378 µm²) y cierre completo a
  100 ns y 40 por ciento de utilización. Desempate: violaciones de max slew y de max capacitancia,
  potencia con actividad real, área. La propuesta de decisión está en `docs/propuesta_d23.md` y en
  D23 de `docs/decisiones.md`.

Referencia (`main`, configuración final D15, D18, D20 y D21): período mínimo **24,5 ns**
(`f1_t24p5`, WNS 0,496 ns en max_ss; 24 ns no cierra por 0,004 ns), 40,8 MHz; área de celdas
estándar 182.265 µm² a 100 ns y 189.817 µm² a 24,5 ns; CPI 2,953 en `isa_test.s` y 2,665 en el
juego completo (`game_tb`); **15,3 MIPS**; 546 violaciones de max slew y 36 de max capacitancia a
100 ns; potencia 8,97 mW sin actividad y 12,76 mW con la actividad real del juego en nom_tt
(`asic/potencia/resultado.md`). Fuentes: `asic/final.md`, `asic/rom/resultados/f1_t24p5/cierre.md`.

## Tabla resumen

Generada por `python3 asic/tabla_sesion.py asic/ramas_sesion.json --md asic/exploraciones_tabla.md`
a partir de los `metrics.json` de cada corrida. Cada fila declara sus corridas en
`asic/ramas_sesion.json`, porque una misma rama tiene corridas con configuraciones distintas y el
período mínimo es el de una configuración concreta. Período mínimo: menor `CLOCK_PERIOD` que
cumple D14 más DRC, LVS y antenas; la columna "cota inferior" da el período mayor que NO cierra,
para que se vea la resolución del barrido. f máx = 1 / T mínimo; MIPS = f máx / CPI del juego
(Ley de Hierro). Área y violaciones son de la corrida a 100 ns. La columna de potencia con
actividad real solo está medida para `main` (frente D3).

| rama o variante | commit | cambio | verificación | barrido (T: WNS max_ss) | T mínimo (ns) | cota inferior | f máx (MHz) | CPI isa_test | CPI juego | MIPS | área stdcell a 100 ns (µm²) | área die a 100 ns (µm²) | slew / cap a 100 ns | potencia con actividad (mW) | nota |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| main (referencia) | fd497bf | configuración final (D15, D18, D20, D21) | check PASS, equiv ciclo a ciclo contra 116fa20 | 32: 4.395, 30: 5.103, 26: 1.996, 25: 0.996, 24.5: 0.496, 24: -0.004 (no cierra) | 24.5 | (no cierra a 24) | 40.8 | 2.953 | 2.665 | 15.3 | 182.265 | 408.957 | 546 / 36 | 12.76 | potencia con actividad: ventana de espera de 3 s en nom_tt (asic/potencia/resultado.md) |
| exp/lsu-offset (B2) | eb29650 | offset de byte de la carga registrado en la LSU | check PASS, equiv ciclo a ciclo | 26: 4.543, 24: 0.088, 23: -0.912 (no cierra), 22: -1.912 (no cierra) | 24 | (no cierra a 23) | 41.7 | 2.953 | 2.665 | 15.6 | 181.170 | 409.040 | 672 / 40 | n/d | sesión anterior (26-10-2026) |
| exp/branch-cmp (B3) | 6ef475f | comparador de saltos desde el banco de registros | check PASS, equiv ciclo a ciclo | 26: 1.915, 24: -0.085 (no cierra) | 26 | (no cierra a 24) | 38.5 | 2.953 | 2.665 | 14.4 | 183.962 | 413.568 | 554 / 29 | n/d | sesión anterior (26-10-2026) |
| exp/lsu-branch (B2+B3) | 35b2d5d | B2 y B3 juntos | check PASS, equiv ciclo a ciclo | b23_t26: incompleta, 24: -0.836 (no cierra) | ninguna cierra | (no cierra a 24) | n/d | 2.953 | 2.665 | n/d | 183.890 | 414.257 | 689 / 39 | n/d | b23_t26 detenida a los 40 min (incompleta); sesión anterior |
| exp/cpi (B4) | dbc8018 | ROM y banco combinacionales, decode en el fetch, 1 instrucción por ciclo | check PASS, equiv funcional | 60: 1.733, 55: -3.267 (no cierra), 50: -4.190 (no cierra), 45: -1.746 (no cierra) | 60 | (no cierra a 55) | 16.7 | 1.004 | 1.312 | 12.7 | 158.024 | 356.012 | 358 / 23 | n/d | sesión anterior; brecha de 5 ns, no cumple la regla de 0,5 ns |
| exp/rf-latch (B5) | ba26813 | banco de registros con latches latq_1 y clock gating icgtp_1 | check PASS, equiv ciclo a ciclo | 26: 0.000 | 26 | sin cota | 38.5 | 2.953 | 2.665 | 14.4 | 165.369 | 353.516 | 312 / 2 | n/d | sesión anterior; WNS 0,000 por el préstamo de tiempo de los latches |
| exp/signoff (B1), variante b1c | a8fd926 | reparación post-GRT con márgenes de 30 % | mismo RTL que main | 26: 1.472 | 26 | sin cota | 38.5 | 2.953 | 2.665 | 14.4 | 183.091 | 408.957 | 489 / 19 | n/d | sesión anterior; no se barrió bajo 26 ns |
| exp/signoff (B1), variante b1g | a8fd926 | márgenes del repair de placement en 30 % | mismo RTL que main | 26: 1.132 | 26 | sin cota | 38.5 | 2.953 | 2.665 | 14.4 | 184.368 | 408.957 | 260 / 22 | n/d | sesión anterior; no se barrió bajo 26 ns |
| exp/pipeline (A) | 4fdf9e7 | lectura del banco y decodificación en el fetch (EarlyRead), banco write-through | check PASS, equiv funcional, hazard_test, mutaciones detectadas, 0 X usados, post-synth PASS | 40: 2.555, 32: 1.591, 26: 0.198, 25.5: -0.302 (no cierra), 25: -0.802 (no cierra), 24.5: -1.302 (no cierra) | 26 | (no cierra a 25.5) | 38.5 | 1.969 | 1.665 | 23.1 | 186.087 | 418.503 | 506 / 32 | n/d | CPI del juego con la estrategia 2 (EarlyRead = 0): 2,665, igual que main |
| exp/pipeline-b2 (A+B2) | 58d32de | A más el offset de byte registrado en la LSU | check PASS, equiv funcional, hazard_test, 0 X usados | 26: 0.591, 25.5: 0.091, 25: -0.409 (no cierra) | 25.5 | (no cierra a 25) | 39.2 | 1.969 | 1.665 | 23.6 | 186.432 | 419.131 | 571 / 37 | n/d | base de exp/candidata |
| exp/pipeline-b5 (A+B5) | fd10cc4 | A más el banco de latches con clock gating | check PASS, equiv funcional, hazard_test, 0 X usados | 34: 0.000, 32: 0.000, 30: 0.000, 29: 0.000, pa_b5_t28: incompleta, 26: -7.102 (no cierra), 25: -8.102 (no cierra) | 29 | (no cierra a 26) | 34.5 | 1.969 | 1.665 | 20.7 | 165.211 | 353.855 | 386 / 3 | n/d | WNS 0,000 por el préstamo de tiempo de los latches |
| exp/fmax (B2+B5, base) | 796833d | B2 y B5 juntos, sin cambio en el pipeline | check PASS, equiv ciclo a ciclo | 24: 0.000, 23.5: 0.000, 23: -0.447 (no cierra), 22: -1.670 (no cierra) | 23.5 | (no cierra a 23) | 42.6 | 2.953 | 2.665 | 16.0 | 165.358 | 353.921 | 327 / 1 | n/d | WNS 0,000 por los latches; margen real en max.rpt (asic/margen_latch.py) |
| exp/fmax con reparación post-GRT | 796833d | B2+B5 más RUN_POST_GRT_RESIZER_TIMING | check PASS, equiv ciclo a ciclo (mismo RTL que la base) | 23.25: 0.000, 23: -0.211 (no cierra) | 23.25 | (no cierra a 23) | 43.0 | 2.953 | 2.665 | 16.1 | 165.358 | 353.921 | 326 / 2 | n/d | mejor base del frente B |
| exp/signoff0, c30 (sin costo de período) | c7637b7 | B2+B5 con reparación post-GRT de diseño y márgenes de 30 % | mismo RTL que exp/fmax | 24: 0.000, 23.5: 0.000 | 23.5 | sin cota | 42.6 | 2.953 | 2.665 | 16.0 | 165.494 | 353.921 | 323 / 1 | n/d | 323 slew / 1 cap con +0,08 % de área y el mismo período mínimo que la base |
| exp/signoff0, cero slew | c7637b7 | B2+B5 con LAYERS_RC medidos, repair post-GRT 30 % y CTS_DISTANCE_BETWEEN_BUFFERS | mismo RTL que exp/fmax | 24: 0.000, 24: -0.473 (no cierra), 23: -1.221 (no cierra) | 24 | (no cierra a 24) | 41.7 | 2.953 | 2.665 | 15.6 | 177.807 | 353.921 | 0 / 2 | n/d | 0 slew / 2 cap a 100 ns con +7,5 % de área; al período, sc_fullp_t24 (margen 15) cierra a 24 ns con 3 / 1 |
| exp/signoff0, g30 (mejor slew dentro del 1 %) | c7637b7 | B2+B5 con márgenes del repair de placement en 30 % | mismo RTL que exp/fmax | 24: -2.500 (no cierra) | ninguna cierra | (no cierra a 24) | n/d | 2.953 | 2.665 | n/d | 166.423 | 353.921 | 214 / 1 | n/d | 214 slew / 1 cap con +0,64 % de área, pero no cierra a 24 ns |
| exp/candidata (A+B2, paquete completo) | ff8adb9 | A mas B2 con la configuracion final de main y EarlyRead=1 | check PASS, equiv funcional, hazard_test, 0 X, post-synth, SDF en 3 esquinas, DRC de KLayout con control positivo, revision independiente | 26: 0.591, 25.5: 0.091, 25: -0.409 (no cierra) | 25.5 | (no cierra a 25) | 39.2 | 1.969 | 1.665 | 23.6 | 186.432 | 419.131 | 571 / 37 | 12.39 | corridas base reusadas de exp/pipeline-b2 (mismo arbol); potencia con actividad: ventana de polling en nom_tt |
| exp/candidata, variante de cero slew | ff8adb9 | la candidata con los RC de cable medidos y reparacion post-GRT (frente C) | mismo RTL que la candidata | sin barrido | ninguna cierra | sin cota | n/d | 1.969 | 1.665 | n/d | 209.185 | 419.131 | 0 / 0 | n/d | 0 slew y 0 cap a 100 ns, pero 114,8 por ciento del area de main: fuera del limite de 105 por ciento |
| main con LAYERS_RC (exploracion del coordinador) | fd497bf | el RTL de main con los RC de cable medidos y reparacion post-GRT | mismo RTL que main | 23: 0.756, 22: 0.215, 21.5: -0.383 (no cierra) | 22 | (no cierra a 21.5) | 45.5 | 2.953 | 2.665 | 17.1 | 201.309 | 408.957 | 2 / 1 | n/d | 110,4 por ciento del area de main: fuera del limite; 0 slew en las 9 esquinas; datos en exp/candidata-rc, asic/main_rc/ |
| exp/candidata-rc (exploracion del coordinador) | 297c5fe | la candidata con los RC de cable medidos y reparacion post-GRT | mismo RTL que la candidata | 25: 1.579, 24: 1.755, 23: 1.494, 22: 0.656, 21.5: 0.876, 21: -0.129 (no cierra) | 21.5 | (no cierra a 21) | 46.5 | 1.969 | 1.665 | 27.9 | 208.439 | 419.131 | 0 / 1 | n/d | 114,4 por ciento del area de main: fuera del limite; 0 slew en las 9 esquinas; ver docs/modelo_cable.md de la rama |

Lectura de la sesión del 27 y 28-10-2026:

- **La métrica principal la gana `exp/pipeline-b2` (A+B2) con 23,6 MIPS contra 15,3 de `main`, un
  54 por ciento más.** El pipeline nuevo (lectura del banco de registros y decodificación durante
  el fetch) baja el CPI del juego de 2,665 a 1,665 y cuesta 1 ns de período (25,5 contra 24,5 ns)
  y 2,3 por ciento de área a 100 ns, dentro del límite.
- Las dos variantes del pipeline se comportan distinto: el offset de byte registrado de B2 le gana
  medio nanosegundo (25,5 contra 26 ns) por 0,2 por ciento de área, mientras que el banco de
  latches de B5 le quita cuatro nanosegundos y medio (30 contra 25,5 ns) aunque ahorra 11 por
  ciento de área, porque con la lectura anticipada el camino que pasa por los latches deja de
  tener medio ciclo de holgura.
- Sin tocar el pipeline, lo más rápido es `exp/fmax` (B2+B5) con la reparación post-GRT del
  resizer: 23,25 ns (43,0 MHz), 1,25 ns menos que `main`, con 9,3 por ciento menos de área. Pero
  con el CPI de 2,665 eso son 16,1 MIPS, muy por debajo de los 23,6 del pipeline: el período no
  compensa el CPI.
- `exp/signoff0` llega a **0 violaciones de max slew** (`sc_full_t100`, con los RC de cable
  medidos del PDK, la reparación post-GRT al 30 por ciento y el espaciado de buffers del CTS),
  pero cuesta 7,5 por ciento de área, muy por encima del límite de 1 por ciento, y empeora el
  período mínimo. Dentro del límite y sin costo de período lo mejor es `sc_c30` (323 slew y 1
  capacitancia contra 327 y 1 de su base, es decir casi sin efecto); la variante que más limpia
  dentro del límite es `sc_g30` (214 slew) pero ya no cierra a 24 ns. Las violaciones de
  capacitancia, en cambio, bajan solas de 36 a 1 con el banco de latches de B5, que elimina los
  480 multiplexores de retención y sus buffers de fanout.

## B2: exp/lsu-offset

- Qué cambia: `rtl/espino_core/espino_load_store_unit.v` guarda `addr_i[1:0]` en `boff_q`
  al emitir la carga y alinea el dato leído con ese registro. El dato llega un ciclo
  después, con el pipeline detenido, así que `addr_i[1:0]` vale lo mismo en los dos
  ciclos: el comportamiento no cambia, pero la ALU sale de la ruta de alineación y
  write-back (la ruta crítica de f1_t26: `alu_operator[1]` -> ALU -> `lsu_addr[1]`
  -> alineación -> `rf_wdata[11]` -> banco).
- Verificación: `make check` PASS (6 testbenches, 80 tests); `make equiv` trazas
  idénticas ciclo a ciclo (1018 eventos, dos estrategias de memoria).
- Corridas (`asic/barrido_exp.md` de la rama): b2_t100 cierra con WNS 67,04 ns en max_ss
  (main 65,22) y 181.170 µm² de celdas (main 182.265, -0,6 %); b2_t26 cierra con 4,54 ns
  (main 2,00); b2_t24 cierra con 0,09 ns (main no cierra por 0,004); b2_t23 (-0,91) y
  b2_t22 (-1,91) no cierran, con el mismo layout que b2_t24. Período mínimo 24 ns
  (41,7 MHz) contra 25 ns. La ruta crítica a 24 ns ya no
  pasa por la ALU: va de `rf_ready` (ops_valid_q) por el control de stall y `rf_we` a los
  muxes de retención del banco (`build/exp_lsu_offset/asic/rom/resultados/b2_t24/layout/ruta_critica.txt`).
  Slew y capacitancia a 100 ns: 672 / 40 (main 546 / 36).

## B3: exp/branch-cmp

- Qué cambia: `rtl/espino_core/espino_id_stage.v` agrega un comparador (igualdad,
  menor con signo y sin signo) que toma `rf_rdata_a_i` y `rf_rdata_b_i` directo del
  banco de registros, y `branch_taken_o` usa ese resultado en vez de `cmp_result_o`
  de la ALU, que pasa por los muxes de operandos. Un salto siempre compara rs1 con
  rs2, así que el resultado es el mismo. La ALU conserva sus comparadores para SLT y
  SLTU; su `cmp_result_o` queda sin uso y la síntesis lo elimina.
- Verificación: `make check` PASS; `make equiv` idéntica ciclo a ciclo.
- Corridas: b3_t100 WNS 67,00 ns, 183.962 µm² (+0,9 % por los comparadores nuevos);
  b3_t26 cierra con 1,92 ns (main 2,00); b3_t24 no cierra (-0,085 ns). Solo no mejora el
  período mínimo: el salto no estaba en la ruta crítica (la ruta de la carga lo tapa).
  Slew y capacitancia a 100 ns: 554 / 29.

## B2 + B3: exp/lsu-branch

- Los dos cambios anteriores (cherry-pick de ambas ramas). Verificación igual: PASS e idéntica ciclo a ciclo.
- Corridas: b23_t100 WNS 69,13 ns (la mejor a 100 ns), 183.890 µm² (+0,9 %), slew/cap 689/39;
  b23_t24 no cierra (-0,84 ns): la ruta crítica pasa a ser la del salto, del registro de
  lectura del banco (`lsu_wdata[30]`, o sea rs2) por el comparador nuevo y `pc_set` hasta un
  bit del PC (`build/exp_lsu_branch/asic/rom/resultados/b23_t24/layout/ruta_critica.txt`);
  b23_t26 se detuvo a los 40 minutos en ResizerTimingPostCTS (regla de tiempo) y no tiene
  resultado. Juntos no superan a B2 solo en período mínimo: una vez sacada la ALU de la ruta
  de la carga, el límite siguiente es el salto, y el comparador dedicado lo acorta pero no
  lo saca de la ruta (sigue leyendo el banco y escribiendo el PC en el mismo ciclo).

## B4: exp/cpi

- Qué cambia: la memoria de instrucciones entrega la instrucción de `pc_q` en el
  mismo ciclo (ROM combinacional, sin registro de instrucción; en la estrategia 2 la
  lectura del arreglo de flip-flops también es combinacional), el banco de registros
  se lee de forma combinacional (sin los 64 flip-flops de salida), el decodificador
  trabaja en el mismo ciclo (sin los 82 registros de pre-decodificación de D18) y
  desaparece el ciclo de espera (`rf_ready_o = 1`). Cada instrucción ejecuta en un
  ciclo salvo las cargas, que esperan un ciclo el dato de la memoria o del periférico
  (lectura registrada). Un salto tomado tampoco deja una instrucción de más que
  invalidar. Archivos: `espino_if_stage.v`, `espino_id_stage.v`, `espino_register_file.v`,
  `pochoco_mem_rom.v`, `pochoco_mem_ff.v`.
- Verificación: `make check` PASS (las seis simulaciones, incluido el juego completo
  con las dos estrategias); `make equiv MODO=funcional`: las secuencias de escrituras
  al banco (46, sin x0), accesos al bus (22) y salidas (2) son idénticas a las de
  116fa20; ciclo a ciclo no puede serlo porque cambia el número de ciclos.
- CPI (Ley de Hierro, tiempo = instrucciones x CPI x T): `isa_test.s` 1,004 (3000 ciclos,
  2988 instrucciones) contra 2,953; juego completo (`game_tb`, 10 rondas con error y
  reintento): 1,312 (1.595.008 ciclos, 1.216.019 instrucciones) contra 2,665
  (1.599.759 ciclos, 600.218 instrucciones). El juego pasa la mitad de los ciclos en
  lazos de espera con `lw`, de ahí que el CPI no llegue a 1.
- Corridas (`asic/barrido_exp.md` de la rama): b4_t100 cierra con WNS 41,73 ns en max_ss y
  158.024 µm² de celdas estándar (-13,3 % contra main: 791 flip-flops en vez de 990, sin los
  64 de salida del banco, los 82 de pre-decodificación, los 32 del registro de instrucción y
  los 33 de PC y validez de la etapa IF); b4_t60 cierra con 1,73 ns; b4_t55 (-3,27),
  b4_t50 (-4,19) y b4_t45 (-1,75) no cierran. Período mínimo 60 ns (16,7 MHz; la brecha
  queda en 5 ns porque es una exploración). La ruta crítica es la de un ciclo completo:
  PC -> ROM -> decodificador -> muxes de lectura del banco -> ALU -> write-back.
- Ley de Hierro: MIPS = 16,7 / 1,312 = 12,7, contra 40,0 / 2,665 = 15,0 del diseño actual.
  El CPI baja a la mitad pero el período sube 2,4 veces: con esta ROM y este banco de
  registros, ejecutar en un ciclo rinde 15 % menos que el pipeline de dos ciclos, aunque
  ahorra 13 % de área. Para el juego da lo mismo (espera botones y mide con CYCLES).

## B1: exp/signoff

Objetivo: llevar a cero las violaciones de max slew (546 pines) y max capacitancia (36
pines) de la corrida final solo con configuración del flujo, sin empeorar el período mínimo
ni el área en más de 1 %. Causa de las violaciones de capacitancia que aparecieron al excluir
buf_1 (D20): 34 de los 36 pines son salidas de buffers `buf_2` que el resizer inserta para
repartir nets de fanout 10 (`fanout*` del banco de registros, 10 entradas de `mux2_2` de
unos 0,025 pF cada una, 0,24 a 0,26 pF contra el límite de 0,2 pF de
`MAX_CAPACITANCE_CONSTRAINT`); con buf_1 el resizer partía esos nets en más trozos. Los otros
2 son el buffer raíz del árbol de reloj (`clkbuf_0_clk`, 0,35 pF: ocho `clkbuf_16` colgando)
y uno de segundo nivel. Las violaciones de slew son entradas de `mux2_2` (147) y de buffers
(68) manejadas por celdas chicas (`aoi21_1`, `buf_2`, `nor2_1`) en la esquina ss.

Primera ronda, a 100 ns (comparar con final: slew 546, cap 36, área 182.265 µm², WNS 65,22):

| variante | cambio | slew | cap | área (µm²) | WNS max_ss (ns) | comentario |
|---|---|---|---|---|---|---|
| b1a | `MAX_FANOUT_CONSTRAINT = 6` | 272 | 1 | 191.885 (+5,3 %) | 64,33 | la que más limpia, pero 1.176 buffers y 5 % de área: fuera del límite |
| b1c | `RUN_POST_GRT_DESIGN_REPAIR = true`, márgenes de slew y cap del repair post-GRT 30 % | 489 | 19 | 183.091 (+0,5 %) | 65,74 | mejora moderada dentro del límite |
| b1d | excluir también `buf_2` | 1.979 | 3 | 193.700 (+6,3 %) | 51,23 | mucho peor: los buffers grandes alargan los nets y el slew se dispara |
| b1e | `CTS_MAX_CAP = 0,15 pF` | 546 | 36 | 182.265 (0 %) | 65,22 | sin efecto: la caracterización del CTS cambia pero el árbol queda igual |

Segunda ronda, a 100 ns:

| variante | cambio | slew | cap | área (µm²) | WNS max_ss (ns) | comentario |
|---|---|---|---|---|---|---|
| b1f | `MAX_FANOUT_CONSTRAINT = 8` | 307 | 2 | 185.431 (+1,7 %) | 63,36 | casi sin capacitancia, pero pasa el 1 % de área |
| b1g | `DESIGN_REPAIR_MAX_SLEW_PCT` y `DESIGN_REPAIR_MAX_CAP_PCT` en 30 (repair de placement) | 260 | 22 | 184.368 (+1,2 %) | 65,96 | el mejor slew; la memoria se mantuvo en 3,5 GB (los 40 % de y3/y4 la llenaban) |
| b1h | fanout 8 más repair post-GRT 30 % | 277 | 3 | 185.536 (+1,8 %) | 63,43 | parecido a b1f |

Tercera ronda, a 100 ns:

| variante | cambio | slew | cap | área (µm²) | WNS max_ss (ns) | comentario |
|---|---|---|---|---|---|---|
| b1i | márgenes del repair de placement en 25 % | 510 | 38 | 182.674 (+0,2 %) | 66,35 | casi no cambia: el salto está entre 25 y 30 % |
| b1j | márgenes 30 % más repair post-GRT 30 % | 277 | 15 | 184.535 (+1,2 %) | 65,82 | parecido a b1g en slew, mejor en capacitancia |

Período: b1c_t26 cierra con WNS 1,47 ns (f1_t26: 2,00) y 190.712 µm² (+0,5 %), slew/cap
439/20; b1g_t26 cierra con 1,13 ns y 190.102 µm² (+0,15 %), 259/21. Ninguna de las dos
empeora el período mínimo medido (26 ns cierra; 25 ns no se corrió en la rama).

Conclusión de B1: con configuración del flujo no se llega a cero. Cada variante cambia
buffers por área: las que más limpian (fanout 6: 272/1; márgenes 30 % más post-GRT: 277/15)
cuestan 5,3 % y 1,2 % de área. Dentro del límite de 1 % la mejor es b1c (repair post-GRT con
márgenes de 30 %: 489 pines de slew y 19 de capacitancia, +0,5 % de área, mismo WNS). Las
dos violaciones de capacitancia del árbol de reloj (buffer raíz con ocho `clkbuf_16`) no las
mueve ninguna variante del resizer ni `CTS_MAX_CAP`; habría que cambiar la topología del
árbol (`CTS_SINK_CLUSTERING_*`) o aceptar el buffer raíz grande. Por qué no desaparecen con
el resizer: el límite de 3 ns de `MAX_TRANSITION_CONSTRAINT` es la SDC del PDK (la biblioteca
permite 7 ns) y la reparación trabaja con parásitos estimados en placement y ruteo global,
mientras que el STA final usa los extraídos del ruteo detallado en la esquina lenta.

## B5: exp/rf-latch (opcional)

- Qué cambia: `rtl/espino_core/espino_register_file.v` guarda los 480 bits en latches
  `latq_1` (43,9 µm²) en vez de flip-flops `dffq_1` (63,7 µm²) con mux de retención
  `mux2_2` (32,9 µm²), y cada uno de los 15 registros tiene una celda de clock gating
  integrado `icgtp_1` (61,5 µm²) que deja pasar un solo pulso de reloj cuando ese
  registro se escribe. El enable del clock gate es combinacional (`we_i` y la
  comparación de `waddr_i`), lo muestrea la celda en la fase baja previa al flanco en
  que el core comete la escritura; el dato se registra en ese flanco (`wdata_q`, 32
  flip-flops) y entra a los latches durante la fase alta siguiente. Las celdas se
  instancian directamente a través de dos envoltorios (`rtl/gf180_cells.v`) con un
  modelo de comportamiento para simulación y lint (`ifdef SYNTHESIS`). Los puertos de
  lectura siguen registrados y el resto del core no cambia.
- Ahorro esperado: 480 x (63,7 + 32,9 - 43,9) - 15 x 61,5 - 32 x 63,7 = unos 22.000 µm²
  (12 % del área de celdas de síntesis). La medida real sale de las corridas b5_*.
- Verificación: `make check` PASS; `make equiv` idéntica ciclo a ciclo (1018 eventos).
  Un primer intento con el enable registrado (`we_q`, `waddr_q`) falló (X en las
  lecturas): el clock gate muestrea el enable en la fase baja anterior al flanco, así
  que un enable registrado llega un ciclo tarde respecto del dato.
- Corridas (`asic/barrido_exp.md` de la rama): b5_t100 cierra con DRC, LVS y antenas
  limpios y hold 0,16 ns; área de celdas 165.369 µm² (-9,3 % contra main; die 353.516 µm²,
  -13,6 %), 8.073 celdas; la síntesis mapeó los 480 `latq_1` y los 15 `icgtp_1`
  (`06-yosys-synthesis/reports/stat.rpt`) y las violaciones de slew y capacitancia bajan a
  312 y 2 (main 546 y 36) porque desaparecen los 480 muxes de retención y sus buffers de
  fanout. STA: OpenSTA trata los 480 latches como "positive level-sensitive latch" con
  préstamo de tiempo (la ruta `wdata_q` -> latch toma prestados 3,38 ns de los 49,3
  disponibles y reporta slack 0,000 por convención: un latch abierto "cumple" mientras le
  quede préstamo), y agrega chequeos de clock gating en las 15 celdas `icgtp_1`
  ("clock gating-check end-point" en `sta.log`), todos cumplidos. El CTS construye un
  árbol de buffers por cada reloj gated. b5_t26 también cierra (DRC, LVS y antenas limpios,
  hold 0,16 ns): área 182.941 µm² contra 189.817 de main a 26 ns (-3,6 %), slew/cap 347/7;
  préstamo de 3,42 ns en los latches y 4,36 ns de slack en la peor ruta a flip-flop, así
  que el período mínimo no empeora (queda por barrer bajo 26 ns).
- Limitación del criterio: el WNS de setup que reporta la corrida es 0,000 porque los
  endpoints de latch quedan en 0 con préstamo; el margen real de las rutas a flip-flops hay
  que leerlo en `max.rpt` (las rutas que no terminan en latch).

---

# Sesión del 27 y 28-10-2026

Las corridas de esta sesión se lanzaron todas desde una cola única (`asic/cola.sh`, con
`asic/encolar.sh` y `asic/esperar.sh`): un solo proceso con un máximo de 3 corridas simultáneas,
corte a los 40 minutos, y chequeo de memoria y disco antes de cada lanzamiento. El estado de cada
corrida queda en `asic/logs/cola_estado.txt` (encolada, lanzada, terminada, fallida, incompleta).

## A: exp/pipeline (lectura del banco y decodificación en el fetch)

- Qué cambia: la ROM de la estrategia 1 es combinacional, así que la instrucción de `pc_q` se
  conoce un ciclo antes de que se cargue en el registro de instrucción. Con esa salida
  (`rom_data`) el core pide la lectura sincrónica del banco de registros y registra las salidas
  del decodificador en el mismo flanco en que se carga la instrucción, de modo que al llegar a la
  ejecución los operandos y el decode ya están listos y desaparece el ciclo de espera
  (`ops_valid_q`). El banco de registros sigue con lectura registrada (no se vuelve combinacional
  como en B4) y gana write-through: la salida registrada toma `wdata` cuando `raddr == waddr` con
  `we` y la dirección no es x0. Archivos: `rtl/espino_core/espino_id_stage.v`,
  `espino_if_stage.v`, `espino_register_file.v`, `espino_controller.v`, `rtl/pochoco_soc.v`,
  `rtl/asic_top.v`. Un parámetro del core (`EarlyRead`) permite volver a la temporización actual,
  que es lo que usa la estrategia 2, cuya memoria tiene lectura registrada y no puede anticipar.
- Riesgos de datos y de control resueltos y documentados en `docs/pipeline.md` de la rama:
  lectura del registro que escribe la instrucción anterior (write-through), carga seguida de uso,
  `jal` y `jalr` seguidos de uso del link, escrituras a x0, y salto tomado (la lectura anticipada
  y el decode de la instrucción descartada no tienen efecto).
- Verificación: `make check` PASS (80 pruebas del assembler y los seis testbenches, con las dos
  estrategias de memoria); `make equiv MODO=funcional` con `sw/isa_test.s`, secuencias de
  escrituras al banco (46), accesos al bus (22) y salidas (2) idénticas a las de 116fa20;
  `sw/hazard_test.s` nuevo (56 comprobaciones, 483 palabras) con trazas equivalentes a las de
  `main` (`make equiv PROG=hazard_test REF=main MODO=funcional`: 348 eventos de banco, 63 de bus y
  2 de salida iguales); dos mutaciones (`MUTA_FWD` sin write-through y `MUTA_LOADUSE` con la
  lectura un flanco antes del commit de la carga) que las pruebas detectan; monitor de valores
  desconocidos usados con 0 en 620.217 escrituras al banco del juego completo; `make post-synth`
  PASS con el netlist de la rama y su control negativo.
- CPI: 1,969 en `isa_test.s` (contra 2,953) y 1,665 en el juego completo (contra 2,665); con la
  estrategia 2 los valores de `main` sin cambio. El juego ejecuta 60 por ciento más instrucciones
  en los mismos ciclos: espera por tiempo, no por instrucciones.
- Corridas: período mínimo 26 ns (38,5 MHz; 25,5 ns no cierra por 0,302 ns), área 186.087 µm² a
  100 ns (102,1 por ciento de `main`), 506 slew y 32 capacitancia. MIPS 23,1 contra 15,3.

## A + B2: exp/pipeline-b2 (la base de la candidata)

El pipeline más el offset de byte de la carga registrado en la LSU (B2, commit 7ff1d06 de
`exp/lsu-offset`). Misma verificación completa. Período mínimo 25,5 ns (39,2 MHz; 25 ns no cierra
por 0,409 ns), área 186.432 µm² a 100 ns (102,3 por ciento de `main`), 571 slew y 37 capacitancia.
MIPS 23,6, el mejor de la sesión. Es la base de `exp/candidata`.

## A + B5: exp/pipeline-b5

El pipeline más el banco de registros con latches y clock gating (B5), con el write-through
reimplementado sobre los latches. Misma verificación completa. Área 165.211 µm² a 100 ns (90,6 por
ciento de `main`, el menor de la sesión) y solo 3 violaciones de capacitancia, pero el período
mínimo sube a 29 ns (34,5 MHz, 20,7 MIPS): a 26 ns el WNS cae a -7,1 ns, y la corrida de 28 ns se
detuvo a los 40 minutos en la reparación de timing (incompleta), así que esta variante es la única
de la sesión que no cierra la regla de 0,5 ns de resolución. Con la lectura anticipada
el camino que entra a los latches pierde el medio ciclo de holgura que tenía con el pipeline de
dos ciclos, así que el ahorro de área se paga con período.

## B: exp/fmax (frecuencia máxima con el core actual)

B2 y B5 juntos sobre el core de `main`, más un barrido de perillas del flujo. Detalle en
`docs/fmax.md` de la rama. Base a 100 ns: 165.358 µm² (90,7 por ciento de `main`), 327 slew y 1
capacitancia, período mínimo 23,5 ns. Con `RUN_POST_GRT_RESIZER_TIMING` el período mínimo baja a
23,25 ns (43,0 MHz), el mejor de la sesión, sin costo de área. Las perillas de `SYNTH_STRATEGY`
(AREA 1 a 3 y DELAY 0 a 4) y los márgenes del resizer en 5 y 15 no mejoran el período; la
biblioteca de 9 pistas (`gf180mcu_fd_sc_mcu9t5v0`) existe en el PDK instalado pero su corrida no
cierra. Con el CPI del core actual (2,665) son 16,1 MIPS, bastante menos que el pipeline.

## C: exp/signoff0 (cero violaciones de slew y de capacitancia)

Sobre la base B2+B5. Detalle, causas y pines restantes en `docs/signoff0.md` de la rama. Cero
violaciones de max slew se alcanza (`sc_full_t100`: 0 slew y 2 capacitancia) con los RC de cable
medidos del PDK en `LAYERS_RC`, la reparación post-GRT al 30 por ciento y el espaciado de buffers
del CTS, pero cuesta 7,5 por ciento de área (177.807 contra 165.358 µm²), muy por encima del
límite de 1 por ciento de la sesión, y empeora el período mínimo. Dentro del límite: `sc_c30`
(reparación post-GRT de diseño con márgenes de 30 por ciento) deja 323 slew y 1 capacitancia con
0,08 por ciento más de área y el mismo período mínimo; `sc_g30` (márgenes del repair de placement
en 30 por ciento) baja a 214 slew con 0,64 por ciento más de área pero ya no cierra a 24 ns.

## E: exp/candidata (el paquete completo de A+B2)

Rama creada desde `exp/pipeline-b2`: el mismo RTL, con el paquete completo que el informe
necesitaría si pasara a ser la corrida final. Detalle en `docs/candidata.md` de la rama y en
`docs/propuesta_d23.md` de `main`, sección 6. Lo medido: cierre a 100 ns y 40 por ciento con DRC
de Magic y de KLayout, LVS y antenas limpios y las 9 esquinas de setup y hold; período mínimo
25,5 ns con la regla de 0,5 ns; barrido de utilización de 50 a 90 por ciento (máxima que cierra
78 por ciento, área mínima 0,221 mm²); las dos estrategias de memoria (la 2 cierra a 100 ns y su
período mínimo empeora a 69,5 ns contra 62 de `main`); síntesis jerárquica; figuras del layout;
simulación post-síntesis con control negativo, `post-synth-final` de 320.000 ciclos y post-PnR con
SDF en tres esquinas; DRC de KLayout con control positivo; y potencia con actividad real en la
ventana de polling (12,392 mW en nom_tt contra 11,504 de `main`), más 8,597 mW sin actividad, que
es menos que los 8,971 de `main`.

Las dos variantes de signoff del frente C medidas sobre este RTL quedaron fuera del paquete: la de
márgenes del repair de placement baja el slew de 571 a 279 pines pero ya no cierra al período
mínimo, y la de los RC de cable medidos llega a 0 violaciones de slew y 0 de capacitancia pero
cuesta 114,8 por ciento del área de `main`, fuera del límite de la sesión.

## Exploración del coordinador: el modelo de cable del resizer explica la diferencia de período

Ramas `exp/candidata-rc` (worktree `build/exp_candidata_rc`) y un worktree desprendido de `main`
(`build/main_rc`), las dos con la configuración de `LAYERS_RC` del frente C más la reparación
post-GRT, corridas con los tags `co_rc_*` y `co_rcm_*`. Con los parásitos de cable medidos en vez
de los del tech LEF, el RTL de `main` cierra a 22 ns (45,5 MHz; 21,5 no cierra) y el de la
candidata a 21,5 ns (46,5 MHz; 21 no cierra), las dos con la regla de 0,5 ns cerrada. O sea que la
candidata no es más lenta que `main`: es medio nanosegundo más rápida, y a 23 ns cierra con el
doble de margen (1,494 contra 0,756 ns en max_ss). El nanosegundo de diferencia de la
configuración del enunciado lo produce la estimación optimista con la que el resizer decide dónde
poner buffers, no la ruta nueva del pipeline. Con el CPI de cada uno son 17,1 MIPS para `main` y
27,9 MIPS para la candidata. La configuración no puede ser la final porque cuesta
110,4 por ciento del área de `main` sobre el RTL de `main` y 114,4 por ciento sobre el de la
candidata, los dos por encima del límite de 105 por ciento. Como efecto secundario deja 0
violaciones de max slew en las 9 esquinas en los dos diseños. Detalle, tabla completa y
reproducción en `docs/modelo_cable.md` de la rama `exp/candidata-rc`.

