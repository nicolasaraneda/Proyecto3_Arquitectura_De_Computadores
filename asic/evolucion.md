# Evolución del rendimiento del diseño (sección 3.4)

Generada por `python3 asic/evolucion.py`. El período mínimo de cada etapa es el menor
`CLOCK_PERIOD` de su barrido que cumple el criterio de cierre (D14 más DRC de Magic, LVS y
antenas); la columna siguiente da el primer período que no cierra, para que se vea la resolución
del barrido. El área, el slew y la capacitancia son los de la corrida a 100 ns de cada etapa.
MIPS = f máx / CPI del juego completo (Ley de Hierro).

| etapa | T mínimo (ns) | primer T que no cierra | f máx (MHz) | CPI del juego | MIPS | área de celdas a 100 ns (µm²) | slew / cap a 100 ns | origen del área |
|---|---|---|---|---|---|---|---|---|
| s1 (estrategia 1, configuración de D14 a D16) | 55,0 | 53,0 | 18,2 | 2,665 | 6,8 | 173.568 | 2184 / 4 | `asic/rom/resultados/s1_t100/metrics.json` |
| p1 (pre-decodificación, D18, con el flujo de D15) | 42,0 | 40,0 | 23,8 | 2,665 | 8,9 | 181.137 | 2201 / 3 | `asic/rom/resultados/p1_t100/metrics.json` |
| v1 (corrida final de v1, tag `v1-final`) | 24,5 | 24,0 | 40,8 | 2,665 | 15,3 | 182.265 | 546 / 36 | `asic/rom/resultados/v1_final/metrics.json` |
| co_rcm (el RTL de v1 con el modelo de cable) | 22,0 | 21,5 | 45,5 | 2,665 | 17,1 | 201.309 | 2 / 1 | `asic/main_rc/resultados/co_rcm_t100/metrics.json` |
| pr (el pipeline sin B2, con el flujo final) | 22,5 | 22,0 | 44,4 | 1,665 | 26,7 | 208.390 | 0 / 1 | `build/exp_pipeline/asic/rom/resultados/pr_t100/metrics.json` |
| final (la corrida final de D23) | 21,5 | 21,0 | 46,5 | 1,665 | 27,9 | 208.439 | 0 / 1 | `asic/rom/resultados/final/metrics.json` |

Descripción y origen del CPI de cada etapa:

- **s1 (estrategia 1, configuración de D14 a D16)**: RTL del Proyecto 3 antes de la pre-decodificación (equivalente ciclo a ciclo a `116fa20`), con la configuración corregida de esquinas y celdas de retardo. CPI 2,665; origen del CPI: `make check` de v1 (`game_tb`); D18 es equivalente ciclo a ciclo a este RTL.
- **p1 (pre-decodificación, D18, con el flujo de D15)**: el decode pasa a un registro (D18), con la configuración de flujo de D15 y D16. CPI 2,665; origen del CPI: el mismo de la fila anterior, porque D18 no cambia ningún ciclo.
- **v1 (corrida final de v1, tag `v1-final`)**: lo anterior más el flujo final de D20 y D21 (sin `buf_1`, margen del resizer de 10 ns, terminales por función). CPI 2,665; origen del CPI: `make check` de v1 (`game_tb`): 1.599.759 / 600.218.
- **co_rcm (el RTL de v1 con el modelo de cable)**: el mismo RTL de v1 con `LAYERS_RC` y la reparación post-GRT: mide cuánto del salto es del flujo y no del diseño. CPI 2,665; origen del CPI: el RTL es el de v1, así que el CPI es el mismo.
- **pr (el pipeline sin B2, con el flujo final)**: el pipeline con lectura del banco y decodificación en el fetch, sin el offset de byte de la carga registrado en la LSU, con la configuración final: mide el aporte de B2. CPI 1,665; origen del CPI: `make check` del worktree `build/exp_pipeline`; A y A+B2 tienen el mismo CPI.
- **final (la corrida final de D23)**: el pipeline con B2 más el modelo de cable y la reparación post-GRT. CPI 1,665; origen del CPI: `docs/verificacion/integracion_01_make_check.txt` (`game_tb`): 1.595.814 / 958.358.

## Cuánto del aumento de MIPS viene del RTL y cuánto del flujo

De v1 a la corrida final los MIPS pasan de 15,3 a 27,9, es decir 12,6 MIPS más (82,4 por ciento).

MIPS = (1000 / T) / CPI, así que el aumento se puede repartir de dos maneras, y las
dos hay que darlas porque la diferencia entre ellas es el término de interacción
(bajar el período rinde más cuando el CPI ya es bajo):

| camino | paso | MIPS | aporte |
|---|---|---|---|
| primero el flujo | v1 | 15,3 | |
| primero el flujo | v1 con el modelo de cable (co_rcm, T 22,0 ns, CPI 2,665) | 17,1 | 1,7 MIPS del flujo |
| primero el flujo | la corrida final (T 21,5 ns, CPI 1,665) | 27,9 | 10,9 MIPS del RTL |
| primero el RTL | v1 | 15,3 | |
| primero el RTL | el pipeline con el flujo de v1 (`exp/candidata`, T 25,5 ns, CPI 1,665) | 23,6 | 8,2 MIPS del RTL |
| primero el RTL | la corrida final (T 21,5 ns, CPI 1,665) | 27,9 | 4,4 MIPS del flujo |

Repartido de la forma conservadora (a cada factor su aporte más chico y el resto
a la interacción): **8,2 MIPS los pone el RTL** (bajar el CPI de 2,665 a 1,665), **1,7 MIPS los pone el flujo**
(bajar el período de 24,5 a 21,5 ns) y **2,6 MIPS
son de la interacción**, que no se le puede atribuir a ninguno de los dos por
separado. El orden de magnitud es claro: el RTL manda, porque el CPI entra
dividiendo y bajó un 37,5 por ciento mientras el período bajó un 12,2 por ciento.

Origen de cada MIPS de la tabla: el período mínimo de cada fila sale de su barrido en
la tabla de arriba, y el CPI de la lista de orígenes de cada etapa. El valor de
`exp/candidata` con el flujo de v1 (25,5 ns) está en `docs/propuesta_d23.md`,
sección 4, y en `asic/exploraciones_tabla.md`.

