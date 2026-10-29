# Banco de preguntas de la defensa

Preguntas que el profesor o un ayudante pueden hacer a cualquiera de los tres sobre el
informe, el RTL, el assembler y el flujo. Cada respuesta está pensada para decirse en voz
alta en unos 20 segundos, con el dato y el archivo que la respaldan.

- **[B]** básica: lo que los tres tienen que poder responder sin mirar nada.
- **[A]** avanzada: va más allá del ramo (física, teoría de timing, flujo por dentro).
- La corrida final es la de D23: el core con lectura del banco y decodificación en el fetch
  (`EarlyRead = 1`), banco write-through y B2, más el modelo de cable medido del resizer y la
  reparación después del ruteo global. "v1" es la corrida final anterior (tag `v1-final`,
  reportes en `asic/rom/resultados/v1_final/`); cuando se cita una cifra de v1 es como historia.
- Los números salen de `asic/final.md`, `asic/rutas.md`, `asic/evolucion.md`, `asic/sintesis.md`,
  `asic/exploraciones.md`, `asic/barrido.md`, `asic/rom/resultados/*/metrics.json` y `cierre.md`,
  `asic/ff/resultados/s4_*/`, `docs/decisiones.md`, `docs/datos_informe.md`,
  `docs/hechos_flujo.md`, `docs/pipeline.md`, `docs/modelo_cable.md`,
  `docs/verificacion/integracion.md`, `docs/equivalencia.md`, `asic/sim/resultado.md`,
  `asic/sim/resultado_sdf.md` y `asic/potencia/resultado.md`. Si un número de acá no calza con
  esos archivos, manda el archivo.

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
≥ 0 y TNS = 0 de setup y de hold en las 9 esquinas (D14). Final: setup WNS 65,725 ns en
max_ss, hold WNS 0,173 ns en min_ff, TNS 0. Dato: `asic/rom/resultados/final/cierre.md`.

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
antenas y, desde D23, otra reparación de diseño y de timing, ruteo detallado, relleno,
extracción de parásitos, STA en 9 esquinas, IR drop, y signoff: GDS (Magic y KLayout), DRC, LVS
(Netgen) y chequeo de antenas. Son 78 pasos y la corrida tarda unos 4 minutos; los más largos son
el ruteo detallado (37 s), el DRC de Magic (19 s) y la reparación después del ruteo global (16 s).
Varios se saltan (macros, obstrucciones, DRC de KLayout, inserción heurística de diodos,
equivalencia formal, que se corrió aparte: pregunta 111). Dato: `docs/hechos_flujo.md`, sección 12.

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
ese pesimismo (pregunta 44).

**11. [A] ¿El placement toma en cuenta el timing?**
No directamente: `PL_TIMING_DRIVEN = False`, y el placement global se guía por ruteabilidad,
con una densidad objetivo que el flujo calcula (53,3 %). El timing lo arreglan después el
resizer, que cambia tamaños y agrega buffers en cuatro pasos (dos de ellos después del ruteo
global, D23), y el CTS. Dato: `docs/hechos_flujo.md`, sección 5.

**12. [A] ¿Qué es el chequeo XOR que aparece en las métricas?**
LibreLane escribe el GDS dos veces, con Magic y con KLayout, a partir del mismo layout, y
compara las dos geometrías con una operación XOR. `design__xor_difference__count = 0`: los
dos GDS son idénticos, así que no hay un error de una de las herramientas al escribirlo.

**13. [B] ¿Qué avisos quedan en la corrida final y por qué no importan?**
Los tres de siempre: tres pines SPI sin área de compuerta en el LEF (no llegan a ninguna
compuerta, D7), VDD y VSS "flotantes" para el resizer (los conecta la red de alimentación; LVS
limpio) y `VSRC_LOC_FILES` sin valor (posición de los pads para el IR drop: un macro no tiene
pads; el análisis igual corrió, con 0,611 mV de caída peor en VDD, el 0,01 % de los 5 V). Queda
además el de max capacitancia, que es un solo pin, la raíz del árbol de reloj (pregunta 60). El
de max slew desapareció con D23. Dato: `asic/rom/resultados/final/avisos.md`.

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
Estrategia 1: ROM combinacional para instrucciones con dos salidas, una registrada, que
mantiene la lectura registrada de la RAM del P2, y una combinacional (`a_next_o`), con la que el
core lee el banco y decodifica un ciclo antes; RAM de datos aparte de 4 palabras. Estrategia 2:
memoria unificada de 115 + 4 = 119 palabras en flip-flops; el programa es el valor de reset,
así que cada bit es un flip-flop con reset o con set, y todo se puede reescribir desde el
puerto de datos, como en el P2. Con ella el core conserva el ciclo de espera (`EarlyRead = 0`,
pregunta 28). Dato: `rtl/pochoco_mem_rom.v`; `docs/pipeline.md`, sección 1.

**25. [B] ¿Qué dio la comparación?**
Con el RTL y la configuración de la corrida final, a 100 ns (`final` contra `s4_t100`): 156.098
contra 696.640 µm² de celdas de síntesis (4,5 veces), 964 contra 4.673 flip-flops, die de 0,419
contra 1,802 mm² (4,3 veces), período mínimo 21,5 contra 32 ns (el menor medido de la 2), CPI
1,665 contra 2,665 (27,9 contra 11,7 MIPS) y 0 nets con violación de antena en las dos. D17 se
decidió antes, con v1 y la configuración de D15: 4,7 veces de área, 55 contra 62 ns y 0 contra 1
net de antena. Dato: `docs/datos_informe.md`, sección 3.2; `asic/barrido.md`.

**26. [A] ¿Por qué la ROM es tan barata comparada con los flip-flops?**
La ROM guarda 115 × 32 = 3.680 bits en 7.448 µm², unos 2 µm² por bit, porque la síntesis
minimiza la lógica: muchos bits son constantes por columna o comparten términos entre
palabras. En la estrategia 2 cada flip-flop extra cuesta unos 146 µm² ((696.640 − 156.098) /
3.709): un flip-flop con reset o set, su mux de escritura por byte y su parte de los dos
muxes de lectura de 119 entradas (puerto de instrucciones y puerto de datos). La diferencia es
de unas 72 veces por bit (con v1 y la configuración de D15 daba 149 µm² y unas 70 veces). Dato:
`asic/sintesis.md`, `sintesis_stat.rpt` de `final` y de `s4_t100`.

**27. [B] ¿Por qué la estrategia 2 además es más lenta?**
Su ruta crítica (`s4_t32`) parte del mismo registro de decode y cruza la misma ALU que la de la
1, pero desde la dirección calculada (`lsu_addr[4]`) le quedan 17,4 ns de lógica hasta un
flip-flop con reset, contra 4,4 ns en la estrategia 1: la dirección se decodifica sobre 119
palabras en vez de 4. Además el die es 4,3 veces más grande, con 5,9 veces más cable. Y por ciclo
también pierde: corre con `EarlyRead = 0` (pregunta 28), así que su CPI es 2,665 contra 1,665.
Dato: `asic/ff/resultados/s4_t32/max_ss_125C_4v50_ruta_critica.rpt`; `docs/datos_informe.md`,
sección 3.2.

**28. [A] ¿Por qué la estrategia 2 no anticipa la lectura del banco?**
Podría, pero no conviene. La memoria en flip-flops también expone `a_next_o`, el mux
combinacional de sus 119 palabras, así que con `EarlyRead = 1` el core funcionaría. Pero en un
ciclo la ruta iría del PC por ese mux hasta rs1 y rs2 y de ahí al árbol de lectura del banco, y
sería la crítica; en la estrategia 1 ese tramo es una ROM que la síntesis minimiza a 7.448 µm².
Y la 2 ya es la lenta sin anticipar (32 contra 21,5 ns) y no es la de la corrida final. Por eso,
y porque así `make check` sigue cubriendo la temporización anterior del core, `pochoco_soc` fija
`EarlyRead = (MemStrategy == 1) ? 1 : 0`: la ROM combinacional es la que hace barato el
pipeline, un argumento más para D17. Dato:
`docs/pipeline.md`, sección 1; `docs/datos_informe.md`, sección 3.2.

**29. [A] ¿Qué pasa si el PC se sale del programa?**
La ROM solo mira `addr_i[8:2]` (7 bits). Las palabras 115 a 127 entregan 0, que es una
instrucción ilegal: el decodificador deja todo en su valor por defecto (sin escritura al
banco, sin acceso a memoria, sin salto), así que actúa como un NOP. En `0x200` la dirección
vuelve a la palabra 0 y el programa reaparece. El juego nunca llega ahí.

**30. [A] ¿Por qué no usaron las SRAM que trae el PDK?**
El PDK trae macros `gf180mcu_fd_ip_sram` de 8 bits de ancho y 64 a 512 palabras. El
enunciado pide comparar ROM y flip-flops, el juego no usa datos, y el banco de registros
necesita dos lecturas de 32 bits por ciclo, que no calza directo con esos macros. Además un
macro duro agrega trabajo de floorplan (ubicarlo, conectarlo a la red de alimentación) y sus
propios modelos de timing.

**31. [A] ¿Una ROM "de verdad" no sería mejor que lógica?**
Una ROM de máscara (un arreglo de transistores programado por contactos o vías) es más densa
por bit, pero el PDK abierto no trae un generador de ROM. La ROM sintetizada es la opción
disponible con celdas estándar y, para 115 palabras, ocupa solo el 4,5 % del diseño. Dato:
`asic/sintesis.md`.

---

## 4. Síntesis (3.3)

**32. [B] ¿Cuáles son las cinco celdas más usadas y qué las explica?**
`nand2_1` 934 (lógica aleatoria de la ROM, el decodificador, la ALU y el banco, que con el
write-through y el enable de lectura pasa de 88 a 265), `mux2_2` 889 (muxes de retención y
árboles de lectura del banco, con el write-through), `dffq_1` 779 (banco 544 = 480 de
almacenamiento + 64 de salida, memoria 192, decode registrado 82, offset de la LSU 2, menos 41
que la síntesis aplanada elimina), `aoi21_1` 437 y `oai21_1` 348. Son celdas a la salida de Yosys
(5.577 de 36 tipos); el layout llega a 9.928. Dato: `asic/sintesis.md`.

**33. [B] ¿Por qué tantos `mux2_2`?**
La biblioteca no tiene flip-flops con habilitación. Un registro que se escribe solo a veces
se arma como `D = en ? d : Q`: un mux de retención por bit. En la síntesis jerárquica (1.139
`mux2_2`) son 796 en el banco (480 de retención y 316 de los árboles de lectura, el
write-through y el enable de lectura), 160 en la memoria y 117 en la etapa ID (82 de retención
del decode). La aplanada termina con 889 porque optimiza a través de los bordes de módulo.
Dato: `asic/sintesis.md`.

**34. [B] ¿Qué módulo tiene más área y cuánto es el contador de ciclos?**
El banco de registros `u_soc.u_core.u_rf`: 80.349 µm², 48,8 % en la síntesis jerárquica y
51,5 % en la final (73.656 µm² en v1; la diferencia es el write-through y el enable de lectura).
El contador `u_soc.u_periph.u_cycles`: 3.943 µm², 2,4 % (2,5 % en la final), el 61 % son sus 32
flip-flops con reset y el resto el incrementador. Dato: `asic/sintesis.md`.

**35. [B] Si la síntesis aplana el diseño, ¿cómo midieron el área por módulo?**
La corrida final conserva la jerarquía solo de los tres módulos que pide el enunciado
(`SYNTH_KEEP_HIERARCHY_MODULES`, D12). Para el resto se sintetizó la misma configuración sin
aplanar (`SYNTH_HIERARCHY_MODE=keep`, corrida h3_t100, solo hasta Yosys), que informa cada
módulo. La aplanada sale 5,2 % más chica (156.098 contra 164.605 µm²) porque optimiza a través
de los bordes de módulo.

**36. [B] ¿Coincidió con lo que esperaban?**
En parte. El banco de registros domina (49 %) y el conteo de flip-flops coincide con el RTL (820
sin reset y 185 con reset; 964 en la final, donde la aplanada elimina 41). No se cumplió que el
flip-flop fuera la celda más numerosa: queda tercero, detrás de `nand2_1` y `mux2_2`, porque el
write-through y el enable de lectura llevan el banco de 88 a 265 `nand2_1` y de 622 a 796
`mux2_2` (estos, en parte, porque la síntesis rehízo el árbol de lectura con menos `mux4_1`). Tampoco esperábamos el peso de los muxes de retención (falta de flip-flops con
habilitación). Dato: `asic/sintesis.md`, sección "Comparación con lo esperado".

**37. [A] ¿Qué hace ABC y por qué aparecen tantas NAND2?**
ABC es la herramienta de Yosys que optimiza la lógica combinacional y la mapea a celdas de la
biblioteca. Con la estrategia de área elige la combinación de celdas que minimiza el área
total, y la NAND2 es universal y una de las celdas más chicas (11 µm²): casi toda la lógica aleatoria cae en
ella y en compuertas compuestas como OAI21 (OR-AND-inversor) y AOI21 (AND-OR-inversor), que
hacen dos niveles de lógica en una sola etapa.

**38. [A] ¿Por qué el área pasa de 156.098 µm² en síntesis a 208.439 µm² en el layout?**
El layout agrega 2.497 celdas de tap (10.963 µm²) y 318 de borde (1.396 µm²), 1.335 buffers
de reparación de timing (30.838 µm², más del doble que en v1, porque el resizer repara con
parásitos realistas y otra vez después del ruteo global), el árbol de reloj (172 buffers y 28
inversores, que incluyen 78 cargas ficticias para equilibrarlo), y el resizer agranda celdas en
las rutas lentas. Sin las de tap ni las de borde son 196.080 µm² de celdas lógicas. Dato:
`metrics.json` de la final, `layout/bloques.txt`.

---

## 5. Timing (3.4)

**39. [B] ¿Cuál es la frecuencia máxima y cómo la obtuvieron?**
46,5 MHz (46,51): el diseño cierra a 21,5 ns con 0,876 ns de margen en max_ss y no a 21 ns
(falla por 0,129 ns, TNS −0,291). Se barrió `CLOCK_PERIOD` en 100, 30, 25, 24, 23, 22, 21,5 y
21 ns con el mismo RTL y la misma configuración (corridas `f2_*`), con pasos de 0,5 ns cerca del
límite. Con el CPI del juego (1,665) son 27,9 MIPS. En v1 eran 24,5 ns y 40,8 MHz. Dato:
`asic/final.md`, `asic/rom/resultados/f2_t21p5/cierre.md`.

**40. [B] ¿Por qué dicen que cada `CLOCK_PERIOD` reoptimiza el circuito?**
El resizer cambia tamaños de celdas y agrega buffers según el período: el área va de 208.439
µm² a 100 ns a 231.229 µm² a 21,5 ns y sube en cada punto del barrido, y por eso el WNS no baja
un nanosegundo por nanosegundo (es mayor a 21,5 que a 22 ns). En v1 pasaba lo contrario: de 26
ns para abajo el layout era idéntico (189.817 µm²) y solo cambiaba el slack, porque con los
parásitos estimados por omisión el resizer creía que no quedaba nada que reparar (preguntas 58
y 59). Dato: `asic/final.md`.

**41. [B] ¿Cuál es la ruta crítica?**
Al período mínimo (21,5 ns, max_ss) empieza en `_4136_`, el registro de decode que guarda
`alu_op_a_sel[2]`, pasa por el mux del operando A, cruza la ALU hasta `lsu_addr[31]` y la
decodificación de dirección del bus, y termina en `_4440_`, el bit 4 del registro del display
(`u_soc.u_periph.digit_q[4]`): un store al display, con ejecución y acceso a memoria. A 100 ns
la peor es otra, la que crea el pipeline: del bit 2 del PC por la ROM combinacional
(`a_next_o[17]`, un bit de rs1) y el árbol de lectura del banco hasta un registro de salida del
banco. Dato: `asic/rutas.md`.

**42. [B] ¿Cómo se reparte el tiempo en esa ruta?**
Árbol de reloj hasta el flip-flop 2,673 ns, reloj a Q 1,830 ns, mux del operando 4,267 ns (9
celdas), ALU 9,048 ns (18 celdas), decodificación de la dirección y habilitación del display
4,417 ns (10 celdas): llega a 22,235 ns. La ALU se lleva el 41 %, y el mux del operando y la
decodificación de dirección casi un 20 % cada uno. En v1 la ruta era el write-back de una carga,
con la ALU y la alineación casi por mitades. Dato: `asic/rutas.md`, sección de `f2_t21p5`.

**43. [A] ¿Cómo se calcula el slack de 0,876 ns de esa ruta?**
Tiempo requerido = período (21,5) + latencia del reloj de captura (2,385) + corrección por
reconvergencia (0,116) − incertidumbre (0,25) − setup del flip-flop (0,640) = 23,111 ns.
Llegada = 22,235 ns. Slack = 23,111 − 22,235 = 0,876 ns. Dato:
`asic/rom/resultados/f2_t21p5/max_ss_125C_4v50_ruta_critica.rpt`, `asic/rutas.md`.

**44. [A] ¿Qué es la corrección por reconvergencia (CRPR)?**
El reloj de lanzamiento y el de captura comparten el primer tramo del árbol (`clkbuf_0_clk`).
Con variación en el chip, el STA toma ese tramo lento para un camino y rápido para el otro,
lo que es físicamente imposible porque es el mismo buffer. CRPR devuelve esa diferencia
(0,116 ns en esta ruta).

**45. [A] ¿Qué es la incertidumbre de reloj de 0,25 ns?**
Un margen que se resta al tiempo disponible para cubrir jitter del reloj y efectos no
modelados. LibreLane la escribe en la SDC con el valor del PDK
(`CLOCK_UNCERTAINTY_CONSTRAINT = 0,25`) y aparece en cada reporte de ruta.

**46. [A] ¿Qué es el skew y cuánto hay?**
La diferencia de llegada del reloj a dos flip-flops. En la ruta crítica el reloj llega 0,288
ns más tarde al de lanzamiento (2,673 ns) que al de captura (2,385 ns), lo que le quita margen
de setup; CRPR devuelve 0,116 ns de esa diferencia, porque parte es pesimismo del análisis. Por
esquina, en la corrida final, el skew de setup va de 0,341 ns (min_ff) a 0,495 ns (max_ss) y el
de hold de −0,433 a −0,768 ns (`clock__skew__worst_*__corner:*` en `metrics.json`).

**47. [A] ¿Por qué el setup se complica en ss y el hold en ff?**
Setup falla si el dato llega tarde: peor con transistores lentos, voltaje bajo, 125 °C y
cables con más RC (max_ss). Hold falla si el dato llega demasiado pronto y pisa al anterior:
peor con todo rápido (min_ff, −40 °C, 5,5 V). Por eso el peor setup es max_ss (65,725 ns a
100 ns) y el peor hold es min_ff (0,173 ns).

**48. [A] ¿El hold depende del período?**
No: el chequeo de hold compara el dato con el mismo flanco que lo lanzó, así que el período
no aparece en la ecuación. Por eso el hold es igual (0,173 ns) en los ocho puntos del barrido,
de 100 a 21 ns. El flujo lo arregla agregando retardo en las rutas cortas: el paso posterior
al CTS insertó 5 buffers de hold, igual que en v1 (la métrica final dice 0 porque la sobrescribe
la reparación posterior al ruteo global, que no encontró nada que arreglar). Dato: `metrics.json`
de `final` y de `f2_*`; `docs/hechos_flujo.md`, sección 7.3.

**49. [A] ¿La ruta crítica es real?**
La de hoy sí: decode registrado, ALU y decodificación de dirección son de un ciclo de verdad. La
duda valía para v1 y para el pipeline sin B2 (`pr_t22p5`), donde la peor era el write-back de una
carga: para el STA era de un ciclo, pero el dato de memoria llega un ciclo después de emitir la
carga, con el pipeline detenido y la dirección estable, así que en la práctica tenía dos. B2
registra los dos bits bajos de la dirección al emitir la carga y la saca de la ruta sin cambiar
el comportamiento: el período mínimo baja de 22,5 a 21,5 ns. Dato: `asic/rutas.md`,
`asic/final.md` (barrido `pr_*`).

**50. [A] ¿Por qué no declarar esa ruta como multiciclo en la SDC?**
Una excepción de timing le dice al STA que no revise algo; si está mal escrita oculta una
falla real que ninguna simulación sin retardos detecta. Además la misma ALU alimenta el
write-back de un ADD en un solo ciclo, así que la excepción tendría que pasar solo por la
alineación. Por eso se cambió el RTL (B2, adoptado en D23) y el STA sigue revisando todo. Dato:
`docs/decisiones.md`, D23.

**51. [B] ¿Qué cambios de RTL hicieron para acortar la ruta y bajar el CPI?**
Dos, uno encima del otro. D18: registrar las 82 salidas del decodificador para sacar el decode de
la ruta de ejecución, usando el ciclo en que cada instrucción esperaba la lectura del banco.
D23: como la ROM es combinacional, la instrucción que pide el fetch está disponible un ciclo
antes; con esa salida (`a_next_o`) el core lee rs1 y rs2 y registra el decode en el mismo flanco
en que carga la instrucción, y desaparece el ciclo de espera (CPI de 2,665 a 1,665). Se agregan
el write-through del banco y B2. A diferencia de D18, este cambio sí cambia los ciclos. Dato:
`docs/pipeline.md`, secciones 1 y 2.

**52. [B] ¿Por qué el decode y no otra parte?**
En la ruta de partida (s1_t55) el decode era el tramo más largo: 19,1 de 55,1 ns. Además
está en todas las rutas de ejecución (cargas, saltos, SLT), así que sacarlo mejora todas, no
solo la peor. Fue el primer paso: después, al ver que la ROM combinacional permitía decodificar
un ciclo antes, se eliminó también el ciclo de espera (D23). Dato: `docs/decisiones.md`, D18.

**53. [B] ¿Cuánto rindió y cuánto costó la pre-decodificación?**
Con la configuración de D15: período mínimo de 55 a 42 ns y 13,0 ns más de slack a 100 ns, por
4,4 % de área (69 flip-flops más tras la síntesis y sus muxes). Con la configuración de v1: 10,7
ns más de slack a 100 ns, y sin pre-decodificación el diseño no cierra a 26 ns (WNS −3,18 ns).
Con la configuración de D23 esa comparación no se repitió. Dato: `asic/barrido.md`,
`asic/final.md` (corridas `r0_*`).

**54. [B] ¿Cómo verificaron que no cambió el comportamiento?**
Como los ciclos cambian a propósito, la equivalencia con el RTL anterior es funcional y no ciclo
a ciclo: `make equiv MODO=funcional` corre `sw/isa_test.s` contra v1 y contra 116fa20 y da las
mismas 46 escrituras al banco, 22 accesos al bus y 2 salidas, con las dos estrategias. Además
`make check` pasa (80 pruebas y seis testbenches), dos programas de riesgos de datos
(`hazard_test`, 56 comprobaciones, y `hazard_review`, 48) dan trazas iguales a v1, las
mutaciones se detectan y un monitor no encontró valores X usados en 620.217 escrituras al banco
(pregunta 114). Dato: `docs/verificacion/integracion.md`.

**55. [A] ¿Por qué los registros de pre-decodificación no tienen reset?**
Porque nunca se lee un valor sin cargar. Se cargan en el mismo flanco que la instrucción, y todo
lo que los usa está condicionado a `instr_valid_i`: `valid_q` arranca en 0 y durante el reset
`pc_q` vale `BootAddr`, así que en cada flanco del reset ya se cargan con la primera instrucción.
Sin reset son `dffq_1`, más chicos que `dffrnq_1`. El monitor de X lo confirma: 0 valores
desconocidos usados en 620.217 escrituras al banco. Dato: `docs/pipeline.md`, sección 2
(riesgo 6).

**56. [B] El período mínimo bajó de 42 a 24,5 ns con el mismo RTL. ¿Qué cambió?**
La configuración del flujo (D20): se excluyó `buf_1` y se le pidió al resizer un margen de
setup de 10 ns. Con eso deja de entregar el mismo circuito en todos los períodos y optimiza
de verdad; las violaciones de slew bajaron de 2.201 a 541 en la corrida de D20 (546 en la final
de v1). Antes, sin pre-decodificación, excluir las celdas de retardo `dly*` (D15) había llevado
el diseño de no cerrar a 60 ns (WNS −7,69 ns, 12 celdas `dly` en la ruta crítica) a cerrar a
55 ns. Después, el modelo de cable de D23 llevó el mismo RTL de v1 a 22 ns (pregunta 58). Dato:
`docs/decisiones.md`, D15 y D20; `asic/evolucion.md`.

**57. [A] ¿Qué hace `PL_RESIZER_SETUP_SLACK_MARGIN`?**
Le dice al resizer que repare rutas hasta dejarlas con ese margen de setup (por defecto
0,05 ns); actúa en la reparación de timing después del árbol de reloj
(`ResizerTimingPostCTS`). Antes casi no hacía nada porque trabaja con parásitos estimados, y
eso ahora está medido: estima los cables entre 2,3 y 2,9 veces más livianos en capacidad que lo
que OpenRCX extrae del ruteo, así que con 0,05 ns veía todo cumplido. Los 10 ns le daban
colchón; la corrección de fondo fue darle los RC medidos (`LAYERS_RC`, preguntas 58 y 59).
Dato: `docs/modelo_cable.md`, secciones 1 y 2.

**58. [B] ¿Qué es el modelo de cable del resizer y por qué lo cambiaron?**
El resizer arregla el timing antes de que existan los cables, así que estima cada net como su
largo por una resistencia y una capacidad por micrómetro. Por omisión usa un solo par, el
promedio de las capas del tech LEF (0,2752 Ω/µm y 64,3 aF/µm), que no cuenta el acoplamiento con
los vecinos ni las vías: subestima la capacidad entre 2,3 y 2,9 veces (pregunta 59). Con cables de
menos da un net por cumplido y la violación aparece recién en el STA final: de ahí las 546 de max
slew de v1. `LAYERS_RC` le da los valores del tech LEF de cada capa multiplicados por el factor medido en cada extracción, y con eso sirve la
reparación después del ruteo global. Con el RTL final el período baja de 25,5 a 21,5 ns y el slew
queda en 0. Dato: `docs/modelo_cable.md`.

**59. [A] ¿Cómo midieron que el tech LEF era optimista?**
Comparando lo que el flujo estima con lo que extrae. `asic/modelo_cable.py` toma los SPEF de
OpenRCX y el largo ruteado de cada net de una corrida sin `LAYERS_RC` (`b5_t100`) y ajusta una
recta de capacidad contra largo sobre los 2.399 nets de más de 20 µm (en los cortos manda la
capacidad fija de vías y extremos). La pendiente da 188,4, 166,3 y 148,0 aF/µm en las
extracciones max, nom y min, contra 64,3: factores de 2,93, 2,59 y 2,30 (en resistencia, 2,18,
1,99 y 1,81). Esos factores escalan el tech LEF en `LAYERS_RC`. La prueba indirecta: con ellos el
slew de v1 baja de 546 a 2 y el del RTL nuevo queda en 0. Dato: `asic/modelo_cable.md`;
`docs/modelo_cable.md`, secciones 2 y 4.

**60. [A] ¿Qué es la violación de capacitancia que queda y por qué no se quita?**
Es un solo pin, el mismo en las nueve esquinas: `clkbuf_0_clk/Z`, la raíz del árbol de reloj,
un `clkbuf_16` que pone el CTS. Maneja 0,428 pF contra un límite de 0,2 pF en la esquina lenta
(0,402 pF en la típica). Ese límite es `MAX_CAPACITANCE_CONSTRAINT`, que LibreLane pone a todos
los pines; el liberty le permite 3,93 pF a ese pin, nueve veces más. Y `repair_design` no toca la
red de reloj, así que ninguna reparación la arregla. Quitarla exigiría otro nivel en el árbol de
reloj, con más buffers, área, potencia y latencia, a cambio de nada medible: no es criterio de
cierre. En v1 eran 36 pines. Dato: `asic/rom/resultados/final/avisos.md`, aviso 4;
`docs/datos_informe.md`, sección 3.6.

**61. [A] ¿Por qué las celdas de retardo empeoraban el timing?**
Están hechas para tener un retardo grande a propósito: sirven para arreglar hold alargando
rutas cortas. Usadas como buffers de fanout en rutas largas, agregan retardo justo donde falta tiempo.

**62. [A] ¿Por qué `buf_1` causaba violaciones de slew?**
Es el buffer más débil: su corriente de salida es baja, así que con cables largos o mucha
carga la transición es lenta. Explicaba el 68 % de los nets con violación de slew (D20). Pero
excluirlo atacaba el síntoma: la causa de fondo era el modelo de cable con que el resizer decide
dónde poner buffers, y con `LAYERS_RC` no queda ninguna violación de slew en las nueve esquinas
(`buf_1` sigue excluido). Dato: `docs/decisiones.md`, D20; `asic/rom/resultados/final/metrics.json`.

**63. [B] ¿Qué pasó con las 546 violaciones de max slew de v1?**
Eran pines donde la transición superaba los 3 ns que pone la SDC (la peor, 5,41 ns en la esquina
lenta, donde el liberty admite 7 ns). No eran criterio de cierre, y el timing ya las consideraba
porque el retardo de cada celda se calcula con su slew de entrada. Tampoco eran un problema del
diseño sino del modelo de cable del resizer: con los RC medidos y la reparación después del ruteo
global, la corrida final tiene 0 en las nueve esquinas, 21 violaciones de fanout (62 en v1), todas
en el árbol de reloj, y una de capacitancia (pregunta 60). Dato: `metrics.json` y
`max_ss_125C_4v50_checks.rpt` de la final.

**64. [A] ¿Cómo calcula el STA el retardo de una celda?**
Con tablas del liberty indexadas por el slew de entrada y la capacitancia de salida (modelo
NLDM): para cada combinación hay un retardo y un slew de salida, y el STA interpola. Por eso
un slew lento en una entrada alarga el retardo de la celda siguiente y se propaga.

**65. [A] ¿Qué dice el liberty de un `dffq_1`?**
Mide 16,24 × 3,92 µm (63,66 µm²). En la esquina típica, setup 0,21 a 0,23 ns, hold 0,05 a
0,08 ns y reloj a Q 1,0 a 1,3 ns; en la lenta, setup 0,44 a 0,47 ns y reloj a Q 1,8 a 2,3 ns
(para transiciones y cargas parecidas a las del diseño). En la ruta crítica, con su carga real y
el derating, el flip-flop de inicio es un `dffq_4` (reloj a Q 1,83 ns) y el de llegada un
`dffrnq_1` (setup 0,64 ns); a 100 ns la ruta termina en un `dffq_1` del banco, con 0,52 ns de
setup. Dato: `docs/hechos_flujo.md`, sección 11; `asic/rutas.md`.

**66. [B] ¿Qué constantes de `game.s` cambian para T = 100 ns?**
f = 10 MHz, así que una décima son 0,1 s × 10.000.000 = 1.000.000 ciclos: `CLK_HZ =
10000000` y `CYCLES_PER_TENTH = 1000000`. `ESPERA_TENTHS = 30` sigue siendo 3 s. Cambian
cuatro palabras de la ROM: los dos `li x12, CYCLES_PER_TENTH` de `cyc2tenths` y
`wait_tenths`, cada uno `lui x12, 0xf4` + `addi x12, x12, 576`.

**67. [A] ¿Y si el macro corriera a 46,5 MHz?**
`CYCLES_PER_TENTH = 4651162 = 0x46F89A`. Los 12 bits bajos (`0x89A`) tienen el bit 11 en 1,
así que `addi` los leería negativos: el assembler sube la parte alta a `0x470` y usa `addi
−1894`. A 10 MHz eso no pasa (`0x240` tiene el bit 11 en 0). El debounce muestrearía cada
0,70 ms y CYCLES daría la vuelta cada 92 s.

**68. [A] ¿Qué pasa cuando CYCLES da la vuelta?**
A 10 MHz pasa cada 2³² × 100 ns ≈ 429 s. La duración es una resta de 32 bits módulo 2³², que
da bien aunque haya una vuelta entre las dos lecturas, y las comparaciones usan `bltu` (sin
signo). Falla solo si una espera dura más de 429 s.

**69. [B] ¿Probaron otros cambios de RTL?**
Sí, en ramas `exp/*`, y dos entraron a la corrida final (D23; en D22 se había decidido no incorporar ninguno): el pipeline
con lectura del banco y decode en el fetch, y B2 (offset de byte de la carga registrado en la
LSU). B3 (comparador de saltos desde el banco) no mueve el período porque el salto no era la ruta
crítica. B4 (todo en un ciclo) baja el CPI a 1,312 pero el período sube a 60 ns y rinde 12,7
MIPS. B5 (banco de latches) ahorra área, pero con el pipeline cierra a 29 ns contra 26 sin latches
(pregunta 74). Dato: `asic/exploraciones.md`; `docs/decisiones.md`, D23.

**70. [B] Si B4 baja el CPI a la mitad, ¿por qué es peor?**
Ley de Hierro: tiempo = instrucciones × CPI × T, o MIPS = f / CPI. B4: 16,7 MHz / 1,312 = 12,7
MIPS. v1: 40,8 MHz / 2,665 = 15,3 MIPS. Final: 46,5 MHz / 1,665 = 27,9 MIPS. Al juntar todo en
un ciclo (PC, ROM, decodificador, lectura del banco, ALU y write-back) el período sube 2,4 veces,
más de lo que baja el CPI. El pipeline baja el CPI conservando la lectura registrada del banco, y
por eso gana. Dato: `asic/exploraciones.md`, `asic/evolucion.md`.

**71. [B] ¿Por qué la frecuencia máxima sola no mide el rendimiento?**
Porque MIPS = f / CPI y las dos se mueven a la vez. v1: 40,8 MHz y CPI 2,665, 15,3 MIPS. Final:
46,5 MHz y 1,665, 27,9 MIPS. B4 baja el CPI a 1,312 pero cae a 16,7 MHz: 12,7 MIPS. B2 con B5 y
reparación post-GRT llega a 43,0 MHz, pero con el CPI viejo da 16,1 MIPS. La final gana porque
mueve las dos: el CPI baja 37,5 % sin el ciclo de espera y el período baja con B2 y el modelo de
cable. De los 12,6 MIPS que gana sobre v1, 8,2 los pone el RTL, 1,7 el flujo y 2,6 la combinación
de los dos. Dato: `asic/exploraciones.md`, `asic/evolucion.md`.

**72. [B] ¿Por qué sí incorporaron B2?**
Porque sobre el pipeline vale 1 ns de período por dos flip-flops: sin B2 el mínimo es 22,5 ns
(26,7 MIPS) y con B2, 21,5 ns (27,9 MIPS). Registrar `addr[1:0]` al emitir la carga saca la ALU
del camino de alineación y write-back, que era la ruta crítica sin B2. A 100 ns casi no cambia
nada (49 µm² de celdas). Se verificó con las comprobaciones c14 a c33 de `hazard_test` (lb, lbu,
lh, lhu y lw con offsets 0 a 3). El argumento de D22 contra B2, que empeoraba el slew, ya no se
sostiene: la final tiene 0 violaciones. Dato: `asic/final.md` (barridos `pr_*` y `f2_*`);
`docs/decisiones.md`, D23.

**73. [A] ¿Qué era B5 y por qué reporta WNS 0,000?**
Banco de registros con latches `latq_1` en vez de flip-flops con mux, y una celda de clock
gating `icgtp_1` por registro: sobre v1, −9,3 % de área y slew/capacitancia de 546/36 a 312/2.
Un latch es transparente mientras el reloj está alto, así que un dato que llega tarde "toma
prestado" tiempo de la fase siguiente (3,38 ns en esa medición). OpenSTA reporta slack 0 en los
latches mientras quede préstamo; el margen real se lee en las rutas a flip-flops. Por qué dejó de
convenir: pregunta 74. Dato: `asic/exploraciones.md`, sección B5.

**74. [A] ¿Por qué el banco de latches de B5 deja de convenir con este pipeline?**
Sobre el pipeline, B5 cierra recién a 29 ns, contra 26 del mismo pipeline sin latches y 25,5 de la
variante adoptada con B2 (todas con el flujo de v1), aunque ocupa 11 % menos (165.211 contra 186.432 µm²): 20,7 contra 23,6 MIPS.
Según la rama, con la lectura anticipada el camino por los latches pierde el medio ciclo de
holgura que tenía. Parte del límite es del flujo: el resizer se queda iterando en los latches, la
corrida de 28 ns se cortó por tiempo y a 29 ns la ruta entre flip-flops aún tiene 3,29 ns de
sobra. Además su cierre se apoya en el préstamo (WNS 0,000 exacto) y su banco nunca pasó por una
simulación con retardos. Dato:
`docs/pipeline.md`, sección 5.1; `docs/revision_frente_a.md`, O2.

**75. [A] ¿Qué es una celda de clock gating y por qué tiene un latch?**
Apaga el reloj de un registro cuando no se escribe (ahorra el mux de retención y la potencia
del reloj). Si se hiciera con una AND directa, un cambio del enable con el reloj alto
cortaría el pulso y generaría glitches. La celda integrada captura el enable en un latch
transparente con el reloj bajo, así que el enable queda quieto mientras el reloj está alto.

**76. [B] ¿Cuántos ciclos toma cada instrucción?**
Uno la mayoría; dos las cargas, que esperan el dato registrado de la memoria o del periférico; y
dos los saltos tomados, porque la instrucción secuencial que ya se había pedido llega inválida y
deja una burbuja. Ya no hay ciclo de espera de la lectura del banco: se pide un ciclo antes con
la salida combinacional de la ROM. CPI del juego completo: 1,665 (2,665 en v1). Dato:
`docs/pipeline.md`, sección 1; `docs/verificacion/integracion.md`.

**77. [A] ¿Con qué resolución mide el juego el tiempo de reacción?**
En el macro manda el debounce: la salida filtrada solo cambia en un tick, cada 2¹⁵ ciclos
(3,28 ms a 10 MHz), y además agrega una latencia fija de unos 10 a 13 ms. El lazo de polling
`wait_press` dura 8 ciclos por cualquiera de sus dos caminos (con o sin realimentación del
LFSR), 0,8 µs, mucho menos que el tick. En la simulación, con un tick cada 4 ciclos, el lazo
sí se nota: un atraso de 7 ciclos no cambia la traza y uno de 8 la cambia en 8 ciclos (51 a
59). El resultado se trunca a décimas y satura en 99. Dato: `docs/pipeline.md`, sección 3.6.

---

## 6. Floorplan, red de alimentación y placement (3.5)

**78. [B] ¿Qué utilización usaron y cuál es el área mínima?**
40 % en la final (lo fija el enunciado; utilización real 53,5 %). Cierran 50, 60, 70, 72 y 73 %;
74 y 75 % fallan en el placement detallado después de la reparación posterior al ruteo global
(`DPL-0036`), 78 % en el CTS, 80 % en la reparación posterior al placement global y 90 % en el
placement global (`GPL-0301`). Mínima: 73 %, die de 476,1 × 494,1 µm, 0,235 mm². En v1 cerraba
hasta 78 %, con 0,216 mm². Dato: `asic/final.md`, `asic/rom/resultados/u2_*`.

**79. [B] ¿Por qué la utilización real es mayor que la pedida?**
El core se dimensiona con el área de síntesis dividida por la utilización (156.098 / 0,40 ≈
390.000 µm²; el core mide 389.525). Después se agregan celdas de tap, buffers del resizer y el
árbol de reloj, y la real sube 13,5 puntos a 40 % y entre 15,3 y 19,7 puntos en el resto del
barrido. Sube más que en v1 porque los buffers de reparación pasan de 636 a 1.335. Dato:
`metrics.json` de `final` y de `u2_*`.

**80. [A] ¿Por qué fallan 74 % y las siguientes?**
Por falta de lugar, cada vez más temprano en el flujo. A 74 y 75 % el placement detallado no
encuentra sitio legal para todas las celdas durante la reparación después del ruteo global (paso
41, 18 y 77 instancias, celdas lógicas); a 78 % le pasa lo mismo dentro del CTS (36) y a 80 % en la reparación
posterior al placement global (5). A 90 % las celdas móviles (169.187 µm²: 156.283 de celdas más
12.904 que el placement global suma como ajuste por densidad de pines) ya ocupan más que el
espacio libre del core: `GPL-0301 Utilization 100.620 % exceeds 100%`. Dato:
`asic/rom/resultados/u2_u74` a `u2_u90`, `falla.txt`.

**81. [B] ¿Qué métrica de congestión graficaron?**
Violaciones de DRC al inicio del ruteo detallado, largo de cables, slew, capacitancia,
antenas, área del die y WNS (`docs/figuras/utilizacion.png`). Las violaciones de ruteo
iniciales pasan de 2 a 40 % a entre 2.189 y 3.252 desde 50 %, y el router las lleva a 0 en todas
las corridas que terminan. El cable tiene su mínimo a 60 % y el slew sube hasta 99 pines a 73 %.
La señal que decide el límite es que a 74 % ya no hay lugar para las celdas. Dato:
`asic/final.md`; `docs/datos_informe.md`, sección 3.5.

**82. [B] ¿Por qué los terminales están donde están?**
Por función (D21, `asic/rom/pines.cfg`): entradas al oeste (botones, `clk` al centro, `rst_n`),
displays al este (cada bus contiguo y en orden de bits), LEDs al norte, SPI al sur. Cada
grupo iría a pads vecinos sin cruces y las señales entran por un lado y salen por el
opuesto. Con la configuración de v1 se comparó con dejarlos al flujo (u1_auto): +0,4 % de cable y
el mismo WNS. No se repitió con la configuración de D23. Dato: `asic/final.md`.

**83. [A] ¿Por qué Metal3 en los lados y Metal2 arriba y abajo?**
Cada capa tiene una dirección preferida de ruteo, alternada: Metal1 horizontal, Metal2
vertical, Metal3 horizontal, Metal4 vertical, Metal5 horizontal (tech LEF). Un terminal en
el lado oeste o este sale horizontal, así que va en Metal3; uno arriba o abajo sale vertical,
en Metal2. Se rutea de Metal2 a Metal5; Metal1 queda para el interior de las celdas y los
rieles.

**84. [B] ¿Cuánto costaría y qué limita esa estimación?**
A US$23.000/mm²: final 0,419 mm² → US$9.640; 73 % → US$5.410; estrategia 2 con la misma
configuración (s4_t100, 1,802 mm²) → US$41.437. El modelo lineal ignora el cupo mínimo de una
oblea multiproyecto, pads, anillo de sello, encapsulado, máscaras (costo fijo), volumen y
rendimiento de fabricación. Dato: `docs/datos_informe.md`, secciones 3.2 y 3.5.

**85. [A] Si el área de celdas sube 14,4 %, ¿por qué se aceptó el cambio?**
Porque el die casi no se mueve. `FP_CORE_UTIL = 40` dimensiona el core sobre el área de
síntesis, anterior al resizer, y los buffers que este agrega caben en espacio ya reservado. Del
14,4 % sobre v1, 2,3 % es del pipeline con B2 y 11,8 % del modelo de cable; el modelo de cable no
cambia el die (419.131 µm² con y sin él) y el pipeline lo sube 2,5 %, US$234. Lo que sube es la
utilización real, de 47,9 a 53,5 %. A cambio, el período baja de 24,5 a 21,5 ns, los MIPS suben
de 15,3 a 27,9 y el slew pasa de 546 a 0. El límite de 105 % de área era una regla del grupo, no
del enunciado. Dato: `docs/decisiones.md`, D23.

**86. [A] ¿Por qué el costo real crece más que lineal con el área?**
Costo por die = costo de la oblea / (dies por oblea × rendimiento). Con más área caben menos
dies por oblea y además baja el rendimiento, porque la probabilidad de que un defecto caiga
en el die crece con el área (rendimiento ≈ 1 / (1 + densidad de defectos × área / N)^N). Las
dos cosas se multiplican.

**87. [B] ¿Qué decisión pesó más en área y costo?**
La estrategia de memoria: con el mismo RTL y configuración, la 2 necesita un die 4,3 veces
mayor. Después la utilización: de 40 a 73 % el die baja 43,9 %. El pipeline y el modelo de cable
de D23 suben 14,4 % el área de celdas, pero solo 2,5 % el die (pregunta 85). Dato:
`docs/datos_informe.md`, secciones 3.2 y 3.5.

**88. [A] ¿Cómo es la red de alimentación?**
Rieles de VDD y VSS de 0,6 µm en Metal1 a lo largo de cada fila (las celdas los comparten),
y una grilla de franjas de 1,6 µm: 8 verticales en Metal4 cada 153,6 µm y 8 horizontales en
Metal5 cada 153,2 µm, unidas a los rieles por vías. No hay anillo alrededor del core. Es la
misma grilla que en v1, aunque el die creció. La caída de tensión peor, en la esquina típica, es
0,611 mV en VDD y 0,219 mV en VSS: nada frente a 5 V, porque el macro consume unos 9,6 mW (menos
de 2 mA). Dato: `docs/hechos_flujo.md`, sección 4.

**89. [A] ¿Para qué sirven las 2.497 celdas de tap?**
Conectan el pozo N a VDD y el sustrato a VSS cada 20 µm (`filltie`, `FP_TAPCELL_DIST`). Sin ellas, una
inyección de corriente puede encender el tiristor parásito (PNPN) que forman los
transistores de un inversor CMOS con el pozo y el sustrato: latch-up, un cortocircuito entre
VDD y VSS que se mantiene solo. Las celdas de borde (318) cierran las filas en los extremos.

**90. [A] ¿Y las 12.390 celdas de relleno?**
Llenan los huecos entre celdas para que los pozos, los implantes y los rieles sean continuos
a lo largo de cada fila. Son 5.942 de relleno simple (`fill_1`, `fill_2`) y 6.448 de
desacople (`fillcap_4` a `fillcap_64`): capacitores entre VDD y VSS que entregan carga local
en los picos de corriente del reloj. Ninguna tiene función lógica; ocupan 181.086 µm², menos que
en v1 aunque son más, porque el diseño más denso deja huecos más chicos. Dato:
`docs/hechos_flujo.md`, sección 8.

**91. [A] ¿Cuánta potencia consume y de qué depende?**
9,62 mW a 10 MHz en la esquina típica: 7,555 mW interna (cortocircuito y nodos internos de las
celdas), 2,062 mW de conmutación de las cargas y 2,05 µW de fuga. La dinámica es α·C·V²·f y la
fuga es despreciable en 180 nm, así que escala con la frecuencia: en la esquina que guarda
`metrics.json` (max_ff, 5,5 V, la última que procesa el flujo) la estimación pasa de 12,10 mW a
100 ns a 56,27 mW a 21,5 ns, 4,65 veces, igual a la razón de frecuencias. Ojo: esos 12,10 mW no
son la típica. Dato: `docs/hechos_flujo.md`, sección 10; `metrics.json` de `final` y `f2_t21p5`.

**92. [A] ¿Ese número es la potencia real?**
Es una cota inferior, y ahora se sabe por cuánto. El flujo no recibe actividad de conmutación,
así que casi todo lo que estima es reloj: secuencial 52,2 % y árbol de reloj
47,7 %, con la lógica combinacional en 3,6 µW. Con la actividad de una simulación del juego sobre
el netlist da 13,936 mW en la pantalla de inicio y 16,615 mW en la espera de 3 s, 45 y 73 % más
que los 9,620 mW del flujo (en v1, 11,504 y 12,755 contra 8,971). La fuga sí cambia con la
temperatura: 2,05 µW a 25 °C y 13,1 µW en la esquina lenta, a 125 °C. Dato:
`asic/potencia/resultado.md`.

**93. [A] ¿Cómo es el árbol de reloj?**
Un H-tree de 4 niveles con raíz `clkbuf_16`: el CTS inserta 122 buffers (121 `clkbuf_8` y 1
`clkbuf_16`) para 964 flip-flops agrupados en 105 sumideros, más 78 cargas ficticias que
equilibran las ramas. En v1 eran 75 buffers en 3 niveles: con los RC medidos, el largo máximo de
cable sin buffer baja de 11.309 a 4.491 µm. La latencia del reloj va de 1,295 a 1,498 ns en la
esquina típica y de 2,359 a 2,720 ns en max_ss. Dato: `docs/hechos_flujo.md`, sección 6.

**94. [A] ¿Cómo se obtienen los parásitos que usa el STA?**
Después del ruteo, OpenROAD extrae la resistencia y la capacitancia de cada cable con las
reglas del PDK para tres esquinas de interconexión (min, nom, max) y escribe tres archivos
SPEF; cada una de las 9 esquinas de STA lee el de su grupo. Antes del ruteo el flujo solo
puede estimarlos: por omisión con el promedio del tech LEF, que subestima la capacidad entre 2,3
y 2,9 veces; la configuración final le da al resizer y al CTS los valores del tech LEF escalados por
el factor medido en cada extracción (`LAYERS_RC`, preguntas 58 y 59). Dato: `docs/modelo_cable.md`, secciones 1 y 2.

---

## 7. Signoff y layout (3.6)

**95. [B] ¿Qué resultados de signoff tienen?**
DRC de Magic 0, DRC de KLayout con el deck de GlobalFoundries 0 marcadores (684 reglas
evaluadas), LVS 0 diferencias, 0 nets con violación de antena (el flujo insertó 1 diodo). Dato:
`cierre.md`, `drc_klayout/resumen.md`.

**96. [B] ¿Qué compara el LVS?**
Netgen compara el circuito extraído del layout (transistores y conexiones que Magic saca del
GDS) con el netlist del diseño con sus conexiones de alimentación. Si coinciden, el layout es
el circuito que se sintetizó: no hay cortos, cables abiertos ni celdas cambiadas.

**97. [B] ¿Por qué dos DRC y cómo saben que el de KLayout funciona?**
LibreLane salta el DRC de KLayout porque la copia del PDK que instala ciel no trae las
reglas (`asic/drc/ORIGEN.md`); se corrió aparte el deck de GlobalFoundries. Control
positivo: a una copia del GDS se le agregó un trazo de Metal1 de 0,20 µm y dos separados por
0,15 µm (mínimos 0,23 µm), y el deck marcó exactamente esas dos violaciones (M1.1 y M1.2a).
Dato: `drc_klayout/control_positivo.md`.

**98. [B] ¿Qué violación apareció durante el desarrollo?**
Una antena en la estrategia 2 con el RTL y la configuración de v1 (todas las corridas `s2_*`).
En s2_t100, el net `net3342` reparte una señal de alto fanout entre cinco buffers y cubre 666 ×
364 µm; en el pin `fanout3341/I` la razón entre el área lateral del Metal2 conectado (sus paredes:
perímetro por espesor) y el área de la compuerta es 449,1, 1,12 veces el máximo de 400. Con el
core y la configuración de D23 desaparece: `s4_t100` cierra con 0 nets y 6 diodos que pone el
flujo. La estrategia 1 nunca la tuvo. Dato: `asic/ff/resultados/s2_t100/antenna_summary.rpt`,
`antena_antes.png`; `asic/ff/resultados/s4_t100/metrics.json`.

**99. [A] ¿Qué es el efecto antena?**
Al fabricar, cada capa de metal se graba con plasma, que deposita carga en el metal. Si un
tramo largo está conectado solo a compuertas (óxido delgado) y todavía no a ninguna difusión
que la descargue, la carga se acumula y puede romper el óxido. La regla limita el área de
metal (de su cara o de sus paredes, según la capa) por área de compuerta.

**100. [B] ¿Cómo la resolvieron?**
Con el RTL de v1, de dos formas. Inserción heurística de diodos: 0 violaciones, pero 36.385
celdas de antena, 18 % más área y 16 ns menos de slack. Más iteraciones y margen en la
reparación de antenas del ruteo global (`GRT_ANTENNA_REPAIR_ITERS = 6`,
`GRT_ANTENNA_REPAIR_MARGIN = 30`): 0 violaciones con 258 celdas de antena en vez de 150 y sin
más área. Con la configuración final ya no hace falta ninguna: `s4_t100` cierra sin esas
perillas. La estrategia 1 nunca la tuvo. Dato: `docs/datos_informe.md`, secciones 3.2 y 3.6.

**101. [A] ¿Cómo arregla un diodo la antena, y qué otra opción hay?**
El diodo de antena es una unión en inversa conectada al net: en operación no conduce, pero
durante la fabricación le da a la carga un camino a sustrato. La otra opción es el "jumper":
cortar el tramo largo y pasarlo por una capa superior, para que la compuerta quede conectada
al metal largo recién cuando se fabrica esa capa.

**102. [A] ¿Por qué no hay figura del net después de reparar?**
En las corridas reparadas el net con el mismo nombre (`net3342`) es otro: los diodos y los
buffers extra renumeran los nets. Se comparó qué celdas conecta en cada DEF y no coincide,
así que se borraron esas figuras y la evidencia del arreglo son los `antenna_summary.rpt` con
0 violaciones.

**103. [B] ¿Cómo marcaron el register file, la ALU y el contador en el layout?**
Sus celdas conservan el nombre de la instancia como prefijo en el DEF (`u_soc.u_core.u_rf/`,
`u_soc.u_core.u_id.u_alu/`, `u_soc.u_periph.u_cycles/`). Un script de KLayout
(`asic/layout/anotar.py`) colorea cada prefijo y genera `bloques.png` y `bloques.lyrdb` para
repetirlo en la interfaz (`docs/layout.md`). Las figuras se regeneraron con la corrida final
de D23.

**104. [B] ¿Por qué el register file mide 96.936 µm² en la figura y 80.349 µm² en la síntesis?**
El resizer agrega buffers dentro del módulo en el layout. Los porcentajes de la figura (49,4 %,
6,0 % y 2,0 %) son sobre 196.080 µm² de celdas lógicas, sin las de tap ni las de borde. Dato:
`asic/rom/resultados/final/layout/bloques.txt`.

**105. [A] ¿Por qué el ruteo detallado parte con 2 violaciones y en v1 con 1.546?**
El ruteo detallado es iterativo: la primera pasada rutea todo aunque queden cortos y
separaciones mal, y las siguientes rerutean las zonas con problemas. En la corrida final la serie
es 2, 0, 430, 3 y 0: la reparación después del ruteo global le entrega un diseño mucho más limpio
que en v1 (1.546, 501, 379 y 0), y las 430 aparecen porque, tras el primer cierre, el flujo inserta
un diodo de antena y vuelve a rutear. En v1, con el orden fijo de terminales (D21), la primera
pasada partía con 1.546 contra 6 sin orden. Dato: `docs/datos_informe.md`, sección 3.6;
`metrics.json`.

---

## 8. Simulación post-síntesis (3.7)

**106. [B] ¿Cómo simularon el netlist?**
`make post-synth`: el mismo testbench de puertos (`tb/post_synth_tb.v`) y los mismos
estímulos en ciclos absolutos para el RTL y para el netlist de Yosys, con los modelos de
celdas del PDK compilados con `-DFUNCTIONAL` (sin bloques `specify`, sin retardos). Se
comparan las trazas de LEDs y display. Dato: `asic/sim/README.md`.

**107. [B] ¿Qué cambiaron para simular y por qué es válido?**
`CYCLES_PER_TENTH = 1` (con `-D` del assembler, así el display muestra ciclos y las esperas
de segundos duran decenas de ciclos) y `DebounceDivBits = 2` (un botón se acepta en unos 12
ciclos). Es el mismo `game.s` y la misma configuración en las dos simulaciones, como pide el
enunciado.

**108. [B] ¿Cómo sabe el testbench qué botón apretar si el LED lo elige un LFSR?**
Los estímulos se calibraron corriendo el RTL por etapas y leyendo en la traza qué LED se
encendió y en qué ciclo (`asic/sim/calibrar.py`). El LFSR se siembra con CYCLES en la
pulsación de inicio y todo es determinista, así que el netlist ve exactamente lo mismo. Con el
core nuevo se recalibraron: el LED de la ronda 1 se enciende en el ciclo 615 (781 en v1) y las
pulsaciones caen en 635, 1.373 y 1.733. Dato: `asic/sim/README.md`.

**109. [B] ¿Qué muestran los resultados?**
Trazas idénticas (17 líneas, la inicial y 16 cambios de salida, en 4.500 ciclos), sin X. La
ronda correcta mide 51 ciclos en las dos (display 51 en el ciclo 1.033), la pulsación incorrecta
muestra EE en el ciclo 1.405 y la ronda vuelve a 02 en el 1.507 en vez de pasar a 03; el
reintento mide 51 otra vez (ciclo 2.131). En v1 eran 57 ciclos: el core nuevo gasta menos ciclos
por instrucción. Dato: `asic/sim/resultado.md`.

**110. [B] ¿Cómo saben que la comparación detectaría un error?**
Control negativo (`make post-synth-control`): se atrasa 8 ciclos la pulsación de la ronda 01
solo en el netlist; el display muestra 59 en vez de 51 y la comparación da FAIL. Con 7 ciclos
no cambia, porque el lazo de polling dura 8 ciclos (pregunta 77). Dato: `asic/sim/resultado.md`.

**111. [A] Si el STA cierra, ¿para qué simular el netlist?**
El STA revisa tiempos, no función. La simulación del netlist confirma que la síntesis no
cambió el comportamiento: valores iniciales descartados, diferencias entre cómo simula y cómo
sintetiza un `case` o una variable sin asignar, o lógica optimizada de más. Para todas las
entradas está la equivalencia formal, corrida fuera del flujo porque su paso `Yosys.EQY` falla
con esta imagen: el flujo clásico de Yosys prueba 976 de 976 celdas `$equiv` contra el netlist de
síntesis y 968 de 968 contra el post-PnR, y un miter desde reset pasa a 24 y a 100 pasos; eqy
deja sin decidir 1 de sus 30 particiones, por estados iniciales inalcanzables. Dato:
`docs/equivalencia.md`, sección 1.

**112. [A] El banco de registros no tiene reset. ¿Por qué no aparecen X en el netlist?**
Por tres razones. El programa escribe cada registro antes de leerlo (D4). Los registros de
decode se cargan en el mismo flanco que la instrucción y todo lo que los usa está condicionado a
`instr_valid_i`, que vale 0 el primer ciclo. Y el write-through hace que una lectura en el mismo
flanco de una escritura tome el dato nuevo y no el valor sin inicializar del arreglo. Un monitor
sobre el juego completo no encontró valores X usados en 620.217 escrituras al banco, y sin
write-through (mutación `MUTA_FWD`) cuenta 77, así que el monitor funciona. Dato:
`docs/verificacion/integracion.md`.

**113. [B] ¿Hicieron la simulación con SDF?**
Sí, era opcional. Se simuló el netlist con el SDF de una corrida completa con la configuración
de simulación (`d2_pnr`) en las esquinas típica, lenta y rápida, tres veces cada una y con dos
simuladores: las 18 trazas son idénticas a la del RTL, sin X. Icarus 13.0 anota los retardos pero
no evalúa los timing checks; CVC 7.00b evalúa los 7.173 checks y no reporta violaciones, y su
control positivo (entradas 1 ns después del flanco) da 8. Además el netlist real de la corrida
final con su SDF típico reproduce los 320.000 ciclos de `make post-synth-final`. Dato:
`asic/sim/resultado_sdf.md`.

**114. [B] ¿Cómo verificaron que el cambio de D23 no altera el comportamiento?**
Con cinco cosas. `make check`: 80 pruebas del assembler y seis testbenches, con las dos
estrategias. Equivalencia funcional, no ciclo a ciclo porque los ciclos cambian a propósito:
`isa_test` da las mismas 46 escrituras al banco, 22 accesos al bus y 2 salidas que v1 y que
116fa20. Dos programas para los seis riesgos de la pregunta 121 (`hazard_test`, 56
comprobaciones, y `hazard_review`, 48, de un revisor), con trazas iguales a v1. Cuatro mutaciones
del write-through y del enable de lectura, todas detectadas (preguntas 123 y 124), aunque
`isa_test` sola no ve las dos del revisor. Y el monitor de X: 0 en 620.217 escrituras. Dato:
`docs/verificacion/integracion.md`, `docs/revision_frente_a.md`.

---

## 9. RTL del Espino Core y del SoC

**115. [B] Recorre un `add` ciclo a ciclo.**
En el flanco N se cargan a la vez el registro de instrucción, los operandos (lectura registrada
del banco, con rs1 y rs2 tomados de la salida combinacional de la ROM, `a_next_o`) y las 82
salidas del decode; `pc_q` avanza. En el ciclo N la ALU suma. En el flanco N+1 se escribe `rd`
(`commit`) y, en el mismo flanco, se cargan la instrucción siguiente y sus operandos, con
write-through si lee el registro que se acaba de escribir. Un ciclo, sin ciclo de espera:
`rf_ready_o` vale 1 siempre. Dato: `docs/pipeline.md`, sección 1.

**116. [B] ¿Y un `lw`?**
Igual hasta la ejecución, donde la ALU calcula la dirección, la LSU emite la lectura y guarda los
dos bits bajos de la dirección (B2), y `busy` detiene el pipeline un ciclo. Durante el stall el
banco no vuelve a leer (`rf_rd_en_o = ~stall_i`), así que los operandos de la carga se conservan.
En el segundo ciclo llega el dato registrado de la memoria o del periférico, la LSU lo alinea con
el offset registrado y en el flanco del commit se escribe en el banco mientras se leen los
operandos de la instrucción siguiente, con write-through si usa ese registro: dos ciclos, sin
burbuja por la dependencia. Dato: `docs/pipeline.md`, secciones 1 y 2.

**117. [B] ¿Y un salto tomado?**
En la ejecución `pc_set` carga el PC con el destino y la instrucción secuencial que ya se
había pedido llega marcada como inválida (`valid_q = 0`). Esa instrucción registra igual sus
operandos y su decode, pero sin efecto, porque la escritura al banco, el acceso a memoria y
`pc_set` están condicionados a `instr_valid_i`: una burbuja de un ciclo, dos en total. El destino
se calcula como `pc + imm` (saltos y `jal`) o `(rs1 + imm) & ~1` (`jalr`). Dato:
`docs/pipeline.md`, sección 2 (riesgo 5).

**118. [B] ¿Cómo es el pipeline del core en la corrida final?**
Una instrucción por ciclo, dos las cargas y dos los saltos tomados. La clave es que la ROM es
combinacional: la instrucción que pide el fetch está en su salida (`a_next_o`) un ciclo antes de
cargarse en el registro de instrucción. Con ella el core pide la lectura de rs1 y rs2 y registra
el decode en el mismo flanco en que carga la instrucción, así que al ejecutar todo está listo y
desaparece el ciclo de espera. El banco sigue con lectura registrada; volverlo combinacional era
B4, que cerraba recién a 60 ns. CPI de 2,665 a 1,665: 27,9 MIPS contra 15,3. Dato:
`docs/pipeline.md`, sección 1.

**119. [B] ¿Qué es el parámetro `EarlyRead` y para qué sirve?**
Elige la temporización del core. Con `EarlyRead = 1` el decode y la lectura del banco salen de la
instrucción combinacional (`instr_next_i`): un ciclo por instrucción. Con `EarlyRead = 0` queda el
bloque `g_wait` con `ops_valid_q`, la temporización de v1 con ciclo de espera. `pochoco_soc` lo
fija en 1 con la estrategia 1 y en 0 con la 2, a la que no le conviene anticipar (pregunta 28).
Así `make check` y `make equiv` cubren las dos temporizaciones, la estrategia 2 reproduce v1 (CPI
2,665 y 388.411 escrituras al banco) y volver atrás es cambiar un parámetro en
`SYNTH_PARAMETERS`. Dato: `docs/pipeline.md`, sección 1; `rtl/pochoco_soc.v`.

**120. [B] ¿Qué hacen `ops_valid_q` y el controlador?**
`ops_valid_q` ya no existe en la corrida final: está en el bloque `g_wait`, que solo se genera
con `EarlyRead = 0` (estrategia 2), donde vale 1 desde el segundo ciclo de cada instrucción. Con
`EarlyRead = 1` los operandos están listos al empezar cada ciclo y `rf_ready_o = 1`. El
controlador detiene el pipeline si hay una instrucción válida sin operandos listos o si la LSU
espera un dato (`stall = rf_wait | lsu_busy`), así que en la final solo detiene por la LSU, y
carga el PC con el destino si hay salto tomado o `jal`/`jalr` (`pc_set`). Dato:
`rtl/espino_core/espino_id_stage.v`, bloques `g_early` y `g_wait`.

**121. [A] ¿Qué riesgos aparecen con la lectura anticipada y cómo se resuelve cada uno?**
Seis, cada uno con su sección en `sw/hazard_test.s`. Escritura seguida de lectura del mismo
registro: el write-through. Carga seguida de uso: el banco no lee durante el stall y la lectura
cae en el commit, donde el write-through entrega el dato. `jal` o `jalr` seguido de uso del link:
el destino se carga después de la burbuja, con el arreglo ya escrito. Escrituras a x0: la
escritura y el adelanto excluyen la dirección 0. Salto tomado: la instrucción descartada llega
con `instr_valid_i = 0` y no tiene efecto. Reset: `valid_q` parte en 0 y nada usa los registros
sin reset antes de cargarlos. `hazard_test` (56 comprobaciones) y `hazard_review` (48) dan trazas
iguales a v1. Dato: `docs/pipeline.md`, sección 2.

**122. [B] ¿Qué es el write-through del banco de registros y por qué hace falta?**
Un camino de adelanto dentro del banco. Con la lectura anticipada, la escritura de una
instrucción y la lectura de la siguiente caen en el mismo flanco, cuando el arreglo todavía tiene
el valor viejo. Si en ese flanco se escribe el mismo registro que se lee y no es x0, la salida
registrada toma `wdata` en vez del arreglo. No es una lectura combinacional: la salida sigue
siendo un flip-flop, solo cambia de dónde viene su entrada. No agrega flip-flops pero sí área:
junto con el enable de lectura, los `mux2_2` del banco suben de 622 a 796 (en parte porque la
síntesis rehízo el árbol de lectura) y el módulo de 73.656 a 80.349 µm² (9,1 %). Dato: `rtl/espino_core/espino_register_file.v`, `asic/sintesis.md`.

**123. [A] ¿Qué pasa si se quita el write-through?**
Se rompe el programa, y está probado. La mutación `MUTA_FWD`, detrás de un `ifdef` que solo se
activa por línea de comandos, pone en 0 las señales de adelanto. Con `hazard_test` contra v1 las
trazas difieren en el evento 6 del banco (la referencia escribe `0000000f` y el mutante
`xxxxxxxx`) y en el primer acceso al bus, y el monitor cuenta 77 valores desconocidos usados (36
en el dato de escritura y 41 en operandos de la ALU); con `hazard_review`, 63. Salen X porque el
banco no tiene reset. Con la estrategia 2 (`EarlyRead = 0`) la mutación no cambia nada. Dato:
`docs/verificacion/integracion.md`, filas 8 y 10 a 12.

**124. [A] ¿Por qué el banco no vuelve a leer mientras la carga espera?**
Porque leería demasiado pronto. Una carga dura dos ciclos; si el banco leyera los operandos de la
instrucción siguiente en el flanco intermedio, esa lectura no se repetiría en el commit y no vería
el dato cargado, ni por el arreglo ni por el write-through. Por eso `rf_rd_en_o = ~stall_i`:
durante el stall los puertos conservan los operandos de la carga, que la ALU sigue usando para la
dirección, y la lectura siguiente cae justo en el commit. La mutación `MUTA_LOADUSE` lo comprueba:
las trazas difieren en el evento 84 del banco, en el 24 del bus y en el display, y con
`hazard_review` el monitor cuenta 679 X usados. Dato: `docs/pipeline.md`, sección 3.4;
`docs/verificacion/integracion.md`.

**125. [B] ¿Cómo se implementa x0?**
`x0` no se almacena: el banco tiene registros de x1 a x15, una escritura a x0 se ignora y una
lectura de la dirección 0 entrega 0 por hardware. En la BRAM del P2 valía 0 solo porque la
memoria partía en cero. El write-through también excluye x0 (`wr = we_i & (waddr_i != 0)`, y la
prueba de la dirección 0 va antes del adelanto), lo que verifican las comprobaciones c42 a c45 de
`hazard_test`. Dato: `rtl/espino_core/espino_register_file.v`.

**126. [B] ¿Por qué los shifts se ejecutan como suma?**
La ALU del repositorio base tiene los shifts comentados para ahorrar LUTs de la FPGA, y el
`case` cae en el valor por defecto, que es una suma. El assembler los rechaza (salvo
`--allow-shifts`) y `game.s` desplaza sumando un registro consigo mismo.

**127. [B] ¿Cómo decide el SoC si un acceso va a memoria o a un periférico?**
Por el bit 31 de la dirección: 0 es memoria, 1 son periféricos (`0x8000_0000`). Dentro de
los periféricos el bit 16 separa la placa (LEDs, display, botones, CYCLES) del SPI. Como las
lecturas son registradas, `rd_is_per` guarda a quién se le pidió el dato para elegir la
respuesta en el ciclo siguiente.

**128. [A] ¿Cómo se escriben bytes y medias palabras?**
La LSU arma las habilitaciones de byte (`data_be`) según el tipo y `addr[1:0]`, y replica el
dato en las cuatro posiciones (un byte ×4, media palabra ×2); la memoria escribe solo los
bytes habilitados. En la lectura, la LSU elige el byte o la media palabra con la copia de
`addr[1:0]` que registró al emitir la carga (`boff_q`, B2), no con la salida de la ALU, y extiende
el signo si es `lb` o `lh`. Por eso la alineación salió de la ruta crítica. Dato:
`rtl/espino_core/espino_load_store_unit.v`.

**129. [A] ¿Qué pasa con una instrucción ilegal?**
El decodificador levanta `illegal_insn`, pero el core no lo usa. Con un opcode desconocido (por
ejemplo la palabra 0) todas las salidas quedan en su valor por defecto (sin escritura, sin acceso
a memoria, sin salto) y funciona como un NOP. Con un opcode válido y un `funct3` ilegal, se
mantienen las señales de ese opcode: un LOAD o un STORE hace un acceso de palabra, y un JALR con
`funct3` ≠ 0 igual salta. El assembler nunca genera esas codificaciones. Con la lectura
anticipada, además, `illegal_insn_o` sale de la instrucción siguiente y no se registra con el
decode: un trap futuro tendría que registrarla (observación O3). Dato:
`docs/revision_frente_a.md`, O3.

**130. [B] ¿Cómo funciona el debounce?**
Un contador de 15 bits da un tick cada 2¹⁵ ciclos (3,28 ms a 10 MHz). Cada botón tiene un
registro de 3 muestras; la salida cambia solo cuando las tres muestras son iguales, así que
acepta un cambio en unos 10 a 13 ms y un rebote no la mueve. Dato: `rtl/debounce.v`.

**131. [A] ¿Por qué CYCLES tiene reset y el banco de registros no?**
CYCLES debe partir en un valor conocido para que la simulación sea determinista (sin reset
sería X en simulación y la semilla del LFSR también) y para que RTL y netlist vean lo mismo.
El banco no lo necesita porque el programa escribe cada registro antes de leerlo, y sin
reset sus 480 bits son `dffq_1`, más chicos.

---

## 10. Assembler

**132. [B] ¿Cómo funciona el assembler?**
Dos pasadas. En la primera lleva la dirección desde 0, guarda cada etiqueta con su dirección
y cada `.equ` con su valor, y calcula el tamaño de cada instrucción (`li` puede ser 1 o 2
palabras). En la segunda codifica cada línea con la tabla de símbolos completa, lo que
permite saltar a etiquetas definidas más abajo. Python 3 sin dependencias.

**133. [B] ¿Cómo se expande `li`?**
Si cabe en 12 bits con signo, `addi`; si los 12 bits bajos son 0, `lui`; si no, `lui` +
`addi`. Como `addi` extiende el signo, si el bit 11 está en 1 la parte alta se redondea:
hi = (valor + 0x800) >> 12, lo = valor − hi·4096. Ejemplo: `li x4, 0x04C11DB7` → `lui x4,
0x04C12` y `addi x4, x4, −585`.

**134. [B] ¿Cómo se codifica un salto?**
El inmediato es la dirección de la etiqueta menos la de la instrucción, en bytes, y debe ser
par. Rango ±4 KiB en las bifurcaciones (12 bits, el bit 0 implícito) y ±1 MiB en `jal`. El bit de
signo del inmediato está en el bit 31 en todos los formatos; en B y J el resto de los bits
va reordenado para que coincida con las posiciones de S y de I/U, y el hardware necesita
menos multiplexores.

**135. [B] ¿Cómo saben que el assembler es correcto?**
80 pruebas (`make test`): los tres ejemplos del repositorio base dan el mismo `.hex` byte a
byte (golden), codificaciones calculadas a mano, pseudo-instrucciones, directivas, `-D`, 28
pruebas de validación (errores, con casos límite en los rangos), ida y vuelta con el desensamblador, y 7 de las
salidas Verilog.

**136. [B] ¿Qué errores detecta?**
Registro desconocido o mayor que x15 (RV32E), shift sin `--allow-shifts`, mnemónico o
directiva desconocidos, etiqueta o constante repetida o no definida, inmediato fuera de
rango, operandos de más o de menos, operando de memoria mal escrito, salto impar o fuera de
alcance, y programa demasiado largo. Siempre con número de línea.

**137. [B] ¿Para qué sirve `-D`?**
Pisa un `.equ` sin editar el archivo. Así la simulación usa el mismo `game.s` con
`CYCLES_PER_TENTH = 1` y el macro con 1.000.000.

---

## 11. Programa del juego

**138. [B] ¿Cómo se elige el LED de cada ronda?**
LFSR de Galois de 32 bits con polinomio `0x04C11DB7` (primitivo, período 2³² − 1),
desplazado sumando el registro consigo mismo (no hay shifter). Se siembra con CYCLES en la
pulsación de inicio y avanza en cada vuelta del lazo de polling; los dos bits bajos eligen el
LED. Por eso existe la pantalla de inicio: sin ella el primer LED sería siempre el mismo.

**139. [B] ¿Desde cuándo y hasta cuándo se mide el tiempo?**
Desde la lectura de CYCLES inmediatamente después de encender el LED objetivo hasta la
lectura de CYCLES apenas se lee el botón correcto. `cyc2tenths` divide por restas
sucesivas, trunca hacia abajo y satura en 99.

**140. [B] ¿Qué pasa con un botón incorrecto?**
`miss`: muestra EE, apaga los LEDs, espera `ERROR_TENTHS` y vuelve a `round_begin` sin tocar
aciertos ni suma, así que la ronda se repite completa, con sus tres segundos.

**141. [B] ¿Por qué el promedio divide por `RONDAS` y no por 10?**
Para que cambiar `RONDAS` cambie también el divisor. Con un 10 fijo, el juego terminaría en
otra ronda pero seguiría dividiendo por 10.

**142. [B] ¿El programa usa stack?**
No. Las subrutinas no son recursivas: cada nivel tiene su registro de retorno (x1 para
`show_bcd` y `wait_tenths`, x15 para `div` y `cyc2tenths`), y ninguna escribe x2 a x8, donde
vive el estado del juego. Por eso el juego no usa la RAM de datos.

---

## 12. Preguntas de "¿por qué no...?"

**143. [B] Si cierra a 21,5 ns, ¿por qué la corrida final es a 100 ns?**
El enunciado fija T = 100 ns y 40 % para la corrida final. La frecuencia máxima se reporta
con el barrido; la final cierra con 65,7 ns de margen.

**144. [A] ¿Por qué la biblioteca de 7 tracks y 5 V?**
`mcu7t5v0` es la de 7 pistas y 5 V, la que LibreLane usa por defecto con gf180mcuD, y por
eso las esquinas son de 4,5, 5,0 y 5,5 V. "7 pistas" es el alto de la celda medido en pistas
de ruteo: 7 × 0,56 µm = 3,92 µm, el alto de cada fila (159 filas de 1.116 sitios de 0,56
µm). Una de 9 pistas tiene celdas más altas, con lugar para transistores más anchos, a
cambio de área; no se probó porque el enunciado no lo pide y el diseño cierra con margen.

**145. [A] ¿El macro funcionaría si se fabrica?**
Lógicamente sí: DRC, LVS y antenas limpios, timing cerrado en 9 esquinas, el RTL y los dos
netlists equivalentes por el flujo clásico de Yosys, y la simulación con SDF idéntica al RTL en
tres esquinas. Falta lo que no es parte de un macro: pads de I/O, anillo de sello, encapsulado y
un plan de pruebas. Por timing aguanta hasta 46,5 MHz; con estas constantes el reloj tiene que
ser de 10 MHz exactos, porque a otra frecuencia las esperas y los tiempos mostrados se escalan
(a 5 MHz la espera de 3 s dura 6 s).

**146. [A] ¿Qué harían con una semana más?**
De la lista que teníamos con v1 casi todo se hizo: B2 entró, B5 se descartó con medición, el slew
quedó en 0 y la simulación con SDF y la equivalencia formal están hechas sobre el netlist nuevo.
Lo que queda: registrar `illegal_insn_o` (observación O3); medir el período mínimo de la estrategia
2 bajo 32 ns, que el límite de 40 minutos por corrida no dejó; repetir con la configuración nueva
los terminales automáticos y el die 1,6:1; medir la potencia con actividad real a la frecuencia
máxima; y cerrar la partición que eqy deja sin decidir, aunque la prueba ya la da el flujo
clásico de Yosys.

**147. [A] ¿Qué quedó imperfecto en el cambio?**
Cuatro cosas. `illegal_insn_o` queda una instrucción adelantada (pregunta 129); hoy es inocuo
porque no hay trap. Quedan una violación de capacitancia y 21 de fanout, todas en el árbol de
reloj (pregunta 60), contra 36 y 62 en v1. El hold baja de 0,178 a 0,173 ns, con los mismos 5 buffers
de hold que en v1; la propuesta anticipaba 0,134 ns, que era la candidata sin
modelo de cable. Y hay más que defender: un camino de datos nuevo, un parámetro de temporización y
una corrección del modelo de cable. A cambio, el rendimiento sube 82 % (de 15,3 a 27,9 MIPS) y el
slew queda en 0. Dato: `docs/revision_frente_a.md`, O3; `docs/decisiones.md`, D23; `cierre.md` de
`final` y de `v1_final`.
