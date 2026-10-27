
## Corrida final (tag final): T = 100 ns, FP_CORE_UTIL = 40 %

Configuración: asic/rom/config.yaml (D15, D20, D21). Criterios de cierre: asic/rom/resultados/final/cierre.md. Las tablas de este archivo las genera asic/tablas.sh con asic/recolectar.py.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Barrido de CLOCK_PERIOD con la configuración final (sección 3.4)

Corridas f1_* (mismo RTL y configuración que la final, solo cambia CLOCK_PERIOD). Cierra a 100, 32, 30, 26, 25 y 24,5 ns (f1_t24p5, WNS 0,496 ns en max_ss_125C_4v50, asic/rom/resultados/f1_t24p5/cierre.md); 24 ns no cierra por 0,004 ns en max_ss_125C_4v50. Período mínimo 24,5 ns (40,8 MHz); la corrida de 24,5 ns cierra la regla de la sesión de dejar 0,5 ns o menos entre el último período que cierra y el primero que no. f1_t28 se detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (regla de tiempo del grupo) y no se cuenta. f1_t26, f1_t25, f1_t24p5 y f1_t24 tienen exactamente el mismo layout (8.708 celdas, 189.817 µm² y 354.897 µm de cables): con el margen de 10 ns de D20 el resizer llega a su límite y de ahí para abajo solo cambia el slack, 1 ns de WNS por cada ns de período.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| f1_t32 | 32 | 17.409 | 0 | 4.395 | 0 | 0.450 | 0 | 1.081 | 0 | 4.395 | 0 | 0.178 | 0 | sí | 183725 | 0.484 | 408957 | 0 | 0 | 0 | sí | 490 | 38 | 0 |
| f1_t30 | 30 | 16.758 | 0 | 5.103 | 0 | 0.450 | 0 | 1.081 | 0 | 5.103 | 0 | 0.178 | 0 | sí | 186320 | 0.491 | 408957 | 0 | 0 | 0 | sí | 521 | 36 | 0 |
| f1_t26 | 26 | 13.160 | 0 | 1.996 | 0 | 0.450 | 0 | 1.081 | 0 | 1.996 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t25 | 25 | 12.160 | 0 | 0.996 | 0 | 0.450 | 0 | 1.081 | 0 | 0.996 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t24p5 | 24.500 | 11.660 | 0 | 0.496 | 0 | 0.450 | 0 | 1.081 | 0 | 0.496 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t24 | 24 | 11.160 | 0 | -0.004 | -0.004 | 0.450 | 0 | 1.081 | 0 | -0.004 | -0.004 | 0.178 | 0 | no | 189817 | 0.500 | 408957 | 0 | 0 | 0 | no | 532 | 36 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t32 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t30 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t26 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t25 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t24p5 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t24 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## RTL sin pre-decodificación (116fa20) con la configuración final (sección 3.4, efecto de D18)

Corridas r0_* del RTL del commit 116fa20 (sin D18) en un worktree (build/ref116, enlazado en asic/rom/runs/r0_*) con la misma asic/rom/config.yaml y pines.cfg de la corrida final, a 100 ns y al período mínimo del diseño final (26 ns, el primer punto que cerró; el final cierra también a 25 ns). Comparar con final y f1_t26.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| r0_t100 | 100 | 74.579 | 0 | 54.552 | 0 | 0.410 | 0 | 1.005 | 0 | 54.552 | 0 | 0.153 | 0 | sí | 174529 | 0.478 | 393525 | 0 | 0 | 0 | sí | 754 | 48 | 0 |
| r0_t26 | 26 | 10.461 | 0 | -3.175 | -1223.744 | 0.413 | 0 | 1.012 | 0 | -3.175 | -1223.744 | 0.155 | 0 | no | 181326 | 0.497 | 393525 | 0 | 0 | 0 | no | 648 | 46 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| r0_t100 | 146215.686 | 60673.133 | 921 | 73655.546 | 10005.722 | 3942.579 |
| r0_t26 | 146215.686 | 60673.133 | 921 | 73655.546 | 10005.722 | 3942.579 |

## Barrido de FP_CORE_UTIL a 100 ns con la configuración final (sección 3.5)

Corridas final (40 %) y u1_u50 a u1_u90; las de 72, 75, 78 y 79 % son del 27-10-2026. Cierran 50, 60, 70, 72, 75 y 78 %: la utilización máxima que cierra es 78 % (u1_u78: die 455,4 x 473,3 µm = 215.545 µm², utilización real 90,3 %, WNS de setup 59,6 ns en max_ss_125C_4v50 y hold 0,182 ns; asic/rom/resultados/u1_u78/cierre.md). u1_u79 y u1_u80 fallan en OpenROAD.CTS ([DPL-0036] Detailed placement failed: al legalizar después de insertar los buffers del árbol de reloj quedan instancias sin lugar, 6 del banco de registros en u1_u79 y 22 en u1_u80; asic/logs/u1_u79.log y asic/logs/u1_u80.log; extractos versionados en asic/rom/resultados/u1_u79/falla.txt y asic/rom/resultados/u1_u80/falla.txt) y u1_u90 en el placement global ([GPL-0301] Utilization 100.531 % exceeds 100%, asic/logs/u1_u90.log; extracto en asic/rom/resultados/u1_u90/falla.txt): no tienen métricas finales. A 78 % la ruta crítica deja de ser la de la ALU al banco de registros (slack 60,5 ns) y pasa a ser la salida seg2[2] del display (59,6 ns; 69,2 ns a 75 %), y las violaciones de slew suben de 424 a 880 pines. Gráfico: docs/figuras/utilizacion.png (asic/graficos.py --util).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| u1_u50 | 100 | 74.727 | 0 | 67.716 | 0 | 0.448 | 0 | 1.074 | 0 | 67.716 | 0 | 0.177 | 0 | sí | 179135 | 0.592 | 329861 | 0 | 0 | 0 | sí | 438 | 24 | 0 |
| u1_u60 | 100 | 74.700 | 0 | 63.675 | 0 | 0.434 | 0 | 1.054 | 0 | 63.675 | 0 | 0.166 | 0 | sí | 177115 | 0.701 | 276917 | 0 | 0 | 0 | sí | 378 | 20 | 0 |
| u1_u70 | 100 | 74.578 | 0 | 64.076 | 0 | 0.414 | 0 | 1.010 | 0 | 64.076 | 0 | 0.156 | 0 | sí | 176044 | 0.809 | 238967 | 0 | 0 | 0 | sí | 392 | 27 | 0 |
| u1_u72 | 100 | 74.741 | 0 | 65.715 | 0 | 0.442 | 0 | 1.064 | 0 | 65.715 | 0 | 0.174 | 0 | sí | 175921 | 0.834 | 232629 | 0 | 0 | 0 | sí | 388 | 29 | 0 |
| u1_u75 | 100 | 74.063 | 0 | 65.786 | 0 | 0.449 | 0 | 1.080 | 0 | 65.786 | 0 | 0.177 | 0 | sí | 175618 | 0.873 | 223753 | 0 | 0 | 0 | sí | 424 | 26 | 0 |
| u1_u78 | 100 | 69.224 | 0 | 59.602 | 0 | 0.456 | 0 | 1.088 | 0 | 59.602 | 0 | 0.182 | 0 | sí | 175227 | 0.903 | 215545 | 0 | 0 | 0 | sí | 880 | 49 | 0 |
| u1_u79 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| u1_u80 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| u1_u90 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u50 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u60 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u70 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u72 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u75 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u78 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Terminales ubicados por el flujo (sin D21), sección 3.5

Corrida u1_auto: asic/rom/config_pines_auto.yaml, idéntica a la final salvo que no define IO_PIN_ORDER_CFG y OpenROAD.IOPlacement ubica los terminales donde acorta los cables. Comparar con final (D21): largo de cables, DRC de ruteo por iteración (route__drc_errors__iter:N en metrics.json), slew y WNS.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| u1_auto | 100 | 74.680 | 0 | 65.213 | 0 | 0.417 | 0 | 1.019 | 0 | 65.213 | 0 | 0.157 | 0 | sí | 182204 | 0.480 | 408957 | 0 | 0 | 0 | sí | 569 | 31 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_auto | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Floorplan con DIE_AREA absoluto y aspecto 1,6:1 (sección 3.5)

Corrida d4_die (asic/rom/config_die.yaml, 27-10-2026): idéntica a la final salvo FP_SIZING: absolute y DIE_AREA 0 0 808,64 505,68 µm (aspecto 1,6:1; 408.913 µm², 0,011 % menos que los 408.957 µm² de la final, que mide 630,60 x 648,52 µm). CORE_AREA no se define: floorplan.tcl de LibreLane la calcula restando los márgenes de siempre (6,72 µm a los lados y 15,68 µm arriba y abajo), 795,20 x 474,32 µm = 377.179 µm² en 121 filas de 1420 sitios (final: 379.800 µm², 157 filas de 1102 sitios; 13-openroad-floorplan de cada corrida). Cierra (asic/rom/resultados/d4_die/cierre.md). Contra la final (metrics.json de cada una): cables 364.879 contra 352.253 µm (+3,6 %; ruteo global 509.586 contra 494.524 µm), cable más largo 975 contra 1.409 µm, WNS de setup 61,672 contra 65,223 ns en max_ss_125C_4v50 (hold 0,156 contra 0,178 ns), slew 567 contra 546 pines, capacitancia 33 contra 36, DRC del ruteo detallado por iteración 1.302, 279, 271, 0 contra 1.546, 501, 379, 0, celdas estándar 8.590 contra 8.670 y área de celdas 180.939 contra 182.265 µm² (-0,7 %). Layout y ruta crítica: asic/rom/resultados/d4_die/layout/.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| d4_die | 100 | 74.457 | 0 | 61.672 | 0 | 0.415 | 0 | 1.013 | 0 | 61.672 | 0 | 0.156 | 0 | sí | 180939 | 0.480 | 408913 | 0 | 0 | 0 | sí | 567 | 33 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| d4_die | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
