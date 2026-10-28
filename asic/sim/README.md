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
| `CYCLES_PER_TENTH` (game.s, `-D`) | 1.000.000 | 1 | Una "décima" es un ciclo: el display muestra directamente los ciclos medidos (saturados en 99) y las esperas de 30, 12 y 10 décimas duran decenas de ciclos en vez de millones. El programa es el mismo `sw/game.s`; los dos `li` de la constante pasan de dos instrucciones a una (`addi`), así que el programa queda de 113 palabras en vez de 115 y las direcciones siguientes se corren (el assembler recalcula los saltos). |
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

El valor 57 es determinista: 20 ciclos hasta la pulsación, 2 del sincronizador, 12 a 15
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
- Para rehacer los estímulos tras cambiar el programa: `make asic/sim/estimulos.txt`
  (o `python3 asic/sim/calibrar.py`).

## Post-PnR con retardos (SDF): `make post-pnr-sdf` y `make post-pnr-cvc`

El mismo testbench y escenario, con el netlist post-PnR y el SDF de una esquina de una
corrida COMPLETA del flujo. La corrida es `d1_pnr` (`asic/sim/config_pnr.yaml`, generada
por `generar_config.py --pnr`: la configuración final completa, incluido
`IO_PIN_ORDER_CFG`, con la ROM de simulación y `DebounceDivBits=2`; se encola con
`bash asic/encolar.sh . asic/sim/config_pnr.yaml d1_pnr 100`; cierre y tablas en
`asic/sim/resultados/d1_pnr/` y `asic/sim/resultado_sdf.md`). Los dos objetivos tienen como
prerrequisito la ROM de simulación `asic/sim/gen/pochoco_rom.v` (no versionada; la genera el
assembler) y no corren LibreLane: el netlist y los SDF tienen que existir en `RUN`.

- `make post-pnr-sdf ESQUINA=<esquina>` (`asic/sim/post_pnr_sdf.sh`): Icarus Verilog 13.0
  de la imagen de LibreLane (`docker run ... ghcr.io/librelane/librelane:3.0.16 iverilog|vvp`,
  variable `IMAGEN_DOCKER`), no el 14.0-devel del host. Simula el RTL de referencia con
  el mismo Icarus, renombra las instancias de nombre jerárquico del netlist y del SDF
  (`renombrar_instancias.py`: sin eso vvp aborta con `vpi_scan(vpiHandle): Assertion 0 failed`
  en el primer INTERCONNECT a `\u_soc.u_core.u_rf/_N_ `, en 13.0 y en 14.0), compila el
  netlist con los modelos del PDK con sus bloques `specify` (`-gspecify -ginterconnect`,
  sin `-DFUNCTIONAL`) y el `$sdf_annotate` del testbench (`-DSDF`), corre vvp `REPETIR`
  veces (3) con el mismo binario borrando la traza antes de cada una, guarda el tiempo y
  el md5 de cada traza y compara cada una con la del RTL. Cuenta las entradas del SDF por
  tipo y los mensajes de anotación de vvp, y dice explícitamente que Icarus NO evalúa los
  timing checks (`warning: Timing checks are not supported.` al compilar, `TIMINGCHECK not
  supported` al anotar): no reporta "0 violaciones". Parámetros: `ESQUINA`
  (`nom_tt_025C_5v00`), `RUN` (`asic/sim/runs/d1_pnr`), `REPETIR` (3), `ESCENARIO`
  (`sim`; `final` corre `asic/sim/estimulos_final.txt`, 320.000 ciclos, con
  `RUN=asic/rom/runs/final`), `MUESTREO` (50), `ESTIMULO` (50) y `ETIQUETA` (sufijo del
  directorio de salida, para controles: `make post-pnr-sdf ESTIMULO=1 ETIQUETA=_control_estimulo1`
  deja el corrimiento de un ciclo en otro directorio, sin pisar el resultado bueno, y falla a
  propósito porque la comparación con el RTL da FAIL). Salidas en
  `build/post_pnr/<tag>/<esquina>[_final]<ETIQUETA>/` (netlist y SDF renombrados, `iverilog.log`,
  `vvp_<n>.log`, `traza_<n>.txt`, `tiempo_<n>.txt`, `comparacion_<n>.txt`, `mensajes_sdf.txt`,
  `resumen.md`).
- `make post-pnr-cvc ESQUINA=<esquina>` (`asic/sim/cvc_sdf.sh`): lo mismo con Open Verilog
  CVC 7.00b (`build/cvc/open-src-cvc/build64/cvc64`, compilado en el host con `make cvc64`;
  instrucciones en el script), que SÍ evalúa `$setup`, `$hold`, `$width`, `$recovery`,
  `$removal` y `$period` con los valores del SDF y reporta cada violación
  (`[566] timing violation`). Usa una copia del modelo sin el `ifnone` de los 120 arcos con
  flanco (`modelo_cvc.py`; CVC los rechaza como error e Icarus los descarta como aviso), el
  SDF sin los 19 INTERCONNECT hacia puertos de salida (error 1509 de CVC) y el modo
  interpretado `+interp` (el enlace del ejecutable compilado falla con el ld actual). Como
  CVC no compila el RTL (cae con Segmentation fault), la referencia es la traza del RTL de
  `make post-pnr-sdf`. Corre cvc64 `REPETIR` veces (3) borrando la traza antes de cada una, con
  el md5 y el tiempo de cada ejecución, y comprueba que el conteo de violaciones sea el mismo en
  todas. Cuenta las violaciones por tipo y por instancia. `ETIQUETA` es un
  sufijo del directorio de salida (`build/post_pnr/cvc/<tag>/<esquina>[_final]<ETIQUETA>/`):
  `make post-pnr-cvc ESTIMULO=1 ETIQUETA=_control_estimulo1` es el control positivo, que
  tiene que reportar violaciones de removal y de setup en los sincronizadores de entrada (y
  entonces la comparación con el RTL da FAIL a propósito, así que el objetivo falla). Salidas
  por repetición: `cvcsim_<n>.log`, `sdf_cvc_<n>.log`, `tiempo_<n>.txt`, `traza_<n>.txt`,
  `comparacion_<n>.txt`, más `violaciones_por_tipo.txt`, `violaciones_por_instancia.txt`,
  `mensajes_sdf.txt` y `resumen.md`.
- `MUESTREO` y `ESTIMULO` (`tb/post_synth_tb.v`): ns después del flanco en que se muestrean
  las salidas y se aplican las entradas (`rst_n` y botones). `make post-synth` usa 1 y 1;
  con retardos anotados hay que usar 50 y 50 en el RTL de referencia y en el netlist,
  porque el reloj llega a los flip-flops 0,8 a 2,7 ns después del flanco externo
  (latencia del árbol de reloj) y una entrada aplicada a +1 ns la captura el netlist un
  ciclo antes que el RTL (toda la traza sale corrida un ciclo). En el RTL el valor no
  cambia la traza.
- Resultado (`asic/sim/resultado_sdf.md`): en `nom_tt_025C_5v00`, `max_ss_125C_4v50` y
  `min_ff_n40C_5v50`, con los dos simuladores, la traza del netlist con retardos es
  idéntica a la del RTL (mismo md5 en las tres ejecuciones de cada simulador en cada
  esquina), sin X; Icarus
  anota 35.910 de 38.086 IOPATH (los 2.176 que faltan son los arcos `ifnone` con flanco de
  mux2, xor2 y xnor2) y 14.565 de 14.566 INTERCONNECT, e ignora los 977 bloques
  TIMINGCHECK; CVC anota todo, evalúa los 7.358 checks y no reporta ninguna violación en
  4.500 ciclos a 100 ns, y en el control positivo reporta 10 (removal/recovery de 33 ps en
  `rst_sync_q` y setup de 88 a 107 ps en `btn_meta`), con lo que la traza queda en X. El netlist
  real de la corrida final con su SDF de `nom_tt` (`make post-pnr-sdf RUN=asic/rom/runs/final
  ESCENARIO=final REPETIR=1`) completó con Icarus los 320.000 ciclos del escenario de
  `make post-synth-final` con la misma traza que el RTL (una ejecución de 24 min 45 s).
