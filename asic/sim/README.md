# Simulación post-síntesis (sección 3.7)

`make post-synth` corre el RTL y el netlist de celdas estándar con el mismo testbench y
los mismos estímulos, compara las trazas ciclo a ciclo y termina en PASS o FAIL. El
resultado queda en `asic/sim/resultado.md`.

## Qué se simula

- Testbench `tb/post_synth_tb.v`: usa solo los puertos de `asic_top` (sin referencias
  jerárquicas), lee los estímulos de un archivo (`<ciclo> <máscara de botones>`, ciclos
  absolutos desde que se suelta `rst_n`) y escribe una línea por cada cambio de los LEDs
  o del display, con los 7 segmentos decodificados a hexadecimal (activos en alto,
  orden {G,F,E,D,C,B,A}). Un patrón con bits X se escribe como X.
- Netlist: `asic/sim/runs/sim_rom/06-yosys-synthesis/asic_top.nl.v`, sintetizado por
  LibreLane hasta `Yosys.Synthesis` con `asic/sim/config.yaml`, que se genera desde la
  configuración final (`asic/sim/generar_config.py`) y solo cambia dos cosas: la ROM y
  el parámetro del debounce. Modelos de celdas: `gf180mcu_fd_sc_mcu7t5v0.v` y
  `primitives.v` del PDK, compilados con `-DFUNCTIONAL` (sin bloques `specify`: cero
  retardo).
- RTL: `rtl/*.v` y `rtl/espino_core/*.v` con la misma ROM, y `DebounceDivBits` pasado
  como parámetro con el mismo valor.

## Configuración común (qué cambió respecto del macro y por qué)

| Qué | Macro | Simulación | Por qué |
|---|---|---|---|
| `CYCLES_PER_TENTH` (game.s, `-D`) | 1.000.000 | 1 | Una "décima" es un ciclo: el display muestra directamente los ciclos medidos (saturados en 99) y las esperas de 30, 12 y 10 décimas duran decenas de ciclos en vez de millones. El programa es el mismo `sw/game.s`; cambian 2 palabras de la ROM (los `li` de la constante). |
| `DebounceDivBits` | 15 | 2 | Tick del debounce cada 4 ciclos en vez de cada 32.768: un botón se acepta en unos 12 ciclos. Va por `SYNTH_PARAMETERS` en el netlist (queda horneado) y por parámetro en el RTL. |
| Estímulos | botones físicos | `asic/sim/estimulos.txt` | Ciclos absolutos fijos para que las dos simulaciones vean lo mismo. |
| Período | 100 ns | 100 ns | Sin efecto en una simulación sin retardos; es el real para la variante con SDF. |

Las demás constantes del juego no cambian (`RONDAS = 10`, esperas, patrones).

## Escenario (`asic/sim/estimulos.txt`)

Lo construye `asic/sim/calibrar.py` corriendo el RTL por etapas: el LED objetivo de
cada ronda lo decide el LFSR del programa (sembrado con CYCLES en la pulsación de
inicio), así que el botón correcto se lee de la traza del RTL y la pulsación siguiente
se agrega en ciclos absolutos. Cada pulsación llega 20 ciclos después de que se
enciende el LED y dura 60 ciclos.

| ciclo | botones | qué pasa |
|---|---|---|
| 300 a 360 | 0001 | pulsación de inicio: siembra el LFSR; 4 LEDs y display 01 en el ciclo 388 y 426 |
| 801 a 861 | 0010 | ronda 1: LED objetivo 0010 encendido en el ciclo 781; acierto, el display muestra 57 (ciclos medidos) en el ciclo 1574 |
| 2141 a 2201 | 0010 | ronda 2: LED objetivo 0001 en el ciclo 2121; botón incorrecto: EE en el ciclo 2181, LEDs apagados en 2183, la ronda vuelve a 02 en 2353 |
| 2719 a 2779 | 0001 | reintento de la ronda 2: LED 0001 en 2699; acierto, 57 en el ciclo 3492; sigue la ronda 03 |

El valor 57 es determinista: 20 ciclos hasta la pulsación, 2 del sincronizador, 8 a 12
del debounce y el resto del lazo de polling y de la lectura de CYCLES del programa.

## Resultado

`asic/sim/resultado.md`: trazas idénticas (17 cambios de salida en 4.500 ciclos), 0
valores X en las salidas del netlist, mismo 57 en las dos rondas correctas, EE y
ronda que no avanza después de la pulsación incorrecta.

## Control negativo

`make post-synth-control` demuestra que la comparación distingue trazas distintas: corre
el netlist con una copia de los estímulos donde la pulsación de la primera ronda llega
`ATRASO` ciclos tarde (`asic/sim/atrasar.py` -> `build/post_synth/estimulos_control.txt`)
y la compara con la traza del RTL con los estímulos originales. El objetivo termina bien
solo si `comparar.py` da FAIL. El resultado se agrega como sección "Control negativo" a
`asic/sim/resultado.md` (`make post-synth` reescribe ese archivo; correr el control
después). `ATRASO = 6` es el atraso más chico que cambia la traza: el programa lee
CYCLES en un lazo de polling de 13 ciclos (57, 70, 83, 96 ciclos medidos para atrasos
de 0, 6 a 20, 30 y 40), así que un atraso de 5 cae en la misma vuelta del lazo y la
traza queda idéntica (`make post-synth-control ATRASO=5` da PASS y el objetivo falla).

## Extras

- `make post-synth-final`: el netlist de la corrida final (constantes reales, ROM
  real, `DebounceDivBits = 15`) con una pulsación de inicio real
  (`asic/sim/estimulos_final.txt`): pantalla de inicio tras el reset y, unos 280.000
  ciclos después (el debounce real), los cuatro LEDs y el 01 de la primera ronda;
  comparado con el RTL en `asic/sim/resultado_final.md`.
- `make post-pnr-sdf`: lo mismo con el SDF de la esquina típica de la corrida final
  (`$sdf_annotate`, modelos compilados con `-gspecify -ginterconnect` para que tengan
  sus bloques `specify` y los retardos de interconexión del SDF). Resultado en
  `asic/sim/resultado_sdf.md`: la simulación anotada completó una vez los 320.000
  ciclos (4 min 19 s de CPU) con la misma traza que el RTL (PASS), pero los intentos
  siguientes de correr el mismo binario abortaron al leer el SDF con una aserción
  interna de vvp (`vpi_scan(vpiHandle): Assertion 0 failed`, Icarus 14.0-devel).
  El objetivo borra la traza anterior antes de correr para que un aborto no dé un
  PASS falso; si aborta, hay que relanzarlo. Sin `-ginterconnect` iverilog omite la
  anotación (`Omitting $sdf_annotate()`), y sin `-gspecify` ni siquiera compila los
  bloques `specify`.
- Para rehacer los estímulos tras cambiar el programa: `make asic/sim/estimulos.txt`
  (o `python3 asic/sim/calibrar.py`).
