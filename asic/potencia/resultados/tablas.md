# Tablas de potencia con actividad real (generadas por asic/potencia/tabla.py)

Fuente de cada numero: `asic/potencia/resultados/<modo o ventana>_<esquina>.rpt`, tabla de `report_power -corner <esquina>` (OpenSTA 2.7.0 de la imagen de LibreLane 3.0.16, `asic/potencia/potencia.tcl`). Potencias en mW; los porcentajes de reloj, secuencial y combinacional son la fila de cada grupo sobre la fila Total del mismo reporte.

## Ventanas simuladas (netlist post-PnR de la corrida final, resultados/ventanas.txt)

| Ventana | Que cubre | Ciclos [ini, fin) | Ciclos | VCD (MB) | Variables del VCD | Codigos distintos | Duracion del VCD (ns) | Tiempo de simulacion |
|---|---|---|---|---|---|---|---|---|
| polling | polling de botones, pantalla de inicio | [500, 20500) | 20000 | 81.1 | 27462 | 6894 | 2000000 | 0m17.982s |
| espera | espera de 3 s de la ronda (wt_wait_loop) | [265000, 285000) | 20000 | 89.9 | 27462 | 6894 | 2000000 | 3m24.222s |
| display | 2000 ciclos alrededor del 01 en el display | [261194, 263194) | 2000 | 10.7 | 27462 | 6894 | 200000 | 3m9.422s |
| rafaga | solo la rafaga round_begin + show_bcd + wait_tenths | [262150, 262490) | 340 | 3.2 | 27462 | 6894 | 34000 | 3m4.850s |
| polling_prof1 | calibracion: polling con $dumpvars(1, dut), solo puertos | [500, 20500) | 20000 | 69.8 | 5821 | 5821 | 2000000 | 0m15.531s |
| polling_init0 | polling con los flip-flops sin reset en 0 (dffq_func_init.v) | [500, 20500) | 20000 | 70.6 | 27462 | 6894 | 2000000 | 0m20.432s |
| espera_init0 | espera con los flip-flops sin reset en 0 (dffq_func_init.v) | [265000, 285000) | 20000 | 87.1 | 27462 | 6894 | 2000000 | 2m41.428s |
| display_init0 | display con los flip-flops sin reset en 0 (dffq_func_init.v) | [261194, 263194) | 2000 | 9.8 | 27462 | 6894 | 200000 | 2m18.510s |
| rafaga_init0 | rafaga con los flip-flops sin reset en 0 (dffq_func_init.v) | [262150, 262490) | 340 | 3.1 | 27462 | 6894 | 34000 | 2m17.323s |
| polling_init1 | polling con los flip-flops sin reset en 1 (dffq_func_init.v) | [500, 20500) | 20000 | 80.3 | 27462 | 6894 | 2000000 | 0m30.938s |
| espera_init1 | espera con los flip-flops sin reset en 1 (dffq_func_init.v) | [265000, 285000) | 20000 | 90.9 | 27462 | 6894 | 2000000 | 4m14.938s |
| display_init1 | display con los flip-flops sin reset en 1 (dffq_func_init.v) | [261194, 263194) | 2000 | 10.6 | 27462 | 6894 | 200000 | 3m27.420s |
| rafaga_init1 | rafaga con los flip-flops sin reset en 1 (dffq_func_init.v) | [262150, 262490) | 340 | 3.2 | 27462 | 6894 | 34000 | 3m27.723s |

## Total por modo y esquina (mW) y diferencia contra el modo defecto

| Esquina | defecto | cero | polling | espera | display | rafaga | pines anotados (VCD) |
|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 8.971 | 9.084 (+1.3 %) | 11.504 (+28.2 %) | 12.755 (+42.2 %) | 12.379 (+38.0 %) | 12.172 (+35.7 %) | 20679 |
| `nom_ss_125C_4v50` | 7.309 | 7.401 (+1.3 %) | 9.325 (+27.6 %) | 10.316 (+41.1 %) | 10.017 (+37.1 %) | 9.853 (+34.8 %) | 20679 |
| `nom_ff_n40C_5v50` | 11.125 | 11.239 (+1.0 %) | 14.304 (+28.6 %) | 15.883 (+42.8 %) | 15.411 (+38.5 %) | 15.149 (+36.2 %) | 20679 |
| `min_tt_025C_5v00` | 8.873 | 8.986 (+1.3 %) | 11.300 (+27.4 %) | 12.504 (+40.9 %) | 12.143 (+36.9 %) | 11.946 (+34.6 %) | 20679 |
| `min_ss_125C_4v50` | 7.234 | 7.326 (+1.3 %) | 9.169 (+26.7 %) | 10.123 (+39.9 %) | 9.836 (+36.0 %) | 9.679 (+33.8 %) | 20679 |
| `min_ff_n40C_5v50` | 10.997 | 11.110 (+1.0 %) | 14.040 (+27.7 %) | 15.558 (+41.5 %) | 15.105 (+37.4 %) | 14.856 (+35.1 %) | 20679 |
| `max_tt_025C_5v00` | 9.089 | 9.202 (+1.2 %) | 11.750 (+29.3 %) | 13.058 (+43.7 %) | 12.664 (+39.3 %) | 12.444 (+36.9 %) | 20679 |
| `max_ss_125C_4v50` | 7.399 | 7.491 (+1.2 %) | 9.514 (+28.6 %) | 10.548 (+42.6 %) | 10.236 (+38.3 %) | 10.061 (+36.0 %) | 20679 |
| `max_ff_n40C_5v50` | 11.280 | 11.394 (+1.0 %) | 14.622 (+29.6 %) | 16.275 (+44.3 %) | 15.780 (+39.9 %) | 15.502 (+37.4 %) | 20679 |

## defecto: sin actividad (lo que hizo el flujo)

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 8.971 | 7.021 | 1.948 | 0.0019 | 41.3 | 58.6 | 0.0 | 78.3 % | 21.7 % |
| `nom_ss_125C_4v50` | 7.309 | 5.711 | 1.585 | 0.0123 | 40.7 | 59.2 | 0.1 | 78.1 % | 21.7 % |
| `nom_ff_n40C_5v50` | 11.125 | 8.766 | 2.357 | 0.0023 | 41.6 | 58.4 | 0.0 | 78.8 % | 21.2 % |
| `min_tt_025C_5v00` | 8.873 | 7.005 | 1.866 | 0.0019 | 40.8 | 59.1 | 0.0 | 78.9 % | 21.0 % |
| `min_ss_125C_4v50` | 7.234 | 5.702 | 1.519 | 0.0123 | 40.2 | 59.8 | 0.1 | 78.8 % | 21.0 % |
| `min_ff_n40C_5v50` | 10.997 | 8.736 | 2.258 | 0.0023 | 41.1 | 58.9 | 0.0 | 79.4 % | 20.5 % |
| `max_tt_025C_5v00` | 9.089 | 7.042 | 2.046 | 0.0019 | 42.0 | 58.0 | 0.0 | 77.5 % | 22.5 % |
| `max_ss_125C_4v50` | 7.399 | 5.722 | 1.665 | 0.0123 | 41.3 | 58.6 | 0.1 | 77.3 % | 22.5 % |
| `max_ff_n40C_5v50` | 11.280 | 8.803 | 2.475 | 0.0023 | 42.2 | 57.8 | 0.0 | 78.0 % | 21.9 % |

## cero: actividad global 0 (solo el reloj)

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 9.084 | 7.136 | 1.946 | 0.0019 | 40.8 | 59.2 | 0.0 | 78.6 % | 21.4 % |
| `nom_ss_125C_4v50` | 7.401 | 5.805 | 1.584 | 0.0123 | 40.2 | 59.8 | 0.0 | 78.4 % | 21.4 % |
| `nom_ff_n40C_5v50` | 11.239 | 8.881 | 2.355 | 0.0023 | 41.2 | 58.8 | 0.0 | 79.0 % | 21.0 % |
| `min_tt_025C_5v00` | 8.986 | 7.119 | 1.865 | 0.0019 | 40.3 | 59.7 | 0.0 | 79.2 % | 20.8 % |
| `min_ss_125C_4v50` | 7.326 | 5.796 | 1.518 | 0.0123 | 39.7 | 60.3 | 0.0 | 79.1 % | 20.7 % |
| `min_ff_n40C_5v50` | 11.110 | 8.851 | 2.257 | 0.0023 | 40.7 | 59.3 | 0.0 | 79.7 % | 20.3 % |
| `max_tt_025C_5v00` | 9.202 | 7.156 | 2.044 | 0.0019 | 41.5 | 58.5 | 0.0 | 77.8 % | 22.2 % |
| `max_ss_125C_4v50` | 7.491 | 5.816 | 1.664 | 0.0123 | 40.8 | 59.1 | 0.0 | 77.6 % | 22.2 % |
| `max_ff_n40C_5v50` | 11.394 | 8.918 | 2.474 | 0.0023 | 41.8 | 58.2 | 0.0 | 78.3 % | 21.7 % |

## polling: polling de botones, pantalla de inicio

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 11.504 | 7.985 | 3.517 | 0.0019 | 32.2 | 47.5 | 20.2 | 69.4 % | 30.6 % |
| `nom_ss_125C_4v50` | 9.325 | 6.443 | 2.870 | 0.0123 | 31.9 | 48.3 | 19.8 | 69.1 % | 30.8 % |
| `nom_ff_n40C_5v50` | 14.304 | 10.054 | 4.248 | 0.0023 | 32.4 | 47.2 | 20.5 | 70.3 % | 29.7 % |
| `min_tt_025C_5v00` | 11.300 | 7.951 | 3.348 | 0.0019 | 32.0 | 48.2 | 19.7 | 70.4 % | 29.6 % |
| `min_ss_125C_4v50` | 9.169 | 6.423 | 2.734 | 0.0123 | 31.7 | 48.9 | 19.4 | 70.1 % | 29.8 % |
| `min_ff_n40C_5v50` | 14.040 | 9.994 | 4.043 | 0.0023 | 32.2 | 47.9 | 20.0 | 71.2 % | 28.8 % |
| `max_tt_025C_5v00` | 11.750 | 8.028 | 3.720 | 0.0019 | 32.5 | 46.8 | 20.8 | 68.3 % | 31.7 % |
| `max_ss_125C_4v50` | 9.514 | 6.467 | 3.035 | 0.0123 | 32.2 | 47.5 | 20.4 | 68.0 % | 31.9 % |
| `max_ff_n40C_5v50` | 14.622 | 10.126 | 4.494 | 0.0023 | 32.6 | 46.4 | 21.0 | 69.3 % | 30.7 % |

## espera: espera de 3 s de la ronda (wt_wait_loop)

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 12.755 | 8.529 | 4.224 | 0.0019 | 29.1 | 43.2 | 27.7 | 66.9 % | 33.1 % |
| `nom_ss_125C_4v50` | 10.316 | 6.853 | 3.450 | 0.0123 | 28.8 | 43.9 | 27.2 | 66.4 % | 33.4 % |
| `nom_ff_n40C_5v50` | 15.883 | 10.781 | 5.100 | 0.0023 | 29.1 | 42.8 | 28.1 | 67.9 % | 32.1 % |
| `min_tt_025C_5v00` | 12.504 | 8.485 | 4.018 | 0.0019 | 29.0 | 43.9 | 27.2 | 67.9 % | 32.1 % |
| `min_ss_125C_4v50` | 10.123 | 6.828 | 3.283 | 0.0123 | 28.7 | 44.6 | 26.7 | 67.4 % | 32.4 % |
| `min_ff_n40C_5v50` | 15.558 | 10.705 | 4.851 | 0.0023 | 29.0 | 43.5 | 27.5 | 68.8 % | 31.2 % |
| `max_tt_025C_5v00` | 13.058 | 8.584 | 4.472 | 0.0019 | 29.2 | 42.4 | 28.4 | 65.7 % | 34.2 % |
| `max_ss_125C_4v50` | 10.548 | 6.885 | 3.651 | 0.0123 | 29.0 | 43.1 | 27.9 | 65.3 % | 34.6 % |
| `max_ff_n40C_5v50` | 16.275 | 10.872 | 5.401 | 0.0023 | 29.2 | 42.0 | 28.8 | 66.8 % | 33.2 % |

## display: 2000 ciclos alrededor del 01 en el display

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 12.379 | 8.370 | 4.007 | 0.0019 | 30.0 | 44.4 | 25.6 | 67.6 % | 32.4 % |
| `nom_ss_125C_4v50` | 10.017 | 6.733 | 3.272 | 0.0123 | 29.7 | 45.1 | 25.2 | 67.2 % | 32.7 % |
| `nom_ff_n40C_5v50` | 15.411 | 10.570 | 4.839 | 0.0023 | 30.0 | 44.0 | 26.0 | 68.6 % | 31.4 % |
| `min_tt_025C_5v00` | 12.143 | 8.328 | 3.813 | 0.0019 | 29.8 | 45.1 | 25.1 | 68.6 % | 31.4 % |
| `min_ss_125C_4v50` | 9.836 | 6.709 | 3.115 | 0.0123 | 29.5 | 45.8 | 24.6 | 68.2 % | 31.7 % |
| `min_ff_n40C_5v50` | 15.105 | 10.499 | 4.604 | 0.0023 | 29.9 | 44.7 | 25.4 | 69.5 % | 30.5 % |
| `max_tt_025C_5v00` | 12.664 | 8.421 | 4.241 | 0.0019 | 30.1 | 43.6 | 26.3 | 66.5 % | 33.5 % |
| `max_ss_125C_4v50` | 10.236 | 6.762 | 3.462 | 0.0123 | 29.9 | 44.3 | 25.8 | 66.1 % | 33.8 % |
| `max_ff_n40C_5v50` | 15.780 | 10.656 | 5.122 | 0.0023 | 30.2 | 43.2 | 26.6 | 67.5 % | 32.5 % |

## rafaga: solo la rafaga round_begin + show_bcd + wait_tenths

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 12.172 | 8.304 | 3.866 | 0.0019 | 30.5 | 44.9 | 24.6 | 68.2 % | 31.8 % |
| `nom_ss_125C_4v50` | 9.853 | 6.683 | 3.157 | 0.0123 | 30.2 | 45.6 | 24.2 | 67.8 % | 32.0 % |
| `nom_ff_n40C_5v50` | 15.149 | 10.478 | 4.668 | 0.0023 | 30.6 | 44.5 | 25.0 | 69.2 % | 30.8 % |
| `min_tt_025C_5v00` | 11.946 | 8.263 | 3.681 | 0.0019 | 30.3 | 45.6 | 24.1 | 69.2 % | 30.8 % |
| `min_ss_125C_4v50` | 9.679 | 6.660 | 3.007 | 0.0123 | 30.0 | 46.3 | 23.7 | 68.8 % | 31.1 % |
| `min_ff_n40C_5v50` | 14.856 | 10.409 | 4.444 | 0.0023 | 30.4 | 45.2 | 24.4 | 70.1 % | 29.9 % |
| `max_tt_025C_5v00` | 12.444 | 8.353 | 4.089 | 0.0019 | 30.7 | 44.1 | 25.3 | 67.1 % | 32.9 % |
| `max_ss_125C_4v50` | 10.061 | 6.711 | 3.337 | 0.0123 | 30.4 | 44.8 | 24.8 | 66.7 % | 33.2 % |
| `max_ff_n40C_5v50` | 15.502 | 10.562 | 4.938 | 0.0023 | 30.7 | 43.7 | 25.6 | 68.1 % | 31.9 % |

## Desglose por grupo en la esquina tipica nom_tt_025C_5v00 (mW)

| Grupo / componente | defecto | cero | polling | espera | display | rafaga | entrada | entrada05 | cero_duty0 | polling_prof1 |
|---|---|---|---|---|---|---|---|---|---|---|
| Sequential interna | 5.258 | 5.374 | 5.325 | 5.341 | 5.336 | 5.323 | 5.258 | 5.261 | 5.191 | 5.271 |
| Sequential conmutacion | 0.001 | 0.000 | 0.145 | 0.167 | 0.162 | 0.140 | 0.001 | 0.003 | 0.000 | 0.000 |
| Sequential fuga | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| Sequential total | 5.258 | 5.374 | 5.470 | 5.509 | 5.498 | 5.463 | 5.258 | 5.265 | 5.192 | 5.271 |
| Combinational interna | 0.002 | 0.000 | 0.899 | 1.426 | 1.272 | 1.219 | 0.002 | 0.009 | 0.000 | 0.000 |
| Combinational conmutacion | 0.001 | 0.000 | 1.426 | 2.111 | 1.899 | 1.780 | 0.001 | 0.004 | 0.000 | 0.000 |
| Combinational fuga | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 |
| Combinational total | 0.003 | 0.001 | 2.325 | 3.537 | 3.172 | 2.999 | 0.003 | 0.013 | 0.001 | 0.001 |
| Clock interna | 1.762 | 1.762 | 1.762 | 1.762 | 1.762 | 1.762 | 1.762 | 1.762 | 1.762 | 1.762 |
| Clock conmutacion | 1.946 | 1.946 | 1.946 | 1.946 | 1.946 | 1.946 | 1.946 | 1.946 | 1.946 | 1.946 |
| Clock fuga | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 |
| Clock total | 3.709 | 3.709 | 3.709 | 3.709 | 3.709 | 3.709 | 3.709 | 3.709 | 3.709 | 3.709 |
| Total interna | 7.021 | 7.136 | 7.985 | 8.529 | 8.370 | 8.304 | 7.021 | 7.032 | 6.953 | 7.033 |
| Total conmutacion | 1.948 | 1.946 | 3.517 | 4.224 | 4.007 | 3.866 | 1.948 | 1.953 | 1.946 | 1.946 |
| Total fuga | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 |
| Total total | 8.971 | 9.084 | 11.504 | 12.755 | 12.379 | 12.172 | 8.971 | 8.987 | 8.901 | 8.981 |

Columnas extra de calibracion (solo nom_tt): `entrada` = `set_power_activity -input -activity 0.1 -duty 0.5`, `entrada05` = lo mismo con actividad 0.5, `cero_duty0` = `set_power_activity -global -activity 0 -duty 0`, `polling_prof1` = VCD de la ventana polling con `$dumpvars(1, dut)` (solo los puertos del macro).

## Sonda: actividad anotada en pines con nombre, esquina nom_tt_025C_5v00

Transiciones por ciclo de 100 ns (densidad de `get_property <pin> activity` por 100 ns) y, entre parentesis, duty y origen de la actividad segun OpenSTA (`vcd`, `clock`, `input`, `propagated`, `global`, `unknown`). Fuente: lineas `sonda` de cada `.rpt`.

| Pin | Que es | defecto | cero | polling | espera | display | rafaga | entrada | entrada05 | cero_duty0 | polling_prof1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `clk` | reloj (puerto) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) |
| `btn[0]` | boton 0 (puerto) | 0.1000 (0.500, input) | 0.0000 (0.500, global) | 0.0000 (0.975, vcd) | 0.0000 (0.000, vcd) | 0.0000 (0.000, vcd) | 0.0000 (0.000, vcd) | 0.1000 (0.500, input) | 0.5000 (0.500, input) | 0.0000 (0.000, global) | 0.0000 (0.975, vcd) |
| `rst_n` | reset (puerto) | 0.1000 (0.500, input) | 0.0000 (0.500, global) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.1000 (0.500, input) | 0.5000 (0.500, input) | 0.0000 (0.000, global) | 0.0000 (1.000, vcd) |
| `u_soc.u_periph.u_cycles/_164_/Q` | cycles_q[0] | 0.0000 (1.000, propagated) | 0.0000 (0.500, global) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 0.0000 (1.000, propagated) | 0.0000 (1.000, propagated) | 0.0000 (0.000, global) | 0.0000 (1.000, propagated) |
| `u_soc.u_periph.u_cycles/_166_/Q` | cycles_q[2] | 0.0000 (0.000, propagated) | 0.0000 (0.500, global) | 0.2500 (0.500, vcd) | 0.2500 (0.500, vcd) | 0.2500 (0.500, vcd) | 0.2500 (0.503, vcd) | 0.0000 (0.000, propagated) | 0.0000 (0.000, propagated) | 0.0000 (0.000, global) | 0.0000 (0.000, propagated) |
| `_4418_/Q` | pc_id[2] | 0.0000 (1.000, propagated) | 0.0000 (0.500, global) | 0.3333 (0.667, vcd) | 0.5000 (0.625, vcd) | 0.4120 (0.455, vcd) | 0.4500 (0.447, vcd) | 0.0000 (1.000, propagated) | 0.0000 (1.000, propagated) | 0.0000 (0.000, global) | 0.0000 (1.000, propagated) |
| `_4186_/Q` | ROM a_rdata_o[0] | 0.0000 (1.000, propagated) | 0.0000 (0.500, global) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.0000 (1.000, propagated) | 0.0000 (1.000, propagated) | 0.0000 (0.000, global) | 0.0000 (1.000, propagated) |
| `u_soc.u_core.u_rf/_3050_/Q` | regs[9][0] (x9 bit 0) | 0.0000 (0.000, propagated) | 0.0000 (0.500, global) | 0.0000 (0.000, vcd) | 0.0000 (1.000, vcd) | 0.0020 (0.986, vcd) | 0.0088 (0.918, vcd) | 0.0000 (0.000, propagated) | 0.0000 (0.000, propagated) | 0.0000 (0.000, global) | 0.0000 (0.000, propagated) |
| `_4551_/Q` | debounce tick cnt[0] | 0.0000 (1.000, propagated) | 0.0000 (0.500, global) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 0.0000 (1.000, propagated) | 0.0000 (1.000, propagated) | 0.0000 (0.000, global) | 0.0000 (1.000, propagated) |
| `_2617_/ZN` | ALU operand_a[0] | 0.0000 (0.000, propagated) | 0.0000 (0.500, global) | 0.0000 (0.000, vcd) | 0.2500 (0.250, vcd) | 0.2790 (0.280, vcd) | 0.1882 (0.194, vcd) | 0.0000 (0.000, propagated) | 0.0000 (0.000, propagated) | 0.0000 (0.000, global) | 0.0000 (0.000, propagated) |

## Contraste: transiciones contadas en el VCD contra la actividad que anota OpenSTA

Por ventana: transiciones por ciclo contadas directamente en el VCD por `asic/potencia/contar_vcd.py` (`resultados/conteo_<ventana>.txt`) y las que anota OpenSTA en el pin correspondiente (`resultados/<ventana>_nom_tt_025C_5v00.rpt`, lineas `sonda`). Deben coincidir; el reloj lo fija la SDC (origen `clock`, 2 por ciclo), no el VCD.

| Senal del VCD | Pin de OpenSTA | polling: VCD / OpenSTA | espera: VCD / OpenSTA | display: VCD / OpenSTA | rafaga: VCD / OpenSTA |
|---|---|---|---|---|---|
| `clk` | `clk` | 2.0000 / 2.0000 | 2.0000 / 2.0000 | 2.0000 / 2.0000 | 2.0000 / 2.0000 |
| `btn[0]` | `btn[0]` | 0.0001 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 |
| `rst_n` | `rst_n` | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 |
| `u_soc.u_periph.cycles_q[0]` | `u_soc.u_periph.u_cycles/_164_/Q` | 1.0000 / 1.0000 | 1.0000 / 1.0000 | 1.0000 / 1.0000 | 1.0000 / 1.0000 |
| `u_soc.u_periph.cycles_q[2]` | `u_soc.u_periph.u_cycles/_166_/Q` | 0.2500 / 0.2500 | 0.2500 / 0.2500 | 0.2500 / 0.2500 | 0.2500 / 0.2500 |
| `u_soc.u_core.pc_id[2]` | `_4418_/Q` | 0.3333 / 0.3333 | 0.5000 / 0.5000 | 0.4120 / 0.4120 | 0.4500 / 0.4500 |
| `u_soc.g_mem_rom.u_mem.a_rdata_o[0]` | `_4186_/Q` | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 |
| `u_soc.u_core.u_rf/regs[9][0]` | `u_soc.u_core.u_rf/_3050_/Q` | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0020 / 0.0020 | 0.0088 / 0.0088 |
| `u_soc.u_periph.u_debounce.u_tick.cnt[0]` | `_4551_/Q` | 1.0000 / 1.0000 | 1.0000 / 1.0000 | 1.0000 / 1.0000 | 1.0000 / 1.0000 |
| `u_soc.u_core.u_id.operand_a[0]` | `_2617_/ZN` | 0.0000 / 0.0000 | 0.2500 / 0.2500 | 0.2795 / 0.2790 | 0.1912 / 0.1882 |

## Sonda: potencia total de algunas instancias (uW), esquina nom_tt_025C_5v00

`report_power -instances` de `asic/potencia/potencia.tcl`; total (interna + conmutacion + fuga) en microvatios.

| Instancia | Que es | defecto | cero | polling | espera | display | rafaga | entrada | entrada05 | cero_duty0 | polling_prof1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `u_soc.u_periph.u_cycles/_164_` | cycles_q[0] | 5.531 | 6.437 | 14.434 | 14.434 | 14.434 | 14.434 | 5.531 | 5.531 | 5.531 | 5.531 |
| `u_soc.u_periph.u_cycles/_166_` | cycles_q[2] | 5.560 | 6.467 | 7.699 | 7.699 | 7.699 | 7.699 | 5.560 | 5.560 | 5.560 | 5.560 |
| `_4418_` | pc_id[2] | 9.318 | 6.450 | 7.991 | 9.271 | 8.625 | 8.921 | 9.318 | 9.318 | 5.544 | 9.318 |
| `_4186_` | ROM a_rdata_o[0] | 5.198 | 5.179 | 5.198 | 5.198 | 5.198 | 5.198 | 5.198 | 5.198 | 5.161 | 5.198 |
| `u_soc.u_core.u_rf/_3050_` | regs[9][0] (x9 bit 0) | 5.186 | 5.205 | 5.186 | 5.223 | 5.232 | 5.262 | 5.186 | 5.186 | 5.186 | 5.186 |
| `_4551_` | debounce tick cnt[0] | 5.487 | 6.391 | 13.688 | 13.688 | 13.688 | 13.688 | 5.487 | 5.487 | 5.487 | 5.487 |
| `_2617_` | ALU operand_a[0] | 0.000 | 0.000 | 0.000 | 1.160 | 1.295 | 0.874 | 0.000 | 0.000 | 0.000 | 0.000 |

## Sensibilidad a los flip-flops sin reset: estado inicial x (base), 0 y 1 (mW)

La simulacion base deja en x los 804 `dffq_1` sin reset (banco de registros, D4; RAM de datos; registros de la segmentacion) hasta que el programa los escribe; los nodos de los muxes de lectura conmutan a x y OpenSTA no cuenta esas transiciones (`resultados/conteo_x_<ventana>.txt`: lineas de valor 0/1 y x del VCD fuera del volcado inicial). Con `asic/potencia/dffq_func_init.v` los mismos flip-flops arrancan en 0 o en 1 (`resultados/<ventana>_init<0|1>_<esquina>.rpt`); los VCD de esas simulaciones no tienen ninguna linea x (`resultados/conteo_x_<ventana>_init<0|1>.txt`), asi que toda la conmutacion que la base escondia en x queda contada. La columna Lineas 0/1 init 0 / init 1 muestra cuanta conmutacion 0/1 aparece de mas o de menos respecto de la base.

| Ventana | Lineas 0/1 del VCD | Lineas x | x / 0/1 | Senales con x | Lineas 0/1 init 0 | Lineas 0/1 init 1 | Esquina | base (x) | init 0 | init 1 | Comb. base / 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| polling | 18050021 | 1696519 | 9.40 % | 448 | 17123429 | 19536565 | `nom_tt_025C_5v00` | 11.504 | 11.376 (-1.1 %) | 11.711 (+1.8 %) | 2.325 / 2.255 / 2.456 |
| polling | 18050021 | 1696519 | 9.40 % | 448 | 17123429 | 19536565 | `min_ff_n40C_5v50` | 14.040 | 13.893 (-1.0 %) | 14.253 (+1.5 %) | 2.801 / 2.721 / 2.963 |
| polling | 18050021 | 1696519 | 9.40 % | 448 | 17123429 | 19536565 | `max_ss_125C_4v50` | 9.514 | 9.403 (-1.2 %) | 9.687 (+1.8 %) | 1.940 / 1.879 / 2.047 |
| espera | 21151582 | 781250 | 3.69 % | 226 | 21229340 | 22165590 | `nom_tt_025C_5v00` | 12.755 | 12.748 (-0.1 %) | 12.811 (+0.4 %) | 3.537 / 3.530 / 3.585 |
| espera | 21151582 | 781250 | 3.69 % | 226 | 21229340 | 22165590 | `min_ff_n40C_5v50` | 15.558 | 15.551 (-0.0 %) | 15.611 (+0.3 %) | 4.279 / 4.272 / 4.339 |
| espera | 21151582 | 781250 | 3.69 % | 226 | 21229340 | 22165590 | `max_ss_125C_4v50` | 10.548 | 10.540 (-0.1 %) | 10.593 (+0.4 %) | 2.940 / 2.933 / 2.978 |
| display | 2065084 | 152806 | 7.40 % | 1600 | 2004132 | 2203101 | `nom_tt_025C_5v00` | 12.379 | 12.294 (-0.7 %) | 12.495 (+0.9 %) | 3.172 / 3.116 / 3.247 |
| display | 2065084 | 152806 | 7.40 % | 1600 | 2004132 | 2203101 | `min_ff_n40C_5v50` | 15.105 | 15.006 (-0.7 %) | 15.216 (+0.7 %) | 3.836 / 3.771 / 3.925 |
| display | 2065084 | 152806 | 7.40 % | 1600 | 2004132 | 2203101 | `max_ss_125C_4v50` | 10.236 | 10.163 (-0.7 %) | 10.335 (+1.0 %) | 2.638 / 2.590 / 2.700 |
| rafaga | 333506 | 18521 | 5.55 % | 1599 | 323628 | 352847 | `nom_tt_025C_5v00` | 12.172 | 12.108 (-0.5 %) | 12.288 (+1.0 %) | 2.999 / 2.942 / 3.098 |
| rafaga | 333506 | 18521 | 5.55 % | 1599 | 323628 | 352847 | `min_ff_n40C_5v50` | 14.856 | 14.778 (-0.5 %) | 14.980 (+0.8 %) | 3.628 / 3.559 / 3.753 |
| rafaga | 333506 | 18521 | 5.55 % | 1599 | 323628 | 352847 | `max_ss_125C_4v50` | 10.061 | 10.008 (-0.5 %) | 10.155 (+0.9 %) | 2.493 / 2.446 / 2.572 |
