# Datos para el informe, por sección del enunciado

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

## 3.4. Timing y frecuencia máxima

- Barrido de CLOCK_PERIOD con la configuración final (corridas `final` y `f1_*`):
  tabla en `asic/final.md` (sección del barrido) y gráfico `docs/figuras/periodo.png`.
  Resultado: cierra a 100, 32, 30, 26, 25 y 24,5 ns; no cierra a 24 ns (WNS -0,004 ns en
  max_ss). Período mínimo 24,5 ns, 40,8 MHz (1/24,5 ns = 40,82 MHz; corrida `f1_t24p5` del
  27-10-2026, `asic/rom/resultados/f1_t24p5/cierre.md`: WNS de setup 0,496 ns y TNS 0 en
  max_ss, hold 0,178 ns en la peor esquina, DRC de Magic, LVS y antenas en 0). Con 24,5 ns
  quedan 0,5 ns entre el último período que cierra y el primero que no (24 ns), que es la
  resolución que fija la regla de la sesión. Con el CPI del juego (2,665) son 15,3 MIPS
  (40,82 / 2,665 = 15,32; con 25 ns eran 15,0). f1_t28 se detuvo
  a los 40 minutos en ResizerTimingPostCTS (regla de tiempo) y no cuenta.
- WNS y TNS de setup y hold en nom_tt_025C_5v00 y max_ss_125C_4v50: columnas de la
  tabla de `asic/final.md` (de `metrics.json` de cada corrida).
- Ruta crítica del período mínimo (`asic/rom/resultados/f1_t24p5/layout/ruta_critica.txt`
  y `.png`, esquina max_ss, T = 24,5 ns; es la misma ruta, celda por celda, que la de f1_t25
  en `asic/rom/resultados/f1_t25/layout/`, porque las dos corridas tienen el mismo layout):
  empieza en `_4189_` (dffq_1, registro de
  pre-decodificación `alu_operator[1]`, etapa ID, 1 celda), pasa por la ALU (comparador,
  `u_soc.u_core.u_id.u_alu`, 9 celdas) hasta `lsu_addr[1]`, la alineación de la carga en
  la LSU (lógica aplanada sin nombre jerárquico, 11 celdas), el mux de write-back
  (`rf_wdata[11]`) y el banco de registros (4 celdas), y termina en
  `u_soc.u_core.u_rf/_2933_` (dffq_1, bit de un registro del banco): 25 celdas numeradas
  desde el startpoint, más 3 buffers del camino de reloj (en gris, sin número). Llegada
  del dato 25,784 ns, tiempo requerido 26,280 ns, slack 0,496 ns
  (`asic/rom/resultados/f1_t24p5/max_ss_125C_4v50_ruta_critica.rpt`; a 25 ns el mismo
  camino tiene requerido 26,780 ns y slack 0,996 ns,
  `asic/rom/resultados/f1_t25/max_ss_125C_4v50_ruta_critica.rpt`). Función: ejecución
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
  a 60 ns (12,7 contra 15,3 MIPS de main a 24,5 ns) y ahorra 13 % de área.
- Cada CLOCK_PERIOD reoptimiza el circuito: el área de celdas va de 182.265 µm² (100
  ns) a 189.817 µm² (26 a 24 ns) y las violaciones de slew de 546 a 532; f1_t26, f1_t25,
  f1_t24p5 y f1_t24 dieron exactamente el mismo layout (8.708 celdas estándar, 189.817 µm²
  y 354.897 µm de cables, `metrics.json` de cada una): el resizer llega a su límite con el
  margen de 10 ns (D20) y de ahí para abajo solo cambia el slack reportado, 1 ns de WNS
  por cada ns de período (0,996 a 25 ns, 0,496 a 24,5 ns, -0,004 a 24 ns).

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
