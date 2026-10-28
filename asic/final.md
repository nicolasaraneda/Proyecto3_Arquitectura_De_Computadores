
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

e1_g30_t100: asic/rom/config.yaml más DESIGN_REPAIR_MAX_SLEW_PCT=30 y DESIGN_REPAIR_MAX_CAP_PCT=30 (la variante que el frente C midió dentro del 1 % de área sobre el RTL B2+B5, docs/signoff0.md). e1_full_t100: asic/rom/config_rc.yaml de la rama (LAYERS_RC medidos por el frente C, con EarlyRead=1) más RUN_POST_GRT_DESIGN_REPAIR=true, GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30, GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 y CTS_DISTANCE_BETWEEN_BUFFERS=100. Comparar con pa_b2_t100 (571 pines de slew y 37 de capacitancia, 186.432 µm²). e1_g30_t25p5 y e1_g30_t25 son la misma variante g30 al periodo minimo de la base y un paso mas abajo: NO cierran (setup -1,422 y -1,922 ns en max_ss_125C_4v50), asi que la variante de signoff cuesta periodo y el paquete se queda con la configuracion base (docs/candidata.md, seccion 7).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pa_b2_t100 | 100 | 74.531 | 0 | 63.191 | 0 | 0.381 | 0 | 0.953 | 0 | 63.191 | 0 | 0.134 | 0 | sí | 186432 | 0.479 | 419131 | 0 | 0 | 0 | sí | 571 | 37 | 0 |
| e1_g30_t100 | 100 | 74.549 | 0 | 64.850 | 0 | 0.382 | 0 | 0.957 | 0 | 64.850 | 0 | 0.135 | 0 | sí | 188798 | 0.485 | 419131 | 0 | 0 | 0 | sí | 279 | 32 | 0 |
| e1_full_t100 | 100 | 73.837 | 0 | 65.849 | 0 | 0.442 | 0 | 1.065 | 0 | 65.849 | 0 | 0.173 | 0 | sí | 209185 | 0.537 | 419131 | 0 | 0 | 0 | sí | 0 | 0 | 0 |
| e1_g30_t25p5 | 25.500 | 11.103 | 0 | -1.422 | -13.564 | 0.375 | 0 | 0.937 | 0 | -1.422 | -13.564 | 0.128 | 0 | no | 195944 | 0.503 | 419131 | 0 | 0 | 0 | no | 243 | 35 | 0 |
| e1_g30_t25 | 25 | 10.603 | 0 | -1.922 | -33.343 | 0.375 | 0 | 0.937 | 0 | -1.922 | -33.343 | 0.128 | 0 | no | 195944 | 0.503 | 419131 | 0 | 0 | 0 | no | 243 | 35 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pa_b2_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_g30_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_full_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_g30_t25p5 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_g30_t25 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |

## Estrategia 2 (memoria en flip-flops) con el RTL de la candidata

Corridas e2_* con asic/ff/config.yaml de la rama (MemStrategy=2, EarlyRead en su valor por defecto 0 para esa estrategia, igual que en main: ver docs/candidata.md). Referencia de main con la estrategia 2: período mínimo 62 ns (asic/exploraciones.md). Con el RTL de la candidata cierra a 100 y 70 ns y no cierra a 65 ns (WNS -4,198 ns y TNS -271,971 ns en max_ss_125C_4v50); las corridas de 100, 70 y 65 ns dan el mismo layout (40.829 celdas, 843.767 um2, 2.209.619 um de cables), asi que el slack baja 1 ns por cada ns de periodo.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| e2_t100 | 100 | 63.255 | 0 | 30.802 | 0 | 0.429 | 0 | 1.041 | 0 | 30.802 | 0 | 0.164 | 0 | sí | 843767 | 0.486 | 1801610 | 0 | 0 | 0 | sí | 18557 | 209 | 0 |
| e2_t70 | 70 | 33.255 | 0 | 0.802 | 0 | 0.429 | 0 | 1.041 | 0 | 0.802 | 0 | 0.164 | 0 | sí | 843767 | 0.486 | 1801610 | 0 | 0 | 0 | sí | 18557 | 209 | 0 |
| e2_t65 | 65 | 28.255 | 0 | -4.198 | -271.971 | 0.429 | 0 | 1.041 | 0 | -4.198 | -271.971 | 0.164 | 0 | no | 843767 | 0.486 | 1801610 | 0 | 0 | 0 | no | 18557 | 209 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| e2_t100 | 696824.531 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| e2_t70 | 696824.531 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| e2_t65 | 696824.531 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |

## Barrido de FP_CORE_UTIL a 100 ns sobre la candidata

pa_b2_t100 es el 40 %; e1_u50 a e1_u90 cambian solo FP_CORE_UTIL. Las que no tienen métricas finales fallaron: el paso y el mensaje están en asic/rom/resultados/<tag>/falla.txt. Gráfico: docs/figuras/utilizacion.png (asic/graficos.py --util).

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pa_b2_t100 | 100 | 74.531 | 0 | 63.191 | 0 | 0.381 | 0 | 0.953 | 0 | 63.191 | 0 | 0.134 | 0 | sí | 186432 | 0.479 | 419131 | 0 | 0 | 0 | sí | 571 | 37 | 0 |
| e1_u50 | 100 | 74.666 | 0 | 63.492 | 0 | 0.441 | 0 | 1.063 | 0 | 63.492 | 0 | 0.173 | 0 | sí | 183951 | 0.591 | 338033 | 0 | 0 | 0 | sí | 506 | 36 | 0 |
| e1_u60 | 100 | 74.673 | 0 | 65.858 | 0 | 0.445 | 0 | 1.071 | 0 | 65.858 | 0 | 0.175 | 0 | sí | 182055 | 0.700 | 283758 | 0 | 0 | 0 | sí | 486 | 41 | 0 |
| e1_u70 | 100 | 74.666 | 0 | 63.967 | 0 | 0.430 | 0 | 1.042 | 0 | 63.967 | 0 | 0.165 | 0 | sí | 181036 | 0.815 | 244851 | 0 | 0 | 0 | sí | 404 | 34 | 0 |
| e1_u72 | 100 | 74.145 | 0 | 64.914 | 0 | 0.448 | 0 | 1.074 | 0 | 64.914 | 0 | 0.177 | 0 | sí | 180039 | 0.836 | 238352 | 0 | 0 | 0 | sí | 357 | 26 | 0 |
| e1_u75 | 100 | 74.136 | 0 | 62.499 | 0 | 0.376 | 0 | 0.940 | 0 | 62.499 | 0 | 0.128 | 0 | sí | 180303 | 0.869 | 229251 | 0 | 0 | 0 | sí | 478 | 32 | 0 |
| e1_u78 | 100 | 73.945 | 0 | 63.948 | 0 | 0.439 | 0 | 1.067 | 0 | 63.948 | 0 | 0.168 | 0 | sí | 180044 | 0.900 | 220839 | 0 | 0 | 0 | sí | 446 | 33 | 0 |
| e1_u80 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| e1_u90 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pa_b2_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_u50 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_u60 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_u70 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_u72 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_u75 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| e1_u78 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
