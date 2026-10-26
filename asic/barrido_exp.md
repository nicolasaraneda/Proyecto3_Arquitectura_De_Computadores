
## exp/lsu-offset (B2): offset de byte registrado en la LSU

Corridas de esta rama con la configuración final (asic/rom/config.yaml, D20 y D21), lanzadas desde su worktree. Referencia en main: final (100 ns), f1_t26, f1_t25 y f1_t24 (asic/final.md).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2_t100 | 100 | 74.583 | 0 | 67.043 | 0 | 0.443 | 0 | 1.066 | 0 | 67.043 | 0 | 0.174 | 0 | sí | 181170 | 0.477 | 409040 | 0 | 0 | 0 | sí | 672 | 40 | 0 |
| b2_t24 | 24 | 11.105 | 0 | 0.088 | 0 | 0.443 | 0 | 1.066 | 0 | 0.088 | 0 | 0.174 | 0 | sí | 186555 | 0.491 | 409040 | 0 | 0 | 0 | sí | 667 | 38 | 0 |
| b2_t26 | 26 | 14.484 | 0 | 4.543 | 0 | 0.443 | 0 | 1.066 | 0 | 4.543 | 0 | 0.174 | 0 | sí | 191806 | 0.505 | 409040 | 0 | 0 | 0 | sí | 584 | 39 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| b2_t100 | 152201.997 | 65193.050 | 992 | 73655.546 | 10005.722 | 3942.579 |
| b2_t24 | 152201.997 | 65193.050 | 992 | 73655.546 | 10005.722 | 3942.579 |
| b2_t26 | 152201.997 | 65193.050 | 992 | 73655.546 | 10005.722 | 3942.579 |
