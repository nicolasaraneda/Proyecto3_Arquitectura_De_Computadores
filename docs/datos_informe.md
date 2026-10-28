# Datos para el informe, por sección del enunciado

AVISO (rama `exp/candidata`, frente E): este archivo es la versión de la CANDIDATA. Cada sección
mantiene los números de `main` (corrida `final`) y termina con un bloque "Candidata" con los
números medidos en esta rama y su archivo de origen. La corrida base de la candidata es
`pa_b2_t100` (100 ns, 40 %), no `final`; el resumen del paquete está en `docs/candidata.md` y las
tablas en `asic/final.md` (las genera `bash asic/tablas.sh`). Qué es la candidata: el core del
frente A (lectura del banco y decodificación en el fetch, `EarlyRead=1`, write-through en el
banco) más el offset de byte registrado en la LSU (B2), con la configuración final de `main`
(D15, D20, D21).

Cada sección lista los números, tablas y figuras que la responden, con la corrida de
origen de cada dato. No es el informe: es el índice de dónde está cada cosa. Las
corridas están en `asic/<config>/runs/<tag>` (no versionadas) y sus reportes en
`asic/<config>/resultados/<tag>/` (versionados, con `metrics.json`). Las tablas de
barridos las genera `asic/recolectar.py` y los gráficos `asic/graficos.py`.

## 2. Corrida final y reproducibilidad

- Corrida final: tag `final`, `asic/rom/config.yaml` (estrategia 1, D17; D15, D20 y
  D21), T = 100 ns, FP_CORE_UTIL = 40 %. Comando: `make final` (`asic/final.sh`), o
  `librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag final`.
- Criterios de cierre (`asic/rom/resultados/final/cierre.md`, `asic/verificar_cierre.py`):
  DRC de Magic 0, LVS 0, antena 0 nets, setup WNS 65,223 ns y hold WNS 0,178 ns en
  la peor de las 9 esquinas, TNS 0 en todas. Además DRC de KLayout 0 marcadores en
  684 reglas (`asic/rom/resultados/final/drc_klayout/resumen.md`, deck en `asic/drc/`).
- Versiones (`asic/versiones.md`, `asic/versiones.sh`): LibreLane 3.0.16, imagen
  `ghcr.io/librelane/librelane:3.0.16`, PDK gf180mcuD revisión
  `54435919abffb937387ec956209f9cf5fd2dfbee`, biblioteca `gf180mcu_fd_sc_mcu7t5v0`,
  Yosys 0.62, OpenROAD dcf36133, Magic 8.3.623, KLayout 0.30.7, Netgen 1.5.316,
  Icarus 13.0 (imagen) y 14.0 (oss-cad-suite, simulaciones).
- Instalación y regeneración del programa: README (`make image`, assembler propio).
- Datos de la corrida final (`asic/rom/resultados/final/metrics.json`):
  die 630,6 x 648,52 µm = 408.957 µm² (0,409 mm²); core 379.800 µm²; área de celdas
  estándar 182.265 µm²; utilización 48,0 %; 8.670 celdas estándar, 990 flip-flops;
  largo de cables 352.253 µm; potencia estimada 8,97 mW a 10 MHz en nom_tt (`power.rpt` de esa esquina; los 11,3 mW de
  `power__total` en `metrics.json` son de max_ff, la última esquina que procesa el flujo).

**Candidata.** Corrida base `pa_b2_t100`: misma `asic/rom/config.yaml` del enunciado (D15, D20,
D21) más `EarlyRead=1`, T = 100 ns, FP_CORE_UTIL = 40 %. Encolada con
`bash asic/encolar.sh build/exp_candidata asic/rom/config.yaml pa_b2_t100 100` (la corrió el frente
A en `build/exp_pipeline_b2`, árbol idéntico a esta rama; enlazada en `asic/rom/runs/`). Cierra:
`asic/rom/resultados/pa_b2_t100/cierre.md` (DRC de Magic 0, LVS 0, antenas 0, setup y hold con
WNS >= 0 y TNS = 0 en las 9 esquinas; WNS de setup 63,191 ns y hold 0,134 ns en la peor esquina), y
DRC de KLayout 0 marcadores. Datos de `metrics.json`: die 419.131 µm² (0,419 mm²), core 389.525 µm²,
área de celdas estándar 186.432 µm² (+2,3 % sobre los 182.265 de `main`, dentro del límite de
105 %), 9.197 celdas, 964 flip-flops, cables 371.092 µm, utilización 47,9 %, potencia sin actividad
8,597 mW en nom_tt (`55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`). Versiones: las mismas de
`main` (`asic/versiones.md`), porque es el mismo LibreLane, la misma imagen y el mismo PDK.
Verificación funcional de la rama: `docs/candidata.md`, sección 1.

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

**Candidata.** Las dos estrategias con el RTL de la candidata (`asic/final.md`, sección
"Estrategia 2"): `pa_b2_t100` (s1) contra `e2_t100` (s2, `asic/ff/config.yaml`): área de celdas
tras PnR 186.432 contra 843.767 µm², die 419.131 contra 1.801.610 µm² (4,3 veces), 9.197 contra
40.829 celdas, cables 371.092 contra 2.209.619 µm, slew/cap 571/37 contra 18.557/209, antenas 0 en
las dos. Las dos cierran a 100 ns (`cierre.md` de cada tag; para s2, WNS de setup 30,802 ns y hold
0,164 ns en la peor esquina). Costo a US$23.000/mm²: 0,419 mm² -> US$9.637 contra 1,802 mm² ->
US$41.437. Con `MemStrategy=2` el SoC instancia el core con `EarlyRead = 0` (decisión del frente A,
`docs/pipeline.md`), así que el CPI del juego con s2 es 2,665, el mismo de `main`, y la comparación
con la referencia de `main` para s2 (período mínimo 62 ns) usa la misma configuración de flujo.
Período mínimo de s2 con este RTL: 69,5 ns (cierra `e2_t69p5` con WNS +0,302 ns y no cierra
`e2_t69` con -0,198 ns; brecha de 0,5 ns). Son 7,5 ns más que `main` porque el banco de registros
con write-through y enable de lectura alarga también la ruta crítica de esa estrategia, en la que
`EarlyRead = 0` y la lectura anticipada no se usa.

## 3.3. Síntesis

- `asic/sintesis.md` (generado por `asic/analisis_sintesis.py` desde `final` y
  `h2_t100`): área por módulo con porcentaje, las cinco celdas más usadas con su
  desglose por módulo y la verificación contra el RTL, fracción del contador de ciclos.
- Cinco celdas más usadas (corrida final, 5.118 celdas de síntesis): dffq_1 804
  (15,7 %), mux2_2 759 (14,8 %), nand2_1 758 (14,8 %), oai21_1 309 (6,0 %), clkinv_1
  284 (5,5 %). dffq_1: 544 del banco de registros (480 bits + 64 de salida), 192 de la
  memoria (registro de instrucción, RAM de 4 palabras, salida de datos), 82 de la
  pre-decodificación; la síntesis aplanada elimina 14 de los 818 del RTL.
- Módulo con más área: `espino_register_file` (u_soc.u_core.u_rf), 73.656 µm², 46,6 %
  de la síntesis jerárquica (157.980 µm²) y 48,4 % de la aplanada (152.169 µm²).
- Contador de ciclos: 3.943 µm², 2,50 % (jerárquica) y 2,59 % (final); 32 dffrnq_1.
- Método: `SYNTH_KEEP_HIERARCHY_MODULES` en la corrida final y síntesis aparte con
  `SYNTH_HIERARCHY_MODE=keep` (h2_t100, `asic/rom/resultados/h2_t100/sintesis_jerarquica.rpt`).
- Reportes: `asic/rom/resultados/final/sintesis_stat.rpt` y `sintesis_stat.json`.

**Candidata.** `asic/sintesis.md` de la rama, regenerado con
`python3 asic/analisis_sintesis.py --final asic/rom/runs/pa_b2_t100 --jerarquica asic/rom/runs/e1_h100 --md asic/sintesis.md`
(del script solo se adaptó el texto que nombraba la corrida jerárquica; los nombres de módulo son
los mismos). Área de celdas de síntesis 156.098 µm² (aplanada) contra 164.605 µm² (jerárquica,
`e1_h100`, -5,2 % por la optimización entre bordes de módulo); 5.577 celdas de 36 tipos;
`espino_register_file` 80.349 µm², 49 % del total (contra 73.656 µm² y 46,6 % en `main`: el
write-through y el enable de lectura suben los mux2_2 de 622 a 796); 964 flip-flops contra 990
(el registro de instrucción pierde 28 bits, porque con EarlyRead solo se usa rd, y B2 agrega 2 para el
offset de byte registrado de la carga: 990 - 28 + 2). Celdas más
usadas: `nand2_1` 934 (16,7 %), `mux2_2` 889 (15,9 %), `dffq_1` 779 (14,0 %), `aoi21_1` 437,
`oai21_1` 348; en `main` el orden era dffq_1, mux2_2, nand2_1. Reportes:
`asic/rom/resultados/pa_b2_t100/sintesis_stat.rpt` y
`asic/rom/resultados/e1_h100/sintesis_jerarquica.rpt`.

## 3.4. Timing y frecuencia máxima

- Barrido de CLOCK_PERIOD con la configuración final (corridas `final` y `f1_*`):
  tabla en `asic/final.md` (sección del barrido) y gráfico `docs/figuras/periodo.png`.
  Resultado: cierra a 100, 32, 30, 26 y 25 ns; no cierra a 24 ns (WNS -0,004 ns en
  max_ss). Período mínimo 25 ns, 40,0 MHz (ver cierre.md de f1_t25). f1_t28 se detuvo
  a los 40 minutos en ResizerTimingPostCTS (regla de tiempo) y no cuenta.
- WNS y TNS de setup y hold en nom_tt_025C_5v00 y max_ss_125C_4v50: columnas de la
  tabla de `asic/final.md` (de `metrics.json` de cada corrida).
- Ruta crítica del período mínimo (`asic/rom/resultados/f1_t25/layout/ruta_critica.txt`
  y `.png`, esquina max_ss, T = 25 ns): empieza en `_4189_` (dffq_1, registro de
  pre-decodificación `alu_operator[1]`, etapa ID, 1 celda), pasa por la ALU (comparador,
  `u_soc.u_core.u_id.u_alu`, 9 celdas) hasta `lsu_addr[1]`, la alineación de la carga en
  la LSU (lógica aplanada sin nombre jerárquico, 11 celdas), el mux de write-back
  (`rf_wdata[11]`) y el banco de registros (4 celdas), y termina en
  `u_soc.u_core.u_rf/_2933_` (dffq_1, bit de un registro del banco): 25 celdas numeradas
  desde el startpoint, más 3 buffers del camino de reloj (en gris, sin número). Llegada
  del dato 25,784 ns, tiempo requerido 26,780 ns, slack 0,996 ns
  (`asic/rom/resultados/f1_t25/max_ss_125C_4v50_ruta_critica.rpt`). Función: ejecución
  (ALU) -> acceso a memoria (alineación del dato) -> write-back. Es la misma ruta que D18
  describe, ahora sin el decode, y la misma de f1_t26 (mismo layout).
- Cambio de RTL (D18, pre-decodificación): antes s1_t55 (55 ns, WNS 1,764) y p1_t42
  (42 ns); con la configuración final, el RTL anterior (116fa20) corre como r0_t100 y
  r0_t26: a 100 ns WNS 54,552 contra 65,223 ns (10,7 ns menos de ruta), área 174.529
  contra 182.265 µm² (+4,4 % por los 69 flip-flops y muxes de la pre-decodificación);
  r0_t26: pendiente (tabla de `asic/final.md`).
- Constantes de game.s para T = 100 ns: D10 (`CLK_HZ = 10000000`, `CYCLES_PER_TENTH = 1000000`).
- Más allá de lo pedido, las ramas exp/* (`asic/exploraciones.md`) miden otros cambios de
  RTL con la misma configuración: registrar el offset de byte en la LSU (B2) cierra a 24 ns
  (41,7 MHz) con 0,6 % menos de área; el comparador de saltos dedicado (B3) no mueve el
  período; ejecutar en un ciclo (B4) baja el CPI de 2,67 a 1,31 pero sube el período mínimo
  a 60 ns (12,7 contra 15,0 MIPS) y ahorra 13 % de área.
- Cada CLOCK_PERIOD reoptimiza el circuito: el área de celdas va de 182.265 µm² (100
  ns) a 189.817 µm² (26 y 24 ns) y las violaciones de slew de 546 a 532; f1_t26 y f1_t24
  dieron exactamente el mismo layout (mismo número de celdas, área y largo de cables): el
  resizer llega a su límite con el margen de 10 ns (D20) y de ahí para abajo solo cambia
  el slack reportado.

**Candidata.** Barrido de CLOCK_PERIOD (`asic/final.md`, sección del barrido; gráfico
`docs/figuras/periodo.png`): cierra a 100, 26 y 25,5 ns; 25 ns NO cierra (setup -0,409 ns y TNS
-1,027 ns en max_ss_125C_4v50, `asic/rom/resultados/pa_b2_t25/cierre.md`). Período mínimo 25,5 ns,
f_max 39,2 MHz, brecha de 0,5 ns con el primero que no cierra (regla de la sesión cumplida).
Contra `main`: 24,5 ns y 40,8 MHz (`m_f1_t24p5`, enlace a la corrida f1_t24p5 del repo principal).
Las corridas de 26, 25,5 y 25 ns tienen el mismo layout (9.224 celdas, 194.212 µm², 373.251 µm de
cables): el resizer llega a su límite con el margen de 10 ns de D20.
Ruta crítica a 25,5 ns (`asic/rom/resultados/pa_b2_t25p5/layout/ruta_critica.txt` y `.png`):
24 celdas, de `_4288_` (`dffrnq_2`, un bit de `pc_q` que maneja
`u_soc.g_mem_rom.u_mem.a_addr_i[3]`) por la ROM combinacional (`a_next_o[17]`) al banco de
registros, y termina en `u_soc.u_core.u_rf/_4114_` (`dffq_1`). Función: fetch (PC -> ROM) ->
lectura anticipada del banco de registros, que es la ruta que crea EarlyRead; en `main` la crítica
era ALU -> alineación de la carga -> write-back. A 100 ns la crítica es otra: 29 celdas de `_4325_`
(`alu_op_b_sel` de la etapa ID) a `_4442_` (`asic/rom/resultados/pa_b2_t100/layout/ruta_critica.txt`).
CPI y MIPS (regla de selección): CPI del juego 1,665 y de isa_test 1,969; MIPS = 39,2 / 1,665 =
23,6 contra 15,3 de `main` (`docs/candidata.md`, secciones 1 y 4).
Variantes de signoff de slew y capacitancia sobre este RTL: `docs/candidata.md`, sección 7
(`e1_g30_t100` baja de 571 a 279 pines de slew por +1,27 % de área, pero `e1_g30_t25p5` no cierra
(-1,422 ns); `e1_full_t100` llega a 0 slew y 0 cap pero cuesta 209.185 µm², 114,8 % de `main`).

## 3.5. Floorplan, utilización y costo

- Barrido de FP_CORE_UTIL a 100 ns (corridas `final` = 40, `u1_u50`, `u1_u60`,
  `u1_u70`, `u1_u80`, `u1_u90`): tabla en `asic/final.md`, gráfico
  `docs/figuras/utilizacion.png` (DRC de ruteo por iteración, largo de cables global y
  detallado, slew, capacitancia, antena, área del die, WNS).
  Resultados: 50 % cierra (die 329.861 µm², utilización real 59 %), 60 % cierra
  (276.917 µm², 70 %), 70 % cierra (238.967 µm², 81 %; el ruteo detallado parte con
  2.149 violaciones de DRC y las resuelve), 80 % falla en CTS (`[DPL-0036] Detailed
  placement failed`, log `asic/logs/u1_u80.log`), 90 % falla en el placement global
  (`[GPL-0301] Utilization 100.531 % exceeds 100%`, `asic/logs/u1_u90.log`). Los logs
  no se versionan (`asic/logs/` está en .gitignore); el extracto de cada falla está en
  `asic/rom/resultados/u1_u80/falla.txt` y `asic/rom/resultados/u1_u90/falla.txt`. Área
  mínima que cumple los criterios: u1_u70, 0,239 mm² (die 480,0 x 497,9 µm), con DRC,
  LVS y antenas limpios y WNS de setup 64,1 ns en max_ss. Las violaciones de slew bajan
  con la utilización (546, 438, 378, 392) porque los cables se acortan.
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
- Costo a US$23.000/mm²: final 0,409 mm² -> US$9.406; mínima (u1_u70) 0,239 mm² ->
  US$5.496 (42 % menos); estrategia 2 (s2_t100) 1,794 mm² -> US$41.266.
  Limitaciones del modelo lineal: el costo real de un prototipo se paga por lote
  (multi-project wafer) con un mínimo de área, el macro no incluye pads, anillo de
  sello ni empaque, el precio por mm² baja con el volumen, y una utilización alta
  ahorra área pero cuesta cierre (80 % ya no coloca). Decisión de mayor impacto en
  área y costo: la estrategia de memoria (D17): 4,4 veces en área y costo; después
  la utilización (40 a 70 %: 0,409 a 0,239 mm², 42 %).

**Candidata.** Barrido de FP_CORE_UTIL a 100 ns (`asic/final.md`, sección del barrido; gráfico
`docs/figuras/utilizacion.png`; `cierre.md` de cada tag): 70 % cierra (die 244.851 µm²,
utilización real 81,5 %, área de celdas 181.036 µm²), 75 % cierra (229.251 µm², 86,9 %, 180.303 µm²)
y 78 % cierra (220.839 µm², 90,0 %, 180.044 µm², WNS de setup 63,948 ns y hold 0,168 ns). Las
violaciones de slew bajan con la utilización (571 a 40 %, 404 a 70 %, 478 a 75 %, 446 a 78 %)
porque los cables se acortan. Área mínima que cierra: 0,221 mm² a 78 % (contra 0,216 mm² de `main`
a 78 %). Costo a US$23.000/mm²: 0,419 mm² -> US$9.637 a 40 % y 0,221 mm² -> US$5.079 a 78 %
(-47 %). Los terminales son los mismos de D21 (`asic/rom/pines.cfg` sin cambios).

## 3.6. Signoff y layout

- DRC de Magic 0, LVS 0, antena 0 (final; `cierre.md`). Segundo DRC con el deck de
  KLayout de GlobalFoundries: 0 marcadores (`drc_klayout/resumen.md`); por qué el flujo
  lo salta: `asic/drc/ORIGEN.md`.
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
- Marcas del register file, la ALU y el contador: `asic/rom/resultados/final/layout/bloques.png`
  (nombres jerárquicos `u_soc.u_core.u_rf`, `u_soc.u_core.u_id.u_alu`,
  `u_soc.u_periph.u_cycles`; 2.103, 615 y 116 celdas; 46,0 %, 6,2 % y 2,3 % del área de
  celdas), `bloques.txt` con las envolventes, `bloques.lyrdb` para KLayout, y
  `docs/layout.md` para repetirlas en la interfaz. Ruta crítica: `ruta_critica.png`;
  slew: `slew.png` (546 pines en 520 celdas, peor 5,41 ns contra 3 ns).
- Avisos que quedan: `asic/rom/resultados/final/avisos.md` (3 pines SPI sin compuerta,
  VDD y VSS "flotantes" para el resizer, VSRC_LOC_FILES sin valor).

**Candidata.** DRC de Magic 0, LVS 0 y antenas 0 (`asic/rom/resultados/pa_b2_t100/cierre.md`);
segundo DRC con el deck de KLayout: 0 marcadores en 684 reglas
(`asic/rom/resultados/pa_b2_t100/drc_klayout/resumen.md`), con control positivo que marca M1.1 y
M1.2a en sus coordenadas (`drc_klayout/control_positivo.md`). Figuras del layout:
`asic/rom/resultados/pa_b2_t100/layout/` y `asic/rom/resultados/pa_b2_t25p5/layout/`
(`bloques.png`, `bloques.txt`, `bloques.lyrdb`, `ruta_critica.png`, `slew.png`: 571 pines en 558
celdas a 100 ns y 508 en 498 a 25,5 ns). Estrategia 2 con este RTL (`e2_t100`): 0 nets con
violación de antena (en `main`, s2_t100 tenía 1), pero 18.557 pines con violación de slew y 209 de
capacitancia (`asic/ff/resultados/e2_t100/metrics.json`).

## 3.7. Simulación post-síntesis

- `make post-synth` (`asic/sim/resultado.md`): RTL y netlist de celdas estándar
  (`asic/sim/runs/sim_rom`, síntesis con la configuración final y la ROM del programa
  de simulación), mismo testbench `tb/post_synth_tb.v` (solo puertos de asic_top) y
  mismos estímulos `asic/sim/estimulos.txt`: trazas idénticas (17 cambios de salida),
  0 valores X. Ronda 1 correcta: el display muestra 57 (ciclos medidos, porque
  CYCLES_PER_TENTH=1) en los dos; pulsación incorrecta en la ronda 2: EE en el ciclo
  2181 y la ronda vuelve a 02 (no avanza); reintento correcto: 57 de nuevo.
- Configuración común documentada en `asic/sim/README.md`: CYCLES_PER_TENTH=1 (el
  display muestra ciclos, saturado en 99; las esperas de 30, 12 y 10 "décimas" duran
  decenas de ciclos), DebounceDivBits=2 (por SYNTH_PARAMETERS en el netlist y por
  parámetro en el RTL), estímulos en ciclos absolutos obtenidos corriendo el RTL por
  etapas (`asic/sim/calibrar.py`).
- Extra: `make post-synth-final` (netlist de la corrida final, constantes reales,
  320.000 ciclos con una pulsación de inicio real): `asic/sim/resultado_final.md`.
  Resultado: PASS (LEDs 1111 en el ciclo 262.156 y display 01 en el 262.194, iguales en RTL y netlist).
  Post-PnR con SDF (opcional): `make post-pnr-sdf`, `asic/sim/resultado_sdf.md`: completó
  una vez con la misma traza (PASS, 4 min 19 s); las corridas siguientes abortan en vvp
  al anotar el SDF (aserción interna de Icarus 14.0-devel con `-ginterconnect`); está
  documentado en `asic/sim/README.md`.

**Candidata.**

- `make post-synth NETLIST_SIM=asic/sim/runs/e1_sim_rom/06-yosys-synthesis/asic_top.nl.v`
  (`asic/sim/resultado.md` de la rama): trazas idénticas entre el RTL y el netlist de celdas
  estándar de ESTA rama, 17 cambios de salida, 0 valores X, PASS. Control negativo
  (`make post-synth-control`, ATRASO=8): FAIL como corresponde, sección "Control negativo" del
  mismo archivo. El netlist es de la corrida `e1_sim_rom` (`asic/sim/config.yaml` de la rama,
  generada por `asic/sim/generar_config.py`, con `EarlyRead=1`, la ROM del programa de simulación
  y DebounceDivBits=2).
- Post-PnR con SDF: `asic/sim/resultado_sdf.md` de la rama. Corrida completa `e1_pnr`
  (`asic/sim/config_pnr.yaml`; cierra, `asic/sim/resultados/e1_pnr/cierre.md`) y
  `make post-pnr-sdf ESQUINA=<esquina>` con el Icarus 13.0 de la imagen en nom_tt_025C_5v00,
  max_ss_125C_4v50 y min_ff_n40C_5v50: las tres PASS, 3 de 3 repeticiones con el mismo md5 que la
  traza del RTL, 0 valores X, 33.247 de 35.715 IOPATH y 15.543 de 15.544 INTERCONNECT anotados.
  Los 7.173 timing checks de los 951 bloques TIMINGCHECK del SDF NO los evalúa Icarus: el cierre
  de setup y hold lo da el STA de las 9 esquinas.
- Potencia con actividad real (`asic/potencia/resultado.md` de la rama, versión reducida del
  método del frente D3): ventana polling, 12,392 mW en nom_tt contra 8,597 mW sin actividad
  (+44,1 %), 10,260 contra 7,098 mW en max_ss y 15,096 contra 10,529 mW en min_ff; 22.130
  actividades de pin anotadas y 0 sin anotar.
