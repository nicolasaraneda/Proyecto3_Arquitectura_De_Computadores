# Barrido de CLOCK_PERIOD de las dos estrategias de memoria

Una fila por corrida. Los valores de timing, área y verificación salen del `metrics.json` de cada corrida (`asic/<rom|ff>/resultados/<tag>/metrics.json`); los de síntesis, del `sintesis_stat.rpt` de la misma carpeta. Todos con 3 decimales.

## Timing, área y verificación tras PnR

| estrategia | T (ns) | setup WS nom_tt | setup TNS nom_tt | setup WS max_ss | setup TNS max_ss | hold WS nom_tt | hold TNS nom_tt | hold WS max_ss | hold TNS max_ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | área stdcell | utilización | área die | antena | DRC | LVS | cierra timing | cierra todo |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MemStrategy 1 (ROM) | 100 | 64.440 | 0.000 | 32.314 | 0.000 | 0.482 | 0.000 | 1.147 | 0.000 | 32.314 | 0.000 | 0.192 | 0.000 | 185591.000 | 0.508 | 393525.000 | 0.000 | 0.000 | 0.000 | sí | sí |
| MemStrategy 1 (ROM) | 75 | 39.440 | 0.000 | 7.314 | 0.000 | 0.482 | 0.000 | 1.147 | 0.000 | 7.314 | 0.000 | 0.192 | 0.000 | 185591.000 | 0.508 | 393525.000 | 0.000 | 0.000 | 0.000 | sí | sí |
| MemStrategy 1 (ROM) | 65 | 29.440 | 0.000 | -2.686 | -53.151 | 0.482 | 0.000 | 1.147 | 0.000 | -2.686 | -53.151 | 0.192 | 0.000 | 185591.000 | 0.508 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no |
| MemStrategy 1 (ROM) | 60 | 24.440 | 0.000 | -7.686 | -891.440 | 0.482 | 0.000 | 1.147 | 0.000 | -7.686 | -891.440 | 0.192 | 0.000 | 185591.000 | 0.508 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no |
| MemStrategy 2 (FF) | 100 | 60.247 | 0.000 | 24.281 | 0.000 | 0.556 | 0.000 | 1.275 | 0.000 | 24.281 | 0.000 | 0.246 | 0.000 | 909072.000 | 0.526 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no |
| MemStrategy 2 (FF) | 90 | 50.247 | 0.000 | 14.281 | 0.000 | 0.556 | 0.000 | 1.275 | 0.000 | 14.281 | 0.000 | 0.246 | 0.000 | 909072.000 | 0.526 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no |
| MemStrategy 2 (FF) | 85 | 45.247 | 0.000 | 9.281 | 0.000 | 0.556 | 0.000 | 1.275 | 0.000 | 9.281 | 0.000 | 0.246 | 0.000 | 909072.000 | 0.526 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no |
| MemStrategy 2 (FF) | 80 | 40.247 | 0.000 | 4.281 | 0.000 | 0.556 | 0.000 | 1.275 | 0.000 | 4.281 | 0.000 | 0.246 | 0.000 | 909072.000 | 0.526 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no |

## Síntesis (jerarquía conservada)

| estrategia | T (ns) | área total del diseño | flip-flops del diseño | área espino_register_file | área espino_alu | área pochoco_cycle_counter |
|---|---|---|---|---|---|---|
| MemStrategy 1 (ROM) | 100 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 75 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 65 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 60 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 100 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 90 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 85 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 80 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |

## Experimento a 60 ns: celdas de retardo y esquinas del resizer (E1)

Cuatro corridas de la estrategia 1 a 60 ns, todas con la misma configuración salvo lo que
se indica: `b1_t60` es la del barrido anterior, `x1_t60_sindly` excluye las celdas de
retardo del buffering (`EXTRA_EXCLUDED_CELLS`), `x2_t60_rszss` fija `RSZ_CORNERS` a las
esquinas lenta, típica y rápida, y `x3_t60_ambos` aplica las dos cosas. Las columnas
nuevas son las instancias de celdas con `dly` en el nombre dentro de
`final/nl/asic_top.nl.v` y tres métricas del `metrics.json` de la corrida.

| corrida | T (ns) | setup WS nom_tt | setup TNS nom_tt | setup WS max_ss | setup TNS max_ss | hold WS nom_tt | hold TNS nom_tt | hold WS max_ss | hold TNS max_ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | área stdcell | utilización | área die | antena | DRC | LVS | cierra timing | cierra todo | instancias dly | design__instance__count | max slew vio | max cap vio |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b1_t60 | 60 | 24.440 | 0.000 | -7.686 | -891.440 | 0.482 | 0.000 | 1.147 | 0.000 | -7.686 | -891.440 | 0.192 | 0.000 | 185591.000 | 0.508 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 539.000 | 19848.000 | 2234.000 | 3.000 |
| x1_t60_sindly | 60 | 31.970 | 0.000 | 6.764 | 0.000 | 0.443 | 0.000 | 1.067 | 0.000 | 6.764 | 0.000 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | sí | sí | 0.000 | 20290.000 | 2184.000 | 4.000 |
| x2_t60_rszss | 60 | 24.440 | 0.000 | -7.686 | -891.440 | 0.482 | 0.000 | 1.147 | 0.000 | -7.686 | -891.440 | 0.192 | 0.000 | 185591.000 | 0.508 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 539.000 | 19848.000 | 2234.000 | 3.000 |
| x3_t60_ambos | 60 | 31.970 | 0.000 | 6.764 | 0.000 | 0.443 | 0.000 | 1.067 | 0.000 | 6.764 | 0.000 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | sí | sí | 0.000 | 20290.000 | 2184.000 | 4.000 |

## Barrido con la configuración corregida (D14 a D16)

Barrido nuevo con `EXTRA_EXCLUDED_CELLS` en los dos `config.yaml` (docs/decisiones.md, D15),
lanzado con `asic/barrido.sh`. Las corridas `s1_*` son la estrategia 1 y las `s2_*` la
estrategia 2. La columna «cierra timing» aplica el criterio de D14: `timing__setup__ws` >= 0,
`timing__setup__tns` == 0, `timing__hold__ws` >= 0 y `timing__hold__tns` == 0 en la peor de
las 9 esquinas. La fase 1 barrió 12 períodos y la fase 2 afinó el límite con 4 más
(`s1_t53`, `s1_t52`, `s2_t63` y `s2_t62`), hasta dejar la brecha entre el menor período que
cierra y el mayor que no cierra en 2 ns para las dos estrategias.

### Timing, área y verificación tras PnR

| estrategia | T (ns) | setup WS nom_tt | setup TNS nom_tt | setup WS max_ss | setup TNS max_ss | hold WS nom_tt | hold TNS nom_tt | hold WS max_ss | hold TNS max_ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | área stdcell | utilización | área die | antena | DRC | LVS | cierra timing | cierra todo | instancias dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MemStrategy 1 (ROM) | 100 | 71.970 | 0.000 | 46.764 | 0.000 | 0.443 | 0.000 | 1.067 | 0.000 | 46.764 | 0.000 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | sí | sí | 0.000 |
| MemStrategy 1 (ROM) | 60 | 31.970 | 0.000 | 6.764 | 0.000 | 0.443 | 0.000 | 1.067 | 0.000 | 6.764 | 0.000 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | sí | sí | 0.000 |
| MemStrategy 1 (ROM) | 55 | 26.970 | 0.000 | 1.764 | 0.000 | 0.443 | 0.000 | 1.067 | 0.000 | 1.764 | 0.000 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | sí | sí | 0.000 |
| MemStrategy 1 (ROM) | 53 | 24.970 | 0.000 | -0.236 | -2.172 | 0.443 | 0.000 | 1.067 | 0.000 | -0.236 | -2.172 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 0.000 |
| MemStrategy 1 (ROM) | 52 | 23.970 | 0.000 | -1.236 | -27.677 | 0.443 | 0.000 | 1.067 | 0.000 | -1.236 | -27.677 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 0.000 |
| MemStrategy 1 (ROM) | 50 | 21.970 | 0.000 | -3.236 | -209.984 | 0.443 | 0.000 | 1.067 | 0.000 | -3.236 | -209.984 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 0.000 |
| MemStrategy 1 (ROM) | 45 | 16.970 | 0.000 | -8.236 | -1812.302 | 0.443 | 0.000 | 1.067 | 0.000 | -8.236 | -1812.302 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 0.000 |
| MemStrategy 1 (ROM) | 40 | 11.970 | 0.000 | -13.236 | -4926.162 | 0.443 | 0.000 | 1.067 | 0.000 | -13.236 | -4926.162 | 0.173 | 0.000 | 173568.000 | 0.475 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 0.000 |
| MemStrategy 1 (ROM) | 35 | 10.394 | 0.000 | -11.150 | -5035.946 | 0.443 | 0.000 | 1.067 | 0.000 | -11.150 | -5035.946 | 0.173 | 0.000 | 173768.000 | 0.476 | 393525.000 | 0.000 | 0.000 | 0.000 | no | no | 0.000 |
| MemStrategy 2 (FF) | 100 | 68.428 | 0.000 | 39.653 | 0.000 | 0.457 | 0.000 | 1.098 | 0.000 | 39.653 | 0.000 | 0.180 | 0.000 | 838173.000 | 0.485 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no | 0.000 |
| MemStrategy 2 (FF) | 75 | 43.428 | 0.000 | 14.653 | 0.000 | 0.457 | 0.000 | 1.098 | 0.000 | 14.653 | 0.000 | 0.180 | 0.000 | 838173.000 | 0.485 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no | 0.000 |
| MemStrategy 2 (FF) | 70 | 38.428 | 0.000 | 9.653 | 0.000 | 0.457 | 0.000 | 1.098 | 0.000 | 9.653 | 0.000 | 0.180 | 0.000 | 838173.000 | 0.485 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no | 0.000 |
| MemStrategy 2 (FF) | 65 | 33.428 | 0.000 | 4.653 | 0.000 | 0.457 | 0.000 | 1.098 | 0.000 | 4.653 | 0.000 | 0.180 | 0.000 | 838173.000 | 0.485 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no | 0.000 |
| MemStrategy 2 (FF) | 63 | 31.428 | 0.000 | 2.653 | 0.000 | 0.457 | 0.000 | 1.098 | 0.000 | 2.653 | 0.000 | 0.180 | 0.000 | 838173.000 | 0.485 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no | 0.000 |
| MemStrategy 2 (FF) | 62 | 30.428 | 0.000 | 1.653 | 0.000 | 0.457 | 0.000 | 1.098 | 0.000 | 1.653 | 0.000 | 0.180 | 0.000 | 838173.000 | 0.485 | 1794180.000 | 1.000 | 0.000 | 0.000 | sí | no | 0.000 |
| MemStrategy 2 (FF) | 60 | 28.428 | 0.000 | -0.347 | -3.088 | 0.457 | 0.000 | 1.098 | 0.000 | -0.347 | -3.088 | 0.180 | 0.000 | 838173.000 | 0.485 | 1794180.000 | 1.000 | 0.000 | 0.000 | no | no | 0.000 |

### Síntesis (jerarquía conservada)

| estrategia | T (ns) | área total del diseño | flip-flops del diseño | área espino_register_file | área espino_alu | área pochoco_cycle_counter |
|---|---|---|---|---|---|---|
| MemStrategy 1 (ROM) | 100 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 60 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 55 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 53 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 52 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 50 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 45 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 40 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 1 (ROM) | 35 | 146400.083 | 921 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 100 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 75 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 70 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 65 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 63 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 62 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |
| MemStrategy 2 (FF) | 60 | 693900.525 | 4602 | 73655.546 | 10005.722 | 3942.579 |

### Comparación de estrategias (sección 3.2)

| estrategia | área de celdas de síntesis (100 ns) | flip-flops (100 ns) | área de celdas estándar tras PnR (100 ns) | utilización (100 ns) | área del die (100 ns) | período mínimo que cierra timing A (ns) | frecuencia máxima (MHz) | nets con violación de antena (100 ns) |
|---|---|---|---|---|---|---|---|---|
| MemStrategy 1 (ROM) | 146400.083 | 921 | 173568.000 | 0.475 | 393525.000 | 55.000 | 18.182 | 0.000 |
| MemStrategy 2 (FF) | 693900.525 | 4602 | 838173.000 | 0.485 | 1794180.000 | 62.000 | 16.129 | 1.000 |
