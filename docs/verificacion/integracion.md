# Verificación de la integración de exp/candidata-rc en main (D23)

Las 15 comprobaciones que D23 exige antes de aceptar la corrida final nueva, corridas sobre `main`
ya integrado (commit de la integración `d974a9f`, con el `Makefile` mezclado y
`tb/post_synth_tb.v` en la versión de `main`, que es la observación O1 de
`docs/revision_frente_a.md`). Todas con
`export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH`. La salida completa de cada una está en
`docs/verificacion/integracion_<n>_<nombre>.txt`; el resumen de códigos de salida en
`integracion_00_resumen.txt`. "v1" es `main` antes de integrar, tag `v1-final`.

| # | Comprobación | Comando | Resultado | Archivo |
|---|---|---|---|---|
| 1 | Pruebas del assembler y los seis testbenches, las dos estrategias | `make check` | **PASS**, código 0. 80 pruebas del assembler en 0,010 s; los seis testbenches "PASS: todos los checks OK" | `integracion_01_make_check.txt` |
| 2 | Equivalencia funcional con el RTL de referencia histórico | `make equiv MODO=funcional` (REF 116fa20) | **equivalente** en las dos estrategias: rf 46, bus 22, io 2 eventos iguales | `integracion_02_equiv_isa_116.txt` |
| 3 | Equivalencia funcional con v1, `sw/isa_test.s` | `make equiv PROG=isa_test REF=v1-final MODO=funcional` | **equivalente** en las dos estrategias: rf 46, bus 22, io 2 | `integracion_03_equiv_isa_v1.txt` |
| 4 | Equivalencia funcional con v1, `sw/hazard_test.s` (56 comprobaciones) | `make equiv PROG=hazard_test REF=v1-final MODO=funcional` | **equivalente** en las dos estrategias: rf 348, bus 63, io 2 | `integracion_04_equiv_hazard_test_v1.txt` |
| 5 | Equivalencia funcional con v1, `sw/hazard_review.s` (48 comprobaciones de la revisión) | `make equiv PROG=hazard_review REF=v1-final MODO=funcional` | **equivalente** en las dos estrategias: rf 271, bus 66, io 2 | `integracion_05_equiv_hazard_review_v1.txt` |
| 6 | Equivalencia funcional con v1, `sw/hazard_cycles.s` (CYCLES) | `make equiv PROG=hazard_cycles REF=v1-final MODO=funcional` | estrategia 1: **difiere a propósito** en el evento 3 de banco (`ref='rf x3 = 00000006' act='rf x3 = 00000003'`: el valor de CYCLES depende del ciclo y el core nuevo llega antes), con bus 10 e io 2 **iguales**; estrategia 2: todo idéntico (rf 25, bus 10, io 2) | `integracion_06_equiv_hazard_cycles_v1.txt` |
| 7 | Mutación base (sin mutar), control de que el arnés compara bien | `MAIN_DIR=build/v1 bash tb/revision_a_mutaciones.sh hazard_test . base` | equivalente a v1 en las dos estrategias | `integracion_07_mut_base.txt` |
| 8 | **Mutación 1: `MUTA_FWD`** (banco sin write-through) | idem con `-DMUTA_FWD` | **detectada**: `DIFIEREN (rf) en el evento 6: ref='rf x5 = 0000000f' act='rf x5 = xxxxxxxx'`, `DIFIEREN (bus) en el evento 1`, io 0 de 2, y el monitor de X cuenta **77** valores desconocidos usados (rf_wdata 36, operandos ALU 41). Con estrategia 2 es invisible, como corresponde (ahí `EarlyRead = 0`) | `integracion_08_mut_fwd.txt` |
| 9 | **Mutación 2: `MUTA_LOADUSE`** (lectura un flanco antes del commit de la carga) | idem con `-DMUTA_LOADUSE` | **detectada**: `DIFIEREN (rf) en el evento 84`, `DIFIEREN (bus) en el evento 24`, `DIFIEREN (io) en el evento 1` (el display muestra otro patrón). Invisible con estrategia 2 | `integracion_09_mut_loaduse.txt` |
| 10 a 12 | Las dos mutaciones también contra `hazard_review.s` | idem con `hazard_review` | **detectadas**: `MUTA_FWD` 63 X usados y `DIFIEREN (rf)` en el evento 8; `MUTA_LOADUSE` 679 X usados y `DIFIEREN (rf)` en el evento 55. La base es equivalente | `integracion_10_mut_rev_base.txt`, `_11_`, `_12_` |
| 13 | Simulación post-síntesis con el testbench de `main` y el netlist nuevo | `make post-synth` | **PASS**: trazas idénticas, 17 cambios de salida en 4.500 ciclos, **0 valores X** en las dos. Display **51** ciclos medidos en las dos rondas correctas, EE en el ciclo 1405 y la ronda que no avanza | `integracion_13_post_synth.txt` |
| 14 | Control negativo de esa comparación | `make post-synth-control` (ATRASO 8) | **FAIL de la comparación, que es lo que corresponde**: el netlist con la pulsación atrasada 8 ciclos da 12 cambios de salida y display 59 en vez de 51; el objetivo termina bien | `integracion_14_post_synth_control.txt` |
| 15 | Recalibración de los estímulos para el core nuevo | `python3 asic/sim/calibrar.py --salida asic/sim/estimulos.txt` | **sin cambios**: el archivo que quedó del `merge` es byte a byte el que vuelve a generar el calibrador con el RTL integrado | `integracion_15_calibrar.txt` |

## Monitor de valores desconocidos usados: 0 en todo lo que no está mutado

`tb/game_tb.v` y `tb/core_trace_tb.v` cuentan cuántos valores X **se usan** (no cuántos existen):
escrituras al banco, datos del bus, operandos de la ALU y salidas.

| Programa y escenario | X usados | escrituras al banco |
|---|---|---|
| Juego completo, 10 rondas, estrategia 1 | **0** | 620.217 |
| Juego completo, RONDAS = 4, estrategia 1 | **0** | 298.803 |
| Juego completo, 10 rondas, estrategia 2 | **0** | 388.411 |
| Juego completo, RONDAS = 4, estrategia 2 | **0** | 187.627 |
| `isa_test`, `hazard_test`, `hazard_review`, `hazard_cycles`, las dos estrategias | **0** | 994 a 1.588 según el programa |
| Mutación `MUTA_FWD` con `hazard_test` | 77 | 1.884 |
| Mutación `MUTA_FWD` con `hazard_review` | 63 | 1.793 |
| Mutación `MUTA_LOADUSE` con `hazard_review` | 679 | 1.814 |

Las tres últimas filas son el control: el monitor sirve porque sí sube cuando el diseño está mal.

## CPI medido en la integración (Ley de Hierro, sección 3.4)

| Escenario | CPI de v1 | CPI integrado | Archivo |
|---|---|---|---|
| Juego completo, 10 rondas, estrategia 1 (`game_tb`) | 2,665 | **1,665** (1.595.814 ciclos / 958.358 instrucciones retiradas) | `integracion_01_make_check.txt` |
| Juego con RONDAS = 4, estrategia 1 | 2,682 | **1,681** (782.048 / 465.094) | idem |
| Juego completo, estrategia 2 (`EarlyRead = 0`) | 2,665 | **2,665** (1.599.759 / 600.218) | idem |
| Juego con RONDAS = 4, estrategia 2 | 2,682 | **2,682** (783.951 / 292.252) | idem |
| `isa_test.s` (`core_trace_tb`), estrategia 1 | 2,953 | **1,969** (3.000 ciclos / 1.524 retiradas) | `integracion_03_equiv_isa_v1.txt` |
| `isa_test.s`, estrategia 2 | 2,953 | **2,953** | idem |
| `hazard_test.s`, estrategia 1 | 2,654 | **1,769** | `integracion_04_...` |
| `hazard_review.s`, estrategia 1 | 2,723 | **1,815** | `integracion_05_...` |

La estrategia 2 reproduce el CPI de v1 exactamente, que es el objetivo del parámetro `EarlyRead`:
la memoria unificada en flip-flops lee registrado y no puede anticipar, así que ese camino del
diseño queda igual que antes y `make check` lo sigue ejercitando.

## Lo que esta verificación NO cubre, dicho explícitamente

- La equivalencia **formal** (`eqy`) entre el RTL nuevo y sus netlists se corre aparte
  (`docs/equivalencia.md`); lo de acá es equivalencia por simulación.
- `hazard_cycles.s` difiere a propósito en las escrituras al banco: el programa lee el contador de
  ciclos y el core nuevo llega antes, así que el valor leído no es comparable. Lo comparable (bus y
  salidas) sí es idéntico, y las 5 comprobaciones del programa pasan en las dos versiones.
- `make post-synth` compara sin retardos. La comparación con retardos anotados es
  `make post-pnr-sdf` y `make post-pnr-cvc`, en `asic/sim/resultado_sdf.md`.
