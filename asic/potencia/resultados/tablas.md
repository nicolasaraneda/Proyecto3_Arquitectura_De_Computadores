# Tablas de potencia con actividad real (generadas por asic/potencia/tabla.py)

Fuente de cada numero: `asic/potencia/resultados/<modo o ventana>_<esquina>.rpt`, tabla de `report_power -corner <esquina>` (OpenSTA 2.7.0 de la imagen de LibreLane 3.0.16, `asic/potencia/potencia.tcl`). Potencias en mW; los porcentajes de reloj, secuencial y combinacional son la fila de cada grupo sobre la fila Total del mismo reporte.

## Ventanas simuladas (netlist post-PnR de la corrida final, resultados/ventanas.txt)

| Ventana | Que cubre | Ciclos [ini, fin) | Ciclos | VCD (MB) | Variables del VCD | Codigos distintos | Duracion del VCD (ns) | Tiempo de simulacion |
|---|---|---|---|---|---|---|---|---|
| polling | polling de botones, pantalla de inicio | [500, 20500) | 20000 | 130.4 | 31553 | 8090 | 2000000 | 0m29.819s |
| espera | espera de 3 s de la ronda (wt_wait_loop) | [265000, 285000) | 20000 | 163.4 | 31553 | 8090 | 2000000 | 5m45.614s |
| display | 2000 ciclos alrededor del 01 en el display | [261172, 263172) | 2000 | 18.1 | 31553 | 8090 | 200000 | 4m31.954s |
| rafaga | solo la rafaga round_begin + show_bcd + wait_tenths | [262151, 262491) | 340 | 4.6 | 31553 | 8090 | 34000 | 4m24.856s |
| polling_prof1 | calibracion: polling con $dumpvars(1, dut), solo puertos | [500, 20500) | 20000 | 116.3 | 7026 | 7026 | 2000000 | 0m27.300s |

## Total por modo y esquina (mW) y diferencia contra el modo defecto

| Esquina | defecto | cero | polling | espera | display | rafaga | pines anotados (VCD) |
|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 9.620 | 9.734 (+1.2 %) | 13.936 (+44.9 %) | 16.615 (+72.7 %) | 15.906 (+65.3 %) | 15.912 (+65.4 %) | 23591 |
| `nom_ss_125C_4v50` | 7.826 | 7.920 (+1.2 %) | 11.261 (+43.9 %) | 13.389 (+71.1 %) | 12.825 (+63.9 %) | 12.833 (+64.0 %) | 23591 |
| `nom_ff_n40C_5v50` | 11.943 | 12.058 (+1.0 %) | 17.364 (+45.4 %) | 20.736 (+73.6 %) | 19.845 (+66.2 %) | 19.845 (+66.2 %) | 23591 |
| `min_tt_025C_5v00` | 9.520 | 9.635 (+1.2 %) | 13.672 (+43.6 %) | 16.265 (+70.8 %) | 15.577 (+63.6 %) | 15.587 (+63.7 %) | 23591 |
| `min_ss_125C_4v50` | 7.749 | 7.843 (+1.2 %) | 11.056 (+42.7 %) | 13.117 (+69.3 %) | 12.570 (+62.2 %) | 12.581 (+62.4 %) | 23591 |
| `min_ff_n40C_5v50` | 11.814 | 11.930 (+1.0 %) | 17.025 (+44.1 %) | 20.287 (+71.7 %) | 19.423 (+64.4 %) | 19.429 (+64.5 %) | 23591 |
| `max_tt_025C_5v00` | 9.741 | 9.855 (+1.2 %) | 14.255 (+46.3 %) | 17.039 (+74.9 %) | 16.303 (+67.4 %) | 16.305 (+67.4 %) | 23591 |
| `max_ss_125C_4v50` | 7.919 | 8.013 (+1.2 %) | 11.508 (+45.3 %) | 13.717 (+73.2 %) | 13.133 (+65.8 %) | 13.137 (+65.9 %) | 23591 |
| `max_ff_n40C_5v50` | 12.100 | 12.215 (+1.0 %) | 17.773 (+46.9 %) | 21.279 (+75.9 %) | 20.354 (+68.2 %) | 20.348 (+68.2 %) | 23591 |

## defecto: sin actividad (lo que hizo el flujo)

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 9.620 | 7.555 | 2.062 | 0.0021 | 47.7 | 52.2 | 0.0 | 78.5 % | 21.4 % |
| `nom_ss_125C_4v50` | 7.826 | 6.134 | 1.679 | 0.0131 | 46.7 | 53.2 | 0.1 | 78.4 % | 21.5 % |
| `nom_ff_n40C_5v50` | 11.943 | 9.444 | 2.496 | 0.0025 | 48.5 | 51.5 | 0.0 | 79.1 % | 20.9 % |
| `min_tt_025C_5v00` | 9.520 | 7.541 | 1.978 | 0.0021 | 47.3 | 52.7 | 0.0 | 79.2 % | 20.8 % |
| `min_ss_125C_4v50` | 7.749 | 6.126 | 1.610 | 0.0131 | 46.2 | 53.7 | 0.1 | 79.1 % | 20.8 % |
| `min_ff_n40C_5v50` | 11.814 | 9.418 | 2.394 | 0.0025 | 48.0 | 51.9 | 0.0 | 79.7 % | 20.3 % |
| `max_tt_025C_5v00` | 9.741 | 7.574 | 2.165 | 0.0021 | 48.3 | 51.7 | 0.0 | 77.8 % | 22.2 % |
| `max_ss_125C_4v50` | 7.919 | 6.145 | 1.762 | 0.0131 | 47.3 | 52.6 | 0.1 | 77.6 % | 22.2 % |
| `max_ff_n40C_5v50` | 12.100 | 9.477 | 2.620 | 0.0025 | 49.0 | 50.9 | 0.0 | 78.3 % | 21.7 % |

## cero: actividad global 0 (solo el reloj)

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 9.734 | 7.671 | 2.061 | 0.0021 | 47.2 | 52.8 | 0.0 | 78.8 % | 21.2 % |
| `nom_ss_125C_4v50` | 7.920 | 6.229 | 1.677 | 0.0131 | 46.2 | 53.8 | 0.0 | 78.7 % | 21.2 % |
| `nom_ff_n40C_5v50` | 12.058 | 9.562 | 2.494 | 0.0025 | 48.0 | 52.0 | 0.0 | 79.3 % | 20.7 % |
| `min_tt_025C_5v00` | 9.635 | 7.657 | 1.976 | 0.0021 | 46.7 | 53.3 | 0.0 | 79.5 % | 20.5 % |
| `min_ss_125C_4v50` | 7.843 | 6.221 | 1.609 | 0.0131 | 45.7 | 54.3 | 0.0 | 79.3 % | 20.5 % |
| `min_ff_n40C_5v50` | 11.930 | 9.535 | 2.392 | 0.0025 | 47.6 | 52.4 | 0.0 | 79.9 % | 20.1 % |
| `max_tt_025C_5v00` | 9.855 | 7.690 | 2.163 | 0.0021 | 47.7 | 52.2 | 0.0 | 78.0 % | 21.9 % |
| `max_ss_125C_4v50` | 8.013 | 6.240 | 1.760 | 0.0131 | 46.7 | 53.2 | 0.0 | 77.9 % | 22.0 % |
| `max_ff_n40C_5v50` | 12.215 | 9.595 | 2.618 | 0.0025 | 48.6 | 51.4 | 0.0 | 78.5 % | 21.4 % |

## polling: polling de botones, pantalla de inicio

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 13.936 | 9.379 | 4.554 | 0.0021 | 33.0 | 37.7 | 29.4 | 67.3 % | 32.7 % |
| `nom_ss_125C_4v50` | 11.261 | 7.528 | 3.720 | 0.0131 | 32.5 | 38.6 | 28.9 | 66.9 % | 33.0 % |
| `nom_ff_n40C_5v50` | 17.364 | 11.862 | 5.499 | 0.0025 | 33.4 | 37.0 | 29.6 | 68.3 % | 31.7 % |
| `min_tt_025C_5v00` | 13.672 | 9.340 | 4.330 | 0.0021 | 32.9 | 38.3 | 28.8 | 68.3 % | 31.7 % |
| `min_ss_125C_4v50` | 11.056 | 7.505 | 3.538 | 0.0131 | 32.4 | 39.3 | 28.3 | 67.9 % | 32.0 % |
| `min_ff_n40C_5v50` | 17.025 | 11.795 | 5.228 | 0.0025 | 33.3 | 37.6 | 29.0 | 69.3 % | 30.7 % |
| `max_tt_025C_5v00` | 14.255 | 9.429 | 4.824 | 0.0021 | 33.0 | 37.0 | 30.0 | 66.1 % | 33.8 % |
| `max_ss_125C_4v50` | 11.508 | 7.557 | 3.938 | 0.0131 | 32.5 | 37.9 | 29.6 | 65.7 % | 34.2 % |
| `max_ff_n40C_5v50` | 17.773 | 11.945 | 5.825 | 0.0025 | 33.4 | 36.3 | 30.3 | 67.2 % | 32.8 % |

## espera: espera de 3 s de la ronda (wt_wait_loop)

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 16.615 | 10.644 | 5.969 | 0.0021 | 27.6 | 32.0 | 40.4 | 64.1 % | 35.9 % |
| `nom_ss_125C_4v50` | 13.389 | 8.496 | 4.880 | 0.0131 | 27.3 | 32.8 | 39.9 | 63.5 % | 36.4 % |
| `nom_ff_n40C_5v50` | 20.736 | 13.532 | 7.201 | 0.0025 | 27.9 | 31.3 | 40.8 | 65.3 % | 34.7 % |
| `min_tt_025C_5v00` | 16.265 | 10.591 | 5.672 | 0.0021 | 27.7 | 32.6 | 39.8 | 65.1 % | 34.9 % |
| `min_ss_125C_4v50` | 13.117 | 8.465 | 4.639 | 0.0131 | 27.3 | 33.4 | 39.2 | 64.5 % | 35.4 % |
| `min_ff_n40C_5v50` | 20.287 | 13.442 | 6.842 | 0.0025 | 28.0 | 31.9 | 40.1 | 66.3 % | 33.7 % |
| `max_tt_025C_5v00` | 17.039 | 10.711 | 6.326 | 0.0021 | 27.6 | 31.3 | 41.1 | 62.9 % | 37.1 % |
| `max_ss_125C_4v50` | 13.717 | 8.535 | 5.169 | 0.0131 | 27.3 | 32.1 | 40.6 | 62.2 % | 37.7 % |
| `max_ff_n40C_5v50` | 21.279 | 13.643 | 7.633 | 0.0025 | 27.9 | 30.6 | 41.5 | 64.1 % | 35.9 % |

## display: 2000 ciclos alrededor del 01 en el display

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 15.906 | 10.303 | 5.601 | 0.0021 | 28.9 | 33.2 | 37.9 | 64.8 % | 35.2 % |
| `nom_ss_125C_4v50` | 12.825 | 8.234 | 4.578 | 0.0131 | 28.5 | 34.1 | 37.4 | 64.2 % | 35.7 % |
| `nom_ff_n40C_5v50` | 19.845 | 13.084 | 6.758 | 0.0025 | 29.2 | 32.6 | 38.2 | 65.9 % | 34.1 % |
| `min_tt_025C_5v00` | 15.577 | 10.252 | 5.323 | 0.0021 | 28.9 | 33.8 | 37.3 | 65.8 % | 34.2 % |
| `min_ss_125C_4v50` | 12.570 | 8.205 | 4.352 | 0.0131 | 28.5 | 34.7 | 36.8 | 65.3 % | 34.6 % |
| `min_ff_n40C_5v50` | 19.423 | 12.999 | 6.422 | 0.0025 | 29.2 | 33.2 | 37.6 | 66.9 % | 33.1 % |
| `max_tt_025C_5v00` | 16.303 | 10.366 | 5.935 | 0.0021 | 28.9 | 32.5 | 38.6 | 63.6 % | 36.4 % |
| `max_ss_125C_4v50` | 13.133 | 8.271 | 4.849 | 0.0131 | 28.5 | 33.4 | 38.1 | 63.0 % | 36.9 % |
| `max_ff_n40C_5v50` | 20.354 | 13.188 | 7.163 | 0.0025 | 29.2 | 31.9 | 39.0 | 64.8 % | 35.2 % |

## rafaga: solo la rafaga round_begin + show_bcd + wait_tenths

| Esquina | Total | Interna | Conmutacion | Fuga | % reloj | % secuencial | % combinacional | Interna/Total | Conmutacion/Total |
|---|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 15.912 | 10.340 | 5.569 | 0.0021 | 28.9 | 33.2 | 37.9 | 65.0 % | 35.0 % |
| `nom_ss_125C_4v50` | 12.833 | 8.268 | 4.552 | 0.0131 | 28.5 | 34.1 | 37.4 | 64.4 % | 35.5 % |
| `nom_ff_n40C_5v50` | 19.845 | 13.122 | 6.721 | 0.0025 | 29.2 | 32.6 | 38.2 | 66.1 % | 33.9 % |
| `min_tt_025C_5v00` | 15.587 | 10.291 | 5.294 | 0.0021 | 28.9 | 33.8 | 37.3 | 66.0 % | 34.0 % |
| `min_ss_125C_4v50` | 12.581 | 8.239 | 4.329 | 0.0131 | 28.5 | 34.7 | 36.8 | 65.5 % | 34.4 % |
| `min_ff_n40C_5v50` | 19.429 | 13.039 | 6.387 | 0.0025 | 29.2 | 33.2 | 37.6 | 67.1 % | 32.9 % |
| `max_tt_025C_5v00` | 16.305 | 10.401 | 5.901 | 0.0021 | 28.9 | 32.5 | 38.6 | 63.8 % | 36.2 % |
| `max_ss_125C_4v50` | 13.137 | 8.303 | 4.821 | 0.0131 | 28.5 | 33.4 | 38.1 | 63.2 % | 36.7 % |
| `max_ff_n40C_5v50` | 20.348 | 13.224 | 7.122 | 0.0025 | 29.2 | 31.9 | 38.9 | 65.0 % | 35.0 % |

## Desglose por grupo en la esquina tipica nom_tt_025C_5v00 (mW)

| Grupo / componente | defecto | cero | polling | espera | display | rafaga | entrada | entrada05 | cero_duty0 | polling_prof1 |
|---|---|---|---|---|---|---|---|---|---|---|
| Sequential interna | 5.023 | 5.140 | 5.119 | 5.151 | 5.140 | 5.140 | 5.023 | 5.026 | 4.960 | 5.036 |
| Sequential conmutacion | 0.001 | 0.000 | 0.134 | 0.158 | 0.146 | 0.149 | 0.001 | 0.004 | 0.000 | 0.000 |
| Sequential fuga | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| Sequential total | 5.024 | 5.141 | 5.253 | 5.310 | 5.286 | 5.290 | 5.024 | 5.031 | 4.961 | 5.036 |
| Combinational interna | 0.002 | 0.000 | 1.729 | 2.962 | 2.632 | 2.669 | 0.002 | 0.009 | 0.000 | 0.000 |
| Combinational conmutacion | 0.001 | 0.000 | 2.360 | 3.750 | 3.395 | 3.360 | 0.001 | 0.005 | 0.000 | 0.000 |
| Combinational fuga | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 |
| Combinational total | 0.004 | 0.001 | 4.091 | 6.713 | 6.028 | 6.030 | 0.004 | 0.014 | 0.001 | 0.001 |
| Clock interna | 2.531 | 2.531 | 2.531 | 2.531 | 2.531 | 2.531 | 2.531 | 2.531 | 2.531 | 2.531 |
| Clock conmutacion | 2.061 | 2.061 | 2.061 | 2.061 | 2.061 | 2.061 | 2.061 | 2.061 | 2.061 | 2.061 |
| Clock fuga | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 | 0.001 |
| Clock total | 4.592 | 4.592 | 4.592 | 4.592 | 4.592 | 4.592 | 4.592 | 4.592 | 4.592 | 4.592 |
| Total interna | 7.555 | 7.671 | 9.379 | 10.644 | 10.303 | 10.340 | 7.555 | 7.566 | 7.491 | 7.567 |
| Total conmutacion | 2.062 | 2.061 | 4.554 | 5.969 | 5.601 | 5.569 | 2.062 | 2.069 | 2.061 | 2.061 |
| Total fuga | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 | 0.002 |
| Total total | 9.620 | 9.734 | 13.936 | 16.615 | 15.906 | 15.912 | 9.620 | 9.638 | 9.554 | 9.629 |

Columnas extra de calibracion (solo nom_tt): `entrada` = `set_power_activity -input -activity 0.1 -duty 0.5`, `entrada05` = lo mismo con actividad 0.5, `cero_duty0` = `set_power_activity -global -activity 0 -duty 0`, `polling_prof1` = VCD de la ventana polling con `$dumpvars(1, dut)` (solo los puertos del macro).

## Sonda: actividad anotada en pines con nombre, esquina nom_tt_025C_5v00

Transiciones por ciclo de 100 ns (densidad de `get_property <pin> activity` por 100 ns) y, entre parentesis, duty y origen de la actividad segun OpenSTA (`vcd`, `clock`, `input`, `propagated`, `global`, `unknown`). Fuente: lineas `sonda` de cada `.rpt`.

| Pin | Que es | defecto | cero | polling | espera | display | rafaga | entrada | entrada05 | cero_duty0 | polling_prof1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `clk` | reloj (puerto) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) | 2.0000 (0.500, clock) |
| `btn[0]` | boton 0 (puerto) | 0.1000 (0.500, input) | 0.0000 (0.500, global) | 0.0000 (0.975, vcd) | 0.0000 (0.000, vcd) | 0.0000 (0.000, vcd) | 0.0000 (0.000, vcd) | 0.1000 (0.500, input) | 0.5000 (0.500, input) | 0.0000 (0.000, global) | 0.0000 (0.975, vcd) |
| `rst_n` | reset (puerto) | 0.1000 (0.500, input) | 0.0000 (0.500, global) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.0000 (1.000, vcd) | 0.1000 (0.500, input) | 0.5000 (0.500, input) | 0.0000 (0.000, global) | 0.0000 (1.000, vcd) |
| `u_soc.u_periph.u_cycles/_164_/Q` | cycles_q[0] | 0.0000 (1.000, propagated) | 0.0000 (0.500, global) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 1.0000 (0.500, vcd) | 0.0000 (1.000, propagated) | 0.0000 (1.000, propagated) | 0.0000 (0.000, global) | 0.0000 (1.000, propagated) |
| `u_soc.u_periph.u_cycles/_166_/Q` | cycles_q[2] | 0.0000 (0.000, propagated) | 0.0000 (0.500, global) | 0.2500 (0.500, vcd) | 0.2500 (0.500, vcd) | 0.2500 (0.500, vcd) | 0.2500 (0.500, vcd) | 0.0000 (0.000, propagated) | 0.0000 (0.000, propagated) | 0.0000 (0.000, global) | 0.0000 (0.000, propagated) |
| `_4418_/Q` | pc_id[2] | 0.0000 (0.000, propagated) | 0.0000 (0.500, global) | 0.0000 (0.000, vcd) | 0.0000 (1.000, vcd) | 0.0005 (0.419, vcd) | 0.0029 (0.462, vcd) | 0.0000 (0.000, propagated) | 0.0000 (0.000, propagated) | 0.0000 (0.000, global) | 0.0000 (0.000, propagated) |
| `_4186_/Q` | ROM a_rdata_o[0] | 0.0000 (0.000, propagated) | 0.0000 (0.500, global) | 0.0000 (0.000, vcd) | 0.0000 (0.000, vcd) | 0.0000 (0.000, vcd) | 0.0000 (0.000, vcd) | 0.0000 (0.000, propagated) | 0.0000 (0.000, propagated) | 0.0000 (0.000, global) | 0.0000 (0.000, propagated) |
| `u_soc.u_core.u_rf/_3050_/Q` | regs[9][0] (x9 bit 0) | - | - | - | - | - | - | - | - | - | - |
| `_4551_/Q` | debounce tick cnt[0] | - | - | - | - | - | - | - | - | - | - |
| `_2617_/ZN` | ALU operand_a[0] | 0.0000 (1.000, propagated) | 0.0000 (0.500, global) | 0.0000 (1.000, vcd) | 0.0312 (0.500, vcd) | 0.0140 (0.789, vcd) | 0.0176 (0.788, vcd) | 0.0000 (1.000, propagated) | 0.0000 (1.000, propagated) | 0.0000 (0.000, global) | 0.0000 (1.000, propagated) |

## Contraste: transiciones contadas en el VCD contra la actividad que anota OpenSTA

Por ventana: transiciones por ciclo contadas directamente en el VCD por `asic/potencia/contar_vcd.py` (`resultados/conteo_<ventana>.txt`) y las que anota OpenSTA en el pin correspondiente (`resultados/<ventana>_nom_tt_025C_5v00.rpt`, lineas `sonda`). Deben coincidir; el reloj lo fija la SDC (origen `clock`, 2 por ciclo), no el VCD.

| Senal del VCD | Pin de OpenSTA | polling: VCD / OpenSTA | espera: VCD / OpenSTA | display: VCD / OpenSTA | rafaga: VCD / OpenSTA |
|---|---|---|---|---|---|
| `clk` | `clk` | 2.0000 / 2.0000 | 2.0000 / 2.0000 | 2.0000 / 2.0000 | 2.0000 / 2.0000 |
| `btn[0]` | `btn[0]` | 0.0001 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 |
| `rst_n` | `rst_n` | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0000 / 0.0000 |
| `u_soc.u_periph.cycles_q[0]` | `u_soc.u_periph.u_cycles/_164_/Q` | 1.0000 / 1.0000 | 1.0000 / 1.0000 | 1.0000 / 1.0000 | 1.0000 / 1.0000 |
| `u_soc.u_periph.cycles_q[2]` | `u_soc.u_periph.u_cycles/_166_/Q` | 0.2500 / 0.2500 | 0.2500 / 0.2500 | 0.2500 / 0.2500 | 0.2500 / 0.2500 |
| `u_soc.u_core.pc_id[2]` | `_4418_/Q` | 0.5000 / 0.0000 | 0.8000 / 0.0000 | 0.6545 / 0.0005 | 0.8029 / 0.0029 |
| `u_soc.g_mem_rom.u_mem.a_rdata_o[0]` | `_4186_/Q` | - / 0.0000 | - / 0.0000 | - / 0.0000 | - / 0.0000 |
| `u_soc.u_core.u_rf/regs[9][0]` | `u_soc.u_core.u_rf/_3050_/Q` | 0.0000 / - | 0.0000 / - | 0.0025 / - | 0.0088 / - |
| `u_soc.u_periph.u_debounce.u_tick.cnt[0]` | `_4551_/Q` | 1.0000 / - | 1.0000 / - | 1.0000 / - | 1.0000 / - |
| `u_soc.u_core.u_id.operand_a[0]` | `_2617_/ZN` | 0.0000 / 0.0000 | 0.2000 / 0.0312 | 0.3595 / 0.0140 | 0.2794 / 0.0176 |

## Sonda: potencia total de algunas instancias (uW), esquina nom_tt_025C_5v00

`report_power -instances` de `asic/potencia/potencia.tcl`; total (interna + conmutacion + fuga) en microvatios.

| Instancia | Que es | defecto | cero | polling | espera | display | rafaga | entrada | entrada05 | cero_duty0 | polling_prof1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `u_soc.u_periph.u_cycles/_164_` | cycles_q[0] | 5.449 | 6.352 | 14.052 | 14.052 | 14.052 | 14.052 | 5.449 | 5.449 | 5.449 | 5.449 |
| `u_soc.u_periph.u_cycles/_166_` | cycles_q[2] | 5.449 | 6.352 | 7.453 | 7.453 | 7.453 | 7.453 | 5.449 | 5.449 | 5.449 | 5.449 |
| `_4418_` | pc_id[2] | 5.447 | 6.350 | 5.448 | 5.297 | 5.388 | 5.398 | 5.447 | 5.447 | 5.447 | 5.447 |
| `_4186_` | ROM a_rdata_o[0] | 5.100 | 5.118 | 5.100 | 5.100 | 5.100 | 5.100 | 5.100 | 5.100 | 5.100 | 5.100 |
| `u_soc.u_core.u_rf/_3050_` | regs[9][0] (x9 bit 0) | 0.000 | 0.000 | 0.000 | 3.062 | 2.160 | 2.891 | 0.000 | 0.000 | 0.000 | 0.000 |
| `_4551_` | debounce tick cnt[0] | - | - | - | - | - | - | - | - | - | - |
| `_2617_` | ALU operand_a[0] | 0.000 | 0.000 | 0.000 | 0.109 | 0.049 | 0.062 | 0.000 | 0.000 | 0.000 | 0.000 |

## Sensibilidad a los flip-flops sin reset: estado inicial x (base), 0 y 1 (mW)

La simulacion base deja en x los 804 `dffq_1` sin reset (banco de registros, D4; RAM de datos; registros de la segmentacion) hasta que el programa los escribe; los nodos de los muxes de lectura conmutan a x y OpenSTA no cuenta esas transiciones (`resultados/conteo_x_<ventana>.txt`: lineas de valor 0/1 y x del VCD fuera del volcado inicial). Con `asic/potencia/dffq_func_init.v` los mismos flip-flops arrancan en 0 o en 1 (`resultados/<ventana>_init<0|1>_<esquina>.rpt`); los VCD de esas simulaciones no tienen ninguna linea x (`resultados/conteo_x_<ventana>_init<0|1>.txt`), asi que toda la conmutacion que la base escondia en x queda contada. La columna Lineas 0/1 init 0 / init 1 muestra cuanta conmutacion 0/1 aparece de mas o de menos respecto de la base.

| Ventana | Lineas 0/1 del VCD | Lineas x | x / 0/1 | Senales con x | Lineas 0/1 init 0 | Lineas 0/1 init 1 | Esquina | base (x) | init 0 | init 1 | Comb. base / 0 / 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| polling | 18050021 | 1696519 | 9.40 % | 448 | 17123429 | 19536565 | `nom_tt_025C_5v00` | 13.936 | 11.376 (-18.4 %) | 11.711 (-16.0 %) | 4.091 / 2.255 / 2.456 |
| polling | 18050021 | 1696519 | 9.40 % | 448 | 17123429 | 19536565 | `min_ff_n40C_5v50` | 17.025 | 13.893 (-18.4 %) | 14.253 (-16.3 %) | 4.944 / 2.721 / 2.963 |
| polling | 18050021 | 1696519 | 9.40 % | 448 | 17123429 | 19536565 | `max_ss_125C_4v50` | 11.508 | 9.403 (-18.3 %) | 9.687 (-15.8 %) | 3.403 / 1.879 / 2.047 |
| espera | 21151582 | 781250 | 3.69 % | 226 | 21229340 | 22165590 | `nom_tt_025C_5v00` | 16.615 | 12.748 (-23.3 %) | 12.811 (-22.9 %) | 6.713 / 3.530 / 3.585 |
| espera | 21151582 | 781250 | 3.69 % | 226 | 21229340 | 22165590 | `min_ff_n40C_5v50` | 20.287 | 15.551 (-23.3 %) | 15.611 (-23.0 %) | 8.141 / 4.272 / 4.339 |
| espera | 21151582 | 781250 | 3.69 % | 226 | 21229340 | 22165590 | `max_ss_125C_4v50` | 13.717 | 10.540 (-23.2 %) | 10.593 (-22.8 %) | 5.564 / 2.933 / 2.978 |
| display | 2065084 | 152806 | 7.40 % | 1600 | 2004132 | 2203101 | `nom_tt_025C_5v00` | 15.906 | 12.294 (-22.7 %) | 12.495 (-21.4 %) | 6.028 / 3.116 / 3.247 |
| display | 2065084 | 152806 | 7.40 % | 1600 | 2004132 | 2203101 | `min_ff_n40C_5v50` | 19.423 | 15.006 (-22.7 %) | 15.216 (-21.7 %) | 7.304 / 3.771 / 3.925 |
| display | 2065084 | 152806 | 7.40 % | 1600 | 2004132 | 2203101 | `max_ss_125C_4v50` | 13.133 | 10.163 (-22.6 %) | 10.335 (-21.3 %) | 5.001 / 2.590 / 2.700 |
| rafaga | 333506 | 18521 | 5.55 % | 1599 | 323628 | 352847 | `nom_tt_025C_5v00` | 15.912 | 12.108 (-23.9 %) | 12.288 (-22.8 %) | 6.030 / 2.942 / 3.098 |
| rafaga | 333506 | 18521 | 5.55 % | 1599 | 323628 | 352847 | `min_ff_n40C_5v50` | 19.429 | 14.778 (-23.9 %) | 14.980 (-22.9 %) | 7.306 / 3.559 / 3.753 |
| rafaga | 333506 | 18521 | 5.55 % | 1599 | 323628 | 352847 | `max_ss_125C_4v50` | 13.137 | 10.008 (-23.8 %) | 10.155 (-22.7 %) | 5.001 / 2.446 / 2.572 |
