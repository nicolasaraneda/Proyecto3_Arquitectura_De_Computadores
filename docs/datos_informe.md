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
  largo de cables 352.253 µm; potencia estimada 11,3 mW a 10 MHz (nom_tt).

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
  Resultado: cierra a 100, 32, 30, 26 y 25 ns; no cierra a 24 ns (WNS -0,004 ns en
  max_ss). Período mínimo 25 ns, 40,0 MHz (ver cierre.md de f1_t25). f1_t28 se detuvo
  a los 40 minutos en ResizerTimingPostCTS (regla de tiempo) y no cuenta.
- WNS y TNS de setup y hold en nom_tt_025C_5v00 y max_ss_125C_4v50: columnas de la
  tabla de `asic/final.md` (de `metrics.json` de cada corrida).
- Ruta crítica del período mínimo (`asic/rom/resultados/f1_t26/layout/ruta_critica.txt`
  y `.png`, esquina max_ss): empieza en `_4189_` (dffq_1, registro de pre-decodificación
  `alu_operator[1]`, etapa ID), pasa por la ALU (comparador, `u_soc.u_core.u_id.u_alu`,
  9 celdas) hasta `lsu_addr[1]`, la alineación de la carga en la LSU (lógica aplanada),
  el mux de write-back (`rf_wdata[11]`) y termina en `u_soc.u_core.u_rf/_2933_` (dffq_1,
  bit de un registro del banco). Función: ejecución (ALU) -> acceso a memoria (alineación
  del dato) -> write-back. Es la misma ruta que D18 describe, ahora sin el decode.
  Pendiente: la de f1_t25 (misma estructura; regenerar con `make layout RUN=asic/rom/runs/f1_t25`).
- Cambio de RTL (D18, pre-decodificación): antes s1_t55 (55 ns, WNS 1,764) y p1_t42
  (42 ns); con la configuración final, el RTL anterior (116fa20) corre como r0_t100 y
  r0_t26: a 100 ns WNS 54,552 contra 65,223 ns (10,7 ns menos de ruta), área 174.529
  contra 182.265 µm² (+4,4 % por los 69 flip-flops y muxes de la pre-decodificación);
  r0_t26: pendiente (tabla de `asic/final.md`).
- Constantes de game.s para T = 100 ns: D10 (`CLK_HZ = 10000000`, `CYCLES_PER_TENTH = 1000000`).
- Cada CLOCK_PERIOD reoptimiza el circuito: el área de celdas va de 182.265 µm² (100
  ns) a 189.817 µm² (26 y 24 ns) y las violaciones de slew de 546 a 532; f1_t26 y f1_t24
  dieron exactamente el mismo layout (mismo número de celdas, área y largo de cables): el
  resizer llega a su límite con el margen de 10 ns (D20) y de ahí para abajo solo cambia
  el slack reportado.

## 3.5. Floorplan, utilización y costo

- Barrido de FP_CORE_UTIL a 100 ns (corridas `final` = 40, `u1_u50`, `u1_u60`,
  `u1_u70`, `u1_u80`, `u1_u90`): tabla en `asic/final.md`, gráfico
  `docs/figuras/utilizacion.png` (DRC de ruteo por iteración, largo de cables global y
  detallado, slew, capacitancia, antena, área del die, WNS).
  Resultados: 50 % cierra (die 329.861 µm², utilización real 59 %), 60 % cierra
  (276.917 µm², 70 %), 70 % cierra (238.967 µm², 81 %; el ruteo detallado parte con
  2.149 violaciones de DRC y las resuelve), 80 % falla en CTS (`[DPL-0036] Detailed
  placement failed`, log `asic/logs/u1_u80.log`), 90 % falla en el placement global
  (`[GPL-0301] Utilization 100.531 % exceeds 100%`, `asic/logs/u1_u90.log`). Área
  mínima que cumple los criterios: u1_u70, 0,239 mm² (die 490,4 x 487,3 µm), con DRC,
  LVS y antenas limpios y WNS de setup 64,1 ns en max_ss. Las violaciones de slew bajan
  con la utilización (546, 438, 378, 392) porque los cables se acortan.
- Terminales (D21, `asic/rom/pines.cfg`): oeste entradas (btn[3:0], clk al centro,
  rst_n), este displays (seg1[6:0], seg2[6:0]), norte led[3:0], sur SPI. Son
  rectángulos de metal en el borde del macro (Metal3 en oeste y este, Metal2 en norte y
  sur), no pads: un chip completo los conectaría a pads de I/O con protección ESD y
  buffers de salida. Figura: `asic/rom/resultados/final/layout/bloques.png`.
  Efecto contra la ubicación automática: corrida `u1_auto` (`asic/rom/config_pines_auto.yaml`),
  pendiente: comparar largo de cables, DRC de ruteo por iteración y WNS con `final`.
- Costo a US$23.000/mm²: final 0,409 mm² -> US$9.406; mínima (u1_u70) 0,239 mm² ->
  US$5.496 (42 % menos); estrategia 2 (s2_t100) 1,794 mm² -> US$41.266.
  Limitaciones del modelo lineal: el costo real de un prototipo se paga por lote
  (multi-project wafer) con un mínimo de área, el macro no incluye pads, anillo de
  sello ni empaque, el precio por mm² baja con el volumen, y una utilización alta
  ahorra área pero cuesta cierre (80 % ya no coloca). Decisión de mayor impacto en
  área y costo: la estrategia de memoria (D17): 4,4 veces en área y costo; después
  la utilización (40 a 70 %: 0,409 a 0,239 mm², 42 %).

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
  (`asic/ff/resultados/s2_t100_diodos/antenna_summary.rpt`), figura `antena_despues.png`
  y `_zoom.png`; costo: 36.385 celdas de antena (contra 150), área de celdas 838.173 ->
  992.171 µm² (+18 %), WNS de setup 39,65 -> 23,65 ns. Para la estrategia 1 no hizo
  falta (0 violaciones en todas sus corridas).
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
  Post-PnR con SDF: `make post-pnr-sdf`, resultado en `asic/sim/resultado_sdf.md`
  (pendiente de confirmar).
