# Banco de preguntas de la defensa

Preguntas que el profesor o un ayudante pueden hacer a cualquiera de los tres sobre el
informe, el RTL, el assembler y el flujo. Cada respuesta está pensada para decirse en voz
alta en unos 20 segundos, con el dato y el archivo que la respaldan.

- **[B]** básica: lo que los tres tienen que poder responder sin mirar nada.
- **[A]** avanzada: va más allá del ramo (física, teoría de timing, flujo por dentro).
- Los números salen de `asic/final.md`, `asic/barrido.md`, `asic/sintesis.md`,
  `asic/exploraciones.md`, `asic/rom/resultados/*/metrics.json`, `docs/decisiones.md` y
  `docs/hechos_flujo.md`. Si un número de acá no calza con esos archivos, manda el archivo.

---

## 1. Corrida final y flujo

**1. [B] ¿Con qué versiones se hizo la corrida final?**
LibreLane 3.0.16 en Docker (imagen `ghcr.io/librelane/librelane:3.0.16`), PDK gf180mcuD
revisión `54435919`, biblioteca `gf180mcu_fd_sc_mcu7t5v0`, Yosys 0.62, OpenROAD dcf36133,
Magic 8.3.623, KLayout 0.30.7, Netgen 1.5.316. Dato: README, `asic/versiones.md`.

**2. [B] ¿Cómo se reproduce la corrida final?**
`make final` (`asic/final.sh`): corre `librelane --dockerized --pdk gf180mcuD
asic/rom/config.yaml --run-tag final`, verifica los criterios de cierre y regenera tablas,
síntesis, figuras, DRC de KLayout y la simulación post-síntesis. El programa se regenera
desde `game.s` con `make image`. Dato: README.

**3. [B] ¿Qué significa que la corrida "cierra"?**
Que LibreLane termina el flujo, DRC y LVS limpios, 0 nets con violación de antena, y WNS
≥ 0 y TNS = 0 de setup y de hold en las 9 esquinas (D14). Final: setup WNS 65,22 ns en
max_ss, hold WNS 0,18 ns en min_ff, TNS 0. Dato: `asic/rom/resultados/final/cierre.md`.

**4. [B] ¿Qué son WNS y TNS?**
El slack es el margen de una ruta: tiempo requerido menos tiempo de llegada. WNS (worst
negative slack) es el slack de la peor ruta; TNS (total negative slack) es la suma de los
slacks negativos de todos los puntos finales. WNS ≥ 0 dice que ninguna ruta falla, y TNS = 0
lo confirma: si una sola ruta fallara, TNS sería negativo.

**5. [B] ¿Por qué 9 esquinas si LibreLane solo marca error en la típica?**
El macro tiene que funcionar en el peor caso de proceso, voltaje y temperatura, y el
enunciado pide la típica y la más lenta. LibreLane solo trata como error `*tt*`
(`TIMING_VIOLATION_CORNERS`), así que el cierre en las demás se revisa con las métricas por
esquina en `asic/verificar_cierre.py`. Pendiente de confirmar con el ayudante (D14).

**6. [A] ¿Qué significa `max_ss_125C_4v50`?**
Tres cosas: `max` es la esquina de parásitos de las interconexiones (resistencia y
capacitancia máximas de los cables), `ss` el proceso lento-lento de los transistores NMOS y
PMOS, y `125C_4v50` la temperatura y el voltaje (125 °C, 4,5 V). Es la peor combinación para
setup: transistores lentos, voltaje bajo, calor y cables con más RC. `min_ff_n40C_5v50` es la
opuesta, la peor para hold.

**7. [B] ¿Qué es un macro y por qué los terminales no son pads?**
Un bloque de celdas estándar con terminales de metal en el borde (Metal3 al oeste y este,
Metal2 al norte y sur), que se integra dentro de un chip más grande. Un chip completo lo
rodearía de pads de I/O con protección ESD, buffers de salida capaces de mover un LED o un
display y entradas con histéresis. Dato: `rtl/asic_top.v`, figura `bloques.png`.

**8. [A] ¿Qué hace el flujo, en orden?**
Lint (Verilator), síntesis (Yosys con ABC) a celdas de la biblioteca, floorplan (tamaño del
die y filas), celdas de tap y de borde, red de alimentación, ubicación de terminales,
placement global, reparación de diseño (buffers por slew, capacitancia y fanout), placement
detallado, árbol de reloj (CTS), reparación de timing, ruteo global con reparación de
antenas, ruteo detallado, relleno, extracción de parásitos, STA en 9 esquinas, IR drop, y
signoff: GDS (Magic y KLayout), DRC, LVS (Netgen) y chequeo de antenas. Son 76 pasos y la
corrida final tarda unos 3 minutos; los más largos son el ruteo detallado (23 s), el DRC de
Magic (22 s) y el CTS (14 s). Varios se saltan (macros, obstrucciones, DRC de KLayout,
inserción heurística de diodos, equivalencia formal). Dato: `docs/hechos_flujo.md`, sección 12.

**9. [A] ¿Qué restricciones de timing le pone el flujo al diseño (la SDC)?**
No definimos una SDC propia, así que se usa la genérica de LibreLane con los valores del
PDK: reloj en `clk` con período 100 ns; retardo de entrada y de salida de 20 % del período
(20 ns) en todos los puertos menos el reloj, como si la lógica de afuera usara esa parte del
ciclo; entradas manejadas por un `inv_1` (el reloj por un `inv_4`); 72,91 fF de carga en
cada salida; incertidumbre de reloj 0,25 ns; transición del reloj 0,15 ns; derating de 5 %;
y límites de transición 3 ns, fanout 10 y capacitancia 0,2 pF. Dato: `docs/hechos_flujo.md`,
sección 1.

**10. [A] ¿Qué es el derating de 5 %?**
`set_timing_derate -early 0.95 -late 1.05`: el STA alarga 5 % los retardos de los caminos
que conviene suponer lentos y acorta 5 % los que conviene suponer rápidos. Cubre la
variación dentro del mismo chip (dos buffers iguales no son idénticos). Como se aplica
también al tramo de reloj común al lanzamiento y a la captura, hace falta CRPR para devolver
ese pesimismo (pregunta 43).

**11. [A] ¿El placement toma en cuenta el timing?**
No directamente: `PL_TIMING_DRIVEN = False`, y el placement global se guía por ruteabilidad,
con una densidad objetivo que el flujo calcula (53,3 %). El timing lo arreglan después el
resizer, que cambia tamaños y agrega buffers, y el CTS. Dato: `docs/hechos_flujo.md`,
sección 5.

**12. [A] ¿Qué es el chequeo XOR que aparece en las métricas?**
LibreLane escribe el GDS dos veces, con Magic y con KLayout, a partir del mismo layout, y
compara las dos geometrías con una operación XOR. `design__xor_difference__count = 0`: los
dos GDS son idénticos, así que no hay un error de una de las herramientas al escribirlo.

**13. [B] ¿Qué avisos quedan en la corrida final y por qué no importan?**
Tres pines SPI sin área de compuerta en el LEF (no llegan a ninguna compuerta, D7), VDD y
VSS "flotantes" para el resizer (los conecta la red de alimentación; LVS limpio) y
`VSRC_LOC_FILES` sin valor (posición de los pads para el IR drop: un macro no tiene pads; el
análisis igual corrió, con 0,15 mV de caída peor).
Dato: `asic/rom/resultados/final/avisos.md`.

---

## 2. Del RTL de FPGA al RTL de ASIC (3.1)

**14. [B] ¿Qué del Proyecto 2 no servía para un ASIC y cómo se supo?**
La BRAM `SB_RAM40_4K` del banco de registros (el linter la reporta como módulo inexistente,
`%Error-MODMISSING`), el contador de reset de encendido con valor inicial (`PROCASSINIT` y
`Set init value` en Yosys), el `$readmemh` dentro de un `initial` (Yosys lo convierte en
valor inicial de la memoria) y la RAM de 512 palabras, que sin BRAM se infiere en flip-flops
(17.188 flip-flops y 2,33 mm² de celdas en c0b). Dato: `asic/p2_original/evidencia.md`.

**15. [B] ¿Por qué un valor inicial es un problema en silicio si en la FPGA funcionaba?**
La FPGA carga el bitstream con los valores iniciales de cada flip-flop y BRAM. Un flip-flop
de la biblioteca no tiene valor de encendido: parte en 0 o en 1 según el ruido. Yosys
descarta el valor inicial sin error, así que el contador de reset partiría en cualquier
valor (reset de 0 a 4095 ciclos) y la RAM con instrucciones arbitrarias.

**16. [B] ¿Qué construcciones no dieron ningún mensaje del flujo?**
x0 = 0 dependía de que la BRAM partiera en cero (ahora se entrega 0 por hardware), los
segmentos invertidos para el display activo en bajo de la Go Board (ahora activos en alto,
D8), `CYCLES_PER_TENTH` calculado para 25 MHz (sección 3.4) y `DebounceDivBits = 15`
elegido para 25 MHz (se mantuvo, D10). Son valores o convenciones, no sintaxis.

**17. [B] ¿Cómo es el reset del macro?**
`rst_n` externo, activo en bajo, entra a un sincronizador de dos flip-flops en `asic_top`:
activa el reset en forma asíncrona (no necesita reloj) y lo libera en un flanco de reloj
(D6). Así todos los flip-flops salen del reset en el mismo ciclo.

**18. [A] ¿Qué pasaría si el reset se liberara directo desde el pin, sin sincronizar?**
Si la liberación cae cerca de un flanco de reloj, se violan los tiempos de recovery y
removal de los flip-flops con reset asíncrono: algunos salen del reset en ese flanco y otros
en el siguiente, o quedan metaestables. El PC y los registros de control arrancarían
desfasados. Con el sincronizador, la liberación viene de un flip-flop del mismo reloj y el
STA puede chequear esos tiempos como cualquier otra ruta.

**19. [A] ¿Por qué los botones pasan por dos flip-flops antes del debounce?**
Son asíncronos al reloj. Si un botón cambia justo en el flanco, el primer flip-flop puede
quedar metaestable (un voltaje intermedio) por un tiempo no acotado. El segundo le da un
ciclo completo para resolverse (100 ns a 10 MHz). El tiempo medio entre fallas crece
exponencialmente con ese tiempo de resolución, así que con un ciclo entero es astronómico.
Dato: `btn_meta` y `btn_sync` en `rtl/pochoco_periph.v`.

**20. [B] ¿Por qué el SPI está en los puertos si no hace nada?**
El enunciado pide el SPI entre los terminales del macro. El juego no lo usa y el esclavo SPI
del repositorio base está incompleto, así que no se instancia (D7): `spi_miso` queda fijo en
1 y las tres entradas no llegan a ninguna compuerta. El bootloader por SPI era opcional y
no se hizo.

---

## 3. Memoria y programa del juego (3.2)

**21. [B] ¿Cuántas palabras usa el juego y cómo lo saben?**
115 de instrucciones (460 bytes) y 0 de datos. Las 115 las cuenta el assembler (las imprime
y quedan como `GAME_WORDS`). Las 0 de datos: todos los `lw` y `sw` de `game.s` (19) usan
`x2`, la base de periféricos `0x8000_0000`, y la simulación de la partida completa no lee ni
escribe la memoria. Ambas bajo el máximo recomendado (256 y 64).

**22. [B] Si el juego usa 0 palabras de datos, ¿por qué hay una RAM de 4?**
La estrategia 1 nombra una RAM de datos; 4 palabras la mantienen por 128 flip-flops. Con el
mismo valor en las dos estrategias, la comparación mide solo cómo se guarda el programa (D9).

**23. [B] ¿Cómo entra el programa al silicio si no hay `$readmemh`?**
El assembler genera Verilog: `--rom` escribe `rtl/gen/pochoco_rom.v`, un `case` con una
palabra por dirección (la ROM combinacional de la estrategia 1), y `--vh` escribe
`rtl/gen/game_image.vh` con `GAME_WORDS` y `game_word(i)`, que la estrategia 2 usa como
valor de reset de cada palabra. `make image` regenera los dos; 7 pruebas
(`test_image.py`) revisan los generadores y que los archivos versionados coinciden con el
`.hex` y con el `game.s` actual.

**24. [B] ¿En qué se diferencian las dos estrategias?**
Estrategia 1: ROM combinacional para instrucciones, con un registro a la salida que mantiene
la lectura registrada de la RAM del P2, y RAM de datos aparte de 4 palabras. Estrategia 2:
memoria unificada de 115 + 4 = 119 palabras en flip-flops; el programa es el valor de reset,
así que cada bit es un flip-flop con reset o con set, y todo se puede reescribir desde el
puerto de datos, como en el P2.

**25. [B] ¿Qué dio la comparación?**
A 100 ns y con el mismo RTL: 146.400 contra 693.901 µm² de celdas de síntesis (4,7 veces),
921 contra 4.602 flip-flops, die de 0,394 contra 1,794 mm², período mínimo 55 contra 62 ns
(18,2 contra 16,1 MHz), 0 contra 1 net con violación de antena. Se eligió la 1 (D17).
Dato: `asic/barrido.md`.

**26. [A] ¿Por qué la ROM es tan barata comparada con los flip-flops?**
La ROM guarda 115 × 32 = 3.680 bits en 7.448 µm², unos 2 µm² por bit, porque la síntesis
minimiza la lógica: muchos bits son constantes por columna o comparten términos entre
palabras. En la estrategia 2 cada bit extra cuesta unos 149 µm² ((693.901 − 146.400) /
3.681): un flip-flop con reset o set, su mux de escritura por byte y su parte de los dos
muxes de lectura de 119 entradas (puerto de instrucciones y puerto de datos). La diferencia es de unas 70 veces por bit.

**27. [B] ¿Por qué la estrategia 2 además es más lenta?**
Su ruta crítica es igual a la de la 1 hasta la dirección que calcula la ALU, pero después
decodifica esa dirección sobre las 119 palabras (pasa por `lsu_addr[8]`, un bit que solo
importa para elegir palabra) hasta un flip-flop de la memoria. En la estrategia 1 esa
decodificación es de 4 palabras. Además el die es 4,6 veces más grande y los cables más
largos.

**28. [A] ¿Qué pasa si el PC se sale del programa?**
La ROM solo mira `addr_i[8:2]` (7 bits). Las palabras 115 a 127 entregan 0, que es una
instrucción ilegal: el decodificador deja todo en su valor por defecto (sin escritura al
banco, sin acceso a memoria, sin salto), así que actúa como un NOP. En `0x200` la dirección
vuelve a la palabra 0 y el programa reaparece. El juego nunca llega ahí.

**29. [A] ¿Por qué no usaron las SRAM que trae el PDK?**
El PDK trae macros `gf180mcu_fd_ip_sram` de 8 bits de ancho y 64 a 512 palabras. El
enunciado pide comparar ROM y flip-flops, el juego no usa datos, y el banco de registros
necesita dos lecturas de 32 bits por ciclo, que no calza directo con esos macros. Además un
macro duro agrega trabajo de floorplan (ubicarlo, conectarlo a la red de alimentación) y sus
propios modelos de timing.

**30. [A] ¿Una ROM "de verdad" no sería mejor que lógica?**
Una ROM de máscara (un arreglo de transistores programado por contactos o vías) es más densa
por bit, pero el PDK abierto no trae un generador de ROM. La ROM sintetizada es la opción
disponible con celdas estándar y, para 115 palabras, ocupa solo el 4,7 % del diseño.

---

## 4. Síntesis (3.3)

**31. [B] ¿Cuáles son las cinco celdas más usadas y qué las explica?**
`dffq_1` 804 (banco de registros 544 = 480 de almacenamiento + 64 de salida, memoria 192,
pre-decodificación 82, menos 14 que la síntesis elimina por ser constantes), `mux2_2` 759
(muxes de retención y árboles de lectura del banco), `nand2_1` 758 (lógica aleatoria de la
ALU, la LSU, los decodificadores y la ROM), `oai21_1` 309 y `clkinv_1` 284. Dato:
`asic/sintesis.md`.

**32. [B] ¿Por qué tantos `mux2_2`?**
La biblioteca no tiene flip-flops con habilitación. Un registro que se escribe solo a veces
se arma como `D = en ? d : Q`: un mux de retención por bit. En la síntesis jerárquica (968
`mux2_2`) son 480 en el banco, 160 en la memoria y 82 en la pre-decodificación, y el resto
son los árboles de lectura del banco y los muxes de operandos. La aplanada termina con 759
porque optimiza a través de los bordes de módulo.

**33. [B] ¿Qué módulo tiene más área y cuánto es el contador de ciclos?**
El banco de registros `u_soc.u_core.u_rf`: 73.656 µm², 46,6 % en la síntesis jerárquica y
48,4 % en la final. El contador `u_soc.u_periph.u_cycles`: 3.943 µm², 2,5 % (2,6 % en la
final), el 61 % son sus 32 flip-flops con reset y el resto el incrementador.

**34. [B] Si la síntesis aplana el diseño, ¿cómo midieron el área por módulo?**
La corrida final conserva la jerarquía solo de los tres módulos que pide el enunciado
(`SYNTH_KEEP_HIERARCHY_MODULES`, D12). Para el resto se sintetizó la misma configuración sin
aplanar (`SYNTH_HIERARCHY_MODE=keep`, corrida h2_t100, solo hasta Yosys), que informa cada
módulo. La aplanada sale 3,7 % más chica porque optimiza a través de los bordes de módulo.

**35. [B] ¿Coincidió con lo que esperaban?**
Sí en lo grueso: el banco de registros domina y los flip-flops son la celda más numerosa; el
conteo coincide con el RTL (818 sin reset y 186 con reset). No esperábamos el peso de los
muxes de retención (falta de flip-flops con habilitación) ni que `nand2_1` quedara a la par
de `mux2_2` (la ROM y la ALU se mapean sobre la compuerta más chica).

**36. [A] ¿Qué hace ABC y por qué aparecen tantas NAND2?**
ABC es la herramienta de Yosys que optimiza la lógica combinacional y la mapea a celdas de la
biblioteca. Con la estrategia de área elige la combinación de celdas que minimiza el área
total, y la NAND2 es la compuerta universal más chica: casi toda la lógica aleatoria cae en
ella y en compuertas compuestas como OAI21 (OR-AND-inversor) y AOI21 (AND-OR-inversor), que
hacen dos niveles de lógica en una sola etapa.

**37. [A] ¿Por qué el área pasa de 152.169 µm² en síntesis a 182.265 µm² en el layout?**
El layout agrega 2.466 celdas de tap (10.827 µm²) y 314 de borde (1.379 µm²), 636 buffers
de reparación de timing, el árbol de reloj (110 buffers y 26 inversores, que incluyen 61
cargas ficticias para equilibrarlo), y el resizer agranda celdas en las rutas lentas. Sin las de tap ni las de borde son 170.060 µm² de celdas lógicas. Dato:
`metrics.json` de la final.

---

## 5. Timing (3.4)

**38. [B] ¿Cuál es la frecuencia máxima y cómo la obtuvieron?**
40 MHz: el diseño cierra a 25 ns y no a 24 ns (falla por 0,004 ns en max_ss). Se barrió
`CLOCK_PERIOD` en 100, 32, 30, 26, 25 y 24 ns con el mismo RTL y la misma configuración (la
de 28 ns se cortó a los 40 minutos y no cuenta).
Dato: `asic/final.md`, `asic/rom/resultados/f1_t25/cierre.md`.

**39. [B] ¿Por qué dicen que cada `CLOCK_PERIOD` reoptimiza el circuito?**
El resizer cambia tamaños de celdas y agrega buffers según el período: el área va de 182.265
µm² a 100 ns a 189.817 µm² a 26 ns. De 26 ns para abajo el layout es idéntico y solo cambia
el slack: el resizer ya no encuentra más que mejorar.

**40. [B] ¿Cuál es la ruta crítica?**
A 25 ns en max_ss: empieza en `_4189_`, el flip-flop de pre-decodificación que guarda
`alu_operator[1]` (etapa ID), cruza la ALU hasta `lsu_addr[1]`, la alineación del dato
cargado en la LSU y el mux de write-back (`rf_wdata[11]`), y termina en
`u_soc.u_core.u_rf/_2933_`, un bit del banco. Funciones: ejecución, acceso a memoria y
write-back de una carga. Dato: `asic/rom/resultados/f1_t25/layout/ruta_critica.txt`.

**41. [B] ¿Cómo se reparte el tiempo en esa ruta?**
Árbol de reloj hasta el flip-flop 2,66 ns, reloj a Q 2,34 ns, ALU 9,50 ns (9 celdas),
alineación y write-back 9,74 ns (12 celdas), entrada al banco 1,55 ns: llega a 25,78 ns. La
ALU y la alineación se reparten la ruta casi por mitades.

**42. [A] ¿Cómo se calcula el slack de 1,00 ns de esa ruta?**
Tiempo requerido = período (25) + latencia del reloj de captura (2,32) + corrección por
reconvergencia (0,11) − incertidumbre (0,25) − setup del flip-flop (0,40) = 26,78 ns.
Llegada = 25,78 ns. Slack = 26,78 − 25,78 = 1,00 ns. Dato:
`asic/rom/resultados/f1_t25/max_ss_125C_4v50_ruta_critica.rpt`.

**43. [A] ¿Qué es la corrección por reconvergencia (CRPR)?**
El reloj de lanzamiento y el de captura comparten el primer tramo del árbol (`clkbuf_0_clk`).
Con variación en el chip, el STA toma ese tramo lento para un camino y rápido para el otro,
lo que es físicamente imposible porque es el mismo buffer. CRPR devuelve esa diferencia
(0,11 ns en esta ruta).

**44. [A] ¿Qué es la incertidumbre de reloj de 0,25 ns?**
Un margen que se resta al tiempo disponible para cubrir jitter del reloj y efectos no
modelados. LibreLane la escribe en la SDC con el valor del PDK
(`CLOCK_UNCERTAINTY_CONSTRAINT = 0,25`) y aparece en cada reporte de ruta.

**45. [A] ¿Qué es el skew y cuánto hay?**
La diferencia de llegada del reloj a dos flip-flops. En la ruta crítica el reloj llega 0,34
ns más tarde al de lanzamiento (2,66 ns) que al de captura (2,32 ns), lo que le quita margen
de setup; CRPR devuelve 0,11 ns de esa diferencia, porque parte es pesimismo del análisis.
Por esquina, el skew de setup va de 0,36 ns (min_ff) a 0,57 ns (max_ss) y el de hold de
−0,43 a −0,79 ns (`clock__skew__worst_*__corner:*` en `metrics.json`).

**46. [A] ¿Por qué el setup se complica en ss y el hold en ff?**
Setup falla si el dato llega tarde: peor con transistores lentos, voltaje bajo, 125 °C y
cables con más RC (max_ss). Hold falla si el dato llega demasiado pronto y pisa al anterior:
peor con todo rápido (min_ff, −40 °C, 5,5 V). Por eso el peor setup es max_ss (65,22 ns a
100 ns) y el peor hold es min_ff (0,18 ns).

**47. [A] ¿El hold depende del período?**
No: el chequeo de hold compara el dato con el mismo flanco que lo lanzó, así que el período
no aparece en la ecuación. Por eso el hold es igual (0,18 ns) en todas las corridas del
barrido. El flujo lo arregla agregando retardo en las rutas cortas: la final tiene 5 buffers
de hold.

**48. [A] ¿La ruta crítica es real?**
Para el STA es de un ciclo, pero en una carga el dato de memoria llega un ciclo después de
emitirla, con el pipeline detenido y la dirección estable. En la práctica tiene dos ciclos.
Registrar los dos bits bajos de la dirección al emitir la carga (B2) la saca de la ruta sin
cambiar el comportamiento, y el período baja a 24 ns.

**49. [A] ¿Por qué no declarar esa ruta como multiciclo en la SDC?**
Una excepción de timing le dice al STA que no revise algo; si está mal escrita oculta una
falla real que ninguna simulación sin retardos detecta. Además la misma ALU alimenta el
write-back de un ADD en un solo ciclo, así que la excepción tendría que pasar solo por la
alineación. Cambiar el RTL (B2) es más seguro: el STA sigue revisando todo.

**50. [B] ¿Qué cambio de RTL hicieron para acortar la ruta?**
Pre-decodificación (D18). Toda instrucción pasa un ciclo esperando la lectura sincrónica del
banco de registros con la instrucción ya estable. En ese ciclo se registran las 82 salidas
del decodificador (operación y operandos de la ALU, inmediatos, señales de salto, LSU y
write-back), y en el ciclo de ejecución el decode ya no está en la ruta. Ningún ciclo cambia.

**51. [B] ¿Por qué el decode y no otra parte?**
En la ruta de partida (s1_t55) el decode era el tramo más largo: 19,1 de 55,1 ns. Además
está en todas las rutas de ejecución (cargas, saltos, SLT), así que sacarlo mejora todas, no
solo la peor.

**52. [B] ¿Cuánto rindió y cuánto costó?**
Con la configuración de D15: período mínimo de 55 a 42 ns y 13,0 ns más de slack a 100 ns.
Con la final: 10,7 ns más de slack a 100 ns, y sin pre-decodificación el diseño no cierra a
26 ns (WNS −3,18 ns). Cuesta 4,4 % de área (69 flip-flops más tras la síntesis y sus muxes).
Dato: `asic/barrido.md`, `asic/final.md`.

**53. [B] ¿Cómo verificaron que no cambió el comportamiento?**
`make equiv` corre `sw/isa_test.s` (todas las instrucciones del assembler) con el RTL
anterior (116fa20) y el nuevo: escrituras al banco, accesos al bus y salidas idénticos ciclo
a ciclo (1.018 eventos por estrategia). Además los tres testbenches dan los mismos 101 checks
en los mismos instantes, y un monitor no encontró valores X usados en 388.411 escrituras al
banco.

**54. [A] ¿Por qué los registros de pre-decodificación no tienen reset?**
Todo lo que los usa está condicionado a `ops_valid_q` (que es 0 en el ciclo de espera) o a
`commit`, y en ese ciclo de espera ya se cargan con la instrucción actual. Nunca se lee un
valor sin cargar, y sin reset son `dffq_1`, más chicos que `dffrnq_1`.

**55. [B] El período mínimo bajó de 42 a 25 ns con el mismo RTL. ¿Qué cambió?**
La configuración del flujo (D20): se excluyó `buf_1` y se le pidió al resizer un margen de
setup de 10 ns. Con eso deja de entregar el mismo circuito en todos los períodos y optimiza
de verdad; las violaciones de slew bajaron de 2.201 a 546. Antes, sin pre-decodificación,
excluir las celdas de retardo `dly*` (D15) había llevado el diseño de no cerrar a 60 ns
(WNS −7,69 ns, 12 celdas `dly` en la ruta crítica) a cerrar a 55 ns.

**56. [A] ¿Qué hace `PL_RESIZER_SETUP_SLACK_MARGIN`?**
Le dice al resizer que repare rutas hasta dejarlas con ese margen de setup (por defecto
0,05 ns); actúa en la reparación de timing después del árbol de reloj
(`ResizerTimingPostCTS`). La causa probable de que antes no hiciera nada es que trabaja con
parásitos estimados antes del ruteo, más optimistas que los extraídos al final, así que con
0,05 ns veía todo cumplido. Con 10 ns trabaja con colchón y el STA final, con parásitos
reales, cierra. Es una explicación, no una medición: el repo no tiene un reporte que la
pruebe.

**57. [A] ¿Por qué las celdas de retardo empeoraban el timing?**
Están hechas para tener un retardo grande a propósito: sirven para arreglar hold alargando
rutas cortas. Usadas como buffers de fanout en rutas largas, agregan retardo justo donde falta tiempo.

**58. [A] ¿Por qué `buf_1` causaba violaciones de slew?**
Es el buffer más débil: su corriente de salida es baja, así que con cables largos o mucha
carga la transición es lenta. Explicaba el 68 % de los nets con violación de slew.

**59. [B] ¿Qué son las 546 violaciones de max slew y por qué no son un problema de cierre?**
Pines donde la transición de la señal supera 3 ns, el límite que pone la SDC. No es
criterio de cierre del enunciado. La peor es 5,41 ns en la esquina lenta, donde el liberty
admite hasta 7 ns por pin; el de la esquina típica admite 4 ns. El timing ya las considera,
porque el retardo de cada celda se calcula con su slew de entrada.

**60. [A] ¿Cómo calcula el STA el retardo de una celda?**
Con tablas del liberty indexadas por el slew de entrada y la capacitancia de salida (modelo
NLDM): para cada combinación hay un retardo y un slew de salida, y el STA interpola. Por eso
un slew lento en una entrada alarga el retardo de la celda siguiente y se propaga.

**61. [A] ¿Qué dice el liberty de un `dffq_1`?**
Mide 16,24 × 3,92 µm (63,66 µm²). En la esquina típica, setup 0,21 a 0,23 ns, hold 0,05 a
0,08 ns y reloj a Q 1,0 a 1,3 ns; en la lenta, setup 0,44 a 0,47 ns y reloj a Q 1,8 a 2,3 ns
(para transiciones y cargas parecidas a las del diseño). En la ruta crítica el reporte da
0,40 ns de setup y 2,34 ns de reloj a Q, con su carga real y el derating. Dato:
`docs/hechos_flujo.md`, sección 11.

**62. [B] ¿Qué constantes de `game.s` cambian para T = 100 ns?**
f = 10 MHz, así que una décima son 0,1 s × 10.000.000 = 1.000.000 ciclos: `CLK_HZ =
10000000` y `CYCLES_PER_TENTH = 1000000`. `ESPERA_TENTHS = 30` sigue siendo 3 s. Cambian
cuatro palabras de la ROM: los dos `li x12, CYCLES_PER_TENTH` de `cyc2tenths` y
`wait_tenths`, cada uno `lui x12, 0xf4` + `addi x12, x12, 576`.

**63. [A] ¿Y si el macro corriera a 40 MHz?**
`CYCLES_PER_TENTH = 4000000 = 0x3D0900`. Los 12 bits bajos (`0x900`) tienen el bit 11 en 1,
así que `addi` los leería negativos: el assembler sube la parte alta a `0x3D1` y usa `addi
−1792`. A 10 MHz eso no pasa (`0x240` tiene el bit 11 en 0). El debounce muestrearía cada
0,82 ms y CYCLES daría la vuelta cada 107 s.

**64. [A] ¿Qué pasa cuando CYCLES da la vuelta?**
A 10 MHz pasa cada 2³² × 100 ns ≈ 429 s. La duración es una resta de 32 bits módulo 2³², que
da bien aunque haya una vuelta entre las dos lecturas, y las comparaciones usan `bltu` (sin
signo). Falla solo si una espera dura más de 429 s.

**65. [B] ¿Probaron otros cambios de RTL?**
Sí, en ramas `exp/*` con la configuración final. B2 (offset de byte de la carga registrado)
cierra a 24 ns con 0,6 % menos de área. B3 (comparador de saltos desde el banco) no mueve el
período porque el salto no era la ruta crítica. B4 (una instrucción por ciclo) baja el CPI
de 2,665 a 1,312 pero el período sube a 60 ns. Ninguno entró a la final (D22). Dato:
`asic/exploraciones.md`.

**66. [B] Si B4 baja el CPI a la mitad, ¿por qué es peor?**
Ley de Hierro: tiempo = instrucciones × CPI × T, o MIPS = f / CPI. B4: 16,7 MHz / 1,312 = 12,7
MIPS. Final: 40 MHz / 2,665 = 15,0 MIPS. Al juntar todo en un ciclo (PC, ROM, decodificador,
lectura del banco, ALU y write-back) el período sube 2,4 veces, más de lo que baja el CPI.

**67. [B] ¿Por qué no incorporaron B2 si es más rápido?**
La final ya cumple todos los criterios con margen (65 ns de slack a 100 ns), y B2 gana 1 ns
a cambio de más violaciones de slew (546 a 672). Cada cambio adoptado es más lógica que
verificar y defender sin cambiar ningún criterio (D22).

**68. [A] ¿Qué era B5 y por qué reporta WNS 0,000?**
Banco de registros con latches `latq_1` en vez de flip-flops con mux, y una celda de clock
gating `icgtp_1` por registro: −9,3 % de área y slew/capacitancia de 546/36 a 312/2. Un latch
es transparente mientras el reloj está alto, así que un dato que llega tarde "toma prestado"
tiempo de la fase siguiente (3,38 ns). OpenSTA reporta slack 0 en los latches mientras quede
préstamo; el margen real se lee en las rutas a flip-flops.

**69. [A] ¿Qué es una celda de clock gating y por qué tiene un latch?**
Apaga el reloj de un registro cuando no se escribe (ahorra el mux de retención y la potencia
del reloj). Si se hiciera con una AND directa, un cambio del enable con el reloj alto
cortaría el pulso y generaría glitches. La celda integrada captura el enable en un latch
transparente con el reloj bajo, así que el enable queda quieto mientras el reloj está alto.

**70. [B] ¿Cuántos ciclos toma cada instrucción?**
Dos la mayoría (un ciclo de espera de la lectura sincrónica del banco y uno de ejecución),
tres las cargas (esperan el dato registrado de la memoria o del periférico), y los saltos
tomados dejan una burbuja de un ciclo. CPI del juego completo: 2,665.

**71. [A] ¿Con qué resolución mide el juego el tiempo de reacción?**
En el macro manda el debounce: la salida filtrada solo cambia en un tick, cada 2¹⁵ ciclos
(3,28 ms a 10 MHz), y además agrega una latencia fija de unos 10 a 13 ms. El lazo de polling
`wait_press` dura 13 ciclos por cualquiera de sus dos caminos (con o sin realimentación del
LFSR), 1,3 µs, mucho menos que el tick. En la simulación, con un tick cada 4 ciclos, el lazo
sí se nota: un atraso de 5 ciclos no cambia la traza y uno de 6 la cambia en 13 ciclos (57 a
70). El resultado se trunca a décimas y satura en 99.

---

## 6. Floorplan, red de alimentación y placement (3.5)

**72. [B] ¿Qué utilización usaron y cuál es el área mínima?**
40 % en la final (lo fija el enunciado; utilización real 48 %). Cierran 50, 60 y 70 %; 80 %
falla en el placement detallado del CTS (`DPL-0036`) y 90 % en el placement global
(`GPL-0301`). Mínima: 70 %, die de 480,0 × 497,9 µm, 0,239 mm². Dato: `asic/final.md`.

**73. [B] ¿Por qué la utilización real es mayor que la pedida?**
El core se dimensiona con el área de síntesis dividida por la utilización (152.169 / 0,40 ≈
380.000 µm²). Después se agregan celdas de tap, buffers del resizer y el árbol de reloj, y la
real sube 8 a 11 puntos.

**74. [A] ¿Por qué fallan 80 y 90 %?**
A 90 % las celdas móviles (163.776 µm²: las 152.353 µm² de la síntesis más 11.422 µm² que el
placement global suma como ajuste por densidad de pines) ocupan más que el espacio libre del
core: `GPL-0301 Utilization 100.531 % exceeds 100%`. A
80 % el placement global pasa, pero tras insertar el árbol de reloj el placement detallado
no encuentra sitios legales para algunas celdas (del banco de registros, buffers de fanout y
de salida). Dato: `asic/rom/resultados/u1_u80/falla.txt` y `u1_u90/`.

**75. [B] ¿Qué métrica de congestión graficaron?**
Violaciones de DRC al inicio del ruteo detallado, largo de cables, slew, capacitancia,
antenas, área del die y WNS (`docs/figuras/utilizacion.png`). Las violaciones de ruteo
iniciales no siguen tendencia (1.546, 2, 5 y 2.149) y el router las lleva a 0 en todas; la
señal que decide el límite es que a 80 % ya no hay lugar para las celdas.

**76. [B] ¿Por qué los terminales están donde están?**
Por función (D21, `asic/rom/pines.cfg`): entradas al oeste (botones, `clk` al centro, `rst_n`),
displays al este (cada bus contiguo y en orden de bits), LEDs al norte, SPI al sur. Cada
grupo iría a pads vecinos sin cruces y las señales entran por un lado y salen por el
opuesto. Comparado con dejarlos al flujo (u1_auto): +0,4 % de cable, mismo WNS.

**77. [A] ¿Por qué Metal3 en los lados y Metal2 arriba y abajo?**
Cada capa tiene una dirección preferida de ruteo, alternada: Metal1 horizontal, Metal2
vertical, Metal3 horizontal, Metal4 vertical, Metal5 horizontal (tech LEF). Un terminal en
el lado oeste o este sale horizontal, así que va en Metal3; uno arriba o abajo sale vertical,
en Metal2. Se rutea de Metal2 a Metal5; Metal1 queda para el interior de las celdas y los
rieles.

**78. [B] ¿Cuánto costaría y qué limita esa estimación?**
A US$23.000/mm²: final 0,409 mm² → US$9.406; 70 % → US$5.496; estrategia 2 (s2_t100, con la
configuración de D15) → US$41.266. El
modelo lineal ignora el cupo mínimo de una oblea multiproyecto, pads, anillo de sello,
encapsulado, máscaras (costo fijo), volumen y rendimiento de fabricación.

**79. [A] ¿Por qué el costo real crece más que lineal con el área?**
Costo por die = costo de la oblea / (dies por oblea × rendimiento). Con más área caben menos
dies por oblea y además baja el rendimiento, porque la probabilidad de que un defecto caiga
en el die crece con el área (rendimiento ≈ 1 / (1 + densidad de defectos × área / N)^N). Las
dos cosas se multiplican.

**80. [B] ¿Qué decisión pesó más en área y costo?**
La estrategia de memoria: con el mismo RTL y configuración, la 2 necesita un die 4,6 veces
mayor. Después la utilización: de 40 a 70 % el die baja 42 %. Pre-decodificación y
configuración del flujo suman 5 % de área de celdas (3,9 % de die).

**81. [A] ¿Cómo es la red de alimentación?**
Rieles de VDD y VSS de 0,6 µm en Metal1 a lo largo de cada fila (las celdas los comparten),
y una grilla de franjas de 1,6 µm: 8 verticales en Metal4 cada 153,6 µm y 8 horizontales en
Metal5 cada 153,2 µm, unidas a los rieles por vías. No hay anillo alrededor del core. La
caída de tensión peor, en la esquina típica, es 0,15 mV en VDD y 0,25 mV en VSS: nada frente
a 5 V, porque el macro consume unos 9 mW (menos de 2 mA). Dato: `docs/hechos_flujo.md`,
sección 4.

**82. [A] ¿Para qué sirven las 2.466 celdas de tap?**
Conectan el pozo N a VDD y el sustrato a VSS cada 20 µm (`filltie`, `FP_TAPCELL_DIST`). Sin ellas, una
inyección de corriente puede encender el tiristor parásito (PNPN) que forman los
transistores de un inversor CMOS con el pozo y el sustrato: latch-up, un cortocircuito entre
VDD y VSS que se mantiene solo. Las celdas de borde (314) cierran las filas en los extremos.

**83. [A] ¿Y las 12.152 celdas de relleno?**
Llenan los huecos entre celdas para que los pozos, los implantes y los rieles sean continuos
a lo largo de cada fila. Son 5.541 de relleno simple (`fill_1`, `fill_2`) y 6.611 de
desacople (`fillcap_4` a `fillcap_64`): capacitores entre VDD y VSS que entregan carga local
en los picos de corriente del reloj. Ninguna tiene función lógica; ocupan 197.535 µm².

**84. [A] ¿Cuánta potencia consume y de qué depende?**
8,97 mW a 10 MHz en la esquina típica: 7,02 mW interna (cortocircuito y nodos internos de las
celdas), 1,95 mW de conmutación de las cargas y 1,9 µW de fuga. A 40 MHz (f1_t25) son 35,8
mW: cuatro veces, porque la potencia dinámica es α·C·V²·f y la fuga es despreciable en 180
nm. Ojo: los 11,3 mW de `metrics.json` son de la esquina rápida (max_ff, 5,5 V), la última
que procesa el flujo. Dato: `power.rpt` por esquina en `docs/hechos_flujo.md`, sección 10.

**85. [A] ¿Ese número es la potencia real?**
Es una cota inferior. El flujo no recibe actividad de conmutación (ni VCD ni SAIF), así que
casi todo lo que estima es el reloj: flip-flops 58,6 % y árbol de reloj 41,3 %, mientras la
lógica combinacional sale en 3 µW. Para un número real habría que simular el juego, guardar
la actividad y dársela al análisis de potencia. La fuga sí cambia con la temperatura: 1,9 µW
a 25 °C y 12,3 µW en la esquina lenta, a 125 °C.

**86. [A] ¿Cómo es el árbol de reloj?**
Un H-tree con raíz `clkbuf_16`: 75 buffers en 3 niveles (66 `clkbuf_8` y 9 `clkbuf_16`) para
990 flip-flops, más 61 cargas ficticias que equilibran las ramas. La latencia del reloj va de
1,25 a 1,48 ns en la esquina típica y de 2,26 a 2,70 ns en max_ss. Dato:
`docs/hechos_flujo.md`, sección 6.

**87. [A] ¿Cómo se obtienen los parásitos que usa el STA?**
Después del ruteo, OpenROAD extrae la resistencia y la capacitancia de cada cable con las
reglas del PDK para tres esquinas de interconexión (min, nom, max) y escribe tres archivos
SPEF; cada una de las 9 esquinas de STA lee el de su grupo. Antes del ruteo el flujo solo
puede estimarlos.

---

## 7. Signoff y layout (3.6)

**88. [B] ¿Qué resultados de signoff tienen?**
DRC de Magic 0, DRC de KLayout con el deck de GlobalFoundries 0 marcadores en 684 reglas,
LVS 0 diferencias, 0 nets con violación de antena. Dato: `cierre.md`, `drc_klayout/`.

**89. [B] ¿Qué compara el LVS?**
Netgen compara el circuito extraído del layout (transistores y conexiones que Magic saca del
GDS) con el netlist del diseño con sus conexiones de alimentación. Si coinciden, el layout es
el circuito que se sintetizó: no hay cortos, cables abiertos ni celdas cambiadas.

**90. [B] ¿Por qué dos DRC y cómo saben que el de KLayout funciona?**
LibreLane salta el DRC de KLayout porque la copia del PDK que instala ciel no trae las
reglas (`asic/drc/ORIGEN.md`); se corrió aparte el deck de GlobalFoundries. Control
positivo: a una copia del GDS se le agregó un trazo de Metal1 de 0,20 µm y dos separados por
0,15 µm (mínimos 0,23 µm), y el deck marcó exactamente esas dos violaciones (M1.1 y M1.2a).
Dato: `drc_klayout/control_positivo.md`.

**91. [B] ¿Qué violación apareció durante el desarrollo?**
Una antena en la estrategia 2 (todas sus corridas). En s2_t100, el net `net3342` reparte una
señal de alto fanout entre cinco buffers y cubre 666 × 364 µm; en el pin `fanout3341/I` la
razón entre el área lateral del Metal2 conectado (sus paredes: perímetro por espesor) y el
área de la compuerta es 449,1, 1,12 veces el máximo de 400. La razón de área de la cara
superior (116,3) no tiene límite en esa capa. Dato: `asic/ff/resultados/s2_t100/antenna_summary.rpt`, `antena_antes.png`.

**92. [A] ¿Qué es el efecto antena?**
Al fabricar, cada capa de metal se graba con plasma, que deposita carga en el metal. Si un
tramo largo está conectado solo a compuertas (óxido delgado) y todavía no a ninguna difusión
que la descargue, la carga se acumula y puede romper el óxido. La regla limita el área de
metal (de su cara o de sus paredes, según la capa) por área de compuerta.

**93. [B] ¿Cómo la resolvieron?**
Dos formas. Inserción heurística de diodos: 0 violaciones, pero 36.385 celdas de antena, 18 %
más área y 16 ns menos de slack. Más iteraciones y margen en la reparación de antenas del
ruteo global (`GRT_ANTENNA_REPAIR_ITERS = 6`, `GRT_ANTENNA_REPAIR_MARGIN = 30`): 0
violaciones con 258 celdas de antena en vez de 150 y sin más área. La estrategia 1 nunca la
tuvo.

**94. [A] ¿Cómo arregla un diodo la antena, y qué otra opción hay?**
El diodo de antena es una unión en inversa conectada al net: en operación no conduce, pero
durante la fabricación le da a la carga un camino a sustrato. La otra opción es el "jumper":
cortar el tramo largo y pasarlo por una capa superior, para que la compuerta quede conectada
al metal largo recién cuando se fabrica esa capa.

**95. [A] ¿Por qué no hay figura del net después de reparar?**
En las corridas reparadas el net con el mismo nombre (`net3342`) es otro: los diodos y los
buffers extra renumeran los nets. Se comparó qué celdas conecta en cada DEF y no coincide,
así que se borraron esas figuras y la evidencia del arreglo son los `antenna_summary.rpt` con
0 violaciones.

**96. [B] ¿Cómo marcaron el register file, la ALU y el contador en el layout?**
Sus celdas conservan el nombre de la instancia como prefijo en el DEF (`u_soc.u_core.u_rf/`,
`u_soc.u_core.u_id.u_alu/`, `u_soc.u_periph.u_cycles/`). Un script de KLayout
(`asic/layout/anotar.py`) colorea cada prefijo y genera `bloques.png` y `bloques.lyrdb` para
repetirlo en la interfaz (`docs/layout.md`).

**97. [B] ¿Por qué el register file mide 78.186 µm² en la figura y 73.656 µm² en la síntesis?**
El resizer agrega buffers dentro del módulo en el layout. Los porcentajes de la figura (46 %,
6,2 % y 2,3 %) son sobre 170.060 µm² de celdas lógicas, sin las de tap ni las de borde.

**98. [A] ¿Por qué el ruteo detallado parte con 1.546 violaciones y termina en 0?**
El ruteo detallado es iterativo: la primera pasada rutea todo aunque queden cortos y
separaciones mal, y las siguientes rerutean las zonas con problemas. Con el orden fijo de
terminales (D21) la primera pasada parte con más conflictos (1.546 contra 6 sin orden) y en
la iteración 3 llega a 0.

---

## 8. Simulación post-síntesis (3.7)

**99. [B] ¿Cómo simularon el netlist?**
`make post-synth`: el mismo testbench de puertos (`tb/post_synth_tb.v`) y los mismos
estímulos en ciclos absolutos para el RTL y para el netlist de Yosys, con los modelos de
celdas del PDK compilados con `-DFUNCTIONAL` (sin bloques `specify`, sin retardos). Se
comparan las trazas de LEDs y display. Dato: `asic/sim/README.md`.

**100. [B] ¿Qué cambiaron para simular y por qué es válido?**
`CYCLES_PER_TENTH = 1` (con `-D` del assembler, así el display muestra ciclos y las esperas
de segundos duran decenas de ciclos) y `DebounceDivBits = 2` (un botón se acepta en unos 12
ciclos). Es el mismo `game.s` y la misma configuración en las dos simulaciones, como pide el
enunciado.

**101. [B] ¿Cómo sabe el testbench qué botón apretar si el LED lo elige un LFSR?**
Los estímulos se calibraron corriendo el RTL por etapas y leyendo en la traza qué LED se
encendió y en qué ciclo (`asic/sim/calibrar.py`). El LFSR se siembra con CYCLES en la
pulsación de inicio y todo es determinista, así que el netlist ve exactamente lo mismo.

**102. [B] ¿Qué muestran los resultados?**
Trazas idénticas (17 cambios de salida en 4.500 ciclos), sin X. La ronda correcta mide 57
ciclos en las dos (display 57 en el ciclo 1.574), la pulsación incorrecta muestra EE en el
ciclo 2.181 y la ronda vuelve a 02 en vez de pasar a 03; el reintento mide 57 otra vez.

**103. [B] ¿Cómo saben que la comparación detectaría un error?**
Control negativo (`make post-synth-control`): se atrasa 6 ciclos la pulsación de la ronda 01
solo en el netlist; el display muestra 70 en vez de 57 y la comparación da FAIL. Con 5 ciclos
no cambia, porque el lazo de polling dura 13 ciclos (pregunta 71).

**104. [A] Si el STA cierra, ¿para qué simular el netlist?**
El STA revisa tiempos, no función. La simulación del netlist confirma que la síntesis no
cambió el comportamiento: valores iniciales descartados, diferencias entre cómo simula y cómo
sintetiza un `case` o una variable sin asignar, o lógica optimizada de más. Una
verificación formal de equivalencia lo probaría para todas las entradas, no solo para un
escenario; LibreLane trae ese paso (`Yosys.EQY`), pero viene apagado y no se usó.

**105. [A] El banco de registros no tiene reset. ¿Por qué no aparecen X en el netlist?**
El programa escribe cada registro antes de leerlo (D4), y los registros de
pre-decodificación se cargan antes de usarse. Un monitor sobre la simulación del juego
completo no encontró valores X usados en 388.411 escrituras al banco.

**106. [B] ¿Hicieron la simulación con SDF?**
Era opcional. `make post-pnr-sdf` con el SDF de la esquina típica completó una vez con la
misma traza (PASS), pero Icarus 14.0-devel aborta al anotar el SDF en corridas siguientes,
así que no se presenta como resultado reproducible. Además `make post-synth-final` simula el
netlist de la corrida final con las constantes reales por 320.000 ciclos: PASS.

---

## 9. RTL del Espino Core y del SoC

**107. [B] Recorre un `add` ciclo a ciclo.**
Ciclo 1 (espera): la instrucción está en el registro de instrucción; el banco lee `rs1` y
`rs2` (lectura sincrónica) y el decodificador registra sus salidas; `ops_valid_q = 0`, así
que `rf_ready = 0` y el controlador detiene el fetch. Ciclo 2 (ejecución): `ops_valid_q =
1`, la ALU suma, el write-back escribe `rd` en el flanco (`commit`) y el fetch avanza.

**108. [B] ¿Y un `lw`?**
Igual hasta la ejecución, donde la ALU calcula la dirección y la LSU emite la lectura; como
es carga, `busy` detiene un ciclo más. En el tercer ciclo llega el dato registrado de la
memoria o del periférico, la LSU lo alinea según `addr[1:0]` y se escribe en el banco.

**109. [B] ¿Y un salto tomado?**
En la ejecución `pc_set` carga el PC con el destino y marca como inválida la instrucción que
ya se había pedido (`valid_q = 0`). Esa instrucción pasa por ID sin efecto: una burbuja de un
ciclo. El destino se calcula como `pc + imm` (saltos y `jal`) o `(rs1 + imm) & ~1`
(`jalr`).

**110. [B] ¿Qué hacen `ops_valid_q` y el controlador?**
`ops_valid_q` dice si los operandos del banco ya están listos (vale 1 desde el segundo ciclo
de cada instrucción; en una carga, también en el tercero). El controlador detiene el pipeline si hay una instrucción válida sin
operandos listos o si la LSU espera un dato (`stall = rf_wait | lsu_busy`), y carga el PC con
el destino si hay salto tomado o `jal`/`jalr` (`pc_set`).

**111. [B] ¿Cómo se implementa x0?**
`x0` no se almacena: el banco tiene registros de x1 a x15, una escritura a x0 se ignora y una
lectura de la dirección 0 entrega 0 por hardware. En la BRAM del P2 valía 0 solo porque la
memoria partía en cero.

**112. [B] ¿Por qué los shifts se ejecutan como suma?**
La ALU del repositorio base tiene los shifts comentados para ahorrar LUTs de la FPGA, y el
`case` cae en el valor por defecto, que es una suma. El assembler los rechaza (salvo
`--allow-shifts`) y `game.s` desplaza sumando un registro consigo mismo.

**113. [B] ¿Cómo decide el SoC si un acceso va a memoria o a un periférico?**
Por el bit 31 de la dirección: 0 es memoria, 1 son periféricos (`0x8000_0000`). Dentro de
los periféricos el bit 16 separa la placa (LEDs, display, botones, CYCLES) del SPI. Como las
lecturas son registradas, `rd_is_per` guarda a quién se le pidió el dato para elegir la
respuesta en el ciclo siguiente.

**114. [A] ¿Cómo se escriben bytes y medias palabras?**
La LSU arma las habilitaciones de byte (`data_be`) según el tipo y `addr[1:0]`, y replica el
dato en las cuatro posiciones (un byte ×4, media palabra ×2); la memoria escribe solo los
bytes habilitados. En la lectura, la LSU elige el byte o la media palabra y extiende el signo
si es `lb` o `lh`.

**115. [A] ¿Qué pasa con una instrucción ilegal?**
El decodificador levanta `illegal_insn`, pero el core no lo usa. Depende del caso: con un
opcode desconocido (por ejemplo la palabra 0) todas las salidas quedan en su valor por
defecto (sin escritura, sin acceso a memoria, sin salto) y funciona como un NOP. Con un
opcode válido y un `funct3` ilegal, se mantienen las señales de ese opcode: un LOAD o un
STORE con `funct3` no definido hace un acceso de palabra, y un JALR con `funct3` ≠ 0 igual
salta. El assembler nunca genera esas codificaciones.

**116. [B] ¿Cómo funciona el debounce?**
Un contador de 15 bits da un tick cada 2¹⁵ ciclos (3,28 ms a 10 MHz). Cada botón tiene un
registro de 3 muestras; la salida cambia solo cuando las tres muestras son iguales, así que
acepta un cambio en unos 10 a 13 ms y un rebote no la mueve. Dato: `rtl/debounce.v`.

**117. [A] ¿Por qué CYCLES tiene reset y el banco de registros no?**
CYCLES debe partir en un valor conocido para que la simulación sea determinista (sin reset
sería X en simulación y la semilla del LFSR también) y para que RTL y netlist vean lo mismo.
El banco no lo necesita porque el programa escribe cada registro antes de leerlo, y sin
reset sus 480 bits son `dffq_1`, más chicos.

---

## 10. Assembler

**118. [B] ¿Cómo funciona el assembler?**
Dos pasadas. En la primera lleva la dirección desde 0, guarda cada etiqueta con su dirección
y cada `.equ` con su valor, y calcula el tamaño de cada instrucción (`li` puede ser 1 o 2
palabras). En la segunda codifica cada línea con la tabla de símbolos completa, lo que
permite saltar a etiquetas definidas más abajo. Python 3 sin dependencias.

**119. [B] ¿Cómo se expande `li`?**
Si cabe en 12 bits con signo, `addi`; si los 12 bits bajos son 0, `lui`; si no, `lui` +
`addi`. Como `addi` extiende el signo, si el bit 11 está en 1 la parte alta se redondea:
hi = (valor + 0x800) >> 12, lo = valor − hi·4096. Ejemplo: `li x4, 0x04C11DB7` → `lui x4,
0x04C12` y `addi x4, x4, −585`.

**120. [B] ¿Cómo se codifica un salto?**
El inmediato es la dirección de la etiqueta menos la de la instrucción, en bytes, y debe ser
par. Rango ±4 KiB en las bifurcaciones (12 bits, el bit 0 implícito) y ±1 MiB en `jal`. El bit de
signo del inmediato está en el bit 31 en todos los formatos; en B y J el resto de los bits
va reordenado para que coincida con las posiciones de S y de I/U, y el hardware necesita
menos multiplexores.

**121. [B] ¿Cómo saben que el assembler es correcto?**
80 pruebas (`make test`): los tres ejemplos del repositorio base dan el mismo `.hex` byte a
byte (golden), codificaciones calculadas a mano, pseudo-instrucciones, directivas, `-D`, 28
pruebas de validación (errores, con casos límite en los rangos), ida y vuelta con el desensamblador, y 7 de las
salidas Verilog.

**122. [B] ¿Qué errores detecta?**
Registro desconocido o mayor que x15 (RV32E), shift sin `--allow-shifts`, mnemónico o
directiva desconocidos, etiqueta o constante repetida o no definida, inmediato fuera de
rango, operandos de más o de menos, operando de memoria mal escrito, salto impar o fuera de
alcance, y programa demasiado largo. Siempre con número de línea.

**123. [B] ¿Para qué sirve `-D`?**
Pisa un `.equ` sin editar el archivo. Así la simulación usa el mismo `game.s` con
`CYCLES_PER_TENTH = 1` y el macro con 1.000.000.

---

## 11. Programa del juego

**124. [B] ¿Cómo se elige el LED de cada ronda?**
LFSR de Galois de 32 bits con polinomio `0x04C11DB7` (primitivo, período 2³² − 1),
desplazado sumando el registro consigo mismo (no hay shifter). Se siembra con CYCLES en la
pulsación de inicio y avanza en cada vuelta del lazo de polling; los dos bits bajos eligen el
LED. Por eso existe la pantalla de inicio: sin ella el primer LED sería siempre el mismo.

**125. [B] ¿Desde cuándo y hasta cuándo se mide el tiempo?**
Desde la lectura de CYCLES inmediatamente después de encender el LED objetivo hasta la
lectura de CYCLES apenas se lee el botón correcto. `cyc2tenths` divide por restas
sucesivas, trunca hacia abajo y satura en 99.

**126. [B] ¿Qué pasa con un botón incorrecto?**
`miss`: muestra EE, apaga los LEDs, espera `ERROR_TENTHS` y vuelve a `round_begin` sin tocar
aciertos ni suma, así que la ronda se repite completa, con sus tres segundos.

**127. [B] ¿Por qué el promedio divide por `RONDAS` y no por 10?**
Para que cambiar `RONDAS` cambie también el divisor. Con un 10 fijo, el juego terminaría en
otra ronda pero seguiría dividiendo por 10.

**128. [B] ¿El programa usa stack?**
No. Las subrutinas no son recursivas: cada nivel tiene su registro de retorno (x1 para
`show_bcd` y `wait_tenths`, x15 para `div` y `cyc2tenths`), y ninguna escribe x2 a x8, donde
vive el estado del juego. Por eso el juego no usa la RAM de datos.

---

## 12. Preguntas de "¿por qué no...?"

**129. [B] Si cierra a 25 ns, ¿por qué la corrida final es a 100 ns?**
El enunciado fija T = 100 ns y 40 % para la corrida final. La frecuencia máxima se reporta
con el barrido; la final cierra con 65 ns de margen.

**130. [A] ¿Por qué la biblioteca de 7 tracks y 5 V?**
`mcu7t5v0` es la de 7 pistas y 5 V, la que LibreLane usa por defecto con gf180mcuD, y por
eso las esquinas son de 4,5, 5,0 y 5,5 V. "7 pistas" es el alto de la celda medido en pistas
de ruteo: 7 × 0,56 µm = 3,92 µm, el alto de cada fila (157 filas de 1.102 sitios de 0,56
µm). Una de 9 pistas tiene celdas más altas, con lugar para transistores más anchos, a
cambio de área; no se probó porque el enunciado no lo pide y el diseño cierra con margen.

**131. [A] ¿El macro funcionaría si se fabrica?**
Lógicamente sí: DRC, LVS y antenas limpios, timing cerrado en 9 esquinas, netlist simulado.
Falta lo que no es parte de un macro: pads de I/O, anillo de sello, encapsulado y un plan de
pruebas. Por timing aguanta hasta 40 MHz; con estas constantes el reloj tiene que ser
de 10 MHz exactos, porque a otra frecuencia las esperas y los tiempos mostrados se escalan
(a 5 MHz la espera de 3 s dura 6 s).

**132. [A] ¿Qué harían con una semana más?**
Integrar B2 (24 ns) y B5 (−9 % de área), cerrar las violaciones de slew sin pasar el 1 % de
área, una simulación con SDF reproducible (otra versión de Icarus o Verilator) y una
verificación formal de equivalencia entre RTL y netlist.
