# Rama exp/candidata (frente E): paquete completo de la candidata

Sesión del 28-10-2026. Rama `exp/candidata`, creada por el coordinador desde `exp/pipeline-b2`
(commit be50893); worktree `build/exp_candidata`. Es el core del frente A (lectura del banco de
registros y decodificación en el fetch, parámetro `EarlyRead`, write-through en el banco) más el
offset de byte de la carga registrado en la LSU (B2, frente B), con la configuración final de
`main` (D15, D20, D21) y `EarlyRead=1` en `SYNTH_PARAMETERS` de `asic/rom/config.yaml`.
No lleva el banco de latches de B5.

Este documento es el paquete que el informe necesitaría si la candidata pasara a ser la corrida
final: los mismos archivos y nombres que usa `main` para la final, pero en la rama
(`asic/final.md`, `asic/sintesis.md`, `asic/sim/resultado*.md`, `asic/rom/resultados/<tag>/`,
`docs/datos_informe.md`). Cada número tiene su archivo de origen.

## 0. Qué corridas son de quién (no se repitió nada)

El árbol de esta rama es idéntico al de `exp/pipeline-b2` en be50893, así que las corridas de ese
frente con `asic/rom/config.yaml` SON corridas de la candidata y no se volvieron a correr (regla
de la sesión). Están enlazadas en `asic/rom/runs/` a `build/exp_pipeline_b2` y sus reportes se
copiaron a `asic/rom/resultados/<tag>/` con `asic/recolectar.py` desde esta rama:

| tag | qué es | de dónde viene |
|---|---|---|
| `pa_b2_t100` | corrida base de la candidata, 100 ns y 40 % | frente A, `build/exp_pipeline_b2` |
| `pa_b2_t26`, `pa_b2_t25p5`, `pa_b2_t25` | barrido de período de la configuración base | frente A |
| `e1_*` | corridas nuevas del frente E con la estrategia 1 | esta rama |
| `e2_*` | corridas nuevas del frente E con la estrategia 2 (`asic/ff`) | esta rama |
| `m_final`, `m_f1_t24p5` | corrida final de `main` y su período mínimo, solo para comparar | enlaces al repo principal, solo lectura |

El tag `e1_t100` NO se usó: en `asic/rom/resultados/` de la rama ya existe un `e1_t100` heredado
de la historia de `main` (una exploración vieja) y no se borra ni se sobreescribe nada
(regla de la sesión). La corrida base de la candidata a 100 ns es `pa_b2_t100`.

## 1. Verificación de la rama (paso obligatorio antes de medir)

Hecha por el frente A en el commit be50893, con el MISMO RTL de esta rama (`git diff
be50893 -- rtl/` vacío). Salidas completas en `docs/verificacion/`:

| prueba | resultado | archivo |
|---|---|---|
| `make check` | 80 pruebas del assembler OK y los seis testbenches PASS (las dos estrategias, partidas completas) | `docs/verificacion/b2_make_check.txt` |
| `make equiv MODO=funcional` (isa_test) | rf 46, bus 22, io 2 eventos iguales, secuencias equivalentes, con las dos estrategias | `docs/verificacion/b2_make_equiv_funcional.txt` |
| `make equiv PROG=hazard_test REF=main MODO=funcional` | rf 348, bus 63, io 2 eventos iguales, secuencias equivalentes | `docs/verificacion/hazard_test_y_mutaciones.txt` |
| monitor de X | 0 valores desconocidos usados en todas las simulaciones | `docs/verificacion/b2_make_check.txt`, `b2_make_equiv_funcional.txt` |
| pruebas de mutación (MUTA_FWD, MUTA_LOADUSE) | las dos mutaciones hacen fallar la comparación | `docs/verificacion/hazard_test_y_mutaciones.txt` |

CPI medido (impreso por `game_tb` y `core_trace_tb`):

| programa / simulación | ciclos | instrucciones | CPI | main |
|---|---|---|---|---|
| juego completo, estrategia 1, 10 rondas | 1.595.814 | 958.358 | 1,665 | 2,665 |
| juego completo, estrategia 1, 4 rondas | 782.048 | 465.094 | 1,681 | 2,682 |
| juego completo, estrategia 2 (EarlyRead = 0) | 1.599.759 | 600.218 | 2,665 | 2,665 |
| `sw/isa_test.s` | 3.000 | 1.524 | 1,969 | 2,953 |
| `sw/hazard_test.s` | 2.999 | 1.695 | 1,769 | 2,654 |

El CPI del juego con la estrategia 2 es exactamente el de `main` porque con `MemStrategy=2` el
SoC instancia el core con `EarlyRead = 0` (decisión del frente A, `docs/pipeline.md`): esa
estrategia conserva la temporización de `main` y así `make check` y `make equiv` siguen cubriendo
el camino antiguo del core en la misma rama.

## 2. Corrida base a 100 ns y 40 %, y comparación con main

Tablas completas en `asic/final.md` (las genera `bash asic/tablas.sh` con `asic/recolectar.py`).
Cierre: `asic/rom/resultados/pa_b2_t100/cierre.md` (DRC de Magic 0, LVS 0, antenas 0, setup y hold
con WNS >= 0 y TNS = 0 en las 9 esquinas).

| magnitud | candidata (pa_b2_t100) | main (m_final) | archivo de origen |
|---|---|---|---|
| cierra a 100 ns y 40 % | sí | sí | `cierre.md` de cada tag |
| WNS de setup, max_ss_125C_4v50 (ns) | 63,191 | 65,223 | `metrics.json` |
| hold peor de las 9 esquinas (ns) | 0,134 | 0,178 | `metrics.json` |
| área de celdas estándar (µm²) | 186.432 | 182.265 | `metrics.json` (`design__instance__area__stdcell`) |
| sobre main | +2,3 % (límite de la sesión: +5 %, 191.378 µm²) | | |
| celdas estándar | 9.197 | 8.670 | `metrics.json` |
| área del die (µm²) | 419.131 | 408.957 | `metrics.json` |
| largo de cables (µm) | 371.092 | 352.253 | `metrics.json` |
| flip-flops | 964 | 990 | `sintesis_stat.rpt` |
| área de síntesis (µm²) | 156.098 | 152.169 | `sintesis_stat.rpt` |
| área de `espino_register_file` (µm²) | 80.349 | 73.656 | `sintesis_stat.rpt` |
| pines con violación de max slew | 571 | 546 | `metrics.json` |
| pines con violación de max capacitancia | 37 | 36 | `metrics.json` |
| potencia sin actividad, nom_tt (mW) | 8,597 | 8,971 | `55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt` |

El banco de registros crece 6.693 µm² por el write-through y el enable de lectura, y el registro
de instrucción pierde 28 flip-flops (con EarlyRead solo se usan los bits de rd): el neto es
+2,3 % de área de celdas a 100 ns, dentro del límite.

## 3. Barrido de período y ruta crítica

`asic/final.md`, sección "Barrido de CLOCK_PERIOD de la candidata". Cierra a 100, 26 y 25,5 ns;
25 ns no cierra (setup en `max_ss_125C_4v50`, WNS -0,409 ns y TNS -1,027 ns;
`asic/rom/resultados/pa_b2_t25/cierre.md`). Período mínimo 25,5 ns, f_max 39,2 MHz, y la brecha
con el primero que no cierra es 0,5 ns, lo que cumple la regla de la sesión.

Ruta crítica a 25,5 ns (`asic/rom/resultados/pa_b2_t25p5/layout/ruta_critica.txt`, figura
`ruta_critica.png`): 24 celdas, de `_4288_` (`dffrnq_2`, un bit de `pc_q` que maneja
`u_soc.g_mem_rom.u_mem.a_addr_i[3]`) a `u_soc.u_core.u_rf/_4114_` (`dffq_1`, un flip-flop del
banco de registros), pasando por la ROM combinacional (`a_next_o[17]`) y por el banco. Es
exactamente el camino que crea EarlyRead: PC -> ROM -> dirección rs -> banco de registros. A
100 ns la crítica es otra (`asic/rom/resultados/pa_b2_t100/layout/ruta_critica.txt`): 29 celdas de
`_4325_` (`dffq_1`, `alu_op_b_sel` de la etapa ID) a `_4442_` (`dffrnq_1`), la ruta que el resizer
deja con el margen de 10 ns de D20.

En `main` el período mínimo es 24,5 ns (40,8 MHz) y la crítica es la de la ALU al banco de
registros (`asic/rom/resultados/final/layout/ruta_critica.txt`).

## 4. Regla de selección: MIPS

| diseño | f_max (MHz) | CPI del juego | MIPS | área de celdas a 100 ns |
|---|---|---|---|---|
| main | 40,8 (24,5 ns) | 2,665 | 15,3 | 182.265 µm² |
| candidata | 39,2 (25,5 ns) | 1,665 | 23,6 | 186.432 µm² (+2,3 %) |

La candidata da 1,54 veces los MIPS de `main` con 2,3 % más de área de celdas, dentro del
límite de 105 % de la regla de selección.
