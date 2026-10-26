
## Corrida final (tag final): T = 100 ns, FP_CORE_UTIL = 40 %

Configuración: asic/rom/config.yaml (D15, D20, D21). Criterios de cierre: asic/rom/resultados/final/cierre.md. Las tablas de este archivo las genera asic/final.sh con asic/recolectar.py.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Barrido de CLOCK_PERIOD con la configuración final (sección 3.4)

Corridas f1_* (mismo RTL y configuración que la final, solo cambia CLOCK_PERIOD). Cierra a 100, 32, 30, 26 y 25 ns; 24 ns no cierra por 0,004 ns en max_ss_125C_4v50. f1_t28 se detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (regla de tiempo del grupo) y no se cuenta. f1_t26, f1_t25 y f1_t24 tienen exactamente el mismo layout (celdas, área y largo de cables): con el margen de 10 ns de D20 el resizer llega a su límite y de ahí para abajo solo cambia el slack.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| f1_t32 | 32 | 17.409 | 0 | 4.395 | 0 | 0.450 | 0 | 1.081 | 0 | 4.395 | 0 | 0.178 | 0 | sí | 183725 | 0.484 | 408957 | 0 | 0 | 0 | sí | 490 | 38 | 0 |
| f1_t30 | 30 | 16.758 | 0 | 5.103 | 0 | 0.450 | 0 | 1.081 | 0 | 5.103 | 0 | 0.178 | 0 | sí | 186320 | 0.491 | 408957 | 0 | 0 | 0 | sí | 521 | 36 | 0 |
| f1_t26 | 26 | 13.160 | 0 | 1.996 | 0 | 0.450 | 0 | 1.081 | 0 | 1.996 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t25 | 25 | 12.160 | 0 | 0.996 | 0 | 0.450 | 0 | 1.081 | 0 | 0.996 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t24 | 24 | 11.160 | 0 | -0.004 | -0.004 | 0.450 | 0 | 1.081 | 0 | -0.004 | -0.004 | 0.178 | 0 | no | 189817 | 0.500 | 408957 | 0 | 0 | 0 | no | 532 | 36 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t32 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t30 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t26 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t25 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t24 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## RTL sin pre-decodificación (116fa20) con la configuración final (sección 3.4, efecto de D18)

Corridas r0_* del RTL del commit 116fa20 (sin D18) en un worktree con la misma asic/rom/config.yaml y pines.cfg de la corrida final, a 100 ns y al período mínimo del diseño final (26 ns, el primer punto que cerró; el final cierra también a 25 ns). Comparar con final y f1_t26.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| r0_t100 | 100 | 74.579 | 0 | 54.552 | 0 | 0.410 | 0 | 1.005 | 0 | 54.552 | 0 | 0.153 | 0 | sí | 174529 | 0.478 | 393525 | 0 | 0 | 0 | sí | 754 | 48 | 0 |
| r0_t26 | 26 | 10.461 | 0 | -3.175 | -1223.744 | 0.413 | 0 | 1.012 | 0 | -3.175 | -1223.744 | 0.155 | 0 | no | 181326 | 0.497 | 393525 | 0 | 0 | 0 | no | 648 | 46 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| r0_t100 | 146215.686 | 60673.133 | 921 | 73655.546 | 10005.722 | 3942.579 |
| r0_t26 | 146215.686 | 60673.133 | 921 | 73655.546 | 10005.722 | 3942.579 |
