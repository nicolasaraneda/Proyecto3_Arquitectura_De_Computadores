
## exp/branch-cmp (B3): comparador de saltos desde el banco de registros

Corridas de esta rama con la configuración final (asic/rom/config.yaml, D20 y D21), lanzadas desde su worktree. Referencia en main: final (100 ns), f1_t26, f1_t25 y f1_t24 (asic/final.md).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b3_t100 | 100 | 73.971 | 0 | 66.997 | 0 | 0.444 | 0 | 1.066 | 0 | 66.997 | 0 | 0.175 | 0 | sí | 183962 | 0.479 | 413568 | 0 | 0 | 0 | sí | 554 | 29 | 0 |
| b3_t24 | 24 | 11.164 | 0 | -0.085 | -0.086 | 0.444 | 0 | 1.067 | 0 | -0.085 | -0.086 | 0.175 | 0 | no | 191127 | 0.497 | 413568 | 0 | 0 | 0 | no | 501 | 29 | 0 |
| b3_t26 | 26 | 13.164 | 0 | 1.915 | 0 | 0.444 | 0 | 1.067 | 0 | 1.915 | 0 | 0.175 | 0 | sí | 191127 | 0.497 | 413568 | 0 | 0 | 0 | sí | 501 | 29 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| b3_t100 | 153949.376 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| b3_t24 | 153949.376 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| b3_t26 | 153949.376 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
