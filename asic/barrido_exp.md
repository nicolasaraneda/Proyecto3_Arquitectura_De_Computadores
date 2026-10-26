
## exp/cpi (B4): una instrucción por ciclo

Corridas de esta rama con la configuración final (asic/rom/config.yaml, D20 y D21). CPI medido con core_trace_tb (isa_test.s) 1,004 y con game_tb (juego completo) 1,312, contra 2,953 y 2,665 en main. Cierra a 100 y 60 ns; no a 55, 50 ni 45.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b4_t100 | 100 | 68.986 | 0 | 41.733 | 0 | 0.415 | 0 | 1.015 | 0 | 41.733 | 0 | 0.156 | 0 | sí | 158024 | 0.481 | 356012 | 0 | 0 | 0 | sí | 358 | 23 | 0 |
| b4_t60 | 60 | 28.986 | 0 | 1.733 | 0 | 0.415 | 0 | 1.015 | 0 | 1.733 | 0 | 0.156 | 0 | sí | 158024 | 0.481 | 356012 | 0 | 0 | 0 | sí | 358 | 23 | 0 |
| b4_t55 | 55 | 23.986 | 0 | -3.267 | -166.804 | 0.415 | 0 | 1.015 | 0 | -3.267 | -166.804 | 0.156 | 0 | no | 158024 | 0.481 | 356012 | 0 | 0 | 0 | no | 358 | 23 | 0 |
| b4_t50 | 50 | 21.225 | 0 | -4.190 | -474.223 | 0.415 | 0 | 1.015 | 0 | -4.190 | -474.223 | 0.156 | 0 | no | 158103 | 0.481 | 356012 | 0 | 0 | 0 | no | 361 | 23 | 0 |
| b4_t45 | 45 | 20.261 | 0 | -1.746 | -150.729 | 0.415 | 0 | 1.015 | 0 | -1.746 | -150.729 | 0.156 | 0 | no | 159246 | 0.485 | 356012 | 0 | 0 | 0 | no | 312 | 21 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| b4_t100 | 131760.294 | 52013.069 | 791 | 69309.050 | 10005.722 | 3942.579 |
| b4_t60 | 131760.294 | 52013.069 | 791 | 69309.050 | 10005.722 | 3942.579 |
| b4_t55 | 131760.294 | 52013.069 | 791 | 69309.050 | 10005.722 | 3942.579 |
| b4_t50 | 131760.294 | 52013.069 | 791 | 69309.050 | 10005.722 | 3942.579 |
| b4_t45 | 131760.294 | 52013.069 | 791 | 69309.050 | 10005.722 | 3942.579 |
