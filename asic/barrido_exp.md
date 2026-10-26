
## exp/rf-latch (B5): banco de registros con latches y clock gating

Corridas de esta rama con la configuración final más LINTER_ERROR_ON_LATCH=false. El WNS de setup 0,000 es la convención de OpenSTA para los endpoints de latch con préstamo de tiempo (ver max.rpt: a 100 ns toma prestados 3,38 ns de 49,3 disponibles; a 26 ns, 3,42 ns, y la peor ruta a un flip-flop tiene 4,36 ns de slack).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b5_t100 | 100 | 0 | 0 | 0 | 0 | 0.441 | 0 | 1.062 | 0 | 0 | 0 | 0.160 | 0 | sí | 165369 | 0.509 | 353516 | 0 | 0 | 0 | sí | 312 | 2 | 0 |
| b5_t26 | 26 | 0 | 0 | 0 | 0 | 0.441 | 0 | 0.755 | 0 | 0 | 0 | 0.164 | 0 | sí | 182941 | 0.563 | 353516 | 0 | 0 | 0 | sí | 347 | 7 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| b5_t100 | 130798.797 | 36545.690 | 542 | 52425.766 | 10005.722 | 3942.579 |
| b5_t26 | 130798.797 | 36545.690 | 542 | 52425.766 | 10005.722 | 3942.579 |
