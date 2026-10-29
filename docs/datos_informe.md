# Datos para el informe, por sección del enunciado

Cada sección lista los números, tablas y figuras que la responden, con la corrida de
origen de cada dato. No es el informe: es el índice de dónde está cada cosa. Las
corridas están en `asic/<config>/runs/<tag>` (no versionadas) y sus reportes en
`asic/<config>/resultados/<tag>/` (versionados, con `metrics.json`). Las tablas de
barridos las genera `asic/recolectar.py` y los gráficos `asic/graficos.py`.

**La corrida final es la de D23** (28-10-2026): el RTL del pipeline con lectura del banco
de registros y decodificación en el fetch (parámetro `EarlyRead`), banco write-through y
el offset de byte de la carga registrado en la LSU (B2), más la configuración del modelo
de cable del resizer (`LAYERS_RC` con los RC medidos) y la reparación después del ruteo
global. Dos consecuencias que valen para todo el documento:

- **"v1" quiere decir `main` antes de integrar**, marcado con el tag `v1-final`. Sus
  reportes están en `asic/rom/resultados/v1_final/` (con un `LEEME.md` que lista cada
  cifra y su clave) y su corrida en disco en `asic/rom/runs/v1_final_run/`. Donde este
  documento compara contra v1, el valor viejo sale de ahí y no de `resultados/final/`,
  que es la corrida nueva.
- **Los pasos del flujo cambiaron de número**: la configuración agrega
  `OpenROAD.RepairDesignPostGRT` (41) y `OpenROAD.ResizerTimingPostGRT` (44), así que
  todo lo posterior se corre dos lugares. El STA final pasa de `55-openroad-stapostpnr` a
  `57-openroad-stapostpnr`, el segundo chequeo de antenas de 46 a 48, el informe de caída
  de tensión de 56 a 58, `magic-writelef` de 60 a 62 y el chequeo de antenas del LEF de 61
  a 63. Los scripts del repositorio buscan los pasos por nombre y no por número
  (`asic/recolectar.py`, `asic/final.sh`, `asic/modelo_cable.py`, `asic/layout/anotar.py`).

## 2. Corrida final y reproducibilidad

- Corrida final: tag `final`, `asic/rom/config.yaml` (estrategia 1, D17; D15, D20, D21 y
  D23), T = 100 ns, FP_CORE_UTIL = 40 %. Comando: `make final` (`asic/final.sh`), o
  `librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag final`.
  `SYNTH_PARAMETERS` es `MemStrategy=1`, `DataWords=4` y `EarlyRead=1`; la configuración
  trae además `LAYERS_RC` (15 pares de capa y extracción) y las cuatro variables de la
  reparación post-GRT (`RUN_POST_GRT_DESIGN_REPAIR`, `GRT_DESIGN_REPAIR_MAX_SLEW_PCT = 30`,
  `GRT_DESIGN_REPAIR_MAX_CAP_PCT = 30`, `RUN_POST_GRT_RESIZER_TIMING`).
- Criterios de cierre (`asic/rom/resultados/final/cierre.md`, `asic/verificar_cierre.py`):
  DRC de Magic 0, LVS 0, antena 0 nets, setup WNS **65,725 ns** y TNS 0 en las 9 esquinas,
  hold WNS **0,173 ns** en la peor esquina (`min_ff_n40C_5v50` y `nom_ff_n40C_5v50`
  empatan; en `max_ss_125C_4v50` el hold es 1,065 ns) y TNS 0 en todas. Además DRC de
  KLayout 0 marcadores en 684 reglas
  (`asic/rom/resultados/final/drc_klayout/resumen.md`, deck en `asic/drc/`), con su
  control positivo: el deck marca las dos violaciones de Metal1 inyectadas, en sus
  coordenadas (`drc_klayout/control_positivo.md`).
  Para comparar, v1: setup 65,223 ns y hold 0,178 ns (`resultados/v1_final/cierre.md`).
- Versiones (`asic/versiones.md`, `asic/versiones.sh`): LibreLane 3.0.16, imagen
  `ghcr.io/librelane/librelane:3.0.16`, PDK gf180mcuD revisión
  `54435919abffb937387ec956209f9cf5fd2dfbee`, biblioteca `gf180mcu_fd_sc_mcu7t5v0`,
  Yosys 0.62, OpenROAD dcf36133, Magic 8.3.623, KLayout 0.30.7, Netgen 1.5.316,
  Icarus 13.0 (imagen) y 14.0 (oss-cad-suite, simulaciones). No cambian con D23.
- Instalación y regeneración del programa: README (`make image`, assembler propio).
- Datos de la corrida final (`asic/rom/resultados/final/metrics.json`), con el valor de v1
  entre paréntesis (`resultados/v1_final/metrics.json`):
  die 638,505 x 656,425 µm = **419.131 µm² (0,419 mm²)** (630,6 x 648,52 µm = 408.957 µm²);
  core **389.525 µm²** en 159 filas de 1.116 sitios (379.800 µm², 157 filas de 1.102;
  `13-openroad-floorplan`, mensajes IFP-0001 e IFP-0102); área de celdas estándar
  **208.439 µm²** (182.265); utilización real **53,5 %** (48,0 %); **9.928** celdas
  estándar (8.670) y **964** flip-flops (990); largo de cables **377.509 µm** (352.253) y
  cable más largo 1.713,94 µm (1.409,36); **0** violaciones de max slew (546), **1** de max
  capacitancia (36) y **21** de max fanout (62); potencia estimada **9,620 mW** a 10 MHz en
  nom_tt (8,971 mW; `power.rpt` de esa esquina: interna 7,555 mW, conmutación 2,062 mW,
  fuga 0,002 mW; los 12,100 mW de `power__total` en `metrics.json` son de max_ff, la última
  esquina que procesa el flujo, contra 11,280 mW en v1).
- Costo a 23.000 dólares por mm²: 0,419131 mm² x 23.000 = **9.640 dólares** (v1: 9.406).
- Que el die no cambie respecto de la candidata sin modelo de cable es el argumento de D23
  para levantar el límite de área de celdas de la sesión: los 419.131 µm² son los mismos de
  `build/exp_candidata/asic/rom/runs/pa_b2_t100/final/metrics.json`, porque el die lo fija
  `FP_CORE_UTIL = 40` sobre el área de la síntesis y las celdas que agrega el resizer caben
  dentro. Lo único que sube es la utilización real del core.

## 3.1. Construcciones dependientes de la FPGA

- `asic/p2_original/evidencia.md` y `asic/p2_original/evidencia/` (corridas c0a, c0b,
  c0c): SB_RAM40_4K (error MODMISSING del linter), `por_cnt` con valor inicial
  (PROCASSINIT), `$readmemh` en `initial`, inferencia de la RAM de 512 palabras en
  flip-flops (17.188 flip-flops, 2.327.825 µm² en c0b), polaridad de 7 segmentos,
  constantes de tiempo y debounce. Decisiones D3 a D10.

## 3.2. Estrategias de memoria

- Tabla comparativa: `asic/barrido.md`, sección "Comparación de estrategias (sección
  3.2)", corridas s1_t100 y s2_t100 (configuración D15, mismo RTL):
  área de celdas de síntesis 146.400 contra 693.901 µm²; flip-flops 921 contra 4.602;
  área tras PnR 173.568 contra 838.173 µm²; die 393.525 contra 1.794.180 µm²;
  período mínimo 55 contra 62 ns; antenas 0 contra 1 net.
- Con la configuración final (D20, D21) la estrategia 1 pasa a 182.265 µm² de celdas y
  408.957 µm² de die (corrida `final`); la estrategia 2 no se repitió con D20/D21.
- Costo a US$23.000/mm²: estrategia 1 (final) 0,409 mm² -> US$9.406; estrategia 2
  (s2_t100) 1,794 mm² -> US$41.266 (4,4 veces). Ver 3.5.
- Antena de la estrategia 2: ver 3.6.
- ROM generada por el assembler: `rtl/gen/pochoco_rom.v` (`make image`, D11);
  memoria unificada: `rtl/pochoco_mem_ff.v` con `rtl/gen/game_image.vh`.

## 3.3. Síntesis

`LAYERS_RC` y la reparación post-GRT solo actúan en el place and route, así que toda esta
sección depende únicamente del RTL nuevo: las cifras de síntesis de la corrida final son
las mismas que daría la candidata sin modelo de cable.

- `asic/sintesis.md` (generado por `asic/analisis_sintesis.py` desde `final` y
  `h3_t100`): área por módulo con porcentaje, las cinco celdas más usadas con su
  desglose por módulo y la verificación contra el RTL, fracción del contador de ciclos.
- Área de celdas de la síntesis: **156.098,48 µm²** aplanada (v1: 152.169,07) y
  **164.604,88 µm²** jerárquica (v1: 157.980), 5,2 % menos al aplanar porque la
  optimización cruza los bordes de módulo
  (`asic/rom/resultados/{final,h3_t100}/` y `resultados/v1_final/sintesis_stat.rpt`).
- Cinco celdas más usadas (corrida final, **5.577 celdas de 36 tipos**; v1: 5.118 de 34):
  **nand2_1 934 (16,7 %), mux2_2 889 (15,9 %), dffq_1 779 (14,0 %), aoi21_1 437 (7,8 %),
  oai21_1 348 (6,2 %)**. En v1 el orden era dffq_1 804 (15,7 %), mux2_2 759 (14,8 %),
  nand2_1 758 (14,8 %), oai21_1 309 (6,0 %) y clkinv_1 284 (5,5 %): **el flip-flop deja de
  ser la celda más numerosa** y `clkinv_1` sale de las cinco primeras.
- Desglose de `dffq_1`: 544 del banco de registros (480 bits de almacenamiento + 64 de las
  dos salidas registradas), 192 de la memoria (registro de instrucción, RAM de 4 palabras,
  salida de datos), 82 del decode registrado y **2 nuevos en la LSU** (el offset de byte de
  la carga registrado al emitirla, que es B2). El RTL tiene 820 bits de registro sin reset
  y 185 con reset (1.005); la síntesis jerárquica da 820 + 185 y la aplanada 779 + 185 =
  **964 flip-flops** (v1: 990). La aplanada elimina 41 flip-flops al propagar constantes a
  través de los bordes de módulo.
- Desglose de `mux2_2` en la síntesis jerárquica: 796 del banco de registros, 160 de la
  memoria y 117 de la etapa ID (1.139 en total). Los del banco suben de 622 a 796 porque al
  mux de retención de cada bit se le suman el mux del write-through y el enable de lectura;
  a cambio sus `mux4_1` bajan de 128 a 66, así que parte del árbol de lectura se remapeó
  (`sintesis_jerarquica.json` de `h2_t100` y de `h3_t100`, clave `num_cells_by_type` del
  módulo). Los 117 de la etapa ID (116 en v1) son los 82 de retención del decode, que ahora
  cargan solo si el pipeline avanza, más los muxes de operandos, de write-back y de
  `pc_target`.
- Módulo con más área: `espino_register_file` (`u_soc.u_core.u_rf`), **80.349 µm², 48,8 %**
  de la síntesis jerárquica y 51,5 % de la aplanada (v1: 73.656 µm², 46,6 % y 48,4 %).
- Contador de ciclos: 3.943 µm², **2,40 %** (jerárquica) y **2,53 %** (final); 32 dffrnq_1,
  que son el 61 % de su área (2.388 de 3.943 µm²). No cambia en valor absoluto: baja de
  porcentaje porque el diseño creció.
- Área del resto de los módulos en la síntesis jerárquica (`asic/sintesis.md`):
  `espino_id_stage` con ALU y decodificador 29.589 µm² (18,0 %), `espino_alu` 10.153
  (6,2 %), `pochoco_mem_rom` con la ROM 27.458 (16,7 %), `pochoco_rom` 7.448 (4,5 %),
  `pochoco_periph` con debounce y contador 14.409 (8,8 %), `espino_if_stage` 8.511 (5,2 %),
  `espino_load_store_unit` **2.819** (1,7 %; sube desde 2.711 por el registro del offset de
  byte), `espino_decoder` 1.965 (1,2 %), y el bus, el sincronizador de reset y el control
  1.470 µm² (0,9 %).
- Método: `SYNTH_KEEP_HIERARCHY_MODULES` en la corrida final y síntesis aparte con
  `SYNTH_HIERARCHY_MODE=keep` (**h3_t100**, `asic/rom/resultados/h3_t100/sintesis_jerarquica.rpt`).
- Reportes: `asic/rom/resultados/final/sintesis_stat.rpt` y `sintesis_stat.json`.

## 3.4. Timing y frecuencia máxima

### Barrido de período y período mínimo

- Barrido de `CLOCK_PERIOD` con la configuración final (corridas `final` y `f2_*`): tabla en
  `asic/final.md` (sección del barrido) y gráfico `docs/figuras/periodo.png`.
- **Período mínimo 21,5 ns, frecuencia máxima 46,5 MHz** (1 / 21,5 ns = 46,51 MHz). La
  corrida `f2_t21p5` cierra todo (`asic/rom/resultados/f2_t21p5/cierre.md`: WNS de setup
  0,876 ns y TNS 0 en `max_ss_125C_4v50`, hold 0,173 ns en la peor esquina, DRC de Magic,
  LVS y antenas en 0) y `f2_t21` no cierra por 0,129 ns (TNS -0,291 ns,
  `asic/rom/resultados/f2_t21/cierre.md`). Con eso **la regla de la sesión de dejar 0,5 ns o
  menos entre el último período que cierra y el primero que no queda cerrada**.
  En v1 eran 24,5 ns y 40,8 MHz (`f1_t24p5` cierra con 0,496 ns, `f1_t24` no por 0,004 ns).
- **MIPS (Ley de Hierro) 27,9** = 46,51 MHz / 1,665 de CPI del juego. En v1 eran 15,3
  (40,82 / 2,665). El CPI del juego completo lo imprime `game_tb` en `make check`:
  1.595.814 ciclos / 958.358 instrucciones retiradas = **1,665** con la estrategia 1, y
  1.599.759 / 600.218 = 2,665 con la estrategia 2, que es el valor de v1
  (`docs/verificacion/integracion_01_make_check.txt`). El CPI de `isa_test.s` lo imprime
  `core_trace_tb` en `make equiv`: 3.000 / 1.524 = **1,969** (v1: 2,953;
  `docs/verificacion/integracion_03_equiv_isa_v1.txt`).
- **El área sigue creciendo en cada período, y el WNS ya no es lineal.** En v1 las corridas
  de 26 a 24 ns daban exactamente el mismo layout (8.708 celdas, 189.817 µm² y 354.897 µm de
  cables), porque con el margen de 10 ns de D20 el resizer llegaba a su límite y de ahí para
  abajo solo cambiaba el slack, 1 ns de WNS por cada ns de período. Con los parásitos medidos
  eso se cae: el resizer sigue encontrando qué reparar en cada período, así que cada corrida
  tiene su propio layout y su propia área, y el WNS sube y baja. Medido
  (`metrics.json` de cada `f2_*`): área de celdas 208.439 µm² a 100 ns, 224.767 a 22 ns,
  231.229 a 21,5 ns y 231.638 a 21 ns; celdas estándar 9.928 a 100 ns y 9.946 a 21,5 ns;
  cables 377.509 µm a 100 ns y 386.712 a 21,5 ns; WNS en `max_ss` 0,656 ns a 22 ns y
  0,876 ns a 21,5 ns, es decir **mejor a 21,5 que a 22**.
- **Las 0 violaciones de max slew no valen en todo el barrido.** A 100 ns, a 22 ns y a
  21,5 ns son 0 (`design__max_slew_violation__count` de cada `metrics.json`), y a 21 ns son
  6. La violación de max capacitancia es 1 en todas las corridas y es siempre el mismo pin
  (ver 3.6).

### Comparación diseño contra diseño con la misma configuración

Es la comparación que D23 usa como argumento y no existía en v1: el RTL de v1 corrido con la
misma configuración del modelo de cable (worktree `build/main_rc`, tags `co_rcm_*`,
reportes en `asic/main_rc/resultados/`) cierra a **22 ns** (45,5 MHz; a 21,5 ns no cierra por
0,383 ns) y el RTL nuevo a **21,5 ns**. A 23 ns el diseño nuevo cierra con el doble de margen
(1,494 contra 0,756 ns en `max_ss`). Con el CPI de cada uno, 17,1 contra 27,9 MIPS. O sea que
el medio nanosegundo de ventaja es del diseño, y los 3 ns que separan a v1 de la corrida final
se reparten entre el flujo y el RTL (ver la tabla de evolución más abajo). `co_rcm_t100`:
201.309 µm² de celdas, WNS 65,276 ns, 2 violaciones de slew y 1 de capacitancia.

### Ruta crítica

Las dos rutas están partidas en tramos, con el cálculo del tiempo requerido, en
`asic/rutas.md` (generado por `bash asic/rutas.sh`, que llama a `asic/ruta_tramos.py` sobre el
`report_checks` de cada corrida). Las figuras anotadas están en
`asic/rom/resultados/<tag>/layout/ruta_critica.png` y la numeración de celdas en
`ruta_critica.txt` (`asic/layout/anotar.sh`).

**A 100 ns (corrida `final`): es la ruta que crea la lectura anticipada.** Empieza en `_4287_`
(`dffrnq_1`, el bit 2 del PC: su salida es `u_soc.g_mem_rom.u_mem.a_addr_i[2]`, módulo
`espino_if_stage`, función **fetch**), pasa por 13 celdas aplanadas que son la ROM
combinacional hasta `u_soc.g_mem_rom.u_mem.a_next_o[17]`, que es el bit 17 de la instrucción,
o sea `rs1[2]`, y de ahí por 19 celdas dentro de `u_soc.u_core.u_rf` (la decodificación de la
dirección de lectura y el árbol de lectura de 15 a 1) hasta terminar en
`u_soc.u_core.u_rf/_4123_` (`dffq_1`, cuya salida es `rdata_a_o[25]`, módulo
`espino_register_file`, función **lectura de operandos**). Son **34 celdas numeradas más 3
buffers del camino de reloj** (`asic/rom/resultados/final/layout/ruta_critica.txt`). Tramos:
árbol de reloj 2,647 ns, reloj a Q 1,877 ns, lógica aplanada (ROM) 12,355 ns, banco de
registros 19,154 ns; llegada del dato 36,033 ns, tiempo requerido 101,758 ns (100 + 2,412 de
latencia del reloj de captura - 0,250 de incertidumbre + 0,115 de CRPR - 0,519 de setup) y
slack 65,725 ns.

**Al período mínimo (`f2_t21p5`, 21,5 ns): es otra ruta, y no pasa por el banco de
registros.** Empieza en `_4136_` (`dffq_4`, salida `u_soc.u_core.u_id.alu_op_a_sel[2]`: uno de
los 82 registros del decode, módulo `espino_id_stage`, función **decode**), pasa por 9 celdas
aplanadas que son el mux del operando A hasta `u_soc.u_core.u_id.operand_a[26]`, por 18 celdas
dentro de `u_soc.u_core.u_id.u_alu` (función **ejecución**) hasta `u_soc.u_core.lsu_addr[31]`,
y por 10 celdas aplanadas más que son la decodificación de dirección del bus (función **acceso
a memoria**), para terminar en `_4440_` (`dffrnq_1`, salida `u_soc.u_periph.digit_q[4]`: el bit
4 del registro del display, módulo `pochoco_periph`, función **escritura del periférico**). Son
**39 celdas numeradas más 3 buffers del camino de reloj**
(`asic/rom/resultados/f2_t21p5/layout/ruta_critica.txt`). Tramos: árbol de reloj 2,673 ns,
reloj a Q 1,830 ns, mux del operando 4,267 ns, ALU 9,048 ns, dirección del bus y periférico
4,417 ns; llegada del dato 22,235 ns, tiempo requerido 23,111 ns (21,5 + 2,385 - 0,250 + 0,116
- 0,640) y slack 0,876 ns.

Lectura de las dos: a 100 ns la ruta larga es la del fetch al banco, porque con 10 ns de margen
el resizer no necesita atacarla; al período mínimo esa ruta ya está reparada y la que manda es
la de siempre, decode a ALU a bus. La ruta del store al display aparece porque el programa
escribe el display con un `sw` cuya dirección la calcula la ALU. En v1 la ruta del período
mínimo iba del registro de pre-decodificación `_4191_` (`alu_op_a_sel[2]`) por la ALU y la
alineación de la LSU al banco de registros (`_4309_`), 25 celdas, con llegada 36,485 ns a 100 ns
(`asic/rom/resultados/v1_final/max_ss_125C_4v50_ruta_critica.rpt`).

### Cambio de RTL: de la pre-decodificación al pipeline

- La pre-decodificación de D18 sigue en el diseño: lo que cambia es **cuándo** se registra el
  decode. Con `EarlyRead = 1` el decodificador trabaja sobre la instrucción que viene de la ROM
  (`instr_next_i`) y sus 82 salidas se registran en el mismo flanco en que se carga la
  instrucción, así que desaparece el ciclo de espera (`ops_valid_q` del bloque `g_wait`, que con
  `EarlyRead = 1` no se genera: por eso el id_stage pasa de 82 + 1 a 82 + 0 flip-flops).
  Detalle del RTL y de su verificación: `docs/pipeline.md` y `docs/verificacion/integracion.md`.
- Medición histórica del efecto de D18, que no cambia porque son corridas del RTL anterior:
  `r0_t100` y `r0_t26` (RTL del commit `116fa20` con la configuración de v1, worktree
  `build/ref116`): a 100 ns WNS 54,552 contra 65,223 ns de v1 y área 174.529 contra 182.265 µm²;
  `r0_t26` **no cierra** (WNS -3,175 ns, TNS -1.223,744 ns, 181.326 µm²). Tabla en
  `asic/final.md`, sección "RTL sin pre-decodificación".

### Tabla de evolución del rendimiento

Una fila por etapa del proyecto, con el período mínimo, la frecuencia máxima, el CPI del juego
completo, los MIPS, el área de celdas a 100 ns y las violaciones de slew y de capacitancia a
100 ns. Está en `asic/evolucion.md` (generada por `python3 asic/evolucion.py`), con el archivo de
origen de cada fila, y separa cuánto del aumento de MIPS viene del RTL (del CPI) y cuánto del
flujo (del período).

### Constantes del juego

- Constantes de `game.s` para T = 100 ns: D10 (`CLK_HZ = 10000000`,
  `CYCLES_PER_TENTH = 1000000`). **No cambian**: el período de la corrida final del enunciado
  sigue siendo 100 ns, así que `rtl/gen/pochoco_rom.v` y la ROM son las mismas.

### Otras exploraciones de RTL

Las ramas `exp/*` (`asic/exploraciones.md`, tabla generada por `asic/tabla_sesion.py` sobre
`asic/ramas_sesion.json`) miden otros cambios con la configuración de v1. **A (pipeline) y B2
ya están dentro de la corrida final**, así que dejan de ser exploraciones; siguen siéndolo B3
(comparador de saltos dedicado: no mueve el período), B4 (ejecutar en un ciclo: CPI 1,312 pero
período mínimo 60 ns, 12,7 MIPS) y B5 (banco de latches con clock gating: 165.211 µm² a 100 ns,
pero con la lectura anticipada el período mínimo sube a 29 ns y rinde 20,7 MIPS). La referencia
de comparación de esa tabla es v1 y está rotulada como tal.

## 3.5. Floorplan, utilización y costo

- Barrido de FP_CORE_UTIL a 100 ns (corridas `final` = 40, `u1_u50`, `u1_u60`,
  `u1_u70`, `u1_u72`, `u1_u75`, `u1_u78`, `u1_u79`, `u1_u80`, `u1_u90`; las de 72, 75, 78 y
  79 % son del 27-10-2026): tabla en `asic/final.md`, gráfico
  `docs/figuras/utilizacion.png` (DRC de ruteo por iteración, largo de cables global y
  detallado, slew, capacitancia, antena, área del die, WNS).
  Resultados: 50 % cierra (die 329.861 µm², utilización real 59 %), 60 % cierra
  (276.917 µm², 70 %), 70 % cierra (238.967 µm², 81 %; el ruteo detallado parte con
  2.149 violaciones de DRC y las resuelve), 72 % cierra (232.629 µm², 83 %; WNS 65,7 ns),
  75 % cierra (223.753 µm², 87 %; WNS 65,8 ns), 78 % cierra (215.545 µm², 90 %; WNS
  59,6 ns, hold 0,182 ns; cables 425.175 µm contra 318.333 a 70 %, +34 %; slew 880 y
  capacitancia 49 contra 392 y 27), 79 % falla en CTS (`[DPL-0036] Detailed placement
  failed`: al legalizar después de insertar los buffers del árbol de reloj quedan 6
  instancias del banco de registros sin lugar; log `asic/logs/u1_u79.log`; die 452,6 x
  470,5 µm y utilización 87,5 % según el placement global, GPL-0019), 80 % falla en el
  mismo paso y con el mismo mensaje (22 instancias; log `asic/logs/u1_u80.log`), 90 % falla en el placement global
  (`[GPL-0301] Utilization 100.531 % exceeds 100%`, `asic/logs/u1_u90.log`). Los logs
  no se versionan (`asic/logs/` está en .gitignore); el extracto de cada falla está en
  `asic/rom/resultados/u1_u79/falla.txt`, `asic/rom/resultados/u1_u80/falla.txt` y
  `asic/rom/resultados/u1_u90/falla.txt`. Cada corrida que cierra tiene su `cierre.md` en
  `asic/rom/resultados/<tag>/` y sus números salen de `metrics.json` (`design__die__area`,
  `design__die__bbox`, `design__instance__utilization`, `timing__setup__ws__corner:max_ss_125C_4v50`,
  `route__wirelength`, `design__max_slew_violation__count`, `design__max_cap_violation__count`).
  Área mínima que cumple los criterios: u1_u78 (78 %), die 455,4 x 473,3 µm = 215.545 µm²
  (0,216 mm²; `design__die__bbox` 0 0 455.395 473.315), 47,3 % menos que la final (408.957
  µm²) y 9,8 % menos que u1_u70 (238.967 µm²), con DRC, LVS y antenas limpios, WNS de setup
  59,6 ns y hold 0,182 ns en la peor esquina (`asic/rom/resultados/u1_u78/cierre.md`). La
  utilización máxima que cierra es 78 %: 79 % ya falla. A 78 % cambia la ruta crítica: la
  de la ALU al banco de registros queda con 60,5 ns de slack y la peor pasa a ser la salida
  `seg2[2]` del display (startpoint `_4486_`, `u_soc.u_periph.digit_q[1]`, slack 59,6 ns
  contra 69,2 ns a 75 % y 70,5 ns en la final): el flip-flop sale con un slew de 4,13 ns
  sobre 0,148 pF y el decodificador de 7 segmentos sigue con slews de 2,7 a 3,5 ns
  (`asic/rom/resultados/u1_u78/max_ss_125C_4v50_ruta_critica.rpt`), lo mismo que muestra el
  salto de slew a 880 pines. Las violaciones de slew bajan
  con la utilización hasta 70 % (546, 438, 378, 392) porque los cables se acortan, se
  mantienen a 72 y 75 % (388, 424) y suben a 78 % (880): con el core casi lleno el
  placement ya no puede acercar las celdas y el largo de cables vuelve a crecer.
- Relación de aspecto del die (corrida `d4_die`, `asic/rom/config_die.yaml`, 27-10-2026;
  tabla "Floorplan con DIE_AREA absoluto" en `asic/final.md`,
  `asic/rom/resultados/d4_die/cierre.md`, `metrics.json` y `layout/bloques.png`): mismo
  diseño y configuración que la final, pero con `FP_SIZING: absolute` y
  `DIE_AREA: [0, 0, 808.64, 505.68]`, un die de 1,6:1 con la misma área (408.913 contra
  408.957 µm², 0,011 % menos). `CORE_AREA` no es obligatoria: `floorplan.tcl` de LibreLane
  la calcula restando los márgenes de siempre (12 sitios = 6,72 µm a los lados, 4 filas =
  15,68 µm arriba y abajo) cuando no se define, y el die se eligió para que el core sea
  entero en sitios y filas: 1420 x 121 (795,20 x 474,32 µm, 377.179 µm²) contra 1102 x 157
  (617,12 x 615,44 µm, 379.800 µm²) en la final (`13-openroad-floorplan/openroad-floorplan.log`
  de cada corrida, IFP-0001 e IFP-0102). `FP_CORE_UTIL` ya no dimensiona el die pero sigue
  fijando la densidad objetivo del placement (53,5 % contra 53,3 %). Cierra con los mismos
  criterios. Efecto medido contra la final (`metrics.json` de cada una): cables 364.879
  contra 352.253 µm (+3,6 %; ruteo global 509.586 contra 494.524 µm), cable más largo 975
  contra 1.409 µm (`route__wirelength__max`), WNS de setup 61,672 contra 65,223 ns en max_ss
  (3,6 ns menos; hold 0,156 contra 0,178 ns), slew 567 contra 546 pines, capacitancia 33
  contra 36, DRC del ruteo detallado por iteración 1.302, 279, 271, 0 contra 1.546, 501,
  379, 0, celdas estándar 8.590 contra 8.670 (96 contra 110 buffers de reloj), área de
  celdas 180.939 contra 182.265 µm² (-0,7 %) y potencia sin actividad 8,69 contra 8,97 mW
  en nom_tt (`power.rpt` de `55-openroad-stapostpnr`). Ruta crítica
  (`asic/rom/resultados/d4_die/layout/ruta_critica.txt`): de `_4191_` (`alu_op_a_sel[2]`,
  etapa ID) por el mux del operando A, la ALU hasta `lsu_addr[0]`, la alineación de la
  carga y `rf_wdata[23]` hasta `u_soc.u_core.u_rf/_2625_`, 30 celdas (la de la final a
  100 ns va de `_4191_` a `_4309_`). Lectura: en el die alargado el banco de registros se
  extiende a lo ancho del core (envolvente de x = 7,8 a 800,8 µm, `bloques.txt`, contra
  22,4 a 455,3 µm en la final) y el total de cables crece 3,6 %, aunque el cable más largo
  se acorta; el timing a 100 ns empeora 3,6 ns y ningún criterio cambia. No se corrió a
  24,5 ns, así que no se sabe si el aspecto mueve el período mínimo.
- Terminales (D21, `asic/rom/pines.cfg`): oeste entradas (btn[3:0], clk al centro,
  rst_n), este displays (seg1[6:0], seg2[6:0]), norte led[3:0], sur SPI. Son
  rectángulos de metal en el borde del macro (Metal3 en oeste y este, Metal2 en norte y
  sur), no pads: un chip completo los conectaría a pads de I/O con protección ESD y
  buffers de salida. Figura: `asic/rom/resultados/final/layout/bloques.png`.
  Efecto contra la ubicación automática (corrida `u1_auto`, `asic/rom/config_pines_auto.yaml`,
  tabla en `asic/final.md`, figura `asic/rom/resultados/u1_auto/layout/bloques.png`): el flujo
  pone clk en la esquina noroeste, los cuatro pines SPI amontonados en la esquina suroeste,
  rst_n y btn[3:0] juntos en el sur, y los 14 segmentos y los 4 LEDs intercalados en el este
  (seg1[5] junto a seg1[1], led[2] junto a led[0]). Contra D21 ahorra 0,4 % de largo de cables
  (350.998 contra 352.253 µm; ruteo global 492.382 contra 494.524 µm), el cable más largo
  pasa de 1.409 a 1.193 µm, el ruteo detallado parte con 6 violaciones en vez de 1.546
  (las dos terminan en 0), el timing es el mismo (WNS 65,21 contra 65,22 ns en max_ss) y
  las violaciones de slew y capacitancia cambian poco (569/31 contra 546/36). Es decir, D21
  cuesta casi nada en el macro y ordena los terminales para los pads.
- Costo a US$23.000/mm²: final 0,409 mm² -> US$9.406; u1_u70 0,239 mm² -> US$5.496
  (42 % menos); mínima (u1_u78) 0,216 mm² -> US$4.958 (47 % menos que la final; 0,215545 x
  23.000); d4_die 0,409 mm² -> US$9.405 (misma área que la final); estrategia 2 (s2_t100)
  1,794 mm² -> US$41.266.
  Limitaciones del modelo lineal: el costo real de un prototipo se paga por lote
  (multi-project wafer) con un mínimo de área, el macro no incluye pads, anillo de
  sello ni empaque, el precio por mm² baja con el volumen, y una utilización alta
  ahorra área pero cuesta cierre (79 % ya no coloca). Decisión de mayor impacto en
  área y costo: la estrategia de memoria (D17): 4,4 veces en área y costo; después
  la utilización (40 a 78 %: 0,409 a 0,216 mm², 47 %; 40 a 70 %: 42 %).

## 3.6. Signoff y layout

- DRC de Magic 0, LVS 0, antena 0 nets (`asic/rom/resultados/final/cierre.md`). Segundo
  DRC con el deck de KLayout de GlobalFoundries: **0 marcadores en 684 reglas**
  (`drc_klayout/resumen.md`), con su **control positivo**: el deck marca las dos
  violaciones de Metal1 inyectadas (ancho mínimo M1.1 y espaciado mínimo M1.2a) en sus
  coordenadas exactas (`drc_klayout/control_positivo.md`). Por qué el flujo salta su propio
  paso de KLayout: `asic/drc/ORIGEN.md`.
- **Las violaciones de max slew pasan de 546 a 0** y las de max capacitancia de 36 a 1
  (`design__max_slew_violation__count` y `__max_cap_violation__count` de
  `resultados/{v1_final,final}/metrics.json`; el detalle por pin, en
  `max_ss_125C_4v50_checks.rpt`). Es el efecto del modelo de cable: el resizer ve el cable
  que después se extrae y repara de verdad (`docs/modelo_cable.md`). El `slew.txt` de la
  corrida nueva dice "0 pines en 0 celdas" y su histograma queda en cero en los cinco
  tramos.
- **La violación de max capacitancia que queda: el pin, la causa y si se puede quitar sin
  costo.** Es un solo pin, el mismo en las nueve esquinas: **`clkbuf_0_clk/Z`, la raíz del
  árbol de reloj**, un `clkbuf_16` que insertó `OpenROAD.CTS` por `CTS_ROOT_BUFFER`. Maneja
  0,428234 pF contra un límite de 0,2 pF, o sea un slack de -0,228234 pF en
  `max_ss_125C_4v50` (0,401561 pF y -0,201561 en `nom_tt_025C_5v00`;
  `asic/rom/resultados/final/{max_ss_125C_4v50,nom_tt_025C_5v00}_checks.rpt`, sección
  `max capacitance`). Tres cosas hay que decir de ella:
  1. **El límite de 0,2 pF no es de la celda, es del flujo**: es
     `MAX_CAPACITANCE_CONSTRAINT = 0.2` de `resolved.json`, que LibreLane aplica con
     `set_max_capacitance` a todos los pines del diseño. El límite propio del `clkbuf_16` en
     el liberty de la esquina lenta es **3,93 pF** para su pin Z
     (`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__ss_125C_4v50.lib`,
     celda `clkbuf_16`, `pin(Z)`, `max_capacitance`): la celda maneja nueve veces menos de lo
     que puede. Y la transición que produce son 0,798408 ns
     (`max_ss_125C_4v50_ruta_critica.rpt`, línea del pin), dentro de los 3 ns de
     `MAX_TRANSITION_CONSTRAINT`, que es por lo que no aparece como violación de slew.
  2. **`repair_design` no toca la red de reloj**, así que ni el repair del placement ni el
     post-GRT la pueden arreglar: el flujo la ve y la deja.
  3. **No se puede quitar sin costo.** Las tres salidas posibles cuestan algo: (a) un buffer
     de raíz más grande no sirve, porque lo que sobra es la carga, no el drive, y además el
     `clkbuf_16` ya está muy por debajo de su propio límite; el PDK tiene un `clkbuf_20`
     (área 136,1 contra 109,76 µm²) pero no reduce la capacidad que maneja. (b) Repartir la
     carga agregando un nivel más al árbol de reloj (`CTS_BALANCE_LEVELS`, o bajar
     `CTS_SINK_CLUSTERING_SIZE`) sí la quitaría, a costa de más buffers de reloj, más área y
     más latencia de inserción, que es justamente lo que la corrida final ya pagó una vez
     (172 buffers de reloj contra 110 en v1, y la potencia del reloj de 3,709 a 4,592 mW,
     `asic/potencia/resultado.md`). (c) Relajar `MAX_CAPACITANCE_CONSTRAINT` la haría
     desaparecer del reporte sin cambiar el circuito, que es esconderla y no arreglarla.
     Como no es criterio de cierre del enunciado y la celda está nueve veces por debajo de su
     límite de biblioteca, la decisión es dejarla y explicarla.
- Violaciones de **max fanout**: 21 pines, todos salidas de buffers del árbol de reloj
  (`clkbuf_0_clk/Z` con 16 cargas y veinte `clkbuf_leaf_*` con 11 o 12) contra el límite de
  10 de `MAX_FANOUT_CONSTRAINT` (`max_ss_125C_4v50_checks.rpt`, sección `max fanout`). En v1
  eran 62. Tampoco son criterio de cierre y tienen la misma causa: el CTS arma el árbol con
  su propio criterio y el chequeo de fanout del signoff no lo mira.
- **DRC del ruteo detallado por iteración**: la corrida nueva parte con **2** violaciones y
  llega a 0 en la iteración 1, después pasa por 430 y 3 y termina en 0 en la iteración 4
  (`route__drc_errors__iter:0` a `:4` de `metrics.json`: 2, 0, 430, 3, 0). En v1 era 1.546,
  501, 379, 0. Las dos cosas que cambian: la reparación post-GRT le entrega al ruteador
  detallado un diseño mucho más limpio (de 1.546 a 2 en la primera iteración), y después del
  primer cierre el flujo inserta un diodo de antena y vuelve a rutear, de donde salen las
  430 de la iteración 2 (`design__instance__count__class:antenna_cell` = 1 en la corrida
  nueva y 0 en v1).
- Violación aparecida durante el desarrollo: antena de la estrategia 2, net `net3342`
  de s2_t100 (1 net, pin `fanout3341/I`, razón de área lateral de Metal2 1,12 veces el
  límite de 400: `asic/ff/resultados/s2_t100/antenna_summary.rpt` y `antenna.rpt`).
  Dónde: `asic/ff/resultados/s2_t100/layout/antena_antes.png` y `_zoom.png` (net de
  666 x 364 µm con cinco buffers fanout*). Cómo se resolvió: corrida `s2_t100_diodos`
  con `RUN_HEURISTIC_DIODE_INSERTION=true`: 0 nets en violación
  (`asic/ff/resultados/s2_t100_diodos/antenna_summary.rpt`); costo: 36.385 celdas de
  antena (`design__instance__count__class:antenna_cell` de `metrics.json`; 150 en
  s2_t100), área de celdas 838.173 -> 992.171 µm² (+18 %), WNS de setup 39,65 -> 23,65
  ns. Alternativa más barata, corrida `s2_t100_antrep` (`GRT_ANTENNA_REPAIR_ITERS = 6`,
  `GRT_ANTENNA_REPAIR_MARGIN = 30`, sin diodos heurísticos): también 0 violaciones
  (`asic/ff/resultados/s2_t100_antrep/antenna_summary.rpt`), con 258 celdas de antena
  (contra 150 en s2_t100) y 833.559 µm² de celdas (menos que la original), WNS 30,03 ns.
  La evidencia del arreglo son los dos `antenna_summary.rpt` vacíos: no hay figura
  "después" porque en esas corridas `net3342` es otro net con el mismo nombre (los
  diodos y los buffers extra renumeran los nets del resizer). En s2_t100 lo maneja
  `fanout3342` desde `u_soc.g_mem_ff.u_mem.a_addr_i[4]` y alimenta cinco buffers en
  666 x 363 µm; en s2_t100_diodos y s2_t100_antrep lo maneja un `fanout3342` cuya
  entrada es `net3344` y alimenta 10 compuertas en 107 x 78 µm. La señal original sale
  en esas corridas por tres buffers (`fanout3613`, `fanout3631`, `fanout3668`, nets de
  322 x 490, 63 x 478 y 666 x 302 µm), repartida y sin violación. Para la estrategia 1
  no hizo falta (0 violaciones en todas sus corridas).
  Otra que apareció y se resolvió sola: con D21 el ruteo detallado parte con 1.546
  violaciones de DRC en la iteración 0 (contra 6 sin orden de pines, z3_t100) y
  termina en 0 en la iteración 3 (`route__drc_errors__iter:N` de `metrics.json`).
- Marcas del register file, la ALU y el contador en el layout:
  `asic/rom/resultados/final/layout/bloques.png` (nombres jerárquicos `u_soc.u_core.u_rf`,
  `u_soc.u_core.u_id.u_alu`, `u_soc.u_periph.u_cycles`; **2.963, 673 y 117 celdas**, y
  **96.935,6, 11.718,0 y 3.995,3 µm², o sea 49,44 %, 5,98 % y 2,04 %** del área de celdas sin
  relleno, que son 196.079,7 µm²), `bloques.txt` con las envolventes y los 28 terminales con
  su capa y su coordenada, `bloques.lyrdb` para KLayout, y `docs/layout.md` para repetirlas
  en la interfaz. El die mide **638,50 x 656,42 µm = 0,4191 mm²**. En v1 eran 2.103, 615 y
  116 celdas y 46,0 %, 6,2 % y 2,3 % (`resultados/v1_final/layout/bloques.txt`).
- Ruta crítica anotada: `layout/ruta_critica.png` y `.txt` (34 celdas numeradas más 3
  buffers del camino de reloj a 100 ns; 39 más 3 al período mínimo, en
  `resultados/f2_t21p5/layout/`). Detalle por tramos en `asic/rutas.md` y lectura en 3.4.
- Figura de slew: `layout/slew.png` y `slew.txt`, que ahora dicen 0 pines en 0 celdas (en v1
  eran 546 pines en 520 celdas, peor 5,41 ns contra el límite de 3 ns).
- Avisos que quedan: `asic/rom/resultados/final/avisos.md`, revisados uno por uno contra el
  `warning.log` de la corrida nueva. Ningún aviso nuevo del flujo; desaparece el de max slew;
  la caída de tensión sube de 0,148 a 0,611 mV en VDD (0,01 % de los 5 V) y la potencia sin
  actividad de 8,971 a 9,620 mW; y el único aviso de lint nuevo es `rst_ni` sin uso en el
  `espino_id_stage`, que es real y lo cubre el monitor de valores desconocidos usados.

## 3.7. Simulación post-síntesis

- `make post-synth` (`asic/sim/resultado.md`): RTL y netlist de celdas estándar
  (`asic/sim/runs/sim_rom`, síntesis con la configuración final y la ROM del programa
  de simulación), mismo testbench `tb/post_synth_tb.v` (solo puertos de `asic_top`) y
  mismos estímulos `asic/sim/estimulos.txt`: **trazas idénticas (17 cambios de salida en
  4.500 ciclos) y 0 valores X** en las dos. Ronda 1 correcta: el display muestra **51**
  (ciclos medidos, porque `CYCLES_PER_TENTH = 1`) en el ciclo 1033 en los dos; pulsación
  incorrecta en la ronda 2: **EE en el ciclo 1405** y la ronda vuelve a 02 en el 1507 (no
  avanza); reintento correcto: 51 de nuevo en el ciclo 2131. En v1 eran 57 ciclos medidos y
  el EE caía en el 2181: **el core nuevo llega antes porque gasta un ciclo menos por
  instrucción**. Salida completa de la corrida de la integración en
  `docs/verificacion/integracion_13_post_synth.txt`.
- Los estímulos se regeneraron para el core nuevo con `python3 asic/sim/calibrar.py`
  (`docs/verificacion/integracion_15_calibrar.txt`): el archivo que quedó del `merge` sale
  byte a byte igual al que vuelve a generar el calibrador con el RTL integrado, así que la
  recalibración está hecha y verificada. Las pulsaciones pasan de los ciclos 801, 2141 y
  2719 de v1 a **635, 1373 y 1733**.
- Control negativo (`make post-synth-control`, `docs/verificacion/integracion_14_post_synth_control.txt`):
  el netlist con la pulsación de la primera ronda atrasada **8** ciclos da 12 cambios de
  salida y display 59, así que la comparación da FAIL, que es lo que el objetivo exige. **8
  es el atraso más chico que cambia la traza** con este core: el programa lee BTN en un lazo
  de polling de 8 ciclos (`POLL_CICLOS` del `Makefile`) y un atraso de 1 a 7 cae en la misma
  vuelta. En v1 el lazo era de 13 ciclos y el mínimo 6.
- Configuración común documentada en `asic/sim/README.md`: `CYCLES_PER_TENTH = 1` (el
  display muestra ciclos, saturado en 99; las esperas de 30, 12 y 10 "décimas" duran
  decenas de ciclos), `DebounceDivBits = 2` (por `SYNTH_PARAMETERS` en el netlist y por
  parámetro en el RTL), estímulos en ciclos absolutos obtenidos corriendo el RTL por
  etapas (`asic/sim/calibrar.py`).
- Extra: `make post-synth-final` (netlist de la corrida final, constantes reales,
  320.000 ciclos con una pulsación de inicio real): `asic/sim/resultado_final.md`.
  Resultado **PASS**: 3 líneas de traza idénticas en RTL y netlist, 0 valores X, con los
  cuatro LEDs en el ciclo **262.151** y el display 01 en el **262.172** (en v1 eran 262.156
  y 262.194). Esos dos ciclos son los que fijan dos de las cuatro ventanas de la medición de
  potencia (`asic/potencia/resultado.md`, sección 4).
- Post-PnR con SDF: `asic/sim/resultado_sdf.md`. Corrida completa del flujo con la
  configuración de simulación (`asic/sim/config_pnr.yaml`, regenerada desde la configuración
  final de D23, tag **`d2_pnr`**; la de v1 era `d1_pnr` y sus resultados quedan en
  `asic/sim/resultados/d1_pnr/`) y su SDF simulado con el mismo testbench y escenario en
  tres esquinas, con tres ejecuciones por esquina y por simulador. Dos simuladores:
  `make post-pnr-sdf` con Icarus Verilog 13.0 de la imagen de LibreLane, que anota los
  retardos pero **no** evalúa los timing checks (lo dice al compilar: "Timing checks are not
  supported"), y `make post-pnr-cvc` con Open Verilog CVC 7.00b, que sí evalúa `$setup`,
  `$hold`, `$width`, `$recovery`, `$removal` y `$period` con los valores del SDF, con un
  control positivo que demuestra que los evalúa. El aborto de vvp al anotar el SDF que se
  veía antes era el nombre jerárquico de las instancias del banco de registros; lo arregla
  `asic/sim/renombrar_instancias.py`.

## 3.8. Verificación adicional de la sesión del 27 y 28-10-2026 (no cambia el diseño)

- Equivalencia formal entre el RTL y los netlists de la corrida final:
  `docs/equivalencia.md` y `asic/eqy/` (frente D2). eqy con las funciones del liberty
  típico como modelo de celda, RTL (`MemStrategy=1`, `DataWords=4`) contra el netlist de
  síntesis y contra el post-PnR sin celdas físicas, con control negativo que falla como
  debe, BMC desde reset y el flujo clásico de Yosys (`equiv_make`, `equiv_simple`,
  `equiv_induct`). El paso `Yosys.EQY` del flujo no sirve para este PDK y se documenta por
  qué.
- Potencia con actividad real: `asic/potencia/resultado.md` y `asic/potencia/` (frente D3).
  VCD de la simulación del netlist de la corrida final en cuatro ventanas del juego
  (lazo de polling, espera de tres segundos, escritura al display y ráfaga de inicio de
  ronda), leídos por OpenSTA con el SPEF y el liberty de las 9 esquinas: 11,5 a 12,8 mW en
  `nom_tt_025C_5v00` según la fase, contra los 8,97 mW de la estimación sin actividad del
  flujo, con la lógica combinacional pasando de 0,0 a 20 y 28 por ciento del total. El
  reloj (árbol más pines CLK de los 990 flip-flops) sigue siendo el 70 a 78 por ciento.
  Incluye la sensibilidad al estado inicial de los flip-flops sin reset (entre -1,2 y
  +1,8 por ciento).
- Ramas de exploración de la sesión y propuesta de decisión: `asic/exploraciones.md`,
  `docs/propuesta_d23.md` y D23 de `docs/decisiones.md`.
