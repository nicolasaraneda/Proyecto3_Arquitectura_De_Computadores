
## exp/pipeline: lectura del banco y decode en el fetch (EarlyRead), barrido de período

asic/rom/config.yaml de la rama (la de main más EarlyRead=1), FP_CORE_UTIL 40 %, corridas por la cola (tags pa_). Cierra a 100, 40, 32 y 26 ns; 25,5, 25 y 24,5 no cierran (setup en max_ss_125C_4v50). Las corridas de 26 a 24,5 ns tienen el mismo layout (9.216 celdas, 195.281 µm², 371.045 µm de cables): el resizer llega a su límite con el margen de 10 ns de D20 y de ahí para abajo el slack baja 1 ns por ns de período. Período mínimo 26 ns (38,5 MHz).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pa_t100 | 100 | 74.535 | 0 | 62.555 | 0 | 0.383 | 0 | 0.957 | 0 | 62.555 | 0 | 0.134 | 0 | sí | 186087 | 0.478 | 418503 | 0 | 0 | 0 | sí | 506 | 32 | 0 |
| pa_t40 | 40 | 20.208 | 0 | 2.555 | 0 | 0.383 | 0 | 0.957 | 0 | 2.555 | 0 | 0.134 | 0 | sí | 186087 | 0.478 | 418503 | 0 | 0 | 0 | sí | 506 | 32 | 0 |
| pa_t32 | 32 | 15.758 | 0 | 1.591 | 0 | 0.384 | 0 | 0.958 | 0 | 1.591 | 0 | 0.134 | 0 | sí | 187744 | 0.482 | 418503 | 0 | 0 | 0 | sí | 463 | 33 | 0 |
| pa_t26 | 26 | 12.158 | 0 | 0.198 | 0 | 0.384 | 0 | 0.959 | 0 | 0.198 | 0 | 0.135 | 0 | sí | 195281 | 0.502 | 418503 | 0 | 0 | 0 | sí | 447 | 33 | 0 |
| pa_t25p5 | 25.500 | 11.658 | 0 | -0.302 | -0.527 | 0.384 | 0 | 0.959 | 0 | -0.302 | -0.527 | 0.135 | 0 | no | 195281 | 0.502 | 418503 | 0 | 0 | 0 | no | 447 | 33 | 0 |
| pa_t25 | 25 | 11.158 | 0 | -0.802 | -8.088 | 0.384 | 0 | 0.959 | 0 | -0.802 | -8.088 | 0.135 | 0 | no | 195281 | 0.502 | 418503 | 0 | 0 | 0 | no | 447 | 33 | 0 |
| pa_t24p5 | 24.500 | 10.658 | 0 | -1.302 | -26.813 | 0.384 | 0 | 0.959 | 0 | -1.302 | -26.813 | 0.135 | 0 | no | 195281 | 0.502 | 418503 | 0 | 0 | 0 | no | 447 | 33 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pa_t100 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pa_t40 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pa_t32 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pa_t26 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pa_t25p5 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pa_t25 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pa_t24p5 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |

## exp/pipeline-b5: exp/pipeline más el banco de registros con latches y clock gating (B5), barrido de período

asic/rom/config.yaml de la rama (la de exp/pipeline, con EarlyRead=1, más LINTER_ERROR_ON_LATCH=false), FP_CORE_UTIL 40 %, corridas por la cola (tags pa_b5_). Cierra a 100, 34, 32, 30 y 29 ns; 26 y 25 no cierran. pa_b5_t28 quedó INCOMPLETA: la cola la detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (paso 37 de 76), así que el primer período que no cierra medido es 26 ns y la regla de 0,5 ns no queda cerrada para esta variante; pa_b5_t28p5 quedó encolada (28,5 ns) para cerrarla por arriba. OJO con esta tabla en dos puntos: (1) el WNS y el TNS de setup son 0,000 exactos en las nueve esquinas cuando la corrida cierra, porque el endpoint de la ruta crítica es el pin D de un latch del banco y OpenSTA cierra la ruta con préstamo de tiempo (time borrowed from endpoint 3,538 ns en pa_b5_t100), de modo que el slack NO mide margen; (2) la columna de flip-flops cuenta las celdas con dff o latch en el nombre y la celda de latch del PDK se llama latq_1, así que informa 514 y no suma los 480 latq_1 del banco (lo mismo hace el área secuencial que informa Yosys).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pa_b5_t100 | 100 | 0 | 0 | 0 | 0 | 0.386 | 0 | 0.973 | 0 | 0 | 0 | 0.134 | 0 | sí | 165211 | 0.504 | 353855 | 0 | 0 | 0 | sí | 386 | 3 | 0 |
| pa_b5_t34 | 34 | 0 | 0 | 0 | 0 | 0.390 | 0 | 0.982 | 0 | 0 | 0 | 0.136 | 0 | sí | 165700 | 0.506 | 353855 | 0 | 0 | 0 | sí | 386 | 3 | 0 |
| pa_b5_t32 | 32 | 0 | 0 | 0 | 0 | 0.392 | 0 | 0.987 | 0 | 0 | 0 | 0.137 | 0 | sí | 167050 | 0.510 | 353855 | 0 | 0 | 0 | sí | 329 | 3 | 0 |
| pa_b5_t30 | 30 | 0 | 0 | 0 | 0 | 0.361 | 0 | 0.924 | 0 | 0 | 0 | 0.119 | 0 | sí | 170589 | 0.521 | 353855 | 0 | 0 | 0 | sí | 300 | 4 | 0 |
| pa_b5_t29 | 29 | 0 | 0 | 0 | 0 | 0.359 | 0 | 0.921 | 0 | 0 | 0 | 0.118 | 0 | sí | 174933 | 0.534 | 353855 | 0 | 0 | 0 | sí | 223 | 5 | 0 |
| pa_b5_t28 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| pa_b5_t26 | 26 | 0 | 0 | -7.102 | -310.392 | 0.397 | 0 | 0.749 | 0 | -7.102 | -310.392 | 0.139 | 0 | no | 171700 | 0.524 | 353855 | 0 | 0 | 0 | no | 403 | 3 | 0 |
| pa_b5_t25 | 25 | 0 | 0 | -8.102 | -374.392 | 0.397 | 0 | 0.549 | 0 | -8.102 | -374.392 | 0.139 | 0 | no | 171700 | 0.524 | 353855 | 0 | 0 | 0 | no | 403 | 3 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pa_b5_t100 | 130930.509 | 34752.211 | 514 | 55628.563 | 10005.722 | 3942.579 |
| pa_b5_t34 | 130930.509 | 34752.211 | 514 | 55628.563 | 10005.722 | 3942.579 |
| pa_b5_t32 | 130930.509 | 34752.211 | 514 | 55628.563 | 10005.722 | 3942.579 |
| pa_b5_t30 | 130930.509 | 34752.211 | 514 | 55628.563 | 10005.722 | 3942.579 |
| pa_b5_t29 | 130930.509 | 34752.211 | 514 | 55628.563 | 10005.722 | 3942.579 |
| pa_b5_t26 | 130930.509 | 34752.211 | 514 | 55628.563 | 10005.722 | 3942.579 |
| pa_b5_t25 | 130930.509 | 34752.211 | 514 | 55628.563 | 10005.722 | 3942.579 |
