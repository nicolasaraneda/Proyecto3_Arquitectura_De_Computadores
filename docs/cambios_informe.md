# Qué cambia en el informe y en la defensa por la corrida final de D23

Este documento es la lista de trabajo para actualizar `informe/main.tex` y `docs/defensa.md`, que no
se tocan desde acá. Tiene dos partes:

1. **El informe**, sección por sección: cada cifra, tabla y figura que cambia, con el valor viejo, el
   nuevo y el archivo de origen de los dos.
2. **La defensa**, pregunta por pregunta, más las preguntas nuevas que hay que agregar, con su
   respuesta completa.

Qué es la corrida final de D23: el RTL del pipeline (lectura del banco de registros y decodificación
durante el fetch con el parámetro `EarlyRead`, banco write-through y el offset de byte de la carga
registrado en la LSU) más la configuración del modelo de cable del resizer (`LAYERS_RC` con los RC
medidos por extracción) y la reparación después del ruteo global. La decisión está en D23 de
`docs/decisiones.md`, el análisis que llevó a ella en `docs/propuesta_d23.md`, el mecanismo del core
en `docs/pipeline.md` y el del modelo de cable en `docs/modelo_cable.md`. "v1" quiere decir `main`
antes de integrar, tag `v1-final`, con sus reportes en `asic/rom/resultados/v1_final/`.

Las tres cifras que resumen el cambio, para tenerlas a mano al leer el resto:

| | v1 | corrida final de D23 |
|---|---|---|
| Período mínimo que cierra todo | 24,5 ns (40,8 MHz) | **21,5 ns (46,5 MHz)** |
| CPI del juego completo y MIPS | 2,665 y 15,3 | **1,665 y 27,9** |
| Área de celdas a 100 ns, die y violaciones de slew | 182.265 µm², 0,409 mm², 546 | **208.439 µm², 0,419 mm², 0** |

El estado de cada verificación de la integración está en `docs/verificacion/integracion.md` y el
reporte completo de la sesión en `docs/reporte_integracion_d23.md`.

---

# Cambios del informe por la corrida final de D23

El informe es un solo archivo LaTeX, `informe/main.tex`, de 441 líneas, sin `\input` ni
`\include`: una introducción sin numerar (la sección 2 del enunciado, con la Tabla 1) y siete
secciones numeradas que corresponden a 3.1 a 3.7 (`\section` en las líneas 63, 102, 135, 191, 317,
365 y 414). Lleva 13 tablas y 4 `\includegraphics` (tres figuras distintas). Con la corrida final de
D23 (el RTL del pipeline con lectura del banco y decodificación en el fetch, `EarlyRead = 1`, banco
write-through y el offset de byte de la carga registrado en la LSU, B2, más el modelo de cable del
resizer, `LAYERS_RC`, y la reparación después del ruteo global) cambia al menos una cifra en 10 de
las 13 tablas, se rehacen completas 7 (`tab:estrategias`, `tab:celdas`, `tab:modulos`, `tab:barrido`,
`tab:ruta`, `tab:util`, `tab:sim`), cambian solo dos celdas en 1 (`tab:cierre`), se agregan o
corrigen filas en 2 (`tab:predeco`, `tab:otros`), quedan intactas 3 (`tab:fpga`, `tab:palabras`,
`tab:antena`) y hay 13 párrafos cuyo argumento, no solo su número, deja de ser cierto.

De las tres figuras incluidas, dos se regeneran y las dos ya están regeneradas (`bloques.png` de la
corrida final, del 28-10-2026 20:22, y `utilizacion.png`, del 28-10-2026 20:57) y una no se regenera
(las dos imágenes de la antena de la estrategia 2, que son evidencia histórica). `utilizacion.png`
hay que volver a generarla, pero no porque sea de v1: se generó cuando del barrido `u2_*` solo había
terminado `u2_u50` (`u2_u50` terminó a las 20:55:57 y `u2_u60` a las 20:58:48,
`asic/logs/cola_estado.txt`).

Conviene separar tres clases de cambio, porque se justifican distinto ante el lector:

- **(a) Correcciones de v1 que valen de todos modos.** Las midió el frente D4 el 27-10-2026
  (`docs/progreso.md`, fila "D4: barridos finos de `main`"; `u1_u78` y `f1_t24p5` corrieron ese día,
  `asic/logs/cola_estado.txt`, entradas 4 y 5) y el `.tex` nunca las recogió: el período mínimo de
  `main` antes de integrar es **24,5 ns** y no 25 (`f1_t24p5` cierra con WNS 0,496 ns), es decir
  **40,8 MHz y 15,3 MIPS** y no 40 MHz y 15,0 MIPS; y la utilización máxima que cierra es **78 %**,
  con un die mínimo de **215.545 µm² (0,216 mm²)**, no 70 % y 0,239 mm². Hay que corregirlas incluso
  si se volviera atrás a v1 (D23, sección "Fecha de corte y vueltas atrás"). Fuente: `asic/final.md`,
  secciones "Historia: la corrida final de v1 y su barrido de período" (líneas 63 y 74) e "Historia:
  barrido de FP_CORE_UTIL de v1 a 100 ns" (línea 105).
- **(b) Cambios por el RTL nuevo.** Afectan todo lo de síntesis y el CPI, y son independientes del
  flujo: área de síntesis aplanada 152.169 a 156.098 µm², jerárquica 157.980 a 164.605, register
  file 73.656 a 80.349, flip-flops 990 a 964, el orden de las cinco celdas más usadas (`dffq_1`
  deja de ser la primera) y el CPI del juego 2,665 a 1,665.
- **(c) Cambios por la configuración del flujo nueva.** Solo actúan en el place and route: área de
  celdas tras PnR 182.265 a 208.439 µm², período mínimo 24,5 a 21,5 ns (46,51 MHz, 27,9 MIPS),
  WNS de setup 65,223 a 65,725 ns, hold 0,178 a 0,173 ns y, sobre todo, **546 violaciones de max
  slew que pasan a 0** y 36 de max capacitancia que pasan a 1.

El tag de la corrida final sigue siendo `final` y sus reportes siguen en
`asic/rom/resultados/final/`, así que las citas de archivo de las líneas 42, 58, 406, 407 y 411 no
cambian de ruta: cambia su contenido. "v1" quiere decir `main` antes de integrar, tag `v1-final`,
con sus reportes en `asic/rom/resultados/v1_final/`.

Un detalle de redacción que también queda viejo: la línea 40 dice "las decisiones se citan con su
número en `docs/decisiones.md` (D1 a D22)", y con D23 agregada (`docs/decisiones.md`, línea 164) hay
que escribir D1 a D23.

**Aviso sobre `asic/final.md`.** Ese archivo se generó el 28-10-2026 a las 20:57 y quedó atrasado:
su tabla de `f2_*` marca `f2_t30` como "incompleta" (terminó a las 21:03:30) y su tabla de `u2_*`
solo tiene `final` y `u2_u50`, con `u2_u60` y `u2_u70` como "incompletas". Para las filas nuevas del
barrido de período y del de utilización hay que citar los `metrics.json` y los `cierre.md` de cada
corrida, o `docs/datos_informe.md` (regenerado el 29-10-2026 a las 00:38), no `asic/final.md`.

## Resumen: qué se rehace y qué no

| tabla o figura | líneas del `.tex` | qué le pasa | archivo de origen del valor nuevo |
|---|---|---|---|
| Tabla 1 `tab:cierre` (criterios de cierre) | 44-60 | **cambian 2 de las 6 filas**: setup WNS 65,22 a 65,725 ns y hold WNS 0,18 a 0,173 ns. Las cuatro de DRC de Magic, DRC de KLayout, LVS y antenas siguen en 0, y la peor esquina no cambia: setup en `max_ss_125C_4v50` y hold en `min_ff_n40C_5v50` (0,173 ns, empatada con `nom_ff_n40C_5v50`) | `asic/rom/resultados/final/cierre.md` y `drc_klayout/resumen.md` ("0 marcadores en 0 reglas, de 684 reglas evaluadas") |
| Tabla 2 `tab:fpga` (construcciones de FPGA) | 71-90 | **intacta**: evidencia histórica de c0a, c0b y c0c sobre el RTL del Proyecto 2 (commit `1227fa5`) | `asic/p2_original/evidencia/` (sin cambios) |
| Tabla 3 `tab:estrategias` (estrategia 1 contra 2) | 112-130 | **se rehace completa**; las 8 filas salen de corridas `s1_*`/`s2_*` con el RTL viejo. Las corridas nuevas **ya están hechas**: `s3_t100` (estrategia 1, terminada con código 0 el 28-10-2026 21:55) y `s4_t100`, `s4_t65`, `s4_t60`, `s4_t55`, `s4_t50` (estrategia 2 con `asic/ff/config_final.yaml`, todas código 0 entre 22:12 y 22:41). Por medir: el período mínimo de la estrategia 2, porque `s4_t50` todavía cierra con WNS 6,939 ns y `s4_t45`, `s4_t42` y `s4_t40` quedaron encoladas el 29-10-2026 a las 00:32 (entradas 156 a 158) | `asic/rom/resultados/s3_t100/{metrics.json,cierre.md,sintesis_stat.rpt}` y `asic/ff/resultados/s4_*/{metrics.json,cierre.md,sintesis_stat.rpt}`; `asic/ff/resultados/LEEME.md` dice por qué la fuente de la estrategia 2 son las `s4_*` y no `e2_t100` |
| Tabla 4 `tab:celdas` (cinco celdas más usadas) | 141-160 | **se rehace completa**: cambian las cinco filas, el orden y el pie (la quinta celda ya no es `clkinv_1` sino `aoi21_1`; el total pasa de 5.118 celdas de 34 tipos a 5.577 de 36, y el reparto por módulo de `h2_t100` a `h3_t100`) | `asic/sintesis.md`, sección "Las 5 celdas más usadas de la corrida final" |
| Tabla 5 `tab:modulos` (área por módulo) | 162-184 | **se rehace completa**: cambian 3 áreas de módulo (register file 73.656 a 80.349, `espino_id_stage` 29.765 a 29.589, LSU 2.711 a 2.819), el total (157.980 a 164.605) y 8 de los 10 porcentajes; la LSU queda en 1,7 % y la fila de bus, sincronizador de reset y control no cambia ni en área (1.470 µm²) ni en porcentaje (0,9 %). También cambia el tag del pie, de `h2_t100` a `h3_t100` | `asic/sintesis.md`, sección "Área por módulo (síntesis jerárquica)" |
| Tabla 6 `tab:barrido` (barrido de período) | 199-219 | **se rehace completa**: los puntos pasan a ser 100, 30, 25, 24, 23, 22, 21,5 y 21 ns (ocho filas, de **siete** corridas `f2_*` más la corrida `final` a 100 ns, todas terminadas y versionadas). De las 10 columnas de datos cambian las 6 de WNS y la de área; las 4 de TNS siguen en 0 salvo la fila que no cierra (`f2_t21`: TNS de setup -0,291 ns en `max_ss_125C_4v50`) | `asic/rom/resultados/{final,f2_t30,f2_t25,f2_t24,f2_t23,f2_t22,f2_t21p5,f2_t21}/metrics.json` |
| Tabla 7 `tab:ruta` (ruta crítica por tramos) | 229-244 | **se rehace completa**: es otra ruta, con otros tramos y otro endpoint | `asic/rutas.md`, sección "Corrida final nueva al periodo minimo (f2_t21p5, 21,5 ns)" (línea 44); `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt` y `max_ss_125C_4v50_ruta_critica.rpt` |
| Tabla 8 `tab:predeco` (efecto de la pre-decodificación) | 252-267 | las 4 filas de historia **no cambian**; hay que **agregar dos filas** (el pipeline nuevo y el pipeline con el modelo de cable) y corregir el T mínimo de la última, que pasa de 25 a 24,5 ns | `asic/exploraciones.md`, tabla resumen (líneas 68 a 89); `docs/modelo_cable.md` sección 4 (tabla de `co_rcm_*` y `co_rc_*`) |
| Tabla 9 `tab:otros` (otros cambios de RTL) | 273-287 | **se rehace**: la fila de la corrida final cambia, B2 pasa a estar dentro de la final y conviene agregar las filas de la sesión del 27 y 28-10 | `asic/exploraciones.md`, tabla resumen (generada por `python3 asic/tabla_sesion.py asic/ramas_sesion.json`, 20 filas de datos desde la línea 70 a la 89) |
| Tabla 10 `tab:palabras` (palabras de la ROM) | 300-314 | **intacta**: las cuatro palabras y sus direcciones son las mismas; solo revisar el commit del pie | `rtl/gen/pochoco_rom.v` (líneas 101, 102, 122 y 123: `lui x12, 0xf4` y `addi x12, x12, 576` dos veces) |
| Tabla 11 `tab:util` (barrido de utilización) | 325-341 | **se rehace completa**: la fila de 40 % sale de la corrida final nueva y las de 50, 60, 70, 72 y 73 % ya están medidas (`u2_u50` a `u2_u73`, todas CIERRAN); **cinco** fallan, no cuatro: 74, 75, 78, 80 y 90 %, y las cinco tienen su `falla.txt` versionado | `asic/rom/resultados/final/metrics.json` y `asic/rom/resultados/u2_*/{metrics.json,cierre.md,falla.txt}`; tabla ya armada en `docs/datos_informe.md` sección 3.5 |
| Tabla 12 `tab:antena` (antena de la estrategia 2) | 385-398 | **intacta**: corridas históricas `s2_t100`, `s2_t100_diodos` y `s2_t100_antrep` con el RTL viejo; el matiz que hay que agregar al texto ya tiene cifra: con el core nuevo y la configuración final la estrategia 2 da **0 nets con violación de antena** (`antenna__violating__nets = 0` en `asic/ff/resultados/s4_t100/metrics.json`), así que la violación es de las corridas históricas y no reaparece | `asic/ff/resultados/s2_t100*/metrics.json` (sin cambios) y `asic/ff/resultados/s4_t100/metrics.json` para el matiz |
| Tabla 13 `tab:sim` (escenario simulado) | 422-437 | **se rehace completa**: cambian 3 de los 4 ciclos de estímulo (el primero, 300 a 360, no cambia), los 5 ciclos de resultado y el valor del display (57 a 51) | `asic/sim/estimulos.txt` (ciclos 300/360, 635/695, 1373/1433, 1733/1793), `asic/sim/resultado.md` (ciclos 1033, 1405, 1507 y 2131) y `asic/sim/resultado_sdf.md` sección 2.2 para el ciclo en que empieza la ronda 01 (4 LEDs en el 383 y display 01 en el **404**, el que en el `.tex` es 426); salida completa en `docs/verificacion/integracion_13_post_synth.txt` |
| Figura 1 `fig:util` `../docs/figuras/utilizacion.png` | 345 | **se regenera, y ya está regenerada** (28-10-2026 20:57, por `bash asic/tablas.sh`, con `final` y `u2_*`), pero hay que repetirla porque entonces solo había terminado `u2_u50` | `$HOME/herramientas/librelane/bin/python3 asic/graficos.py --util <corridas> --salida-util docs/figuras/utilizacion.png` (`asic/tablas.sh`, líneas 32 a 38) |
| Figura 2 `fig:antena` `../asic/ff/resultados/s2_t100/layout/antena_antes.png` y `_zoom.png` | 377-378 | **no se regenera**: corrida histórica con el RTL viejo | sin cambios |
| Figura 3 `fig:bloques` `../asic/rom/resultados/final/layout/bloques.png` | 406 | **se regenera y ya está regenerada** (28-10-2026 20:22, con la corrida final nueva); la misma ruta, otro contenido | `bash asic/layout/anotar.sh asic/rom/runs/final`; datos en `asic/rom/resultados/final/layout/bloques.txt` |

Figuras que se regeneran pero hoy **no** están en el `.tex`, y que con los cambios nuevos pasan a
ser buenas candidatas: `docs/figuras/periodo.png` (el barrido ahora tiene ocho puntos y el área de
celdas crece en todos; ya está regenerada el 28-10-2026 20:57, pero con siete puntos, porque
`f2_t30` terminó a las 21:03:30), `asic/rom/resultados/final/layout/slew.png` (en v1 marcaba 546
pines en 520 celdas, en la final nueva queda vacía: `slew.txt` dice "0 pines en 0 celdas") y
`asic/rom/resultados/f2_t21p5/layout/ruta_critica.png`. `docs/figuras/construccion.gif` también se
regenera, **y ya está regenerado** (28-10-2026 21:28), y tampoco está incluido.

## Párrafos cuyo argumento cambia, no solo el número

El mapa `etapa1_4.json` identifica cinco (líneas 221, 223, 250, 269 y 289). Los cinco se verifican
en el `.tex` de hoy y están abajo; se agregan ocho más que también dejan de ser ciertos, con lo
que son trece en total: 188, 197, 221, 223, 227, 246, 250, 269, 289, 323, 350, 411 y 439.

### 1. Línea 221: "de 26 ns para abajo el layout es idéntico"

Dice hoy: "Aquí el área de celdas sube de 182\,265\umd a 100\,ns a 189\,817\umd a 26\,ns. De
26\,ns para abajo el layout es idéntico (mismas celdas, área y largo de cables) y solo cambia el
slack: el resizer ya no encuentra nada más que mejorar."

Por qué deja de ser cierto: con los parásitos medidos el resizer sigue encontrando trabajo en cada
período y el área crece en los ocho puntos del barrido, de 208.439 µm² a 100 ns a 231.229 a
21,5 ns y 231.638 a 21 ns, sin ningún punto en que el layout se repita (comparar
`design__instance__area__stdcell` y `design__instance__count__stdcell` de
`asic/rom/resultados/{final,f2_t30,f2_t25,f2_t24,f2_t23,f2_t22,f2_t21p5,f2_t21}/metrics.json`:
áreas 208.439, 219.059, 219.531, 220.655, 222.714, 224.767, 231.229 y 231.638 µm², y 9.928, 9.929,
9.926, 9.928, 9.925, 9.927, 9.946 y 9.947 celdas; en v1 las cuatro corridas de 26 a 24 ns
(`f1_t26`, `f1_t25`, `f1_t24p5` y `f1_t24`) tenían exactamente 8.708 celdas, 189.817 µm² y
354.897 µm de cables, según `asic/final.md`, sección "Historia: la corrida final de v1 y su barrido
de período", línea 63).

Qué decir en su lugar: que cada `CLOCK_PERIOD` reoptimiza el circuito y que, con un modelo de
cable realista, la reoptimización no se agota: el área de celdas sube un 10,9 % de 100 a 21,5 ns
(208.439 a 231.229 µm²) y el barrido termina porque el diseño deja de cerrar, no porque el resizer
deje de trabajar. La frase sobre el límite del resizer con el margen de 10 ns de D20 pasa a ser
historia de v1.

### 2. Línea 223: las violaciones de slew "no son criterio de cierre"

Dice hoy: "... las violaciones de max slew de 2\,201 a 546 pines. Esas violaciones no son criterio
de cierre: el límite de 3\,ns es la restricción del flujo, y el peor valor (5,41\,ns, en la esquina
lenta) está dentro de los 7\,ns que admite la biblioteca en esa esquina."

Por qué deja de ser cierto: la configuración nueva deja **0 violaciones de max slew en las nueve
esquinas** (`design__max_slew_violation__count = 0` en `asic/rom/resultados/final/metrics.json`;
`asic/rom/resultados/final/layout/slew.txt`: "0 pines en 0 celdas"; `avisos.md` lo confirma esquina
por esquina: "la corrida nueva tiene 0 violaciones de max slew en las nueve esquinas ... contra 546
en v1"), así que el argumento de que eran inevitables y toleradas se cae. El peor valor de
5,414 ns es verificable, pero es de v1 (`asic/rom/resultados/v1_final/layout/slew.txt`, líneas 7 y
8, pines `u_soc.u_core.u_rf/fanout35` y `fanout34`). Queda **1** violación de max capacitancia, que
es la raíz del árbol de reloj (`clkbuf_0_clk/Z`), un pin que `repair_design` no toca
(`asic/rom/resultados/final/avisos.md`, aviso 4: 0,428234 pF contra un límite de 0,2 pF en
`max_ss_125C_4v50`, mientras el liberty admite 3,93 pF en ese pin; `docs/modelo_cable.md`,
sección 4, punto 3).

Qué decir en su lugar: el diagnóstico del frente C, que es el aporte técnico más fuerte de la
sesión y hoy no está en el informe. El resizer estima los parásitos con un solo par de números, el
promedio de las capas de ruteo del tech LEF: **0,2752 ohm/µm y 64,3 aF/µm**, igual en las nueve
esquinas (`build/exp_rf_latch/asic/rom/runs/b5_t100/14-openroad-dumprcvalues/resizer_values_after.rpt`,
fila `Signal Avg`: 2.751623e-01 y 6.4324e-05; `asic/modelo_cable.md`, sección 1). OpenRCX,
extrayendo del ruteo detallado, mide por regresión lineal sobre **2.399 nets** de más de 20 µm:
**188,4 / 166,3 / 148,0 aF/µm** y **0,599 / 0,549 / 0,498 ohm/µm** (max / nom / min), o sea factores
**2,93 / 2,59 / 2,30** en capacidad y **2,18 / 1,99 / 1,81** en resistencia (`asic/modelo_cable.md`,
sección 2). Con parásitos de menos el resizer cree haber terminado antes de tiempo y no pone el
buffer; la violación aparece recién en el STA final con el SPEF de verdad. `LAYERS_RC` reemplaza la
tabla del tech LEF capa por capa y esquina por esquina con esos valores escalados, y entonces los
dos pasos post-GRT (`RUN_POST_GRT_DESIGN_REPAIR` con `GRT_DESIGN_REPAIR_MAX_SLEW_PCT` y
`GRT_DESIGN_REPAIR_MAX_CAP_PCT` en 30, y `RUN_POST_GRT_RESIZER_TIMING`; `asic/rom/config.yaml`,
líneas 54 a 59) pasan a servir de algo. Ninguno de los valores de `LAYERS_RC` está escrito a mano:
los deriva `asic/modelo_cable.py` y el mismo script verifica que la configuración coincide con lo
derivado (`asic/modelo_cable.md`, sección 4: "Coincide", los 15 pares capa por extracción).

### 3. Línea 250: "toda instrucción pasa un ciclo esperando la lectura sincrónica del banco"

Dice hoy: "En este Espino toda instrucción pasa un ciclo esperando la lectura sincrónica del banco
de registros con la instrucción ya estable. La pre-decodificación usa ese ciclo: registra las
salidas del decodificador (82 bits...) ... y en el ciclo de ejecución el decode ya no está en la
ruta. Ninguna instrucción cambia su número de ciclos."

Por qué deja de ser cierto: `EarlyRead = 1` **elimina ese ciclo**. La ROM de la estrategia 1 es
combinacional, así que su salida (`rom_data` dentro de `rtl/pochoco_mem_rom.v`, que sale por el
puerto `a_next_o`, línea 37 y `assign` de la línea 55) ya tiene la instrucción de la dirección que
pide la etapa IF un ciclo antes de que se cargue en el registro de instrucción; con ella se piden
las lecturas del banco (rs1 y rs2) y se registra el decode en el mismo flanco. `ops_valid_q` deja de
instanciarse (queda solo en la rama `g_wait` del `generate`, la de `EarlyRead = 0`:
`rtl/espino_core/espino_id_stage.v`, líneas 149 a 162) y el conteo pasa de dos ciclos por
instrucción (tres las cargas y los saltos tomados) a **uno, dos las cargas y dos los saltos
tomados** (`docs/pipeline.md`, sección 1, tabla "Temporización nueva", línea 41 en adelante, y la
frase de la línea 49). El CPI del juego completo baja de **2,665 a 1,665** y el de `isa_test.s` de
2,953 a 1,969 (`docs/verificacion/integracion.md`, sección "CPI medido en la integración":
1.595.814 ciclos / 958.358 instrucciones retiradas).

Qué decir en su lugar: que D18 y D19 (la pre-decodificación) quedan **contenidas** en un cambio
mayor, y que el eje de la subsección pasa a ser la Ley de Hierro. Hay que mantener los 82 bits de
decode registrado, que siguen siendo 82 (`asic/sintesis.md`, desglose de `dffq_1`: 82 en
`espino_id_stage`, con el detalle bit por bit), y agregar que el banco de registros gana
write-through (`wr = we_i & (waddr_i != 0)` y `fwd_a = wr & (raddr_a_i == waddr_i)`, con lo que la
salida registrada toma `wdata_i`: `rtl/espino_core/espino_register_file.v`, líneas 62 a 74) y un
habilitador de lectura `rd_en_i` (línea 50), y que la LSU registra `addr_i[1:0]` (B2, 2 flip-flops
más: `asic/sintesis.md`, desglose de `dffq_1`, fila `espino_load_store_unit`). También que la
estrategia 2 usa `EarlyRead = 0` y por eso reproduce exactamente el CPI de v1, 2,665, que es lo que
hace que `make check` siga ejercitando el camino antiguo del core (`docs/pipeline.md`, sección 1,
"Estrategia 2"; `docs/verificacion/integracion.md`, filas de estrategia 2 de la tabla de CPI:
1.599.759 / 600.218).

### 4. Línea 269: "trazas idénticas ciclo a ciclo con el RTL anterior"

Dice hoy: "Se verificó con \sig{make equiv}: \sig{sw/isa\_test.s}, que usa todas las instrucciones
del assembler, da trazas idénticas ciclo a ciclo con el RTL anterior (\sig{116fa20}) en escrituras
al banco, accesos al bus y salidas, con las dos estrategias de memoria."

Por qué deja de ser cierto: la equivalencia ciclo a ciclo es imposible por construcción, porque el
core nuevo retira las instrucciones antes. Pasa a ser **equivalencia funcional**: la misma
secuencia de escrituras al banco, de accesos al bus y de salidas. Las 15 comprobaciones de la
integración están en `docs/verificacion/integracion.md` y todas dieron el resultado que se les
pedía (las 13 que tienen que dar verde dan verde; la 6 difiere a propósito en el banco y la 14 es un
control negativo que tiene que fallar la comparación, y falla).

Qué decir en su lugar, con las cifras de ese archivo: `make equiv MODO=funcional` contra el RTL de
referencia histórico (116fa20) y contra v1 con `sw/isa_test.s` da 46 eventos de banco, 22 de bus y
2 de salida iguales en las dos estrategias; `sw/hazard_test.s` (56 comprobaciones nuevas) da 348,
63 y 2; `sw/hazard_review.s` (48 comprobaciones escritas por la revisión independiente) da 271, 66
y 2; dos mutaciones del RTL (banco sin write-through, `MUTA_FWD`, y lectura un flanco antes del
commit de la carga, `MUTA_LOADUSE`) **se detectan** (con `hazard_test` la primera usa 77 valores
desconocidos; con `hazard_review` son 63 la primera y 679 la segunda); y el monitor de X cuenta
**0 valores desconocidos usados en 620.217 escrituras al banco** del juego completo. Una sola
comparación difiere a propósito: `sw/hazard_cycles.s` lee el contador de ciclos, que depende del
ciclo, y el core nuevo llega antes; lo comparable (bus 10 y salidas 2) sí es idéntico.

### 5. Línea 289: "ninguno se incorporó a la corrida final (D22)"

Dice hoy: "Ninguno se incorporó a la corrida final (D22): esta ya cumple todos los criterios con
margen, y cada cambio agrega lógica que verificar sin cambiar el cumplimiento de ningún criterio."

Por qué deja de ser cierto: **D23 reemplaza a D22**. La corrida final adopta el pipeline nuevo (A)
más B2 más el modelo de cable, con la razón textual "Representa una ganancia en frecuencia y MIPS
considerable, tomando en consideración el área sacrificada" (`docs/decisiones.md`, línea 164 en
adelante, D23).

Qué decir en su lugar: que la métrica de selección de la sesión fue MIPS = f máxima / CPI del juego
completo, con el período barrido hasta dejar 0,5 ns o menos entre el último que cierra y el primero
que no (`docs/decisiones.md`, D23, viñeta "Contexto"); que A + B2 gana con 23,6 MIPS contra 15,3 de
v1 con la configuración anterior, y 27,9 con el modelo de cable (`asic/exploraciones.md`, tabla
resumen, filas `main (referencia)`, `exp/candidata` y `exp/candidata-rc`); que B3, B4 y B5 siguen
fuera, y por qué (B4 baja el CPI a 1,312 pero su período mínimo, 60 ns, es 2,45 veces el del v1
corregido de 24,5 ns; B5 ahorra 11 % de área de celdas pero con la lectura anticipada le **cuesta**
3,5 ns de período: `exp/pipeline-b5` cierra a 29 ns con 165.211 µm² contra 25,5 ns y 186.432 µm² de
`exp/pipeline-b2`, `asic/exploraciones.md`, filas 79 y 80). Y que el límite de área de celdas de
105 % que la sesión se había fijado **se levanta**, porque no es un criterio del enunciado y porque
lo que el enunciado sí pide no empeora: el die y el costo son los mismos, 419.131 µm² y
9.640 dólares (`docs/decisiones.md`, D23, "Nota sobre el límite de área de celdas"). El reparto del
salto de MIPS está medido: de los 12,6 MIPS de diferencia, 8,2 los pone el RTL, 1,7 el flujo y 2,6
son de la interacción (`asic/evolucion.md`, citado en `asic/exploraciones.md`).

### 6. Línea 188: "se esperaba que los flip-flops fueran la celda más numerosa ... Las dos cosas se cumplen"

Dice hoy: "... y el conteo de flip-flops coincide con el RTL: 818 sin reset y 186 con reset en la
síntesis jerárquica, 990 en la final. Lo que no se esperaba es el peso de los multiplexores ...
Tampoco se esperaba que \sig{nand2\_1} quedara a la par de \sig{mux2\_2}."

Por qué deja de ser cierto: con el RTL nuevo `nand2_1` es la **primera** celda (934, 16,7 %),
`mux2_2` la segunda (889, 15,9 %) y `dffq_1` cae a **tercera** (779, 14,0 %)
(`asic/rom/resultados/final/sintesis_stat.rpt`, bloque "design hierarchy" que empieza en la línea
166: `nand2_1` 934 en la línea 203, `mux2_2` 889 en la 201 y `dffq_1` 779 en la 199; y
`asic/sintesis.md`). Ya no se cumple lo esperado de que el flip-flop fuera la celda más numerosa, y
la frase de que `nand2_1` queda "a la par" pasa a ser "la supera".

La fuente está al día y no hay que corregirla: `asic/sintesis.md` se regeneró el 28-10-2026 a las
21:16 y su última sección ("Comparación con lo esperado antes de sintetizar") ya dice lo contrario
de lo que dice el `.tex`: "Se esperaba que los flip-flops fueran la celda más numerosa y los
multiplexores la segunda ... **No se cumplió**: la celda más usada es `nand2_1`, y el flip-flop
queda tercero". No hay contradicción entre ese párrafo y su propia tabla de celdas.

Qué decir en su lugar: que la expectativa se cumple a medias, que el banco de registros sigue
dominando el área (48,8 % en la jerárquica, que `asic/sintesis.md` redondea a 49 %) y que la razón
de que `nand2_1` pase al primer lugar es que la lógica combinacional del banco creció: **265
`nand2_1` en el register file contra 88 en v1** (`asic/rom/resultados/h3_t100/sintesis_jerarquica.rpt`,
línea 462, contra `asic/rom/resultados/h2_t100/sintesis_jerarquica.rpt`, línea 461; también
`v1_final/sintesis_stat.rpt`, línea 120), por los muxes del write-through y del habilitador de
lectura. El conteo nuevo contra el RTL es: **820 sin reset y 185 con reset (1.005)**; la jerárquica
da 820 + 185 y la aplanada 779 + 185 = **964** (`asic/sintesis.md`, "Comparación con lo esperado
antes de sintetizar"). La aplanada elimina **41** flip-flops, no 14.

Y el desglose completo de `nand2_1` por módulo en la síntesis jerárquica nueva (`asic/sintesis.md`,
sección "1. `nand2_1`: desglose por módulo", 785 celdas en total): 265 en el register file, 106 en
la ALU, 85 en la LSU, 79 en la etapa ID, 74 en la ROM, 72 en los periféricos, 53 en el
decodificador, 25 en el fetch, 13 en la memoria, 6 en el contador de ciclos, 4 en los debounce, 2
en el divisor del debounce y 1 en el bus.

**Corrección importante respecto de la versión anterior de este documento:** la LSU **no** pasa de
6 a 85 `nand2_1`. En v1 la LSU tenía **94** (`asic/rom/resultados/h2_t100/sintesis_jerarquica.rpt`,
línea 425) y en el diseño nuevo tiene **85** (`h3_t100/sintesis_jerarquica.rpt`, línea 428): el
conteo **baja**, no sube. El 6 que aparecía citado es el de `pochoco_cycle_counter`
(`asic/rom/resultados/v1_final/sintesis_stat.rpt`, línea 152, que es el bloque del contador de
ciclos, no el de la LSU: la corrida final aplana la LSU y su reporte no la separa). Lo que sí sube
en la LSU es el área, 2.711 a 2.819 µm², por los 2 flip-flops de B2 y su lógica
(`h2_t100/sintesis_jerarquica.rpt`, línea 435: "Chip area for module '\espino_load_store_unit':
2711.072000", contra `asic/sintesis.md`, fila de la LSU: 2.819).

### 7. Línea 227 y línea 246: la ruta crítica ya no es la de una carga, y B2 ya no es una propuesta

Dicen hoy (227): la ruta crítica "es el camino de una carga: ejecución (la ALU calcula la
dirección), acceso a memoria (los dos bits bajos de la dirección eligen el byte o la media palabra)
y write-back"; y (246): "Por eso registrar los dos bits bajos de la dirección al emitir la carga la
saca de la ruta sin cambiar el comportamiento (cambio B2 de la Tabla~\ref{tab:otros})".

Por qué dejan de ser ciertos: B2 **ya está dentro de la corrida final**, así que la alineación de
la carga salió de la ruta, y la ruta crítica al período mínimo es otra. A 21,5 ns va del
flip-flop de pre-decodificación `_4136_` (`dffq_4`, netlist línea 28905;
`u_soc.u_core.u_id.alu_op_a_sel[2]`) por el mux del operando A, la ALU hasta
`u_soc.u_core.lsu_addr[31]`, y de ahí por lógica aplanada hasta `_4440_` (`dffrnq_1`). Ese
flip-flop es **`u_soc.u_periph.digit_q[4]`**, un bit del registro del display: en el netlist,
`gf180mcu_fd_sc_mcu7t5v0__dffrnq_1 _4440_ (.D(_0357_), .RN(net848), .CLK(clknet_leaf_79_clk),
.Q(\u_soc.u_periph.digit_q[4]))` (`asic/rom/runs/f2_t21p5/final/nl/asic_top.nl.v`, línea 29924). La
cadena pasa por `_4079_`, una `nand3_4` cuyas tres entradas son `u_soc.u_core.lsu_we`, el decode de
la dirección (`_1838_`) y `_0467_`, y entrega `_1980_` (línea 28693 del mismo netlist), y termina en
`_4094_`, una `oai21_2` que produce `_0357_`, el pin D de `_4440_` (línea 28751). El decode de la
dirección sí viene de `lsu_addr[31]`, pero en dos pasos: `_1838_` es la salida de un `nor2_4`
(`_3825_`, línea 27823) entre `net194` y `_0384_`, y `_0384_` es `lsu_addr[31]` invertido
(`clkinv_16 _2014_`, línea 21097, sobre `net117`, que es el `buf_8 max_cap117` de
`u_soc.u_core.lsu_addr[31]`, línea 31118). Es decir: **la ruta crítica nueva es un store al
display**: ejecución (la ALU calcula la dirección), decodificación de la dirección del bus combinada
con la señal de escritura, y habilitación del registro DISP del periférico. Esto corrige la
hipótesis del mapa `etapa1_4.json`, que en su sección "pendientes" suponía que el endpoint era el
control de la detención del pipeline. La misma suposición está en el `.tex`, línea 289, pero ahí es
sobre la corrida de B2 solo (`exp/lsu-offset`, 24 ns) y queda como historia.

Qué decir en su lugar: que la ruta crítica depende del período, porque el resizer optimiza distinto
en cada punto. A 100 ns la crítica es la que crea `EarlyRead`: del flip-flop `_4287_`
(`dffrnq_1`, cuya Q es `u_soc.g_mem_rom.u_mem.a_addr_i[2]`, un bit del PC que direcciona la ROM)
por la ROM combinacional hasta `u_soc.g_mem_rom.u_mem.a_next_o[17]` y de ahí por el árbol de lectura
del banco hasta `u_soc.u_core.u_rf/_4123_`, la salida registrada del puerto de lectura A
(`asic/rutas.md`, sección "Corrida final nueva a 100 ns (tag final)", línea 17: startpoint `_4287_`,
endpoint `u_soc.u_core.u_rf/_4123_`, con 13 celdas de lógica aplanada por 12,355 ns y 19 celdas
dentro del banco por 19,154 ns, llegada total 36,033 ns). Al período mínimo la crítica vuelve a la
ALU, pero termina en el periférico y no en el banco. Y que B2 pasa de propuesta a parte del diseño:
la frase "registrar los dos bits bajos de la dirección al emitir la carga la saca de la ruta" se
escribe en pasado y se cita como lo que explica que la ruta de la carga ya no aparezca.

Nota sobre los nombres de instancia: los netlists de dos corridas distintas no comparten
numeración, así que `_4123_` y `_4287_` son del netlist de `final` y `_4136_`, `_4440_`, `_4079_` y
`_4094_` del de `f2_t21p5`. Las dos rutas completas, con sus tramos y sus nets del RTL, están en
`asic/rutas.md` (secciones de las líneas 17 y 44), que genera `bash asic/rutas.sh`.

### 8. Línea 323: "La utilización real queda 8 a 11 puntos sobre la pedida"

Dice hoy: "Entre las probadas, el área mínima con la que el diseño completa el flujo y cumple todos
los criterios es la de 70\,\%: un die de $480{,}0 \times 497{,}9$\um, 0,239\mmd ... La utilización
real queda 8 a 11 puntos sobre la pedida porque el core se dimensiona con el área de síntesis y
después se agregan celdas de tap, buffers y el árbol de reloj."

Por qué deja de ser cierto, por dos motivos acumulados. Primero, la corrección de v1: con la
configuración de v1 la utilización máxima que cierra es **78 %** (`u1_u78`: die 455,4 x 473,3 µm =
215.545 µm², real 90,3 %, WNS de setup 59,602 ns, hold 0,182 ns, "Resultado: CIERRA"), y es **79 %**
el primero que falla, no 80 (`asic/final.md`, sección "Historia: barrido de FP_CORE_UTIL de v1 a
100 ns", línea 105; `asic/rom/resultados/u1_u78/{metrics.json,cierre.md}` y `u1_u79/falla.txt`, que
muestra `[INFO DPL-0034] Detailed placement failed on the following 6 instances` del banco de
registros al legalizar dentro de `OpenROAD.CTS`, `Error: cts.tcl, 102 DPL-0036`).

Segundo, con la configuración nueva el barrido entero se corre de nuevo y la utilización máxima que
cierra **baja a 73 %**, con un die de 235.237 µm² (0,235 mm²), un 43,9 % menos que el de la corrida
final (`asic/rom/resultados/u2_u73/{metrics.json,cierre.md}`, "Resultado: CIERRA";
`docs/datos_informe.md`, sección 3.5). El diseño nuevo tiene 14 % más área de celdas, así que el
core se llena antes que en v1.

Y la brecha entre la pedida y la real ya no es de 8 a 11 puntos: en la corrida final nueva, con
40 % pedida, la real es **53,5 %**, o sea 13,5 puntos (`design__instance__utilization = 0,53511`), y
con el barrido nuevo llega a **19,7 puntos** a 72 % pedida (real 91,7 %,
`asic/rom/resultados/u2_u72/metrics.json`: 0,9166). La serie completa de la brecha es 13,5 (40 %),
15,3 (50), 16,9 (60), 18,7 (70), 19,7 (72) y 18,8 (73) puntos.

Qué decir en su lugar: que la brecha tiene dos componentes, las celdas físicas (tap, relleno,
borde) y lo que agrega el resizer, y que la segunda crece con un modelo de cable realista, porque
el resizer agranda celdas y pone buffers que antes no ponía. Las cifras del barrido nuevo ya están
medidas para 40, 50, 60, 70, 72 y 73 % (ver la Tabla 11 más arriba) y **las cinco que fallan ya
fallaron**: no queda nada encolado de este barrido.

**Corrección importante respecto de la versión anterior de este documento:** `u2_u74` no está
encolada ni falta. Corrió y **falló** con código 2 el 28-10-2026 a las 21:50:40
(`asic/logs/cola_estado.txt`, entrada 154), en `OpenROAD.RepairDesignPostGRT` (paso 41, el que
agrega D23) con `[DPL-0036] Detailed placement failed` desde `repair_design_postgrt.tcl:48` y 18
instancias sin lugar; el extracto está versionado en `asic/rom/resultados/u2_u74/falla.txt`. Con eso
la regla de resolución del barrido queda cerrada a 1 punto de utilización: 73 % cierra y 74 no. Las
cinco fallas, con su paso y su cuenta de instancias sin lugar tal como la informa OpenROAD:

- **74 %**: `OpenROAD.RepairDesignPostGRT` (paso 41), 18 instancias;
- **75 %**: el mismo paso (`repair_design_postgrt.tcl:48`), 77 instancias;
- **78 %**: `OpenROAD.CTS` (paso 35, `cts.tcl:102`), 36 instancias, 19 de ellas del banco de
  registros;
- **80 %**: `OpenROAD.RepairDesignPostGPL` (paso 32, `repair_design.tcl:68`), 5 instancias;
- **90 %**: antes que todas, en el placement global, `[GPL-0301] Utilization 100.620 % exceeds
  100%` con 169.186,876 µm² de instancias movibles (en v1 era 100,531 %).

Cuidado con una cifra de `docs/datos_informe.md` sección 3.5: dice "40 instancias sin lugar" para
el 75 %, que son las líneas `[INFO DPL-0035]` que alcanzó a copiar el extracto, no las que informa
la herramienta; `u2_u75/falla.txt` dice "on the following 77 instances". Si el informe cita ese
número, conviene citar el 77 y decir que el extracto lista 40 de ellas.

### 9. Línea 350: la serie de violaciones de slew contra la utilización

Dice hoy: "Las violaciones de max slew bajan de 546 pines a 40\,\% a 378 y 392 a 60 y 70\,\%,
porque los cables se acortan (de 352 a 317 y 318\,mm en el ruteo detallado). Las violaciones de DRC
al inicio del ruteo detallado no siguen una tendencia (1\,546, 2, 5 y 2\,149), pero el router las
lleva a cero en todas las corridas que terminan."

Las tres cifras de slew y las tres de largo de cables se verifican en v1 (`u1_u60`: 378
violaciones y 316.543 µm; `u1_u70`: 392 y 318.333; `v1_final`: 546 y 352.253). El problema es
que con el modelo de cable a 40 % ya hay **0** violaciones de slew, así que la serie no se puede
contar como una tendencia que baja: con el barrido `u2_*` la serie nueva es **0 (40 %), 8 (50), 0
(60), 20 (70), 92 (72) y 99 (73)**, es decir **no baja**, y a partir de 70 % sube con fuerza (la
serie no es monótona: entre 50 y 60 % vuelve a 0)
(`design__max_slew_violation__count` de `asic/rom/resultados/{final,u2_u50,u2_u60,u2_u70,u2_u72,u2_u73}/metrics.json`).
Y el largo de cables tampoco se acorta en todo el rango: 377.509 µm a 40 %, 361.730 a 50, 352.225 a
60, y después **sube** a 407.376 a 70, 447.720 a 72 y 449.400 a 73 (`route__wirelength` de los
mismos archivos). La capacitancia hace lo mismo, de 1 a 5 (72 %) y 6 (73 %). La serie de DRC también
cambia: a 40 % con el modelo de cable la iteración 0 ya no parte con 1.546 sino con **2** (ver el
párrafo siguiente).

Un dato que conviene decir y que hoy no está: el mínimo de área del die y el mínimo de cables no
caen en la misma utilización. El die más chico que cierra es el de 73 % (0,235 mm²), pero ahí los
cables son los más largos del barrido; el mínimo de cables está en 60 % (0,284 mm² de die)
(`docs/datos_informe.md`, sección 3.5).

### 10. Línea 350: el DRC del ruteo detallado por iteración

Aclaración de rutas respecto de la versión anterior de este documento: el 1.546 aparece **una sola
vez** en `informe/main.tex`, en la línea 350. La línea 371 no lo menciona: habla del DRC de Magic y
del deck de KLayout (684 reglas) y no de las iteraciones del ruteo detallado. El segundo lugar donde
está el 1.546 es `docs/datos_informe.md` sección 3.6 (líneas 442, 444 y 470), que es un documento de
origen y no el informe.

En v1 la serie por iteración de la corrida final es **1.546, 501, 379, 0** y en la final nueva es
**2, 0, 430, 3, 0** (`route__drc_errors__iter:N` de
`asic/rom/resultados/v1_final/metrics.json` y de `asic/rom/resultados/final/metrics.json`). Es un
cambio llamativo, porque el informe usa el 1.546 como punto de partida de la serie contra la
utilización (línea 350) y `docs/datos_informe.md` lo usa además, en su sección 3.6, como la
"violación que se resolvió sola" que D21 provoca. Con la configuración nueva el ruteo detallado
parte casi limpio, sube en la tercera iteración y termina en cero igual. Al período mínimo vuelve a
partir alto: `f2_t21p5` da **1.685, 414, 331, 0**. Y al subir la utilización parte mucho más alto y
necesita más iteraciones: 2.219, 716, 552, 2, 0 a 50 %; 2.189, 842, 746, 9, 2, 2, 0 a 60; 2.793,
1.159, 1.031, 16, 0 a 70; 3.252, 1.449, 1.220, 12, 0 a 72; y 3.144, 1.305, 1.229, 71, 0 a 73. En
todas termina en 0. Conviene decir las dos cosas y no generalizar: lo que se sostiene es que el
router termina en cero en todas las corridas que completan.

### 11. Línea 411: "El register file ocupa casi la mitad oeste del core"

Dice hoy: "El register file ocupa casi la mitad oeste del core, la ALU queda en el centro, junto a
él, y el contador de ciclos en una franja angosta cerca del borde este. Las áreas de la figura son
mayores que las de síntesis (78\,186 contra 73\,656\umd en el register file) ... y sus porcentajes
son sobre 170\,060\umd de celdas lógicas."

Por qué deja de ser cierto: en la corrida final nueva el banco de registros se extiende por casi
todo el core, con envolvente de (7,84; 50,96) a (492,8; 638,96) µm sobre un core que va de
(6,72; 15,68) a (631,68; 638,96) (`asic/rom/resultados/final/layout/bloques.txt` y
`design__core__bbox` de `metrics.json`). Ya no es "la mitad oeste": ocupa el 94 % de la altura del
core y el 78 % de su ancho, y la ALU queda embebida dentro de esa zona, con envolvente de
(197,12; 235,2) a (533,12; 411,6). El contador de ciclos sigue cerca del borde este, con envolvente
de (499,52; 266,56) a (630,56; 497,84). Y las cifras de la comparación cambian: **96.936 contra
80.349 µm²** en el register file (49,44 % del layout), con porcentajes sobre **196.080 µm²** de
celdas lógicas sin relleno.

### 12. Línea 439: la simulación post-PnR con SDF "no se considera un resultado reproducible"

Dice hoy: "La simulación opcional con SDF de la esquina típica completó una vez con la misma traza,
pero Icarus 14.0 aborta al anotar el SDF en las corridas siguientes, así que no se considera un
resultado reproducible."

Por qué deja de ser cierto: el frente D1 la cerró sobre el netlist de v1, y **sobre el netlist nuevo
ya está repetida**. El aborto de `vvp` era el nombre jerárquico de las instancias del banco de
registros, en Icarus 13.0 y en 14.0, y lo arregla `asic/sim/renombrar_instancias.py`.

**Corrección importante respecto de la versión anterior de este documento:** no falta la simulación
con SDF sobre el netlist nuevo. `asic/sim/resultado_sdf.md` **ya documenta `d2_pnr`** y no `d1_pnr`,
y lo que hay medido es esto:

- la corrida de place and route es **`d2_pnr`** (`asic/sim/config_pnr.yaml`, la configuración final
  completa de D23 con la ROM de simulación y `DebounceDivBits = 2`), terminada con código 0 el
  28-10-2026 a las 21:04:20 en 5 min 31 s (`asic/logs/cola_estado.txt`, entrada 152), con sus
  reportes en `asic/sim/resultados/d2_pnr/`, cuyo `cierre.md` dice **CIERRA** (setup WNS 59,174 ns y
  hold 0,082 ns en la peor esquina, DRC 0, LVS 0, antenas 0, die 414.282 µm², utilización 0,540,
  slew 5 y capacitancia 1). Difiere de la corrida final (207.624 contra 208.439 µm² de celdas y 951
  contra 964 flip-flops) solo por la ROM de 113 palabras y el debounce de 2 bits;
- **Icarus Verilog 13.0** de la imagen de LibreLane, que anota los retardos pero no evalúa los
  timing checks: tres esquinas (`nom_tt_025C_5v00`, `max_ss_125C_4v50`, `min_ff_n40C_5v50`) por tres
  ejecuciones, nueve trazas, todas idénticas a la del RTL, con 16 cambios de salida y 0 valores X, y
  un solo md5, **`5b6cebfb898a90a258b592fb29e64651`**;
- **Open Verilog CVC 7.00b**, que sí evalúa `$setup`, `$hold`, `$width`, `$recovery`, `$removal` y
  `$period`: las mismas tres esquinas por tres ejecuciones, el mismo md5, y **0 violaciones de
  timing** con los **7.173 checks** de los **951 bloques TIMINGCHECK** activos (1.902 SETUP, 1.902
  HOLD, 2.074 WIDTH, 172 RECOVERY, 172 REMOVAL, 951 PERIOD). El control positivo con `ESTIMULO = 1`
  reporta **8 violaciones en 4 instancias** (4 `$setup`, 2 `$removal`, 2 `$recovery`), que son
  exactamente los dos flip-flops del sincronizador de reset y los dos primeros del sincronizador de
  botones, y la traza se cae a X;
- el renombrado creció con el diseño nuevo: `asic/sim/renombrar_instancias.py` renombra **3.787
  instancias** y **20.939 referencias del SDF**, no 2.828;
- y además hay un escenario que el informe hoy no tiene: el **netlist real de la corrida final** con
  su SDF de `nom_tt_025C_5v00` corrido **320.000 ciclos** (32 ms simulados, 42 min 36 s), con la
  misma traza que el RTL (md5 `347f1d2dd76675023fb51edb9b8c2878`), los cuatro LEDs en el ciclo
  262.151 y el 01 en el 262.172, exactamente los mismos ciclos que sin retardos (con el core de v1
  caían en 262.156 y 262.194).

Todo eso está en `asic/sim/resultado_sdf.md` (secciones 1 a 5). Los números de `d1_pnr` (cuatro
esquinas, `nom_tt_025C_5v00`, `max_ss_125C_4v50`, `min_ff_n40C_5v50` y `nom_ss_125C_4v50`, doce
trazas por simulador, md5 `4f14ec05462e4789a3d873d2ba50fd97`, 57 ciclos medidos, 7.358 checks de
977 bloques TIMINGCHECK y 2.828 instancias renombradas) son correctos, pero **su archivo de origen
ya no es `asic/sim/resultado_sdf.md`**: están en el historial de git de ese archivo (commit
`c7833b9`, recuperable con `git show c7833b9:asic/sim/resultado_sdf.md` o
`git log -p asic/sim/resultado_sdf.md`) y los reportes de la corrida en
`asic/sim/resultados/d1_pnr/`. Si el informe cita cifras de la simulación con SDF, tienen que ser
las de `d2_pnr`.

### 13. Línea 439: las otras cuatro cifras del párrafo del control negativo

El mismo párrafo 439 tiene cuatro cifras más que cambian, y ninguna es un detalle:

- "la ronda correcta mide 57 ciclos en las dos simulaciones" pasa a **51** (`asic/sim/resultado.md`;
  `docs/verificacion/integracion_13_post_synth.txt`);
- "atrasa 6 ciclos la pulsación de la ronda 01" pasa a **8**, y "el display muestra 70 en vez de 57"
  pasa a **59 en vez de 51**, con 12 cambios de salida contra 17 líneas (`asic/sim/resultado.md`,
  sección "Control negativo"; `docs/verificacion/integracion.md`, comprobación 14);
- "Con 5 ciclos de atraso la traza no cambia, porque el programa lee los botones en un lazo de
  13 ciclos" pasa a: 8 es el atraso más chico que cambia la traza y el lazo de polling es de
  **8 ciclos** (con 7 la traza no cambia) (`asic/sim/resultado.md`, sección "Control negativo").

Y hay una ambigüedad que conviene resolver al reescribir: "17 cambios de salida en 4.500 ciclos".
El testbench informa **16 cambios** (`docs/verificacion/integracion_13_post_synth.txt`:
"post_synth_tb: 4500 ciclos, 16 cambios de salida (0 con X)") y la traza tiene **17 líneas**, la
inicial más los 16 cambios, que es lo que `asic/sim/resultado.md` cuenta como 17 y lo que
`asic/sim/resultado_sdf.md` aclara explícitamente ("17 líneas: la inicial y 16 cambios"). Lo
correcto es escribir 16 cambios de salida, o 17 líneas de traza, pero no "17 cambios".

### Nota sobre la línea 197, que el mapa marcaba como cambio de número y es de argumento

Dice hoy: "El diseño cierra hasta 25\,ns y no a 24\,ns, donde falla por 0,004\,ns en la esquina
lenta. La frecuencia máxima es 40\,MHz. La corrida de 28\,ns se detuvo a los 40 minutos y no tiene
resultado, lo que no cambia el límite porque 26 y 25\,ns cierran."

No cambian solo los números (25 a 21,5 ns, 40 a 46,5 MHz, 0,004 a 0,129 ns): cambia el argumento,
porque la excusa de la corrida que no terminó desaparece. En el barrido nuevo las ocho corridas
terminaron, no hay ninguna detenida por la regla de 40 minutos, y el límite queda cerrado por la
regla de 0,5 ns de la sesión: `f2_t21p5` cierra con WNS 0,876 ns y TNS 0, y `f2_t21` no cierra por
0,129 ns con TNS -0,291 ns (`asic/rom/resultados/f2_t21p5/cierre.md` y `f2_t21/cierre.md`). La
`f1_t28` detenida a los 40 minutos en `OpenROAD.ResizerTimingPostCTS` pasa a ser historia de v1
(`asic/final.md`, línea 63).

> **Nota de procedencia.** Todo lo anterior (el resumen de tablas y figuras y los trece párrafos
> cuyo argumento cambia) pasó por una revisión adversaria el 29-10-2026 que reabrió cada archivo
> citado y cada línea de `informe/main.tex`; lo que corrigió está anotado en el apéndice de este
> documento. Lo que sigue, de la sección 2 en adelante, es la redacción original, con sus cifras
> verificadas contra su archivo por quien la escribió pero sin esa segunda pasada. Donde una cifra
> diga "por medir", vale la tabla de cierre, que está más abajo.

## Sección 2. Corrida final y reproducibilidad (líneas 40 a 60)

### Texto

| cambio | línea | qué hay que hacer | archivo de origen |
|---|---|---|---|
| Rango de decisiones | 40 | "D1 a D22" pasa a "D1 a D23" | `docs/decisiones.md`, línea 164: "## D23. Corrida final: mantener main o adoptar exp/candidata (28-10-2026)", con "**Elegida: (b), variante `exp/candidata-rc`.**" |
| Versiones de herramientas y PDK | 40 | **no cambian**: LibreLane 3.0.16 en Docker, imagen `ghcr.io/librelane/librelane:3.0.16` (id `02d50f259d48`), PDK `gf180mcuD` revisión `54435919abffb937387ec956209f9cf5fd2dfbee` y biblioteca `gf180mcu_fd_sc_mcu7t5v0` | `asic/versiones.md`, regenerado el 2026-10-28 (Yosys 0.62, OpenROAD `dcf36133`, Magic 8.3.623, KLayout 0.30.7, Netgen 1.5.316, Icarus 13.0 en la imagen y 14.0 en el anfitrión) |
| Tag de la corrida final | 42 y 58 | **no cambia**: sigue siendo `final`, `asic/rom/runs/final`, reportes en `asic/rom/resultados/final/` | `asic/rom/resultados/final/cierre.md`, primera línea: "Criterios de cierre de `asic/rom/runs/final`" |
| `SYNTH_PARAMETERS` | 42 | agregar `EarlyRead=1` junto a `MemStrategy=1` y `DataWords=4` | `asic/rom/config.yaml`, líneas 11 a 14 |
| Lista de perillas de la corrida final | 42 | hoy dice "la estrategia de memoria 1 ... y la pre-decodificación"; hay que agregar el pipeline nuevo (lectura del banco y decode en el fetch), el banco write-through, B2, el modelo de cable del resizer (`LAYERS_RC`, 15 pares de capa y extracción) y las cuatro variables de la reparación post-GRT (`RUN_POST_GRT_DESIGN_REPAIR`, `GRT_DESIGN_REPAIR_MAX_SLEW_PCT: 30`, `GRT_DESIGN_REPAIR_MAX_CAP_PCT: 30`, `RUN_POST_GRT_RESIZER_TIMING`) | `asic/rom/config.yaml`, líneas 43 a 99; `docs/modelo_cable.md`, sección 3 |
| $T = 100$ ns y `FP_CORE_UTIL` = 40 % | 42 | **no cambian** | `asic/rom/config.yaml`, líneas 40 y 41 |
| Las nueve esquinas, sus nombres y D14 | 42 | **no cambian**; LibreLane sigue tratando como error solo la típica y el cierre se verifica con `asic/verificar_cierre.py` | `asic/rom/resultados/final/cierre.md`, que lista las 9 esquinas de setup y las 9 de hold |
| Numeración de los pasos del flujo (texto nuevo opcional) | 42 | la configuración agrega `OpenROAD.RepairDesignPostGRT` (paso 41) y `OpenROAD.ResizerTimingPostGRT` (paso 44), así que todo lo posterior corre dos lugares: el STA final pasa de `55-openroad-stapostpnr` a `57-openroad-stapostpnr`, el segundo chequeo de antenas de 46 a 48, el informe de caída de tensión de 56 a 58, `magic-writelef` de 60 a 62 y el chequeo de antenas del LEF de 61 a 63 | `asic/rom/resultados/final/avisos.md`, primer bloque; `docs/datos_informe.md`, líneas 20 a 26 |

### Tabla 1 (`tab:cierre`)

| dato | línea del `.tex` | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| DRC (Magic) | 50 | 0 violaciones | **0 violaciones** (no cambia) | `asic/rom/resultados/final/cierre.md`; `metrics.json`, `magic__drc_error__count = 0` |
| DRC (KLayout, deck de GlobalFoundries) | 51 | 0 marcadores en 684 reglas | **0 marcadores en 684 reglas** (no cambia, pero la medición es nueva: el deck se corrió sobre el GDS de la corrida final nueva) | `asic/rom/resultados/final/drc_klayout/resumen.md`: "0 marcadores en 0 reglas (de 684 reglas evaluadas por el deck)" |
| LVS (Netgen) | 52 | 0 diferencias | **0 diferencias** (no cambia) | `cierre.md`; `metrics.json`, `design__lvs_error__count = 0` |
| Antenas | 53 | 0 nets | **0 nets**, con 1 diodo de antena insertado | `metrics.json`, `antenna__violating__nets = 0`, `antenna_diodes_count = 1` (en v1 era 0) |
| Setup: WNS y TNS | 54 | 65,22 ns y 0 ns, peor esquina `max_ss_125C_4v50` | **65,725 ns y 0 ns**, peor esquina `max_ss_125C_4v50` | `cierre.md`: "setup max_ss_125C_4v50: WNS / TNS \| 65.725 / 0.000"; v1: 65.223 (`v1_final/cierre.md`) |
| Hold: WNS y TNS | 55 | 0,18 ns y 0 ns, peor esquina `min_ff_n40C_5v50` | **0,173 ns y 0 ns**, con `min_ff_n40C_5v50` y `nom_ff_n40C_5v50` empatados (`max_ff` 0,174) | `cierre.md`: hold `min_ff` 0.173, `nom_ff` 0.173, `max_ff` 0.174; v1: 0.178 en `min_ff` |
| Número de reglas del deck | 51 | 684 | **684** (no cambia) | `asic/rom/resultados/final/drc_klayout/resumen.md`; `asic/drc/ORIGEN.md` |

Filas informativas que la Tabla 1 podría ganar, porque son el resultado más visible de D23 y hoy el
informe no las pone en ninguna tabla de cierre (todas de `asic/rom/resultados/final/cierre.md`,
bloque "dato informativo", con el valor de v1 de `v1_final/cierre.md` entre paréntesis): max slew
**0** (546), max capacitancia **1** (36), área del die **419.131 µm²** (408.957) y utilización
**0,535** (0,480).

**Cuidado con el hold.** Los 0,173 ns son los de la **peor** esquina (`min_ff` y `nom_ff`). En
`max_ss_125C_4v50`, que es la esquina que decide el setup, el hold es **1,065 ns**
(v1: 1,081 ns). Las dos cifras aparecen en el informe: 0,18 en la Tabla 1 (línea 55) y 1,081 en las
columnas "hold ss" de la Tabla 6 (líneas 209 a 214). No hay que mezclarlas.

## Sección 3.1. Del RTL de FPGA al RTL de ASIC (líneas 63 a 99)

La Tabla 2 (`tab:fpga`) **no se regenera**: es evidencia de las corridas c0a, c0b y c0c sobre el
RTL del Proyecto 2 (commit `1227fa5`), con los logs copiados en `asic/p2_original/evidencia/`.
Verificado: los 17.188 flip-flops de la línea 83 son 17.004 `dffq_1` más 184 `dffrnq_1`
(`asic/p2_original/evidencia/c0b/stat.rpt`, líneas 24 y 25) y los 2.327.825 µm² son "Chip area for
module '\game_top': 2327825.203200" (línea 49 del mismo archivo).

### Texto

| cambio | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Parámetros del top que eligen la memoria | 67 | "Los parámetros `MemStrategy` y `DataWords` eligen la memoria" | agregar `EarlyRead`, parámetro de temporización del core, con valor por omisión `(MemStrategy == 1) ? 1 : 0` | `asic/rom/config.yaml` línea 14; `docs/pipeline.md`, sección 1, lista "Qué cambia en el RTL" (`rtl/pochoco_soc.v` y `rtl/asic_top.v`) |
| Banco de registros en flip-flops (fila de D3 y D4 de la Tabla 2) | 77 | "Banco de registros en flip-flops con lectura sincrónica, igual que la BRAM (D3, D4)" | sigue válido, y ahora el banco tiene además write-through y un habilitador de lectura (`rd_en_i`) | `docs/pipeline.md`, sección 1, viñeta de `espino_register_file.v` |
| `x0` vale 0 | 95 | "En el banco nuevo `x0` no se almacena y la lectura de la dirección 0 entrega 0 por hardware" | igual, más la precisión de que el write-through **excluye** `x0`: `wr = we_i & (waddr_i != 0)` condiciona tanto la escritura como el adelanto | `docs/pipeline.md`, sección 2, punto 4 |
| Los otros tres ítems sin mensaje (segmentos, `CYCLES_PER_TENTH`, `DebounceDivBits`) | 96 a 98 | sin cambios | sin cambios: el período de la corrida final sigue siendo 100 ns, así que D8 y D10 valen igual | `docs/decisiones.md`, D8 y D10 |

No hay tabla de cifras que cambie en esta sección.

## Sección 3.2. Memoria y programa del juego (líneas 102 a 132)

### Texto

| cambio | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Palabras del juego y RAM de datos | 106 | 115 palabras (460 bytes) y 0 de datos; máximos 256 y 64; RAM de 4 palabras (128 flip-flops) | **no cambia** | `rtl/gen/game_image.vh`, línea 5: `localparam integer GAME_WORDS = 115` |
| Pruebas del assembler | 108 | 80 en total, siete nuevas de `test_image.py` | las 80 siguen siendo las del assembler (`make check` PASS, 80 pruebas en 0,010 s); la verificación del RTL nuevo agrega `sw/hazard_test.s` (56 comprobaciones) y `sw/hazard_review.s` (48), que son otro conteo | `docs/verificacion/integracion.md`, comprobación 1 |
| Descripción de la estrategia 1 | 110 | "la ROM entrega la instrucción a través de un registro que conserva la lectura registrada de la RAM del Proyecto 2" | hay que agregar que la memoria expone además `a_next_o`, la palabra de `a_addr_i` **sin registrar**, y que con `EarlyRead = 1` es esa salida combinacional la que alimenta las direcciones de lectura del banco y el decodificador | `docs/pipeline.md`, sección 1 (`rtl/pochoco_mem_rom.v` y `rtl/pochoco_mem_ff.v`: "salida `a_next_o`") |
| Descripción de la estrategia 2 | 110 | igual | agregar que usa `EarlyRead = 0` (valor por omisión con `MemStrategy = 2`) y por eso reproduce la temporización y el CPI de v1 | `docs/pipeline.md`, sección 1, "Estrategia 2"; `docs/verificacion/integracion.md`, tabla de CPI |
| Argumento nuevo para D17 | 132 | "Por área, frecuencia y antenas se eligió la estrategia 1" | la ROM combinacional pasa de ser una ventaja de área a ser **condición** del pipeline: es lo que permite conocer la instrucción un ciclo antes y pedir la lectura del banco en el fetch. Con la memoria unificada en flip-flops la lectura es registrada y no se puede anticipar; si se forzara `EarlyRead = 1` ahí, la crítica sería el mux de 119 palabras hacia rs y el banco | `docs/pipeline.md`, sección 1, "Estrategia 2" |
| Argumento de las antenas | 132 | la estrategia 2 tenía 1 net con violación de antena | **la violación desaparece**: `s4_t100` (el core nuevo con `EarlyRead = 0` y el modelo de cable) cierra con **0 nets en violación** y 6 diodos que insertó el propio flujo, contra 0 nets y 1 diodo de la estrategia 1. Con eso el argumento de D17 ya no se puede apoyar en las antenas, y hay que apoyarlo en el área, la frecuencia y el CPI. **Cuidado al citar**: la corrida `e2_t100` que está en `asic/ff/resultados/` es del 25-10-2026, con el RTL y la configuración de v1, y sí tiene 1 net en violación (906.413 µm² de celdas, 19.332 pines de slew, 209 de capacitancia); no sirve de comparación | `asic/ff/resultados/s4_t100/metrics.json` (`antenna__violating__nets` 0, `antenna_diodes_count` 6) y `asic/ff/resultados/LEEME.md` |

### Tabla 3 (`tab:estrategias`)

Las 8 filas viejas se verifican una por una en `asic/barrido.md`, sección "Comparación de
estrategias (sección 3.2)", líneas 103 y 104 (corridas `s1_t100` y `s2_t100`, configuración de
D15). Las dos corridas de referencia **ya están hechas**: `s3_t100` para la estrategia 1 (reproduce la
corrida `final` métrica por métrica: mismo área, mismos 964 flip-flops, mismo die, mismo WNS) y
`s4_t100` para la estrategia 2 (`asic/ff/resultados/s4_t100/`). La tabla armada está en
`docs/datos_informe.md`, sección 3.2. Lo único que falta es el período mínimo de la estrategia 2:
`s4_t50` cierra con 6,939 ns de holgura y el barrido sigue bajando (`s4_t45`, `s4_t42`, `s4_t40`).

| dato | línea del `.tex` | valor viejo (estrategia 1 / estrategia 2) | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Área de celdas de síntesis | 118 | 146.400 / 693.901 µm² | estrategia 1: **156.098,48 µm²**; estrategia 2: **696.640,13 µm²** (4,5 veces) | `asic/rom/resultados/final/sintesis_stat.rpt` línea 232 y `asic/rom/resultados/s3_t100/sintesis_stat.rpt` línea 232 ("Chip area for top module '\asic_top': 156098.476800") y `asic/ff/resultados/s4_t100/sintesis_stat.rpt` línea 235 (696640.134400); viejo: `asic/barrido.md` línea 103 (146400.083) y `asic/ff/resultados/s2_t100/sintesis_stat.rpt` línea 231 (693900.524800) |
| Área de celdas tras place and route | 119 | 173.568 / 838.173 µm² | estrategia 1: **208.439 µm²**; estrategia 2: **977.015 µm²** (4,7 veces) | `design__instance__area__stdcell` de `asic/rom/resultados/final/metrics.json` (208439) y de `asic/ff/resultados/s4_t100/metrics.json` (977015); viejo: `asic/rom/resultados/s1_t100/metrics.json` (173568) y `asic/ff/resultados/s2_t100/metrics.json` (838173) |
| Flip-flops | 120 | 921 / 4.602 | estrategia 1: **964**; estrategia 2: **4.673** | `design__instance__count__class:sequential_cell` de `final` (964) y de `asic/ff/resultados/s4_t100/metrics.json` (4673); viejo: `s1_t100` 921 y `s2_t100` 4602 |
| Utilización real (pedida 40 %) | 121 | 47,5 % / 48,5 % | estrategia 1: **53,5 %** (`0,53511`); estrategia 2: **56,2 %** (`0,562228`) | `design__instance__utilization` de `final` (0,53511) y de `s4_t100` (0,562228); viejo: `s1_t100` 0,475391 y `s2_t100` 0,4848 |
| Área del die | 122 | 0,394 / 1,794 mm² | estrategia 1: **0,419 mm²** (419.131 µm², die 638,505 x 656,425 µm); estrategia 2: **1,802 mm²** (1.801.610 µm², die 1.333,31 x 1.351,23 µm), **4,3 veces** el de la 1 | `design__die__area` y `design__die__bbox` de `final` (419131) y de `asic/ff/resultados/s4_t100/metrics.json` (1801610, bbox 0 0 1333.31 1351.23); viejo: `s1_t100` 393525 y `s2_t100` 1794180 |
| Período mínimo que cierra timing | 123 | 55 / 62 ns | estrategia 1: **21,5 ns**; estrategia 2: **35 ns o menos** (el barrido `s4_*` cierra a 100, 65, 60, 55, 50, 45, 42, 40 y 35 ns; el punto de 30 ns no cabe en el corte de 40 minutos de la cola, dos intentos) | `asic/rom/resultados/f2_t21p5/cierre.md` (CIERRA, WNS 0,876 ns) y `asic/rom/resultados/co_rc_t21/metrics.json` (no cierra, WNS -0,129 ns); viejo: `asic/barrido.md` línea 103 y 104 |
| Frecuencia máxima | 124 | 18,2 / 16,1 MHz | estrategia 1: **46,51 MHz** (1 / 21,5 ns); estrategia 2: **28,57 MHz o más** (1 / 35 ns) | cálculo sobre el período mínimo de arriba; `docs/decisiones.md`, D23 ("el período mínimo baja de 24,5 a 21,5 ns") |
| Nets con violación de antena | 125 | 0 / 1 | estrategia 1: **0** (1 diodo); estrategia 2: **0** (6 diodos): la violación de la estrategia 2 desaparece con la configuración nueva | `asic/rom/resultados/final/metrics.json`, `antenna__violating__nets = 0` |
| Pie: la regla del barrido | 128 | "barrer `CLOCK_PERIOD` hasta dejar 2\,ns entre el último que cierra y el primero que no" | la regla de la sesión es **dejar 0,5 ns o menos**, y el barrido nuevo usa pasos de 0,5 ns (21, 21,5, 22, 23, 24, 25 ns) | `asic/exploraciones.md`, encabezado de la sesión del 27 y 28-10-2026: "período barrido hasta dejar 0,5 ns o menos entre el último período que cierra y el primero que no"; `docs/decisiones.md`, D23, viñeta "Contexto" |
| Pie: fuente | 128 | `asic/barrido.md` | `asic/barrido.md` (historia) más `asic/rom/resultados/s3_t100/` y `asic/ff/resultados/s4_*/`, con la tabla ya armada en `docs/datos_informe.md` sección 3.2 | |

### Párrafo de cierre de 3.2 (línea 132)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Diferencia de flip-flops entre estrategias | 132 | 3.681 más (los $119 \times 32 = 3.808$ bits de la memoria unificada menos los 128 de la RAM de datos) | **3.709 flip-flops más** (4.673 contra 964); la cuenta de 3.808 menos 128 sigue explicando el grueso, pero el ajuste cambia porque la estrategia 1 pasa a 964 flip-flops y la 2 arranca de otro RTL | `asic/rom/resultados/final/metrics.json` (964) |
| Área de la ROM y su porcentaje | 132 | 7.448 µm², el 4,7 % del diseño | **7.448 µm²** (igual), el **4,5 %** de la síntesis jerárquica nueva | `asic/sintesis.md`, fila `pochoco_rom`: 7.448 µm², 4,5 % de 164.605 |
| Cuántas veces más grande es el die de la estrategia 2 | 132 | 4,6 veces | **4,3 veces** (1.801.610 / 419.131), igual que antes por casualidad: los dos dies crecieron. Con el die de `s2_t100` contra el de la final nueva también salen 4,3 (1.794.180 / 419.131) | `asic/ff/resultados/s2_t100/metrics.json` y `asic/rom/resultados/final/metrics.json` |
| Área de celdas y de die de la estrategia 1 con la configuración final | 132 | 182.265 µm² de celdas y 0,409 mm² de die | **208.439 µm²** de celdas y **0,419 mm²** de die | `asic/rom/resultados/final/metrics.json` |
| Ruta crítica de la estrategia 2 | 132 | "es igual a la de la 1 hasta la dirección que calcula la ALU, pero sigue por la decodificación de esa dirección sobre las 119 palabras" | hay que revisarlo: la ruta crítica de la estrategia 1 ya no es la de la carga, así que la comparación con la 2 pierde su punto de partida. **Por medir** con `s4_t100` | `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt` para el lado de la estrategia 1 |

## Sección 3.3. Síntesis (líneas 135 a 188)

`LAYERS_RC` y la reparación post-GRT solo actúan en el place and route, así que **toda esta sección
depende únicamente del RTL nuevo** y sus cifras ya están medidas y regeneradas en `main`:
`asic/sintesis.md` se generó con `asic/analisis_sintesis.py` desde la corrida `final` y la síntesis
jerárquica `h3_t100`.

### Texto

| cambio | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Tag de la síntesis jerárquica | 139, 158 y 182 | `h2_t100` | **`h3_t100`** (el mapa dice `e1_h100`, que era el tag en la rama; en `main` es `h3_t100`) | `asic/rom/resultados/h3_t100/sintesis_jerarquica.rpt`; comando en `asic/sintesis.md`, sección "Método": `librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml -c SYNTH_HIERARCHY_MODE=keep --to Yosys.Synthesis --run-tag h3_t100` |
| Área aplanada contra jerárquica, y la brecha | 139 | "su área es 3,7 % menor (152.169 contra 157.980 µm²)" | **5,2 % menor: 156.098 contra 164.605 µm²** | `asic/rom/resultados/final/sintesis_stat.rpt` línea 232 (156098.476800) y `asic/rom/resultados/h3_t100/sintesis_jerarquica.rpt` línea 627 (164604.876800); viejo verificado en `v1_final/sintesis_stat.rpt` línea 230 (152169.068800) y `h2_t100/sintesis_jerarquica.rpt` línea 625 (157979.763200) |
| Módulos cuya jerarquía se conserva | 139 | register file, ALU y contador de ciclos (D12) | **no cambia** | `asic/rom/config.yaml`, líneas 17 a 20 |

### Tabla 4 (`tab:celdas`): las cinco celdas más usadas

Se rehace completa: cambian las cinco filas, el orden, los porcentajes y el pie.

| dato | línea del `.tex` | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Primera celda | 147 | `dffq_1`, 804, 15,7 % | **`nand2_1`, 934, 16,7 %** | `asic/sintesis.md`, tabla "Las 5 celdas más usadas"; `asic/rom/resultados/final/sintesis_stat.rpt` línea 203 |
| Segunda celda | 149 | `mux2_2`, 759, 14,8 % | **`mux2_2`, 889, 15,9 %** | ídem, línea 201 |
| Tercera celda | 151 | `nand2_1`, 758, 14,8 % | **`dffq_1`, 779, 14,0 %** | ídem, línea 199 |
| Cuarta celda | 153 | `oai21_1`, 309, 6,0 % | **`aoi21_1`, 437, 7,8 %** (celda nueva en las cinco primeras) | ídem, línea 193 |
| Quinta celda | 155 | `clkinv_1`, 284, 5,5 % | **`oai21_1`, 348, 6,2 %**; `clkinv_1` sale de las cinco primeras (queda en 283) | ídem, líneas 210 y 198 |
| Pie: total de celdas y de tipos | 158 | 5.118 celdas de 34 tipos | **5.577 celdas de 36 tipos** | `asic/sintesis.md`: "La corrida final tiene 5.577 celdas de 36 tipos"; conteo directo del bloque "design hierarchy" de `sintesis_stat.rpt`: 5.577 (final) y 5.118 (v1) |
| Pie: tag del reparto por módulo | 158 | "El reparto por módulo sale de `h2_t100`" | **`h3_t100`** | `asic/sintesis.md`, sección "Método" |
| Explicación de `dffq_1` | 147 | 544 del banco (480 bits más 64 de los dos puertos registrados), 192 de la memoria, 82 de la pre-decodificación; "la síntesis aplanada elimina 14 que valen siempre lo mismo" | 544 del banco, 192 de la memoria, 82 del decode registrado y **2 nuevos en la LSU** (`addr_q[1:0]`, el offset de byte de B2); total esperado desde el RTL **820**, jerárquica 820, final **779**: la aplanada elimina **41** al propagar constantes a través de los bordes de módulo | `asic/sintesis.md`, sección "3. `dffq_1`: desglose por módulo" |
| Explicación de `mux2_2` | 149 | 480 del banco, 160 de la memoria, 82 de la pre-decodificación | **796 del banco** (al mux de retención de cada uno de los 480 bits se le suman el mux del write-through y el habilitador de lectura; quedan 316 muxes funcionales), 160 de la memoria y **117 de la etapa ID** (los 82 de retención del decode, que ahora cargan solo si el pipeline avanza, `dec_load = ~stall_i`, más los muxes de operandos, de write-back y de `pc_target`); total jerárquico 1.139 | `asic/sintesis.md`, sección "2. `mux2_2`: desglose por módulo" |
| Explicación de `nand2_1` (fila que pasa a ser la primera) | 151 | "Yosys, con la estrategia de área, mapea sobre ella la lógica aleatoria: ALU, alineación de la LSU, decodificadores y ROM" | el argumento se mantiene, y conviene agregar el desglose nuevo, que explica por qué pasa al primer lugar: 265 en el register file (88 en v1), 106 en la ALU, **85 en la LSU** (6 en v1), 79 en la etapa ID, 74 en la ROM, 72 en los periféricos, 53 en el decodificador, 25 en el fetch, 13 en la memoria, 6 en el contador de ciclos, 4 en los debounce, 2 en el divisor y 1 en el bus (785 en la jerárquica) | `asic/sintesis.md`, sección "1. `nand2_1`: desglose por módulo"; v1 en `v1_final/sintesis_stat.rpt` líneas 120 y 152 |
| Explicación de `aoi21_1` (fila nueva) | 153 | no existía | AND-OR-inversor, lógica aleatoria: 190 en el register file, 53 en la ALU, 48 en la ROM, 40 en la etapa ID, 14 en el fetch, 10 en el contador de ciclos, 10 en la LSU, 4 en los periféricos, 3 en el decodificador y 3 en el divisor del debounce | `asic/sintesis.md`, sección "4. `aoi21_1`: desglose por módulo" |

### Tabla 5 (`tab:modulos`): área de celdas por módulo

Se rehace completa. Cambian tres áreas (register file, etapa ID y LSU) y los diez porcentajes,
porque el total sube. Todas las filas nuevas salen de `asic/sintesis.md`, sección "Área por módulo
(síntesis jerárquica)", y las viejas se verifican en las líneas 168 a 179 del `.tex`.

| módulo | línea del `.tex` | valor viejo (µm², %) | valor nuevo (µm², %) | archivo de origen |
|---|---|---|---|---|
| `espino_register_file` (`u_soc.u_core.u_rf`) | 168 | 73.656, 46,6 | **80.349, 48,8** | `asic/sintesis.md` |
| `espino_id_stage` (con ALU y decodificador) | 169 | 29.765, 18,8 | **29.589, 18,0** | ídem |
| `espino_alu` | 170 | 10.153, 6,4 | **10.153, 6,2** (el área no cambia) | ídem |
| `pochoco_mem_rom` (con la ROM) | 171 | 27.458, 17,4 | **27.458, 16,7** (el área no cambia) | ídem |
| `pochoco_rom` | 172 | 7.448, 4,7 | **7.448, 4,5** (el área no cambia) | ídem |
| `pochoco_periph` (con debounce y contador) | 173 | 14.409, 9,1 | **14.409, 8,8** (el área no cambia) | ídem |
| `pochoco_cycle_counter` | 174 | 3.943, 2,5 | **3.943, 2,4** (el área no cambia) | ídem |
| `espino_if_stage` | 175 | 8.511, 5,4 | **8.511, 5,2** (el área no cambia) | ídem |
| `espino_load_store_unit` | 176 | 2.711, 1,7 | **2.819, 1,7** (sube por los 2 flip-flops del offset de byte de B2 y su lógica) | ídem |
| Bus, sincronizador de reset y control | 177 | 1.470, 0,9 | **1.470, 0,9** (158 de `asic_top` más 1.242 de `pochoco_soc` más 70 de `espino_controller`) | ídem, filas `asic_top`, `pochoco_soc` y `espino_controller` |
| **Total** | 179 | **157.980, 100** | **164.605, 100** | `asic/rom/resultados/h3_t100/sintesis_jerarquica.rpt`, línea 627 |
| Fila que se podría agregar: `espino_decoder` | 169 (hoy va dentro de la etapa ID) | no existe como fila | 1.965 µm², 1,2 % | `asic/sintesis.md`, fila `espino_decoder` |
| Pie: tag | 182 | `h2_t100` | **`h3_t100`** | `asic/sintesis.md` |
| Descripción de la etapa ID en el pie o en la columna de función | 169 | "decode y ejecución" | `asic/sintesis.md` la describe ahora como "decode registrado en el flanco del fetch (EarlyRead), muxes de operandos, salto y write-back", y el register file como "banco de registros x1 a x15 con dos puertos de lectura registrados y write-through" | `asic/sintesis.md`, columna "función" |

### Párrafos de 3.3 (líneas 186 y 188)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Register file: área y porcentajes | 186 | 73.656 µm²: 46,6 % de la jerárquica y 48,4 % de la final, "donde conserva su jerarquía y mide lo mismo" | **80.349 µm²: 48,8 % de la jerárquica y 51,5 % de la final** (51,5 % de 156.098 µm²); sigue midiendo lo mismo en las dos síntesis, porque conserva su jerarquía | `asic/sintesis.md`: "en la corrida final el módulo conservado `espino_register_file` mide 80.349 µm² (51.5 % de 156.098 µm²)" |
| Contador de ciclos: porcentajes y fracción de flip-flops | 186 | 3.943 µm², 2,5 % de la jerárquica y 2,6 % de la final; 61 % de su área son sus 32 flip-flops con reset | **3.943 µm², 2,40 % de la jerárquica y 2,53 % de la final**; el 61 % sigue igual (2.388 de 3.943 µm², 32 `dffrnq_1`) | `asic/sintesis.md`, "Fracción del contador de ciclos" |
| Conteo de flip-flops contra el RTL | 188 | "818 sin reset y 186 con reset en la síntesis jerárquica, 990 en la final" | el RTL tiene **820 sin reset y 185 con reset (1.005)**; la jerárquica da 820 + 185 y la final **779 + 185 = 964** | `asic/sintesis.md`, "Comparación con lo esperado antes de sintetizar"; `asic/rom/resultados/final/metrics.json`, `design__instance__count__class:sequential_cell = 964` |
| Porcentaje del área que resulta ser el banco | 188 | 47 % (implícito en "el banco de registros dominara el área") | **49 %** | `asic/sintesis.md`: "Resultó el 49 % del área" |
| Expectativa sobre la celda más numerosa | 188 | "Se esperaba que ... los flip-flops fueran la celda más numerosa. Las dos cosas se cumplen" | **ya no se cumple**: ver el párrafo 6 de la sección de argumentos | `asic/sintesis.md`, última sección |

## Sección 3.4.1. Timing, barrido de período (líneas 195 a 223)

### Texto

| cambio | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Último período que cierra y primero que no | 197 | "cierra hasta 25 ns y no a 24 ns, donde falla por 0,004 ns en la esquina lenta" | **cierra hasta 21,5 ns y no a 21 ns, donde falla por 0,129 ns** (TNS -0,291 ns). Y el valor viejo de v1 está mal: v1 cierra a **24,5 ns** con WNS 0,496 ns, y 24 ns falla por 0,004 | nuevo: `asic/rom/resultados/f2_t21p5/cierre.md` (WNS 0,876 ns, CIERRA) y `asic/rom/resultados/co_rc_t21/metrics.json` (`timing__setup__ws` -0,1293, `timing__setup__tns` -0,2908); la corrida `f2_t21` de `main` ya terminó con código 0 y da los mismos valores (`asic/rom/runs/f2_t21/final/metrics.json`), pero sus reportes todavía no están copiados a `asic/rom/resultados/`. Viejo: `asic/final.md`, párrafo del barrido, y `asic/rom/resultados/f1_t24p5/metrics.json` (0,49598) |
| Frecuencia máxima | 197 | 40 MHz | **46,51 MHz** (1 / 21,5 ns); el valor correcto de v1 es 40,8 MHz | `docs/decisiones.md`, D23; `docs/modelo_cable.md`, sección 4, punto 1 ("la candidata a 21,5 ns, 46,5 MHz"); `asic/exploraciones.md`, fila `exp/candidata-rc`: 46.5 MHz |
| Corrida detenida por tiempo | 197 | "La corrida de 28 ns se detuvo a los 40 minutos y no tiene resultado, lo que no cambia el límite porque 26 y 25 ns cierran" | hay que rehacer la frase: las siete corridas del barrido con el modelo de cable completaron. `f1_t28` sigue siendo cierto como historia de v1 | `docs/modelo_cable.md`, sección 4 (las 11 filas tienen resultado); `asic/final.md`, línea del barrido, para `f1_t28` |
| MIPS (frase que conviene agregar aquí, hoy solo está en la Tabla 9) | 197 | 15,0 MIPS | **27,9 MIPS** (46,51 / 1,665); el valor corregido de v1 es 15,3 (40,82 / 2,665) | `docs/decisiones.md`, D23: "el MIPS sube de 15,3 a 27,9"; `asic/exploraciones.md`, filas `main (referencia)` y `exp/candidata-rc` |

### Tabla 6 (`tab:barrido`)

Se rehace completa. Cambian los puntos del barrido: hoy son 100, 32, 30, 26, 25 y 24 ns, y el
barrido nuevo medido es **100, 25, 24, 23, 22, 21,5 y 21 ns**. En `main` hay dos juegos de archivos
para los mismos puntos: los tags `co_rc_*` (la exploración de `exp/candidata-rc`, con el mismo RTL
y la misma configuración, reportes versionados en `asic/rom/resultados/co_rc_*/`) y los tags `f2_*`
(las corridas de reproducción en `main`). `f2_t21p5` ya está versionada y da **exactamente** los
mismos números que `co_rc_t21p5`; `f2_t21` y `f2_t22` terminaron con código 0 y reproducen
`co_rc_t21` y `co_rc_t22` al dígito. **El barrido `f2_*` está completo**: los siete puntos (100,
30, 25, 24, 23, 22, 21,5 y 21 ns, que son ocho contando el de 100 ns) tienen sus reportes en
`asic/rom/resultados/f2_*/`, así que la tabla se arma con ellos y se cita
`asic/rom/resultados/f2_*/metrics.json`; los `co_rc_*` quedan como la exploración que los
anticipó.

Columnas, en el orden del `.tex` (líneas 209 a 214): T, setup WNS y TNS en `nom_tt_025C_5v00`,
setup WNS y TNS en `max_ss_125C_4v50`, hold WNS y TNS en `nom_tt`, hold WNS y TNS en `max_ss`,
área de celdas estándar tras PnR y si cierra las nueve esquinas.

| fila | línea del `.tex` | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| 100 ns | 209 | 74,694 / 0 / 65,223 / 0 / 0,450 / 0 / 1,081 / 0 / 182.265 / sí | **74,404 / 0 / 65,725 / 0 / 0,442 / 0 / 1,065 / 0 / 208.439 / sí** | `asic/rom/resultados/final/metrics.json` y `cierre.md` |
| 32 ns | 210 | 17,409 / 0 / 4,395 / 0 / 0,450 / 0 / 1,081 / 0 / 183.725 / sí | **la fila desaparece**: con el modelo de cable no hay corrida de 32 ns (el barrido nuevo salta de 100 a 30 y 25 ns). `f2_t30` está encolada | `asic/final.md` para el valor viejo (`f1_t32`); `asic/logs/cola_estado.txt`, entrada 131 |
| 30 ns | 211 | 16,758 / 0 / 5,103 / 0 / 0,450 / 0 / 1,081 / 0 / 186.320 / sí | **16,460 / 0 / 4,924 / 0 / 0,442 / 0 / 1,065 / 0 / 219.059 / sí** | `asic/rom/resultados/f2_t30/metrics.json` y su `cierre.md`; `asic/final.md` (`f1_t30`) para el valor viejo |
| 26 ns | 212 | 13,160 / 0 / 1,996 / 0 / 0,450 / 0 / 1,081 / 0 / 189.817 / sí | **la fila desaparece**: el barrido nuevo no tiene punto en 26 ns | `asic/final.md` (`f1_t26`) |
| 25 ns | 213 | 12,160 / 0 / 0,996 / 0 / 0,450 / 0 / 1,081 / 0 / 189.817 / sí | **12,306 / 0 / 1,579 / 0 / 0,442 / 0 / 1,065 / 0 / 219.531 / sí** (reproducido por `f2_t25` al dígito) | `asic/rom/resultados/co_rc_t25/metrics.json` |
| 24 ns | 214 | 11,160 / 0 / $-0{,}004$ / $-0{,}004$ / 0,450 / 0 / 1,081 / 0 / 189.817 / **no** | **11,931 / 0 / 1,755 / 0 / 0,442 / 0 / 1,065 / 0 / 220.655 / sí** (reproducido por `f2_t24` al dígito) por terminar) | `asic/rom/resultados/co_rc_t24/metrics.json` |
| 23 ns (fila nueva) | tras 214 | no existe | **11,272 / 0 / 1,494 / 0 / 0,442 / 0 / 1,065 / 0 / 222.714 / sí** (reproducido por `f2_t23` al dígito) | `asic/rom/resultados/co_rc_t23/metrics.json` |
| 22 ns (fila nueva) | tras 214 | no existe | **10,358 / 0 / 0,656 / 0 / 0,442 / 0 / 1,065 / 0 / 224.767 / sí** | `asic/rom/resultados/co_rc_t22/metrics.json`; reproducido por `f2_t22` (`asic/rom/runs/f2_t22/final/metrics.json`, código 0) |
| 21,5 ns (fila nueva, el período mínimo) | tras 214 | no existe | **10,257 / 0 / 0,876 / 0 / 0,442 / 0 / 1,065 / 0 / 231.229 / sí** | `asic/rom/resultados/f2_t21p5/metrics.json` y `cierre.md` |
| 21 ns (fila nueva, la que no cierra) | tras 214 | no existe | **9,614 / 0 / $-0{,}129$ / $-0{,}291$ / 0,442 / 0 / 1,065 / 0 / 231.638 / no** | `asic/rom/resultados/co_rc_t21/metrics.json`; reproducido por `f2_t21` (`asic/rom/runs/f2_t21/final/metrics.json`, código 0) |
| Pie: corridas y fuente | 217 | "corridas `final` y `f1_*` ... Fuente: `asic/final.md`" | corridas `final` y **`f2_*`**; fuente: `asic/rom/resultados/f2_*/metrics.json`, con `docs/modelo_cable.md` sección 4 para la comparación contra el mismo barrido sobre el RTL de v1 | `docs/modelo_cable.md`, sección 4 |

Dato útil para el pie o para el texto: el hold en `nom_tt` y en `max_ss` es **idéntico en los siete
puntos del barrido** (0,442 y 1,065 ns), igual que en v1 (0,450 y 1,081), porque el hold no depende
del período.

### Párrafo de la reoptimización (línea 221)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Rango de área de celdas al bajar el período | 221 | de 182.265 µm² a 100 ns a 189.817 µm² a 26 ns | de **208.439 µm² a 100 ns a 231.229 a 21,5 ns** (231.638 a 21 ns), subiendo en cada punto: 219.531 a 25, 220.655 a 24, 222.714 a 23 y 224.767 a 22 ns | `design__instance__area__stdcell` de `asic/rom/resultados/{final,co_rc_t25,co_rc_t24,co_rc_t23,co_rc_t22,f2_t21p5,co_rc_t21}/metrics.json` |
| "De 26 ns para abajo el layout es idéntico" | 221 | cierto en v1: `f1_t26`, `f1_t25`, `f1_t24p5` y `f1_t24` tienen 8.708 celdas, 189.817 µm² y 354.897 µm de cables | **falso con la configuración nueva**: ver el párrafo 1 de la sección de argumentos | `asic/final.md`, párrafo del barrido; `metrics.json` de las corridas nuevas |

### Párrafo de la configuración del flujo (línea 223)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Celdas de retardo `dly*` en la ruta crítica a 60 ns | 223 | 12 celdas (D15) | **se conserva como historia** | `docs/decisiones.md`, D15; `asic/barrido.md` |
| Circuito idéntico en todos los períodos con la configuración del PDK | 223 | 173.568 µm² de 100 a 40 ns en el barrido `s1_*` | **se conserva como historia** (verificado: `asic/rom/resultados/s1_t100/metrics.json` da 173568) | `asic/barrido.md` |
| Efecto de D20 | 223 | "el período mínimo bajó de 42 a 25 ns y las violaciones de max slew de 2.201 a 546 pines" | el período mínimo bajó de 42 a **24,5** ns (corrección de v1), y la cadena sigue: a 25,5 ns con el pipeline nuevo y a 21,5 ns con el modelo de cable. El slew baja de 2.201 a 546 y de ahí a **0** | `asic/rom/resultados/p1_t100/metrics.json` (2201 pines, 181.137 µm²), `v1_final/metrics.json` (546) y `final/metrics.json` (0); `asic/exploraciones.md`, filas `exp/pipeline-b2` (25,5 ns) y `exp/candidata-rc` (21,5 ns) |
| "Esas violaciones no son criterio de cierre ... 5,41 ns dentro de los 7 ns de la biblioteca" | 223 | peor slew 5,41 ns en la esquina lenta, límite del flujo 3 ns | **el argumento se cae**: 0 violaciones en las nueve esquinas. El 5,414 ns es verificable pero es de v1 | `asic/rom/resultados/v1_final/layout/slew.txt` (546 pines en 520 celdas, peores: `u_soc.u_core.u_rf/fanout35` y `fanout34` con 5,414 ns) y `asic/rom/resultados/final/layout/slew.txt` (0 pines en 0 celdas) |
| Párrafo nuevo: el modelo de cable | tras 223 | no está en el informe | tech LEF 0,2752 ohm/µm y 64,3 aF/µm contra 0,599 / 0,549 / 0,498 ohm/µm y 188,4 / 166,3 / 148,0 aF/µm medidos (max / nom / min) por regresión sobre 2.399 nets; factores 2,93 / 2,59 / 2,30 en capacidad y 2,18 / 1,99 / 1,81 en resistencia. Tabla del tech LEF por capa: Metal1 0,39130 ohm/µm y 9,2000e-05 pF/µm, Metal2 y Metal3 y Metal4 0,32143, Metal5 0,13636 | `asic/modelo_cable.md`, secciones 1 y 2; `docs/modelo_cable.md`, secciones 1 a 3; `asic/rom/config.yaml`, comentario de las líneas 61 a 80 |
| Párrafo nuevo: las 0 violaciones de slew, en qué corridas | tras 223 | no está | **0 violaciones de max slew en las nueve esquinas a 100 ns y a 21,5 ns**; 1 de capacitancia, que es la raíz del árbol de reloj. Pero **no** en todo el barrido: la serie de los ocho puntos es 0 (100 ns), 4 (30), 0 (25), 4 (24), 4 (23), 0 (22), 0 (21,5) y 6 (21, el punto que no cierra) | `design__max_slew_violation__count` de `final` y de cada `f2_*/metrics.json`; `docs/modelo_cable.md`, sección 4, tabla |
| Párrafo nuevo: el mismo flujo sobre el RTL de v1 | tras 223 | no está | la configuración se corrió sobre los **dos** RTL, para que la comparación fuera del diseño y no de la herramienta: el de v1 cierra a 22 ns (45,5 MHz, 17,1 MIPS, 214.348 µm²; a 21,5 falla por 0,383 ns) y el nuevo a 21,5 ns (46,5 MHz, 27,9 MIPS). El nanosegundo de desventaja que el pipeline nuevo tenía con la configuración de v1 (25,5 contra 24,5 ns) era de la herramienta | `docs/modelo_cable.md`, sección 4, tabla y punto 2 (tags `co_rcm_*` en `asic/main_rc/resultados/`); `asic/exploraciones.md`, fila "main con LAYERS_RC"; `asic/rutas.md`, sección `co_rcm_t22` |

## Sección 3.4.2. Timing, ruta crítica (líneas 225 a 246)

Se rehace completa: es otra ruta. Y conviene decir que **hay dos rutas críticas distintas según el
período**, porque es lo que explica el diseño nuevo.

### Texto

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Corrida cuya ruta se describe | 227 y 242 | 25 ns, `f1_t25` | **21,5 ns, `f2_t21p5`** (el período mínimo). Nota: la ruta de v1 a su período mínimo real, 24,5 ns, es la misma celda por celda que la de `f1_t25`, porque las dos corridas tienen el mismo layout; solo cambia el requerido (26,280 contra 26,780 ns) y el slack (0,496 contra 0,996 ns) | `asic/rutas.md`, sección "Corrida final nueva al periodo minimo (f2_t21p5, 21,5 ns)"; v1 en la sección "Periodo minimo de v1 (f1_t24p5, 24,5 ns; historia)" |
| Flip-flop de inicio | 227 | `_4189_`, que guarda `alu_operator[1]` en la etapa ID (`dffq_1`) | **`_4136_`** (`dffq_4`), que guarda `u_soc.u_core.u_id.alu_op_a_sel[2]`, también un bit del registro de decode de la etapa ID | `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt`, línea 1 del camino; netlist `asic/rom/runs/f2_t21p5/final/nl/asic_top.nl.v`, línea 28905 |
| Flip-flop de llegada | 227 | `u_soc.u_core.u_rf/_2933_`, un bit de un registro del register file | **`_4440_`** (`dffrnq_1`), que es **`u_soc.u_periph.digit_q[4]`**, un bit del registro del display | netlist de `f2_t21p5`, línea 29924: `.Q(\u_soc.u_periph.digit_q[4])` |
| Señal intermedia de la ALU | 227 | `lsu_addr[1]` | **`u_soc.u_core.lsu_addr[31]`** | `asic/rutas.md`, tabla de `f2_t21p5` |
| Qué camino es | 227 y 246 | el camino de una carga: ejecución, acceso a memoria (alineación) y write-back | **un store al periférico**: ejecución (la ALU calcula la dirección), decodificación de la dirección del bus junto con `u_soc.u_core.lsu_we`, y habilitación del registro DISP. La alineación de la carga salió de la ruta por B2 | netlist de `f2_t21p5`, línea 28693 (`nand3_4 _4079_` con entradas `u_soc.u_core.lsu_we`, `_1838_` y `_0467_`) y línea 28751 (`oai21_2 _4094_` que produce `_0357_`, el pin D de `_4440_`) |
| Total de celdas de la ruta | 227 | 25 celdas numeradas más 3 buffers de reloj | **39 celdas numeradas** (el flip-flop de inicio, 37 combinacionales y el flip-flop de llegada) más **3** del camino de reloj (`clkbuf_0_clk`, `clkbuf_4_5_0_clk`, `clkbuf_leaf_14_clk`) | `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt`, encabezado: "39 celdas numeradas; 3 celdas del camino de reloj" |

### Tabla 7 (`tab:ruta`)

Los tramos se rehacen con el reparto que ya calcula `asic/ruta_tramos.py` y que está publicado en
`asic/rutas.md`. Nota sobre las columnas: hoy la tabla tiene celdas, retardo y llegada; en
`asic/rutas.md` las columnas son celdas, retardo y "hasta", y la llegada es la suma acumulada.

| tramo | línea del `.tex` | valor viejo (celdas, retardo, llegada) | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Árbol de reloj hasta el flip-flop de inicio | 235 | 3, 2,66, 2,66 | **3, 2,673, 2,673** (hasta `_4136_/CLK`) | `asic/rutas.md`, tabla de `f2_t21p5` |
| Reloj a salida del flip-flop de inicio | 236 | 1 (`_4189_`, `dffq_1`), 2,34, 5,00 | **1 (`_4136_`, `dffq_4`), 1,830, 4,503** | ídem |
| Mux del operando A y lógica aplanada de la etapa ID | 237 (reemplaza el tramo de la ALU) | no existe como tramo separado | **9, 4,267, 8,770** (hasta `_2844_/ZN`, que es `u_soc.u_core.u_id.operand_a[26]`); pasa por `u_soc.u_core.u_id.alu_op_a_sel[2]`, `net935`, `_1023_`, `net1430`, `net768`, `net767`, `net1103`, `net997` y `_1050_` | ídem, fila "lógica aplanada" |
| ALU (`u_soc.u_core.u_id.u_alu`) | 237 | 9, 9,50, 14,49 (hasta `lsu_addr[1]`) | **18, 9,048, 17,818** (hasta `u_soc.u_core.lsu_addr[31]`) | ídem |
| Alineación de la carga y mux de write-back | 238 | 12, 9,74, 24,23 | **el tramo desaparece**: B2 lo sacó de la ruta | `asic/rutas.md`; `docs/propuesta_d23.md` y `asic/exploraciones.md`, sección "B2: exp/lsu-offset" |
| Decodificación de la dirección del bus y habilitación del registro del display | nuevo, en lugar de 238 | no existe | **10, 4,417, 22,235** (de `lsu_addr[31]` a `_4440_/D`); pasa por `net117`, `_0384_`, `_1838_`, `_1980_`, `_1982_`, `net938`, `net24`, `net1126`, `_1986_` y `_0357_` | `asic/rutas.md`, tabla de `f2_t21p5`; `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt`, celdas 29 a 38 |
| Entrada al banco (buffer y mux de retención) | 239 | 2, 1,55, 25,78 | **el tramo desaparece**: el endpoint ya no está en el banco | `asic/rutas.md` |
| Pie: llegada, requerido y slack | 242 | llegada 25,784 ns (pie: antes de 26,78 ns, slack 1,00 ns) | **llegada 22,235 ns, requerido 23,111 ns, slack 0,876 ns**; el requerido se arma con el período 21,500, la latencia del reloj de captura +2,385, la incertidumbre $-0{,}250$, el pesimismo de reconvergencia +0,116 y el setup de biblioteca $-0{,}640$ | `asic/rutas.md`, bloque "Cálculo del tiempo requerido" de `f2_t21p5`; `asic/rom/resultados/f2_t21p5/max_ss_125C_4v50_ruta_critica.rpt` |
| Pie: corrida y archivo | 242 | `f1_t25`, `asic/rom/resultados/f1_t25/max_ss_125C_4v50_ruta_critica.rpt` | **`f2_t21p5`**, `asic/rom/resultados/f2_t21p5/max_ss_125C_4v50_ruta_critica.rpt` | |

### Párrafo o tabla adicional: la ruta crítica a 100 ns

No está hoy en el informe y conviene agregarla, porque es la ruta que **crea** `EarlyRead` y la que
justifica el diseño. Todos los datos de `asic/rutas.md`, sección "Corrida final nueva a 100 ns (tag
final)":

| tramo | celdas | retardo (ns) | hasta |
|---|---|---|---|
| árbol de reloj | 3 | 2,647 | `_4287_/CLK` |
| reloj a Q del flip-flop de inicio (`_4287_`, `dffrnq_1`, cuya Q es `u_soc.g_mem_rom.u_mem.a_addr_i[2]`, un bit del PC) | 1 | 1,877 | `_4287_/Q` |
| ROM combinacional y lógica aplanada | 13 | 12,355 | `_2258_/ZN`, que es `u_soc.g_mem_rom.u_mem.a_next_o[17]` |
| árbol de lectura del register file | 19 | 19,154 | `u_soc.u_core.u_rf/_2889_/ZN` |
| pin D del flip-flop de llegada (`u_soc.u_core.u_rf/_4123_`, cuya Q es `u_soc.u_core.rf_rdata_a[25]`) | 0 | 0,000 | `u_soc.u_core.u_rf/_4123_/D` |
| **total (llegada)** | | **36,033** | requerido 101,758; slack 65,725 |

La identidad de los dos flip-flops se verifica en el netlist de la corrida final
(`asic/rom/runs/final/final/nl/asic_top.nl.v`, líneas 30522 y 43537).

## Sección 3.4.3. Cambio al RTL (líneas 248 a 289)

Es la subsección que más hay que reescribir: la pre-decodificación (D18, D19) queda **contenida**
en un cambio mayor y D22 queda reemplazada por D23.

### Texto

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Tramo del decodificador en la ruta de partida | 250 | 19,1 de 55,1 ns en `s1_t55` | **no cambia** (historia de D18) | `asic/barrido.md`; `asic/rom/resultados/s1_t55/` |
| Ciclo de espera y número de ciclos por instrucción | 250 | "toda instrucción pasa un ciclo esperando la lectura sincrónica del banco" y "ninguna instrucción cambia su número de ciclos" | **se cae**: ver el párrafo 3 de la sección de argumentos. Dos ciclos por instrucción (tres las cargas y los saltos tomados) pasan a **uno, dos y dos** | `docs/pipeline.md`, sección 1 |
| Bits de decode registrado | 250 | 82 bits (operación y operandos de la ALU, inmediatos, señales de salto, de la LSU y de write-back) | **82 bits** (siguen igual), más **2** en la LSU por B2 | `asic/sintesis.md`, desglose de `dffq_1`: `alu_operator` 4, `alu_op_a_sel` 2, `alu_op_b_sel` 1, `imm_operand` 32, `imm_target` 32, `rf_we` 1, `rf_wd_sel` 2, `is_branch`/`is_jal`/`is_jalr` 3, `lsu_req`/`lsu_we` 2, `lsu_type` 2, `lsu_sign` 1 |
| CPI del juego | 250 y 279 | 2,665 | **1,665** (1.595.814 ciclos / 958.358 instrucciones retiradas); `isa_test.s` pasa de 2,953 a 1,969; `hazard_test.s` 1,769 y `hazard_review.s` 1,815; con la estrategia 2 el CPI sigue siendo 2,665 | `docs/verificacion/integracion.md`, sección "CPI medido en la integración" |
| Verificación contra el RTL anterior | 269 | `make equiv` con trazas idénticas ciclo a ciclo con 116fa20 | equivalencia **funcional**: ver el párrafo 4 de la sección de argumentos | `docs/verificacion/integracion.md`, comprobaciones 2 a 12 |
| Cuánto acorta la pre-decodificación y cuánto cuesta | 269 | 13,0 ns (D15) y 10,7 ns (final); período de 55 a 42 ns; 4,4 % de área; 69 flip-flops más | **se conservan como historia de D18**, y hay que agregar el efecto del pipeline nuevo: CPI de 2,665 a 1,665; período de 24,5 a 25,5 ns con la configuración anterior y a **21,5 ns** con el modelo de cable; **964** flip-flops, 26 menos que v1 (el registro de instrucción pierde 28 bits, porque con `EarlyRead` solo se usa `instr_rdata_i[10:7]`, y B2 agrega 2) | `docs/pipeline.md`, sección 1, párrafo "Efecto en la síntesis" (962 flip-flops en `exp/pipeline`, antes de B2); `asic/exploraciones.md`, filas `exp/pipeline-b2` y `exp/candidata-rc` |
| Argumento de cierre | 289 | "Ninguno se incorporó a la corrida final (D22)" | **D23 reemplaza a D22**: ver el párrafo 5 de la sección de argumentos | `docs/decisiones.md`, D23 |
| Párrafo nuevo posible: variantes de signoff descartadas | tras 289 | no está | `exp/signoff0` llega a 0 violaciones de slew con el RTL de B2+B5, pero cuesta 7,5 % de área y empeora el período (177.807 µm², 24 ns); `sc_g30` baja a 214 pines con 0,64 % de área pero no cierra a 24 ns; la variante de cero slew de la candidata da 0 slew y 0 capacitancia con 209.185 µm² (114,8 % del área de v1) | `asic/exploraciones.md`, filas "exp/signoff0, cero slew", "exp/signoff0, g30" y "exp/candidata, variante de cero slew" |

### Tabla 8 (`tab:predeco`)

Las cuatro filas de historia se verifican y **no cambian**; hay que corregir el T mínimo de la
cuarta y agregar dos filas.

| fila | línea del `.tex` | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Sin pre-decodificación, flujo D15 | 258 | WNS 46,76, área 173.568, 921 flip-flops, T mínimo 55 | **igual** (verificado: `s1_t100` da WNS 46,764 en `max_ss` y 173.568 µm², 921 flip-flops) | `asic/rom/resultados/s1_t100/metrics.json`; `asic/barrido.md` |
| Con pre-decodificación, flujo D15 | 259 | WNS 59,75, área 181.137, 990, T mínimo 42 | **igual** (verificado: `p1_t100` da 59,754 y 181.137, 990) | `asic/rom/resultados/p1_t100/metrics.json`; `asic/barrido.md` |
| Sin pre-decodificación, flujo final | 261 | WNS 54,55, área 174.529, 921, T mínimo $> 26$ | **igual** (`r0_t100`: 54,552 y 174.529; `r0_t26` no cierra con WNS $-3{,}175$). Conviene aclarar que esa línea base queda a dos cambios de RTL de distancia | `asic/final.md`, sección "RTL sin pre-decodificación (116fa20)" |
| Con pre-decodificación, flujo final (la corrida final de v1) | 262 | WNS 65,22, área 182.265, 990, T mínimo 25 | **T mínimo 24,5** (corrección de v1); el resto igual | `asic/final.md`, párrafo del barrido; `asic/rom/resultados/f1_t24p5/metrics.json` |
| Fila nueva: pipeline nuevo (A+B2), flujo final anterior | tras 262 | no existe | WNS 65,7 (a 100 ns), área **186.432**, flip-flops **964**, T mínimo **25,5 ns** | `asic/exploraciones.md`, fila `exp/pipeline-b2 (A+B2)` y fila `exp/candidata (A+B2, paquete completo)` |
| Fila nueva: pipeline nuevo más modelo de cable (la corrida final) | tras 262 | no existe | WNS **65,725**, área **208.439**, flip-flops **964**, T mínimo **21,5 ns** | `asic/rom/resultados/final/{cierre.md,metrics.json}` y `asic/rom/resultados/f2_t21p5/cierre.md` |
| Pie: corridas y fuente | 265 | corridas `s1_*`, `p1_*`, `r0_*` y `f1_*`; fuente `asic/barrido.md` y `asic/final.md` | agregar `pa_*`/`co_rc_*`/`f2_*` y las fuentes `asic/exploraciones.md` y `docs/modelo_cable.md` | |

### Tabla 9 (`tab:otros`)

| fila | línea del `.tex` | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Corrida final (`main`) | 279 | 25 ns, 182.265 µm², CPI 2,665, 15,0 MIPS | **dos filas**: v1 corregido (24,5 ns, 182.265 µm², CPI 2,665, **15,3 MIPS**) y la final nueva (**21,5 ns, 208.439 µm², CPI 1,665, 27,9 MIPS**) | `asic/exploraciones.md`, filas `main (referencia)` y `exp/candidata-rc`; `docs/decisiones.md`, D23 |
| B2: offset de byte registrado en la LSU (`exp/lsu-offset`) | 280 | 24 ns, 181.170 µm², CPI 2,665, 15,6 MIPS | **las cifras no cambian**, pero la fila cambia de sentido: B2 está **dentro** de la corrida final | `asic/exploraciones.md`, fila `exp/lsu-offset (B2)`; `docs/decisiones.md`, D23 |
| B3: comparador de saltos (`exp/branch-cmp`) | 281 | 26 ns, 183.962 µm², CPI 2,665, 14,4 MIPS | **no cambia** | `asic/exploraciones.md`, fila `exp/branch-cmp (B3)` |
| B4: una instrucción por ciclo (`exp/cpi`) | 282 | 60 ns, 158.024 µm², CPI 1,312, 12,7 MIPS | **no cambia**, pero el argumento sí: ahora existe una opción que baja el CPI sin pagar período, y B4 queda como el contraejemplo | `asic/exploraciones.md`, fila `exp/cpi (B4)` |
| Filas nuevas de la sesión del 27 y 28-10 | tras 282 | no existen | A (`exp/pipeline`) 26 ns, 186.087 µm², CPI 1,665, 23,1 MIPS; A+B2 (`exp/pipeline-b2`) 25,5 ns, 186.432, 1,665, 23,6; A+B5 (`exp/pipeline-b5`) 29 ns, 165.211, 1,665, 20,7; B5 (`exp/rf-latch`) 26 ns, 165.369, 2,665, 14,4; B2+B5 (`exp/fmax`) 23,5 ns, 165.358, 2,665, 16,0; B2+B5 con reparación post-GRT 23,25 ns, 165.358, 2,665, 16,1; v1 con `LAYERS_RC` 22 ns, 201.309, 2,665, 17,1; candidata con `LAYERS_RC` 21,5 ns, 208.439, 1,665, 27,9 | `asic/exploraciones.md`, tabla resumen (20 filas, generada por `python3 asic/tabla_sesion.py asic/ramas_sesion.json --md asic/exploraciones_tabla.md`) |
| Pie: aclaraciones | 285 | "B3 no se corrió a 25 ns y B4 no cierra a 55 ns" | agregar que el período de todas las filas se barrió con la regla de 0,5 ns, y que la columna de potencia con actividad real solo está medida para v1 (12,76 mW, ventana de espera de 3 s) y para la candidata sin modelo de cable (12,39 mW, ventana de polling): son **ventanas distintas** y no son comparables entre sí | `asic/exploraciones.md`, nota de la columna de potencia y notas de las filas |

### Párrafo de B2, B3 y B4 (línea 289)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| "B2 es el único que mejora el período (24 ns)" | 289 | cierto respecto de los 25 ns del `.tex` | con el período corregido de v1 (24,5 ns) B2 mejora **medio** nanosegundo, no uno; y la frase hay que reescribirla porque B2 ya está adentro | `asic/exploraciones.md`, filas `main (referencia)` y `exp/lsu-offset (B2)` |
| "El período sube 2,4 veces y rinde 15 % menos MIPS" (B4) | 289 | 60/25 = 2,4 y 12,7/15,0 = 15 % menos | con el v1 corregido: **2,45 veces** (60/24,5) y **17 % menos** (12,7/15,3); contra la corrida final nueva, 2,8 veces y 54 % menos MIPS | cálculo sobre `asic/exploraciones.md` |
| "aunque ahorra 13 % de área" (B4) | 289 | 158.024 contra 182.265 µm² | sigue siendo 13 % contra v1; contra la corrida final nueva es **24 %** (158.024 contra 208.439) | `asic/exploraciones.md`; `asic/rom/resultados/final/metrics.json` |

## Sección 3.4.4. Constantes del juego para T = 100 ns (líneas 291 a 314)

**No cambia ninguna cifra.** La corrida final sigue a $T = 100$ ns, así que $f = 10$ MHz,
`CYCLES_PER_TENTH` = 1.000.000, `CLK_HZ` pasa de 25.000.000 a 10.000.000 y la expansión de
`li x12` sigue siendo `lui x12, 0xF4` más `addi x12, x12, 576`.

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Las cuatro palabras de la ROM (Tabla 10) | 306 a 309 | `0x0148` `00262637` a `000f4637`; `0x014c` `5a060613` a `24060613`; `0x019c` y `0x01a0` iguales | **no cambian** | `rtl/gen/pochoco_rom.v`, líneas 101, 102, 122 y 123: `7'd82 : data_o = 32'h000f4637; // 0x0148: lui x12, 0xf4`, `7'd83 : data_o = 32'h24060613; // 0x014c: addi x12, x12, 576`, `7'd103` y `7'd104` iguales |
| Commit citado en el pie de la Tabla 10 | 312 | commit `5d57856` | **revisar**: `5d57856` ("Constantes del juego para T = 100 ns (10 MHz)") es el commit donde las palabras cambiaron, pero el archivo que hay hoy se escribió en **`dc316f3`** ("Trazabilidad: ROM generada completa, contador de ciclos como módulo y jerarquía conservada (D11 a D13)"), que es el último commit que lo toca. La integración (`d974a9f`) no lo modificó | `git log --oneline -- rtl/gen/pochoco_rom.v`: una sola entrada, `dc316f3` |
| `DebounceDivBits = 15` y los tiempos del debounce | 98 (se cita desde 3.1) | muestra cada 3,3 ms, cambio aceptado en unos 10 ms | **no cambian** | `docs/decisiones.md`, D10 |

## Sección 3.5.1. Floorplan, utilización y área mínima (líneas 321 a 350)

### Texto

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Utilización que da el área mínima y ese die | 323 | 70 %, die de 480,0 x 497,9 µm, 0,239 mm² | **corrección de v1: 78 %**, die 455,4 x 473,3 µm = 215.545 µm² (0,216 mm²), utilización real 90,3 %, WNS 59,602 ns, hold 0,182 ns. Con la configuración nueva la máxima que cierra es **73 %**, con die 476,1 x 494,1 µm = 235.237 µm² (0,235 mm²), utilización real 91,8 % y WNS 59,531 ns (`u2_u73/metrics.json` y su `cierre.md`): baja de 78 a 73 porque el diseño nuevo tiene 14 % más área de celdas | `asic/final.md`, sección del barrido de `FP_CORE_UTIL`; `asic/rom/resultados/u1_u78/metrics.json` (`design__die__bbox` 0 0 455.395 473.315, `design__die__area` 215545, `design__instance__utilization` 0,903302) |
| Primera utilización que falla y en qué paso | 323 y 335 a 336 | 80 % falla en el placement detallado durante el CTS; 90 % no cabe en el core | **corrección de v1: 79 % ya falla en el CTS** (`[DPL-0036]`, con 6 instancias del banco de registros sin lugar al legalizar tras insertar los buffers del reloj) y 80 % también (22 instancias); 90 % falla en el placement global (`[GPL-0301] Utilization 100.531 % exceeds 100%`). Con la configuración nueva **la primera que falla es 74 %**, y no en el CTS sino en `OpenROAD.RepairDesignPostGRT` (paso 41, el que agrega D23), con 18 instancias sin lugar; 78 % es la que falla en el CTS (36 instancias) y 80 % cae todavía antes, en `OpenROAD.RepairDesignPostGPL` (paso 32, 5 instancias) | `asic/rom/resultados/u2_u74/falla.txt`, `u2_u78/falla.txt` y `u2_u80/falla.txt`; v1 en `asic/rom/resultados/u1_u79/falla.txt` (líneas 5 a 8: `[INFO DPL-0034] Detailed placement failed on the following 6 instances`, `u_soc.u_core.u_rf/_2001_`), `u1_u80/falla.txt` y `u1_u90/falla.txt` |
| Cuántos puntos queda la utilización real sobre la pedida | 323 | 8 a 11 puntos | con v1 corregido van de 8 a 12 puntos (40 a 48,0; 78 a 90,3); con la configuración nueva van de **13,5 a 19,7 puntos** (40 a 53,5; 50 a 65,3; 60 a 76,9; 70 a 88,7; 72 a 91,7; 73 a 91,8), porque el resizer agrega celdas después del floorplan | `asic/final.md`, columna "utilización"; `asic/rom/resultados/final/metrics.json` |
| Mensaje de falla del placement global | 339 | `[GPL-0301] Utilization 100.531 % exceeds 100%` | **`[GPL-0301] Utilization 100.620 % exceeds 100%`** (169.186,876 µm² de instancias movibles sobre un core más chico) | `asic/rom/resultados/u2_u90/falla.txt`; `u1_u90/falla.txt` línea 12 para el valor viejo |
| Mensaje de falla del CTS | 339 | `[DPL-0036] Detailed placement failed` | sigue siendo `[DPL-0036] Detailed placement failed`, pero con la configuración nueva hay que citar **`u2_u78`** para el caso del CTS (`cts.tcl:102`, 36 instancias) y **`u2_u74`** para el límite real del barrido (`repair_design_postgrt.tcl:48`, 18 instancias) | `asic/rom/resultados/u2_u78/falla.txt` línea 44 y `u2_u74/falla.txt` línea 26 |
| Texto nuevo que explica el crecimiento del die | 321 a 323 | no está | el die crece de 408.957 a 419.131 µm² (+2,5 %) porque `FP_CORE_UTIL = 40` lo dimensiona sobre el **área de síntesis**, que sube de 152.169 a 156.098 µm² (+2,6 %); el core pasa de 379.800 µm² en 157 filas de 1.102 sitios a **389.525 µm² en 159 filas de 1.116 sitios**. El área que agregan los buffers del resizer cabe dentro y solo sube la utilización real | `asic/rom/resultados/final/metrics.json` (`design__core__area` 389525, `design__core__bbox` 6.72 15.68 631.68 638.96); `docs/datos_informe.md`, línea 55 (mensajes IFP-0001 e IFP-0102 de `13-openroad-floorplan`) |

### Tabla 11 (`tab:util`)

Columnas: pedida, die en µm, die en mm², utilización real, WNS de setup en `max_ss_125C_4v50` y
resultado. **El barrido `u2_*` ya está corrido completo** (entradas 132 a 139 y 153 a 154 de
`asic/logs/cola_estado.txt`): cierran 40, 50, 60, 70, 72 y 73 por ciento, y fallan 74, 75, 78, 80 y
90. La tabla del informe hay que rehacerla entera, con dos filas nuevas (72 y 73 %) y sin la de
79 %, que era de v1. Los valores viejos se verifican todos en `metrics.json` de las corridas `u1_*`.

| fila | línea del `.tex` | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| 40 % | 331 | 630,6 x 648,5 / 0,409 / 48,0 % / 65,22 | **638,5 x 656,4 / 0,419 / 53,5 % / 65,725** | `asic/rom/resultados/final/metrics.json` (`design__die__bbox` 0 0 638.505 656.425, `design__die__area` 419131, `design__instance__utilization` 0,535110) y `cierre.md` |
| 50 % | 332 | 565,4 x 583,4 / 0,330 / 59,2 % / 67,72 | **572,5 x 590,4 / 0,338 / 65,3 % / 63,697** | `u2_u50/metrics.json` (bbox 572.515 590.435, área 338033, util 0,653222); viejo: `u1_u50/metrics.json` (565.445 583.365, 329861, 0,591755, 67,716) |
| 60 % | 333 | 517,3 x 535,3 / 0,277 / 70,1 % / 63,68 | **523,8 x 541,7 / 0,284 / 76,9 % / 65,117** | `u2_u60/metrics.json` (523.805 541.725, 283758, 0,768834); viejo: `u1_u60/metrics.json` (517.345 535.265, 276917, 0,701152, 63,675) |
| 70 % | 334 | 480,0 x 497,9 / 0,239 / 80,9 % / 64,08 | **485,9 x 503,9 / 0,245 / 88,7 % / 60,805** | `u2_u70/metrics.json` (485.945 503.865, 244851, 0,886704); viejo: `u1_u70/metrics.json` (479.965 497.885, 238967, 0,809013, 64,076) |
| 72 % (fila nueva) | tras 334 | no existe | **479,3 x 497,3 / 0,238 / 91,7 % / 61,351** | `u2_u72/metrics.json` (479.335 497.255, 238352, 0,916600); v1: `u1_u72/metrics.json` (473.44 491.36, 232629, 0,834286, 65,715) |
| 73 % (fila nueva, **la del die mínimo que cierra**) | tras 334 | no existe | **476,1 x 494,1 / 0,235 / 91,8 % / 59,531** | `u2_u73/metrics.json` (476.135 494.055, 235237, 0,917614) y `u2_u73/cierre.md`: CIERRA |
| 74 % (fila nueva) | tras 334 | no existe | **falla** en `OpenROAD.RepairDesignPostGRT` (paso 41, el que agrega D23) con `[DPL-0036]` y 18 instancias sin lugar. Es el primer punto que no cierra, así que la resolución del barrido queda en 1 punto de utilización | `u2_u74/falla.txt`, líneas 6 y 26 |
| 75 % | tras 334 | no existe | **falla** en el mismo paso con 77 instancias sin lugar | `u2_u75/falla.txt`, línea 6; la línea del error está en `asic/logs/u2_u75.log` 18737 porque el extracto se corta en 40 líneas |
| 78 % (en v1 era la de área mínima) | tras 334 | no existe | **falla** en `OpenROAD.CTS` (paso 35) con 36 instancias sin lugar, 19 del banco de registros; v1: 455,4 x 473,3 / 0,216 / 90,3 % / 59,60 | `u2_u78/falla.txt`, líneas 6 y 44; v1 en `u1_u78/metrics.json` |
| 79 % | fila de v1, **se quita** | v1: falla en CTS con 6 instancias | no se corrió con la configuración nueva, porque 74 ya falla; la fila deja de tener sentido | `u1_u79/falla.txt` (historia) |
| 80 % | 335 | falla en CTS (`DPL-0036`) | **falla antes**, en `OpenROAD.RepairDesignPostGPL` (paso 32), con 5 instancias sin lugar; en v1 fallaba en el CTS con 22 | `u2_u80/falla.txt`, líneas 6 y 13; `u1_u80/falla.txt` |
| 90 % | 336 | falla en placement global (`GPL-0301`, 100,531 %) | **falla igual**, con `[GPL-0301] Utilization 100.620 % exceeds 100%` (169.186,876 µm² de instancias movibles) | `u2_u90/falla.txt`; `u1_u90/falla.txt` línea 12 para el valor viejo |
| Pie: corridas y fuente | 339 | corridas `final` y `u1_*`; fuente `asic/final.md` y los `falla.txt` | corridas `final` y **`u2_*`**; fuente `asic/rom/resultados/u2_*/metrics.json` y sus `falla.txt`, con la tabla ya armada en `docs/datos_informe.md` sección 3.5 | |

Dos lecturas que conviene poner en el texto, porque no se leen de la tabla:

- **El die mínimo que cierra y el mínimo de cables no están en la misma utilización.** El die más
  chico que cierra es el de 73 % (0,235 mm²), pero ahí los cables son los más largos del barrido
  (449.400 µm) y quedan 99 pines con violación de slew; el mínimo de cables está en 60 %
  (352.225 µm, die 0,284 mm²). Si el criterio es el costo gana 73 %, si es la calidad del signoff
  gana 60 %.
- **La utilización real queda cada vez más por encima de la pedida**: 13,5 puntos a 40 %, 15,3 a
  50 %, 16,9 a 60 %, 18,7 a 70 %, 19,7 a 72 % y 18,8 a 73 %. Con el modelo de cable el resizer
  agrega celdas después del floorplan, así que la diferencia es mayor que los 8 a 12 puntos de v1.

### Párrafo de slew, cables y DRC (línea 350)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Violaciones de max slew contra la utilización | 350 | 546 a 40 %, 378 a 60 % y 392 a 70 % | **la serie hay que rehacerla entera**: con la configuración nueva son **0** (40 %), 8 (50), 0 (60), 20 (70), 92 (72) y 99 (73). v1 completo: 546 (40), 438 (50), 378 (60), 392 (70), 388 (72), 424 (75), 880 (78) | `design__max_slew_violation__count` de `final` y `u2_u*/metrics.json`; v1 en `u1_u*` |
| Violaciones de max capacitancia contra la utilización | 350 | no está | **1** a 40, 50, 60 y 70 %, **5** a 72 % y **6** a 73 %: con el core casi lleno vuelven a aparecer, y deja de ser cierto que la única violación sea la raíz del árbol de reloj | `design__max_cap_violation__count` de las mismas corridas |
| Largo de cables del ruteo detallado | 350 | de 352 a 317 y 318 mm | **377.509 µm a 40 %** (+7,2 % respecto de v1) y después 361.730 (50 %), 352.225 (60 %), 407.376 (70 %), 447.720 (72 %) y 449.400 (73 %): tiene un mínimo en 60 % y de ahí sube | `route__wirelength` de `final` y de `u2_u*/metrics.json` |
| Violaciones de DRC al inicio del ruteo detallado | 350 | 1.546, 2, 5 y 2.149 (40, 50, 60 y 70 %), "pero el router las lleva a cero" | a 40 % con la configuración nueva la serie por iteración es **2, 0, 430, 3, 0**: ya no parte con 1.546 y termina en cero igual. La serie de cada `u2_*` se lee del log de su paso de ruteo detallado, como se hizo en `docs/hechos_flujo.md` | `asic/rom/runs/final/*-openroad-detailedrouting/` y `docs/hechos_flujo.md` |
| Cable más largo (dato que se podría agregar) | 350 | 1.409,36 µm en v1 | **1.713,94 µm** en la corrida final nueva, y baja con la utilización: 1.548,84 (50 %), 1.517,64 (60 %), 1.333,50 (70 %), 1.287,78 (72 %), 1.352,76 (73 %) | `route__wirelength__max` de `final`, `u2_u*` y `v1_final` |
| Señal de congestión que decide el límite | 350 | "a 80 % el placement detallado ya no encuentra lugar para las celdas" | con la configuración nueva el límite lo pone **74 %**, y no en el CTS sino en el paso de reparación después del ruteo global, que es el que agrega D23: el mismo paso que compró las 0 violaciones de slew es el que gasta el espacio | `u2_u74/falla.txt` |


## Sección 3.5.2. Terminales del macro (líneas 352 a 356)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Criterio de D21 y el archivo de pines | 354 | oeste entradas con `clk` al centro, este los dos displays, norte los LEDs, sur el SPI | **no cambia** | `asic/rom/config.yaml`, líneas 30 a 38; `asic/rom/pines.cfg` |
| Capas de los terminales | 356 | Metal3 en oeste y este, Metal2 en norte y sur | **no cambia** | `asic/rom/resultados/final/layout/bloques.txt`, sección "terminales" |
| Coordenadas de los terminales | 354 (implícito en la Figura 3) | `clk` al centro del lado oeste en (0,28; 323,96); `led[0]` en (79,80; 648,24); `seg1[0]` en (630,32; 24,92) | el die crece, así que todas se corren: `clk` en **(0,28; 327,32)**, `led[0]` en (79,80; **656,14**), `seg1[0]` en (**638,23**; 29,40), `spi_sclk` en (79,80; 0,28). Los 29 terminales están listados | `asic/rom/resultados/final/layout/bloques.txt` contra `asic/rom/resultados/v1_final/layout/bloques.txt` |
| Comparación contra la ubicación automática | 354 | "ahorra solo 0,4 % de cable y el WNS es el mismo" (350.998 contra 352.253 µm; WNS 65,213 contra 65,223 ns) | **por medir**: no hay corrida equivalente de `u1_auto` con el RTL ni la configuración nuevos, y **no está encolada**. Si no se corre, hay que decir explícitamente que la cifra es de v1 | viejo verificado en `asic/rom/resultados/u1_auto/metrics.json` (`route__wirelength` 350998, WNS 65,2129, slew 569, capacitancia 31, DRC por iteración 6, 0, 407, 0) y `asic/final.md`, sección "Terminales ubicados por el flujo (sin D21)" |

## Sección 3.5.3. Costo (líneas 358 a 362)

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Precio por mm² y el modelo lineal | 360 | US$23.000 por mm², costo proporcional al área del die | **no cambia**, ni las cuatro limitaciones del modelo | `docs/datos_informe.md`, sección 3.5 (costo) |
| Costo de la corrida final | 360 | 0,409 mm², US$9.406 | **0,419 mm² (419.131 µm²), US$9.640** (0,419131 x 23.000) | `docs/decisiones.md`, D23: "0,419131 mm² por 23.000 dólares/mm² = 9.640 dólares"; `asic/rom/resultados/final/metrics.json` |
| Costo de la corrida de área mínima | 360 | 70 %, 0,239 mm², US$5.496 | **corrección de v1: 78 %, 0,216 mm², US$4.958** (0,215545 x 23.000). **Con la configuración nueva es 73 %, 0,235 mm² y US$5.410** (0,235237 x 23.000) | `docs/datos_informe.md`, línea 270; `asic/rom/resultados/u1_u78/metrics.json` |
| Costo de la estrategia 2 | 360 | 1,794 mm², US$41.266 | **1,802 mm² (1.801.610 µm²), US$41.437** (1,801610 x 23.000); la cifra de 1,794 mm² y US$41.266 queda como historia de `s2_t100` | `asic/ff/resultados/s2_t100/metrics.json` (`design__die__area` 1794180) |
| Cuántas veces más die necesita la estrategia 2 | 362 | 4,6 veces | **4,3 veces** (1.801.610 / 419.131 = 4,298); contra el die nuevo y el `s2_t100` viejo también salen 4,3 | `asic/ff/resultados/s2_t100/metrics.json` y `asic/rom/resultados/final/metrics.json` |
| Reducción del die al subir la utilización | 362 | de 40 a 70 % reduce el die en 42 % | **corrección de v1: de 40 a 78 % lo reduce 47 %** (408.957 a 215.545 µm²); de 40 a 70 % son 42 %. **Con la configuración nueva, de 40 a 73 % lo reduce 43,9 %** (419.131 a 235.237 µm²), y de 40 a 70 % un 41,6 % | `asic/rom/resultados/{v1_final,u1_u70,u1_u78}/metrics.json`; `docs/datos_informe.md`, línea 278 |
| "La pre-decodificación y la configuración del flujo suman 5 % de área" | 362 | 182.265 contra 173.568 µm², +5,0 % | **hay que reescribirla con la distinción de D23**: el pipeline nuevo suma **2,3 %** de área de celdas (182.265 a 186.432 µm²) y el modelo de cable otro **11,8 %** (186.432 a 208.439), **14,4 % en total**; pero el **die y el costo no cambian** respecto de la candidata sin modelo de cable, porque el die lo fija `FP_CORE_UTIL` sobre el área de síntesis y no el área que ocupan las celdas después del resizer. Lo único que sube es la utilización real del core, de 47,9 a **53,5 %** | `docs/decisiones.md`, D23, "Nota sobre el límite de área de celdas"; `asic/exploraciones.md`, fila `exp/candidata (A+B2, paquete completo)` (186.432 µm², die 419.131); `asic/rom/resultados/final/metrics.json` |

Este es el argumento que conviene destacar en 3.5.3, porque es el eje de D23 y responde por
adelantado a la pregunta obvia: por qué se acepta 14,4 % más de área de celdas.

## Sección 3.6.1. DRC, LVS y antenas (líneas 369 a 398)

### Texto

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| DRC de Magic, LVS y antenas de la corrida final | 371 | 0, 0 y 0 | **0, 0 y 0** (mismo resultado, medición nueva) | `asic/rom/resultados/final/cierre.md` y `metrics.json` |
| DRC de KLayout con el deck de GlobalFoundries | 371 | 684 reglas, 0 marcadores | **684 reglas, 0 marcadores** (medición nueva, sobre el GDS de la corrida final nueva) | `asic/rom/resultados/final/drc_klayout/resumen.md`: "DRC de KLayout: asic/rom/runs/final/final/gds/asic_top.gds ... 0 marcadores en 0 reglas (de 684 reglas evaluadas por el deck)" |
| Control positivo del deck | 371 | dos violaciones de Metal1 (un trazo de 0,20 µm de ancho y dos trazos separados por 0,15 µm, contra mínimos de 0,23 µm); el deck marcó M1.1 y M1.2a en sus coordenadas | **igual, repetido sobre el GDS nuevo**, con las mismas figuras y las mismas coordenadas: M1.1 en el rectángulo de (3.500, 3.000) a (3.700, 5.000) y M1.2a en el hueco de (5.500, 3.000) a (5.650, 5.000). "PASA: el deck detecta las dos violaciones y no marca nada más" | `asic/rom/resultados/final/drc_klayout/control_positivo.md` (y `v1_final/drc_klayout/control_positivo.md` para comparar) |
| Antena de la estrategia 2 | 373 | `net3342` de `s2_t100`, cinco buffers, envolvente de 666 x 364 µm, razón 449,1 contra el máximo de 400 (1,12 veces), pin `fanout3341/I` | **no cambia**: evidencia histórica con el RTL viejo. Matiz que hay que agregar: **por medir** si con el core nuevo la estrategia 2 sigue teniendo la violación (corrida `s4_t100`, encolada). La única estrategia 2 versionada en `main` es `e2_t100`, del 25-10-2026, con el RTL y la configuración viejos | `asic/ff/resultados/s2_t100/antenna.rpt` y `antenna_summary.rpt`; `asic/ff/config_final.yaml` |
| Perillas de reparación de antenas | 383 | `GRT_ANTENNA_REPAIR_ITERS = 6` y `GRT_ANTENNA_REPAIR_MARGIN = 30`, 108 diodos más sin aumentar el área | **no cambian**, pero hay que **distinguirlas** de las perillas nuevas de la corrida final: `RUN_POST_GRT_DESIGN_REPAIR`, `GRT_DESIGN_REPAIR_MAX_SLEW_PCT = 30`, `GRT_DESIGN_REPAIR_MAX_CAP_PCT = 30` y `RUN_POST_GRT_RESIZER_TIMING`, que son reparaciones de slew, capacitancia y timing tras el ruteo global, no de antenas | `asic/rom/config.yaml`, líneas 52 a 59; `docs/modelo_cable.md`, sección 3, tabla |
| Antenas de la estrategia 1 | 383 | 0 violaciones en todas sus corridas | **sigue valiendo**: las siete corridas `co_rc_*` y la `f2_t21p5` dan 0 nets, y la corrida final inserta 1 diodo de antena | `antenna__violating__nets` de `asic/rom/resultados/{final,f2_t21p5,co_rc_*}/metrics.json`; `docs/modelo_cable.md`, sección 4 |
| Costo de la inserción heurística de diodos | 383 | 18 % más de área de celdas y 16 ns menos de slack | **no cambia** (historia) | `asic/ff/resultados/s2_t100_diodos/metrics.json` |

### Tabla 12 (`tab:antena`)

**No se regenera.** Las tres filas se verifican una por una y quedan intactas.

| fila | línea del `.tex` | valor del `.tex` | verificación | archivo de origen |
|---|---|---|---|---|
| `s2_t100` (original) | 391 | 1 / 150 / 838.173 / 39,65 | correcto | `asic/ff/resultados/s2_t100/metrics.json`: `antenna__violating__nets` 1, `design__instance__count__class:antenna_cell` 150, `design__instance__area__stdcell` 838173, WNS `max_ss` 39,653 |
| `s2_t100_diodos` | 392 | 0 / 36.385 / 992.171 / 23,65 | correcto | ídem de `s2_t100_diodos`: 0, 36385, 992171, 23,652 |
| `s2_t100_antrep` | 393 | 0 / 258 / 833.559 / 30,03 | correcto | ídem de `s2_t100_antrep`: 0, 258, 833559, 30,029 |

### Dato nuevo para el texto: los avisos que quedan

El informe no tiene un párrafo de avisos, y conviene uno, porque es la única diferencia en la lista
de avisos del flujo: el `warning.log` de la corrida nueva tiene 58 líneas contra 51 en v1, y **lo
único que cambió en la lista de avisos distintos es que desapareció `Max Slew violations found in
the following corners:`**. Ningún aviso nuevo apareció. Los tres que quedan son los mismos de v1:
tres pines de SPI sin información de compuerta de antena (el juego no usa SPI, D7), dos nets
"flotantes" que son VDD y VSS para el resizer, y `VSRC_LOC_FILES` sin valor. Fuente:
`asic/rom/resultados/final/avisos.md`, encabezado y secciones 1 a 3.

## Sección 3.6.2. Layout anotado (líneas 400 a 411)

El método **no cambia**: los tres módulos conservan su jerarquía (D12), `asic/layout/anotar.py` lee
el DEF con los LEF del PDK, colorea por prefijo de instancia y genera `bloques.png`, `bloques.txt`
y `bloques.lyrdb`. Los tres prefijos (`u_soc.u_core.u_rf/`, `u_soc.u_core.u_id.u_alu/`,
`u_soc.u_periph.u_cycles/`) tampoco cambian. La Figura 3 **ya está regenerada** con la corrida
final nueva.

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Dimensiones del die que encuadran la figura | 406 a 411 | 630,60 x 648,52 µm (0,4090 mm²) | **638,50 x 656,42 µm (0,4191 mm²)** | `asic/rom/resultados/final/layout/bloques.txt`, primera línea |
| Base de los porcentajes (celdas lógicas sin relleno) | 411 | 170.060 µm² | **196.079,7 µm²** | ídem, primera línea: "area de celdas estandar (sin fill) 196079.7 um2"; v1: 170059.9 |
| Register file: celdas, área, porcentaje y envolvente | 411 | 2.103 celdas, 78.186,4 µm², 45,98 %, envolvente (22,4; 125,44) a (455,28; 627,2) | **2.963 celdas, 96.935,6 µm², 49,44 %, envolvente (7,84; 50,96) a (492,8; 638,96)** | ídem, línea 2 |
| ALU: celdas, área, porcentaje y envolvente | 411 | 615 celdas, 10.620,4 µm², 6,25 %, envolvente (259,28; 239,12) a (469,84; 419,44) | **673 celdas, 11.718,0 µm², 5,98 %, envolvente (197,12; 235,2) a (533,12; 411,6)** | ídem, línea 3 |
| Contador de ciclos: celdas, área, porcentaje y envolvente | 411 | 116 celdas, 3.977,7 µm², 2,34 %, envolvente (536,48; 160,72) a (622,72; 356,72) | **117 celdas, 3.995,3 µm², 2,04 %, envolvente (499,52; 266,56) a (630,56; 497,84)** | ídem, línea 4 |
| Comparación del área del layout contra la de síntesis | 411 | "78.186 contra 73.656 µm² en el register file" | **96.936 contra 80.349 µm²**: el resizer agrega 16.587 µm² dentro del módulo, 20,6 % (en v1 agregaba 4.530 µm², 6,2 %) | `bloques.txt` y `asic/sintesis.md` |
| Descripción de la ubicación | 411 | "El register file ocupa casi la mitad oeste del core, la ALU queda en el centro, junto a él, y el contador de ciclos en una franja angosta cerca del borde este" | hay que reescribirla mirando la figura nueva: ver el párrafo 11 de la sección de argumentos | `bloques.txt`; `metrics.json`, `design__core__bbox` 6.72 15.68 631.68 638.96 |
| Pie de la Figura 3 | 407 | "Fuente: `asic/rom/resultados/final/layout/`" | **no cambia de ruta** | `asic/rom/resultados/final/layout/` (regenerado el 28-10-2026 20:22) |

Dato adicional que esta subsección podría usar: al período mínimo el reparto es otro, porque el
resizer trabaja más. `asic/rom/resultados/f2_t21p5/layout/bloques.txt`: base de 218.870,2 µm²,
register file 2.945 celdas y 100.766,3 µm² (46,04 %), ALU 687 celdas y 15.787,9 µm² (7,21 %),
contador 117 celdas y 3.995,3 µm² (1,83 %).

## Sección 3.7. Simulación funcional post-síntesis (líneas 414 a 439)

### Texto

| dato | línea | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Qué cambia `asic/sim/config.yaml` respecto de la final | 418 | "que solo cambia la ROM y el debounce" | cambia la ROM, el debounce (`DebounceDivBits=2`) y agrega **`EarlyRead=1`**. Además, el archivo es generado (`asic/sim/generar_config.py` desde `asic/rom/config.yaml`) y arrastra también `LAYERS_RC` y las cuatro variables post-GRT, aunque para `make post-synth` solo importe la síntesis | `asic/sim/config.yaml`, encabezado y `SYNTH_PARAMETERS` |
| Netlist usado | 418 | `asic/sim/runs/sim_rom` | el mismo nombre, con `EarlyRead=1`. La observación O1 de la revisión independiente ya está cerrada: la comprobación 13 de la integración corrió `make post-synth` sobre `main` integrado, con el `tb/post_synth_tb.v` de `main` | `docs/verificacion/integracion.md`, encabezado y comprobación 13 |
| Reglas de los estímulos | 420 | pulsación 20 ciclos después de encenderse el LED, dura 60 | **no cambian** | `asic/sim/estimulos.txt`, encabezado: "inicio en 300, pulsacion 20 ciclos despues de cada LED, 60 ciclos apretado" |
| `DebounceDivBits = 2` y los ciclos que acepta un botón | 420 | 2, unos 12 ciclos | **no cambian** | `asic/sim/README.md` |
| Trazas idénticas y valores X | 439 | 17 cambios de salida en 4.500 ciclos, 0 valores X | **17 cambios de salida en 4.500 ciclos, 0 valores X** (no cambia) | `asic/sim/resultado.md`; `Makefile`, línea 206 (`PS_CICLOS := 4500`) |
| Valor que muestra el display en la ronda correcta | 429, 432 y 439 | 57 ciclos | **51 ciclos** | `asic/sim/resultado.md`: "ronda 01: acierto, el display muestra 51 (ciclos medidos) en el ciclo 1033" |
| Control negativo: atraso y valor | 439 | 6 ciclos de atraso; el display muestra 70 en vez de 57 y la comparación da FAIL | **8 ciclos de atraso; el display muestra 59 en vez de 51** y la comparación da FAIL, con 12 líneas de traza del netlist contra 17 del RTL | `asic/sim/resultado.md`, sección "Control negativo"; `Makefile`, línea 261 (`ATRASO ?= 8`); `docs/verificacion/integracion.md`, comprobación 14. El valor viejo se verifica con `git show v1-final:asic/sim/resultado.md` (display 70 en el ciclo 1748, 11 líneas) |
| Atraso que todavía no cambia la traza y el lazo de polling | 439 | con 5 ciclos no cambia, porque el programa lee los botones en un lazo de 13 ciclos | **con 7 ciclos no cambia, porque el lazo de polling pasa a 8 ciclos** | `asic/sim/resultado.md`, sección "Control negativo"; `Makefile`, línea 262 (`POLL_CICLOS ?= 8`) |
| `make post-synth-final` | 439 | "coincide con el RTL durante 320.000 ciclos, hasta los cuatro LEDs y el 01 de la primera ronda" | el escenario y los 320.000 ciclos **no cambian** (`PSF_CICLOS := 320000`), y el resultado sigue siendo PASS con 3 cambios de salida y 0 valores X. Los dos ciclos exactos (en v1, LEDs 1111 en el 262.156 y display 01 en el 262.194) están **por medir**: `asic/sim/resultado_final.md` no los registra y hay que leerlos de `build/post_synth/traza_rtl_final.txt` después de `make post-synth-final` | `asic/sim/resultado_final.md`; `Makefile`, líneas 285 a 302; valor viejo en `docs/datos_informe.md`, línea 335 |
| Simulación post-PnR con SDF | 439 | "no se considera un resultado reproducible" | **se cae, y ya está rehecho**: la corrida `d2_pnr` cerró y la simulación con SDF sobre su netlist da traza idéntica a la del RTL en tres esquinas, un solo md5 `5b6cebfb898a90a258b592fb29e64651` en las nueve ejecuciones, 0 valores X y, con CVC, 0 violaciones de los 7.173 checks de los 951 bloques TIMINGCHECK | `asic/sim/resultado_sdf.md` (secciones 1 a 4, corrida `d2_pnr`) |

### Tabla 13 (`tab:sim`)

Se rehace completa. Los estímulos nuevos ya están en `main` (`asic/sim/estimulos.txt`, byte a byte
el que vuelve a generar el calibrador con el RTL integrado, comprobación 15 de la integración) y la
traza nueva completa, con sus 17 líneas, está en `docs/verificacion/b2_make_post_synth.txt`, líneas
28 a 44.

| fila | línea del `.tex` | valor viejo (ciclos, botón, qué pasa, ciclo del resultado) | valor nuevo | archivo de origen |
|---|---|---|---|---|
| Pulsación de inicio | 428 | 300 a 360, `0001`, empieza la ronda 01, ciclo **426** | 300 a 360 (los estímulos no cambian), ciclo **404** | `asic/sim/estimulos.txt`; `docs/verificacion/b2_make_post_synth.txt`, línea 30: "404 led=1111 disp=01" |
| Ronda 01, botón correcto | 429 | 801 a 861, `0010`, LED `0010`, el display muestra 57, ciclo **1.574** | **635 a 695**, `0010`, LED `0010` encendido en el ciclo **615**, el display muestra **51**, ciclo **1.033** | `asic/sim/estimulos.txt` (comentario: "LED objetivo 0010 encendido en el ciclo 615"); `asic/sim/resultado.md`; traza líneas 31 y 32 |
| Ronda 02, botón incorrecto | 430 | 2.141 a 2.201, `0010`, LED `0001`, el display muestra EE, ciclo **2.181** | **1.373 a 1.433**, `0010`, LED `0001` encendido en el ciclo **1.353**, el display muestra EE, ciclo **1.405** | `asic/sim/estimulos.txt`; `asic/sim/resultado.md`; traza líneas 35 y 36 |
| La ronda vuelve a 02 | 431 | ciclo **2.353** | ciclo **1.507** | `asic/sim/resultado.md`: "tras EE vuelve a la ronda 02 en el ciclo 1507 (la ronda NO avanzo)"; traza línea 39 |
| Reintento de la ronda 02 | 432 | 2.719 a 2.779, `0001`, acierto, el display muestra 57, ciclo **3.492** | **1.733 a 1.793**, `0001`, LED objetivo encendido en el ciclo **1.713**, acierto, el display muestra **51**, ciclo **2.131** | `asic/sim/estimulos.txt`; `asic/sim/resultado.md`; traza líneas 40 y 41 |
| Pie | 435 | "Fuente: `asic/sim/resultado.md`" | **no cambia de ruta** (el archivo ya está regenerado en `main`) | `asic/sim/resultado.md` |

Los valores viejos de esta tabla se verifican con `git show v1-final:asic/sim/resultado.md`: display
57 en el ciclo 1.574, EE en el 2.181, vuelta a la ronda 02 en el 2.353 y reintento en el 3.492.

## Sección 3.8 que habría que agregar

El informe termina en la sección 7 y no tiene conclusiones ni anexos. El hueco que D23 hace más
visible es que las tres verificaciones que **sostienen** el cambio de corrida final no aparecen en
ninguna parte del `.tex`. Son la sección 3.8 de `docs/datos_informe.md`. Harían falta un párrafo
por cada una y una tabla de cuatro filas.

| verificación | qué dice hoy el repositorio | estado para la corrida final nueva | archivo de origen |
|---|---|---|---|
| Simulación post-PnR con retardos (SDF), frente D1 | corrida `d1_pnr` (flujo completo con `asic/sim/config_pnr.yaml`), netlist post-PnR y SDF simulados con el mismo testbench y escenario de `make post-synth` en cuatro esquinas (`nom_tt_025C_5v00`, `max_ss_125C_4v50`, `min_ff_n40C_5v50` y `nom_ss_125C_4v50`), tres ejecuciones por esquina y por simulador: todas las trazas idénticas a la del RTL (md5 `4f14ec05462e4789a3d873d2ba50fd97`), 0 valores X; Icarus 13.0 de la imagen anota retardos pero no evalúa timing checks, y Open Verilog CVC 7.00b sí los evalúa y no reporta ninguna violación, con control positivo | **medido** con el netlist nuevo (corrida `d2_pnr`, CIERRA): tres esquinas en vez de cuatro (`nom_tt_025C_5v00`, `max_ss_125C_4v50` y `min_ff_n40C_5v50`), tres ejecuciones por esquina y por simulador, las nueve trazas idénticas a la del RTL con md5 `5b6cebfb898a90a258b592fb29e64651` y 0 valores X; CVC evalúa los 7.173 checks de los 951 bloques TIMINGCHECK y no reporta ninguna violación, con control positivo de 8 violaciones en los sincronizadores de entrada. El md5 de v1 era `4f14ec05462e4789a3d873d2ba50fd97` | `asic/sim/resultado_sdf.md`; `asic/sim/resultados/d2_pnr/cierre.md` |
| Equivalencia formal RTL contra netlist, frente D2 | `eqy` 0.68 con las funciones del liberty típico como modelo de celda: RTL contra el netlist de síntesis (22 particiones, PASS) y contra el post-PnR sin celdas físicas (21 particiones, PASS); control negativo (una `nand2_1` cambiada por `nor2_1` en la ALU) **FAIL como corresponde**; BMC desde reset con `sby` (24 y 100 pasos) y el flujo clásico de Yosys (`equiv_make`, `equiv_simple -seq 2`, `equiv_induct -seq 4`), los dos PASS; y por qué el paso `Yosys.EQY` del flujo no sirve con este PDK | **medido** con el RTL y los netlists nuevos (`asic/eqy/resultados/`): `eqy` prueba 29 de sus 30 particiones y deja sin decidir la grande, porque el RTL tiene 44 bits de registro que el netlist no tiene y `pdr` encuentra un estado inicial inalcanzable; la prueba la da el flujo clásico de Yosys, **976 de 976 celdas `$equiv` contra el netlist de síntesis y 968 de 968 contra el post-PnR**, más el miter desde reset, que pasa a 24 y a 100 pasos. El control negativo de la mutación de una celda de la ALU lo discrimina el flujo clásico (776 de 976 celdas probadas, 200 sin probar). Los resultados de v1 quedan en `asic/eqy/resultados_v1/` | `docs/equivalencia.md`, secciones 1, 4.5, 5.2, 5.5 y 6 |
| Potencia con actividad real, frente D3 | VCD de la simulación del netlist post-PnR ejecutando el juego, leído por OpenSTA con el SPEF y el liberty de las nueve esquinas, en cuatro ventanas (lazo de polling, espera de tres segundos, escritura al display y ráfaga de inicio de ronda): en `nom_tt_025C_5v00`, 8,971 mW sin actividad, 9,084 solo reloj, 11,504 en polling, 12,755 en la espera, 12,379 alrededor del 01 y 12,172 en la ráfaga; el reloj es el 70 a 78 % del total | **medido** con el netlist nuevo: en `nom_tt_025C_5v00` la potencia va de **9,620 mW sin actividad** a 13,936 mW en el lazo de polling (+44,9 %), 16,615 en la espera de tres segundos (+72,7 %) y 15,9 en las dos ventanas del cambio de display; el reloj más los registros son el 70,6 % del total en polling contra el 79,8 % de v1. En v1 eran 8,971 y 11,504 mW. Las dos ventanas que dependen del 01 del display se corrieron 22 ciclos, porque con el core nuevo ese evento cae en el ciclo 262.172. El documento de v1 queda en `asic/potencia/resultado_v1.md` | `asic/potencia/resultado.md`, secciones 1 a 3 |
| Potencia sin actividad de la corrida final nueva (esta sí está medida) | el flujo la estima en `nom_tt_025C_5v00` | **9,620 mW** a 10 MHz (interna 7,555 mW, conmutación 2,062 mW, fuga 0,002 mW), contra 8,971 mW en v1. Los 12,100 mW de `power__total` de `metrics.json` son de `max_ff`, la última esquina que procesa el flujo (v1: 11,280 mW) | `docs/datos_informe.md`, líneas 60 a 63; `asic/rom/resultados/final/metrics.json` (`power__total` 0,0121) y `v1_final/metrics.json` (0,011280) |
| Verificación funcional del pipeline nuevo (sección propia o citada desde 3.4) | las 15 comprobaciones de la integración, todas en verde: `make check` PASS (80 pruebas del assembler y seis testbenches), equivalencia funcional con 116fa20 y con v1 en cuatro programas, dos mutaciones detectadas, `make post-synth` PASS con control negativo, y recalibración de estímulos sin cambios. Más el monitor de valores desconocidos: **0 X usados en 620.217 escrituras al banco** del juego completo | **medido y cerrado** | `docs/verificacion/integracion.md` y los 16 archivos `docs/verificacion/integracion_*.txt` |

Si no se abre una sección 3.8, el mínimo es citar la equivalencia formal y la potencia desde 3.3 y
3.5, y la simulación post-PnR desde 3.7, donde ya hay una frase sobre el SDF que de todos modos hay
que reescribir.

## Figuras

| figura y ruta en el `.tex` | línea | qué muestra | se regenera | comando | cambia lo que muestra |
|---|---|---|---|---|---|
| Figura 1, `../docs/figuras/utilizacion.png` | 345 | utilización pedida contra violaciones de DRC del ruteo detallado, largo de cables, violaciones de slew, capacitancia y antena, área del die y WNS; líneas punteadas para las corridas que no terminan | **sí**, y hay que regenerarla al final del barrido: la versión del 28-10-2026 20:57 se armó cuando del barrido `u2_*` solo habían terminado dos puntos. La regenera `bash asic/tablas.sh` (que llama a `asic/graficos.py --util`) | `python3 asic/graficos.py --util asic/rom/runs/final asic/rom/runs/u2_u50 ... --salida-util docs/figuras/utilizacion.png` (ver el encabezado de `asic/graficos.py`, líneas 5 y 6) | **sí, mucho**: la serie de slew arranca en 0 en lugar de 546, la de DRC por iteración arranca en 2 en lugar de 1.546 y el eje de área del die se corre. Depende del barrido `u2_*`, **por medir** |
| Figura 2, `../asic/ff/resultados/s2_t100/layout/antena_antes.png` y `antena_antes_zoom.png` | 377 y 378 | `net3342` de `s2_t100` en rojo sobre el layout de la estrategia 2, completo y en acercamiento, con los cinco buffers en azul | **no**: corrida histórica con el RTL viejo | `bash asic/layout/anotar.sh asic/ff/runs/s2_t100 -rd net=net3342 -rd nombre=antena_antes` (no hace falta correrlo) | no |
| Figura 3, `../asic/rom/resultados/final/layout/bloques.png` | 406 | layout de la corrida final con el register file (azul), la ALU (rojo) y el contador de ciclos (verde), cada uno con su envolvente, y los terminales en el borde | **sí, y ya está regenerada** (28-10-2026 20:22, con la corrida final nueva) | `bash asic/layout/anotar.sh asic/rom/runs/final` | **sí**: el die es más grande (638,50 x 656,42 µm), el register file se extiende por casi todo el core y el pie de la figura y el párrafo que la describe cambian. La ruta del archivo **no** cambia |
| Candidata nueva, `docs/figuras/periodo.png` | no incluida hoy | el barrido de período | **sí**, y hoy está vieja (27-10-2026) | `python3 asic/graficos.py --periodo asic/rom/runs/final asic/rom/runs/f2_t30 ... --salida-periodo docs/figuras/periodo.png` | encajaría bien en 3.4.1, porque el barrido nuevo tiene siete puntos y el área crece en todos |
| Candidata nueva, `asic/rom/resultados/final/layout/slew.png` | no incluida hoy | las celdas con violación de max slew sobre el layout | **sí, y ya está regenerada** | `bash asic/layout/anotar.sh asic/rom/runs/final` (la genera junto con `bloques.png`) | **queda vacía**: 0 pines en 0 celdas, contra 546 pines en 520 celdas en v1 (`asic/rom/resultados/v1_final/layout/slew.txt`). Es la imagen más directa del efecto de D23 |
| Candidata nueva, `asic/rom/resultados/f2_t21p5/layout/ruta_critica.png` | no incluida hoy | la ruta crítica al período mínimo sobre el layout | **sí, y ya está regenerada** | `bash asic/layout/anotar.sh asic/rom/runs/f2_t21p5` | serviría para la Tabla 7, porque la ruta nueva cruza de la etapa ID al periférico del display |
| `docs/figuras/construccion.gif` | no incluida hoy | los pasos del flujo, cuadro por cuadro | **sí**, y hoy está vieja: los PNG de `asic/rom/resultados/final/animacion/` son del 26-10-2026 (v1) y son 12 cuadros; con la configuración nueva habría dos más (`RepairDesignPostGRT` y `ResizerTimingPostGRT`) | `make animacion RUN=asic/rom/runs/final` (`Makefile`, líneas 392 a 396) | sí, y el cambio es didáctico: se ven los dos pasos nuevos |

## Cifras que ya estaban mal en v1 y hay que corregir igual

Estas no dependen de D23: las midió el frente D4 el 27-10-2026, el `.tex` nunca las recogió y hay
que corregirlas incluso si se volviera atrás a v1. Las dos primeras las nombra D23 explícitamente
("Lo que ya está decidido, independiente de esta decisión").

| # | cifra | línea del `.tex` | lo que dice el `.tex` | lo correcto para v1 | archivo de origen |
|---|---|---|---|---|---|
| 1 | Período mínimo de v1 | 197, 262 y 279 | cierra hasta 25 ns y no a 24 | **24,5 ns**: `f1_t24p5` cierra con WNS de setup 0,496 ns y TNS 0 en `max_ss_125C_4v50`, hold 0,178 ns en la peor esquina, y DRC, LVS y antenas en 0. 24 ns no cierra por 0,004 ns | `asic/rom/resultados/f1_t24p5/metrics.json` (`timing__setup__ws` 0,49598) y `cierre.md`; `asic/final.md`, párrafo del barrido |
| 2 | Frecuencia máxima de v1 | 197 | 40 MHz | **40,8 MHz** (1 / 24,5 ns = 40,82) | cálculo; `asic/exploraciones.md`, fila `main (referencia)`: 40.8 |
| 3 | MIPS de v1 | 279 | 15,0 | **15,3** (40,82 / 2,665) | `asic/exploraciones.md`, fila `main (referencia)`: 15.3; `docs/decisiones.md`, D23 |
| 4 | Utilización máxima que cierra | 323 y 334 | 70 % es "el área mínima con la que el diseño completa el flujo y cumple todos los criterios" | **78 %** (`u1_u78` cierra: WNS 59,602 ns, hold 0,182 ns, DRC y LVS 0, antenas 0) | `asic/rom/resultados/u1_u78/metrics.json`; `asic/final.md`, sección del barrido de `FP_CORE_UTIL` |
| 5 | Área mínima del die | 323 y 360 | die de 480,0 x 497,9 µm, 0,239 mm², US$5.496 | **455,4 x 473,3 µm, 215.545 µm² (0,216 mm²), US$4.958** | `asic/rom/resultados/u1_u78/metrics.json` (`design__die__bbox` 0 0 455.395 473.315, `design__die__area` 215545); `docs/datos_informe.md`, línea 270 |
| 6 | Primera utilización que falla | 335 | 80 % falla en el CTS | **79 %** ya falla en el CTS, con 6 instancias del banco de registros sin lugar; 80 % falla igual con 22 | `asic/rom/resultados/u1_u79/falla.txt` y `u1_u80/falla.txt` |
| 7 | Reducción del die al subir la utilización | 362 | de 40 a 70 % reduce el die en 42 % | de 40 a **78 %** lo reduce **47 %** (408.957 a 215.545 µm²); el 42 % de 70 % sigue siendo correcto si se mantiene esa fila | `asic/rom/resultados/{v1_final,u1_u70,u1_u78}/metrics.json` |
| 8 | Tabla 11: faltan cuatro filas medidas | 325 a 341 | la tabla salta de 70 a 80 % | faltan 72, 75, 78 y 79 %, que están medidas desde el 27-10-2026 en v1 | `asic/rom/resultados/{u1_u72,u1_u75,u1_u78,u1_u79}/`; `asic/final.md` |
| 9 | Tabla 6: falta la fila de 24,5 ns | 209 a 214 | la tabla salta de 25 a 24 ns | falta `f1_t24p5` (24,5 ns: 11,660 / 0 / 0,496 / 0 / 0,450 / 0 / 1,081 / 0 / 189.817 / sí) | `asic/final.md`, fila `f1_t24p5`; `asic/rom/resultados/f1_t24p5/metrics.json` |
| 10 | Pie de la Tabla 3: la resolución del barrido | 128 | "hasta dejar 2 ns entre el último que cierra y el primero que no" | la regla que se usó en la sesión es **0,5 ns o menos**, y los barridos nuevos usan pasos de 0,5 ns | `asic/exploraciones.md`, encabezado de la sesión del 27 y 28-10-2026; `docs/decisiones.md`, D23, "Contexto" |
| 11 | Hold de la Tabla 1 | 55 | 0,18 ns en `min_ff_n40C_5v50` | el valor es correcto (0,178 ns, redondeado), pero conviene decir que es el de la **peor** esquina: en `max_ss_125C_4v50` el hold de v1 es 1,081 ns, y las dos cifras aparecen en el informe | `asic/rom/resultados/v1_final/cierre.md` y `metrics.json` |
| 12 | Tabla 10: commit citado | 312 | commit `5d57856` | el archivo que hay hoy se escribió en **`dc316f3`**; `5d57856` es el commit donde cambiaron las palabras, no el último que toca el archivo | `git log --oneline -- rtl/gen/pochoco_rom.v` |
| 13 | Fuentes que quedaron sin regenerar | pies de las Tablas 6 y 11 | citan `asic/final.md` | `asic/final.md` **no** está regenerado: su fila "final" trae los números de v1 (182.265 µm², 408.957 µm², 546 pines de slew, WNS 65,223), así que citarlo como fuente de las tablas nuevas sería un error. Lo mismo pasa con `docs/datos_informe.md`, cuyas secciones 2 y 3.3 ya están al día pero cuyas secciones 3.2, 3.4, 3.5, 3.6 y 3.7 todavía describen v1 | `asic/final.md`, línea 10; `docs/datos_informe.md`, secciones 3.4 a 3.7 |

### Nota sobre dos cifras que no pude verificar en `main`

- **El área de celdas de la candidata sin modelo de cable (186.432 µm²) y su utilización real
  (47,9 %)**, que sostienen el desglose "2,3 % más el modelo de cable" de 3.5.3, no tienen un
  `metrics.json` versionado en `main`: la corrida es `pa_b2_t100` del worktree `build/exp_candidata`.
  Sí están escritas en dos archivos versionados, `asic/exploraciones.md` (fila `exp/candidata
  (A+B2, paquete completo)`: 186.432 µm², die 419.131 µm²) y `docs/decisiones.md` (D23), así que se
  pueden citar desde ahí.
- **Los ciclos exactos de `make post-synth-final`** (en v1, LEDs 1111 en el 262.156 y display 01 en
  el 262.194) no están en ningún archivo versionado de la corrida nueva:
  `asic/sim/resultado_final.md` solo registra "3 cambios de salida, 0 con valores X, trazas
  idénticas, PASS". Para la corrida nueva hay que leerlos de `build/post_synth/traza_rtl_final.txt`
  después de `make post-synth-final`, o no citarlos.

---

# Cambios del banco de preguntas de la defensa por la corrida final de D23

De las 132 preguntas de `docs/defensa.md`, **81 quedan afectadas** por la corrida final nueva (el RTL
del pipeline con lectura del banco y decodificación en el fetch, más la configuración del modelo de
cable del resizer). De esas 81, **64 cambian al menos una cifra** y **17 cambian de mecanismo, de
argumento o de estado sin que ninguna de las cifras que citan cambie de valor** (24, 49, 51, 54, 56,
58, 87, 88, 90, 96, 104, 106, 110, 111, 114, 115 y 132). Además se proponen **15 preguntas nuevas**,
numeradas de la 133 a la 147, con lo que el banco pasaría de 132 a 147 preguntas. Dos de las 81 no
estaban en el mapa de la etapa 1 y las agrego acá porque las verifiqué contra los archivos: la 8 (el
flujo pasa de 76 a 78 pasos) y la 104 (la equivalencia formal ya no está "apagada y sin usar", porque
el frente D2 la corrió). **Nueve** preguntas ya estaban desactualizadas contra `main` **antes** de
este cambio y hay que corregirlas igual: la 38 y la 129 (el período mínimo de v1 es 24,5 ns y no 25),
la 72, la 74, la 75, la 78 y la 80 (la utilización máxima que cierra en v1 es 78 por ciento y el die
mínimo 0,216 mm², no 70 por ciento y 0,239 mm²; y la primera que falla es 79, no 80), la 85 (la
potencia con actividad real ya se midió en v1) y la 106 (la simulación con SDF ya es reproducible).
"v1" quiere decir `main` antes de integrar, tag `v1-final`, con sus reportes en
`asic/rom/resultados/v1_final/`.

Tres avisos de método antes de la lista. Primero, todas las cifras nuevas de place and route salen
de corridas de `main` ya integrado, con sus reportes versionados en `asic/rom/resultados/`:
`final/` (100 ns, la corrida final), el barrido de período `f2_t30`, `f2_t25`, `f2_t24`, `f2_t23`,
`f2_t22`, `f2_t21p5` (el período mínimo, 21,5 ns) y `f2_t21` (21 ns, el que no cierra), y el barrido
de utilización `u2_u50` a `u2_u90`. Los siete tags del barrido de período y los **diez** del de
utilización están seguidos por git (`git ls-files asic/rom/resultados/`: `u2_u50`, `u2_u60`,
`u2_u70`, `u2_u72`, `u2_u73`, `u2_u74`, `u2_u75`, `u2_u78`, `u2_u80` y `u2_u90`; el `u2_u74` es el
punto fino que acotó el máximo y se agregó después de que se escribió el mapa de la etapa 1). Lo que
falta no son los reportes, es volver a correr `asic/tablas.sh`: la tabla de período de `asic/final.md`
marca `f2_t30` como "incompleta" (línea 31) y la de utilización solo trae `final` y `u2_u50`, con
`u2_u60` y `u2_u70` como "incompleta" (líneas 53 y 54) y sin ninguna fila para `u2_u72`, `u2_u73`,
`u2_u74` ni para los puntos que fallan; falta además la sección "Estrategia 2 de memoria con la
configuración final" que `asic/ff/resultados/LEEME.md` ya anuncia para las corridas `s4_*`.
Segundo, `asic/final.md`, `docs/datos_informe.md` y `docs/hechos_flujo.md` **sí están regenerados**
con la corrida nueva (`asic/final.md` trae la fila `final` con 208.439 µm², 0,535 y 419.131;
`docs/datos_informe.md` trae 53,5 por ciento, 9.640 dólares y las 5.577 celdas de 36 tipos;
`docs/hechos_flujo.md` trae los 78 pasos, la densidad 0,532942 y la tabla de potencia con 52,2 y
47,7 por ciento), así que sirven como fuente de los valores **nuevos**; para los valores **viejos**
hay que ir a `asic/rom/resultados/v1_final/`, a las secciones "Historia" de `asic/final.md` o al
propio `docs/defensa.md`. Tercero, donde un número no se puede leer de ningún archivo digo "por
medir" y de qué corrida o comando sale; no interpolé ni redondeé nada de memoria.

## Resumen por tema

| qué cita | preguntas | qué pasa a decir |
|---|---|---|
| ciclos por instrucción y CPI | 50, 66, 70, 71, 107, 108, 109, 110 | un ciclo la mayoría, dos las cargas y dos los saltos tomados; CPI del juego 1,665 (antes 2,665); desaparece el ciclo de espera y `ops_valid_q` |
| frecuencia máxima y barrido de período | 38, 39, 48, 52, 55, 63, 129, 131 | período mínimo 21,5 ns (46,5 MHz) con WNS 0,876 ns en max_ss; 21 ns no cierra por 0,129 ns; 27,9 MIPS; el barrido completo (30, 25, 24, 23, 22, 21,5 y 21 ns) ya está medido en `main` |
| ruta crítica y su desglose | 40, 41, 42, 43, 45, 61 | otra ruta: decode registrado, mux de operandos, ALU y decodificación de dirección; llegada 22,235 ns, slack 0,876 ns; a 100 ns la peor es PC, ROM y mux de lectura del banco |
| área de celdas y conteos del layout | 37, 39, 73, 82, 83, 97 | 208.439 µm² de celdas estándar (14,4 por ciento más), 9.928 celdas, 2.497 de tap y 318 de borde, 1.335 buffers de reparación de timing |
| slew, capacitancia y fanout | 55, 56, 58, 59, 68, 87 | 0 violaciones de max slew en las nueve esquinas (antes 546), 1 de capacitancia (la raíz del árbol de reloj) y 21 de fanout |
| síntesis: celdas y área por módulo | 31, 32, 33, 34, 35 | `nand2_1` pasa a ser la más usada (934); banco de registros 80.349 µm² (51,5 por ciento); 5.577 celdas de 36 tipos a la salida de Yosys |
| cierre y signoff | 3, 13, 88, 90, 98 | setup 65,725 ns y hold 0,173 ns en la peor esquina; DRC de Magic, LVS y antenas en 0; DRC de KLayout 0 marcadores con 684 reglas evaluadas sobre el GDS nuevo |
| potencia e IR drop | 13, 81, 84, 85 | 9,620 mW sin actividad en nom_tt y 0,611 mV de caída en VDD; la potencia con actividad real del diseño nuevo **ya está medida**: 13,936 a 16,615 mW en nom_tt |
| floorplan, utilización y costo | 72, 73, 74, 75, 76, 78, 80, 81, 130 | utilización real 53,5 por ciento, 159 filas de 1.116 sitios, die 419.131 µm² y 9.640 dólares; el barrido de utilización del diseño nuevo **ya está medido**: cierra hasta 73 por ciento y 74 ya falla |
| estrategias de memoria | 24, 25, 26, 27, 30 | la ROM combinacional deja de ser un detalle y pasa a ser condición del pipeline; la comparación de las dos estrategias con el RTL nuevo **ya está medida** (`s3_t100` y `s4_t100`, en `docs/datos_informe.md` sección 3.2); del barrido de período de la estrategia 2 falta el tramo por debajo de 50 ns |
| simulación post-síntesis y con SDF | 101, 102, 103, 104, 106 | display 51 en el ciclo 1033, lazo de polling de 8 ciclos, atraso de control 8; el SDF del netlist nuevo **ya está medido** (corrida `d2_pnr`, tres esquinas) |
| verificación funcional y riesgos de datos | 53, 105, 111, 114, 115 | `hazard_test` (56 comprobaciones), `hazard_review` (48), dos mutaciones detectadas y 0 valores X usados en 620.217 escrituras al banco |
| exploraciones y decisiones | 48, 49, 51, 65, 67, 68, 132 | el pipeline y B2 están adoptados (D23, no D22); el aporte de B2 **ya está medido** con el barrido `pr_*` (1 ns de período); B5 sube el período a 29 ns con este pipeline |
| el flujo por dentro | 8, 11, 87 | 78 pasos (dos nuevos de reparación después del ruteo global, no consecutivos), 3 min 40 s, densidad objetivo 53,2942 por ciento |

## Pregunta por pregunta

### Pregunta 3 (línea 28): qué significa que la corrida "cierra"

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| setup WNS en max_ss a 100 ns | 65,22 ns | 65,725 ns | `asic/rom/resultados/final/cierre.md`; `metrics.json`, clave `timing__setup__ws` |
| hold WNS en min_ff | 0,18 ns | 0,173 ns | `asic/rom/resultados/final/cierre.md` (fila `hold min_ff_n40C_5v50`) |
| TNS de setup y de hold | 0 | 0 (no cambia, las nueve esquinas) | `asic/rom/resultados/final/cierre.md` |

Lo demás de la respuesta (DRC, LVS, 0 nets de antena, las nueve esquinas, D14) no cambia.

### Pregunta 8 (línea 58): qué hace el flujo, en orden

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| pasos del flujo | 76 | 78 | listado de `asic/rom/runs/final/` (78 carpetas numeradas) contra `asic/rom/runs/v1_final_run/` (76); `docs/hechos_flujo.md`, sección 12 ("Son 78 pasos con carpeta, no 76") |
| pasos nuevos | no existían | `41-openroad-repairdesignpostgrt` y `44-openroad-resizertimingpostgrt` (no son consecutivos: entre ellos van `42-odb-diodesonports` y `43-openroad-repairantennas`) | `asic/rom/resultados/final/avisos.md`, encabezado; listado de `asic/rom/runs/final/`; `asic/rom/config.yaml`, líneas 54 y 59 (`RUN_POST_GRT_DESIGN_REPAIR: true`, `RUN_POST_GRT_RESIZER_TIMING: true`) |
| duración de la corrida | unos 3 minutos | 3 min 40 s (23:15:42 a 23:19:22) | `asic/logs/final.log`, primera y última marca de tiempo del flujo |
| paso más largo | ruteo detallado 23 s | ruteo detallado 37,1 s | `asic/rom/runs/final/46-openroad-detailedrouting/runtime.txt` (00:00:37.079); el 23 s de v1 es `v1_final_run/44-openroad-detailedrouting/runtime.txt` (00:00:22.864), porque en v1 el ruteo detallado es el paso **44** y no el 46 |
| segundo y tercero | DRC de Magic 22 s, CTS 14 s | DRC de Magic 18,9 s, reparación de diseño post-GRT 15,8 s, CTS 14,7 s | `runtime.txt` de `66-magic-drc` (18.875), `41-openroad-repairdesignpostgrt` (15.769) y `35-openroad-cts` (14.661); los de v1 son `64-magic-drc` (21.902) y `35-openroad-cts` (14.058) |

**Cómo queda la respuesta.** La lista de etapas es la misma, con dos agregados: después del ruteo
global el flujo ahora repara el diseño y el timing otra vez (`RepairDesignPostGRT` en el paso 41 y
`ResizerTimingPostGRT` en el 44), que es la mitad de configuración de D23. Son 78 pasos y la corrida
final tarda 3 minutos y 40 segundos; los más largos son el ruteo detallado (37 s), el DRC de Magic
(19 s), la reparación de diseño después del ruteo global (16 s) y el CTS (15 s). Se siguen saltando
macros, obstrucciones, DRC de KLayout, inserción heurística de diodos y la equivalencia formal; esa
última se corrió aparte, fuera del flujo (pregunta 104).

### Pregunta 11 (línea 85): el placement toma en cuenta el timing

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| densidad objetivo calculada por el flujo | 53,3 por ciento (0,533277) | 53,2942 por ciento (0,532942) | `asic/rom/runs/final/flow.log`, línea 74 ("using dynamically calculated target density: 53.294200"); `docs/hechos_flujo.md`, sección 5, que trae el valor nuevo y el de v1 en la misma fila |
| `PL_TIMING_DRIVEN` | False | False (no cambia) | `asic/rom/resultados/final/resolved.json` |
| quién arregla el timing después | el resizer y el CTS | el resizer en cuatro pasos (32, 37, 41 y 44) y el CTS | listado de `asic/rom/runs/final/`; `asic/rom/resultados/final/avisos.md` |

### Pregunta 13 (línea 96): qué avisos quedan y por qué no importan

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| caída de tensión peor del análisis de IR drop | 0,15 mV | 0,611 mV en VDD y 0,219 mV en VSS | `asic/rom/resultados/final/metrics.json`, claves `design_powergrid__drop__worst__net:VDD` (0,0006108) y `__net:VSS` (0,0002192); `avisos.md`, aviso 3 |
| potencia que informa ese análisis | no citada (8,971 mW en v1) | 9,620 mW a 10 MHz en la esquina típica | `asic/rom/resultados/final/avisos.md`, aviso 3; `asic/rom/runs/final/57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`, fila Total (9.619598e-03 W) |
| avisos de lint | no citado (11 en v1) | 12; el nuevo es `espino_id_stage.v:59:22: Signal is not used: 'rst_ni'` | `asic/rom/resultados/final/metrics.json`, `design__lint_warning__count` = 12 (v1: 11); `avisos.md`, sección 5 |
| aviso de max slew | existía en v1 | **desaparece** (0 violaciones en las nueve esquinas) | `asic/rom/resultados/final/avisos.md`, encabezado y sección 6 |

**Cómo queda la respuesta.** Siguen los tres avisos de siempre: tres pines SPI sin área de compuerta
en el LEF (no llegan a ninguna compuerta, D7), VDD y VSS "flotantes" para el resizer (los conecta la
red de alimentación; LVS limpio) y `VSRC_LOC_FILES` sin valor (posición de los pads para el IR drop:
un macro no tiene pads; el análisis igual corrió, con 0,611 mV de caída peor en VDD, el 0,01 por
ciento de los 5 V). Queda además el aviso de max capacitancia, que ahora es un solo pin
(pregunta 59). Y desapareció el aviso de max slew, que es justamente lo que trae D23. Dato:
`asic/rom/resultados/final/avisos.md`.

### Pregunta 24 (línea 173): en qué se diferencian las dos estrategias

No cambia ninguna cifra, pero la respuesta queda incompleta como mecanismo. Hoy dice que la
estrategia 1 es una ROM combinacional con un registro a la salida que mantiene la lectura registrada
de la RAM del P2. Hay que agregar que la salida combinacional de la ROM se usa **también
directamente**, por el puerto `a_next_o` de `pochoco_mem_rom`: con ella el core le pide al banco de
registros la lectura de rs1 y rs2 y registra el decode un ciclo antes, que es lo que permite una
instrucción por ciclo. La ROM combinacional deja de ser un detalle de implementación y pasa a ser
condición del pipeline (pregunta nueva 135). El matiz exacto, que conviene decir bien porque es una
pregunta fácil de repreguntar: la memoria unificada en flip-flops **también** expone ese puerto
(`a_next_o` en `rtl/pochoco_mem_ff.v`), así que estructuralmente se podría anticipar con ella, pero
el mux de 119 palabras quedaría en el camino y la haría impracticable; por eso `pochoco_soc` fija
`EarlyRead = (MemStrategy == 1) ? 1 : 0`. Dato: `docs/pipeline.md`, sección 1;
`rtl/pochoco_mem_rom.v`, líneas 37 y 55 (`a_next_o`); `docs/datos_informe.md`, sección 3.2, punto 1.

### Pregunta 25 (línea 180): qué dio la comparación de las dos estrategias

La comparación con el RTL nuevo y la configuración final **ya está medida**: es la corrida `s3_t100`
(estrategia 1, que reproduce la final exactamente) contra `s4_t100` (estrategia 2 con
`asic/ff/config_final.yaml`), y la tabla completa está en `docs/datos_informe.md`, sección 3.2.

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| área de celdas de síntesis, estrategia 1 contra 2 | 146.400 contra 693.901 µm² (4,7 veces) | 156.098 contra **696.640 µm²** (4,5 veces) | viejo en `asic/barrido.md`, tabla de síntesis (146400.083 y 693900.525); nuevo en `asic/rom/resultados/final/sintesis_stat.rpt` (156098.4768) y `asic/ff/resultados/s4_t100/sintesis_stat.rpt` (696640.1344), los dos en la línea "Chip area for top module"; tabla en `docs/datos_informe.md`, sección 3.2 |
| área de celdas tras place and route | no citada | 208.439 contra **977.015 µm²** (4,7 veces) | `design__instance__area__stdcell` de `asic/rom/resultados/final/metrics.json` y de `asic/ff/resultados/s4_t100/metrics.json` |
| flip-flops, estrategia 1 contra 2 | 921 contra 4.602 | 964 contra **4.673** (3.709 más) | `asic/barrido.md`; `asic/sintesis.md`, comparación final (779 + 185 = 964); `design__instance__count__class:sequential_cell` de `s4_t100` |
| celdas estándar | no citadas | 9.928 contra **43.960** | `design__instance__count__stdcell` de las dos corridas |
| área del die, estrategia 1 contra 2 | 0,394 contra 1,794 mm² | 0,419131 contra **1,801610 mm²** (4,3 veces) | `asic/rom/resultados/final/metrics.json` (`design__die__area` = 419131) y `asic/ff/resultados/s4_t100/metrics.json` (1801610); viejo en `asic/barrido.md` (393525 y 1794180) |
| largo de cables | no citado | 377.509 contra **2.242.954 µm** (5,9 veces) | `route__wirelength` de las dos corridas |
| período mínimo, estrategia 1 contra 2 | 55 contra 62 ns (18,2 contra 16,1 MHz) | estrategia 1: 21,5 ns (46,5 MHz, 27,9 MIPS); estrategia 2: **35 ns o menos** (28,57 MHz, 10,7 MIPS con su CPI de 2,665). El barrido completo es 100, 65, 60, 55, 50, 45, 42, 40 y 35 ns, todos cerrando, con WNS 3,066 ns en max_ss a 35 ns; el de 30 ns no se midió porque no cabe en el corte de 40 minutos de la cola | `asic/rom/resultados/f2_t21p5/cierre.md`; `asic/ff/resultados/s4_t50/{cierre.md,metrics.json}`; viejo en `asic/barrido.md` |
| nets con violación de antena | 0 contra 1 | **0 contra 0**: la estrategia 1 sigue en 0 (con 1 diodo) y la estrategia 2 con la configuración final cierra con 0 nets y 6 diodos que insertó el flujo | `antenna__violating__nets` y `antenna_diodes_count` de `asic/rom/resultados/final/metrics.json` y de `asic/ff/resultados/s4_t100/metrics.json`; `docs/datos_informe.md`, sección 3.2, punto 3 |
| violaciones de max slew y de max capacitancia | no citadas | 0 / 1 contra **62 / 14** | `design__max_slew_violation__count` y `design__max_cap_violation__count` de las dos corridas; `s4_t100/cierre.md` |
| CPI del juego completo | no citado | 1,665 contra **2,665** | `docs/verificacion/integracion.md`, tabla de CPI (la estrategia 2 corre con `EarlyRead = 0` y reproduce el CPI de v1) |

**Cómo queda la respuesta.** Hay dos comparaciones y conviene no mezclarlas. La que decidió D17 es
`s1_t100` contra `s2_t100` con la configuración de D15: a 100 ns y con el mismo RTL, 146.400 contra
693.901 µm² de celdas de síntesis (4,7 veces), 921 contra 4.602 flip-flops, die de 0,394 contra
1,794 mm², período mínimo 55 contra 62 ns, y 0 contra 1 net con violación de antena
(`asic/barrido.md`). La comparación de hoy, con el RTL y la configuración de la corrida final, es
`s3_t100` contra `s4_t100`: 156.098 contra 696.640 µm² de síntesis, 964 contra 4.673 flip-flops, die
0,419 contra 1,802 mm² (4,3 veces), 377.509 contra 2.242.954 µm de cable, y las dos con 0 nets en
violación de antena. Y ahora la diferencia no es solo de área y de frecuencia: el CPI pasa a ser
1,665 contra 2,665, porque la estrategia 2 corre con `EarlyRead = 0`. **Ojo con el mapa de la
etapa 1**: dice que con el core nuevo la estrategia 2 pasa a 0 nets en violación de antena citando
`e2_t100`. La conclusión es correcta y la confirma `s4_t100`, pero la cita no sirve: el `e2_t100` que
hay en `main` (`asic/ff/resultados/e2_t100/metrics.json`) es una corrida temprana con el RTL de v1 e
informa `antenna__violating__nets = 1`, 153 celdas de antena y 93 diodos. El aviso de colisión de
tags está en `asic/ff/resultados/LEEME.md`: para el informe la fuente de la estrategia 2 son las
`s4_*`.

### Pregunta 26 (línea 186): por qué la ROM es tan barata comparada con los flip-flops

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| tamaño y área de la ROM | 115 x 32 = 3.680 bits en 7.448 µm², unos 2 µm² por bit | igual (7.448 µm²) | `asic/sintesis.md`, fila `pochoco_rom`; las 115 palabras están en `rtl/gen/pochoco_rom.v`, línea 8 |
| costo por bit extra en la estrategia 2 | 149 µm² ((693.901 - 146.400) / 3.681) | **146,8 µm²** ((696.640 - 156.098) / 3.681) | la cuenta vieja se reproduce con `asic/barrido.md`; la nueva con `asic/rom/resultados/final/sintesis_stat.rpt` (156098.4768) y `asic/ff/resultados/s4_t100/sintesis_stat.rpt` (696640.1344) |
| diferencia por bit entre ROM y flip-flops | unas 70 veces | **unas 73 veces** (146,8 contra los 2,02 µm²/bit de la ROM: 7.448 / 3.680) | idem, más `asic/sintesis.md`, fila `pochoco_rom` |

La cuenta vieja sigue siendo válida como medición de `s1_t100` y `s2_t100` con la configuración de
D15 (`asic/barrido.md`), y da el mismo orden de magnitud; la nueva es la de la configuración final.
Cualquiera de las dos sirve, pero hay que decir de cuál se habla.

### Pregunta 27 (línea 193): por qué la estrategia 2 además es más lenta

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| cuántas veces más grande es el die de la estrategia 2 | 4,6 veces | **4,3 veces** medidas con el RTL nuevo (1.801.610 / 419.131 = 4,30) | `asic/ff/resultados/s4_t100/metrics.json` (`design__die__area` = 1801610) y `asic/rom/resultados/final/metrics.json` (419131); `docs/datos_informe.md`, sección 3.2 |
| período mínimo de la estrategia 2 | 62 ns | **35 ns o menos**: cierra a 35 ns con WNS 3,066 ns en max_ss y el punto de 30 ns no se pudo medir (dos corridas cortadas a los 40 minutos en el paso 44). El salto de 62 a 35 ns no es del core, que con `MemStrategy = 2` sigue siendo el de v1, sino del modelo de cable y la reparación post-GRT | `asic/ff/resultados/s4_t35/{cierre.md,metrics.json}` y `s4_t30_b/falla.txt`; el 62 ns de v1 en `asic/barrido.md` |

El mecanismo no cambia: la ruta es igual a la de la estrategia 1 hasta la dirección que calcula la
ALU y después decodifica esa dirección sobre 119 palabras en vez de 4. Hay que agregar que con el core
nuevo la estrategia 2 corre con `EarlyRead = 0` (pregunta nueva 134), así que no gana nada del
pipeline y sí paga el área del write-through: su CPI es 2,665 contra 1,665
(`docs/verificacion/integracion.md`, tabla de CPI).

### Pregunta 30 (línea 213): una ROM "de verdad" no sería mejor que lógica

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| porcentaje del diseño que ocupa la ROM | 4,7 por ciento | 4,5 por ciento | `asic/sintesis.md`, fila `pochoco_rom` (7.448 de 164.605 µm² en la síntesis jerárquica) |

### Pregunta 31 (línea 222): las cinco celdas más usadas

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| celda más usada | `dffq_1` 804 | `nand2_1` 934 (16,7 por ciento) | `asic/sintesis.md`, tabla de las 5 celdas más usadas; `55-odb-cellfrequencytables/cell_function.rpt` (nand2 934) |
| segunda | `mux2_2` 759 | `mux2_2` 889 (15,9 por ciento) | idem |
| tercera | `nand2_1` 758 | `dffq_1` 779 (14,0 por ciento) | idem |
| cuarta | `oai21_1` 309 | `aoi21_1` 437 (7,8 por ciento) | idem |
| quinta | `clkinv_1` 284 | `oai21_1` 348 (6,2 por ciento) | idem |
| desglose de `dffq_1` | banco 544, memoria 192, pre-decodificación 82, menos 14 que elimina la aplanada | banco 544, memoria 192, decode registrado 82, LSU 2 (B2), menos 41 que elimina la aplanada | `asic/sintesis.md`, sección 3 (desglose de `dffq_1`) |
| total de celdas de la síntesis | no citado en la pregunta (5.118 de 34 tipos) | 5.577 celdas de 36 tipos **a la salida de Yosys**; el layout termina con 9.928 | `asic/sintesis.md`, encabezado de la sección de celdas más usadas, que lo dice con esas palabras ("Son las celdas que salen de Yosys, no las del layout... el diseño final llega a 9.928"); el de v1 en `git show v1-final:asic/sintesis.md`, línea 41 |

**Cómo queda la respuesta.** `nand2_1` 934 (lógica aleatoria de la ROM, el decodificador, la ALU y
ahora también el banco, donde pasa de 88 a 265 en la síntesis jerárquica), `mux2_2` 889 (muxes de
retención y árboles de lectura del banco, más el write-through), `dffq_1` 779 (banco 544, memoria 192,
los 82 registros de decode y los 2 bits del offset de byte de la carga en la LSU, menos 41 que la
síntesis aplanada elimina al propagar constantes), `aoi21_1` 437 y `oai21_1` 348. Conviene decir que
esos conteos son de la síntesis (5.577 celdas de 36 tipos) y no del layout, que llega a 9.928 celdas
estándar. Dato: `asic/sintesis.md`.

### Pregunta 32 (línea 229): por qué tantos `mux2_2`

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| `mux2_2` en la síntesis aplanada | 759 | 889 | `asic/sintesis.md`, tabla de las 5 celdas más usadas |
| `mux2_2` en la síntesis jerárquica | 968 | 1.139 | idem, columna jerárquica |
| `mux2_2` del banco de registros | 480 de retención más los árboles de lectura (622 en total) | 796 en total: 480 de retención y 316 funcionales (árboles de lectura y write-through) | `asic/sintesis.md`, desglose de `mux2_2` por módulo; el 622 de v1 en `git show v1-final:asic/sintesis.md`, línea 65 |
| `mux2_2` de la memoria | 160 | 160 (no cambia) | idem |
| `mux2_2` de la etapa ID | 82 de pre-decodificación (116 en el id_stage) | 117 en el id_stage: 82 de retención del decode y 35 funcionales | idem; el 116 de v1 está en `git show v1-final:asic/sintesis.md`, línea 67, y lo confirma `docs/datos_informe.md` ("Los 117 de la etapa ID (116 en v1)") |

El mecanismo no cambia (la biblioteca no tiene flip-flops con habilitación, así que cada bit escrito
bajo condición lleva un mux de retención), y hay que agregar una causa nueva: el write-through pone un
mux más por cada puerto de lectura, para elegir entre el arreglo y el dato que se está escribiendo.

### Pregunta 33 (línea 236): qué módulo tiene más área y cuánto es el contador

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| área del banco de registros en síntesis | 73.656 µm² | 80.349 µm² (80.348,7104) | `asic/rom/resultados/final/sintesis_stat.rpt`, `Chip area for module '\espino_register_file'`; `asic/sintesis.md` |
| porcentaje del banco en la síntesis jerárquica | 46,6 por ciento | 48,8 por ciento | `asic/sintesis.md`, tabla de área por módulo |
| porcentaje del banco en la corrida final | 48,4 por ciento | 51,5 por ciento (80.349 de 156.098) | `asic/sintesis.md` |
| área del contador de ciclos | 3.943 µm², 2,5 por ciento jerárquica y 2,6 por ciento final | 3.943 µm² (igual), 2,40 por ciento jerárquica y 2,53 por ciento final | `asic/sintesis.md`; `asic/rom/resultados/final/sintesis_stat.rpt` (3942.5792) |
| de qué es el contador | 61 por ciento sus 32 flip-flops con reset | igual (2.388 µm² de 3.943) | `asic/sintesis.md` |

### Pregunta 34 (línea 241): cómo midieron el área por módulo si la síntesis aplana

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| tag de la corrida jerárquica | h2_t100 | h3_t100 | `asic/sintesis.md`, sección Método; `asic/rom/resultados/h3_t100/` |
| cuánto más chica sale la aplanada | 3,7 por ciento | 5,2 por ciento (156.098 contra 164.605 µm²) | `asic/sintesis.md`, línea de área total; `docs/datos_informe.md` ("156.098,48 µm² aplanada ... y 164.604,88 µm² jerárquica") |

El método no cambia: `SYNTH_KEEP_HIERARCHY_MODULES` en la final para los tres módulos que pide el
enunciado (D12) y una corrida aparte con `SYNTH_HIERARCHY_MODE=keep` solo hasta Yosys para repartir el
resto.

### Pregunta 35 (línea 247): coincidió con lo que esperaban

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| flip-flops esperados desde el RTL | 818 sin reset y 186 con reset | 820 sin reset y 185 con reset (1.005) | `asic/sintesis.md`, sección "Comparación con lo esperado" |
| flip-flops de la corrida final | 990 (no citado en la pregunta) | 964 (779 + 185) | `asic/sintesis.md`; `asic/rom/resultados/final/metrics.json`, `design__instance__count__class:sequential_cell` = 964 (v1: 990) |
| porcentaje de área del banco | 47 por ciento | 49 por ciento | `asic/sintesis.md`, línea "Resultó el 49 % del área" (v1: 47 %) |
| la sorpresa de `nand2_1` | quedó "a la par" de `mux2_2` | pasa a ser la celda más usada (934 contra 889); en el banco pasa de 88 a 265 (177 más), no son 265 nuevas | `asic/sintesis.md`, tabla de celdas y desglose de `nand2_1` (265); `git show v1-final:asic/sintesis.md`, línea 81 (88) |

Aviso de redacción, con la fuente corregida: el "a la par" que hay que cambiar está en la respuesta
de **`docs/defensa.md`, línea 250** ("ni que `nand2_1` quedara a la par de `mux2_2`"). El archivo
generado `asic/sintesis.md` ya dice lo contrario en su línea 129: "**No se cumplió**: la celda más
usada es `nand2_1`, y el flip-flop queda tercero". O sea que el texto generado y la tabla están de
acuerdo, y el que quedó viejo es el banco de preguntas.

### Pregunta 37 (línea 260): por qué el área pasa de síntesis a layout

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| área de síntesis | 152.169 µm² | 156.098 µm² | `asic/rom/resultados/final/sintesis_stat.rpt` |
| área de celdas en el layout | 182.265 µm² | 208.439 µm² | `asic/rom/resultados/final/metrics.json`, `design__instance__area__stdcell` |
| celdas de tap y su área | 2.466 celdas, 10.827 µm² | 2.497 celdas, 10.963 µm² | idem, `design__instance__count__class:tap_cell` y `__area__class:tap_cell` (10962,8) |
| celdas de borde y su área | 314 celdas, 1.379 µm² | 318 celdas, 1.396 µm² | idem, `class:endcap_cell` (1396,15) |
| buffers de reparación de timing | 636 | 1.335 (30.838 µm² contra 11.349) | idem, `class:timing_repair_buffer` |
| árbol de reloj | 110 buffers y 26 inversores, con 61 cargas ficticias | 172 buffers y 28 inversores; el CTS crea 122 buffers y 78 cargas ficticias | `metrics.json`, `class:clock_buffer` y `class:clock_inverter`; `asic/rom/runs/final/35-openroad-cts/openroad-cts.log` (CTS-0018 "Created 122 clock buffers" y CTS-0207 "Dummy loads inserted 78") |
| área de celdas lógicas sin tap ni borde | 170.060 µm² | 196.080 µm² (208.439 - 10.963 - 1.396) | `asic/rom/resultados/final/layout/bloques.txt`, encabezado (196.079,7 µm²) |

**Cómo queda la respuesta.** El layout agrega 2.497 celdas de tap (10.963 µm²) y 318 de borde
(1.396 µm²), 1.335 buffers de reparación de timing (30.838 µm², más del doble que en v1 porque la
configuración nueva repara dos veces más y con parásitos realistas), el árbol de reloj (172 buffers y
28 inversores, con 78 cargas ficticias para equilibrarlo) y el redimensionado de celdas en las rutas
lentas. Sin las de tap ni las de borde son 196.080 µm² de celdas lógicas.

### Pregunta 38 (línea 270): cuál es la frecuencia máxima y cómo la obtuvieron

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| frecuencia máxima | 40 MHz (la pregunta sigue diciendo 40 MHz en `main`; la cifra corregida de v1, 40,8 MHz, está en `asic/final.md` y en D23) | 46,5 MHz (1 / 21,5 ns = 46,51 MHz) | `asic/rom/resultados/f2_t21p5/cierre.md`; `asic/final.md`, sección "Historia" ("Cerraba a 24,5 ns (40,8 MHz, 15,3 MIPS)"); `docs/decisiones.md`, D23 (que trae las dos correcciones de v1: 24,5 ns, 40,8 MHz y 15,3 MIPS) |
| período mínimo que cierra | 25 ns (24,5 ns en `main` corregido) | 21,5 ns, con WNS 0,876 ns en max_ss y TNS 0 en las nueve esquinas | `asic/rom/resultados/f2_t21p5/cierre.md`; `metrics.json`, `timing__setup__ws` = 0,876 |
| primer período que no cierra | 24 ns, por 0,004 ns | 21 ns, por 0,129 ns (TNS -0,291) | `asic/rom/resultados/f2_t21/metrics.json` (reportes versionados) |
| períodos barridos | 100, 32, 30, 26, 25 y 24 ns | **el barrido completo ya está medido en `main`**: 100, 30, 25, 24, 23, 22, 21,5 y 21 ns | `asic/rom/resultados/final`, `f2_t30`, `f2_t25`, `f2_t24`, `f2_t23`, `f2_t22`, `f2_t21p5` y `f2_t21`; tabla en `asic/final.md`, sección "Barrido de CLOCK_PERIOD con la configuración final" (que todavía marca `f2_t30` como "incompleta") |

WNS de setup en `max_ss_125C_4v50` de cada punto, de los `metrics.json` de las siete corridas `f2_*`:
30 ns 4,924; 25 ns 1,579; 24 ns 1,755; 23 ns 1,494; 22 ns 0,656; 21,5 ns 0,876; 21 ns -0,129
(el único que no cierra). Las de 30, 25, 24, 23 y 22 ns cierran también DRC, LVS y antenas
(`cierre.md` de cada tag: las cinco dicen "Resultado: CIERRA").

**Cómo queda la respuesta.** 46,5 MHz: el diseño cierra a 21,5 ns con 0,876 ns de margen en la esquina
lenta y no cierra a 21 ns (falla por 0,129 ns, con TNS -0,291). Se barrió `CLOCK_PERIOD` con el mismo
RTL y la misma configuración (corridas `f2_*`: 30, 25, 24, 23, 22, 21,5 y 21 ns), con lo que la regla
de la sesión de dejar 0,5 ns o menos entre el último período que cierra y el primero que no queda
cerrada. El mismo barrido hecho en la exploración que llevó a D23, con el mismo RTL y la misma
configuración pero otro tag (`co_rc_*`), está en `docs/modelo_cable.md`, sección 4, y da los mismos
WNS y las mismas áreas, lo que sirve de comprobación cruzada. Con el CPI del juego de 1,665 eso son
27,9 MIPS. Dato: `asic/rom/resultados/f2_t21p5/cierre.md`, `asic/final.md`.

### Pregunta 39 (línea 276): por qué cada `CLOCK_PERIOD` reoptimiza el circuito

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| área de celdas a 100 ns | 182.265 µm² | 208.439 µm² | `asic/rom/resultados/final/metrics.json` |
| área al período más corto | 189.817 µm² a 26 ns, idéntica de 26 ns para abajo | 231.229 µm² a 21,5 ns y 231.638 µm² a 21 ns: distinta en cada período | `asic/rom/resultados/f2_t21p5/metrics.json` y `f2_t21/metrics.json`; viejo en `asic/final.md`, sección "Historia: la corrida final de v1 y su barrido de período" |
| celdas estándar al período mínimo | 8.708 (f1_t26 a f1_t24, idénticas) | 9.946 | `asic/rom/resultados/f2_t21p5/metrics.json`, `design__instance__count__stdcell`; el 8.708 de v1 está en el texto de `asic/final.md`, sección "Historia: la corrida final de v1 y su barrido de período" |
| "de 26 ns para abajo el layout es idéntico" | cierto en v1 | **deja de ser cierto**: el área sube en cada paso del barrido (219.059 a 30 ns, 219.531 a 25, 220.655 a 24, 222.714 a 23, 224.767 a 22, 231.229 a 21,5 y 231.638 a 21) | los siete `metrics.json` de `asic/rom/resultados/f2_*`; el mismo barrido con otro tag en `docs/modelo_cable.md`, sección 4 (corridas `co_rc_*`), que da los mismos números |

**Cómo queda la respuesta.** El resizer cambia tamaños de celdas y agrega buffers según el período: el
área va de 208.439 µm² a 100 ns a 231.229 µm² a 21,5 ns, y ahora sube en **cada** paso del barrido. En
v1 pasaba lo contrario: de 26 ns para abajo entregaba exactamente el mismo layout (8.708 celdas y
189.817 µm² en f1_t26, f1_t25, f1_t24p5 y f1_t24), porque con los parásitos estimados por omisión
creía que ya no había nada que reparar. Esa es justamente la señal de que el modelo de cable estaba
mal (preguntas nuevas 141 y 142).

### Pregunta 40 (línea 281): cuál es la ruta crítica

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| punto de partida | `_4189_`, flip-flop de pre-decodificación de `alu_operator[1]` (la pregunta lo da a 25 ns, f1_t25) | `_4136_` (`dffq_4`), el registro de decode que guarda `alu_op_a_sel[2]` | `asic/rutas.md`, sección del período mínimo; `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt`, entrada 1 |
| por dónde pasa | ALU, alineación del dato cargado y mux de write-back | mux de operandos (9 celdas) hasta `operand_a[26]`, ALU (18 celdas) hasta `lsu_addr[31]` y decodificación de dirección (10 celdas) | `asic/rutas.md`; `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt` |
| punto de llegada | `u_soc.u_core.u_rf/_2933_`, un bit del banco | `_4440_`, un flip-flop con reset (`dffrnq_1`) que el reporte da aplanado y que en el netlist es **`u_soc.u_periph.digit_q[4]`**, el bit 4 del registro del display del periférico | `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt` (entrada 39, sin nombre jerárquico); `asic/rutas.md`, líneas 17 a 25, que lo resuelve con `grep -A3 "dffrnq_1 _4440_" asic/rom/runs/f2_t21p5/final/nl/asic_top.nl.v` |
| celdas de la ruta | no citado | 39 celdas numeradas, más 3 del camino de reloj | `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt`, encabezado ("39 celdas numeradas; 3 celdas del camino de reloj") |
| la ruta a 100 ns | la pregunta **no la describe**; la de v1 a 100 ns no es la de la carga: va de `_4191_` (`alu_op_a_sel[2]`) por la ALU a `lsu_addr[31]` y termina en `_4309_`, con llegada 36,485 ns | otra: `_4287_` (`dffrnq_1`, el bit 2 de la dirección que pide el fetch, `a_addr_i[2]`), ROM combinacional, `a_next_o[17]` y mux de lectura del banco hasta `u_soc.u_core.u_rf/_4123_` (`dffq_1`), 34 celdas y 36,033 ns de llegada | `asic/rutas.md`, secciones "Corrida final nueva a 100 ns" y "Corrida final de v1 a 100 ns (historia)"; `asic/rom/resultados/final/layout/ruta_critica.txt` |

**Cómo queda la respuesta.** Hay que distinguir dos rutas, porque ya no son la misma. Al período
mínimo (21,5 ns, esquina max_ss) la ruta crítica empieza en `_4136_`, el registro de decode que guarda
`alu_op_a_sel[2]`, pasa por los buffers y el mux de operandos hasta `operand_a[26]`, cruza la ALU
hasta `lsu_addr[31]` y termina, después de la decodificación de dirección, en `_4440_`, que es el
bit 4 del registro del display del periférico (`u_soc.u_periph.digit_q[4]`): funciones de decode
registrado, ejecución y escritura a un periférico, en un solo ciclo de verdad. En la corrida final a
100 ns la peor ruta es la otra, la que crea el pipeline nuevo: del bit 2 de la dirección del fetch
por la ROM combinacional, de ahí al bit de rs1 (`a_next_o[17]`) y por el mux de lectura de 16 a 1
hasta un registro de salida del banco. Esa segunda es la que limita el período cuando el resizer
trabaja con holgura. Dato: `asic/rutas.md`.

### Pregunta 41 (línea 288): cómo se reparte el tiempo en esa ruta

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| árbol de reloj hasta el flip-flop de lanzamiento | 2,66 ns | 2,673 ns (3 celdas) | `asic/rutas.md`, tabla de tramos de f2_t21p5 |
| reloj a Q del flip-flop de lanzamiento | 2,34 ns | 1,830 ns (`dffq_4`) | idem |
| ALU | 9,50 ns, 9 celdas | 9,048 ns, 18 celdas (de `operand_a[26]` a `lsu_addr[31]`) | idem |
| alineación y write-back | 9,74 ns, 12 celdas | ya no está en la ruta; en su lugar hay 4,267 ns de mux de operandos (9 celdas) antes de la ALU y 4,417 ns de decodificación de dirección (10 celdas) después | idem |
| último tramo antes del flip-flop de llegada | 1,55 ns, que en la pregunta es el tramo `u_soc.u_core.u_rf` de 2 celdas ("entrada al banco"), no un setup de biblioteca | el tramo desaparece: la ruta entra directo al pin D y lo que se resta es el setup de biblioteca, 0,640 ns (`dffrnq_1`) | `asic/rutas.md`, tabla de tramos y cálculo del tiempo requerido de f2_t21p5 y de f1_t24p5 |
| llegada total | 25,78 ns | 22,235 ns | idem, `data arrival time` |

**Cómo queda la respuesta.** Árbol de reloj hasta el flip-flop 2,673 ns, reloj a Q 1,830 ns, mux de
operandos 4,267 ns (9 celdas), ALU 9,048 ns (18 celdas), decodificación de la dirección 4,417 ns
(10 celdas): llega a 22,235 ns. La moraleja cambia: ya no son la ALU y la alineación repartiéndose la
ruta por mitades, sino la ALU que se lleva poco menos de la mitad y dos tramos de buffers e
interconexión a los lados.

### Pregunta 42 (línea 293): cómo se calcula el slack de esa ruta

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| período | 25 ns | 21,5 ns | `asic/rutas.md`, cálculo del tiempo requerido de f2_t21p5 |
| latencia del reloj de captura | 2,32 ns | 2,385 ns | idem |
| corrección por reconvergencia | 0,11 ns | 0,116 ns | idem |
| incertidumbre | 0,25 ns | 0,25 ns (no cambia) | idem |
| setup del flip-flop | 0,40 ns | 0,640 ns | idem |
| tiempo requerido | 26,78 ns | 23,111 ns | idem, `data required time` |
| llegada | 25,78 ns | 22,235 ns | idem |
| slack | 1,00 ns | 0,876 ns | idem; `asic/rom/resultados/f2_t21p5/cierre.md` |

La cuenta queda: 21,5 + 2,385 + 0,116 - 0,25 - 0,640 = 23,111 ns de tiempo requerido, menos 22,235 ns
de llegada, igual 0,876 ns de slack. (Las cifras viejas son las de 25 ns que cita la pregunta; en
`asic/rutas.md` el período mínimo de v1 está medido a 24,5 ns, f1_t24p5, donde la misma cuenta da
26,280 ns de tiempo requerido y 0,496 ns de slack.)

### Pregunta 43 (línea 299): qué es la corrección por reconvergencia (CRPR)

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| CRPR en la ruta crítica | 0,11 ns | 0,116 ns al período mínimo y 0,115 ns a 100 ns | `asic/rutas.md`, cálculos del tiempo requerido de f2_t21p5 y de la final |
| tramo compartido del árbol | `clkbuf_0_clk` | `clkbuf_0_clk` (no cambia) | `asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt`, primera celda del camino de reloj |

### Pregunta 45 (línea 310): qué es el skew y cuánto hay

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| llegada del reloj al flip-flop de lanzamiento y al de captura | 2,66 contra 2,32 ns (0,34 ns) | 2,673 contra 2,385 ns (0,288 ns) | `asic/rutas.md`, tramos y cálculo de f2_t21p5 |
| parte que devuelve CRPR | 0,11 ns | 0,116 ns | idem |
| skew de setup por esquina | 0,36 ns (min_ff) a 0,57 ns (max_ss) | 0,341 ns (min_ff) a 0,495 ns (max_ss) | `asic/rom/resultados/final/metrics.json`, `clock__skew__worst_setup__corner:*`; tabla completa en `docs/hechos_flujo.md`, sección 6.3 |
| skew de hold por esquina | -0,43 a -0,79 ns | -0,433 (min_ff) a -0,768 ns (max_ss) | idem, `clock__skew__worst_hold__corner:*` |

### Pregunta 46 (línea 317): por qué el setup se complica en ss y el hold en ff

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| peor setup (max_ss) a 100 ns | 65,22 ns | 65,725 ns | `asic/rom/resultados/final/cierre.md` |
| peor hold (min_ff) | 0,18 ns | 0,173 ns | idem |

La explicación física no cambia.

### Pregunta 47 (línea 323): el hold depende del período

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| hold igual en todo el barrido | 0,18 ns | 0,173 ns, igual en los **ocho** puntos medidos (la final a 100 ns más los siete del barrido: 30, 25, 24, 23, 22, 21,5 y 21 ns) | `timing__hold__ws` de los `metrics.json` de `asic/rom/resultados/final` y de las siete corridas `f2_*` (0,17272 a 0,17276) |
| buffers de hold de la corrida final | 5 | **0** | `asic/rom/resultados/final/metrics.json`, `design__instance__count__hold_buffer` = 0 (v1: 5) |

El argumento central queda mejor que antes (el hold es idéntico en todas las corridas del barrido),
pero la última frase hay que cambiarla: la corrida nueva no necesita ningún buffer de hold.

### Pregunta 48 (línea 329): la ruta crítica es real

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| qué lograba B2 | registrar `addr[1:0]` saca la ruta y el período baja a 24 ns | B2 está adoptado; el período mínimo de la corrida final es 21,5 ns | `docs/decisiones.md`, D23; `asic/rom/resultados/f2_t21p5/cierre.md`; el 24 ns de B2 sobre el RTL de v1 sigue en `asic/exploraciones.md` (fila `exp/lsu-offset`) |
| cuánto aporta B2 sobre este pipeline | no existía la pregunta | **medido, y es 1 ns de período**: sin B2 (`pr_*`, rama `exp/pipeline` con la configuración final) el mínimo que cierra es 22,5 ns (WNS 0,007 ns) y 22 ns no cierra (-0,597 ns, TNS -3,869); con B2 cierra a 21,5 ns. En MIPS son 26,7 contra 27,9. A 100 ns la diferencia es casi nula: 208.390 contra 208.439 µm² de celdas, WNS 65,710 contra 65,725 ns, 0 slew en las dos, die 418.503 contra 419.131 µm² | `build/exp_pipeline/asic/rom/resultados/pr_t24`, `pr_t23`, `pr_t22`, `pr_t21p5`, `pr_t21` y `pr_t100` (`metrics.json` y `cierre.md`); `asic/rom/resultados/f2_t21p5/cierre.md`; tramos de `pr_t24` a `pr_t21` en `asic/rutas.md` |

Barrido `pr_*` completo en `max_ss_125C_4v50`, de los `metrics.json`: 100 ns 65,710 (cierra);
24 ns 1,556 (cierra); 23 ns 0,463 (cierra); 22,5 ns 0,007 (cierra); 22 ns -0,597 (no cierra, TNS -3,869); 21,5 ns -0,938
(no cierra); 21 ns -1,634 (no cierra). Lo único que falta de ese barrido es el punto de 22,5 ns, para
cumplir la regla de la sesión de dejar 0,5 ns o menos entre el último que cierra y el primero que no.

**Cómo queda la respuesta.** La pregunta sigue sirviendo, pero en pasado. En v1 la peor ruta era la del
write-back de una carga: para el STA era de un ciclo, pero en la práctica el dato de memoria llega un
ciclo después de emitir la carga, con el pipeline detenido y la dirección estable, así que eran dos
ciclos. Ese argumento ya no hace falta para defender el cierre, porque la ruta desapareció: B2
registra los dos bits bajos de la dirección al emitir la carga y la alineación salió del camino. La
ruta crítica de hoy (decode registrado, mux de operandos, ALU y decodificación de dirección) es
genuinamente de un ciclo. Y ahora se puede decir cuánto aporta B2 sobre este pipeline: 1 ns de
período (de 22,5 a 21,5 ns, o de 44,4 a 46,5 MHz) por dos flip-flops en la LSU. Dato: `asic/rutas.md`,
`docs/decisiones.md` D23, `build/exp_pipeline/asic/rom/resultados/pr_*`.

### Pregunta 49 (línea 335): por qué no declarar esa ruta como multiciclo en la SDC

No cambia ninguna cifra y el argumento mejora: se hizo exactamente lo que la respuesta dice que es lo
seguro (cambiar el RTL en vez de escribir una excepción de timing), y el STA sigue revisando todo. Hay
que poner B2 en presente del diseño y no como opción descartada. Dato: `docs/decisiones.md`, D23.

### Pregunta 50 (línea 341): qué cambio de RTL hicieron para acortar la ruta

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| ciclos por instrucción | 2 (un ciclo de espera más ejecución) | 1 | `docs/pipeline.md`, sección 1 (tabla de temporización); `docs/verificacion/integracion.md`, tabla de CPI |
| salidas del decodificador registradas | 82 | 82 (no cambia; cambia **cuándo** se cargan) | `asic/sintesis.md`, desglose de `dffq_1` en `espino_id_stage` |
| "ningún ciclo cambia" | cierto para D18 | falso para este cambio: cambian todos los ciclos, y hubo que recalibrar los estímulos | `docs/pipeline.md`, sección 3.6; `asic/sim/estimulos.txt` (ronda 1 en el ciclo 615, contra 781 en v1) |

**Cómo queda la respuesta.** Dos cambios, uno encima del otro. El primero es D18: registrar las 82
salidas del decodificador para que el decode no esté en la ruta de ejecución. El segundo, el de D23:
como la ROM de la estrategia 1 es combinacional, la instrucción de la dirección que pide el fetch ya
está disponible un ciclo antes de cargarse en el registro de instrucción, así que con esa salida
(`a_next_o`) el core le pide al banco la lectura de rs1 y rs2 y registra el decode en el mismo flanco
en que carga la instrucción. Al llegar a la ejecución, operandos y decode ya están listos y desaparece
el ciclo de espera: el CPI del juego baja de 2,665 a 1,665. Se agregan además el write-through del
banco (para que la escritura del mismo flanco se vea) y B2 (la LSU registra `addr[1:0]` al emitir la
carga). Dato: `docs/pipeline.md`, secciones 1 y 2.

### Pregunta 51 (línea 347): por qué el decode y no otra parte

No cambia ninguna cifra: en `s1_t55` el decode era el tramo más largo (19,1 de 55,1 ns) y está en todas
las rutas de ejecución. Lo que hay que agregar es que ese argumento fue el primer paso: primero se
registró el decode (D18) y después, al ver que la ROM combinacional permitía hacerlo un ciclo antes,
se sacó también el ciclo de espera (D23). Dato: el desglose de los 19,1 de 55,1 ns está en
`docs/decisiones.md`, D18, línea 129 (no en `asic/final.md`, que solo trae la tabla del barrido
`s1_*`), con el reporte en `asic/rom/resultados/s1_t55/max_ss_125C_4v50_ruta_critica.rpt`; el resto en
`docs/pipeline.md`.

### Pregunta 52 (línea 352): cuánto rindió y cuánto costó la pre-decodificación

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| período mínimo de 55 a 42 ns con la configuración de D15 | se mantiene como historia de D18 | igual | `asic/barrido.md` |
| slack extra a 100 ns "con la final" | 10,7 ns | **por medir** (hay que repetir la corrida `r0_*` con la configuración nueva); el 10,7 ns de v1 se reproduce como 65,223 menos 54,552 | `asic/final.md`, sección "Historia: RTL sin pre-decodificación (116fa20) con la configuración de v1" (r0_t100: 54,552 ns) |
| período al que no cierra sin pre-decodificación | no cierra a 26 ns (WNS -3,18 ns) | **por medir** con la configuración nueva; en v1 es -3,175 ns | `asic/final.md`, fila r0_t26 |
| costo de área | 4,4 por ciento | el cambio completo (pipeline más modelo de cable) cuesta 14,4 por ciento de área de celdas | `docs/decisiones.md`, D23 (208.439 contra 182.265 µm²) |

### Pregunta 53 (línea 358): cómo verificaron que no cambió el comportamiento

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| equivalencia con `isa_test` | 1.018 eventos por estrategia, ciclo a ciclo contra 116fa20 | modo funcional: 46 escrituras al banco, 22 accesos al bus y 2 salidas iguales, con las dos estrategias, contra 116fa20 y contra v1 | `docs/verificacion/integracion.md`, filas 2 y 3 |
| programa de riesgos de datos | no existía | `sw/hazard_test.s`, 56 comprobaciones: 348 eventos de banco, 63 de bus y 2 de salida iguales; `sw/hazard_review.s`, 48 comprobaciones: 271, 66 y 2 | `docs/verificacion/integracion.md`, filas 4 y 5; `sw/hazard_test.s` línea 31 (`.equ TOTAL, 56`) y `sw/hazard_review.s` línea 51 (`.equ TOTAL, 48`) |
| pruebas de mutación | no existían | 2 mutaciones propias más 2 del revisor, todas detectadas | `docs/verificacion/integracion.md`, filas 7 a 12 |
| escrituras al banco sin valores X usados | 388.411 | 620.217 (estrategia 1, 10 rondas); la estrategia 2 sigue dando 388.411 | `docs/verificacion/integracion.md`, tabla del monitor de X |
| los tres testbenches con los mismos 101 checks | 101 checks | `make check` PASS: 80 pruebas del assembler y los **seis** testbenches, con las dos estrategias | `docs/verificacion/integracion.md`, fila 1 |

**Cómo queda la respuesta.** Cinco cosas, y la equivalencia ya no es ciclo a ciclo sino funcional,
porque los ciclos cambian a propósito: `make check` (80 pruebas del assembler y seis testbenches PASS
con las dos estrategias), `make equiv MODO=funcional` con `isa_test` contra v1 y contra 116fa20
(46 escrituras al banco, 22 accesos al bus y 2 salidas idénticas), un programa escrito para este
cambio (`sw/hazard_test.s`, 56 comprobaciones, 348 eventos de banco iguales), cuatro pruebas de
mutación que las pruebas detectan, y un monitor que no encontró ningún valor desconocido usado en
620.217 escrituras al banco del juego completo. Dato: `docs/verificacion/integracion.md`.

### Pregunta 54 (línea 365): por qué los registros de decode no tienen reset

No cambia ninguna cifra, pero el argumento se apoya en `ops_valid_q`, que con `EarlyRead = 1` ya no
existe. La respuesta nueva: los registros de decode se cargan en el mismo flanco que la instrucción, y
lo que impide leer un valor sin cargar es `instr_valid_i` (`valid_q` arranca en 0 y durante el reset
`pc_q` vale `BootAddr`, así que en cada flanco del reset se cargan con la primera instrucción). La
conclusión de área sobrevive: sin reset son `dffq_1`, más chicos que `dffrnq_1`. La evidencia es el
monitor de X: 0 valores desconocidos usados en 620.217 escrituras al banco. Dato: `docs/pipeline.md`,
sección 2 (riesgo 6); `docs/verificacion/integracion.md`; `rtl/espino_core/espino_id_stage.v`,
bloques `g_early` y `g_wait`.

### Pregunta 55 (línea 370): el período mínimo bajó de 42 a 25 ns con el mismo RTL

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| período mínimo después de D20 | 25 ns | 24,5 ns en v1; 21,5 ns en la corrida final nueva (otro RTL y otra configuración) | `asic/final.md`, fila f1_t24p5 (WNS 0,496 ns); `asic/rom/resultados/f2_t21p5/cierre.md` |
| violaciones de slew | de 2.201 a 546 | de 2.201 a 546 con D20 y de 546 a **0** con el modelo de cable | el 2.201 está en `docs/decisiones.md`, D20, línea 147, que para su propia corrida (32 ns) da 541; el 546 que cita la pregunta es el de la corrida final de v1 (`asic/rom/resultados/v1_final/metrics.json`, `design__max_slew_violation__count`); el 0 está en `asic/rom/resultados/final/metrics.json` |

La historia de D15 y D20 se mantiene tal cual; lo que cambia es el punto de llegada. Si alguien
repregunta por el 541 de D20, la respuesta es que es la corrida de 32 ns con la que se decidió D20 y
el 546 es la corrida final de v1.

### Pregunta 56 (línea 377): qué hace `PL_RESIZER_SETUP_SLACK_MARGIN`

No cambia ninguna cifra (el margen por omisión sigue siendo 0,05 ns y el que se usa, 10 ns,
`asic/rom/config.yaml` línea 29 y `resolved.json`), pero hay que reescribir el final. Hoy termina
diciendo "Es una explicación, no una medición: el repo no tiene un reporte que la pruebe". Ahora está
medido: el resizer estima la capacidad de los cables entre 2,3 y 2,9 veces menor que la que OpenRCX
extrae del ruteo detallado, y darle los valores por capa con `LAYERS_RC` baja el período mínimo y
deja 0 violaciones de max slew. La hipótesis quedó confirmada y con archivo de origen. Dato:
`docs/modelo_cable.md`, secciones 1 y 2 (los factores 2,93 / 2,59 / 2,30 están en la tabla de la
sección 2); `asic/modelo_cable.md`, sección 2.

### Pregunta 58 (línea 390): por qué `buf_1` causaba violaciones de slew

No cambia ninguna cifra: el mecanismo (es el buffer más débil, así que con cables largos la transición
es lenta) y el 68 por ciento siguen siendo historia de v1. Hay que agregar el cierre de la historia:
excluir `buf_1` era un parche sobre el síntoma, y la causa de fondo era el modelo con que el resizer
decidía dónde poner buffers; con `LAYERS_RC` no quedan violaciones de slew en ninguna de las nueve
esquinas. Dato: `docs/decisiones.md` D20; `asic/rom/resultados/final/metrics.json`.

### Pregunta 59 (línea 394): qué son las 546 violaciones de max slew

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| violaciones de max slew | 546 (max_ss) | **0 en las nueve esquinas** | `asic/rom/resultados/final/metrics.json`, `design__max_slew_violation__count`; `max_ss_125C_4v50_checks.rpt` ("max slew violation count 0"); `layout/slew.txt` ("0 pines en 0 celdas") |
| peor violación de slew | 5,41 ns en la esquina lenta | no hay violaciones | idem |
| violaciones de max capacitancia | 36 (no citado en la pregunta; es `design__max_cap_violation__count` de v1) | 1: `clkbuf_0_clk/Z`, 0,428234 pF contra el límite de 0,2 pF | `max_ss_125C_4v50_checks.rpt`, sección `max capacitance`; `avisos.md`, aviso 4 |
| violaciones de max fanout | 62 (no citado en la pregunta; v1) | 21 | `asic/rom/resultados/final/metrics.json`, `design__max_fanout_violation__count` |

**Cómo queda la respuesta.** La pregunta ya no puede preguntar por 546 violaciones: la corrida final no
tiene ninguna. Conviene darla vuelta ("¿qué pasó con las 546 violaciones de max slew de v1?"). Una
violación de max slew es un pin donde la transición de la señal supera los 3 ns que pone la SDC; no es
criterio de cierre del enunciado, y el timing ya las considera porque el retardo de cada celda se
calcula con su slew de entrada. En v1 eran 546, con la peor en 5,41 ns en la esquina lenta (el liberty
admite hasta 7 ns por pin ahí). No eran un problema del diseño sino del modelo de cable del resizer:
con los RC medidos por capa (`LAYERS_RC`) y la reparación después del ruteo global, quedan 0 en las
nueve esquinas, 21 violaciones de fanout y una sola de capacitancia, la raíz del árbol de reloj, que
`repair_design` no toca (pregunta nueva 144).

### Pregunta 61 (línea 405): qué dice el liberty de un `dffq_1`

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| medidas y tiempos de biblioteca del `dffq_1` | 16,24 x 3,92 µm (63,66 µm²); setup 0,21 a 0,23 ns y reloj a Q 1,0 a 1,3 ns en la típica, setup 0,44 a 0,47 ns y reloj a Q 1,8 a 2,3 ns en la lenta | no cambian (la SDC no cambió, así que el punto elegido de la grilla tampoco) | `docs/hechos_flujo.md`, sección 11 (y 11.2 para el punto elegido) |
| setup del flip-flop de la ruta crítica | 0,40 ns | 0,640 ns (`dffrnq_1`) al período mínimo y 0,519 ns a 100 ns (`dffq_1` del banco) | `asic/rutas.md`, cálculos del tiempo requerido de f2_t21p5 y de la final |
| reloj a Q del flip-flop de la ruta crítica | 2,34 ns | 1,830 ns (`dffq_4`) al período mínimo y 1,877 ns a 100 ns | idem, tablas de tramos |

La última frase hay que cambiarla: el flip-flop de lanzamiento de la ruta crítica ya no es un `dffq_1`
sino un `dffq_4`, y el de llegada al período mínimo es un `dffrnq_1`.

### Pregunta 63 (línea 418): y si el macro corriera a 40 MHz

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| frecuencia de la pregunta | 40 MHz | 46,5 MHz (1 / 21,5 ns) | `asic/rom/resultados/f2_t21p5/cierre.md` |
| `CYCLES_PER_TENTH` | 4.000.000 = 0x3D0900, `lui 0x3D1` y `addi -1792` | 4.651.162 = 0x46F89A, `lui 0x470` y `addi -1894` | cálculo con el período medido de `f2_t21p5/cierre.md` y el algoritmo de `li` del assembler (`assembler/core.py`; pregunta 119): 0,1 / 21,5 ns = 4.651.162,79, hi = (4.651.162 + 0x800) >> 12 = 0x470, lo = 4.651.162 - (0x470 << 12) = -1894 |
| período de muestreo del debounce | 0,82 ms | 0,70 ms (2^15 / 46,51 MHz) | cálculo con `DebounceDivBits = 15`, que está en `rtl/asic_top.v` línea 24, `rtl/pochoco_soc.v` línea 20 y `rtl/pochoco_periph.v` línea 13 (en `rtl/debounce.v` el parámetro se llama `DivBits`, línea 17), y el período medido |
| vuelta de CYCLES | 107 s | 92 s (2^32 / 46,51 MHz) | cálculo con el período medido |

El mecanismo se conserva entero y el ejemplo sigue funcionando: los 12 bits bajos (0x89A) tienen el
bit 11 en 1, así que el assembler sube la parte alta y usa un `addi` negativo, igual que pasaba con
0x900 a 40 MHz.

### Pregunta 65 (línea 429): probaron otros cambios de RTL

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| qué exploraciones entraron a la corrida final | ninguna (D22) | el pipeline del frente A más B2, con el modelo de cable del resizer (**D23**) | `docs/decisiones.md`, D23; `asic/exploraciones.md`, tabla "¿entró en la corrida final?" |
| B2 | cierra a 24 ns con 0,6 por ciento menos de área | sigue valiendo como medición de B2 sobre el RTL de v1 (24 ns, 181.170 µm² contra 182.265); B2 está adoptado | `asic/exploraciones.md`, fila `exp/lsu-offset` |
| B3 | no mueve el período | no cambia (26 ns, 38,5 MHz, 14,4 MIPS) | `asic/exploraciones.md`, fila `exp/branch-cmp` |
| B4 | CPI de 2,665 a 1,312 y el período sube a 60 ns | no cambia (16,7 MHz, 12,7 MIPS) | `asic/exploraciones.md`, fila `exp/cpi` |
| B5 | no citado en esta pregunta | sobre el RTL de v1 baja el área 9,3 por ciento (165.369 contra 182.265 µm²); sobre el pipeline nuevo el período sube a 29 ns (20,7 MIPS) | `asic/exploraciones.md`, filas `exp/rf-latch` y `exp/pipeline-b5`; `docs/pipeline.md`, sección 5.1 |

**Cómo queda la respuesta.** Sí, en ramas `exp/*` con la configuración final, y dos de ellas entraron a
la corrida final (D23, que reemplaza a D22 en este punto): el pipeline con lectura del banco y decode
en el fetch, y B2 (el offset de byte de la carga registrado en la LSU). De las que no entraron: B3
(comparador de saltos desde el banco) no mueve el período porque el salto no era la ruta crítica; B4
(todo en un ciclo) baja el CPI a 1,312 pero el período sube a 60 ns y rinde peor (12,7 MIPS); y B5
(banco de latches) ahorra área pero con el pipeline nuevo sube el período de 25,5 a 29 ns (pregunta
nueva 140). Dato: `asic/exploraciones.md`, `docs/decisiones.md` D23.

### Pregunta 66 (línea 436): si B4 baja el CPI a la mitad, por qué es peor

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| MIPS de la corrida final | 40 MHz / 2,665 = 15,0 | 46,5 MHz / 1,665 = **27,9** | `docs/decisiones.md`, D23; `asic/rom/resultados/f2_t21p5/cierre.md`; `docs/verificacion/integracion.md` (CPI 1,665) |
| MIPS de v1 | 15,0 | 40,8 MHz / 2,665 = 15,3 (cifra ya corregida en `asic/final.md` y en D23) | `asic/exploraciones.md`, fila "main (referencia)" |
| MIPS de B4 | 16,7 MHz / 1,312 = 12,7 | no cambia | `asic/exploraciones.md`, fila `exp/cpi` |

Conviene agregar la comparación con v1 para que se vea el salto: 27,9 contra 15,3 MIPS, un 82 por
ciento más, con el mismo programa y el mismo enunciado.

### Pregunta 67 (línea 441): por qué no incorporaron B2 si es más rápido

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| premisa | B2 no se incorporó (D22) | B2 **está incorporado** (D23) | `docs/decisiones.md`, D23 |
| costo de slew de B2 | 546 a 672 violaciones | la corrida final tiene 0 violaciones de slew | `asic/rom/resultados/final/metrics.json`; el 672 de v1 en `asic/exploraciones.md`, fila `exp/lsu-offset` |
| costo de área de B2 | 0,6 por ciento menos de área sobre v1 | dos flip-flops en la LSU (`espino_load_store_unit` pasa de 1 a 3 flip-flops locales) | `asic/sintesis.md`, tabla de área por módulo (3) y desglose de `dffq_1` (`addr_q[1:0]`); `git show v1-final:asic/sintesis.md`, línea 28 (1) |
| aporte de B2 sobre este pipeline | no existía | **medido**: 1 ns de período (sin B2 el mínimo que cierra es 22,5 ns, con B2 21,5 ns), y a 100 ns 49 µm² de celdas y 15 ps de WNS | `build/exp_pipeline/asic/rom/resultados/pr_t22p5/cierre.md` (0,007 ns, cierra) y `pr_t22/cierre.md` (-0,597 ns, no cierra); `pr_t100/metrics.json` (208.390 µm², 65,710 ns) contra `asic/rom/resultados/final/metrics.json` (208.439 µm², 65,725 ns) |

**Cómo queda la respuesta.** Hay que darla vuelta: "¿por qué **sí** incorporaron B2?". Porque la ALU
estaba en el camino de alineación y write-back de la carga: registrar `addr[1:0]` al emitir la carga
saca ese camino de la ruta crítica, cuesta dos flip-flops en la LSU y vale 1 ns de período sobre
este mismo pipeline (22,5 ns sin B2 contra 21,5 ns con B2, barrido `pr_*` contra barrido `f2_*`). Se
verificó con las 20 comprobaciones de la sección 3 de `sw/hazard_test.s` (c14 a c33: lb, lbu, lh, lhu
y lw con offsets 0 a 3, con y sin signo, desde la RAM y desde el periférico). El argumento viejo de
que B2 empeoraba el slew tampoco se sostiene: la corrida final tiene 0 violaciones.

### Pregunta 68 (línea 446): qué era B5 y por qué reporta WNS 0,000

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| qué mejoraba B5 | -9,3 por ciento de área y slew/capacitancia de 546/36 a 312/2 | sobre v1 sigue igual; la base de comparación de hoy es 0/1, así que esa mejora ya no existe | `asic/exploraciones.md`, fila `exp/rf-latch` (165.369 µm², 312 / 2); `asic/rom/resultados/final/metrics.json` (0 / 1) |
| préstamo de tiempo de los latches | 3,38 ns | no cambia | `docs/pipeline.md`, sección 5.1 |
| período de B5 con el pipeline nuevo | no medido | 29 ns, con 165.211 µm² de celdas y 20,7 MIPS | `asic/exploraciones.md`, fila `exp/pipeline-b5`; `docs/pipeline.md`, sección 5.1 |

Toda la explicación del préstamo de tiempo y de por qué OpenSTA reporta slack 0 en los latches se
conserva, y es una buena pregunta avanzada. Lo que hay que agregar es por qué B5 no entró (pregunta
nueva 140).

### Pregunta 70 (línea 459): cuántos ciclos toma cada instrucción

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| la mayoría de las instrucciones | 2 ciclos (espera más ejecución) | 1 ciclo | `docs/pipeline.md`, sección 1, tabla de temporización |
| las cargas | 3 ciclos | 2 ciclos | idem |
| los saltos tomados | 3 ciclos (2 más la burbuja) | 2 ciclos (1 más la burbuja) | idem |
| CPI del juego completo | 2,665 | **1,665** (1.595.814 ciclos / 958.358 instrucciones) | `docs/verificacion/integracion.md`, tabla de CPI; `docs/pipeline.md`, sección 3.1 |

**Cómo queda la respuesta.** Un ciclo la mayoría, dos las cargas (esperan el dato registrado de la
memoria o del periférico) y dos los saltos tomados (la instrucción secuencial que ya se había pedido
llega marcada como inválida y deja una burbuja). Desaparece el ciclo de espera de la lectura del banco,
porque la lectura se pide un ciclo antes con la salida combinacional de la ROM. CPI del juego completo:
1,665.

### Pregunta 71 (línea 464): con qué resolución mide el juego el tiempo de reacción

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| duración del lazo `wait_press` | 13 ciclos, 1,3 µs | 8 ciclos, 0,8 µs a 10 MHz | `docs/pipeline.md`, sección 3.6; `asic/sim/resultado.md`, sección Control negativo ("un lazo de polling de 8 ciclos") |
| atraso que no cambia la traza | 5 ciclos | 7 ciclos | `asic/sim/resultado.md`, sección Control negativo |
| atraso que sí la cambia | 6 ciclos, 13 ciclos de diferencia (57 a 70) | 8 ciclos, 8 ciclos de diferencia (51 a 59) | idem |
| debounce | tick cada 2^15 ciclos (3,28 ms), latencia 10 a 13 ms | no cambia | `rtl/debounce.v` (el filtro y el divisor `DivBits`) con `DebounceDivBits = 15` de `rtl/asic_top.v`, línea 24 |

### Pregunta 72 (línea 476): qué utilización usaron y cuál es el área mínima

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| utilización pedida | 40 por ciento | 40 por ciento (no cambia, lo fija el enunciado) | `asic/rom/config.yaml`, línea 41; `resolved.json` |
| utilización real | 48 por ciento | 53,5 por ciento (0,535110) | `asic/rom/resultados/final/metrics.json`, `design__instance__utilization` |
| utilizaciones que cierran | 50, 60 y 70 por ciento | en v1: 50, 60, 70, 72, 75 y 78; **con el diseño nuevo: 50, 60, 70, 72 y 73** | `asic/final.md`, sección "Historia: barrido de FP_CORE_UTIL de v1"; `cierre.md` y `metrics.json` de `asic/rom/resultados/u2_u50`, `u2_u60`, `u2_u70`, `u2_u72` y `u2_u73` (los cinco con **Resultado: CIERRA**) |
| dónde falla | 80 por ciento en el placement detallado del CTS (DPL-0036) y 90 por ciento en el global (GPL-0301) | en v1 fallan 79 y 80 en el CTS y 90 en el global; **con el diseño nuevo**: 74 y 75 por ciento en la reparación de diseño después del ruteo global (paso 41, DPL-0036 con 18 y 77 instancias sin sitio), 78 en el CTS (paso 35, 36 instancias), 80 en la reparación post-placement global (paso 32, 5 instancias) y 90 en el placement global | `asic/rom/resultados/u2_u74/falla.txt`, `u2_u75/falla.txt`, `u2_u78/falla.txt`, `u2_u80/falla.txt` y `u2_u90/falla.txt`; los de v1 en `u1_u79/falla.txt`, `u1_u80/falla.txt` y `u1_u90/falla.txt` |
| área mínima | 70 por ciento, 480,0 x 497,9 µm, 0,239 mm² | en v1: 78 por ciento, 455,4 x 473,3 µm, 215.545 µm² (0,216 mm²), utilización real 90,3 por ciento; **con el diseño nuevo: 73 por ciento, 476,135 x 494,055 µm, 235.237 µm² (0,235 mm²), utilización real 91,8 por ciento** | `asic/final.md` (u1_u78); `asic/rom/resultados/u2_u73/metrics.json` (`design__die__area` = 235237, `design__die__bbox` = 0 0 476.135 494.055, `design__instance__utilization` = 0,917614) y `u2_u73/cierre.md` |

**Cómo queda la respuesta.** 40 por ciento en la final, que lo fija el enunciado, con utilización real
53,5 por ciento. El área mínima sale del barrido de `FP_CORE_UTIL`: con el diseño nuevo cierra hasta
el 73 por ciento, con un die de 476,1 x 494,1 µm (0,235 mm²) y utilización real del 91,8 por ciento, y
el 74 por ciento ya falla, así que el límite queda acotado sin hueco: **73 cierra y 74 no**
(`asic/rom/resultados/u2_u74/falla.txt`, 18 instancias sin sitio en el paso 41). En v1 cerraba hasta
el 78 por ciento, con 0,216 mm². Dato: `asic/rom/resultados/u2_u73/cierre.md`, `u2_u74/falla.txt`.
Pendiente de forma, no de medición: volver a correr `asic/tablas.sh` para que la tabla de utilización
de `asic/final.md` deje de tener solo `final` y `u2_u50` (con `u2_u60` y `u2_u70` como "incompleta") e
incorpore `u2_u72`, `u2_u73` y `u2_u74`.

### Pregunta 73 (línea 481): por qué la utilización real es mayor que la pedida

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| cuenta de dimensionado del core | 152.169 / 0,40 = unos 380.000 µm² | 156.098 / 0,40 = 390.245 µm² (el core medido es 389.525) | `asic/rom/resultados/final/sintesis_stat.rpt`; `metrics.json`, `design__core__area` |
| cuánto sube la utilización real | 8 a 11 puntos | 13,5 puntos a 40 por ciento (40 a 53,5); en el barrido nuevo sube entre 15,3 puntos (50 a 65,3) y 19,7 puntos (72 a 91,7) | `asic/rom/resultados/final/metrics.json`; `design__instance__utilization` de `u2_u50` (0,653222), `u2_u60` (0,768834), `u2_u70` (0,886704), `u2_u72` (0,916600) y `u2_u73` (0,917614) |

El mecanismo no cambia, pero el margen que se agrega es mayor porque los buffers de reparación pasan
de 636 a 1.335.

### Pregunta 74 (línea 486): por qué fallan 80 y 90 por ciento

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| primera utilización que falla | 80 por ciento | 79 por ciento en v1; **74 por ciento con el diseño nuevo** | `asic/final.md`, barrido de `FP_CORE_UTIL`; `asic/rom/resultados/u1_u79/falla.txt`; `asic/rom/resultados/u2_u74/falla.txt` |
| causa del fallo | el placement detallado no encuentra sitios legales | igual, pero el paso cambia: en v1 era el CTS (u1_u79 con 6 instancias, u1_u80 con 22); con el diseño nuevo el primero que se queda sin sitios es el paso 41, la reparación de diseño después del ruteo global, con 18 instancias en u2_u74 y 77 en u2_u75, casi todas del banco de registros | `asic/final.md`; `u1_u79/falla.txt`, `u1_u80/falla.txt` (`asic/logs/u1_u80.log`, línea 17914, para el conteo de 22); `u2_u74/falla.txt` (líneas 6, 26 y 27: "18 instances", "Error: repair_design_postgrt.tcl, 48 DPL-0036", "Classic - Stage 41 - Repair Design (Post-Global Routing)") y `u2_u75/falla.txt` (77 instancias; las dos líneas del paso y del guion están en `asic/logs/u2_u75.log`, líneas 18737 y 18738, no en el extracto versionado) |
| área de celdas móviles a 90 por ciento | 163.776 µm² (152.353 de síntesis más 11.422 de ajuste por densidad de pines) | **169.186,876 µm²** con el diseño nuevo; a 40 por ciento el global placement informa 156.282,874 µm² de móviles y 12.904,003 µm² de ajuste | `asic/rom/resultados/u2_u90/falla.txt` (GPL-0018); `asic/rom/runs/final/28-openroad-globalplacement/openroad-globalplacement.log`, líneas 19 y 21 (GPL-0036 y GPL-0035); el dato de v1 en `docs/hechos_flujo.md`, sección 5 |
| mensaje de fallo a 90 por ciento | `GPL-0301 Utilization 100.531 % exceeds 100%` | `GPL-0301 Utilization 100.620 % exceeds 100%` | `asic/rom/resultados/u2_u90/falla.txt` |

El mecanismo se conserva con la base de área nueva: a 90 por ciento las celdas móviles más el ajuste
por densidad de pines ocupan más que el espacio libre del core. Lo que la medición agrega es que el
límite **bajó**: de 78 por ciento en v1 a 73 con el diseño nuevo, como era de esperar con 1.258 celdas
estándar más, y que el primer paso que se queda sin lugar ya no es el CTS sino la reparación de diseño
posterior al ruteo global, que es uno de los dos pasos que agrega D23.

### Pregunta 75 (línea 494): qué métrica de congestión graficaron

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| métricas graficadas | DRC al inicio del ruteo detallado, largo de cables, slew, capacitancia, antenas, área del die y WNS | no cambia la lista; la figura ya está regenerada | `asic/graficos.py --util`; `docs/figuras/utilizacion.png` (regenerada el 28-10-2026) |
| violaciones de ruteo iniciales del barrido | 1.546, 2, 5 y 2.149 | con el diseño nuevo: 2 a 40 por ciento, 2.219 a 50, 2.189 a 60, 2.793 a 70, 3.252 a 72 y 3.144 a 73 | `route__drc_errors__iter:0` de `asic/rom/resultados/final` y de `u2_u50`, `u2_u60`, `u2_u70`, `u2_u72` y `u2_u73` |
| utilización donde se acaba el lugar | 80 por ciento | 79 por ciento en v1; **74 por ciento con el diseño nuevo** | `asic/final.md`; `asic/rom/resultados/u2_u74/falla.txt` |

Dato que conviene decir: con el diseño nuevo las violaciones iniciales del ruteo detallado sí siguen
tendencia creciente con la utilización (2.219, 2.189, 2.793, 3.252, 3.144), al contrario que en v1,
donde la serie no tenía forma; y el slew también se degrada (8, 0, 20, 92 y 99 pines de 50 a 73 por
ciento, contra 0 a 40 por ciento), lo que da un segundo argumento para no subir la utilización.

### Pregunta 76 (línea 500): por qué los terminales están donde están

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| reparto por función | entradas al oeste, displays al este, LEDs al norte, SPI al sur | no cambia, y el layout nuevo lo confirma pin por pin | `asic/rom/pines.cfg`; `asic/rom/resultados/final/layout/bloques.txt`, lista de terminales (btn y clk y rst_n en Metal3 al oeste, led en Metal2 al norte, seg1 y seg2 en Metal3 al este, spi en Metal2 al sur) |
| comparación con los terminales automáticos | más 0,4 por ciento de cable, mismo WNS | **por medir** (hay que repetir la corrida de `asic/rom/config_pines_auto.yaml` con el RTL y la configuración nuevos; `asic/final.md` lo dice con esas palabras: "No se repitió con la configuración nueva") | `asic/final.md`, sección "Historia: terminales ubicados por el flujo (sin D21)" (u1_auto, de v1: 182.204 µm² de celdas y WNS 65,213 contra 65,223) |

### Pregunta 78 (línea 513): cuánto costaría y qué limita esa estimación

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| die y costo de la corrida final | 0,409 mm², 9.406 dólares | 0,419131 mm², **9.640 dólares** | `asic/rom/resultados/final/metrics.json` (`design__die__area` = 419131); `docs/decisiones.md`, D23; `docs/datos_informe.md` |
| costo al área mínima | 70 por ciento, 5.496 dólares | en v1: 78 por ciento, 0,215545 mm², unos 4.958 dólares; **con el diseño nuevo: 73 por ciento, 0,235237 mm², unos 5.410 dólares** | `asic/final.md` (u1_u78: die 215.545 µm²); `asic/rom/resultados/u2_u73/metrics.json` (235.237 µm²); cuenta a 23.000 dólares/mm² |
| costo de la estrategia 2 | 41.266 dólares (s2_t100, configuración de D15) | sigue valiendo para esa corrida (1,794180 mm² por 23.000 = 41.266 dólares); con el RTL y la configuración nuevos son **41.437 dólares** (1,801610 mm², `s4_t100`), 4,3 veces el de la estrategia 1 | `asic/barrido.md` (die 1794180); `asic/ff/resultados/s4_t100/metrics.json` (1801610); `docs/datos_informe.md`, sección 3.2 |
| lo que el modelo lineal ignora | cupo de la oblea, pads, anillo de sello, encapsulado, máscaras, volumen y rendimiento | no cambia | la respuesta actual |

**Cómo queda la respuesta.** A 23.000 dólares/mm²: la final 0,419 mm² da 9.640 dólares, y el área
mínima medida con el diseño nuevo (73 por ciento de utilización) 0,235 mm², unos 5.410 dólares; la
estrategia 2 con la misma configuración, 1,802 mm² y 41.437 dólares. El dato que conviene agregar para
la defensa es que el área de celdas sube 14,4 por ciento con D23 pero el costo sube solo 2,5 por
ciento, porque el die lo fija `FP_CORE_UTIL` sobre el área de la síntesis y no el área que ocupan las
celdas después del resizer (pregunta nueva 143).

### Pregunta 80 (línea 525): qué decisión pesó más en área y costo

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| cuántas veces más grande es el die de la estrategia 2 | 4,6 veces | **4,3 veces** medidas con el RTL y la configuración nuevos (1.801.610 / 419.131) | `asic/ff/resultados/s4_t100/metrics.json`; `asic/rom/resultados/final/metrics.json`; `docs/datos_informe.md`, sección 3.2 |
| cuánto baja el die al subir la utilización | de 40 a 70 por ciento baja 42 por ciento | en v1: de 40 a 78 por ciento baja 47,3 por ciento (408.957 a 215.545 µm²); **con el diseño nuevo: de 40 a 73 por ciento baja 43,9 por ciento (419.131 a 235.237 µm²)** | `asic/final.md` (final y u1_u78); `asic/rom/resultados/u2_u73/metrics.json` |
| aporte del RTL y de la configuración | pre-decodificación más configuración del flujo: 5 por ciento de celdas (3,9 por ciento de die) | pipeline más modelo de cable: 14,4 por ciento de celdas y **2,5 por ciento de die** (408.957 a 419.131 µm²) | `docs/decisiones.md`, D23 |

El orden de las causas se mantiene (primero la estrategia de memoria, después la utilización, después
el RTL y la configuración), pero la tercera hay que renombrarla.

### Pregunta 81 (línea 530): cómo es la red de alimentación

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| rieles y ancho de las franjas | rieles de 0,6 µm en Metal1, franjas de 1,6 µm | no cambian | `docs/hechos_flujo.md`, sección 4.1 (`PDN_RAIL_WIDTH` 0,6; `PDN_VWIDTH` y `PDN_HWIDTH` 1,6) |
| franjas de la grilla | 8 verticales en Metal4 cada 153,6 µm y 8 horizontales en Metal5 cada 153,2 µm | **no cambian**: 8 verticales en Metal4 y 8 horizontales en Metal5, en las mismas posiciones que en v1, con paso 153,6 µm en Metal4 y 153,18 µm en Metal5 (el valor exacto de `PDN_HPITCH`) | `asic/rom/runs/final/21-openroad-generatepdn/asic_top.def`, sección `SPECIALNETS`, comparado contra el mismo DEF de `v1_final_run` (idénticos); `docs/hechos_flujo.md`, sección 4.1, que verifica que las 36 variables `PDN_*` tienen el mismo valor que en v1 |
| caída de tensión peor | 0,15 mV en VDD y 0,25 mV en VSS | 0,611 mV en VDD y 0,219 mV en VSS | `asic/rom/resultados/final/metrics.json`, `design_powergrid__drop__worst__net:VDD` y `__net:VSS` |
| consumo que lo justifica | unos 9 mW, menos de 2 mA | 9,620 mW, 1,92 mA a 5 V | `asic/rom/runs/final/57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`, fila Total |

La conclusión no cambia: 0,611 mV frente a 5 V es el 0,01 por ciento. Y hay que corregir una cosa de
la respuesta vieja: el die crece (de 630,60 x 648,52 a 638,505 x 656,425 µm) pero la grilla de
alimentación es exactamente la misma, porque su paso y su desplazamiento son fijos.

### Pregunta 82 (línea 538): para qué sirven las 2.466 celdas de tap

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| celdas de tap | 2.466 | 2.497 | `asic/rom/resultados/final/metrics.json`, `design__instance__count__class:tap_cell`; `55-odb-cellfrequencytables/cell.rpt` (`filltie` 2497) |
| celdas de borde | 314 | 318 | idem, `class:endcap_cell`; `cell.rpt` (`endcap` 318) |
| filas del core | no citado en esta pregunta (157) | 159 | `asic/rom/resultados/final/metrics.json`, `design__rows` = 159 (v1: 157) |

La explicación del latch-up, el tiristor parásito y la distancia de 20 µm no cambia; los conteos suben
porque el die tiene dos filas más.

### Pregunta 83 (línea 544): y las 12.152 celdas de relleno

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| celdas de relleno | 12.152 | 12.390 | `asic/rom/resultados/final/metrics.json`, `design__instance__count__class:fill_cell` |
| desglose | 5.541 de relleno simple (`fill_1`, `fill_2`) y 6.611 de desacople (`fillcap_4` a `fillcap_64`) | 5.942 de relleno simple (`fill_1` 3.040 y `fill_2` 2.902) y 6.448 de desacople (`fillcap_4` 2.770, `fillcap_8` 1.911, `fillcap_16` 1.085, `fillcap_32` 429, `fillcap_64` 253) | `asic/rom/runs/final/55-odb-cellfrequencytables/cell.rpt` y `cell_function.rpt` (`fill` 5942, `fillcap` 6448) |
| área que ocupan | 197.535 µm² | 181.086 µm² | `asic/rom/resultados/final/metrics.json`, `design__instance__area__class:fill_cell` |

Dato interesante para la defensa: hay más celdas de relleno pero ocupan menos área, porque las celdas
lógicas y los buffers nuevos se comieron el espacio libre y el relleno que queda es de celdas más
chicas.

### Pregunta 84 (línea 550): cuánta potencia consume y de qué depende

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| potencia a 10 MHz en la esquina típica | 8,97 mW (7,02 interna, 1,95 de conmutación, 1,9 µW de fuga) | 9,620 mW (7,555 interna, 2,062 de conmutación, 2,05 µW de fuga) | `asic/rom/runs/final/57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`, fila Total; el valor de v1 en `asic/rom/runs/v1_final_run/55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt` |
| potencia a la frecuencia máxima | 35,8 mW a 40 MHz (f1_t25) | 44,74 mW a 46,5 MHz (f2_t21p5) en la esquina típica | `asic/rom/runs/f2_t21p5/57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`, fila Total (4.473707e-02 W) |
| potencia que informa `metrics.json` (esquina rápida max_ff) | 11,3 mW | 12,10 mW (9,48 interna, 2,62 de conmutación, 2,5 µW de fuga) | `asic/rom/resultados/final/metrics.json`, `power__total`, `power__internal__total`, `power__switching__total`, `power__leakage__total` |

La fórmula (potencia dinámica proporcional a alfa por C por V al cuadrado por f, fuga despreciable en
180 nm) y el aviso sobre la esquina de `metrics.json` se conservan.

### Pregunta 85 (línea 557): ese número es la potencia real

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| reparto de la estimación sin actividad | flip-flops 58,6 por ciento y árbol de reloj 41,3 por ciento, combinacional 3 µW | secuencial 52,2 por ciento y reloj 47,7 por ciento, combinacional 3,56 µW (0,0 por ciento) | `asic/rom/runs/final/57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`, columna de porcentajes; tabla repetida en `docs/hechos_flujo.md`, sección 10, y en `asic/potencia/resultado.md`, sección 3 |
| "para un número real habría que simular el juego" | pendiente | **ya está medido en los dos diseños**. En v1: 11,504 mW en la ventana de polling y 12,755 mW en la espera de 3 s, contra 8,971 mW de la estimación del flujo (nom_tt). En la corrida final nueva: 9,734 mW solo reloj, 13,936 mW en polling (+44,9 por ciento), 16,615 mW en la espera de 3 s (+72,7 por ciento), 15,906 mW alrededor del 01 del display y 15,912 mW en la ráfaga, todo en nom_tt, contra 9,620 mW del flujo | `asic/potencia/resultado.md`, secciones 1 a 3 (corrida nueva, `bash asic/potencia/correr.sh todo`, reportes en `asic/potencia/resultados/`); `asic/potencia/resultado_v1.md`, sección 1 (v1, reportes en `asic/potencia/resultados_v1/`) |
| fuga por temperatura | 1,9 µW a 25 °C y 12,3 µW en la esquina lenta | 2,05 µW a 25 °C y 13,1 µW en max_ss | `power.rpt` de `nom_tt_025C_5v00` (2.051293e-06) y de `max_ss_125C_4v50` (1.310728e-05) de la corrida final |

**Cómo queda la respuesta.** Es una cota inferior, y ahora se sabe por cuánto. El flujo no recibe
actividad de conmutación (ni VCD ni SAIF), así que casi todo lo que estima es el reloj: en la corrida
final, 52,2 por ciento de los flip-flops y 47,7 por ciento del árbol de reloj, con la lógica
combinacional en 3,56 µW. Para un número real hay que simular el juego, guardar la actividad y
dársela al análisis de potencia: eso se hizo con el netlist nuevo y da 13,936 mW en la ventana de
polling y 16,615 mW en la espera de 3 s, contra los 9,620 mW que estimaba el flujo (45 y 73 por
ciento más); en v1 la misma medición daba 11,504 y 12,755 mW contra 8,971. Con actividad real, el
reloj más los registros son el 70,6 por ciento del total en la ventana de polling y el 59,6 en la de
espera (`asic/potencia/resultado.md`, sección 3). La esquina de mayor potencia es `max_ff_n40C_5v50`
con 21,279 mW en la ventana de espera. La fuga sí cambia con la temperatura: 2,05 µW a 25 °C y
13,1 µW en la esquina lenta, a 125 °C.

### Pregunta 86 (línea 564): cómo es el árbol de reloj

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| buffers del árbol | 75 en 3 niveles (66 `clkbuf_8` y 9 `clkbuf_16`) | el CTS crea 122 buffers de reloj (121 `clkbuf_8` y 1 `clkbuf_16`); el layout termina con 172 buffers de reloj y 28 inversores | `asic/rom/runs/final/35-openroad-cts/openroad-cts.log` (CTS-0018) y `cts.rpt` (121 y 1); `docs/hechos_flujo.md`, sección 6.2; `asic/rom/resultados/final/metrics.json`, `class:clock_buffer` y `class:clock_inverter` |
| cargas ficticias | 61 | 78 | `openroad-cts.log` (CTS-0207 "Dummy loads inserted 78"); v1: 61 en el mismo mensaje de `v1_final_run` |
| flip-flops que alimenta | 990 | 964 sumideros, agrupados en 105 | `openroad-cts.log` (CTS-0010 "has 964 sinks" y CTS-0019 "Total number of sinks after clustering: 105"); v1: 990 y 66 |
| niveles del H-Tree | 3 | **4** (nivel 1 horizontal con 53 sumideros por subregión, 2 vertical con 27, 3 horizontal con 14, 4 vertical con 7) | `docs/hechos_flujo.md`, sección 6.4 ("cuatro niveles, no tres como en v1"); `openroad-cts.log`, CTS-0034, líneas 62 a 81 |
| buffers en el camino de reloj | no citado | 3 mínimo y 3 máximo, igual que en v1 | `openroad-cts.log` (CTS-0012 y CTS-0013), en la corrida nueva y en `v1_final_run` |
| latencia del reloj | 1,25 a 1,48 ns en la típica y 2,26 a 2,70 ns en max_ss | **1,295 a 1,498 ns en la típica y 2,359 a 2,720 ns en max_ss** (sube un poco, porque el árbol tiene un nivel más) | `docs/hechos_flujo.md`, sección 6.3, tabla de latencia de red por esquina (de `57-openroad-stapostpnr/<esquina>/clock.rpt`) |

Ojo con la respuesta vieja: decía "75 buffers en 3 niveles". Los dos números cambian, pero por motivos
distintos: los buffers suben a 122 porque con los RC medidos el largo máximo de cable sin buffer baja
de 11.309 a 4.491 µm (`openroad-cts.log`, RSZ-0058, en `v1_final_run` y en `final`;
`docs/hechos_flujo.md` sección 6.4), y los niveles del H-Tree pasan de 3 a 4 porque hay más sumideros
agrupados que repartir.

### Pregunta 87 (línea 570): cómo se obtienen los parásitos que usa el STA

No cambia ninguna cifra, pero la respuesta es incompleta justo en el tema central de D23. Hoy termina
diciendo "Antes del ruteo el flujo solo puede estimarlos". Hay que agregar cómo los estima y qué se
hizo: por omisión usa un solo par de valores, el promedio de las capas de ruteo del tech LEF
(0,2752 ohm/µm y 64,3 aF/µm), que subestima la capacidad entre 2,3 y 2,9 veces contra lo que OpenRCX
extrae del ruteo detallado; la configuración final le da los valores por capa y por esquina con
`LAYERS_RC`, para que el resizer y el CTS decidan con parásitos parecidos a los finales. Es la antesala
natural de las preguntas nuevas 141 y 142. Dato: `asic/modelo_cable.md`, secciones 1 y 2;
`docs/modelo_cable.md`, secciones 1 y 2 (la tabla de la sección 2 trae los factores 2,93 / 2,59 / 2,30
de capacidad y 2,18 / 1,99 / 1,81 de resistencia).

### Pregunta 88 (línea 580): qué resultados de signoff tienen

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| DRC de Magic | 0 | 0 (confirmado en la corrida nueva) | `asic/rom/resultados/final/cierre.md`; `metrics.json`, `magic__drc_error__count` |
| LVS | 0 diferencias | 0 (confirmado) | idem, `design__lvs_error__count` |
| nets con violación de antena | 0 | 0 (confirmado) | idem, `antenna__violating__nets` |
| DRC de KLayout | 0 marcadores en 684 reglas | 0 marcadores **sobre el GDS nuevo**, con 684 reglas evaluadas por el deck | `asic/rom/resultados/final/drc_klayout/resumen.md`, que lo escribe así: "0 marcadores en 0 reglas (de 684 reglas evaluadas por el deck)" |

Ninguna cifra cambia de valor, pero las cuatro hay que re-citarlas de la corrida nueva, y las cuatro
ya están medidas. Esto corrige al mapa de la etapa 1, que daba el DRC de KLayout por medir. Y conviene
decir la cifra como la escribe el archivo (0 marcadores, 684 reglas evaluadas), no "0 marcadores en
684 reglas", que se puede leer como que las 684 reglas marcaron cero cada una.

### Pregunta 90 (línea 589): por qué dos DRC y cómo saben que el de KLayout funciona

No cambia ninguna cifra: el motivo de correr el deck aparte (la copia del PDK que instala ciel no trae
las reglas) y el control positivo (un trazo de Metal1 de 0,20 µm y dos separados por 0,15 µm, con
mínimos de 0,23 µm, que el deck marca como M1.1 y M1.2a) siguen igual. Lo que hay que decir es que el
control se repitió sobre el GDS nuevo, con el mismo resultado: 2 marcadores en 2 reglas, cada uno en
las coordenadas donde debía caer, y 0 marcadores sobre el GDS sin modificar. Dato:
`asic/rom/resultados/final/drc_klayout/control_positivo.md` y `resumen.md`.

### Pregunta 91 (línea 596): qué violación apareció durante el desarrollo

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| el caso de la antena | 1 net en s2_t100 (net3342, pin `fanout3341/I`, razón 449,1 contra el máximo de 400, 1,12 veces) | sigue siendo cierto y hay que decir explícitamente de qué corrida sale: la estrategia 2 de v1, con la configuración de D15 | `asic/ff/resultados/s2_t100/antenna_summary.rpt`; `docs/datos_informe.md`, sección 3.6 |
| celdas de antena de la corrida final | 0 | 1 (con 0 nets en violación) | `asic/rom/resultados/final/metrics.json`, `design__instance__count__class:antenna_cell` = 1 y `antenna_diodes_count` = 1 (en v1 la clave de celdas de antena no existe y `antenna_diodes_count` es 0) |
| la estrategia 2 con la configuración final | no existía | **0 nets en violación** y 6 diodos insertados por el flujo (7 celdas de antena) | `asic/ff/resultados/s4_t100/metrics.json`; `docs/datos_informe.md`, sección 3.2, punto 3 |

**Cómo queda la respuesta.** Hay que presentarla como un hallazgo de v1, con su corrida: una violación
de antena en la estrategia 2 (`s2_t100`), donde el net `net3342` reparte una señal de alto fanout
entre cinco buffers sobre 666 x 364 µm y en el pin `fanout3341/I` la razón entre el área lateral del
Metal2 conectado y el área de compuerta es 449,1, es decir 1,12 veces el máximo de 400. La estrategia 1
no la tuvo nunca, con un matiz nuevo que conviene decir: la corrida final nueva inserta una celda de
antena donde v1 no insertaba ninguna, y sigue con 0 nets en violación. **Y la violación desapareció
también del lado de la estrategia 2**: con el core y la configuración de D23, `s4_t100` cierra con
0 nets en violación y 6 diodos. El mapa de la etapa 1 acertaba en eso, pero citaba mal: el `e2_t100`
de `main` (`asic/ff/resultados/e2_t100/metrics.json`) es una corrida temprana con el RTL de v1 e
informa `antenna__violating__nets = 1`, 153 celdas de antena y 93 diodos, así que esa cita no sirve;
la buena es `s4_t100` (aviso de colisión de tags en `asic/ff/resultados/LEEME.md`).

### Pregunta 93 (línea 609): cómo resolvieron la violación de antena

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| diodos heurísticos | 0 violaciones, 36.385 celdas de antena, 18 por ciento más de área, 16 ns menos de slack | sigue valiendo como medición de v1 (área 838.173 a 992.171 µm², WNS 39,65 a 23,65 ns) | `docs/datos_informe.md`, sección 3.6; `asic/ff/resultados/s2_t100_diodos/` |
| más iteraciones y margen en el ruteo global | 0 violaciones con 258 celdas de antena en vez de 150, sin más área | sigue valiendo como medición de v1 (833.559 µm², WNS 30,03 ns) | idem; `asic/ff/resultados/s2_t100_antrep/` |
| "la estrategia 1 nunca la tuvo" | cierto | cierto, con el matiz de que la corrida final nueva inserta 1 celda de antena | `asic/rom/resultados/final/metrics.json` |
| hace falta todavía alguna de las dos soluciones | sí, para la estrategia 2 | **no con la configuración final**: `s4_t100` cierra con 0 nets y 6 diodos, sin las perillas de antena | `asic/ff/resultados/s4_t100/metrics.json`; `asic/ff/config_final.yaml` (no define `GRT_ANTENNA_REPAIR_*`) |

### Pregunta 96 (línea 628): cómo marcaron el register file, la ALU y el contador

No cambia ninguna cifra (la pregunta no cita números): el método es el mismo, los prefijos de instancia
sobreviven en el DEF y `asic/layout/anotar.py` los colorea. Lo que hay que decir es que las figuras y
sus archivos de datos se regeneraron a partir de la corrida final nueva:
`asic/rom/resultados/final/layout/bloques.png`, `bloques.lyrdb`, `bloques.txt`, `ruta_critica.png`,
`ruta_critica.txt`, `slew.png` y `slew.txt`, más los siete equivalentes de `f2_t21p5`. Lo que el mapa
de la etapa 1 daba por abierto (a qué módulo pertenece el flip-flop de llegada de la ruta crítica del
período mínimo, pregunta 40) **ya está resuelto**: `asic/rutas.md`, líneas 17 a 25, lo busca en el
netlist de la corrida (`grep -A3 "dffrnq_1 _4440_" asic/rom/runs/f2_t21p5/final/nl/asic_top.nl.v`) y
devuelve `.Q(\u_soc.u_periph.digit_q[4] )`, es decir el bit 4 del registro del display del periférico.
El `ruta_critica.txt` de `f2_t21p5` sigue mostrando esa entrada 39 como "logica aplanada sin nombre
jerarquico", así que lo que queda es de forma: correr el anotador sobre el netlist jerárquico para que
la figura también lo nombre.

### Pregunta 97 (línea 634): por qué el register file mide distinto en la figura y en la síntesis

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| área del banco en el layout | 78.186 µm² | 96.935,6 µm² (2.963 celdas) | `asic/rom/resultados/final/layout/bloques.txt` |
| área del banco en la síntesis | 73.656 µm² | 80.349 µm² | `asic/rom/resultados/final/sintesis_stat.rpt` |
| base de celdas lógicas de los porcentajes | 170.060 µm² | 196.079,7 µm² (sin celdas de relleno) | `asic/rom/resultados/final/layout/bloques.txt`, encabezado |
| porcentajes de los tres módulos | 46 por ciento, 6,2 por ciento y 2,3 por ciento | 49,44 por ciento (banco), 5,98 por ciento (ALU) y 2,04 por ciento (contador) | idem |

El mecanismo no cambia: el resizer agrega buffers dentro del módulo en el layout, y por eso el banco
mide más en la figura que en la síntesis.

### Pregunta 98 (línea 638): por qué el ruteo detallado parte con 1.546 violaciones

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| violaciones de la primera pasada | 1.546 | **2** | `asic/rom/resultados/final/metrics.json`, `route__drc_errors__iter:0` |
| serie por iteración | 1.546, 501, 379, 0 (llega a 0 en la iteración 3) | 2, 0, 430, 3, 0 (cinco iteraciones, llega a 0 en la iteración 4) | idem, `route__drc_errors__iter:0` a `:4` |
| comparación con terminales sin orden fijo | 1.546 contra 6 | **por medir** (hay que repetir la corrida de terminales automáticos) | `asic/final.md`, sección "Historia: terminales ubicados por el flujo (sin D21)" (dato de v1) |

**Cómo queda la respuesta.** La premisa de la pregunta se cae: con la configuración nueva el ruteo
detallado parte con 2 violaciones, no con 1.546. El mecanismo iterativo se conserva y conviene explicar
la serie, que ahora tiene cinco pasadas (2, 0, 430, 3 y 0): el salto a 430 en la tercera es efecto de
la reparación de diseño después del ruteo global, que agrega buffers y obliga a reencaminar zonas que
ya estaban limpias; las dos últimas pasadas lo dejan en 0. Dato adicional: el paso de ruteo detallado
hace dos subcorridas (`drt-run-0` y `drt-run-1`) y en v1 hacía una (`docs/hechos_flujo.md`, sección 7).

### Pregunta 101 (línea 660): cómo sabe el testbench qué botón apretar

La pregunta no cita ciclos, pero su respuesta se apoya en los estímulos versionados, y esos sí cambian.

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| ciclo en que se enciende el LED objetivo de la ronda 1 | 781 | 615 | `asic/sim/estimulos.txt`, comentario de la ronda 1; el 781 en `git show v1-final:asic/sim/estimulos.txt`; `docs/pipeline.md`, sección 3.6 |
| ciclos de las pulsaciones | 300, 801, 2141 y 2719 | 300 (inicio), 635, 1373 y 1733 | `asic/sim/estimulos.txt`; los de v1 en `git show v1-final:asic/sim/estimulos.txt` |
| método | correr el RTL por etapas con `asic/sim/calibrar.py` | no cambia; la integración confirmó que el archivo versionado es byte a byte el que vuelve a generar el calibrador | `docs/verificacion/integracion.md`, fila 15 |

### Pregunta 102 (línea 665): qué muestran los resultados

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| ciclos que mide la ronda correcta | 57 | 51 | `asic/sim/resultado.md`, líneas 3 y 8 |
| ciclo en que el display lo muestra | 1.574 | 1.033 en la ronda 1 y 2.131 en la ronda 2 | idem |
| ciclo en que aparece EE | 2.181 | 1.405 | idem, línea 5 |
| ciclo en que vuelve a la ronda 02 | no citado | 1.507 | idem, línea 6 |
| cambios de salida y valores X | 17 cambios en 4.500 ciclos, 0 X | 17 cambios en 4.500 ciclos, 0 X (no cambia) | idem; `docs/verificacion/integracion.md`, fila 13 |

### Pregunta 103 (línea 670): cómo saben que la comparación detectaría un error

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| atraso del control negativo | 6 ciclos | 8 ciclos | `asic/sim/resultado.md`, sección Control negativo; `docs/verificacion/integracion.md`, fila 14 |
| qué muestra el display con el atraso | 70 en vez de 57 | 59 en vez de 51, en el ciclo 1.089 | `asic/sim/resultado.md`, línea 40 ("primera diferencia en la linea 5: RTL=(1033, '0010', '51') netlist=(1089, '0010', '59')") |
| atraso más grande que no cambia la traza | 5 ciclos | 7 ciclos | idem |
| duración del lazo de polling | 13 ciclos | 8 ciclos | idem; `docs/pipeline.md`, sección 3.6 |

### Pregunta 104 (línea 675): si el STA cierra, para qué simular el netlist

No cambia ninguna cifra, pero la última frase dejó de ser cierta y hay que corregirla. Hoy dice que
una verificación formal de equivalencia lo probaría para todas las entradas, que LibreLane trae el
paso `Yosys.EQY` pero "viene apagado y no se usó". El frente D2 la corrió, fuera del flujo, sobre los
netlists de los dos diseños, y los dos resultados ya están escritos:

| qué | v1 (`docs/equivalencia_v1.md`) | corrida final nueva (`docs/equivalencia.md`) |
|---|---|---|
| eqy contra el netlist de síntesis | PASS, 22 de 22 particiones (21 por `sat`, 1 por `pdr`) | **29 de 30 particiones**; la grande, `asic_top.led.0` (807 salidas), queda sin decidir: `sat` agota sus 5 pasos y `pdr` da un contraejemplo desde un estado inicial inalcanzable |
| eqy contra el netlist post-PnR | PASS, 21 de 21 particiones | 29 de 30, con la misma partición grande (799 salidas) sin decidir |
| flujo clásico de Yosys (`equiv_make`, `equiv_simple -seq 2`, `equiv_induct -seq 4`) | PASS: 1.002 celdas `$equiv` contra la síntesis (3 + 999) y 994 contra el post-PnR (3 + 991) | **PASS, y es la prueba que cierra el caso**: 976 celdas `$equiv` contra la síntesis (5 por `equiv_simple` y 971 por `equiv_induct`, 0 sin probar) y **968 contra el post-PnR** (5 + 963, 0 sin probar) |
| miter completo desde reset (sby, `smtbmc yices`) | PASS a 24 pasos contra los dos netlists y a 100 pasos contra el de síntesis | **PASS a 24 pasos y a 100 pasos** contra el netlist de síntesis (`asic/eqy/resultados/sint_v1ff/bmc_24_resumen.txt` y `asic/eqy/resultados/sint_v1/bmc_100_resumen.txt`, los dos con "DONE (PASS, rc=0)") |
| control negativo (una celda cambiada en la ALU) | eqy FAIL, como corresponde | eqy **no discrimina** (la partición que contiene la ALU es la que queda sin decidir) y el BMC de 24 pasos tampoco; el que sí discrimina es el flujo clásico: prueba 776 de 976 celdas y deja 200 sin probar |
| paso `Yosys.EQY` del flujo | falla: con el guion genérico no encuentra `game_image.vh`; con guion propio, la imagen de LibreLane no trae `make`, que eqy necesita | igual, no depende del diseño |

Así que la respuesta nueva es: la equivalencia formal **está hecha para los dos diseños**, el RTL y
los dos netlists de la corrida final son equivalentes, y hay que decir con honestidad quién lo prueba
(el flujo clásico de Yosys por inducción, más el miter desde reset) y qué se perdió respecto de v1
(eqy deja una partición sin decidir, y por eso su control negativo dejó de discriminar). Dato:
`docs/equivalencia.md`, sección 1; `docs/equivalencia_v1.md`, sección 1.

### Pregunta 105 (línea 682): el banco no tiene reset, por qué no aparecen X

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| escrituras al banco revisadas sin X usados | 388.411 | 620.217 (estrategia 1, 10 rondas) | `docs/verificacion/integracion.md`, tabla del monitor de X |
| qué protege los registros de decode | se cargan antes de usarse (ciclo de espera) | se cargan en el mismo flanco que la instrucción, y lo que protege es `instr_valid_i` | `docs/pipeline.md`, sección 2 (riesgo 6); `rtl/espino_core/espino_id_stage.v`, línea 258 (`lsu_req_o = lsu_req_dec & instr_valid_i & rf_ready_o`) |
| valores X usados con la mutación `MUTA_FWD` | no existía | 77 (36 en `rf_wdata` y 41 en operandos de la ALU) | `docs/verificacion/integracion.md`, fila 8 |

**Cómo queda la respuesta.** Por tres razones, y la tercera es nueva. El programa escribe cada registro
antes de leerlo (D4). Los registros de decode se cargan en el mismo flanco que la instrucción y todo lo
que los consume está condicionado a `instr_valid_i`, que vale 0 el primer ciclo. Y el write-through
hace que la lectura que cae en el mismo flanco de una escritura tome el dato que se está escribiendo,
en vez del valor sin inicializar del arreglo. Un monitor sobre la simulación del juego completo no
encontró ningún valor desconocido usado en 620.217 escrituras al banco, y cuando se quita el
write-through a propósito (mutación `MUTA_FWD`) cuenta 77, lo que demuestra que el monitor funciona.

### Pregunta 106 (línea 687): hicieron la simulación con SDF

No cambia ninguna cifra de la respuesta, pero el estado hay que corregirlo del todo: la simulación con
SDF **ya está hecha sobre el netlist nuevo**. `asic/sim/resultado_sdf.md` es hoy el documento de la
corrida `d2_pnr` (el flujo completo con la configuración de simulación de D23,
`asic/sim/config_pnr.yaml`), con el mismo testbench y el mismo escenario de `make post-synth`
(4.500 ciclos, ronda correcta de **51** ciclos medidos), en **tres** esquinas: `nom_tt_025C_5v00`,
`max_ss_125C_4v50` y `min_ff_n40C_5v50`. Resultado con Icarus 13.0 de la imagen de LibreLane: en las
tres esquinas la traza del netlist con retardos es idéntica a la del RTL (md5
`5b6cebfb898a90a258b592fb29e64651`), sin valores X, y reproducible en las tres ejecuciones de cada
esquina (nueve trazas, un solo md5). Open Verilog CVC 7.00b, que sí evalúa los timing checks, está en
la sección 4 con su control positivo. Dos avisos de fuente: la corrida de v1 era `d1_pnr` y sus
reportes siguen en `asic/sim/resultados/d1_pnr/`, pero sus **números** (57 ciclos medidos, md5
`4f14ec05462e4789a3d873d2ba50fd97`, cuatro esquinas) ya no están en `asic/sim/resultado_sdf.md`: están
en el historial de git de ese archivo. Y lo medido sin retardos con el netlist nuevo es `make
post-synth` (PASS, 17 cambios de salida, 0 X) con su control negativo. Dato:
`asic/sim/resultado_sdf.md`; `docs/verificacion/integracion.md`, filas 13 y 14.

### Pregunta 107 (línea 697): recorre un `add` ciclo a ciclo

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| ciclos de un `add` | 2 (espera más ejecución) | 1 | `docs/pipeline.md`, sección 1, tabla de temporización |
| señal que detenía el fetch | `ops_valid_q = 0`, de ahí `rf_ready = 0` | no existe con `EarlyRead = 1`: `rf_ready_o = 1'b1` siempre | `docs/pipeline.md`, sección 1; `rtl/espino_core/espino_id_stage.v`, bloque `g_early`, línea 132 |

**Cómo queda la respuesta.** En el flanco N se cargan tres cosas a la vez: el registro de instrucción
(en la memoria), los operandos (lectura registrada del banco, con rs1 y rs2 tomados de la salida
combinacional de la ROM, `a_next_o`) y las 82 salidas registradas del decodificador; `pc_q` avanza. En
el ciclo N la ALU suma, con operandos y decode ya listos. En el flanco N+1 se escribe `rd` (`rf_we` con
`commit`) y, en el mismo flanco, se cargan la instrucción siguiente y sus operandos, con write-through
si esa instrucción lee el registro que la actual acaba de escribir. Un ciclo, sin ciclo de espera.

### Pregunta 108 (línea 703): y un `lw`

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| ciclos de un `lw` | 3 | 2 | `docs/pipeline.md`, sección 1, tabla de temporización |
| de dónde sale el offset de alineación | `addr[1:0]` de la salida de la ALU en el mismo ciclo | la copia registrada de `addr_i[1:0]` que la LSU guardó al emitir la carga (B2) | `rtl/espino_core/espino_load_store_unit.v`; `asic/sintesis.md`, desglose de `dffq_1` (`addr_q[1:0]`, 2 flip-flops en la LSU) |
| qué hace el banco durante el stall | leía igual | no vuelve a leer (`rf_rd_en_o = ~stall_i`, el `advance` del bloque `g_early`) y conserva los operandos de la carga | `docs/pipeline.md`, sección 2 (riesgo 2); `rtl/espino_core/espino_id_stage.v`, líneas 122 (`wire advance = ~stall_i;`) y 147 (`assign rf_rd_en_o = advance;`) |

**Cómo queda la respuesta.** Igual que un `add` hasta la ejecución. En el ciclo 1 la ALU calcula la
dirección, la LSU emite la lectura y registra los dos bits bajos de la dirección, y `busy` detiene el
pipeline un ciclo; mientras hay stall el banco no vuelve a leer, así que los operandos de la carga se
conservan (la ALU sigue calculando la dirección) y la lectura de la instrucción siguiente se posterga.
En el ciclo 2 llega el dato registrado de la memoria o del periférico, la LSU lo alinea con el offset
registrado y en el flanco del commit se escribe en el banco y, a la vez, se leen los operandos de la
instrucción siguiente, con write-through si usa ese registro. Son dos ciclos y el riesgo de carga
seguida de uso queda resuelto sin burbuja extra.

### Pregunta 109 (línea 708): y un salto tomado

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| ciclos de un salto tomado | 3 (2 más la burbuja) | 2 (1 más la burbuja) | `docs/pipeline.md`, sección 1, tabla de temporización |
| cálculo del destino | `pc + imm` o `(rs1 + imm) & ~1` | no cambia | `rtl/espino_core/espino_id_stage.v` |

El mecanismo de la burbuja se conserva (`pc_set` carga el PC y la instrucción ya pedida llega con
`valid_q = 0`), y hay que agregar que esa instrucción descartada registra igual sus operandos y su
decode, sin efecto, porque `lsu_req_o`, `rf_we_o` (vía `commit`) y `pc_set_o` están condicionados a
`instr_valid_i`. Dato: `docs/pipeline.md`, sección 2 (riesgo 5).

### Pregunta 110 (línea 714): qué hacen `ops_valid_q` y el controlador

No cambia ninguna cifra, pero la pregunta pierde su sujeto: `ops_valid_q` ya no existe en la
configuración final (solo queda en el bloque `g_wait`, que se usa con `EarlyRead = 0`, es decir con la
estrategia 2 de memoria). La respuesta nueva: con la lectura anticipada los operandos están listos
siempre al empezar el ciclo, así que `rf_ready_o = 1` y el controlador detiene el pipeline solo cuando
la LSU espera un dato (la rama de espera de operandos queda sin usar), y carga el PC con el destino si
hay salto tomado, `jal` o `jalr`. Conviene aclarar que el parámetro deja el camino viejo disponible, y
que por eso `make check` y `make equiv` siguen cubriendo las dos temporizaciones. Dato:
`docs/pipeline.md`, sección 1; `rtl/espino_core/espino_id_stage.v`, bloques `g_early` (líneas 126 a
148) y `g_wait` (149 a 162).

### Pregunta 111 (línea 720): cómo se implementa x0

No cambia ninguna cifra y la respuesta sigue siendo correcta (x0 no se almacena, el banco tiene x1 a
x15, una escritura a x0 se ignora y una lectura de la dirección 0 entrega 0 por hardware). Hay que
agregar una frase: el write-through también excluye x0, porque la condición de adelanto se arma sobre
`wr = we_i & (waddr_i != 4'd0)`, así que una instrucción que escribe a x0 y otra que lee x0 en el
mismo flanco siguen viendo 0. Lo verifican las comprobaciones c42 a c45 de `sw/hazard_test.s`
(sección 6). Dato: `rtl/espino_core/espino_register_file.v`, líneas 62, 73, 74, 79 y 80;
`docs/pipeline.md`, sección 2 (riesgo 4).

### Pregunta 114 (línea 736): cómo se escriben bytes y medias palabras

No cambia ninguna cifra. La escritura sigue igual (`data_be` según el tipo y `addr[1:0]`, con el dato
replicado en las cuatro posiciones). La lectura sí cambia: la LSU ya no elige el byte o la media
palabra con `addr[1:0]` del ciclo, sino con la copia registrada de `addr_i[1:0]` que guardó al emitir
la carga (B2). Vale decirlo porque es la razón por la que la alineación salió de la ruta crítica y por
la que la LSU tiene dos flip-flops nuevos (pasa de 1 a 3). Dato:
`rtl/espino_core/espino_load_store_unit.v`; `asic/sintesis.md`, tabla de área por módulo
(`espino_load_store_unit`, 3 flip-flops locales), contra `git show v1-final:asic/sintesis.md`, línea 28
(1).

### Pregunta 115 (línea 742): qué pasa con una instrucción ilegal

No cambia ninguna cifra y los dos casos siguen siendo correctos (opcode desconocido que actúa como NOP,
opcode válido con `funct3` ilegal que mantiene las señales de ese opcode). Hay que agregar la
observación O3 de la revisión independiente: con la lectura anticipada el decodificador trabaja sobre
la instrucción siguiente y `illegal_insn_o` no se registra con el resto del decode, así que la señal
queda desfasada una instrucción. Hoy es inocuo porque el core no la usa y no hay trap, pero si alguien
agregara uno apuntaría a la instrucción equivocada; la corrección es registrarla con el resto del
decode. Estado: el RTL ya lo documenta (`rtl/espino_core/espino_id_stage.v`, líneas 94 a 102, commit
`84857f9`), pero la señal sigue sin registrarse. Dato: `docs/revision_frente_a.md`, O3.

### Pregunta 129 (línea 832): si cierra a 25 ns, por qué la corrida final es a 100 ns

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| período mínimo de la premisa | 25 ns | 21,5 ns | `asic/rom/resultados/f2_t21p5/cierre.md` |
| margen con que cierra la final | 65 ns | 65,7 ns | `asic/rom/resultados/final/cierre.md` |

El argumento no cambia: el enunciado fija T = 100 ns y 40 por ciento para la corrida final, y la
frecuencia máxima se reporta con el barrido.

### Pregunta 130 (línea 836): por qué la biblioteca de 7 tracks y 5 V

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| filas y sitios del core | 157 filas de 1.102 sitios | 159 filas de 1.116 sitios (177.444 sitios) | `asic/rom/resultados/final/metrics.json`, `design__rows` = 159 y `design__sites` = 177444 (v1: 157 y 173.014) |

Toda la explicación de la biblioteca (`mcu7t5v0`, esquinas de 4,5, 5,0 y 5,5 V, 7 pistas por 0,56 µm
igual a 3,92 µm de alto de fila) no cambia.

### Pregunta 131 (línea 843): el macro funcionaría si se fabrica

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| frecuencia que aguanta por timing | 40 MHz | 46,5 MHz | `asic/rom/resultados/f2_t21p5/cierre.md` |
| lo que respalda el "sí" | DRC, LVS y antenas limpios, timing en 9 esquinas, netlist simulado | igual, y ahora además con **equivalencia formal y simulación con SDF sobre el netlist nuevo**: el RTL y los dos netlists de la corrida final son equivalentes por el flujo clásico de Yosys (976 de 976 celdas `$equiv` contra el de síntesis y 968 de 968 contra el post-PnR) y la traza con retardos anotados es idéntica a la del RTL en tres esquinas, reproducible en nueve corridas | `asic/rom/resultados/final/cierre.md`; `docs/equivalencia.md`, sección 1; `asic/sim/resultado_sdf.md` |

Lo demás no cambia: faltan pads de I/O, anillo de sello, encapsulado y plan de pruebas, y con estas
constantes el reloj tiene que ser de 10 MHz exactos.

### Pregunta 132 (línea 850): qué harían con una semana más

No cambia ninguna cifra porque la respuesta es una lista de pendientes, pero de las **cinco** cosas que
lista (B2, B5, el slew, la simulación con SDF y la equivalencia formal) **cuatro ya están hechas** y la
quinta (B5) quedó descartada con una razón medida, así que hay que reescribirla entera.

| qué cita | valor viejo | valor nuevo | archivo de origen |
|---|---|---|---|
| integrar B2 (24 ns) | pendiente | **hecho**: B2 está en la corrida final (D23) | `docs/decisiones.md`, D23 |
| integrar B5 (-9 por ciento de área) | pendiente | **descartado con razón medida**: con este pipeline sube el período a 29 ns | `asic/exploraciones.md`, fila `exp/pipeline-b5`; `docs/pipeline.md`, sección 5.1 |
| cerrar las violaciones de slew sin pasar el 1 por ciento de área | pendiente | **hecho**, pero no con ese presupuesto: 0 violaciones al precio de 14,4 por ciento de área de celdas, con el die y el costo casi sin cambio (2,5 por ciento de die) | `asic/rom/resultados/final/metrics.json`; `docs/decisiones.md`, D23 |
| simulación con SDF reproducible | pendiente | **hecha con el netlist nuevo** (corrida `d2_pnr`, tres esquinas, Icarus 13.0 y CVC 7.00b, nueve trazas con un solo md5) | `asic/sim/resultado_sdf.md` |
| verificación formal de equivalencia | pendiente | **hecha con el netlist nuevo** (eqy 0.68 prueba 29 de 30 particiones; la prueba la cierra el flujo clásico de Yosys con 976 de 976 celdas `$equiv` contra la síntesis y 968 de 968 contra el post-PnR) | `docs/equivalencia.md` |

**Cómo queda la respuesta.** De la lista vieja no queda nada abierto: B2 entró, B5 se descartó con
medición, el slew quedó en 0 y la equivalencia formal y la simulación con SDF están hechas sobre el
netlist nuevo. Tampoco siguen abiertos los dos huecos que el mapa de la etapa 1 daba por pendientes:
la comparación de las dos estrategias de memoria con la configuración final ya se corrió (`s3_t100` y
`s4_t100`, en `docs/datos_informe.md` sección 3.2) y el aporte de B2 sobre este pipeline ya está
medido con el barrido `pr_*` (1 ns de período). Lo que queda, dicho con nombre y apellido:
registrar `illegal_insn_o` para que no quede desfasada (observación O3, hoy solo documentada en el
RTL); terminar el barrido de período de la estrategia 2 por debajo de 50 ns (`s4_t45` y `s4_t42` están
corriendo) y agregar el punto de 22,5 ns del barrido `pr_*`, que son los dos tramos de resolución que
faltan para cumplir la regla de los 0,5 ns; repetir la corrida de terminales automáticos con la
configuración nueva, que es el hueco real que queda en la sección 3.5; volver a correr
`asic/tablas.sh` para que `asic/final.md` incorpore los puntos nuevos y la sección de la estrategia 2;
cerrar la partición grande que eqy deja sin decidir, o dejar explicado por qué la prueba la da el
flujo clásico; y evaluar si el banco de latches vuelve a convenir con alguna variante del pipeline que
le devuelva la holgura que perdió.

## Preguntas cuya respuesta deja de ser válida aunque no citen números

Las agrupo por el supuesto que se rompe. Las que además cambian de cifra ya tienen su entrada arriba;
acá va el supuesto, porque es lo que hay que desaprender antes de la defensa.

**1. Que el banco de registros se lee registrado y nada más, sin camino de adelanto.** Preguntas 111
(x0) y 114 (bytes y medias palabras), más la 105 (valores X) y las 31, 32 y 33 (área y celdas del
banco). El banco sigue teniendo los dos puertos de lectura registrados, pero ahora la entrada de esos
registros puede venir del dato que se está escribiendo en el mismo flanco (write-through), y eso cuesta
316 muxes funcionales y 6.693 µm². Fuente: `rtl/espino_core/espino_register_file.v`, `asic/sintesis.md`.

**2. Que toda instrucción pasa un ciclo esperando la lectura del banco, y que `ops_valid_q` gobierna el
pipeline.** Preguntas 50, 54, 70, 107, 108, 109 y 110. Es el supuesto que estructura todas las
respuestas de ciclo a ciclo del banco, y el que hay que cambiar con más cuidado: `ops_valid_q` no
existe en la configuración final, `rf_ready_o` vale 1 siempre, el stall lo produce solo la LSU, y la
protección de los registros sin reset pasa a ser `instr_valid_i`. Fuente: `docs/pipeline.md`,
secciones 1 y 2.

**3. Que las violaciones de slew son un problema del diseño, con el que hay que vivir porque no es
criterio de cierre.** Preguntas 56, 58 y 59, más la 68 (que las usaba como mérito de B5) y la 55 (que
las presenta como logro parcial de D20). Eran un problema del modelo con que el flujo decidía dónde
poner buffers: con los RC medidos por capa quedan 0 en las nueve esquinas. Fuente:
`docs/modelo_cable.md`, `asic/rom/resultados/final/metrics.json`.

**4. Que ninguna exploración entró en la corrida final (D22).** Preguntas 65, 67 y 48, más la 132 y la
49. D23 adoptó el pipeline del frente A y B2, y la configuración del modelo de cable del frente C; la
referencia a D22 queda reemplazada por D23 en todas ellas, y la 67 conviene darla vuelta ("por qué sí
incorporaron B2"). Fuente: `docs/decisiones.md`, D23; `asic/exploraciones.md`.

**5. Que la equivalencia con el RTL anterior es ciclo a ciclo.** Preguntas 53 y 65. Ya no puede serlo,
porque los ciclos cambian a propósito: la equivalencia es funcional (misma secuencia de escrituras al
banco, de accesos al bus y de salidas), y para compensar la pérdida se agregaron dos programas de
riesgos de datos, cuatro mutaciones y el monitor de valores X. Fuente:
`docs/verificacion/integracion.md`.

**6. Que la verificación formal de equivalencia y la simulación con SDF están pendientes.** Preguntas
104, 106 y 132. Las dos están hechas, y sobre el netlist nuevo, no solo sobre v1. Lo que hay que
explicar es el matiz: eqy deja una partición sin decidir con el diseño nuevo y la prueba la da el
flujo clásico de Yosys. Fuente: `docs/equivalencia.md`, `asic/sim/resultado_sdf.md`.

**7. Que la ROM combinacional es solo la opción más barata de guardar el programa.** Preguntas 24, 26,
27 y 30. Pasa a ser condición del pipeline: la lectura del banco un ciclo antes se pide con su salida
combinacional, y por eso la estrategia 2 corre con la temporización vieja (`EarlyRead = 0`, CPI 2,665
contra 1,665). El matiz hay que decirlo bien: la memoria unificada en flip-flops también expone un
puerto `a_next_o`, así que estructuralmente podría anticipar, pero el mux de 119 palabras en el camino
la haría impracticable, y por eso `pochoco_soc` fija `EarlyRead = (MemStrategy == 1) ? 1 : 0`. Es un
argumento más a favor de D17. Fuente: `docs/pipeline.md`, sección 1 y su subsección de estrategia 2;
`docs/datos_informe.md`, sección 3.2, punto 1.

> **Nota de procedencia.** Todo lo anterior (el resumen por tema, las 81 preguntas afectadas y las
> respuestas que dejan de ser válidas) pasó por la misma revisión adversaria, que reabrió
> `docs/defensa.md` y cada archivo citado; sus correcciones están en el apéndice. Lo que sigue, las
> 15 preguntas nuevas, es la redacción original sin esa segunda pasada.

## Preguntas nuevas

Son 15, numeradas desde la 133. Cada respuesta está escrita para decirse en voz alta, con el archivo
de origen de cada cifra. Dónde conviene insertarlas: la 133, la 134 y la 136 a la 139 en la sección 9
(RTL del Espino Core y del SoC), antes y después de la pregunta 110; la 135 en la sección 3 (memoria),
después de la 27; la 140 a la 142 y la 144 en la sección 5 (timing), junto a la 68 y después de la 56;
la 143 en la sección 6 (floorplan y costo), después de la 78; la 145 al final de la sección 8; la 146
junto a la 66; y la 147 al final de la sección 12.

### 133. [B] Cómo es el pipeline del core en la corrida final

Una instrucción por ciclo, dos las cargas y dos los saltos tomados. La clave es que la ROM de la
estrategia 1 es **combinacional**: la instrucción de la dirección que pide el fetch (`pc_q`) ya está en
su salida un ciclo antes de cargarse en el registro de instrucción. Con esa salida (el puerto
`a_next_o` de la memoria) el core hace dos cosas por adelantado: le pide al banco de registros la
lectura de rs1 y rs2, y registra las 82 salidas del decodificador. Las dos ocurren en el mismo flanco
en que se carga la instrucción, así que al empezar el ciclo de ejecución los operandos y el decode ya
están listos y no hace falta el ciclo de espera que tenía la versión anterior. El CPI del juego baja de
2,665 a 1,665 (`docs/verificacion/integracion.md`, tabla de CPI: 1.595.814 ciclos y 958.358
instrucciones) y el período mínimo queda en 21,5 ns (`asic/rom/resultados/f2_t21p5/cierre.md`), así que
el rendimiento pasa de 15,3 a 27,9 MIPS (`docs/decisiones.md`, D23). Lo que **no** se hizo es volver
combinacional el banco de registros: eso era la exploración B4, que cerraba recién a 60 ns
(`asic/exploraciones.md`, fila `exp/cpi`). Dato: `docs/pipeline.md`, sección 1;
`rtl/espino_core/espino_id_stage.v`.

### 134. [B] Qué es el parámetro `EarlyRead` y para qué sirve

Es un parámetro del core que elige la temporización. Con `EarlyRead = 1` el core pide la lectura del
banco y registra el decode a partir de la instrucción combinacional (`instr_next_i`): una instrucción
por ciclo. Con `EarlyRead = 0` queda el bloque `g_wait` con `ops_valid_q`, que es exactamente la
temporización anterior: dos ciclos por instrucción con un ciclo de espera. El valor por omisión en
`pochoco_soc` depende de la memoria: 1 con la estrategia 1 y 0 con la estrategia 2. Sirve para tres
cosas. Primero, la estrategia 2 no puede anticipar sin pagar el período (pregunta 135) y necesita el
camino viejo. Segundo, con el parámetro las pruebas cubren las dos temporizaciones en la misma rama:
`make check` y `make equiv` corren las dos, y la estrategia 2 reproduce exactamente los números de v1
(CPI del juego 2,665 y 388.411 escrituras al banco, `docs/verificacion/integracion.md`). Tercero, es la
vuelta atrás más barata si algo saliera mal: se cambia un parámetro en `SYNTH_PARAMETERS`, no el RTL.
Dato: `docs/pipeline.md`, sección 1; `rtl/pochoco_soc.v`, `rtl/asic_top.v`.

### 135. [A] Por qué la estrategia 2 no puede anticipar la lectura

Por lo que cuesta la ruta, no porque falte la señal. La memoria en flip-flops también expone
`a_next_o`, que es el mux combinacional sobre las 119 palabras antes de registrarse, así que las dos
memorias tienen la misma interfaz y técnicamente se podría pasar `EarlyRead = 1` y funcionaría. El
problema es el período: la ruta pasaría del flip-flop del PC por un mux de 119 palabras de 32 bits, de
ahí a los campos rs1 y rs2 de la instrucción y de ahí a la dirección de lectura del banco, todo en un
ciclo. En la estrategia 1 ese mismo tramo es una ROM combinacional de 115 palabras que la síntesis
minimiza mucho (7.448 µm², unos 2 µm² por bit, `asic/sintesis.md`), mientras en la estrategia 2 es un
árbol de multiplexores sobre flip-flops. Y la estrategia 2 ya es la lenta sin anticipar nada: con el
RTL de v1 cerraba a 62 ns contra 55 ns de la estrategia 1 (`asic/barrido.md`), así que anticipar la
empeoraría. Por eso `pochoco_soc` instancia el core con `EarlyRead = 0` cuando `MemStrategy = 2`.
Dicho de otra forma: la ROM combinacional de la estrategia 1 deja de ser solo la opción más barata y
pasa a ser condición del pipeline, que es un argumento más a favor de D17. El período mínimo de la
estrategia 2 con el RTL nuevo y la configuración final es de **35 ns o menos** (barrido `s4_*`), o
sea 10,7 MIPS con su CPI de 2,665 contra los 27,9 de la estrategia 1. Dato: `docs/pipeline.md`,
sección 1, subsección de estrategia 2; `asic/final.md`, barrido `s4_*`.

### 136. [A] Qué riesgos de datos y de control aparecen con la lectura anticipada y cómo se resuelve cada uno

Son seis y cada uno tiene su prueba en `sw/hazard_test.s`, que tiene 56 comprobaciones.

1. **Escritura seguida de lectura del mismo registro.** En el mismo flanco se escribe `rd` de la
   instrucción i y se leen los operandos de i+1, y en ese flanco el arreglo todavía tiene el valor
   viejo. Lo resuelve el write-through: la salida registrada toma `wdata` si hay escritura, la
   dirección de lectura coincide con la de escritura y no es x0. A dos instrucciones de distancia el
   arreglo ya está actualizado. Prueba: secciones 1 y 2 de `hazard_test` (c01 a c10 más la dirección y
   el dato de un store).
2. **Carga seguida de uso.** Mientras la LSU está ocupada el banco no vuelve a leer
   (`rf_rd_en_o = ~stall_i`), así que la lectura de i+1 cae justo en el flanco del commit de la carga y
   el write-through le entrega el dato; de paso los operandos de la carga se conservan durante el
   stall, que es lo que la LSU necesita. Prueba: sección 3 (c14 a c33: lb, lbu, lh, lhu y lw con
   offsets 0 a 3, con y sin signo, desde la RAM y desde el periférico).
3. **`jal` o `jalr` seguido de uso del link.** `rd` se escribe en el commit del salto y la instrucción
   destino se carga un flanco después, tras la burbuja, cuando el arreglo ya tiene el valor. Prueba:
   sección 5 (c38 a c41).
4. **Escrituras a x0.** La condición de escritura y la de adelanto excluyen la dirección 0, y leer x0
   entrega 0 por hardware. Prueba: sección 6 (c42 a c45).
5. **Salto tomado.** La instrucción secuencial que ya se había pedido llega con `instr_valid_i = 0`:
   registra sus operandos y su decode sin efecto, porque `lsu_req_o`, `rf_we_o` (vía `commit`) y
   `pc_set_o` están condicionados a esa señal. Prueba: secciones 7 y 8 (los 12 saltos condicionales con
   la instrucción siguiente dependiente, y saltos encadenados).
6. **Reset.** `valid_q` arranca en 0 y durante el reset `pc_q` vale `BootAddr`, así que los registros
   sin reset se cargan con la primera instrucción en cada flanco y nada los lee antes. Lo confirma el
   monitor de valores desconocidos usados.

La comprobación de que esto no es solo un relato: la traza de `hazard_test` contra el RTL de v1 da
348 eventos de banco, 63 de bus y 2 de salida idénticos con las dos estrategias, y un revisor que no
escribió el código agregó 48 comprobaciones propias (`sw/hazard_review.s`, 271, 66 y 2 eventos
idénticos). Dato: `docs/pipeline.md`, sección 2; `docs/verificacion/integracion.md`, filas 4 y 5;
`rtl/espino_core/espino_register_file.v`.

### 137. [B] Qué es el write-through del banco de registros y por qué hace falta

Es un camino de adelanto dentro del banco. Los dos puertos de lectura son registrados: la salida es un
flip-flop que se carga con el valor del arreglo. El problema es que con la lectura anticipada la
escritura de una instrucción y la lectura de la siguiente caen en el **mismo flanco** de reloj, y en
ese flanco el arreglo todavía tiene el valor viejo. El write-through lo resuelve haciendo que la salida
registrada tome directamente `wdata` cuando hay escritura, la dirección de lectura coincide con la de
escritura y la dirección no es x0. Importante para no confundirlo: no es un camino combinacional de
lectura; la salida sigue siendo un flip-flop, lo único que cambia es que su entrada puede venir del
dato que se está escribiendo en vez del arreglo. Cuesta área: los `mux2_2` del banco pasan de 622 a 796
y el módulo de 73.656 a 80.349 µm², un 9,1 por ciento más, sin agregar ni un flip-flop. Dato:
`rtl/espino_core/espino_register_file.v`; `docs/pipeline.md`, sección 1; `asic/sintesis.md`, desglose de
`mux2_2` y tabla de área por módulo.

### 138. [A] Qué pasa si se quita el write-through

Se rompe el programa, y lo sabemos porque se probó. La prueba de mutación `MUTA_FWD` pone las dos
señales de adelanto en 0 (es decir, saca el write-through) detrás de un `ifdef` que solo se activa por
línea de comandos, y corre la comparación contra el RTL de v1. Resultado: las trazas difieren en el
evento 6 del banco, donde la referencia escribe `0000000f` y el mutante escribe `xxxxxxxx`; difieren
también en el primer evento de bus; y el monitor de valores desconocidos usados, que normalmente cuenta
0, cuenta **77** (36 en el dato de escritura al banco y 41 en operandos de la ALU). Con
`sw/hazard_review.s`, el programa del revisor, cuenta 63 y la primera diferencia es el evento 8. La
razón de los valores X es que el banco no tiene reset: si una instrucción lee un registro que la
anterior acaba de escribir y el adelanto no está, lo que sale del arreglo es el valor sin inicializar.
La mutación sirve para dos cosas: demuestra que el write-through es necesario y demuestra que las
pruebas lo detectarían si alguien lo borrara. Con la estrategia 2 (`EarlyRead = 0`) la mutación no
cambia nada, lo que confirma que ese camino no depende del adelanto. Dato:
`docs/verificacion/integracion.md`, filas 8 y 10 a 12; `docs/pipeline.md`, sección 3.4.

### 139. [A] Por qué el banco no vuelve a leer mientras la carga espera

Porque si leyera, leería demasiado pronto. Una carga dura dos ciclos: en el primero la LSU emite la
lectura y en el segundo llega el dato y se comete. Si el banco leyera los operandos de la instrucción
siguiente en el flanco intermedio, esa lectura ocurriría un flanco antes del commit de la carga y no se
repetiría en el flanco del commit, así que la instrucción siguiente no vería el dato cargado ni por el
arreglo ni por el write-through. Por eso la etapa ID le pasa al banco `rf_rd_en_o = ~stall_i`: mientras
hay stall los puertos de lectura no se cargan, conservan los operandos de la carga (que la ALU
necesita, porque sigue calculando la dirección) y la lectura de la instrucción siguiente cae
exactamente en el flanco del commit. Esto también se verificó por mutación: `MUTA_LOADUSE` cambia la
condición por el stall registrado y las trazas difieren en el evento 84 del banco (la referencia
escribe `00000002` y el mutante `00000795`), en el evento 24 del bus y en el primero de salida, con el
display mostrando otro patrón; con `hazard_review` el monitor cuenta 679 valores desconocidos usados.
Dato: `rtl/espino_core/espino_id_stage.v`, bloque `g_early`; `docs/pipeline.md`, secciones 2 (riesgo 2)
y 3.4; `docs/verificacion/integracion.md`, filas 9 y 12.

### 140. [A] Por qué el banco de latches de B5 deja de convenir con este pipeline

Porque el pipeline nuevo se come el medio ciclo del que vivía B5. B5 cambia los flip-flops del banco por
latches `latq_1` con una celda de clock gating por registro, y gana área (9,4 por ciento menos de
celdas estándar sobre v1) y slew, porque se ahorra el mux de retención por bit. El truco de
temporización es que un latch es transparente mientras el reloj está alto, así que un dato que llega
tarde toma prestado tiempo de la fase siguiente (3,38 ns en la medición). Con la temporización anterior
el camino que entraba a esos latches tenía holgura de sobra, porque el dato venía del ciclo de
ejecución. Con la lectura anticipada, el camino que entra al banco es el del PC por la ROM
combinacional y de ahí a la dirección de lectura, y ya no le queda ese colchón: sobre el pipeline nuevo
el período mínimo sube de 25,5 a 29 ns, aunque el área baje a 165.211 µm². Por la métrica principal eso
son 20,7 MIPS contra 23,6 de la variante que se adoptó (las dos sin el modelo de cable, para que la
comparación sea homogénea). Es un buen ejemplo de que dos optimizaciones que funcionan por separado
pueden pelearse entre sí. Hay dos cosas más que decir si se la presenta: su cierre se apoya en el
préstamo de tiempo, así que el WNS de setup que informa (0,000 exacto en las nueve esquinas) no mide
margen; y su banco de latches nunca pasó por una simulación con retardos anotados. Dato:
`asic/exploraciones.md`, filas `exp/rf-latch` y `exp/pipeline-b5`; `docs/pipeline.md`, sección 5.1;
`docs/revision_frente_a.md`, O2.
### 141. [B] Qué es el modelo de cable del resizer y por qué lo cambiaron

El resizer es el paso que arregla el timing cambiando tamaños de celdas y agregando buffers, y trabaja
**antes** de que existan los cables, así que tiene que estimar la resistencia y la capacidad de cada
net: supone que el net va más o menos en línea recta entre los pines, mide ese largo y lo multiplica
por una resistencia y una capacidad por micrómetro. Por omisión usa un solo par de valores, el promedio
de las capas de ruteo del tech LEF: 0,2752 ohm/µm y 64,3 aF/µm, el mismo par en las nueve esquinas. Esa
estimación es optimista por dos razones que se suman: el valor del tech LEF es la capacidad de un cable
solo contra el sustrato, sin los vecinos que en un chip real le agregan acoplamiento, y un cable de
verdad no va en línea recta ni vive en una sola capa (sube y baja por vías, que agregan resistencia).
Medido, el error es de 2,3 a 2,9 veces en capacidad (pregunta 142). Con parásitos de menos el resizer
**cree haber terminado antes de tiempo**: mira un net, calcula el slew con un cable tres veces más
liviano, le sale que cumple y no pone el buffer; la violación aparece recién en el STA final, que sí
usa los parásitos extraídos. Eso explica las 546 violaciones de max slew de v1. La variable `LAYERS_RC`
de LibreLane permite darle los valores capa por capa y esquina por esquina; la configuración final usa
el tech LEF escalado por los factores medidos y además activa la reparación de diseño y de timing
después del ruteo global, que sin `LAYERS_RC` no servían de nada. Resultado: el período mínimo baja de
24,5 a 21,5 ns y las violaciones de max slew pasan de 546 a 0 en las nueve esquinas. Dato:
`docs/modelo_cable.md`, secciones 1 a 3; `asic/modelo_cable.md`; `asic/rom/config.yaml`.

### 142. [A] Cómo midieron que el tech LEF era optimista

Comparando, net por net, lo que el flujo estima con lo que extrae. Después del ruteo detallado OpenRCX
escribe en archivos SPEF la resistencia y la capacidad de verdad de cada net, y el flujo también deja
el largo ruteado de cada uno. `asic/modelo_cable.py` toma esas dos cosas y hace una regresión lineal de
la capacidad de cable extraída contra el largo, sobre los **2.399 nets de más de 20 µm** de la corrida
(los más cortos se descartan porque en ellos manda la capacidad fija de las vías y los extremos, no la
pendiente, que es lo que se quiere medir). La pendiente de esa recta es la capacidad por micrómetro que
el ruteo real tiene: 188,4 aF/µm en la extracción max, 166,3 en la nom y 148,0 en la min, contra los
64,3 aF/µm que usa el resizer. Son factores de 2,93, 2,59 y 2,30; en resistencia, 2,18, 1,99 y 1,81.
Esos factores son los que escalan el tech LEF en el bloque `LAYERS_RC`, y el mismo script verifica que
lo que hay en la configuración es exactamente lo que se deriva de la corrida (termina con código
distinto de cero si no coincide). La prueba de que el diagnóstico era correcto es indirecta pero
fuerte: al darle al flujo los valores corregidos, las violaciones de slew del STA final desaparecen en
los dos RTL, el de v1 y el nuevo, lo que confirma que no eran un problema del diseño sino del modelo
con que el flujo decidía dónde poner buffers. Dato: `asic/modelo_cable.md`, secciones 1 a 3;
`docs/modelo_cable.md`, secciones 2 y 4.

### 143. [A] Si el área de celdas sube 14,4 por ciento, por qué se aceptó el cambio

Porque lo que sube es el área que **ocupan** las celdas dentro del die, no el die. El tamaño del die lo
fija `FP_CORE_UTIL = 40` por ciento sobre el área de la **síntesis**, que es anterior al resizer:
156.098 µm² divididos por 0,40 dan el core (389.525 µm² medidos) y de ahí sale un die de 419.131 µm².
Los buffers que el resizer agrega después llenan espacio que ya estaba reservado y vacío, así que el
die queda exactamente igual al de la misma candidata sin modelo de cable, y el costo estimado también:
0,419131 mm² por 23.000 dólares/mm² son 9.640 dólares. Lo que sube es la utilización real del core, de
47,9 a 53,5 por ciento, muy por debajo del 90,3 por ciento con el que todavía cierra la utilización
máxima medida en v1. En resumen: el chip que se fabrica y lo que cuesta son los mismos, y a cambio el
período mínimo baja de 24,5 a 21,5 ns, el rendimiento sube de 15,3 a 27,9 MIPS y las violaciones de
slew pasan de 546 a 0. Sobre el límite de 105 por ciento de área de celdas que antes descartaba esta
configuración: era una regla de selección que se fijó el grupo para la sesión, no un criterio del
enunciado (el enunciado pide cierre de timing, DRC, LVS y antenas, e informar área, frecuencia y
costo), y se levantó porque lo que el enunciado sí pide no empeora. Dato: `docs/decisiones.md`, D23,
nota sobre el límite de área; `asic/rom/resultados/final/metrics.json` y
`asic/rom/resultados/v1_final/metrics.json`.

### 144. [A] Qué es la violación de capacitancia que queda y por qué no se puede quitar sin costo

Es **un solo pin**, el mismo en las nueve esquinas: `clkbuf_0_clk/Z`, la raíz del árbol de reloj, un
`clkbuf_16` que insertó el CTS. Maneja 0,428234 pF contra un límite de 0,2 pF, es decir un slack de
-0,228234 pF en la esquina lenta (0,401561 pF y -0,201561 en la típica). Dos cosas hay que decir para
que se entienda por qué queda. Primero, el límite de 0,2 pF es `MAX_CAPACITANCE_CONSTRAINT`, una
restricción que LibreLane pone a todos los pines del diseño, no el límite de la celda: el liberty de la
esquina lenta permite 3,93 pF en ese pin, o sea que la celda maneja nueve veces menos de lo que puede.
Segundo, `repair_design` no toca la red de reloj, así que ni la reparación del placement ni la de
después del ruteo global pueden arreglarla, por diseño de la herramienta. Para quitarla habría que
intervenir el árbol de reloj a mano o pedirle al CTS más niveles de buffer, y eso cuesta area, potencia
de reloj y skew, a cambio de nada medible: no es criterio de cierre del enunciado y el pin cumple el
límite real de la celda con nueve veces de margen. En v1 eran 36 pines con violación de capacitancia y
ahora es 1, justo el único que la reparación no puede tocar. Dato:
`asic/rom/resultados/final/avisos.md`, aviso 4; `asic/rom/resultados/final/max_ss_125C_4v50_checks.rpt`,
sección `max capacitance`.

### 145. [B] Cómo verificaron que el cambio no altera el comportamiento

Con cinco cosas, en orden de fuerza, y todas con su salida guardada en `docs/verificacion/`.

1. `make check`: las 80 pruebas del assembler y los seis testbenches PASS, con las dos estrategias de
   memoria.
2. Equivalencia funcional contra v1 y contra el RTL de referencia histórico: la traza de
   `sw/isa_test.s` da las mismas 46 escrituras al banco, los mismos 22 accesos al bus y las mismas
   2 salidas, con las dos estrategias. Es funcional y no ciclo a ciclo porque los ciclos cambian a
   propósito: lo que tiene que ser idéntico son los efectos, no los instantes.
3. Un programa escrito para este cambio, `sw/hazard_test.s`, con 56 comprobaciones que cubren los seis
   riesgos de la pregunta 136: 348 eventos de banco, 63 de bus y 2 de salida iguales a los de v1. Y
   `sw/hazard_review.s`, 48 comprobaciones del revisor: 271, 66 y 2.
4. Cuatro pruebas de mutación que rompen a propósito el write-through y el enable de lectura, y que las
   pruebas detectan (preguntas 138 y 139). Sin esto no sabríamos si las pruebas son capaces de fallar;
   de hecho se descubrió que `isa_test` sola **no** detecta ninguna de las dos, y que lo que las caza
   son los programas de riesgos.
5. Un monitor que cuenta valores desconocidos **usados** en cada flanco (escrituras al banco, datos del
   bus, operandos de la ALU en un commit y salidas): 0 en 620.217 escrituras al banco del juego
   completo, y 77 cuando se activa la mutación, lo que demuestra que el monitor sirve.

Además, la simulación del netlist contra el RTL con el testbench de `main` da trazas idénticas
(17 cambios de salida, 0 valores X) y su control negativo falla como corresponde; y la equivalencia
formal con eqy, que prueba todas las entradas y no solo un escenario, está medida sobre los netlists
de v1 y corriendo sobre los nuevos. Encima, un revisor que no escribió el código reprodujo la
verificación completa, escribió sus propias comprobaciones y mutaciones, y verificó número por número
las tablas del frente. Dato: `docs/verificacion/integracion.md` (las 15 comprobaciones, todas en
verde); `docs/pipeline.md`, sección 3; `docs/revision_frente_a.md`.

### 146. [B] Por qué la frecuencia máxima sola no mide el rendimiento

Por la Ley de Hierro: tiempo de ejecución igual a instrucciones por CPI por período, o lo mismo dicho
al revés, MIPS igual a frecuencia dividida por CPI. Las tres cosas se mueven juntas y hay que mirar el
producto. En este proyecto se ven los cuatro casos:

| diseño | f máx (MHz) | CPI del juego | MIPS |
|---|---|---|---|
| v1 (`main` antes de integrar) | 40,8 | 2,665 | 15,3 |
| corrida final de D23 | 46,5 | 1,665 | **27,9** |
| B4 (todo en un ciclo) | 16,7 | 1,312 | 12,7 |
| B2 más B5 con reparación post-GRT | 43,0 | 2,665 | 16,1 |

B4 es el ejemplo de manual al revés: baja el CPI a la mitad, pero al juntar en un ciclo el PC, la ROM,
el decodificador, la lectura del banco, la ALU y el write-back el período sube 2,4 veces, más de lo que
baja el CPI, y rinde peor que v1. Y la fila de B2 más B5 muestra el otro extremo: es la más rápida en
frecuencia después de la final, pero con el CPI viejo da 16,1 MIPS, muy por debajo de los 27,9. La
corrida final gana porque mueve las dos variables en la dirección correcta a la vez: el CPI baja 37,5
por ciento porque desaparece el ciclo de espera, y el período baja porque B2 saca la alineación de la
carga de la ruta crítica y porque el resizer, con un modelo de cable realista, repara de verdad. Dato:
`asic/exploraciones.md`, tabla resumen; `docs/decisiones.md`, D23;
`asic/rom/resultados/f2_t21p5/cierre.md`; `docs/verificacion/integracion.md`, tabla de CPI.

### 147. [A] Qué quedó imperfecto en el cambio

Cuatro cosas, dichas sin maquillaje.

1. **`illegal_insn_o` queda desfasada una instrucción.** Con la lectura anticipada el decodificador
   trabaja sobre la instrucción siguiente y esa señal no se registra con el resto del decode, así que
   apunta a la instrucción equivocada. Hoy es inocuo porque el core no la usa (no hay trap en el
   diseño), pero si alguien agregara uno habría que registrarla. Lo encontró la revisión independiente
   (observación O3).
2. **Queda una violación de max capacitancia y 21 de fanout.** La de capacitancia es la raíz del árbol
   de reloj, que `repair_design` no toca (pregunta 144). En v1 eran 36 y 62, así que las dos mejoran,
   pero no quedan en cero.
3. **El margen de hold baja un poco.** La corrida final cierra con 0,173 ns en la peor esquina contra
   0,178 de v1: un 2,8 por ciento menos. Sigue cumpliendo, y de hecho el diseño nuevo no necesita
   ningún buffer de hold mientras v1 usaba cinco. Conviene corregir acá un número de
   `docs/propuesta_d23.md`, sección 9, que anticipaba 0,134 ns (25 por ciento menos): esa cifra era de
   la candidata sin el modelo de cable, y la corrida final mide 0,173 ns.
4. **La superficie que hay que defender es mayor:** un camino de datos nuevo (write-through), un
   parámetro de temporización (`EarlyRead`) y una configuración de flujo que corrige el modelo de cable
   del resizer. Son tres cosas más que explicar, y por eso se agregaron estas preguntas al banco.

A cambio, el rendimiento real en el programa del enunciado sube 82 por ciento (15,3 a 27,9 MIPS) y las
violaciones de max slew desaparecen. Dato: `docs/revision_frente_a.md`, O3; `docs/decisiones.md`, D23;
`asic/rom/resultados/final/metrics.json` y `cierre.md`; `docs/propuesta_d23.md`, sección 9.

## Lo que queda por medir, con la corrida o el comando de donde sale

| qué falta | de dónde sale | preguntas que dependen |
|---|---|---|
| el resto del barrido de período (23, 24, 25 y 30 ns) | corridas `f2_t23`, `f2_t24`, `f2_t25` y `f2_t30`; `f2_t22` ya terminó en disco con WNS 0,656 ns (`asic/rom/runs/f2_t22/final/metrics.json`) pero sus reportes no están versionados | 38, 39 |
| el barrido de utilización y los puntos finos del máximo que cierra | corridas `u2_u50` a `u2_u90` y `asic/graficos.py --util` | 72, 73, 74, 75, 80 |
| la comparación con terminales automáticos | repetir la corrida de `asic/rom/config_pines_auto.yaml` con el RTL nuevo | 76, 98 |
| el aporte de B2 sobre este pipeline | corridas `pr_*` de `exp/pipeline` sin B2 (worktree `build/exp_pipeline`) con la configuración final | 48, 67 |
| la estrategia 1 reproducida y la estrategia 2 con la configuración final | corridas `s3_t100` y `s4_*` (`asic/ff/config_final.yaml`) | 25, 26, 27, 78, 80, 135 |
| el efecto de quitar la pre-decodificación con la configuración nueva | repetir las corridas `r0_*` | 52 |
| la simulación post-PnR con SDF del netlist nuevo | corrida `d2_pnr` (flujo completo con la ROM de simulación) y `make post-pnr-sdf` / `make post-pnr-cvc` | 106, 131 |
| la potencia con actividad real del netlist nuevo | `bash asic/potencia/correr.sh` (regenera `asic/potencia/resultado.md`) | 84, 85, 81 |
| la equivalencia formal contra los netlists nuevos | `bash asic/eqy/correr.sh` (regenera `docs/equivalencia.md`) | 104, 131, 132 |
| las figuras de período y de utilización | `docs/figuras/periodo.png` y `utilizacion.png` (`asic/graficos.py`) | 38, 75 |
| el módulo al que pertenece el flip-flop de llegada de la ruta crítica del período mínimo | `bash asic/layout/anotar.sh asic/rom/runs/f2_t21p5` sobre el netlist jerárquico | 40 |
| el número y el paso de las franjas de la red de alimentación, y el rango completo de latencia del reloj | pasos `21-openroad-generatepdn` y `35-openroad-cts` de la corrida final, como se hizo para `docs/hechos_flujo.md` | 81, 86 |
| el desglose de la estimación de potencia sin actividad por fuente (pines CLK contra árbol de reloj) | `asic/potencia/resultados/` con el netlist nuevo | 85 |

---

# Cierre: lo que decía "por medir" y ya está medido

Las dos partes de arriba se redactaron mientras la cola de LibreLane todavía corría, así que dejaron
63 marcas de "por medir". **Casi todas ya tienen número**, y las que quedan están listadas al final
de esta sección. Donde el texto de arriba y esta tabla no coincidan, manda esta tabla; el detalle,
con el archivo de origen de cada cifra, está en `docs/datos_informe.md` y en `asic/final.md`.

| lo que faltaba | medido | dónde |
|---|---|---|
| Barrido de período completo | cierra a 100, 30, 25, 24, 23, 22 y 21,5 ns; no cierra a 21. **Período mínimo 21,5 ns (46,51 MHz), 27,9 MIPS**, con la regla de 0,5 ns cerrada | `asic/final.md`, barrido `f2_*`; `asic/rom/resultados/f2_t21p5/cierre.md` |
| Barrido de utilización completo | cierran 40, 50, 60, 70, 72 y 73 %; fallan 74, 75, 78, 80 y 90 %. **Máxima que cierra 73 %, die 235.237 µm² (0,235 mm²)**; la regla queda cerrada a 1 punto | `asic/final.md`, barrido `u2_*`; `asic/rom/resultados/u2_u7*/` |
| Estrategia 1 reproducida con otro tag | `s3_t100` da **exactamente** los mismos números que `final` (208.439 µm², 419.131 µm² de die, WNS 65,725 ns, 0 slew, 1 cap): el flujo es determinista con esta configuración | `asic/final.md`, sección de `s3_t100` |
| Estrategia 2 con el core y la configuración nuevos | `s4_t100`: síntesis 696.640 µm², PnR **977.015 µm²**, **4.673** flip-flops, die **1.801.610 µm² (1,802 mm²)**, utilización 0,562, cables 2.242.954 µm, **0 nets con violación de antena** (6 diodos), 62 slew y 14 cap, WNS 55,558 ns. CPI del juego **2,665** (`EarlyRead = 0`) | `asic/final.md`, sección de `s4_*`; `asic/ff/resultados/s4_t100/` |
| Costo de la estrategia 2 | 1,801610 mm² x 23.000 = **41.437 dólares**, 4,3 veces el de la estrategia 1 (9.640) | cálculo sobre `design__die__area` |
| La violación de antena de la estrategia 2 | **desaparece** con el core y la configuración nuevos: 0 nets contra 1 en las corridas `s2_*` de v1. Ojo con `e2_t100`, que es una corrida temprana con el RTL de v1 (`asic/ff/resultados/LEEME.md`) | `asic/ff/resultados/s4_t100/metrics.json` |
| Aporte de B2 con el flujo final | sin B2 el período mínimo es **22,5 ns** (44,4 MHz, 26,7 MIPS) y con B2 21,5: **B2 compra 1 ns**, es decir 1,2 MIPS. Al mismo período de 23 ns da 1,031 ns más de holgura y ocupa 1.690 µm² menos | `asic/final.md`, sección `pr_*`; `docs/datos_informe.md` 3.4 |
| Ruta crítica al período mínimo | identificada en los dos extremos y partida en tramos, con el cálculo del tiempo requerido | `asic/rutas.md`; `docs/datos_informe.md` 3.4 |
| Tabla de evolución del rendimiento | seis etapas, de 6,8 a 27,9 MIPS, con el reparto del aumento entre el RTL y el flujo | `asic/evolucion.md` |
| Simulación post-PnR con SDF | `d2_pnr` cierra; tres esquinas con Icarus y con CVC, 18 ejecuciones con un solo md5, 0 violaciones de timing y control positivo con 8 violaciones; y el netlist real a 320.000 ciclos con la misma traza que el RTL | `asic/sim/resultado_sdf.md` |
| Equivalencia formal | el flujo clásico prueba 976 de 976 celdas contra el netlist de síntesis y 968 de 968 contra el post-PnR; el miter desde reset pasa a 24 y a 100 pasos; eqy deja una partición sin decidir por el estado inicial libre | `docs/equivalencia.md` |
| Potencia con actividad real | 9,620 mW sin actividad y 13,936 a 16,615 mW con actividad en nom_tt, comparada contra v1 y contra la candidata | `asic/potencia/resultado.md` |
| Período mínimo de la estrategia 2 | cierra hasta **35 ns** (28,57 MHz, 10,7 MIPS con CPI 2,665), contra 62 ns con la configuración de v1. El punto de 30 ns **no se midió**: dos corridas cortadas por la regla de 40 minutos | `asic/final.md`, barrido `s4_*`; `asic/ff/resultados/s4_t35/cierre.md` y `s4_t30_b/falla.txt` |
| Figuras | `docs/figuras/periodo.png`, `utilizacion.png` y `construccion.gif` (14 cuadros, con los dos pasos nuevos) regeneradas con la corrida final; `bloques.png`, `ruta_critica.png` y `slew.png` también | `asic/tablas.sh`, `asic/layout/anotar.sh`, `make animacion` |

**Lo que sigue sin medirse, y hay que decirlo en el informe**: la potencia a la frecuencia máxima,
el experimento de sensibilidad al estado inicial de los flip-flops sin reset, la potencia de la
estrategia 2, y las dos mediciones de la sección 3.5 que no se repitieron con la configuración nueva
(el die de aspecto 1,6:1 y los terminales ubicados por el flujo, que siguen comparando contra v1).


---

# Apéndice: qué corrigió la revisión adversaria

Las dos partes de arriba se escribieron primero y se revisaron después, reabriendo cada archivo
citado. Esta es la lista de lo que la revisión cambió: sirve para auditarla y para no volver a citar
una cifra ya corregida. El alcance llega hasta donde lo dice cada "Nota de procedencia".

## Parte 1, el informe


Revisión adversaria hecha el 29-10-2026 contra los archivos del repositorio, reabriendo cada archivo
de origen y cada línea citada de `informe/main.tex`.

**Alcance: 187 cifras, nombres de archivo, números de línea y afirmaciones de estado revisados; 14
estaban mal.** Lo que se corrigió, en orden de gravedad:

1. **Tabla 1 `tab:cierre`**: decía "se rehace completa (4 de 6 filas cambian de cifra o de esquina)".
   Solo cambian **2 de las 6** filas (setup y hold). Las de DRC de Magic, DRC de KLayout, LVS y
   antenas están en 0 en las dos corridas y la peor esquina no cambia en ninguno de los dos casos
   (`asic/rom/resultados/final/cierre.md` y `v1_final/cierre.md`). Por arrastre se corrigió el conteo
   del encabezado: se rehacen completas **7** tablas, no 8.
2. **Tabla 3 `tab:estrategias`**: decía que `s3_t100` y `s4_t100` estaban "por medir, las dos
   encoladas". Las dos **ya corrieron** con código 0 el 28-10-2026 (`s3_t100` a las 21:55, `s4_t100`
   a las 22:12), más `s4_t65`, `s4_t60`, `s4_t55` y `s4_t50`, y están versionadas. Lo único por
   medir es el período mínimo de la estrategia 2 (`s4_t45`, `s4_t42` y `s4_t40`, encoladas el
   29-10-2026 a las 00:32).
3. **Tabla 11 `tab:util` y párrafo 8**: decían que faltaba `u2_u74` y que "está encolada
   (`asic/logs/cola_estado.txt`, entrada 154)". `u2_u74` **falló** con código 2 el 28-10-2026 a las
   21:50:40 en `OpenROAD.RepairDesignPostGRT` (paso 41) con 18 instancias sin lugar, y su
   `falla.txt` está versionado. Son **cinco** las corridas que fallan (74, 75, 78, 80 y 90 %), no
   cuatro, y la utilización máxima que cierra con la configuración nueva es **73 %** (die
   235.237 µm², 0,235 mm²), dato que el documento no decía en ninguna parte.
4. **Párrafo 12 (línea 439, SDF)**: decía "Lo que falta es la simulación con SDF sobre ese netlist
   ...: `asic/sim/resultado_sdf.md` todavía documenta `d1_pnr` y no menciona `d2_pnr`". Es falso:
   ese archivo documenta `d2_pnr` en tres esquinas con los dos simuladores, 18 ejecuciones con un
   solo md5 `5b6cebfb898a90a258b592fb29e64651`, **0 violaciones de timing** con 7.173 checks activos
   y control positivo, más una corrida de 320.000 ciclos sobre el netlist real de la corrida final.
5. **Párrafo 12, cifras de `d1_pnr`**: las cifras (cuatro esquinas, doce trazas, md5
   `4f14ec05462e4789a3d873d2ba50fd97`, 7.358 checks, 977 bloques TIMINGCHECK, 2.828 instancias
   renombradas) son correctas pero estaban citadas a `asic/sim/resultado_sdf.md`, que ya no las
   tiene. Están en el historial de git de ese archivo (commit `c7833b9`). Y el renombrado en el
   diseño nuevo es de **3.787** instancias y 20.939 referencias del SDF, no 2.828.
6. **Párrafo 6, "Ojo con la fuente"**: decía que la última sección de `asic/sintesis.md` "dice
   todavía lo contrario, 'La tabla anterior lo confirma; la novedad es que `nand2_1` queda casi a la
   par de `mux2_2`'", y que había que corregirla. Esa frase **no está** en el archivo:
   `asic/sintesis.md` se regeneró el 28-10-2026 a las 21:16 y dice "**No se cumplió**: la celda más
   usada es `nand2_1`, y el flip-flop queda tercero". El párrafo entero se reemplazó.
7. **Tabla 5 `tab:modulos`**: decía "cambian 3 áreas y los 10 porcentajes". Cambian 3 áreas de
   módulo **y el total** (157.980 a 164.605 µm²), y de los 10 porcentajes cambian **8**: la LSU
   queda en 1,7 % y la fila de bus, sincronizador y control no cambia ni en área (1.470 µm²) ni en
   porcentaje (0,9 %).
8. **Tabla 6 `tab:barrido`**: decía "Las ocho corridas `f2_*`". Son **siete** corridas `f2_*` más la
   corrida `final` a 100 ns (ocho puntos). Y "las 10 columnas" no cambian todas: cambian las 6 de
   WNS y la de área; las 4 de TNS siguen en 0 salvo la fila que no cierra.
9. **Párrafo 10, encabezado**: decía "Líneas 350 y 371". El 1.546 aparece **solo en la línea 350**;
   la 371 es sobre el DRC de Magic y el deck de KLayout. El segundo lugar donde se usa es
   `docs/datos_informe.md` sección 3.6, que no es el informe. La frase "el informe usa el 1.546 en
   dos lugares" se reescribió.
10. **Párrafo 9**: decía "Las cuatro cifras de slew". Son **tres** (546, 378 y 392). Y "sube con la
    utilización en vez de bajar" se precisó: la serie 0, 8, 0, 20, 92, 99 no baja y sube con fuerza
    desde 70 %, pero no es monótona.
11. **Párrafo 7**: decía que `_1838_` "viene de `lsu_addr[31]` invertido". `_1838_` es la salida de
    un `nor2_4` (`_3825_`, línea 27823) entre `net194` y `_0384_`; el que es `lsu_addr[31]`
    invertido es `_0384_` (`clkinv_16 _2014_`, línea 21097). Se agregó la cadena completa.
12. **Párrafo 5**: decía que B5 "le quita 3,5 ns al período". Se lo **cuesta**: `exp/pipeline-b5`
    cierra a 29 ns y `exp/pipeline-b2` a 25,5 ns. Y el ahorro de área de B5 se dejó anclado a sus
    dos cifras (165.211 contra 186.432 µm²).
13. **Tabla 13 `tab:sim`**: decía "cambian los 4 ciclos de estímulo". Cambian **3 de los 4**: el
    primero (300 a 360) es igual en `asic/sim/estimulos.txt`. Los 5 ciclos de resultado sí cambian
    los cinco, pero el que en el `.tex` es 426 no sale de `asic/sim/resultado.md`: sale de
    `asic/sim/resultado_sdf.md` sección 2.2 (display 01 en el ciclo **404**). Se corrigió además la
    cita de `docs/verificacion/b2_make_post_synth.txt`, que es de la rama `exp/pipeline-b2`: para el
    diseño integrado el archivo es `docs/verificacion/integracion_13_post_synth.txt`.
14. **Párrafo 4**: decía que las 15 comprobaciones de la integración "todas dan verde". Dos no dan
    verde por diseño: la 6 difiere a propósito en las escrituras al banco y la 14 es un control
    negativo que tiene que fallar la comparación. Se reescribió como "todas dieron el resultado que
    se les pedía".

**Lo que se agregó porque faltaba** (no es corrección de un error, pero sin esto el documento deja
cifras sin archivo de origen o párrafos sin marcar): la línea 197 como decimotercer párrafo cuyo
argumento cambia; las cuatro cifras del control negativo de la línea 439 (51, 8, 59 y el lazo de
8 ciclos) y la ambigüedad entre 16 cambios y 17 líneas de traza; la corrección de "D1 a D22" a
"D1 a D23" en la línea 40; el aviso de que `asic/final.md` quedó atrasado a las 20:57 del 28-10 y no
sirve como fuente de las filas nuevas de `f2_t30` ni del barrido `u2_*`; el matiz de `tab:antena`
con su cifra (0 nets en violación con el core nuevo, `s4_t100`); la serie completa de DRC por
iteración de cada corrida `u2_*`; la serie de la brecha de utilización punto por punto; y el aviso
de que los nombres de instancia de dos netlists distintos no se pueden mezclar.

**Lo que se verificó y estaba bien** (lista no exhaustiva de los bloques más densos): las 4 columnas
de `hechos_nuevos.md` contra `metrics.json` de `final`, `v1_final`, `f2_t21p5` y `f2_t21`; las ocho
áreas y los ocho conteos de celdas del barrido de período; las seis filas del barrido de utilización
nuevo (die, utilización real, WNS, hold, cables, slew y capacitancia) y las siete de v1; las tres
series de DRC por iteración de v1, de `final` y de `f2_t21p5`; los números de línea 199, 201 y 203
de `final/sintesis_stat.rpt`, 120 y 152 de `v1_final/sintesis_stat.rpt`, 425 y 461 de
`h2_t100/sintesis_jerarquica.rpt` y 428 de `h3_t100/sintesis_jerarquica.rpt` (el 265 de `h3_t100`
está en la 462 y el documento no lo decía, se agregó); las trece cantidades del desglose de
`nand2_1` y su total de 785; los cuatro valores del modelo de cable del tech LEF y los seis de la
extracción, con sus seis factores; las cuatro líneas del netlist de `f2_t21p5` (28693, 28751, 28905
y 29924) con el texto exacto de las instancias; las dos envolventes y las dos áreas de
`bloques.txt`, con el `design__core__bbox`; los diez números de equivalencia y mutación de
`integracion.md`; las cuatro líneas de `pochoco_rom.v`; los cinco sellos de tiempo de figuras; y las
líneas 188, 197, 221, 223, 227, 246, 250, 269, 289, 323, 350, 411 y 439 de `informe/main.tex`, que
contienen de verdad las frases que este documento les atribuye.

**Dos notas de procedencia.** (1) Este documento es, línea por línea, el bloque de las líneas 32 a
404 de `docs/cambios_informe.md` del repositorio, así que los 14 errores de arriba también están
ahí y conviene arreglarlos en ese archivo cuando se lo toque. (2) El repositorio está vivo mientras
se lo revisa: `u2_u74/falla.txt` apareció entre dos lecturas de este mismo trabajo y `pr_t22p5` se
lanzó el 29-10 a las 00:32, así que cualquier afirmación de "por medir" hay que volver a
comprobarla contra `asic/logs/cola_estado.txt` antes de escribirla en el informe.


## Parte 2, la defensa


Revisé una por una las **250 filas de datos** de las tablas de este documento (cada una con su valor
viejo, su valor nuevo y su archivo de origen) y las **cifras del texto corrido** de las 81 entradas,
abriendo en cada caso el archivo citado: los `metrics.json`, `cierre.md`, `avisos.md`,
`sintesis_stat.rpt`, `layout/*.txt` y `falla.txt` de `asic/rom/resultados/`, los `runtime.txt`,
`flow.log`, `power.rpt`, `cts.rpt` y logs de OpenROAD de `asic/rom/runs/`, `asic/final.md`,
`asic/sintesis.md`, `asic/rutas.md`, `asic/barrido.md`, `asic/exploraciones.md`, `asic/modelo_cable.md`,
`asic/ff/resultados/`, `asic/potencia/resultado*.md`, `asic/sim/{resultado.md,resultado_sdf.md,estimulos.txt}`,
`asic/eqy/resultados/`, `docs/{decisiones.md,datos_informe.md,hechos_flujo.md,pipeline.md,modelo_cable.md,equivalencia.md,equivalencia_v1.md,revision_frente_a.md}`,
`docs/verificacion/integracion.md`, el RTL (`rtl/espino_core/*.v`, `rtl/pochoco_mem_rom.v`,
`rtl/gen/pochoco_rom.v`, `rtl/debounce.v`, `rtl/asic_top.v`), `sw/hazard_*.s` y, para cada valor
"viejo", la línea exacta de `docs/defensa.md`. También comprobé los **81 números de línea** de
`docs/defensa.md`: los 81 son correctos. No hay ningún carácter de raya larga en el documento y todo
el texto está en español.

**Encontré 29 errores y los corregí.** Ocho son cifras o estados presentados como pendientes que ya
están medidos, cinco son cifras equivocadas, nueve son archivos o líneas de origen mal citados y siete
son conteos o afirmaciones de alcance que no se sostienen:

Cosas dadas por medir que ya están medidas (el documento se escribió antes de que terminaran esas
corridas):

1. **Resumen por tema, pregunta 25, 26, 27, 78 y 80**: la comparación de las dos estrategias de
   memoria con el RTL y la configuración nuevos no está "por medir": está en
   `docs/datos_informe.md` sección 3.2, con `s3_t100` (que reproduce la final exactamente,
   `asic/rom/runs/s3_t100/final/metrics.json`) y `s4_t100` (`asic/ff/resultados/s4_t100/`). Agregué
   las cifras: síntesis 696.640 µm², PnR 977.015 µm², 4.673 flip-flops, 43.960 celdas, die
   1.801.610 µm², 2.242.954 µm de cable, 62/14 de slew/cap, setup WNS 55,558 ns, CPI 2,665.
2. **Pregunta 26**: el costo por bit extra de la estrategia 2 pasa de "por medir" a 146,8 µm²/bit
   ((696.640 - 156.098) / 3.681) y la diferencia con la ROM a unas 73 veces.
3. **Pregunta 27 y 80**: el die de la estrategia 2 ya no es una hipótesis ("4,3 veces si no
   cambiara") sino una medición: 1.801.610 / 419.131 = 4,3 veces.
4. **Pregunta 78**: el costo de la estrategia 2 con la configuración nueva es 41.437 dólares, no
   "por medir".
5. **Pregunta 48, 67 y 132**: el barrido de período de `pr_*` (sin B2) ya está medido:
   `pr_t24` 1,556 y `pr_t23` 0,463 cierran, `pr_t22` -0,597, `pr_t21p5` -0,938 y `pr_t21` -1,634 no.
   Sin B2 el mínimo que cierra es 22,5 ns, así que **B2 vale 1 ns de período** sobre este pipeline.
   Lo único que falta de ese barrido es el punto de 22,5 ns.
6. **Pregunta 40 y 96**: el flip-flop de llegada de la ruta crítica del período mínimo ya está
   identificado: `asic/rutas.md`, líneas 17 a 25, resuelve `_4440_` en el netlist como
   `u_soc.u_periph.digit_q[4]`, el bit 4 del registro del display del periférico.
7. **Pregunta 72, 74 y 75**: la afirmación "entre 73 y 75 por ciento no hay punto medido, así que el
   máximo que cierra está acotado entre esos dos valores" es falsa: `u2_u74` existe, está seguido por
   git y **falla** en el paso 41 con 18 instancias sin sitio
   (`asic/rom/resultados/u2_u74/falla.txt`). El máximo que cierra es 73 y la primera que falla es
   **74**, no 75.
8. **Pregunta 91 y 93**: la violación de antena de la estrategia 2 sí desaparece con el core y la
   configuración nuevos (`s4_t100`: 0 nets y 6 diodos), así que el mapa de la etapa 1 acertaba en la
   conclusión y erraba solo en la cita. El documento decía que "ese dato no reproduce y no hay que
   usarlo", que es demasiado: lo que no reproduce es el `e2_t100` de `main`.

Cifras equivocadas:

9. **Pregunta 73**: "19,8 puntos (72 a 91,7)" está mal; `u2_u72` tiene utilización real 0,9166, o sea
   **19,7 puntos** sobre el 72 pedido.
10. **Pregunta 47**: "igual en los siete puntos: 100, 30, 25, 24, 23, 22, 21,5 y 21 ns" enumera
    **ocho** puntos (la final más los siete del barrido).
11. **Intro**: "los nueve del de utilización están seguidos por git" son **diez**
    (`git ls-files asic/rom/resultados/` lista también `u2_u74`).
12. **Pregunta 132**: "de las cuatro cosas que lista tres ya están hechas y la cuarta (B5) quedó
    descartada" no cuadra con la respuesta, que lista **cinco** cosas (B2, B5, el slew, la SDF y la
    equivalencia formal): cuatro están hechas y B5 se descartó.
13. **Pregunta 104, 131 y 132**: "976 de 976 celdas `$equiv`" vale para el netlist de síntesis; contra
    el post-PnR el flujo clásico da **968** (5 + 963). Decir "los dos netlists ... 976 de 976" es
    inexacto.

Archivos o líneas de origen mal citados:

14. **Pregunta 8**: el ruteo detallado de v1 no es `v1_final_run/46-openroad-detailedrouting` (esa
    carpeta no existe en v1, que tiene 76 pasos) sino **`44-openroad-detailedrouting`**
    (00:00:22.864).
15. **Pregunta 35**: el aviso estaba al revés. `asic/sintesis.md` línea 129 **no** dice que `nand2_1`
    "queda casi a la par de `mux2_2`": dice "**No se cumplió**: la celda más usada es `nand2_1`, y el
    flip-flop queda tercero". La frase vieja está en **`docs/defensa.md`, línea 250**, la respuesta de
    la propia pregunta 35.
16. **Pregunta 74**: las dos líneas citadas ("Error: repair_design_postgrt.tcl, 48 DPL-0036" y
    "Classic - Stage 41 - Repair Design (Post-Global Routing)") **no están** en
    `u2_u75/falla.txt`, cuyo extracto termina en la lista de instancias; están en
    `asic/logs/u2_u75.log`, líneas 18737 y 18738, y en `asic/rom/resultados/u2_u74/falla.txt`,
    líneas 26 y 27.
17. **Pregunta 74**: el conteo de 22 instancias de `u1_u80` no está en su `falla.txt` (el extracto
    empieza después de esa línea) sino en `asic/logs/u1_u80.log`, línea 17914.
18. **Pregunta 63 y 71**: `DebounceDivBits = 15` **no está** en `rtl/debounce.v` (ahí el parámetro se
    llama `DivBits`, línea 17); está en `rtl/asic_top.v` línea 24, `rtl/pochoco_soc.v` línea 20 y
    `rtl/pochoco_periph.v` línea 13.
19. **Pregunta 108**: `wire advance = ~stall_i;` está en la línea **122** de
    `rtl/espino_core/espino_id_stage.v`, no en la 123 (la 123 es `wire dec_load;`).
20. **Pregunta 55**: `docs/decisiones.md` D20 (línea 147) dice "de 2201 a **541**", no a 546; el 546
    es el de la corrida final de v1 (`v1_final/metrics.json`), que es el que cita la pregunta.
    Separé las dos fuentes.
21. **Pregunta 104**: el miter desde reset contra el netlist de síntesis pasa a 24 **y a 100** pasos
    (`asic/eqy/resultados/sint_v1/bmc_100_resumen.txt`, "DONE (PASS, rc=0)"), no solo a 24.
22. **Pregunta 51**: agregué la línea exacta del desglose de los 19,1 de 55,1 ns
    (`docs/decisiones.md`, línea 129), que el documento daba solo como "D18".

Conteos y afirmaciones de alcance que no se sostienen:

23. **Intro**: "incorporen f2_t30 y los puntos u2_u60 a u2_u73, que todavía figuran como
    'incompleta'". En `asic/final.md` solo `f2_t30` (línea 31), `u2_u60` (53) y `u2_u70` (54) figuran
    como "incompleta"; `u2_u72`, `u2_u73`, `u2_u74` y los puntos que fallan **no figuran en ninguna
    fila**, y falta además la sección de la estrategia 2 que `asic/ff/resultados/LEEME.md` ya
    anuncia.
24. **Pregunta 25**: el período mínimo de la estrategia 2 no es un "por medir" a secas. El barrido
    `s4_*` terminó: cierra a 100, 65, 60, 55, 50, 45, 42, 40 y **35 ns** (3,066 ns de margen en
    max_ss), contra los 62 ns que daba con la configuración de v1. El punto de 30 ns no se midió
    porque las dos corridas que lo intentaron las cortó la regla de 40 minutos de la cola en el
    paso 44 de 78, así que 35 ns es el menor medido y no necesariamente el mínimo.
25. **Pregunta 31**: "total de celdas de la corrida final: 5.577 celdas de 36 tipos" es ambiguo.
    `asic/sintesis.md` ahora lo dice explícitamente: son las celdas que **salen de Yosys**, no las del
    layout, que llega a 9.928 (`design__instance__count__stdcell`).
26. **Pregunta 24 y supuesto 7**: "por eso la estrategia 2 no puede hacer lo mismo" es más fuerte de
    lo que dicen los archivos. `docs/datos_informe.md` sección 3.2 punto 1 aclara que
    `pochoco_mem_ff` también expone `a_next_o` y que lo impracticable es el mux de 119 palabras en el
    camino; por eso `pochoco_soc` fija `EarlyRead = (MemStrategy == 1) ? 1 : 0`.
27. **Pregunta 38**: "40 MHz (en `main` ya estaba corregida a 40,8 MHz)" se lee como si `docs/defensa.md`
    ya tuviera la corrección. No la tiene: su línea 271 sigue diciendo 40 MHz; la cifra corregida está
    en `asic/final.md` (sección "Historia") y en D23.
28. **Pregunta 76**: agregué la frase con la que `asic/final.md` lo dice ("No se repitió con la
    configuración nueva") y las cifras de `u1_auto` (182.204 µm², WNS 65,213 contra 65,223), para que
    el "por medir" tenga su archivo.
29. **Pregunta 93**: agregué la fila que faltaba para cerrar el tema: con la configuración final la
    estrategia 2 ya no necesita ni los diodos heurísticos ni las perillas de antena, porque `s4_t100`
    cierra con 0 nets y 6 diodos y `asic/ff/config_final.yaml` no define `GRT_ANTENNA_REPAIR_*`.

Lo que **no** encontré mal, y conviene dejar dicho porque es lo que más revisé: los 81 números de
línea de `docs/defensa.md`; todas las cifras de place and route de la corrida final, de `f2_t21p5` y
de `f2_t21` contra `hechos_nuevos.md` y contra los `metrics.json`; los siete WNS del barrido de
período y las siete áreas; las cinco utilizaciones que cierran y sus die y utilización real; los
desgloses de celdas de `asic/sintesis.md` (934 / 889 / 779 / 437 / 348 y los cuatro desgloses por
módulo); los tramos y los cálculos de tiempo requerido de `asic/rutas.md` (2,673 / 1,830 / 4,267 /
9,048 / 4,417 / 22,235 y 21,5 + 2,385 + 0,116 - 0,25 - 0,640 = 23,111); las cifras de potencia con
actividad real; las de la equivalencia formal y la simulación con SDF; y todos los valores "viejos",
que están en la línea de `docs/defensa.md` que el documento indica.
