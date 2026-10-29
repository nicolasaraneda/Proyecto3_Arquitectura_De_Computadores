
## Corrida final (tag final): T = 100 ns, FP_CORE_UTIL = 40 %

Configuración: asic/rom/config.yaml (D15, D20, D21 y D23: EarlyRead = 1, LAYERS_RC con los RC de cable medidos y la reparación después del ruteo global). Criterios de cierre: asic/rom/resultados/final/cierre.md; avisos revisados uno por uno en avisos.md. La corrida final de v1 (antes de integrar exp/candidata-rc) está en asic/rom/resultados/v1_final/ y bajo el tag v1-final. Las tablas de este archivo las genera asic/tablas.sh con asic/recolectar.py.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.404 | 0 | 65.725 | 0 | 0.442 | 0 | 1.065 | 0 | 65.725 | 0 | 0.173 | 0 | sí | 208439 | 0.535 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |

## Barrido de CLOCK_PERIOD con la configuración final (sección 3.4)

Corridas f2_* (mismo RTL y configuración que la final, solo cambia CLOCK_PERIOD); el punto de 100 ns es la corrida final. Período mínimo 21,5 ns (46,5 MHz): f2_t21p5 cierra con WNS de setup 0,876 ns y TNS 0 en max_ss_125C_4v50, y f2_t21 no cierra por 0,129 ns (TNS -0,291 ns), con lo que la regla de la sesión de dejar 0,5 ns o menos entre el último período que cierra y el primero que no queda cerrada. A diferencia de lo que pasaba en v1, acá cada período da su propio layout: con los parásitos de cable medidos el resizer sigue encontrando qué reparar, así que el área de celdas sube de 208.439 µm² a 100 ns a 231.229 µm² a 21,5 ns y el WNS deja de bajar 1 ns por cada ns de período (4,924 a 30 ns, 1,579 a 25, 1,755 a 24, 1,494 a 23, 0,656 a 22 y 0,876 a 21,5). Las violaciones de max slew son 0 a 100, 25, 22 y 21,5 ns, 4 a 30, 24 y 23 ns y 6 a 21 ns; la de max capacitancia es siempre 1 y es siempre el mismo pin, la raíz del árbol de reloj (asic/rom/resultados/final/avisos.md, aviso 4). Gráfico: docs/figuras/periodo.png (asic/graficos.py --periodo). Las rutas críticas por tramos están en asic/rutas.md.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.404 | 0 | 65.725 | 0 | 0.442 | 0 | 1.065 | 0 | 65.725 | 0 | 0.173 | 0 | sí | 208439 | 0.535 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| f2_t30 | 30 | 16.460 | 0 | 4.924 | 0 | 0.442 | 0 | 1.065 | 0 | 4.924 | 0 | 0.173 | 0 | sí | 219059 | 0.562 | 419131 | 0 | 0 | 0 | sí | 4 | 1 | 0 |
| f2_t25 | 25 | 12.306 | 0 | 1.579 | 0 | 0.442 | 0 | 1.065 | 0 | 1.579 | 0 | 0.173 | 0 | sí | 219531 | 0.564 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| f2_t24 | 24 | 11.931 | 0 | 1.755 | 0 | 0.442 | 0 | 1.065 | 0 | 1.755 | 0 | 0.173 | 0 | sí | 220655 | 0.566 | 419131 | 0 | 0 | 0 | sí | 4 | 1 | 0 |
| f2_t23 | 23 | 11.272 | 0 | 1.494 | 0 | 0.442 | 0 | 1.065 | 0 | 1.494 | 0 | 0.173 | 0 | sí | 222714 | 0.572 | 419131 | 0 | 0 | 0 | sí | 4 | 1 | 0 |
| f2_t22 | 22 | 10.358 | 0 | 0.656 | 0 | 0.442 | 0 | 1.065 | 0 | 0.656 | 0 | 0.173 | 0 | sí | 224767 | 0.577 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| f2_t21p5 | 21.500 | 10.257 | 0 | 0.876 | 0 | 0.442 | 0 | 1.065 | 0 | 0.876 | 0 | 0.173 | 0 | sí | 231229 | 0.594 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| f2_t21 | 21 | 9.614 | 0 | -0.129 | -0.291 | 0.442 | 0 | 1.065 | 0 | -0.129 | -0.291 | 0.173 | 0 | no | 231638 | 0.595 | 419131 | 0 | 0 | 0 | no | 6 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| f2_t30 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| f2_t25 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| f2_t24 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| f2_t23 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| f2_t22 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| f2_t21p5 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| f2_t21 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |

## Barrido de FP_CORE_UTIL a 100 ns con la configuración final (sección 3.5)

Corridas final (40 %) y u2_*. La columna utilización es la real que mide el flujo (design__instance__utilization), no la pedida: con el modelo de cable el resizer agrega celdas, así que la real queda bastante por encima de la pedida. El valor que el informe reporta como utilización máxima que cierra es el de FP_CORE_UTIL pedido en la corrida de menor die que cierra todo; las que fallan no tienen métricas finales (la tabla las marca incompleta porque no hay final/metrics.json, pero ninguna se cortó por tiempo: las cinco fallaron por el diseño) y su extracto está en asic/rom/resultados/<tag>/falla.txt. Utilización máxima que cierra: 73 % (die 235.237 µm², 0,235 mm²), y 74 % es la primera que falla, así que la resolución queda en 1 punto. Dónde falla cada una: 74 y 75 % en OpenROAD.RepairDesignPostGRT (paso 41, el que agrega D23) con 18 y 77 instancias sin lugar; 78 % en OpenROAD.CTS (paso 35) con 36; 80 % en OpenROAD.RepairDesignPostGPL (paso 32) con 5; y 90 % en el placement global con [GPL-0301] Utilization 100.620 % exceeds 100%. Gráfico: docs/figuras/utilizacion.png (asic/graficos.py --util). La comparación con v1 (que cerraba hasta 78 % con un die de 0,216 mm²) está en docs/datos_informe.md, sección 3.5.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.404 | 0 | 65.725 | 0 | 0.442 | 0 | 1.065 | 0 | 65.725 | 0 | 0.173 | 0 | sí | 208439 | 0.535 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| u2_u50 | 100 | 74.561 | 0 | 63.697 | 0 | 0.397 | 0 | 0.981 | 0 | 63.697 | 0 | 0.144 | 0 | sí | 203214 | 0.653 | 338033 | 0 | 0 | 0 | sí | 8 | 1 | 0 |
| u2_u60 | 100 | 74.615 | 0 | 65.117 | 0 | 0.395 | 0 | 0.980 | 0 | 65.117 | 0 | 0.142 | 0 | sí | 199880 | 0.769 | 283758 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| u2_u70 | 100 | 74.293 | 0 | 60.805 | 0 | 0.372 | 0 | 0.946 | 0 | 60.805 | 0 | 0.125 | 0 | sí | 196907 | 0.887 | 244851 | 0 | 0 | 0 | sí | 20 | 1 | 0 |
| u2_u72 | 100 | 73.836 | 0 | 61.351 | 0 | 0.399 | 0 | 0.993 | 0 | 61.351 | 0 | 0.142 | 0 | sí | 197305 | 0.917 | 238352 | 0 | 0 | 0 | sí | 92 | 5 | 0 |
| u2_u73 | 100 | 73.899 | 0 | 59.531 | 0 | 0.426 | 0 | 1.038 | 0 | 59.531 | 0 | 0.162 | 0 | sí | 196334 | 0.918 | 235237 | 0 | 0 | 0 | sí | 99 | 6 | 0 |
| u2_u74 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| u2_u75 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| u2_u78 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| u2_u80 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| u2_u90 | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| u2_u50 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| u2_u60 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| u2_u70 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| u2_u72 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| u2_u73 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |

## Estrategia 1 con la configuración final, reproducción independiente (sección 3.2)

Corrida s3_t100: la misma configuración y el mismo RTL que la corrida final, con otro tag. Sirve de reproducción: si da los mismos números que final, el flujo es determinista con esta configuración. El barrido de período de la estrategia 1 es el de las f2_* de más arriba; no se repitió con otro tag.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| final | 100 | 74.404 | 0 | 65.725 | 0 | 0.442 | 0 | 1.065 | 0 | 65.725 | 0 | 0.173 | 0 | sí | 208439 | 0.535 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| s3_t100 | 100 | 74.404 | 0 | 65.725 | 0 | 0.442 | 0 | 1.065 | 0 | 65.725 | 0 | 0.173 | 0 | sí | 208439 | 0.535 | 419131 | 0 | 0 | 0 | sí | 0 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| final | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |
| s3_t100 | 156098.477 | 63399.571 | 964 | 80348.710 | 10005.722 | 3942.579 |

## Estrategia 2 de memoria con la configuración final (sección 3.2)

Corridas s4_* con asic/ff/config_final.yaml: memoria unificada de instrucciones y datos en flip-flops, el core nuevo con EarlyRead = 0 (el valor por omisión cuando MemStrategy = 2: la memoria en flip-flops lee registrado y no puede anticipar la lectura del banco) y las mismas perillas de flujo de la corrida final, incluido el modelo de cable. Por eso su CPI es el de v1 (2,665 en el juego completo, docs/verificacion/integracion_01_make_check.txt) y no el 1,665 de la estrategia 1. Comparar con las s2_* de v1 (asic/barrido.md), que usaban asic/ff/config.yaml y cuyo periodo minimo era 62 ns. Con la configuracion final la estrategia 2 baja mucho mas: cierra a 100, 65, 60, 55, 50, 45, 42, 40 y 35 ns, y el WNS no baja un nanosegundo por cada nanosegundo de periodo porque el resizer sigue reparando (55,558 a 100 ns; 10,558 a 55; 6,939 a 50; 6,802 a 45; 5,431 a 42; 5,531 a 40; 3,066 a 35). El punto de 30 ns no se pudo medir: s4_t30 y su repeticion s4_t30_b (esta ultima con la cola vacia) las corto la regla de 40 minutos de la cola en el paso 44 de 78, con el resizer todavia en WNS -0,276 ns; evidencia en asic/ff/resultados/s4_t30_b/falla.txt. O sea que 35 ns es el menor periodo medido, no necesariamente el minimo.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| s4_t100 | 100 | 72.771 | 0 | 55.558 | 0 | 0.439 | 0 | 1.060 | 0 | 55.558 | 0 | 0.171 | 0 | sí | 977015 | 0.562 | 1801610 | 0 | 0 | 0 | sí | 62 | 14 | 0 |
| s4_t65 | 65 | 41.084 | 0 | 20.558 | 0 | 0.439 | 0 | 1.060 | 0 | 20.558 | 0 | 0.171 | 0 | sí | 977015 | 0.562 | 1801610 | 0 | 0 | 0 | sí | 62 | 14 | 0 |
| s4_t60 | 60 | 36.084 | 0 | 15.558 | 0 | 0.439 | 0 | 1.060 | 0 | 15.558 | 0 | 0.171 | 0 | sí | 977015 | 0.562 | 1801610 | 0 | 0 | 0 | sí | 62 | 14 | 0 |
| s4_t55 | 55 | 31.084 | 0 | 10.558 | 0 | 0.439 | 0 | 1.060 | 0 | 10.558 | 0 | 0.171 | 0 | sí | 977015 | 0.562 | 1801610 | 0 | 0 | 0 | sí | 62 | 14 | 0 |
| s4_t50 | 50 | 26.834 | 0 | 6.939 | 0 | 0.439 | 0 | 1.060 | 0 | 6.939 | 0 | 0.171 | 0 | sí | 977125 | 0.562 | 1801610 | 0 | 0 | 0 | sí | 64 | 13 | 0 |
| s4_t45 | 45 | 24.513 | 0 | 6.802 | 0 | 0.439 | 0 | 1.060 | 0 | 6.802 | 0 | 0.171 | 0 | sí | 978190 | 0.563 | 1801610 | 0 | 0 | 0 | sí | 49 | 15 | 0 |
| s4_t42 | 42 | 22.385 | 0 | 5.431 | 0 | 0.439 | 0 | 1.060 | 0 | 5.431 | 0 | 0.171 | 0 | sí | 980598 | 0.564 | 1801610 | 0 | 0 | 0 | sí | 52 | 11 | 0 |
| s4_t40 | 40 | 21.461 | 0 | 5.531 | 0 | 0.439 | 0 | 1.060 | 0 | 5.531 | 0 | 0.163 | 0 | sí | 981147 | 0.565 | 1801610 | 0 | 0 | 0 | sí | 66 | 17 | 0 |
| s4_t35 | 35 | 17.708 | 0 | 3.066 | 0 | 0.439 | 0 | 1.060 | 0 | 3.066 | 0 | 0.171 | 0 | sí | 990048 | 0.570 | 1801610 | 0 | 0 | 0 | sí | 35 | 14 | 0 |
| s4_t30_b | incompleta |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| s4_t100 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t65 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t60 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t55 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t50 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t45 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t42 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t40 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |
| s4_t35 | 696640.134 | 346545.248 | 4673 | 80348.710 | 10005.722 | 3942.579 |

## El pipeline sin B2 con la configuración final (sección 3.4, efecto de B2)

Corridas pr_* en el worktree build/exp_pipeline (rama exp/pipeline, asic/rom/config_final.yaml: la configuración final de D23 aplicada al RTL del frente A sin el offset de byte de la carga registrado en la LSU). Mide cuánto aporta B2 con el flujo final, igual que exp/lsu-offset lo midió con el flujo de v1. El CPI es el mismo que el de la corrida final (1,665): B2 no cambia ningún ciclo, solo acorta la ruta de alineación y write-back. Período mínimo sin B2: 22,5 ns (44,4 MHz); pr_t22p5 cierra con WNS 0,007 ns y TNS 0 en max_ss_125C_4v50 y pr_t22 no cierra por 0,597 ns (TNS -3,869), con lo que la regla de 0,5 ns queda cerrada. Con B2 el mínimo es 21,5 ns, así que B2 compra 1 ns de período y 1,2 MIPS (26,7 contra 27,9). Comparar contra las f2_* del mismo período.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pr_t100 | 100 | 74.479 | 0 | 65.710 | 0 | 0.407 | 0 | 1.001 | 0 | 65.710 | 0 | 0.151 | 0 | sí | 208390 | 0.535 | 418503 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| pr_t24 | 24 | 11.920 | 0 | 1.556 | 0 | 0.409 | 0 | 1.007 | 0 | 1.556 | 0 | 0.152 | 0 | sí | 221838 | 0.570 | 418503 | 0 | 0 | 0 | sí | 2 | 1 | 0 |
| pr_t23 | 23 | 10.877 | 0 | 0.463 | 0 | 0.409 | 0 | 1.005 | 0 | 0.463 | 0 | 0.152 | 0 | sí | 224404 | 0.577 | 418503 | 0 | 0 | 0 | sí | 2 | 1 | 0 |
| pr_t22p5 | 22.500 | 10.409 | 0 | 0.007 | 0 | 0.410 | 0 | 1.007 | 0 | 0.007 | 0 | 0.152 | 0 | sí | 227032 | 0.583 | 418503 | 0 | 0 | 0 | sí | 2 | 1 | 0 |
| pr_t22 | 22 | 9.852 | 0 | -0.597 | -3.869 | 0.408 | 0 | 1.005 | 0 | -0.597 | -3.869 | 0.151 | 0 | no | 228523 | 0.587 | 418503 | 0 | 0 | 0 | no | 2 | 1 | 0 |
| pr_t21p5 | 21.500 | 9.362 | 0 | -0.938 | -178.821 | 0.409 | 0 | 1.006 | 0 | -0.938 | -178.821 | 0.151 | 0 | no | 228035 | 0.586 | 418503 | 0 | 0 | 0 | no | 0 | 1 | 0 |
| pr_t21 | 21 | 8.768 | 0 | -1.634 | -542.714 | 0.410 | 0 | 1.007 | 0 | -1.634 | -542.714 | 0.152 | 0 | no | 227478 | 0.585 | 418503 | 0 | 0 | 0 | no | 0 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| pr_t100 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pr_t24 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pr_t23 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pr_t22p5 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pr_t22 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pr_t21p5 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |
| pr_t21 | 155854.810 | 63272.250 | 962 | 80348.710 | 10005.722 | 3942.579 |

## Historia: la corrida final de v1 y su barrido de período

v1 es main antes de integrar exp/candidata-rc (tag v1-final); su corrida final quedó en asic/rom/runs/v1_final_run y sus reportes versionados en asic/rom/resultados/v1_final/. Cerraba a 24,5 ns (40,8 MHz, 15,3 MIPS) con 182.265 µm² de celdas, 546 violaciones de max slew y 36 de max capacitancia. f1_t26, f1_t25, f1_t24p5 y f1_t24 daban exactamente el mismo layout (8.708 celdas, 189.817 µm² y 354.897 µm de cables): con el margen de 10 ns de D20 y la estimación de parásitos del tech LEF el resizer llegaba a su límite y de ahí para abajo solo cambiaba el slack. f1_t28 se detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (regla de tiempo del grupo) y no se cuenta.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| v1_final_run | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| f1_t32 | 32 | 17.409 | 0 | 4.395 | 0 | 0.450 | 0 | 1.081 | 0 | 4.395 | 0 | 0.178 | 0 | sí | 183725 | 0.484 | 408957 | 0 | 0 | 0 | sí | 490 | 38 | 0 |
| f1_t30 | 30 | 16.758 | 0 | 5.103 | 0 | 0.450 | 0 | 1.081 | 0 | 5.103 | 0 | 0.178 | 0 | sí | 186320 | 0.491 | 408957 | 0 | 0 | 0 | sí | 521 | 36 | 0 |
| f1_t26 | 26 | 13.160 | 0 | 1.996 | 0 | 0.450 | 0 | 1.081 | 0 | 1.996 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t25 | 25 | 12.160 | 0 | 0.996 | 0 | 0.450 | 0 | 1.081 | 0 | 0.996 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t24p5 | 24.500 | 11.660 | 0 | 0.496 | 0 | 0.450 | 0 | 1.081 | 0 | 0.496 | 0 | 0.178 | 0 | sí | 189817 | 0.500 | 408957 | 0 | 0 | 0 | sí | 532 | 36 | 0 |
| f1_t24 | 24 | 11.160 | 0 | -0.004 | -0.004 | 0.450 | 0 | 1.081 | 0 | -0.004 | -0.004 | 0.178 | 0 | no | 189817 | 0.500 | 408957 | 0 | 0 | 0 | no | 532 | 36 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| v1_final_run | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t32 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t30 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t26 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t25 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t24p5 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| f1_t24 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Historia: RTL sin pre-decodificación (116fa20) con la configuración de v1 (sección 3.4, efecto de D18)

Corridas r0_* del RTL del commit 116fa20 (sin D18) en un worktree (build/ref116, enlazado en asic/rom/runs/r0_*) con la asic/rom/config.yaml y pines.cfg que tenía v1, a 100 ns y a 26 ns. Comparar con v1_final_run y f1_t26, no con la corrida final nueva.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| r0_t100 | 100 | 74.579 | 0 | 54.552 | 0 | 0.410 | 0 | 1.005 | 0 | 54.552 | 0 | 0.153 | 0 | sí | 174529 | 0.478 | 393525 | 0 | 0 | 0 | sí | 754 | 48 | 0 |
| r0_t26 | 26 | 10.461 | 0 | -3.175 | -1223.744 | 0.413 | 0 | 1.012 | 0 | -3.175 | -1223.744 | 0.155 | 0 | no | 181326 | 0.497 | 393525 | 0 | 0 | 0 | no | 648 | 46 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| r0_t100 | 146215.686 | 60673.133 | 921 | 73655.546 | 10005.722 | 3942.579 |
| r0_t26 | 146215.686 | 60673.133 | 921 | 73655.546 | 10005.722 | 3942.579 |

## Historia: barrido de FP_CORE_UTIL de v1 a 100 ns

Corridas u1_* con la configuración de v1. Cerraban 50, 60, 70, 72, 75 y 78 %: la utilización máxima que cerraba era 78 % (u1_u78: die 455,4 x 473,3 µm = 215.545 µm², utilización real 90,3 %, WNS de setup 59,6 ns en max_ss_125C_4v50 y hold 0,182 ns). u1_u79 y u1_u80 fallaban en OpenROAD.CTS (al legalizar después de insertar los buffers del árbol de reloj quedan instancias sin lugar: el log informa [INFO DPL-0034] con la lista de 6 instancias en u1_u79 y 22 en u1_u80, y después [ERROR DPL-0036] Detailed placement failed; extractos versionados en asic/rom/resultados/u1_u79/falla.txt y u1_u80/falla.txt) y u1_u90 en el placement global ([GPL-0301] Utilization 100.531 % exceeds 100%, extracto en u1_u90/falla.txt). A 78 % la ruta crítica dejaba de ser la de la ALU al banco de registros (slack 60,5 ns) y pasaba a ser la salida seg2[2] del display (59,6 ns; 69,2 ns a 75 %), y las violaciones de slew subían de 424 a 880 pines.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| v1_final_run | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
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
| v1_final_run | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u50 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u60 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u70 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u72 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u75 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_u78 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Historia: terminales ubicados por el flujo (sin D21), sección 3.5

Corrida u1_auto con la configuración de v1: idéntica a la final de v1 salvo que no define IO_PIN_ORDER_CFG y OpenROAD.IOPlacement ubica los terminales donde acorta los cables. Comparar con v1_final_run (D21): largo de cables, DRC de ruteo por iteración (route__drc_errors__iter:N en metrics.json), slew y WNS. No se repitió con la configuración nueva.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| v1_final_run | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| u1_auto | 100 | 74.680 | 0 | 65.213 | 0 | 0.417 | 0 | 1.019 | 0 | 65.213 | 0 | 0.157 | 0 | sí | 182204 | 0.480 | 408957 | 0 | 0 | 0 | sí | 569 | 31 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| v1_final_run | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| u1_auto | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |

## Historia: floorplan con DIE_AREA absoluto y aspecto 1,6:1 (sección 3.5)

Corrida d4_die con la configuración de v1 (asic/rom/config_die.yaml): idéntica a la final de v1 salvo FP_SIZING: absolute y DIE_AREA 0 0 808,64 505,68 µm (aspecto 1,6:1; 408.913 µm², 0,011 % menos que los 408.957 µm² de la final de v1, que medía 630,60 x 648,52 µm). CORE_AREA no se define: floorplan.tcl de LibreLane la calcula restando los márgenes de siempre (6,72 µm a los lados y 15,68 µm arriba y abajo), 795,20 x 474,32 µm = 377.179 µm² en 121 filas de 1420 sitios (final de v1: 379.800 µm², 157 filas de 1102 sitios). Contra la final de v1: cables 364.879 contra 352.253 µm (+3,6 %), cable más largo 975 contra 1.409 µm, WNS de setup 61,672 contra 65,223 ns en max_ss_125C_4v50, slew 567 contra 546 pines y área de celdas 180.939 contra 182.265 µm². No se repitió con la configuración nueva.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| v1_final_run | 100 | 74.694 | 0 | 65.223 | 0 | 0.450 | 0 | 1.081 | 0 | 65.223 | 0 | 0.178 | 0 | sí | 182265 | 0.480 | 408957 | 0 | 0 | 0 | sí | 546 | 36 | 0 |
| d4_die | 100 | 74.457 | 0 | 61.672 | 0 | 0.415 | 0 | 1.013 | 0 | 61.672 | 0 | 0.156 | 0 | sí | 180939 | 0.480 | 408913 | 0 | 0 | 0 | sí | 567 | 33 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| v1_final_run | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| d4_die | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
