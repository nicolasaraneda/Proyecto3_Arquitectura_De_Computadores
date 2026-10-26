# Exploraciones en ramas exp/* (bloque B)

Cada exploración vive en su rama `exp/<nombre>`, creada desde `main` y no fusionada,
con sus corridas y sus datos. Acá queda el resumen y el commit de cada rama. Las
corridas de cada rama se lanzan desde su worktree (`git worktree add build/exp_<nombre> exp/<nombre>`)
con la misma configuración final (`asic/rom/config.yaml`), y se verifican con
`make check` (80 tests del assembler y seis testbenches) y `make equiv` (traza de
`sw/isa_test.s` contra el commit 116fa20: idéntica ciclo a ciclo, o en el modo
funcional, misma secuencia de escrituras al banco, accesos al bus y salidas).

Referencia (main, configuración final D20 y D21): período mínimo 26 ns (f1_t26,
WNS 1,996 ns en max_ss; 24 ns no cierra por 0,004 ns), 38,5 MHz; área de celdas
estándar 182.265 µm² a 100 ns; CPI 2,953 en `isa_test.s` y 2,665 en el juego
completo (`game_tb`); 546 violaciones de max slew y 36 de max capacitancia a 100 ns.

## Tabla resumen

Generada por `asic/exploraciones_tabla.py` a partir de los `metrics.json` de cada rama
(período mínimo: menor CLOCK_PERIOD que cumple D14 más DRC, LVS y antenas; f máx = 1/T;
MIPS = f máx / CPI del juego; área y violaciones de la corrida a 100 ns). La columna
"corridas" da el WNS de setup en max_ss_125C_4v50 de cada período corrido.

| rama | commit | cambio | verificación | corridas (T: WNS max_ss) | T mínimo que cierra (ns) | f máx (MHz) | CPI isa_test | CPI juego | MIPS (f/CPI juego) | área stdcell a 100 ns (µm²) | slew / cap a 100 ns |
|---|---|---|---|---|---|---|---|---|---|---|---|
| main (referencia) | 2dd4e45 | configuración final D20 y D21 | check PASS, equiv ciclo a ciclo | 100: 65.22, 32: 4.39, 30: 5.10, 26: 2.00, 25: 1.00, 24: -0.00 (no cierra) | 25 | 40.0 | 2.953 | 2.665 | 15.0 | 182265 | 546 / 36 |
| exp/lsu-offset (B2) | eb29650 | offset de byte de la carga registrado en la LSU | check PASS, equiv ciclo a ciclo | 100: 67.04, 26: 4.54, 24: 0.09, 23: -0.91 (no cierra), 22: -1.91 (no cierra) | 24 | 41.7 | 2.953 | 2.665 | 15.6 | 181170 | 672 / 40 |
| exp/branch-cmp (B3) | 6ef475f | comparador de saltos desde el banco de registros | check PASS, equiv ciclo a ciclo | 100: 67.00, 26: 1.92, 24: -0.08 (no cierra) | 26 | 38.5 | 2.953 | 2.665 | 14.4 | 183962 | 554 / 29 |
| exp/lsu-branch (B2+B3) | 35b2d5d | B2 y B3 juntos | check PASS, equiv ciclo a ciclo | 100: 69.13, 24: -0.84 (no cierra) | 100 | 10.0 | 2.953 | 2.665 | 3.8 | 183890 | 689 / 39 |
| exp/cpi (B4) | dbc8018 | ROM y banco combinacionales, decode en el fetch, 1 instrucción por ciclo | check PASS, equiv funcional | 100: 41.73, 60: 1.73, 55: -3.27 (no cierra), 50: -4.19 (no cierra), 45: -1.75 (no cierra) | 60 | 16.7 | 1.004 | 1.312 | 12.7 | 158024 | 358 / 23 |
| exp/rf-latch (B5) | ba26813 | banco de registros con latches y clock gating | check PASS, equiv ciclo a ciclo | 100: 0.00, 26: 0.00 | 26 | 38.5 | 2.953 | 2.665 | 14.4 | 165369 | 312 / 2 |
| exp/signoff (B1), variante b1c | a8fd926 | reparación post-GRT con márgenes de 30 % (mejor variante dentro del 1 % de área) | mismo RTL que main | 100: 65.74, 26: 1.47 | 26 | 38.5 | 2.953 | 2.665 | 14.4 | 183091 | 489 / 19 |
| exp/signoff (B1), variante b1g | a8fd926 | márgenes del repair de placement en 30 % | mismo RTL que main | 100: 65.96, 26: 1.13 | 26 | 38.5 | 2.953 | 2.665 | 14.4 | 184368 | 260 / 22 |

Lectura: B2 es el único cambio que mejora el período mínimo (24 contra 25 ns) y además
baja el área; B4 reduce el área 13 % y el CPI a la mitad, pero el período sube a 60 ns y
rinde menos en MIPS; B5 reduce el área 9 % a 100 ns (3,6 % a 26 ns) y las violaciones de
slew y capacitancia sin tocar el período; B1 no llega a cero violaciones dentro del 1 %
de área (b1c a 26 ns: WNS 1,47 ns, 439/20; b1g a 26 ns: WNS 1,13 ns, 259/21).

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
