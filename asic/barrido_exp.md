
## Frente C, primera tanda a 100 ns (base, márgenes del repair, RC medidos, SDC de PnR, CTS)

sc_base: config.yaml sin variantes. sc_g30: DESIGN_REPAIR_MAX_SLEW_PCT y DESIGN_REPAIR_MAX_CAP_PCT en 30. sc_c30: RUN_POST_GRT_DESIGN_REPAIR=true con GRT_DESIGN_REPAIR_MAX_SLEW_PCT y GRT_DESIGN_REPAIR_MAX_CAP_PCT en 30. sc_j30: sc_g30 más sc_c30. sc_rc: config_rc.yaml (LAYERS_RC por esquina, RC de cable medidos). sc_sdc2: config_sdc2.yaml (PNR_SDC_FILE con 2 ns y 0,15 pF, SIGNOFF_SDC_FILE genérica). sc_rcc: config_rc.yaml más RUN_POST_GRT_DESIGN_REPAIR=true (márgenes post-GRT por defecto 10 %). sc_rccs: config_rc.yaml más CTS_SINK_CLUSTERING_SIZE=20 y CTS_SINK_CLUSTERING_MAX_DIAMETER=100. sc_rccd: config_rc.yaml más CTS_DISTANCE_BETWEEN_BUFFERS=100.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sc_base_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.067 | 0 | 0 | 0 | 0.161 | 0 | sí | 165358 | 0.505 | 353921 | 0 | 0 | 0 | sí | 327 | 1 | 0 |
| sc_g30_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.066 | 0 | 0 | 0 | 0.174 | 0 | sí | 166423 | 0.508 | 353921 | 0 | 0 | 0 | sí | 214 | 1 | 0 |
| sc_c30_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.060 | 0 | 0 | 0 | 0.157 | 0 | sí | 165494 | 0.505 | 353921 | 0 | 0 | 0 | sí | 323 | 1 | 0 |
| sc_j30_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.066 | 0 | 0 | 0 | 0.174 | 0 | sí | 166423 | 0.508 | 353921 | 0 | 0 | 0 | sí | 214 | 1 | 0 |
| sc_rc_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.068 | 0 | 0 | 0 | 0.174 | 0 | sí | 172560 | 0.527 | 353921 | 0 | 0 | 0 | sí | 47 | 2 | 0 |
| sc_sdc2_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.064 | 0 | 0 | 0 | 0.157 | 0 | sí | 172988 | 0.528 | 353921 | 0 | 0 | 0 | sí | 85 | 2 | 0 |
| sc_rcc_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.068 | 0 | 0 | 0 | 0.174 | 0 | sí | 174007 | 0.531 | 353921 | 0 | 0 | 0 | sí | 2 | 1 | 0 |
| sc_rccs_t100 | 100 | 0 | 0 | 0 | 0 | 0.419 | 0 | 1.024 | 0 | 0 | 0 | 0.158 | 0 | sí | 172639 | 0.527 | 353921 | 0 | 0 | 0 | sí | 37 | 4 | 0 |
| sc_rccd_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.068 | 0 | 0 | 0 | 0.174 | 0 | sí | 171520 | 0.524 | 353921 | 0 | 0 | 0 | sí | 44 | 3 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| sc_base_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_g30_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_c30_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_j30_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_rc_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_sdc2_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_rcc_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_rccs_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_rccd_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |

## Frente C, segunda tanda: combinación completa (LAYERS_RC, repair post-GRT 30 %, CTS_DISTANCE_BETWEEN_BUFFERS=100) a 100, 24 y 23 ns, clusters de 6 sumideros, márgenes post-GPL en 0, y sc_g30 a 24 ns

sc_full: config_rc.yaml más RUN_POST_GRT_DESIGN_REPAIR=true, GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30, GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 y CTS_DISTANCE_BETWEEN_BUFFERS=100 (a 100, 24 y 23 ns). sc_fulls6: sc_full más CTS_SINK_CLUSTERING_SIZE=6. sc_full0: sc_full con DESIGN_REPAIR_MAX_SLEW_PCT=0 y DESIGN_REPAIR_MAX_CAP_PCT=0 (el repair post-GPL sin margen, para medir cuánto del área pone el margen de 20 %). sc_g30_t24: config.yaml con márgenes post-GPL en 30 (la mejor dentro del 1 % de la tanda 1) a 24 ns.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sc_full_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.069 | 0 | 0 | 0 | 0.171 | 0 | sí | 177807 | 0.543 | 353921 | 0 | 0 | 0 | sí | 0 | 2 | 0 |
| sc_full_t24 | 24 | 0 | 0 | -0.473 | -0.691 | 0.443 | 0 | 0.296 | 0 | -0.473 | -0.691 | 0.174 | 0 | no | 182140 | 0.556 | 353921 | 0 | 0 | 0 | no | 0 | 2 | 0 |
| sc_fulls6_t100 | 100 | 0 | 0 | 0 | 0 | 0.409 | 0 | 1.006 | 0 | 0 | 0 | 0.153 | 0 | sí | 183567 | 0.560 | 353921 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| sc_full0_t100 | 100 | 0 | 0 | 0 | 0 | 0.385 | 0 | 0.955 | 0 | 0 | 0 | 0.134 | 0 | sí | 176714 | 0.540 | 353921 | 0 | 0 | 0 | sí | 9 | 2 | 0 |
| sc_g30_t24 | 24 | 0 | 0 | -2.500 | -35.248 | 0.443 | 0 | 0.342 | 0 | -2.500 | -35.248 | 0.157 | 0 | no | 169908 | 0.519 | 353921 | 0 | 0 | 0 | no | 237 | 2 | 0 |
| sc_full_t23 | 23 | 0 | 0 | -1.221 | -10.259 | 0.443 | 0 | 0.194 | 0 | -1.221 | -10.259 | 0.174 | 0 | no | 183354 | 0.560 | 353921 | 0 | 0 | 0 | no | 0 | 2 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| sc_full_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_full_t24 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_fulls6_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_full0_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_g30_t24 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_full_t23 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |

## Frente C, tercera tanda: repair post-GRT con margenes 30, 50 y 65 % a 100 ns; repair post-GRT 30 % al periodo (24 y 23,5 ns); y las combinaciones con LAYERS_RC mas resizer post-GRT de timing a 24 ns

Base de comparacion: sc_base_t100 a 100 ns (165.358 um2, 327 slew / 1 cap) y fb_t24 / fb_t23p5 del frente B al periodo. Cierre segun asic/verificar_cierre.py.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sc_c50_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.060 | 0 | 0 | 0 | 0.157 | 0 | sí | 166592 | 0.509 | 353921 | 0 | 0 | 0 | sí | 321 | 2 | 0 |
| sc_c65_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.066 | 0 | 0 | 0 | 0.174 | 0 | sí | 171316 | 0.523 | 353921 | 0 | 0 | 0 | sí | 811 | 1 | 0 |
| sc_c30_t24 | 24 | 0 | 0 | 0 | 0 | 0.444 | 0 | 0.334 | 0 | 0 | 0 | 0.161 | 0 | sí | 171403 | 0.523 | 353921 | 0 | 0 | 0 | sí | 342 | 2 | 0 |
| sc_c30_t23p5 | 23.500 | 0 | 0 | 0 | 0 | 0.444 | 0 | 0.240 | 0 | 0 | 0 | 0.158 | 0 | sí | 172290 | 0.526 | 353921 | 0 | 0 | 0 | sí | 323 | 1 | 0 |
| sc_fullp_t24 | 24 | 0 | 0 | 0 | 0 | 0.443 | 0 | 0.658 | 0 | 0 | 0 | 0.174 | 0 | sí | 184698 | 0.564 | 353921 | 0 | 0 | 0 | sí | 3 | 1 | 0 |
| sc_rccp_t24 | 24 | 0 | 0 | 0 | 0 | 0.443 | 0 | 0.692 | 0 | 0 | 0 | 0.174 | 0 | sí | 185602 | 0.567 | 353921 | 0 | 0 | 0 | sí | 3 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| sc_c50_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_c65_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_c30_t24 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_c30_t23p5 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_fullp_t24 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc_rccp_t24 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |

## Frente C, cuarta tanda (sc2_*): el resizer de timing post-GRT sobre la variante dentro del 1 % y la configuracion recomendada a 100 ns y a 22,5 ns

sc2_g30p_t24 prueba si RUN_POST_GRT_RESIZER_TIMING le devuelve el periodo a sc_g30 (no lo hace); sc2_rccp_t100 y sc2_rccp_t22p5 miden la configuracion recomendada (LAYERS_RC mas repair post-GRT 30 % mas resizer de timing post-GRT) a 100 ns y al periodo.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sc2_g30p_t24 | 24 | 0 | 0 | -2.411 | -32.918 | 0.443 | 0 | 0.360 | 0 | -2.411 | -32.918 | 0.169 | 0 | no | 169935 | 0.519 | 353921 | 0 | 0 | 0 | no | 191 | 1 | 0 |
| sc2_rccp_t100 | 100 | 0 | 0 | 0 | 0 | 0.443 | 0 | 1.068 | 0 | 0 | 0 | 0.174 | 0 | sí | 178834 | 0.546 | 353921 | 1 | 0 | 0 | no | 0 | 1 | 0 |
| sc2_rccp_t22p5 | 22.500 | 0 | 0 | 0 | 0 | 0.443 | 0 | 0.520 | 0 | 0 | 0 | 0.174 | 0 | sí | 186599 | 0.570 | 353921 | 0 | 0 | 0 | sí | 0 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| sc2_g30p_t24 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc2_rccp_t100 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
| sc2_rccp_t22p5 | 130954.656 | 36673.011 | 544 | 52425.766 | 10005.722 | 3942.579 |
