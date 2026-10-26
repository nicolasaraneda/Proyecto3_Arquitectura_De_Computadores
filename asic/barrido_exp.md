
## exp/signoff (B1), primera ronda a 100 ns

b1a: MAX_FANOUT_CONSTRAINT=6. b1c: RUN_POST_GRT_DESIGN_REPAIR=true con GRT_DESIGN_REPAIR_MAX_SLEW_PCT y GRT_DESIGN_REPAIR_MAX_CAP_PCT en 30. b1d: EXTRA_EXCLUDED_CELLS agrega buf_2. b1e: CTS_MAX_CAP=0.15. Referencia: final en main (slew 546, cap 36, área 182.265 µm²).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b1a_t100 | 100 | 74.537 | 0 | 64.334 | 0 | 0.447 | 0 | 1.073 | 0 | 64.334 | 0 | 0.176 | 0 | sí | 191885 | 0.505 | 408957 | 0 | 0 | 0 | sí | 272 | 1 | 0 |
| b1c_t100 | 100 | 74.692 | 0 | 65.742 | 0 | 0.450 | 0 | 1.081 | 0 | 65.742 | 0 | 0.178 | 0 | sí | 183091 | 0.482 | 408957 | 0 | 0 | 0 | sí | 489 | 19 | 0 |
| b1d_t100 | 100 | 72.894 | 0 | 51.227 | 0 | 0.547 | 0 | 1.246 | 0 | 51.227 | 0 | 0.239 | 0 | sí | 193700 | 0.510 | 408957 | 0 | 0 | 0 | sí | 1979 | 3 | 551 |
| b1e_t100 | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| b1a_t100 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| b1c_t100 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| b1d_t100 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| b1e_t100 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
