# Propuesta: adoptar `exp/candidata` como corrida final (D23)

**Estado: resuelto el 28-10-2026. D23 eligió la opción (b) en su variante `exp/candidata-rc`**, es
decir el RTL de esta propuesta más la configuración del modelo de cable del resizer de la sección
6 bis. El límite de área de celdas de 105 por ciento que esa sección usaba para descartarla era una
regla de selección del grupo, no del enunciado, y se levantó: ver D23 en `docs/decisiones.md` y
`docs/modelo_cable.md`. Este documento se conserva como el análisis que llevó a la decisión; sus
tablas describen `main` v1 (tag `v1-final`) contra la candidata sin modelo de cable, y los números
de la corrida final nueva están en `asic/final.md` y en `docs/datos_informe.md`.

Este documento compara la corrida final de v1 (`main`, tag `v1-final`) con la rama `exp/candidata`
de la sesión del 27 y 28-10-2026, en todos los criterios del enunciado y en las métricas de la
regla de selección de la sesión.

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
a rehacer las secciones 3.3 a 3.7 del informe y a revisar 46 respuestas del banco de la
defensa, de las que unas 25 cambian de cifra, a 14 días de la entrega.** Las tres opciones, con sus consecuencias, están en la
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
  período mínimo pasa de 25,5 a 29 ns (`exp/pipeline-b5`), aunque el área baje a 165.211 µm².
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
| Potencia con actividad real, nom_tt | 11,5 a 12,8 mW según la fase del juego | ver sección 6 | `asic/potencia/resultado.md` |
| Simulación post-síntesis (3.7) | PASS, 0 X, con control negativo | PASS, 0 X, con control negativo | `asic/sim/resultado.md` de cada rama |
| Simulación post-PnR con SDF (3.7) | PASS en 4 esquinas, con Icarus y con CVC | ver sección 6 | `asic/sim/resultado_sdf.md` |
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
| A + B5 | `exp/pipeline-b5` | 29 ns | 34,5 MHz | 1,665 | 20,7 | 165.211 µm² | sí (90,6 por ciento) |
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
| Revisión independiente | APROBADA CON OBSERVACIONES (`docs/revision_frente_a.md`): el revisor reprodujo toda la verificación, escribió 48 comprobaciones de riesgos nuevas (`sw/hazard_review.s`) y 5 de CYCLES, agregó dos mutaciones propias que las pruebas detectan, y verificó número por número las dos tablas del frente sin encontrar diferencias |

Dos consecuencias de la temporización nueva que hay que tener presentes: el display muestra **51**
ciclos medidos en vez de 57 en el escenario de `asic/sim/estimulos.txt` (el lazo de polling pasa de
13 a 8 ciclos), y el atraso mínimo que cambia la traza en el control negativo pasa de 6 a 8 ciclos.
Los estímulos de la rama se recalibraron con `asic/sim/calibrar.py`.

## 6. Paquete de la rama candidata

El frente E le hizo a `exp/candidata` el paquete completo que el informe necesitaría si pasara a
ser la final, con los mismos nombres de archivo que usa `main`: `asic/final.md`,
`asic/sintesis.md`, `asic/sim/resultado*.md`, `asic/rom/resultados/<tag>/`, `docs/datos_informe.md`
(un bloque "Candidata" por sección) y `docs/candidata.md` con las 11 secciones y el origen de cada
número. Son 14 commits en la rama, empujada a `origin`. Las corridas base (`pa_b2_*`) no se
repitieron: el árbol de la rama es idéntico al de `exp/pipeline-b2`, así que esas corridas son las
de la candidata y quedaron enlazadas en `asic/rom/runs/`.

| Paso del paquete | Resultado | Archivo de origen (en la rama) |
|---|---|---|
| Corrida a 100 ns y 40 por ciento | cierra: DRC de Magic 0, LVS 0, antenas 0, setup y hold en las 9 esquinas; 186.432 µm², 102,3 por ciento de `main` | `asic/rom/resultados/pa_b2_t100/cierre.md` |
| Barrido de período con la regla de 0,5 ns | mínimo 25,5 ns (25 ns no cierra por 0,409 ns) | `asic/final.md` |
| Ruta crítica del período mínimo | del PC a la ROM combinacional y de ahí a la dirección de lectura del banco, 24 celdas: es la ruta que crea la lectura anticipada | `asic/rom/resultados/pa_b2_t25p5/layout/ruta_critica.txt` |
| Barrido de utilización | 50, 60, 70, 72, 75 y 78 por ciento cierran; 80 falla en el CTS y 90 en el placement global. Área mínima 0,221 mm² a 78 por ciento (`main`: 0,216 mm²) | `asic/final.md`, `falla.txt` de `e1_u80` y `e1_u90` |
| Las dos estrategias de memoria con el core nuevo | estrategia 2 cierra a 100 ns y su período mínimo empeora a 69,5 ns (`main`: 62 ns), porque el banco write-through alarga también esa ruta, donde la lectura anticipada no se usa | `asic/ff/resultados/e2_*/cierre.md` |
| Síntesis jerárquica | hecha, `asic/sintesis.md` regenerado | `asic/rom/resultados/e1_h100/sintesis_jerarquica.rpt` |
| Figuras del layout | bloques, ruta crítica y slew de la corrida base y de la del período mínimo | `asic/rom/resultados/<tag>/layout/` |
| Simulación post-síntesis | PASS con el netlist propio, control negativo FAIL con `ATRASO = 8`, y `post-synth-final` PASS en 320.000 ciclos con el netlist real | `asic/sim/resultado.md`, `resultado_final.md` |
| Simulación post-PnR con SDF | corrida completa `e1_pnr` que cierra, y trazas idénticas al RTL en `nom_tt`, `max_ss` y `min_ff` | `asic/sim/resultado_sdf.md`, `asic/sim/resultados/e1_pnr/cierre.md` |
| DRC de KLayout con control positivo | 0 marcadores en 684 reglas; el control positivo marca las dos violaciones de Metal1 en sus coordenadas | `asic/rom/resultados/pa_b2_t100/drc_klayout/{resumen.md,control_positivo.md}` |
| Potencia sin actividad (nom_tt) | 8,597 mW, **menos** que los 8,971 mW de `main` | `power.rpt` de la corrida base |
| Potencia con actividad real (ventana de polling, nom_tt) | 12,392 mW contra 11,504 mW de `main` en la misma ventana | `asic/potencia/resultado.md` de la rama |

Variantes de signoff del frente C medidas sobre la candidata, las dos descartadas para el paquete:

- `e1_g30_t100` (márgenes del repair de placement en 30 por ciento): baja las violaciones de slew
  de 571 a 279 por 1,27 por ciento de área, pero **ya no cierra al período mínimo** (a 25,5 ns deja
  -1,422 ns), igual que le pasó al frente C en su rama. Cuesta unos 1,4 MIPS para mejorar un
  criterio que es solo de desempate.
- `e1_full_t100` (RC de cable medidos más reparación post-GRT): llega a **0 violaciones de slew y 0
  de capacitancia** con cierre completo a 100 ns, pero cuesta 209.185 µm², es decir 114,8 por
  ciento del área de `main`, fuera del límite de 105 por ciento. Es la respuesta medida a si las
  546 violaciones de slew de `main` se pueden eliminar: sí, y este es el precio.

**El paquete se queda con la configuración base** de la rama, que es la final de `main` más
`EarlyRead = 1`.

Lo que quedó sin hacer en el paquete, dicho explícitamente: la simulación con Open Verilog CVC de
la rama (el objetivo está copiado pero no se corrió), la potencia con actividad en las otras tres
ventanas y las 9 esquinas, la ruta crítica anotada de las dos variantes de signoff, y los
equivalentes de la corrida con terminales automáticos y del GIF de construcción.

## 6 bis. Por qué la candidata parece 1 ns más lenta: el modelo de cable del resizer

Medición del coordinador, fuera del paquete, para entender la única desventaja de temporización de
la candidata. El frente C mostró que el resizer de OpenROAD estima la capacidad de los cables con
2,3 a 2,9 veces menos de la que extrae OpenRCX del ruteo detallado, y que corregirla con
`LAYERS_RC` (los valores del tech LEF escalados por esquina para que coincidan con la pendiente
medida sobre 2.399 nets) más la reparación post-GRT cambia el período que alcanza el flujo. Corrí
esa misma configuración sobre los dos RTL, en ramas aparte (`exp/candidata-rc` y un worktree
`build/main_rc` de `main`), con los tags `co_rc_*` y `co_rcm_*`:

| corrida | RTL | T (ns) | cierra | WNS setup max_ss (ns) | TNS setup (ns) | hold peor (ns) | área stdcell (µm²) | slew / cap |
|---|---|---|---|---|---|---|---|---|
| `co_rcm_t100` | main | 100 | sí | 65.276 | 0.000 | 0.158 | 201.309 (110,4 por ciento de main) | 2 / 1 |
| `co_rcm_t23` | main | 23 | sí | 0.756 | 0.000 | 0.158 | 212.530 | 0 / 1 |
| `co_rcm_t22` | main | 22 | sí | 0.215 | 0.000 | 0.157 | 214.348 | 0 / 1 |
| `co_rcm_t21p5` | main | 21,5 | **no** | -0.383 | -15.730 | 0.157 | 215.406 | 3 / 1 |
| `co_rc_t100` | candidata | 100 | sí | 65.725 | 0.000 | 0.173 | 208.439 (114,4 por ciento de main) | 0 / 1 |
| `co_rc_t25` | candidata | 25 | sí | 1.579 | 0.000 | 0.173 | 219.531 | 0 / 1 |
| `co_rc_t24` | candidata | 24 | sí | 1.755 | 0.000 | 0.173 | 220.655 | 4 / 1 |
| `co_rc_t23` | candidata | 23 | sí | 1.494 | 0.000 | 0.173 | 222.714 | 4 / 1 |
| `co_rc_t22` | candidata | 22 | sí | 0.656 | 0.000 | 0.173 | 224.767 | 0 / 1 |
| `co_rc_t21p5` | candidata | 21,5 | sí | 0.876 | 0.000 | 0.173 | 231.229 | 0 / 1 |
| `co_rc_t21` | candidata | 21 | **no** | -0.129 | -0.291 | 0.173 | 231.638 | 6 / 1 |
Período mínimo con esta configuración: **22 ns** para el RTL de `main` (45,5 MHz; 21,5 ns no cierra
por 0,383 ns) y **21,5 ns** para el de la candidata (46,5 MHz; 21 ns no cierra por 0,129 ns). Las
dos cierran la regla de 0,5 ns de resolución. Con el CPI de cada uno eso son 17,1 MIPS para `main`
y **27,9 MIPS** para la candidata.


Conclusiones, que valen para el informe aunque esta configuración no pueda ser la final:

1. **La candidata no es más lenta que `main`: con el modelo de cable corregido es medio
   nanosegundo más rápida.** El RTL de `main` cierra a 22 ns y el de la candidata a 21,5 ns, las
   dos con la regla de 0,5 ns cerrada, y a 23 ns la candidata tiene el doble de margen (1,494
   contra 0,756 ns). Con el CPI de cada uno eso son 17,1 contra 27,9 MIPS. El nanosegundo de
   diferencia de la configuración del enunciado (25,5 contra 24,5 ns) lo produce el resizer, que
   con parásitos optimistas deja de reparar antes en el diseño con la ruta nueva.
2. **Esta configuración no puede ser la corrida final**: cuesta 110,4 por ciento del área de
   `main` sobre el RTL de `main` y 114,4 por ciento sobre el de la candidata, las dos por encima
   del límite de 105 por ciento de la regla de selección. Por eso ni `main` ni la candidata la
   usan, y el período mínimo que se reporta sigue siendo el de la configuración del enunciado.
3. Como efecto secundario, la misma configuración deja 0 violaciones de max slew en las 9 esquinas
   en los dos diseños, lo que confirma el diagnóstico del frente C: las violaciones de slew de la
   corrida final no son un problema del diseño sino del modelo con que el flujo decide dónde
   poner buffers.

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
   figuras y 46 respuestas de la defensa (unas 25 cambian de cifra), a 14 días de la entrega.
   Es el riesgo principal.
2. **Superficie que defender.** El cambio introduce un camino de datos nuevo (write-through) y un
   parámetro de temporización (`EarlyRead`) que los tres integrantes tienen que poder explicar,
   incluidos los riesgos de datos y por qué cada uno está resuelto.
3. **Margen de hold.** La candidata cierra con 0,134 ns de hold en la peor esquina contra 0,178 ns
   de `main`: sigue cumpliendo, pero con 25 por ciento menos de margen.
4. **Slew.** 571 pines con violación de max slew contra 546. No es criterio de cierre, pero es un
   número que empeora y que hay que saber explicar (cables más largos, 6 por ciento más de celdas).
5. **La frecuencia máxima baja.** De 40,8 a 39,2 MHz con la configuración del enunciado. Si en la
   defensa se pregunta por la frecuencia máxima sin más contexto, la candidata parece peor; hay dos
   argumentos: la Ley de Hierro (el tiempo de ejecución es instrucciones por CPI por período, y el
   producto mejora 54 por ciento) y la medición de la sección 6 bis (con un modelo de cable
   realista la candidata cierra a 21,5 ns y `main` a 22, o sea que la desventaja es de la
   herramienta).
6. **Integración con main (lo señaló la revisión independiente, O1).** La rama salió de `main` el
   27-10 y desde entonces `main` avanzó: el único archivo que tocan los dos lados es el `Makefile`,
   y la versión de la rama borra lo que agregó el frente D1 (`post-pnr-cvc`, la regla de
   `asic/sim/config_pnr.yaml`). Además `main` cambió `tb/post_synth_tb.v` y la rama no, así que el
   `make post-synth` PASS de la rama se obtuvo con el testbench anterior. Antes de adoptarla hay
   que rebasar la rama sobre `main`, mezclar el `Makefile` a mano (quedarse con el de `main` y
   agregarle `PROG`, `ATRASO ?= 8` y `POLL_CICLOS ?= 8`) y volver a correr `make check` y
   `make post-synth`. Es el único trabajo de verificación que queda pendiente de verdad.
7. **`illegal_insn_o` queda desfasado una instrucción** con la lectura anticipada (O3 de la
   revisión): hoy es inocuo porque la señal no se usa en ninguna parte (no hay trap), pero si
   alguien agregara uno apuntaría a la instrucción equivocada. Hay que registrarla con el resto
   del decode o dejarlo comentado en el RTL.
8. **Lo que no se midió.** La potencia con actividad real de la candidata y los puntos del paquete
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
