# Rama exp/fmax (frente B): frecuencia máxima con B2 + B5 y perillas del flujo

RTL: main 50f8a39 + B2 (f053dec, offset de byte registrado en la LSU) + B5 (73f1d72 y 210b6a7,
banco de registros con latches latq_1 y clock gating icgtp_1). Configuración base:
asic/rom/config.yaml (D15, D20, D21 más LINTER_ERROR_ON_LATCH). Todas las corridas con
FP_CORE_UTIL = 40 %. Criterio de cierre: asic/verificar_cierre.py (cierre.md en cada carpeta
de asic/rom/resultados/<tag>/). Con B5 el WNS de setup que reporta metrics.json es 0,000 por
convención de OpenSTA (los endpoints de latch quedan en 0 mientras tengan préstamo de
tiempo); el margen real de las rutas a flip-flop y el préstamo de los latches se leen de
max.rpt de max_ss con asic/margen_latch.py (margen_latch.md en cada carpeta de resultados).

## Base B2 + B5: 100 ns y barrido de período

fb_t100 es la base a 100 ns y 40 %. fb_t24 cierra, fb_t23 y fb_t22 no (fb_t22 además tiene violación de hold en max_ss: hold WS -0,077 ns, por eso LibreLane terminó con código 2 aunque dejó metrics.json). fb_t23p5 completa la regla de 0,5 ns.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| fb_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.067 | 0 | 0 | 0 | 0.161 | 0 | sí | 165358 | 0.505 | 353921 | 0 | 0 | 0 | sí | 327 | 1 | 0 |
| fb_t24 | 24 | 0 | 0 | 0 | 0 | 0.436 | 0 | 0.335 | 0 | 0 | 0 | 0.152 | 0 | sí | 171289 | 0.523 | 353921 | 0 | 0 | 0 | sí | 351 | 2 | 0 |
| fb_t23 | 23 | 0 | 0 | -0.447 | -3.639 | 0.440 | 0 | 0.136 | 0 | -0.447 | -3.639 | 0.136 | 0 | no | 172185 | 0.526 | 353921 | 0 | 0 | 0 | no | 340 | 2 | 0 |
| fb_t22 | 22 | 0 | 0 | -1.670 | -39.765 | 0.444 | 0 | -0.077 | -0.154 | -1.670 | -39.765 | -0.077 | -0.154 | no | 171594 | 0.524 | 353921 | 0 | 0 | 0 | no | 368 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| fb_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| fb_t24 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| fb_t23 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| fb_t22 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |

## Perillas del resizer a 100 ns sobre la base

fb_pgrt_t100: RUN_POST_GRT_RESIZER_TIMING=true; fb_m5_t100 y fb_m15_t100: PL_RESIZER_SETUP_SLACK_MARGIN en 5 y 15 (la base usa 10). Pasadas como VAR=VAL al encolar.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| fb_pgrt_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.067 | 0 | 0 | 0 | 0.169 | 0 | sí | 165358 | 0.505 | 353921 | 0 | 0 | 0 | sí | 326 | 2 | 0 |
| fb_m5_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.067 | 0 | 0 | 0 | 0.161 | 0 | sí | 165358 | 0.505 | 353921 | 0 | 0 | 0 | sí | 327 | 1 | 0 |
| fb_m15_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.067 | 0 | 0 | 0 | 0.161 | 0 | sí | 165358 | 0.505 | 353921 | 0 | 0 | 0 | sí | 327 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| fb_pgrt_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| fb_m5_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| fb_m15_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |

## SYNTH_STRATEGY a 100 ns sobre la base

Copias de config.yaml que solo agregan SYNTH_STRATEGY (asic/rom/config_d0.yaml a config_d4.yaml: DELAY 0 a DELAY 4; config_a1.yaml a config_a3.yaml: AREA 1 a AREA 3). La base es AREA 0 (fb_t100).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| fb_d0_t100 | 100 | 0 | 0 | 0 | 0 | 0.398 | 0 | 0.981 | 0 | 0 | 0 | 0.146 | 0 | sí | 175410 | 0.507 | 373772 | 0 | 0 | 0 | sí | 539 | 1 | 0 |
| fb_d1_t100 | 100 | 0 | 0 | 0 | 0 | 0.439 | 0 | 1.059 | 0 | 0 | 0 | 0.172 | 0 | sí | 179082 | 0.510 | 380023 | 0 | 0 | 0 | sí | 430 | 3 | 0 |
| fb_d2_t100 | 100 | 0 | 0 | 0 | 0 | 0.439 | 0 | 1.059 | 0 | 0 | 0 | 0.172 | 0 | sí | 179969 | 0.512 | 379850 | 0 | 0 | 0 | sí | 482 | 11 | 0 |
| fb_d3_t100 | 100 | 0 | 0 | 0 | 0 | 0.441 | 0 | 1.063 | 0 | 0 | 0 | 0.173 | 0 | sí | 174518 | 0.509 | 372294 | 0 | 0 | 0 | sí | 499 | 7 | 0 |
| fb_d4_t100 | 100 | 0 | 0 | 0 | 0 | 0.449 | 0 | 1.077 | 0 | 0 | 0 | 0.177 | 0 | sí | 184948 | 0.476 | 417255 | 0 | 0 | 0 | sí | 1073 | 13 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| fb_d0_t100 | 138600.538 | 36673.011 | 544 | 52948.224 | 12157.018 | 4177.466 |
| fb_d1_t100 | 141008.672 | 36673.011 | 544 | 55029.274 | 12315.072 | 4311.373 |
| fb_d2_t100 | 140942.816 | 36673.011 | 544 | 54967.808 | 12200.922 | 4282.835 |
| fb_d3_t100 | 138029.786 | 36673.011 | 544 | 52842.854 | 12457.760 | 4555.040 |
| fb_d4_t100 | 155374.061 | 36673.011 | 544 | 55944.672 | 14589.299 | 4862.368 |
