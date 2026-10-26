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
