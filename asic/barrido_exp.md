
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
