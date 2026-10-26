
## exp/lsu-branch (B2+B3): offset registrado en la LSU y comparador de saltos

Corridas de esta rama con la configuración final. b23_t26 se detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (regla de tiempo del grupo) y no tiene resultado.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b23_t100 | 100 | 74.612 | 0 | 69.129 | 0 | 0.385 | 0 | 0.958 | 0 | 69.129 | 0 | 0.134 | 0 | sí | 183890 | 0.478 | 414257 | 0 | 0 | 0 | sí | 689 | 39 | 0 |
| b23_t24 | 24 | 10.890 | 0 | -0.836 | -2.760 | 0.385 | 0 | 0.958 | 0 | -0.836 | -2.760 | 0.134 | 0 | no | 188638 | 0.490 | 414257 | 0 | 0 | 0 | no | 638 | 41 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| b23_t100 | 154214.995 | 65193.050 | 992 | 73655.546 | 10005.722 | 3942.579 |
| b23_t24 | 154214.995 | 65193.050 | 992 | 73655.546 | 10005.722 | 3942.579 |
