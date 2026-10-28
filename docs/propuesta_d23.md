# Propuesta: adoptar `exp/candidata` como corrida final (D23)

Este documento compara la corrida final actual (`main`, tag `final`) con la rama `exp/candidata`
de la sesión del 27 y 28-10-2026, en todos los criterios del enunciado y en las métricas de la
regla de selección de la sesión. Es una propuesta: nada de esto está adoptado en `main`. La
decisión queda en D23 de `docs/decisiones.md`, con "Elegida: pendiente (Nicolás)".

Todos los números salen de los `metrics.json`, los `cierre.md` y los reportes copiados a
`resultados/` de cada corrida; la ruta de origen va en cada fila o al final de cada tabla. Nada
está estimado: donde no hay medición, dice "no medido".

## 1. Resumen y recomendación

La candidata es el core con **lectura del banco de registros y decodificación durante el fetch**
(frente A, rama `exp/pipeline`, parámetro `EarlyRead`) más el **offset de byte de la carga
registrado en la LSU** (B2), sobre la misma configuración de flujo de la corrida final actual
(D15, D20, D21). Rama `exp/candidata`, creada desde `exp/pipeline-b2` (commit `be50893`).

| | `main` (final) | `exp/candidata` (A+B2) |
|---|---|---|
| CPI del juego completo (`game_tb`) | 2,665 | **1,665** |
| Período mínimo que cierra todo | 24,5 ns | 25,5 ns |
| f máx | 40,8 MHz | 39,2 MHz |
| **MIPS = f máx / CPI (métrica principal)** | 15,3 | **23,6 (+54 por ciento)** |
| Área de celdas estándar a 100 ns | 182.265 µm² | 186.432 µm² (+2,3 por ciento) |

El cambio gana un 54 por ciento de rendimiento real en el programa del enunciado, a cambio de
1 ns de período, 2,3 por ciento de área de celdas y 2,5 por ciento de área de die. Cumple el
límite de área de la sesión (105 por ciento de `main`) y cierra todos los criterios del enunciado
a 100 ns y 40 por ciento de utilización.

Recomendación del coordinador: **es un cambio defendible y bien verificado, pero adoptarlo obliga
a rehacer las secciones 3.3 a 3.7 del informe y a reescribir unas 25 respuestas del banco de la
defensa, a 14 días de la entrega.** Las tres opciones, con sus consecuencias, están en la
sección 9 y en D23. La opción intermedia (adoptar nada en la corrida final y presentar la
candidata como la exploración principal de la sección 3.4, que es lo que hoy hace D22 con el
bloque B) conserva todo el trabajo hecho y no toca ninguna cifra del informe.

## 2. Qué es exactamente la candidata

- **RTL.** `rtl/espino_core/espino_id_stage.v`, `espino_if_stage.v`, `espino_register_file.v`,
  `espino_controller.v`, `espino_load_store_unit.v`, `rtl/pochoco_soc.v` y `rtl/asic_top.v`:
  - la ROM de la estrategia 1 es combinacional, así que la instrucción de `pc_q` se conoce un
    ciclo antes de que se cargue en el registro de instrucción; con esa salida el core pide la
    lectura sincrónica del banco de registros y registra las salidas del decodificador en el mismo
    flanco en que se carga la instrucción. Al llegar a la ejecución, operandos y decode ya están
    listos: desaparece el ciclo de espera (`ops_valid_q`) sin volver combinacional el banco de
    registros (eso era B4, `exp/cpi`, que cerraba a 60 ns);
  - el banco de registros gana write-through: la salida registrada toma `wdata` cuando
    `raddr == waddr`, hay escritura y la dirección no es x0;
  - un parámetro del core, `EarlyRead`, permite volver a la temporización anterior. La estrategia 2
    de memoria (flip-flops, lectura registrada) no puede anticipar y usa `EarlyRead = 0`, con lo
    que reproduce exactamente los ciclos y el CPI de `main`;
  - la LSU registra `addr_i[1:0]` al emitir la carga y alinea el dato leído con ese registro (B2),
    lo que saca la ALU de la ruta de alineación y write-back.
- **Configuración del flujo.** La misma de la corrida final: `EXTRA_EXCLUDED_CELLS` con `dly*` y
  `buf_1` (D15, D20), `PL_RESIZER_SETUP_SLACK_MARGIN = 10` (D20), `IO_PIN_ORDER_CFG` con
  `asic/rom/pines.cfg` (D21), `SYNTH_KEEP_HIERARCHY_MODULES` con el banco de registros, la ALU y el
  contador de ciclos (D12), `MemStrategy = 1`, `DataWords = 4` (D9, D17) y `EarlyRead = 1`.
- **Lo que NO lleva.** El banco de registros con latches y clock gating (B5): con la lectura
  anticipada el camino que entra a los latches pierde el medio ciclo de holgura que tenía, y el
  período mínimo pasa de 25,5 a 30 ns (`exp/pipeline-b5`), aunque el área baje a 165.211 µm².
  Tampoco lleva las configuraciones de signoff del frente C que superan el límite de área.

## 3. Criterios del enunciado: `main` contra la candidata

Corridas: `asic/rom/runs/final` y `build/exp_candidata/asic/rom/runs/e1_t100` (o, mientras el
paquete de la rama esté en curso, `build/exp_pipeline_b2/asic/rom/runs/pa_b2_t100`, que es el
mismo RTL y la misma configuración). Las dos a T = 100 ns y `FP_CORE_UTIL` = 40 por ciento.

| Criterio (sección del enunciado) | `main` | candidata | Archivo de origen |
|---|---|---|---|
| Cierra el flujo completo | sí | sí | `final/metrics.json` de cada corrida |
| DRC de Magic | 0 | 0 | `magic__drc_error__count` |
| DRC de KLayout (deck del PDK) | 0 marcadores en 684 reglas | ver sección 6 | `resultados/*/drc_klayout/resumen.md` |
| LVS (Netgen) | 0 | 0 | `design__lvs_error__count` |
| Nets con violación de antena | 0 | 0 | `antenna__violating__nets` |
| Setup WNS / TNS, peor de las 9 esquinas | 65,223 ns / 0 (max_ss) | 63,191 ns / 0 (max_ss) | `cierre.md` |
| Hold WNS / TNS, peor de las 9 esquinas | 0,178 ns / 0 (min_ff) | 0,134 ns / 0 (min_ff) | `cierre.md` |
| Área de celdas estándar (2, 3.3) | 182.265 µm² | 186.432 µm² (+2,3 por ciento) | `design__instance__area__stdcell` |
| Área del die (3.5) | 408.957 µm² (0,409 mm²) | 419.131 µm² (0,419 mm², +2,5 por ciento) | `design__die__area` |
| Celdas estándar | 8.670 | 9.197 (+6,1 por ciento) | `design__instance__count__stdcell` |
| Largo de cables | 352.253 µm | 371.092 µm (+5,3 por ciento) | `route__wirelength` |
| Costo a 23.000 dólares por mm² (3.5) | 9.406 dólares | 9.640 dólares | área del die |
| Frecuencia máxima (3.4) | 40,8 MHz (24,5 ns) | 39,2 MHz (25,5 ns) | `f1_t24p5` y el barrido de la rama |
| CPI de `isa_test.s` | 2,953 | 1,969 | `core_trace_tb` en `make equiv` |
| CPI del juego completo | 2,665 | 1,665 | `game_tb` en `make check` |
| MIPS (Ley de Hierro) | 15,3 | 23,6 | cálculo con las dos filas anteriores |
| Violaciones de max slew / max cap a 100 ns | 546 / 36 | 571 / 37 | `design__max_slew_violation__count` y `__max_cap__` |
| Potencia sin actividad, nom_tt | 8,97 mW | ver sección 6 | `55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt` |
| Potencia con actividad real, nom_tt | 11,5 a 12,8 mW según la fase | no medido (ver sección 6) | `asic/potencia/resultado.md` |
| Simulación post-síntesis (3.7) | PASS, 0 X, con control negativo | PASS, 0 X, con control negativo | `asic/sim/resultado.md` de cada rama |
| Simulación post-PnR con SDF (3.7) | PASS en 3 esquinas, Icarus y CVC | ver sección 6 | `asic/sim/resultado_sdf.md` |
| Utilización máxima que cierra (3.5) | 78 por ciento, die 0,216 mm² | ver sección 6 | `asic/final.md` |

Las violaciones de max slew y de max capacitancia no son criterio de cierre del enunciado; se
informan por la regla de desempate de la sesión. La candidata queda 25 pines peor en slew y 1 en
capacitancia que `main`, por los cables más largos y las celdas nuevas del write-through.

## 4. Regla de selección: todas las opciones medidas

Métrica principal MIPS = f máx / CPI del juego completo. Límite de área de celdas estándar a
100 ns: 105 por ciento de la de `main`, es decir 191.378 µm². Tabla completa, con el barrido de
período de cada opción y su archivo de origen, en `asic/exploraciones.md` (generada por
`asic/tabla_sesion.py`).

| Opción | Rama | T mínimo | f máx | CPI juego | MIPS | Área a 100 ns | Dentro del límite |
|---|---|---|---|---|---|---|---|
| **A + B2 (candidata)** | `exp/pipeline-b2` | 25,5 ns | 39,2 MHz | 1,665 | **23,6** | 186.432 µm² | sí (102,3 por ciento) |
| A solo | `exp/pipeline` | 26 ns | 38,5 MHz | 1,665 | 23,1 | 186.087 µm² | sí (102,1 por ciento) |
| A + B5 | `exp/pipeline-b5` | 30 ns | 33,3 MHz | 1,665 | 20,0 | 165.211 µm² | sí (90,6 por ciento) |
| B2 + B5 con reparación post-GRT | `exp/fmax` | 23,25 ns | 43,0 MHz | 2,665 | 16,1 | 165.358 µm² | sí (90,7 por ciento) |
| B2 + B5 | `exp/fmax` | 23,5 ns | 42,6 MHz | 2,665 | 16,0 | 165.358 µm² | sí |
| B2 solo | `exp/lsu-offset` | 24 ns | 41,7 MHz | 2,665 | 15,6 | 181.170 µm² | sí |
| **`main` (referencia)** | `main` | 24,5 ns | 40,8 MHz | 2,665 | 15,3 | 182.265 µm² | sí (100 por ciento) |
| B5 solo | `exp/rf-latch` | 26 ns | 38,5 MHz | 2,665 | 14,4 | 165.369 µm² | sí |
| B4 (todo en un ciclo) | `exp/cpi` | 60 ns | 16,7 MHz | 1,312 | 12,7 | 158.024 µm² | sí |

Lectura: el único cambio que mueve la métrica principal de verdad es bajar el CPI sin perder
mucho período, y eso es exactamente lo que hace el pipeline del frente A. Las opciones que solo
bajan el período (B2, B5, perillas del flujo) se mueven entre 14,4 y 16,1 MIPS, porque el período
mínimo del diseño actual ya está cerca de su límite; la opción que baja el CPI a 1,3 pero sube el
período a 60 ns (B4) rinde peor que `main`. El desempate por área favorecería a `exp/fmax`
(165.358 µm², 9,3 por ciento menos que `main`), pero la regla de la sesión pone el MIPS primero.

## 5. Verificación de la candidata

Todo desde `build/exp_candidata` (o `build/exp_pipeline_b2`, el mismo RTL), con
`export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH`. Detalle y salidas completas en
`docs/pipeline.md` y `docs/verificacion/` de `exp/pipeline`.

| Prueba | Resultado |
|---|---|
| `make check` | PASS: 80 pruebas del assembler y los seis testbenches, con las dos estrategias de memoria |
| `make equiv MODO=funcional` (`sw/isa_test.s` contra 116fa20) | 46 escrituras al banco, 22 accesos al bus y 2 salidas idénticas, con las dos estrategias |
| `sw/hazard_test.s` (nuevo, 56 comprobaciones) contra `main` | 348 eventos de banco, 63 de bus y 2 de salida iguales, con las dos estrategias |
| Prueba de mutación | `MUTA_FWD` (sin write-through) y `MUTA_LOADUSE` (lectura un flanco antes del commit de la carga) producen trazas distintas y 77 valores X usados; las pruebas las detectan |
| Monitor de valores desconocidos usados | 0 en 620.217 escrituras al banco del juego completo; 0 en `isa_test` y en `hazard_test` |
| `make post-synth` con el netlist de la rama | PASS, 17 cambios de salida, 0 X, más control negativo con `ATRASO = 8` |
| Revisión independiente | ver `docs/revision_frente_a.md` |

Dos consecuencias de la temporización nueva que hay que tener presentes: el display muestra **51**
ciclos medidos en vez de 57 en el escenario de `asic/sim/estimulos.txt` (el lazo de polling pasa de
13 a 8 ciclos), y el atraso mínimo que cambia la traza en el control negativo pasa de 6 a 8 ciclos.
Los estímulos de la rama se recalibraron con `asic/sim/calibrar.py`.

## 6. Paquete de la rama candidata

PAQUETE_PENDIENTE

## 7. Qué cambia en el informe si la candidata pasa a ser la final

| Sección | Qué hay que rehacer |
|---|---|
| 3.1 (del RTL de FPGA al de ASIC) | D3 (lectura sincrónica del banco) sigue válida, pero el banco pasa a tener write-through y el core un parámetro de temporización: hay que decirlo en el párrafo del banco de registros |
| 3.2 (estrategias de memoria) | la comparación de las dos estrategias se rehace con el core nuevo (el CPI de la estrategia 2 no cambia, el de la 1 sí); además la ROM combinacional pasa a ser condición del pipeline, lo que agrega un argumento a D17 |
| 3.3 (síntesis) | área total y por módulo, las cinco celdas más usadas y el conteo de flip-flops cambian (9.197 celdas contra 8.670): hay que regenerar `asic/sintesis.md` y la tabla y el texto de la sección |
| 3.4 (timing) | frecuencia máxima 39,2 MHz en vez de 40,8; barrido de período nuevo; ruta crítica nueva; la subsección de la pre-decodificación (D18) pasa a ser parte de un cambio mayor; la Ley de Hierro y el CPI se vuelven el centro de la sección (15,3 contra 23,6 MIPS) |
| 3.5 (floorplan, utilización y costo) | die 0,419 mm² y costo 9.640 dólares; barrido de utilización nuevo; la comparación con los terminales automáticos (D21) se mantiene pero sus números cambian |
| 3.6 (signoff y layout) | DRC, LVS y antenas siguen limpios, pero las tres figuras del layout (bloques, ruta crítica y slew) se regeneran, y las violaciones de slew pasan a 571 |
| 3.7 (simulación post-síntesis) | el valor que muestra el display pasa de 57 a 51 ciclos medidos, el control negativo de 6 a 8 ciclos de atraso, y la simulación con SDF se repite con el netlist nuevo |
| Decisiones | D18 y D19 (pre-decodificación) quedan contenidas en el cambio nuevo; D22 (ninguna exploración entra en la final) queda reemplazada por D23 |

Figuras que se regeneran: `docs/figuras/periodo.png`, `utilizacion.png`, `construccion.gif` y las
tres de `asic/rom/resultados/<tag>/layout/`.

## 8. Qué cambia en el banco de preguntas de la defensa

Preguntas de `docs/defensa.md` que citan cifras o mecanismos que cambiarían. Cada una hay que
releerla, porque la lista sale de buscar los números y los nombres en el texto:

| Qué cita | Preguntas |
|---|---|
| 25 ns, 40,0 MHz o la frecuencia máxima | 9, 38, 40, 44, 55, 63, 66, 84, 129, 131 |
| CPI 2,953 o 2,665 | 65, 66, 70 |
| la pre-decodificación o `ops_valid_q` | 31, 32, 40, 52, 54, 55, 105, 107, 110 |
| el ciclo de espera o los ciclos por instrucción | 48, 54, 70 |
| la lectura registrada del banco (sin write-through) | 24, 50, 70, 107, 113 |
| 546 slew o 36 capacitancia | 55, 59, 67, 68, 75, 98 |
| área 182.265 o 152.169, o las celdas más usadas | 31, 32, 35, 37, 39, 54, 61, 73, 117 |
| la ruta crítica de `f1_t25` | 38, 40, 42, 84 |
| la simulación post-síntesis (57 ciclos, atraso 6) | 45, 57, 71, 102, 103 |
| la utilización de 70 por ciento y 0,239 mm² | 72, 78, 80 |

Las de la última fila hay que corregirlas igual, adopte o no la candidata: el frente D4 midió que
la utilización máxima que cierra es 78 por ciento y el área mínima 0,216 mm².

Preguntas nuevas que habría que agregar: por qué el write-through es necesario y qué pasa sin él
(la prueba de mutación lo responde), por qué la estrategia 2 no puede anticipar la lectura, por
qué el banco de latches de B5 deja de convenir con este pipeline, y cómo se verificó que el
cambio no altera el comportamiento (hazard_test, mutaciones, monitor de X).

## 9. Riesgos

1. **Tiempo.** Adoptar la candidata obliga a rehacer las secciones 3.3 a 3.7 del informe, las
   figuras y unas 25 respuestas de la defensa, a 14 días de la entrega. Es el riesgo principal.
2. **Superficie que defender.** El cambio introduce un camino de datos nuevo (write-through) y un
   parámetro de temporización (`EarlyRead`) que los tres integrantes tienen que poder explicar,
   incluidos los riesgos de datos y por qué cada uno está resuelto.
3. **Margen de hold.** La candidata cierra con 0,134 ns de hold en la peor esquina contra 0,178 ns
   de `main`: sigue cumpliendo, pero con 25 por ciento menos de margen.
4. **Slew.** 571 pines con violación de max slew contra 546. No es criterio de cierre, pero es un
   número que empeora y que hay que saber explicar (cables más largos, 6 por ciento más de celdas).
5. **La frecuencia máxima baja.** De 40,8 a 39,2 MHz. Si en la defensa se pregunta por la
   frecuencia máxima sin más contexto, la candidata parece peor; el argumento es la Ley de Hierro
   (el tiempo de ejecución es instrucciones por CPI por período, y el producto mejora 54 por
   ciento).
6. **Lo que no se midió.** La potencia con actividad real de la candidata y los puntos del paquete
   que queden abiertos en la sección 6.

## 10. Opciones

Las tres opciones, con sus consecuencias, están en D23 de `docs/decisiones.md`. En resumen:

- **(a) Mantener `main`.** Cero trabajo y cero riesgo; se pierde el 54 por ciento de rendimiento y
  la candidata queda como la exploración principal de la sección 3.4 (igual que el bloque B con
  D22).
- **(b) Adoptar la candidata como corrida final.** Se gana la métrica principal y una sección 3.4
  mucho más rica; cuesta rehacer las secciones 3.3 a 3.7, las figuras y parte de la defensa.
- **(c) Adoptar solo parte.** Por ejemplo solo B2 (período mínimo 24 ns, 15,6 MIPS, menos área) o
  solo la configuración de signoff del frente C: cambios chicos, bien medidos, con poco impacto en
  el informe, pero que casi no mueven la métrica principal.
