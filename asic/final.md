
## Candidata (rama exp/candidata) a 100 ns y 40 %, contra la corrida final de main

pa_b2_t100 es la corrida base de la candidata (asic/rom/config.yaml de la rama: la configuración final de main, D15, D20 y D21, más EarlyRead=1 en SYNTH_PARAMETERS); el RTL es el del frente A (lectura del banco y decode en el fetch) más B2 (offset de byte registrado en la LSU). m_final es la corrida final de main (enlace a asic/rom/runs/final del repo principal) y m_f1_t24p5 su período mínimo. Criterios de cierre: asic/rom/resultados/<tag>/cierre.md.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pa_b2_t100 | 100 | 74.531 | 0 | 63.191 | 0 | 0.381 | 0 | 0.953 | 0 | 63.191 | 0 | 0.134 | 0 | sí | 186432 | 0.479 | 419131 | 0 | 0 | 0 | sí | 571 | 37 | 0 |
| m_final | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pa_b2_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| m_final | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Barrido de CLOCK_PERIOD de la candidata (configuración base)

Corridas pa_b2_* (mismo RTL y configuración, solo cambia CLOCK_PERIOD), medidas por el frente A en build/exp_pipeline_b2 y enlazadas acá. Cierra a 100, 26 y 25,5 ns; 25 ns no cierra (setup en max_ss_125C_4v50, WNS -0,409 ns). Período mínimo 25,5 ns (39,2 MHz) y la brecha con el primero que no cierra es 0,5 ns, lo que cumple la regla de la sesión. Las corridas de 26, 25,5 y 25 ns tienen el mismo layout (9.224 celdas, 194.212 µm², 373.251 µm de cables).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pa_b2_t100 | 100 | 74.531 | 0 | 63.191 | 0 | 0.381 | 0 | 0.953 | 0 | 63.191 | 0 | 0.134 | 0 | sí | 186432 | 0.479 | 419131 | 0 | 0 | 0 | sí | 571 | 37 | 0 |
| pa_b2_t26 | 26 | 12.482 | 0 | 0.591 | 0 | 0.381 | 0 | 0.955 | 0 | 0.591 | 0 | 0.135 | 0 | sí | 194212 | 0.499 | 419131 | 0 | 0 | 0 | sí | 508 | 40 | 0 |
| pa_b2_t25p5 | 25.500 | 11.982 | 0 | 0.091 | 0 | 0.381 | 0 | 0.955 | 0 | 0.091 | 0 | 0.135 | 0 | sí | 194212 | 0.499 | 419131 | 0 | 0 | 0 | sí | 508 | 40 | 0 |
| pa_b2_t25 | 25 | 11.482 | 0 | -0.409 | -1.027 | 0.381 | 0 | 0.955 | 0 | -0.409 | -1.027 | 0.135 | 0 | no | 194212 | 0.499 | 419131 | 0 | 0 | 0 | no | 508 | 40 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pa_b2_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| pa_b2_t26 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| pa_b2_t25p5 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| pa_b2_t25 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |

## Variantes de signoff de slew y capacitancia sobre la candidata a 100 ns

e1_g30_t100: asic/rom/config.yaml más DESIGN_REPAIR_MAX_SLEW_PCT=30 y DESIGN_REPAIR_MAX_CAP_PCT=30 (la variante que el frente C midió dentro del 1 % de área sobre el RTL B2+B5, docs/signoff0.md). e1_full_t100: asic/rom/config_rc.yaml de la rama (LAYERS_RC medidos por el frente C, con EarlyRead=1) más RUN_POST_GRT_DESIGN_REPAIR=true, GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30, GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 y CTS_DISTANCE_BETWEEN_BUFFERS=100. Comparar con pa_b2_t100 (571 pines de slew y 37 de capacitancia, 186.432 µm²).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pa_b2_t100 | 100 | 74.531 | 0 | 63.191 | 0 | 0.381 | 0 | 0.953 | 0 | 63.191 | 0 | 0.134 | 0 | sí | 186432 | 0.479 | 419131 | 0 | 0 | 0 | sí | 571 | 37 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pa_b2_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
