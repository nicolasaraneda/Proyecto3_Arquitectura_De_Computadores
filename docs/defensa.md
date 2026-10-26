# Preguntas probables de la defensa, con respuesta corta y dónde está el dato

Treinta preguntas que un ayudante puede hacer sobre el informe, el RTL y el assembler.
Cada respuesta se apoya en un archivo del repositorio.

## Flujo y corrida final

1. **¿Con qué versión de todo se hizo la corrida final?** LibreLane 3.0.16 (imagen `ghcr.io/librelane/librelane:3.0.16`), PDK gf180mcuD revisión 54435919, biblioteca gf180mcu_fd_sc_mcu7t5v0, Yosys 0.62, OpenROAD dcf36133, Magic 8.3.623, KLayout 0.30.7, Netgen 1.5.316. Archivo: `asic/versiones.md`.
2. **¿Cómo se reproduce la corrida final?** `make final` (`asic/final.sh`): corre `librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag final`, verifica los criterios de cierre y regenera tablas, síntesis, figuras, DRC de KLayout y la simulación post-síntesis. Archivo: README, `asic/final.sh`.
3. **¿Qué significa que la corrida "cierra"?** DRC y LVS limpios, 0 nets con violación de antena, y WNS >= 0 y TNS = 0 de setup y hold en las 9 esquinas de STA (D14). Lo revisa `asic/verificar_cierre.py`; resultado en `asic/rom/resultados/final/cierre.md`.
4. **¿Por qué 9 esquinas si LibreLane solo falla por la típica?** Porque el chip tiene que funcionar en el peor proceso, voltaje y temperatura; LibreLane solo marca error en nom_tt (`TIMING_VIOLATION_CORNERS`), así que el cierre en las demás se verifica con las métricas por esquina. Archivo: `docs/decisiones.md`, D14.
5. **¿Qué es un macro y por qué los terminales no son pads?** El resultado es un bloque de celdas estándar con terminales de metal en el borde (Metal3 al oeste y este, Metal2 al norte y sur); un chip completo lo rodearía de pads de I/O con protección ESD y buffers. Archivos: `rtl/asic_top.v`, `asic/rom/resultados/final/layout/bloques.png`.
6. **¿Qué avisos quedan en la corrida final y por qué no importan?** Tres pines SPI sin información de antena (no llegan a ninguna compuerta, D7), VDD y VSS "flotantes" para el resizer (los conecta la red de potencia; LVS limpio) y VSRC_LOC_FILES sin valor (ubicación de las fuentes para el análisis de caída de tensión: no hay pads). Archivo: `asic/rom/resultados/final/avisos.md`.

## Sección 3.1 y 3.2

7. **¿Qué del Proyecto 2 no se podía sintetizar y cómo se supo?** La BRAM `SB_RAM40_4K` (el linter de Verilator la reporta como módulo inexistente), el contador de power-on reset con valor inicial (PROCASSINIT; en silicio no hay valor inicial), el `$readmemh` dentro de un `initial` (Yosys lo convierte en valor inicial, que se descarta) y la RAM de 512 palabras que se infiere en 16.384 flip-flops. Archivo: `asic/p2_original/evidencia.md`.
8. **¿Cómo entra el programa al silicio si no hay `$readmemh`?** El assembler genera código Verilog: la ROM combinacional `rtl/gen/pochoco_rom.v` (un `case` por dirección) y la imagen `rtl/gen/game_image.vh` para la memoria en flip-flops. `make image` los regenera y un test comprueba que corresponden a `sw/game.s`. Archivos: `docs/assembler.md`, D11.
9. **¿Por qué la estrategia 1 y no la memoria unificada?** 4,7 veces menos área de celdas de síntesis (146.400 contra 693.901 µm²), 921 contra 4.602 flip-flops, die 0,39 contra 1,79 mm², 55 contra 62 ns de período mínimo y sin violación de antena. Archivo: `asic/barrido.md` (comparación 3.2), D17.
10. **¿Por qué la RAM de datos tiene 4 palabras si el juego no usa memoria de datos?** El juego hace 0 lecturas y 0 escrituras de datos; 4 palabras mantienen la RAM que pide la estrategia 1 con costo mínimo (128 flip-flops) y el mismo valor en las dos estrategias hace comparable la comparación. Archivo: D9.

## Sección 3.3

11. **¿Cuáles son las cinco celdas más usadas y por qué?** dffq_1 (804), mux2_2 (759), nand2_1 (758), oai21_1 (309), clkinv_1 (284). Los flip-flops sin reset son el banco de registros (544 = 480 bits + 64 de salida), la memoria (192) y la pre-decodificación (82); los mux2 son en su mayoría muxes de retención (la biblioteca no tiene flip-flops con enable) y los árboles de lectura del banco; las NAND2 son la lógica aleatoria de la ROM, la ALU y el decodificador. Archivo: `asic/sintesis.md`.
12. **¿Qué módulo tiene más área?** El banco de registros `u_soc.u_core.u_rf`: 73.656 µm², 46,6 % en la síntesis jerárquica y 48,4 % en la final. Archivo: `asic/sintesis.md`.
13. **¿Y el contador de ciclos?** 3.943 µm², 2,5 %: 32 flip-flops con reset más un incrementador. Archivo: `asic/sintesis.md`.
14. **La corrida final aplana el diseño: ¿cómo se midió el área por módulo?** Con una síntesis aparte de la misma configuración con `SYNTH_HIERARCHY_MODE=keep` solo hasta Yosys (h2_t100); la final conserva solo tres módulos (`SYNTH_KEEP_HIERARCHY_MODULES`, D12). La aplanada ahorra 3,7 % por optimizar a través de los bordes. Archivos: `asic/sintesis.md`, `asic/rom/resultados/h2_t100/sintesis_jerarquica.rpt`.

## Sección 3.4

15. **¿Cuál es la frecuencia máxima?** 40 MHz: cierra a 25 ns y no a 24 (WNS -0,004 ns en max_ss_125C_4v50). Archivos: `asic/final.md`, `asic/rom/resultados/f1_t25/cierre.md`.
16. **¿Cuál es la ruta crítica?** Del registro de pre-decodificación `alu_operator[1]` (`_4189_`, etapa ID) por el comparador de la ALU hasta `lsu_addr[1]`, la alineación de la carga en la LSU, el mux de write-back `rf_wdata[11]` y un flip-flop del banco (`u_soc.u_core.u_rf/_2933_`): ejecución, acceso a memoria y write-back. Es un camino falso funcionalmente (el resultado de un SLT nunca es la dirección de una carga) pero real para el STA. Archivo: `asic/rom/resultados/f1_t25/layout/ruta_critica.txt` y `.png`.
17. **¿Qué cambio de RTL se hizo y cuánto rindió?** Pre-decodificación (D18): registrar las salidas del decodificador en el ciclo de espera del banco. Con la misma configuración, a 100 ns el WNS pasa de 54,6 a 65,2 ns (10,7 ns menos de ruta) y el período mínimo de 42 a 25 ns; cuesta 4,4 % de área (69 flip-flops más muxes). Verificado ciclo a ciclo con `make equiv`. Archivos: D18, `asic/final.md` (r0_* contra f1_*).
18. **¿Por qué dicen que cada CLOCK_PERIOD reoptimiza el circuito?** El resizer dimensiona celdas y agrega buffers según el período: el área de celdas va de 182.265 µm² a 100 ns a 189.817 µm² a 26 ns, y las violaciones de slew cambian. Pero f1_t26, f1_t25 y f1_t24 dan el mismo layout: con el margen de 10 ns (D20) el resizer ya hizo todo lo que podía. Archivo: `asic/final.md`.
19. **¿Qué pasó con las constantes de game.s?** Para T = 100 ns, f = 10 MHz, una décima son 1.000.000 ciclos: `CLK_HZ = 10000000` y `CYCLES_PER_TENTH = 1000000`; el debounce con DivBits = 15 muestrea cada 3,3 ms. Archivo: D10, `sw/game.s`.
20. **¿Por qué las violaciones de max slew si el timing cierra?** El límite de 3 ns es la restricción SDC del PDK (MAX_TRANSITION_CONSTRAINT), no la biblioteca, que permite 7 ns; son transiciones lentas en la esquina ss en nets de alto fanout. No son criterio de cierre; se trabajan en la rama exp/signoff. Archivos: `asic/rom/resultados/p1_t100/diagnostico_slew.txt`, `asic/exploraciones.md`.

## Sección 3.5

21. **¿Qué utilización se usó y hasta dónde se puede subir?** 40 % en la final (utilización real 48 % tras el buffering). 50 y 60 % cierran; 80 % falla en el placement detallado y 90 % pide más del 100 % del core. Archivo: `asic/final.md`, `docs/figuras/utilizacion.png`.
22. **¿Cuánto costaría el macro?** A US$23.000/mm², 0,409 mm² son US$9.406; la mínima que cierra baja a unos US$6.400 (60 %); la estrategia 2 costaría US$41.266. El modelo lineal ignora el mínimo de área de un lote multiproyecto, los pads, el empaque y el volumen. Archivo: `docs/datos_informe.md` (3.5).
23. **¿Qué decisión pesó más en área y costo?** La estrategia de memoria: 4,4 veces en die y costo. Después, la utilización. Archivos: D17, `asic/final.md`.
24. **¿Por qué los terminales están donde están?** Por función (D21): entradas al oeste con clk al centro, displays al este, LEDs al norte, SPI al sur, cada bus contiguo y en orden de bits, para que cada grupo vaya a pads vecinos sin cruces. Se midió el efecto contra la ubicación automática (u1_auto). Archivos: `asic/rom/pines.cfg`, D21.

## Sección 3.6 y 3.7

25. **¿Qué violación apareció durante el desarrollo y cómo se resolvió?** Una antena en la estrategia 2 (net `net3342`, Metal2 con razón de área lateral 1,12 veces el límite, en un net de 666 µm con cinco buffers). Se resolvió de dos formas: inserción heurística de diodos (0 violaciones, pero 36.385 diodos, 18 % más área y 16 ns menos de slack) y, mejor, más iteraciones y margen de la reparación de antenas del ruteo global (0 violaciones con 110 diodos y la misma área). Archivos: `asic/ff/resultados/s2_t100/layout/antena_antes.png`, `asic/ff/resultados/s2_t100_diodos/layout/antena_despues.png`, `antenna_summary.rpt` de ambas.
26. **¿Cómo marcaron el register file, la ALU y el contador en el layout?** Por nombre jerárquico de instancia en el DEF (`u_soc.u_core.u_rf/*`, `u_soc.u_core.u_id.u_alu/*`, `u_soc.u_periph.u_cycles/*`), con un script de KLayout en modo batch; se repite en la interfaz con la base de marcadores `bloques.lyrdb` o buscando instancias. Archivos: `asic/layout/anotar.py`, `docs/layout.md`.
27. **¿El GDS pasó un segundo DRC?** Sí: el deck de KLayout de GlobalFoundries (684 reglas) no marca nada sobre el GDS final; LibreLane lo salta porque el PDK de ciel no trae las reglas. Archivos: `asic/rom/resultados/final/drc_klayout/resumen.md`, `asic/drc/ORIGEN.md`.
28. **¿Cómo verificaron el netlist post-síntesis?** El mismo testbench de puertos y los mismos estímulos en ciclos absolutos para el RTL y el netlist: trazas idénticas, sin X; la ronda correcta mide 57 ciclos en los dos, la pulsación incorrecta muestra EE y la ronda no avanza. Archivos: `asic/sim/README.md`, `asic/sim/resultado.md`.
29. **¿Por qué CYCLES_PER_TENTH = 1 en esa simulación?** Para que el display muestre directamente los ciclos medidos y las esperas de segundos duren decenas de ciclos; es el mismo `game.s` con una constante pisada al ensamblar (opción `-D`), igual en las dos simulaciones. Archivo: `asic/sim/README.md`.

## RTL y assembler

30. **¿Cómo sabe el testbench qué botón apretar si el LED lo elige un LFSR?** Los estímulos se calibraron corriendo el RTL por etapas y leyendo en la traza qué LED se encendió y en qué ciclo; como el LFSR se siembra con CYCLES en la pulsación de inicio y todo es determinista, el netlist ve exactamente lo mismo. Archivo: `asic/sim/calibrar.py`.
31. **¿Por qué el assembler rechaza los shifts?** La ALU los ejecuta como suma; un programa con `sll` ensamblaría y correría mal. Por eso `game.s` desplaza sumando (`add x7, x7, x7`). Archivo: `docs/assembler.md`.
32. **¿Cuántos ciclos toma cada instrucción?** Dos (ciclo de espera del banco de registros de lectura sincrónica y ciclo de ejecución), tres las cargas y una burbuja extra los saltos tomados: CPI 2,67 en el juego. La rama exp/cpi ejecuta en un ciclo (CPI 1,31 en el juego). Archivos: `docs/memory_map.md`, `asic/exploraciones.md`.
