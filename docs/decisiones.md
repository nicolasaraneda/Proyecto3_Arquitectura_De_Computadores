# Decisiones del proyecto

Cada decisión registra las opciones, la elegida, la razón y lo que se pierde con la opción descartada.

## D1. Cómo se trajo el Proyecto 2 a este repositorio (25-10-2026)

- Opciones: (a) copiar los archivos en un commit inicial; (b) traer el historial completo con un merge del repositorio del Proyecto 2.
- Elegida: (b). El punto de partida es el commit `1227fa5` de `Vcalderone/Proyecto2_Arquitectura_De_Computadores`.
- Razón: `git diff 1227fa5` muestra exactamente qué se cambió para pasar de FPGA a ASIC, que es lo que se puede preguntar en la defensa.
- Qué se pierde: el repositorio arrastra los commits del Proyecto 2 y archivos propios de la FPGA (Makefile del iCE40, goboard.pcf, informe del Proyecto 2), que se ordenarán aparte.

## D2. Cómo se instala LibreLane (25-10-2026)

- Opciones: Nix o Docker.
- Elegida: Docker. LibreLane 3.0.16 instalado con pip en un entorno virtual (`~/herramientas/librelane`); las corridas usan `--dockerized`.
- Razón: lo hablamos con el profesor, y Nicolás ya usa Docker en otros dos proyectos.
- Qué se pierde: las herramientas corren dentro de un contenedor, y abrir KLayout u OpenROAD GUI desde ahí es más engorroso que con Nix.

## D3. Lectura del banco de registros en flip-flops (25-10-2026)

- Opciones: (a) lectura sincrónica, igual que la BRAM; (b) lectura combinacional.
- Elegida: (a).
- Razón: es un reemplazo directo de la BRAM por flip-flops; el ID stage y el controlador no cambian y cada instrucción toma los mismos ciclos que en el Proyecto 2. Verificado: los tres testbenches dan los mismos 101 checks en los mismos instantes que el commit 1227fa5.
- Qué se pierde: el ciclo de espera de lectura por instrucción y 64 flip-flops de salida.

## D4. Reset del banco de registros (25-10-2026)

- Opciones: (a) solo x0 fijo en 0 y x1 a x15 sin reset; (b) reset a 0 de los 15 registros.
- Elegida: (a).
- Razón: igual que en la BRAM, los registros no necesitan reset porque el juego escribe cada registro antes de leerlo. Verificado con un monitor sobre la simulación de game_tb: 0 valores desconocidos (X) usados en 388411 escrituras al banco.
- Qué se pierde: si un cambio futuro de game.s leyera un registro antes de escribirlo, su valor en silicio no estaría definido.

## D5. Dónde van los cambios de RTL (25-10-2026)

- Opciones: (a) en los mismos archivos de rtl/; (b) en una carpeta nueva.
- Elegida: (a).
- Razón: junto con D1, git diff 1227fa5 muestra cada cambio hecho para ASIC.
- Qué se pierde: el diseño deja de caber en la Go Board; para volver a la placa hay que usar el commit 1227fa5.
- Consecuencia: al crear asic_top se eliminaron rtl/game_top.v, goboard.pcf y los objetivos de síntesis y programación de la FPGA del Makefile.

## D6. Reset del macro (25-10-2026)

- Opciones: (a) rst_n externo activo en bajo con sincronizador de 2 flip-flops; (b) rst_n externo directo; (c) rst_n externo manteniendo el contador de 4096 ciclos.
- Elegida: (a).
- Razón: el contador del Proyecto 2 dependía del valor inicial que da la FPGA y existía por la BRAM, que ya no está. El sincronizador hace que todos los flip-flops salgan del reset en el mismo flanco.
- Qué se pierde: la espera de 164 µs al encender, que ya no protege nada.

## D7. SPI (25-10-2026)

- Opciones: (a) puertos presentes sin lógica, con MISO fijo; (b) instanciar pochoco_spi_slave.
- Elegida: (a).
- Razón: el juego no usa SPI, y el módulo está marcado como trabajo en progreso, con registros de otro proyecto; instanciarlo agrega área y lógica sin verificar.
- Qué se pierde: los puertos SPI quedan sin función y no se implementa el bootloader por SPI (opcional en el enunciado).

## D8. Polaridad de los 7 segmentos (25-10-2026)

- Opciones: (a) activos en alto en los puertos del macro; (b) activos en bajo, como en la Go Board.
- Elegida: (a).
- Razón: los puertos representan la función lógica (1 = segmento encendido); la inversión era propia del display de la Go Board.
- Qué se pierde: la salida deja de coincidir con la del Proyecto 2; un display activo en bajo necesitaría invertirla afuera.

## D9. Palabras de la RAM de datos (25-10-2026)

- Opciones: (a) 0 palabras, sin RAM de datos; (b) 4 palabras; (c) 64 palabras, el máximo recomendado.
- Elegida: (b), con el mismo valor en las dos estrategias (DataWords = 4).
- Razón: el juego usa 0 palabras de datos (0 lecturas y 0 escrituras en la simulación completa, y todos los lw y sw van a periféricos a través de x2). Cuatro palabras mantienen la RAM de datos que pide la estrategia 1 con un costo mínimo, y usar el mismo valor en la estrategia 2 hace que la comparación mida solo cómo se guarda el programa.
- Qué se pierde: 128 flip-flops que el juego no usa. Con (a), la estrategia 1 quedaría sin la RAM de datos que nombra el enunciado; con (c), la RAM dominaría el área de ambas estrategias.

## D10. Constantes del juego para el macro (25-10-2026)

- Opciones: (a) regenerar el programa para T = 100 ns antes de comparar las estrategias de memoria; (b) hacerlo al final, en la sección 3.4.
- Elegida: (a).
- Razón: las corridas de la comparación, y todas las siguientes, usan el mismo programa que correría el macro.
- Cálculo: f = 1/T = 1/100 ns = 10 MHz; una décima son 0,1 s × 10.000.000 ciclos/s = 1.000.000 ciclos. CLK_HZ = 10.000.000 y CYCLES_PER_TENTH = 1.000.000. ESPERA_TENTHS sigue en 30 (3 s) y el tiempo se sigue mostrando en décimas.
- Nota: el debounce sigue con DebounceDivBits = 15; a 10 MHz muestrea cada 3,3 ms y acepta un cambio en unos 10 ms, muy por debajo de la décima que se muestra.
- Qué se pierde: nada en las simulaciones, que ensamblan con CYCLES_PER_TENTH = 2500; en la imagen cambian 4 palabras.

## D11. Generación de la ROM (25-10-2026)

- Opciones: (a) el assembler genera solo la tabla (`game_image.vh`) y `pochoco_rom.v` es un envoltorio escrito a mano; (b) el assembler genera también el módulo `pochoco_rom.v` completo.
- Elegida: (b).
- Razón: el enunciado pide una ROM generada automáticamente por el assembler. Con (b) el módulo completo sale del assembler (opción `--rom`, en `rtl/gen/pochoco_rom.v`) y no queda ninguna parte de la ROM escrita a mano.
- Qué se pierde: un archivo generado más que mantener al día; lo cubre el mismo test que revisa la imagen.

## D12. Trazabilidad del register file, la ALU y el contador de ciclos (25-10-2026)

- Opciones: (a) conservar la jerarquía solo de esos tres módulos en la síntesis (`SYNTH_KEEP_HIERARCHY_MODULES`) y sacar el área de todos los módulos con una síntesis aparte sin aplanar; (b) no aplanar nada (`SYNTH_HIERARCHY_MODE: keep`); (c) seguir aplanando y rastrear las celdas por nombres de nets.
- Elegida: (a). Además, el contador de ciclos pasa a ser un módulo propio (`pochoco_cycle_counter`, instancia `u_soc.u_periph.u_cycles`), con el mismo comportamiento.
- Razón: con la síntesis aplanada las celdas quedan con nombres como `_9766_`, y así no se puede medir el área de cada bloque (3.3), nombrar el módulo de la ruta crítica (3.4) ni marcar los bloques en el layout (3.6). Conservar solo esos tres bordes mantiene la optimización del resto del diseño.
- Qué se pierde: la optimización a través de esos tres bordes, con un efecto chico en área y timing. Se decidió antes del barrido de timing para que el barrido y la corrida final sean el mismo circuito.

## D13. Frecuencia máxima de cada estrategia (25-10-2026)

- Opciones: (a) barrido de `CLOCK_PERIOD` para las dos estrategias; (b) estimar la estrategia 2 a partir del slack y barrer solo la estrategia final.
- Elegida: (a).
- Razón: el enunciado define la frecuencia máxima como el menor período que cierra timing en todas las esquinas, y advierte que cada período reoptimiza el circuito. Una estimación desde el slack no es un dato obtenido de las corridas.
- Qué se pierde: tiempo de máquina (unas tres corridas de unos 14 minutos para la estrategia 2).

## D14. Esquinas exigidas para cerrar timing (26-10-2026)

- Opciones: (a) la típica y la más lenta, que en la práctica significa las 9 esquinas que analiza LibreLane; (b) solo la típica, que es lo único que LibreLane trata como error por defecto en GF180 (TIMING_VIOLATION_CORNERS = *tt*).
- Elegida: (a). Pendiente de confirmar con el ayudante.
- Razón: el chip tiene que funcionar en el peor caso de proceso, voltaje y temperatura, y el enunciado pide la tabla de timing con la esquina típica y la más lenta. Una corrida cierra timing cuando el WNS de setup y de hold es mayor o igual a 0 y el TNS es 0 en la peor de las 9 esquinas (métricas timing__setup__ws, timing__setup__tns, timing__hold__ws y timing__hold__tns).
- Qué se pierde: la frecuencia máxima queda limitada por la esquina lenta. Como LibreLane solo marca como error la esquina típica, el cierre en las demás se verifica con las métricas de cada corrida y no con el mensaje final del flujo.

## D15. Celdas de retardo en el buffering (26-10-2026)

- Opciones: (a) excluirlas de la síntesis y del place and route (EXTRA_EXCLUDED_CELLS: gf180mcu_fd_sc_mcu7t5v0__dly*); (b) dejar la configuración del PDK, que no las excluye.
- Elegida: (a).
- Razón: con la configuración del PDK, el flujo usó 539 celdas de retardo como buffers de fanout y de puertos, y 12 quedaron en la ruta crítica. A 60 ns la estrategia 1 no cerraba en la esquina lenta (b1_t60: setup WS -7.686 ns); al excluirlas cierra (x1_t60_sindly: setup WS 6.764 ns), con DRC, LVS y antenas limpios.
- Qué se pierde: el barrido anterior (b1_* y b2_*) deja de representar el diseño y se repite; el arreglo de hold usa buffers comunes en vez de celdas de retardo.

## D16. Esquinas del resizer (26-10-2026)

- Opciones: (a) dejar el valor por defecto; (b) fijar RSZ_CORNERS a las esquinas lenta, típica y rápida.
- Elegida: (a).
- Razón: por sí solo, (b) no cambió el resultado (x2_t60_rszss sigue sin cerrar en la esquina lenta: setup WS -7.686 ns), y junto con D15 (x3_t60_ambos: setup WS 6.764 ns) no se diferencia de D15 sola (x1). Un cambio que no aporta no se agrega a la configuración.
- Qué se pierde: nada medible en el experimento.

## D17. Estrategia de memoria de la corrida final (26-10-2026)

- Opciones: (a) estrategia 1, ROM combinacional generada más RAM de datos de 4 palabras; (b) estrategia 2, memoria unificada en flip-flops.
- Elegida: (a).
- Razón: con la configuración corregida (barrido s1_* y s2_*, `asic/barrido.md`), a T = 100 ns la estrategia 1 ocupa 146.400 µm² de celdas en síntesis contra 693.901 µm² (4,7 veces menos), tiene 921 flip-flops contra 4.602, un die de 0,394 mm² contra 1,794 mm², cierra timing hasta 55 ns contra 62 ns (18,2 MHz contra 16,1 MHz) y no tiene violaciones de antena, mientras la estrategia 2 tiene 1 net con violación en todas sus corridas.
- Qué se pierde: la memoria unificada, donde datos e instrucciones comparten espacio y el programa se puede sobrescribir desde el puerto de datos. El juego no usa ninguna de las dos cosas.

## D18. Cambio de RTL para acortar la ruta crítica: pre-decodificación (26-10-2026)

- Ruta crítica de partida (s1_t55, esquina max_ss): del registro de instrucción (`u_soc.g_mem_rom.u_mem.a_rdata_o[4]`) al register file (`u_soc.u_core.u_rf/_2913_`), 55,1 ns: 4,1 ns hasta la salida del registro, 19,1 ns de decode (el opcode elige el operando B), 14,5 ns en la ALU (la comparación de SLT/SLTU llega al bit 0 del resultado, que es también la dirección de la LSU), 13,7 ns de alineación de la carga y write-back, y 3,7 ns de entrada al register file. Es el write-back de una carga. Funcionalmente es un camino falso (el resultado de un SLT nunca es la dirección de una carga), pero el análisis estático de timing lo cuenta.
- Opciones: (a) registrar en la LSU el offset de byte al emitir la carga, lo que saca el tramo de alineación de esta ruta; (b) pre-decodificar: registrar las salidas del decodificador en el ciclo en que cada instrucción espera la lectura del banco de registros, lo que saca el decode de todas las rutas de ejecución.
- Elegida: (b).
- Razón: el decode es el tramo más largo de la ruta (35 %) y está en todas las rutas de ejecución (cargas, saltos, SLT), así que la mejora no queda limitada por la ruta siguiente. Toda instrucción ya pasa un ciclo esperando el banco de registros con la instrucción estable, y el decodificador puede trabajar ahí sin cambiar los ciclos de ninguna instrucción.
- Verificación: los tres testbenches dan los mismos 101 checks en los mismos instantes, con las dos estrategias de memoria; `make equiv` corre `sw/isa_test.s` (todas las instrucciones que soporta el assembler) con el RTL de 116fa20 y con el nuevo, y las trazas de escrituras al banco de registros, accesos al bus y salidas son idénticas ciclo a ciclo (1.018 eventos por estrategia); el monitor de valores desconocidos no encontró ninguno usado en 388.411 escrituras al banco.
- Qué se pierde: unos 77 flip-flops más (síntesis genérica; el área real sale de las corridas), y la etapa de decode queda repartida en dos ciclos.

## D19. La corrida final incluye la pre-decodificación (26-10-2026)

- Opciones: (a) sí, si pasa la verificación; (b) no, la corrida final es s1_t100 y el cambio queda como experimento de la sección 3.4.
- Elegida: (a).
- Razón: la corrida final es el mejor diseño verificado, y la frecuencia máxima que se reporta es la del diseño que se entrega.
- Qué se pierde: se repite el barrido de la estrategia 1 cerca del nuevo límite, y las secciones 3.3, 3.6 y 3.7 se hacen sobre el diseño con pre-decodificación.

## D20. Configuración del flujo de la corrida final (26-10-2026)

- Opciones: (a) la configuración de D15 y D16 (p1: excluye solo las celdas de retardo, margen del resizer por defecto); (b) opción z1, excluir además `gf180mcu_fd_sc_mcu7t5v0__buf_1`; (c) opción z2, `PL_RESIZER_SETUP_SLACK_MARGIN = 10`; (d) opción z3, las dos juntas.
- Elegida: (d). `EXTRA_EXCLUDED_CELLS = gf180mcu_fd_sc_mcu7t5v0__dly*` y `gf180mcu_fd_sc_mcu7t5v0__buf_1`, `PL_RESIZER_SETUP_SLACK_MARGIN = 10`.
- Razón: buf_1 explicaba el 68 % de los nets con violación de slew y las cadenas de buffers de la ruta crítica; sin él y con margen, el diseño cierra a 32 ns (p1: 42 ns) y las violaciones de slew bajan de 2201 a 541.
- Qué se pierde: +0,6 % de área y las violaciones de capacitancia suben de 3 a 31, pendientes de B1.

## D21. Ubicación de los terminales por función (26-10-2026)

- Opciones: (a) dejar que el flujo ubique los terminales donde acorte los cables (`OpenROAD.IOPlacement`); (b) fijar la ubicación por función con `IO_PIN_ORDER_CFG` (`asic/rom/pines.cfg`).
- Elegida: (b). Oeste, entradas (clk al centro del lado, rst_n y btn[3:0]); este, displays (seg1[6:0] y seg2[6:0], cada bus contiguo y en orden de bits); norte, led[3:0]; sur, spi_sclk, spi_mosi, spi_cs_n y spi_miso.
- Razón: cada grupo iría a pads vecinos de un chip completo sin cruces, y el flujo de señales queda entrada, lógica, salida.
- Qué se pierde: la libertad del flujo para acortar cables (se mide en A4).

## D22. Exploraciones del bloque B en la corrida final (26-10-2026)

- Opciones: (a) ninguna, la corrida final queda como está; (b) incorporar B5 (register file con latches y clock gating); (c) incorporar B2 (offset de byte registrado en la LSU).
- Elegida: (a).
- Razón: la corrida final ya cumple todos los criterios con margen (setup 65,2 ns y hold 0,18 ns en la peor esquina a T = 100 ns; período mínimo 25 ns). B2 gana 1 ns a cambio de más violaciones de slew (546 a 672); B5 reduce 9,3 % el área de celdas pero agrega latches, clock gating y préstamo de tiempo, y su WNS de setup se reporta en 0,000 por convención; B4 baja el CPI a la mitad pero rinde 15 % menos en MIPS; las variantes de B1 mejoran slew y capacitancia, que no son criterio de cierre, a costa de área. Cada cambio adoptado amplía lo que el grupo debe defender sin cambiar el cumplimiento de ningún criterio.
- Qué se pierde: el 9,3 % de área de B5 y el nanosegundo de B2. Las exploraciones quedan documentadas en asic/exploraciones.md y en sus ramas exp/*.

## D23. Corrida final: mantener main o adoptar exp/candidata (28-10-2026)

**Elegida: (b), variante `exp/candidata-rc`.**

**Razón:** "Representa una ganancia en frecuencia y MIPS considerable, tomando en consideración el
área sacrificada."

La corrida final del Proyecto 3 pasa a ser el RTL de `exp/candidata` (lectura del banco de registros
y decodificación durante el fetch con el parámetro `EarlyRead`, banco write-through y el offset de
byte de la carga registrado en la LSU, B2) **más la configuración del modelo de cable del resizer**
(`LAYERS_RC` con los RC medidos por extracción) y la reparación post-GRT. El análisis completo, con
todas las tablas y los archivos de origen, está en `docs/propuesta_d23.md` y en `docs/modelo_cable.md`;
los datos de cada rama en `asic/exploraciones.md`.

### Nota sobre el límite de área de celdas (105 por ciento)

El límite de 105 por ciento del área de celdas estándar de `main` a 100 ns **era una regla de
selección que se fijó el grupo para esta sesión, no un criterio del enunciado**: el enunciado pide
cierre de timing, DRC, LVS y antenas, e informar área, frecuencia y costo, pero no fija un techo de
área. Ese límite es el único motivo por el que `docs/propuesta_d23.md` y `docs/modelo_cable.md`
descartaban la configuración del modelo de cable, y se levanta porque lo que el enunciado sí pide no
empeora:

- el **área del die no cambia**: 419.131 µm² (0,419 mm²), exactamente la misma de la candidata sin
  modelo de cable (`design__die__area` de `build/exp_candidata_rc/asic/rom/runs/co_rc_t100/final/metrics.json`
  y de `build/exp_candidata/asic/rom/runs/pa_b2_t100/final/metrics.json`). El die lo fija
  `FP_CORE_UTIL = 40` sobre el área de la síntesis, no el área que ocupan las celdas después del
  resizer;
- el **costo estimado tampoco cambia**: 0,419131 mm² por 23.000 dólares/mm² = 9.640 dólares, el
  mismo de la candidata (sección 3.5);
- lo que sube es la **utilización real del core**, de 47,9 a 53,5 por ciento
  (`design__instance__utilization`: 0,479898 en `asic/rom/resultados/v1_final/metrics.json`,
  0,478613 en la candidata y 0,535110 en `co_rc_t100`). Sigue muy por debajo del 91,8 por ciento
  con el que cierra la utilización real máxima medida después con esta misma configuración
  (`u2_u73`, `FP_CORE_UTIL = 73`), así que el área que gastan los buffers nuevos cabe en el die que
  ya estaba elegido. (Cuando se escribió esta nota el barrido de utilización con la configuración
  nueva todavía no existía y la referencia era el 90,3 por ciento de v1, `u1_u78`; el barrido
  posterior la confirmó.)

Dicho de otro modo: el área de celdas sube 14,4 por ciento (208.439 contra 182.265 µm²) pero el
chip que se fabrica y lo que cuesta son los mismos, y a cambio el período mínimo baja de 24,5 a
21,5 ns y el MIPS sube de 15,3 a 27,9. Esa es la "ganancia en frecuencia y MIPS considerable,
tomando en consideración el área sacrificada" de la razón de arriba.

### Fecha de corte y vueltas atrás

**Fecha de corte: 1-11-2026 a las 23:59.** Si a esa hora la `candidata-rc` integrada no cumple
todas las verificaciones y el cierre completo, se vuelve atrás en este orden:

1. **Primera vuelta atrás: `exp/candidata` con la configuración anterior** (el mismo RTL sin
   `LAYERS_RC` ni reparación post-GRT): período mínimo 25,5 ns, 39,2 MHz, 23,6 MIPS, 186.432 µm².
   Es un cambio de configuración, no de RTL, así que toda la verificación funcional sigue valiendo.
2. **Segunda vuelta atrás: `main` v1**, el estado de `main` antes de integrar, marcado con el tag
   `v1-final` (tag anotado `f868867`, que apunta al commit `d881583`) y con sus reportes copiados a `asic/rom/resultados/v1_final/`:
   período mínimo 24,5 ns, 40,8 MHz, 15,3 MIPS, 182.265 µm².

En cualquiera de los dos casos hay que reportarlo explícitamente.

- Contexto: la sesión del 27 y 28-10-2026 reabrió la optimización con una regla de selección fija
  (métrica principal MIPS = f máx / CPI del juego completo; período barrido hasta dejar 0,5 ns o
  menos entre el último período que cierra y el primero que no; límite de área de celdas estándar
  a 100 ns de 105 por ciento de la de `main`, y cierre completo a 100 ns y 40 por ciento de
  utilización; desempate por violaciones de max slew y de max capacitancia, potencia con actividad
  real y área). También corrigió dos cifras de `main` que valen para cualquier opción: el período
  mínimo es 24,5 ns y no 25 (`f1_t24p5` cierra con WNS 0,496 ns), es decir 40,8 MHz y 15,3 MIPS, y
  la utilización máxima que cierra es 78 por ciento, con un die mínimo de 0,216 mm² (`u1_u78`).
- La candidata (`exp/candidata`, desde `exp/pipeline-b2`, commit `be50893`): lectura del banco de
  registros y decodificación durante el fetch, con banco write-through y un parámetro del core
  (`EarlyRead`) que deja la temporización anterior para la estrategia 2 de memoria, más el offset
  de byte de la carga registrado en la LSU (B2). CPI del juego 1,665 contra 2,665; período mínimo
  25,5 ns contra 24,5; **23,6 MIPS contra 15,3 (+54 por ciento)**; área de celdas 186.432 µm²
  contra 182.265 (+2,3 por ciento); die 0,419 contra 0,409 mm²; cierra DRC, LVS, antenas y las 9
  esquinas de setup y hold a 100 ns y 40 por ciento. Verificación: `make check` PASS, `make equiv`
  funcional con las dos estrategias, `sw/hazard_test.s` nuevo con trazas equivalentes a las de
  `main`, dos mutaciones que las pruebas detectan, 0 valores desconocidos usados en 620.217
  escrituras al banco, `make post-synth` PASS con control negativo y revisión de un agente que no
  escribió ese código.

Opciones:

- **(a) Mantener `main` como corrida final** y presentar la candidata como la exploración
  principal de la sección 3.4, igual que D22 hace con el bloque B.
  - Consecuencias: el informe, las figuras y el banco de preguntas no cambian (salvo las dos
    cifras corregidas de arriba, que hay que corregir en cualquier caso). Riesgo cero a 14 días de
    la entrega.
  - Qué se pierde: el 54 por ciento de rendimiento medido y una sección 3.4 que hoy tendría la
    Ley de Hierro como eje (CPI, período y MIPS medidos en cuatro variantes del core).
- **(b) Adoptar la candidata como corrida final.**
  - Consecuencias: hay que rehacer las secciones 3.3 a 3.7 del informe con los números nuevos,
    regenerar cuatro figuras y revisar 46 respuestas de `docs/defensa.md`, de las que unas 25 cambian de cifra (la
    lista por pregunta está en `docs/propuesta_d23.md`, sección 8), y agregar al banco las preguntas nuevas
    sobre el write-through, los riesgos de datos y por qué B5 deja de convenir. El paquete de
    corridas y simulaciones que el informe necesita ya está hecho en la rama.
  - Qué se pierde: la frecuencia máxima baja de 40,8 a 39,2 MHz y el margen de hold de 0,178 a
    0,134 ns; las violaciones de max slew suben de 546 a 571; y se amplía lo que los tres
    integrantes tienen que poder defender.
- **(c) Adoptar solo parte.** Dos variantes razonables:
  - solo B2 (`exp/lsu-offset`, ya verificado en la sesión anterior): período mínimo 24 ns
    (41,7 MHz), 15,6 MIPS, 181.170 µm² (menos área que `main`), con un cambio de RTL de 16 líneas
    en la LSU. Toca solo las cifras de timing y de área del informe.
  - solo la configuración de signoff del frente C que entra en el límite de área
    (`sc_c30`: reparación post-GRT de diseño con márgenes de 30 por ciento): deja las violaciones
    de slew casi igual sobre el core actual, así que su efecto solo se nota sobre el RTL B2+B5;
    sobre `main` no aporta.
  - Consecuencias: cambios chicos y bien medidos, con poco impacto en el informe.
  - Qué se pierde: la métrica principal casi no se mueve (15,6 contra 23,6 MIPS de la candidata).

Lo que ya está decidido, independiente de esta decisión: las correcciones de las cifras de `main`
(período mínimo 24,5 ns y 40,8 MHz en la sección 3.4; utilización máxima 78 por ciento y área
mínima 0,216 mm² en la sección 3.5), y los resultados de verificación del frente D que no cambian
el diseño (simulación post-PnR con SDF en tres esquinas con Icarus y con Open Verilog CVC,
equivalencia formal entre el RTL y los netlists, y potencia con actividad real).

### Estado de la integración (28-10-2026)

La integración y sus verificaciones se registran en `docs/cambios_informe.md` y en el reporte de la
sesión. "v1" en todos los documentos quiere decir `main` antes de integrar, tag `v1-final`.
