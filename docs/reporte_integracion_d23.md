# Reporte de la integración de D23: la corrida final pasa a exp/candidata-rc

Sesión del 28-10-2026. Este documento es el reporte de la integración: qué se hizo, qué quedó
medido, qué falló y qué quedó incompleto. Cada cifra tiene su archivo de origen. "v1" es `main`
antes de integrar, marcado con el tag `v1-final`.

## 1. Decisión y fecha de corte

D23 quedó resuelta en `docs/decisiones.md` con **"Elegida: (b), variante `exp/candidata-rc`"** y la
razón textual del coordinador: "Representa una ganancia en frecuencia y MIPS considerable, tomando
en consideración el área sacrificada."

Quedó registrado ahí mismo que **el límite de 105 por ciento del área de celdas estándar era una
regla de selección del grupo y no del enunciado**, y por qué se levanta: el área del die no cambia
(419.131 µm², los mismos de la candidata sin modelo de cable) y el costo estimado tampoco
(9.640 dólares); lo único que sube es la utilización real del core, de 47,9 a 53,5 por ciento
(`design__instance__utilization` de `asic/rom/resultados/{v1_final,final}/metrics.json` y de
`build/exp_candidata/asic/rom/runs/pa_b2_t100/final/metrics.json`).

**Fecha de corte: 1-11-2026 a las 23:59.** No hizo falta usarla: la `candidata-rc` integrada cumple
todas las verificaciones y cierra. Las dos vueltas atrás quedan documentadas y disponibles:

1. `exp/candidata` con la configuración anterior (25,5 ns, 23,6 MIPS, 186.432 µm²);
2. `main` v1, tag `v1-final`, commit `d881583` (24,5 ns, 15,3 MIPS, 182.265 µm²).

## 2. Estado de cada verificación

Las 15 comprobaciones de la integración, con su salida completa, están en
`docs/verificacion/integracion.md` y en los `docs/verificacion/integracion_*.txt`. **Todas en
verde.**

| # | Verificación | Resultado |
|---|---|---|
| 1 | `make check` (80 pruebas del assembler y los seis testbenches, las dos estrategias) | **PASS**, código 0 |
| 2 | `make equiv MODO=funcional` contra `116fa20` | **equivalente** en las dos estrategias: rf 46, bus 22, io 2 |
| 3 | `make equiv PROG=isa_test REF=v1-final MODO=funcional` | **equivalente** en las dos estrategias |
| 4 | `make equiv PROG=hazard_test REF=v1-final MODO=funcional` (56 comprobaciones) | **equivalente**: rf 348, bus 63, io 2 |
| 5 | `make equiv PROG=hazard_review REF=v1-final MODO=funcional` (48 comprobaciones de la revisión) | **equivalente**: rf 271, bus 66, io 2 |
| 6 | `make equiv PROG=hazard_cycles REF=v1-final MODO=funcional` | difiere **a propósito** en el valor de CYCLES (evento 3 del banco); bus 10 e io 2 idénticos; con la estrategia 2, todo idéntico |
| 7 | Mutación `MUTA_FWD` (banco sin write-through) | **detectada**: trazas distintas y 77 valores X usados |
| 8 | Mutación `MUTA_LOADUSE` (lectura un flanco antes del commit de la carga) | **detectada**: difieren banco, bus y salidas |
| 9 | Las dos mutaciones contra `hazard_review.s` | **detectadas** (63 y 679 X usados) |
| 10 | Monitor de valores desconocidos usados | **0** en 620.217 escrituras al banco del juego completo, y 0 en todos los programas de prueba |
| 11 | `make post-synth` con `tb/post_synth_tb.v` de `main` | **PASS**: trazas idénticas, 17 cambios de salida, 0 X |
| 12 | `make post-synth-control` | **FAIL de la comparación, que es lo que el objetivo exige** |
| 13 | `make post-synth-final` (320.000 ciclos con el netlist real) | **PASS**: 3 líneas idénticas, 0 X |
| 14 | Recalibración de `asic/sim/estimulos.txt` | **sin cambios**: el calibrador regenera el mismo archivo byte a byte |
| 15 | Origen de `LAYERS_RC` | **reproduce**: `asic/modelo_cable.py` deriva los 15 pares del bloque desde la extracción y lo verifica contra la configuración (código 0) |

La observación O1 de `docs/revision_frente_a.md` (el `Makefile` y `tb/post_synth_tb.v` de la rama
estaban atrasados) queda cerrada: el `Makefile` se mezcló solo, conservando lo que agregó `main`
(`post-pnr-cvc`, la regla de `asic/sim/config_pnr.yaml`, `LIBRELANE` con `--docker-no-tty`) y lo que
agregó la rama (`PROG`, `ATRASO = 8`, `POLL_CICLOS = 8`), y `tb/post_synth_tb.v` quedó en la versión
de `main`, con la que se volvieron a correr `make check` y `make post-synth`.

## 3. Cierre de la corrida final

`asic/rom/resultados/final/cierre.md`: **CIERRA**.

| criterio | valor | v1 |
|---|---|---|
| DRC de Magic | 0 | 0 |
| DRC de KLayout con el deck del PDK | 0 marcadores en 684 reglas, con control positivo que marca las dos violaciones inyectadas | 0 en 684 |
| LVS (Netgen) | 0 | 0 |
| Nets con violación de antena | 0 (con 1 diodo de antena insertado) | 0 (0 diodos) |
| Setup WNS / TNS, peor de las 9 esquinas | 65,725 ns / 0 (`max_ss_125C_4v50`) | 65,223 / 0 |
| Hold WNS / TNS, peor de las 9 esquinas | 0,173 ns / 0 (`min_ff` y `nom_ff`; en `max_ss` 1,065 ns) | 0,178 / 0 |
| Área de celdas estándar | 208.439 µm² | 182.265 |
| Área del die | 419.131 µm² (0,419 mm²; 638,505 x 656,425 µm) | 408.957 (0,409) |
| Utilización real del core | 0,535 | 0,480 |
| Celdas estándar / flip-flops | 9.928 / 964 | 8.670 / 990 |
| Largo de cables | 377.509 µm | 352.253 |
| Violaciones de max slew / max cap / max fanout | **0** / 1 / 21 | 546 / 36 / 62 |
| Potencia sin actividad, `nom_tt` | 9,620 mW | 8,971 |
| Costo a 23.000 dólares por mm² | 9.640 dólares | 9.406 |

## 4. Período mínimo y MIPS

**Período mínimo 21,5 ns, frecuencia máxima 46,5 MHz, CPI del juego 1,665, 27,9 MIPS.**

- `f2_t21p5` cierra todo con WNS de setup 0,876 ns y TNS 0 en `max_ss_125C_4v50`
  (`asic/rom/resultados/f2_t21p5/cierre.md`).
- `f2_t21` no cierra por 0,129 ns (TNS -0,291 ns, `asic/rom/resultados/f2_t21/cierre.md`), así que
  **la regla de la sesión de dejar 0,5 ns o menos entre el último período que cierra y el primero
  que no queda cerrada**.
- f máx = 1 / 21,5 ns = 46,51 MHz. CPI del juego completo = 1.595.814 ciclos / 958.358 instrucciones
  retiradas = 1,665 (`docs/verificacion/integracion_01_make_check.txt`). MIPS = 46,51 / 1,665 =
  27,9.
- En v1: 24,5 ns, 40,8 MHz, CPI 2,665 y 15,3 MIPS. **El MIPS sube un 82 por ciento.**

## 5. Las tablas de los puntos 3 y 4 del encargo

Están generadas por scripts, con el archivo de origen de cada fila:

| tabla | archivo | la genera |
|---|---|---|
| Corrida final y los barridos de período y de utilización | `asic/final.md` | `bash asic/tablas.sh` |
| Evolución del rendimiento etapa por etapa, con el reparto del aumento de MIPS entre el RTL y el flujo | `asic/evolucion.md` | `python3 asic/evolucion.py --md asic/evolucion.md` |
| Rutas críticas por tramos y el cálculo del tiempo requerido | `asic/rutas.md` | `bash asic/rutas.sh` |
| Área por módulo, celdas más usadas y comparación con lo esperado | `asic/sintesis.md` | `python3 asic/analisis_sintesis.py` |
| Tabla de la sesión con todas las ramas y variantes | `asic/exploraciones_tabla.md` | `python3 asic/tabla_sesion.py asic/ramas_sesion.json` |
| Modelo de cable: regresión y bloque `LAYERS_RC` | `asic/modelo_cable.md` | `python3 asic/modelo_cable.py` |
| Potencia con actividad real, 4 ventanas y 9 esquinas | `asic/potencia/resultado.md` y `resultados/tablas.md` | `bash asic/potencia/correr.sh todo` |

## 6. La violación de capacitancia que queda

Un solo pin, el mismo en las nueve esquinas: **`clkbuf_0_clk/Z`, la raíz del árbol de reloj**, un
`clkbuf_16` que insertó `OpenROAD.CTS` por `CTS_ROOT_BUFFER`. Maneja 0,428234 pF contra un límite de
0,2 pF, es decir -0,228234 pF de slack en `max_ss_125C_4v50` (0,401561 y -0,201561 en `nom_tt`).

- **La causa**: el límite de 0,2 pF es `MAX_CAPACITANCE_CONSTRAINT` del flujo, aplicado con
  `set_max_capacitance` a todos los pines; el límite propio de la celda en el liberty de la esquina
  lenta es **3,93 pF**, o sea que maneja nueve veces menos de lo que puede. Y `repair_design` no toca
  la red de reloj, así que ni el repair del placement ni el nuevo del post-GRT la pueden arreglar.
- **Se puede quitar, pero no sin costo.** Un buffer de raíz más grande no sirve (lo que sobra es la
  carga, no el drive). Repartir la carga con un nivel más de árbol de reloj sí la quitaría, a costa
  de más buffers de reloj, más área y más latencia de inserción, que es exactamente lo que la
  corrida final ya pagó una vez (172 buffers de reloj contra 110 en v1, y la potencia del reloj de
  3,709 a 4,592 mW). Relajar la restricción la haría desaparecer del reporte sin cambiar el
  circuito. La decisión es dejarla y explicarla.
- Análisis completo en `docs/datos_informe.md` sección 3.6 y en
  `asic/rom/resultados/final/avisos.md`, aviso 4.

## 7. Qué falló

1. **`u2_u74`, `u2_u75`, `u2_u78`, `u2_u80` y `u2_u90` no completan el flujo**, y es el resultado
   esperado del barrido de utilización: a partir de cierto punto no hay espacio para legalizar lo
   que agregan los pasos de reparación. **La utilización máxima que cierra es 73 por ciento**
   (`u2_u73/cierre.md`: CIERRA, die 235.237 µm²), y como 74 es la primera que falla, la resolución
   del barrido queda en 1 punto. Las cinco fallan antes del ruteo detallado, en pasos distintos y
   por eso vale anotarlo: `u2_u74` y `u2_u75` en `OpenROAD.RepairDesignPostGRT` (paso 41, el que
   agrega D23), con 18 y 77 instancias sin lugar; `u2_u78` en `OpenROAD.CTS` (paso 35) con 36;
   `u2_u80` en `OpenROAD.RepairDesignPostGPL` (paso 32) con 5, las cuatro con
   `[DPL-0036] Detailed placement failed`; y `u2_u90` en el placement global con
   `[GPL-0301] Utilization 100.620 % exceeds 100%`. Extractos versionados en
   `asic/rom/resultados/u2_u*/falla.txt`; el de `u2_u75` se corta en 40 líneas, así que su línea de
   error está en `asic/logs/u2_u75.log` 18737.
2. **La equivalencia formal por `eqy` perdió una partición respecto de v1.** Prueba 29 de sus 30
   particiones contra los dos netlists y deja sin decidir la grande (`asic_top.led.0`). La causa está
   medida y es estructural, no un error del diseño: el RTL tiene 44 bits de registro que el netlist
   no tiene (27 más que en v1), porque con la lectura anticipada el decodificador trabaja sobre la
   salida de la ROM y la síntesis elimina los bits del registro de instrucción que ya nadie lee; eqy
   prueba cada partición para todo estado inicial, incluidos los inalcanzables, y `pdr` encuentra uno
   en que los bits 20 y 21 del PC difieren. **Ese estado no se alcanza desde reset** (el programa
   ocupa 115 palabras y el PC nunca pasa de 0x1CC). La equivalencia sí queda probada, por el flujo
   clásico de Yosys (976 de 976 celdas `$equiv`, inducción que cierra en el paso 3) y por el miter
   completo desde reset. Detalle en `docs/equivalencia.md`, secciones 4.5, 5.5 y 6.
3. **El control negativo de la equivalencia cambió de método.** La mutación de una celda de la ALU
   ya no la detecta `eqy` (cae dentro de la partición que no se decide) ni el BMC de 24 pasos (el
   acarreo del bit 30 del sumador no se ejercita tan pronto). Sí la detecta el flujo clásico, que
   deja 200 de 976 celdas sin probar contra 0 en el netlist sin mutar. Queda informado en
   `docs/equivalencia.md`, sección 5.2.
4. **Un detalle de operación, sin consecuencia en los resultados**: al mover el log de la corrida
   final de v1 se truncó `asic/logs/final.log` mientras la corrida nueva escribía en él. `asic/logs/`
   no está versionado y los reportes de v1 estaban ya copiados a `asic/rom/resultados/v1_final/`, así
   que no se perdió nada que el informe use; el log de la corrida nueva quedó completo.

5. **El empuje forzado de `exp/candidata-rc` quedó denegado por el permiso de la sesión.** El rebase
   sobre `main` reescribe los hashes de la rama, así que actualizarla en `origin` pedía
   `git push --force-with-lease`, y el clasificador de permisos lo rechazó. La rama rebasada se
   empujó con otro nombre, `exp/candidata-rc-rebasada`, y `origin/exp/candidata-rc` sigue apuntando
   al commit anterior al rebase (`297c5fe`, el mismo que guarda el tag `candidata-rc-pre-rebase`).
   No afecta a nada medido: lo que se mezcló en `main` es la rama rebasada y los dos estados siguen
   alcanzables. Para mover `exp/candidata-rc` en su lugar hace falta autorizar el empuje forzado.

## 8. Corridas incompletas

Hay que separar dos cosas distintas: las que **fallaron** (el flujo se detuvo con error) y las que
quedaron **incompletas por tiempo** (la cola las cortó a los 40 minutos).

**Fallaron cinco**, todas del barrido de utilización, y es el resultado que el barrido busca: son
las del punto 7.1.

**Quedaron incompletas por tiempo tres corridas** (cuatro intentos), todas registradas en `asic/logs/detenidas.txt`:

| corrida | cuándo | hasta dónde llegó | qué significa |
|---|---|---|---|
| `pa_b5_t28` | 28-10 07:41 | `OpenROAD.ResizerTimingPostCTS` | exploración B5 (banco de registros con latches) en `exp/pipeline-b5`; la rama no entró en la corrida final, así que no afecta a ningún número del informe. Queda dicho en `docs/pipeline.md` 5.1 |
| `pa_b5_t28p5` | 28-10 08:41 | el mismo paso | lo mismo: por eso la regla de 0,5 ns queda **abierta** en el barrido de B5, y así está informado |
| `s4_t30` y su repetición `s4_t30_b` | 29-10 01:53 y 02:34 | `OpenROAD.ResizerTimingPostGRT` (paso 44 de 78) | el punto de 30 ns de la estrategia 2. La primera vez competía por CPU con otras dos corridas; la segunda corrió **sola** y la cortó igual: solo el paso 37 (`ResizerTimingPostCTS`) se lleva 1.301 s, y al cortarse el resizer todavía iba en WNS -0,276 ns con 21 puntos en violación. Evidencia en `asic/ff/resultados/s4_t30_b/falla.txt` |

La consecuencia del último caso es la única que toca un número del informe, y hay que decirla tal
cual: **el período mínimo de la estrategia 2 que esta sesión pudo medir es el de `s4_t32`** (32 ns,
31,25 MHz, WNS 1,807 ns), y el punto de 30 ns no se midió porque la corrida no cabe en el corte de
40 minutos de la cola. No es que no cierre: es que no se sabe. La propia corrida de 32 ns tardó
40 min 8 s, así que el corte es el límite práctico de lo que esta sesión puede medir en la
estrategia 2.

## 9. Disco y memoria

La cola revisa memoria y disco antes de lanzar cada corrida y lo anota en
`asic/logs/cola_estado.txt`, en la misma línea del lanzamiento (`usados=<MB> libre=<GB>
disco=<GB>`). Ninguna corrida se saltó ni se mató por esas guardas en esta sesión.

| qué | cuánto | de dónde |
|---|---|---|
| Disco del sistema de archivos | 1.007 GB en total, 355 GB usados, 602 GB libres (38 %) | `df -h .` |
| El repositorio completo con todo lo generado | 329 GB | `du -sh .` |
| Corridas de LibreLane de la estrategia 1 (`asic/rom/runs`) | 70 GB | `du -sh` |
| Corridas de la estrategia 2 (`asic/ff/runs`) | 79 GB | `du -sh` |
| Árboles de trabajo de las ramas de exploración (`build/`) | 179 GB | `du -sh` |
| Lo que sí está versionado de las corridas (`asic/rom/resultados` y `asic/ff/resultados`) | 20 MB y 3,9 MB | `du -sh` |

El reparto importa para reproducir: de los 329 GB, **solo 24 MB están en git**. Los
`asic/*/resultados/<tag>/` guardan de cada corrida el `metrics.json`, los reportes de STA, el
`cierre.md` y, cuando falla, el extracto `falla.txt`; el resto (los `runs/`, los ODB, los GDS, los
VCD) se puede volver a generar con la configuración versionada y no se sube.

## 10. Commits y tags

La sesión dejó **50 commits en `main`** sobre el tag `v1-final`, uno por hito
(`git log --oneline v1-final..HEAD`). Todas las referencias están en `origin`, confirmado con
`git ls-remote origin` (los dos tags son anotados, así que `ls-remote` imprime el hash del objeto de tag y no el del commit; la tabla da los dos):

| referencia | commit en `origin` | qué es |
|---|---|---|
| rama `main` | la punta de la sesión | la integración y todo el trabajo; el `git ls-remote` del cierre está al final de esta sección |
| tag `v1-final` | `f868867` (tag anotado; apunta al commit `d881583`) | `main` antes de integrar: el estado al que se vuelve en la segunda vuelta atrás |
| tag `candidata-rc-pre-rebase` | `968ab00` (tag anotado; apunta al commit `297c5fe`) | `exp/candidata-rc` antes del rebase, para que los hashes que citan los documentos sigan alcanzables |
| rama `exp/candidata-rc-rebasada` | `90a3efd` | la rama rebasada tal como se mezcló en `main` (es el segundo padre del merge `d974a9f`) |
| rama `exp/candidata-rc` | `297c5fe` | quedó en el commit anterior al rebase: ver el punto 7.5 |

Los hitos de la integración, en orden:

| commit | hito |
|---|---|
| `d974a9f` | merge `--no-ff` de `exp/candidata-rc` en `main` |
| `71fe7a0` | la configuración final de D23 pasa a `asic/rom/config.yaml` |
| `6d4382e` | el origen del modelo de cable queda reproducible (`asic/modelo_cable.py`) |
| `c926425` | la corrida final nueva cierra y las 15 verificaciones quedan en verde |
| `236da63` | ruta crítica por tramos y tabla de evolución del rendimiento |
| `38981bf` | potencia con actividad real comparada contra v1 y contra la candidata |
| `217f7b7` y `8844ca5` | equivalencia formal del diseño nuevo, completa |
| `289dd44` | SDF en tres esquinas con Icarus y con CVC sobre `d2_pnr` |
| `04fa633` | `docs/hechos_flujo.md` reescrito como acta de la corrida final nueva |
| `1858fb9` | barridos de utilización y de `pr_*` completos |
| `7dd2fb4` | `docs/cambios_informe.md`, sección por sección y pregunta por pregunta |
| `daacad5` | `docs/cambios_informe.md` rehecho con la revisión adversaria (14 + 29 correcciones) |
| `5914024` | `pr_t22p5` cierra: B2 vale 1 ns, no 1,5 |
| `f88ecbb` | el barrido de la estrategia 2 llega a 32 ns |

Un commit no puede registrar su propio hash, así que la comprobación de que todo está en `origin`
va aparte. Al cerrar la sesión, con el árbol de trabajo limpio (`git status --porcelain` vacío) y
`main` empujado:

```
$ git ls-remote origin refs/heads/main refs/tags/v1-final refs/tags/candidata-rc-pre-rebase \
      refs/heads/exp/candidata-rc refs/heads/exp/candidata-rc-rebasada
297c5fe1d71c983e87abde7859842c9cdb2e652a	refs/heads/exp/candidata-rc
90a3efd1a1448dcc61e3d3df54eedefd5b764129	refs/heads/exp/candidata-rc-rebasada
2a4b4668c9a366f1205ec576a697ef8169cc2024	refs/heads/main
968ab00723bc96f97c7ab630333793408e07ca9d	refs/tags/candidata-rc-pre-rebase
f868867ed54b1e8aac4361e771daec6e6553cd5c	refs/tags/v1-final
$ git rev-parse HEAD
2a4b4668c9a366f1205ec576a697ef8169cc2024
```

`2a4b466` es el commit que dejó esta sección al día; después de él solo va el que agrega este
bloque, que se empuja igual.
