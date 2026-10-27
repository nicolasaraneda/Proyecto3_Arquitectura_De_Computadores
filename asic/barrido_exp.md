
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
