# Simulación post-PnR con retardos (SDF), sección 3.7

Netlist post-PnR y SDF de la corrida `d1_pnr` (flujo completo con la configuración de
simulación, abajo), simulados con el mismo testbench de puertos y el mismo escenario de
`make post-synth` (`tb/post_synth_tb.v`, `asic/sim/estimulos.txt`, 4.500 ciclos a 100 ns:
pulsación de inicio, ronda correcta de 57 ciclos, pulsación incorrecta con EE y reintento),
en tres esquinas: típica `nom_tt_025C_5v00`, lenta `max_ss_125C_4v50` y rápida
`min_ff_n40C_5v50`, más una cuarta (`nom_ss_125C_4v50`) como prueba de punta a punta de los
objetivos del Makefile. Dos simuladores:

- Icarus Verilog 13.0 de la imagen de LibreLane (`make post-pnr-sdf`, `asic/sim/post_pnr_sdf.sh`):
  anota los retardos del SDF pero NO evalúa los timing checks (sección 3).
- Open Verilog CVC 7.00b (`make post-pnr-cvc`, `asic/sim/cvc_sdf.sh`): anota los retardos y SÍ
  evalúa `$setup`, `$hold`, `$width`, `$recovery`, `$removal` y `$period` con los valores del SDF
  (sección 4), con un control positivo que demuestra que los evalúa.

Resultado: en las tres esquinas, con los dos simuladores, la traza del netlist con retardos es
idéntica a la del RTL (md5 `4f14ec05462e4789a3d873d2ba50fd97`), sin valores X, reproducible en tres
ejecuciones de cada simulador en cada esquina, y CVC no reporta ninguna violación de timing en 4.500
ciclos a 100 ns. Además, el
netlist REAL de la corrida final (`asic/rom/runs/final`, ROM real y `DebounceDivBits=15`) con su SDF
de `nom_tt_025C_5v00` completó con Icarus el escenario de 320.000 ciclos de `make post-synth-final`
con la misma traza que el RTL (sección 2.5).

Archivos de salida (no versionados): `build/post_pnr/d1_pnr/<esquina>[_control_estimulo1]/` (Icarus),
`build/post_pnr/cvc/d1_pnr/<esquina>[_control_estimulo1]/` (CVC) y
`build/post_pnr/final/nom_tt_025C_5v00_final/` (escenario final), cada uno con su `resumen.md`.
Los logs de `make` de cada corrida quedan en `build/post_pnr/make_*.log`.

## 1. Corrida d1_pnr: flujo completo con la configuración de simulación (asic/sim/config_pnr.yaml)

`asic/sim/config_pnr.yaml` la genera `asic/sim/generar_config.py --pnr` desde `asic/rom/config.yaml`:
es la configuración final completa (D15, D20, D21, incluido `IO_PIN_ORDER_CFG: dir::../rom/pines.cfg`,
que `asic/sim/config.yaml` omite porque solo se corre hasta la síntesis) con la ROM del programa de
simulación (`asic/sim/gen/pochoco_rom.v`, `CYCLES_PER_TENTH=1`) y `DebounceDivBits=2`.
Encolada con `bash asic/encolar.sh . asic/sim/config_pnr.yaml d1_pnr 100` (CLOCK_PERIOD 100,
FP_CORE_UTIL 40); terminó con código 0 en 3 min 21 s (`asic/logs/cola_estado.txt`, 13:33 a 13:36).
Cierre: `asic/sim/resultados/d1_pnr/cierre.md` (`asic/verificar_cierre.py`): DRC 0, LVS 0,
antena 0, setup y hold con WNS >= 0 y TNS = 0 en las 9 esquinas: CIERRA. Archivos copiados por
`asic/recolectar.py` a `asic/sim/resultados/d1_pnr/`.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| d1_pnr | 100 | 74.695 | 0 | 63.717 | 0 | 0.442 | 0 | 1.063 | 0 | 63.717 | 0 | 0.173 | 0 | sí | 179330 | 0.479 | 403659 | 0 | 0 | 0 | sí | 516 | 30 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| d1_pnr | 150125.338 | 64095.450 | 977 | 73655.546 | 10005.722 | 3942.579 |

Difiere de la corrida final (`asic/final.md`: 182.265 µm², 990 flip-flops) solo por el programa
(113 palabras en vez de 115) y el debounce de 2 bits en vez de 15 (13 flip-flops menos).
Latencia del árbol de reloj de d1_pnr (`asic/sim/runs/d1_pnr/55-openroad-stapostpnr/<esquina>/skew.max.rpt`,
latencia de fuente y de destino en la ruta del peor skew): 1,465 y 1,241 ns en `nom_tt`, 2,679 y
2,252 ns en `max_ss`, 0,928 y 0,792 ns en `min_ff`. Este dato explica el corrimiento de la sección 2.3.

## 2. Icarus Verilog 13.0 de la imagen: `make post-pnr-sdf ESQUINA=<esquina>`

### 2.1 Comandos y versiones

`make post-pnr-sdf ESQUINA=<esquina>` llama a `asic/sim/post_pnr_sdf.sh asic/sim/runs/d1_pnr <esquina> 3 sim 50 50 ''`
(los últimos argumentos son `REPETIR`, `ESCENARIO`, `MUESTREO`, `ESTIMULO` y `ETIQUETA`),
que corre `iverilog` y `vvp` con
`docker run --rm --user "$(id -u):$(id -g)" -v "$HOME:$HOME" -w "$(pwd)" -e HOME="$HOME" ghcr.io/librelane/librelane:3.0.16 ...`:

```
iverilog -V        -> Icarus Verilog version 13.0 (devel) ()      (imagen sha256:02d50f259d48)
vvp -V             -> Icarus Verilog runtime version 13.0 (devel) ()
# 1. referencia del RTL, mismo Icarus, mismo testbench, estímulos y parámetros
iverilog -g2012 -I asic/sim/gen -DESTIMULOS="asic/sim/estimulos.txt" -DTRAZA=... -DCICLOS=4500 -DDIV_BITS=2 \
        -DMUESTREO=50 -DESTIMULO=50 -o build/post_pnr/d1_pnr/tb_rtl_sim tb/post_synth_tb.v rtl/*.v rtl/espino_core/*.v asic/sim/gen/pochoco_rom.v
vvp build/post_pnr/d1_pnr/tb_rtl_sim
# 2. netlist y SDF con las instancias jerárquicas renombradas (sección 2.4)
python3 asic/sim/renombrar_instancias.py --netlist asic/sim/runs/d1_pnr/final/nl/asic_top.nl.v \
        --salida build/post_pnr/d1_pnr/<esquina> asic/sim/runs/d1_pnr/final/sdf/<esquina>/asic_top__<esquina>.sdf
# 3. netlist con los modelos del PDK CON sus bloques specify (sin -DFUNCTIONAL) y $sdf_annotate (-DSDF)
iverilog -g2012 -gspecify -ginterconnect -DNETLIST -DSDF="build/post_pnr/d1_pnr/<esquina>/asic_top__<esquina>.sdf" \
        -DESTIMULOS="asic/sim/estimulos.txt" -DTRAZA=... -DCICLOS=4500 -DMUESTREO=50 -DESTIMULO=50 \
        -o build/post_pnr/d1_pnr/<esquina>/tb_sdf tb/post_synth_tb.v build/post_pnr/d1_pnr/<esquina>/asic_top.nl.v \
        $PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v \
        $PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v
# 4. tres ejecuciones del mismo binario; la traza se borra antes de cada una
rm -f traza.txt; time vvp build/post_pnr/d1_pnr/<esquina>/tb_sdf        (x3, md5sum de cada traza)
# 5. comparación de cada traza con la del RTL
python3 asic/sim/comparar.py build/post_pnr/d1_pnr/traza_rtl_sim.txt build/post_pnr/d1_pnr/<esquina>/traza_<n>.txt
```

`PDK_ROOT=$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee`. Sin `-ginterconnect`
iverilog omite la anotación (`Omitting $sdf_annotate()`); sin `-gspecify` no compila los bloques specify.

### 2.2 Resultado por esquina (netlist post-PnR de d1_pnr, 3 ejecuciones de vvp por esquina)

Fuente: `build/post_pnr/d1_pnr/<esquina>/resumen.md`, `tiempo_<n>.txt`, `traza_<n>.txt`, `vvp_<n>.log`.

| esquina | ciclos | cambios de salida | con X | igual al RTL | 3 md5 iguales | tiempo real de vvp (s), 3 ejecuciones | IOPATH anotados | INTERCONNECT anotados | timing checks |
|---|---|---|---|---|---|---|---|---|---|
| nom_tt_025C_5v00 | 4500 | 16 | 0 | sí (3 de 3) | sí | 47,274 / 47,806 / 53,067 | 35910 de 38086 | 14565 de 14566 | no evaluados (977 bloques ignorados) |
| max_ss_125C_4v50 | 4500 | 16 | 0 | sí (3 de 3) | sí | 50,769 / 61,006 / 62,475 | 35910 de 38086 | 14565 de 14566 | no evaluados (977 bloques ignorados) |
| min_ff_n40C_5v50 | 4500 | 16 | 0 | sí (3 de 3) | sí | 65,828 / 55,437 / 51,181 | 35910 de 38086 | 14565 de 14566 | no evaluados (977 bloques ignorados) |
| nom_ss_125C_4v50 (*) | 4500 | 16 | 0 | sí (3 de 3) | sí | 43,370 / 43,459 / 42,736 | 35910 de 38086 | 14565 de 14566 | no evaluados (977 bloques ignorados) |

(*) Cuarta esquina, corrida a las 20:56 como prueba de punta a punta del objetivo `make post-pnr-sdf`
después de darle como prerrequisito la ROM de simulación (`build/post_pnr/make_nom_ss_125C_4v50.log`,
`build/post_pnr/cadena_nom_ss.log`); mismo md5.

md5 de las doce trazas del netlist y de la del RTL: `4f14ec05462e4789a3d873d2ba50fd97` (17 líneas:
la inicial y 16 cambios). El RTL con el mismo Icarus tarda de 0,073 a 0,082 s; el netlist anotado,
de 42,7 a 65,8 s
(`time` de bash dentro de la imagen: real, usuario y sistema en `tiempo_<n>.txt`). Es la misma traza
de `make post-synth` (`build/post_synth/traza_rtl.txt`, mismo md5): 4 LEDs y display 01 en los ciclos
388 y 426, 57 ciclos medidos en el 1574, EE en el 2181, ronda 02 repetida en el 2353, 57 en el 3492.
Los cuatro binarios de vvp (uno por esquina) no abortaron en ninguna de las doce ejecuciones
(código 0 en los `tiempo_<n>.txt`).

### 2.3 Instante de aplicación de las entradas (ESTIMULO) y el corrimiento de un ciclo

El testbench de `make post-synth` aplica `rst_n` y los botones 1 ns después del flanco de subida
y muestrea las salidas 1 ns después. Con el SDF anotado eso NO sirve: el reloj llega a los
flip-flops después de la latencia del árbol de reloj (sección 1: entre 0,8 y 2,7 ns según la
esquina), es decir después de ese +1 ns, así que el netlist captura cada entrada en el flanco del
MISMO ciclo en que el testbench la aplica, y el RTL (sin retardos) en el siguiente. Con ESTIMULO=1
y muestreo a +50 ns, el netlist anotado dio en `nom_tt` y `max_ss` exactamente la misma secuencia de
17 líneas que el RTL pero con TODOS los ciclos restados en 1 (387 en vez de 388, 425 en vez de 426,
1573 en vez de 1574, ..., hasta 4038 en vez de 4039), md5 `114791491cb3919872c49576ab3f1932`, y
`comparar.py` dio FAIL. Está medido dos veces: tres ejecuciones por esquina en la corrida de las
13:46 (`build/post_pnr/make_nom_tt.log` y `make_max_ss.log`, los tres md5 iguales) y una
ejecución guardada aparte con
`make post-pnr-sdf ESTIMULO=1 ETIQUETA=_control_estimulo1 REPETIR=1`
(`build/post_pnr/make_sdf_control_estimulo1.log`, salida en
`build/post_pnr/d1_pnr/nom_tt_025C_5v00_control_estimulo1/`: `traza_1.txt`, `comparacion_1.txt`,
`resumen.md`; mismo md5, 52,575 s), que es la que queda como evidencia porque las primeras se
sobreescribieron al correr la configuración buena. Para eso se le agregó el parámetro `ETIQUETA` a
`asic/sim/post_pnr_sdf.sh`, igual al de `cvc_sdf.sh`.
Por eso `tb/post_synth_tb.v` tiene ahora el parámetro `ESTIMULO` (ns después del flanco en que se
aplican las entradas; 1 por defecto) además de `MUESTREO`, y `make post-pnr-sdf` usa 50 y 50 en el
RTL de referencia y en el netlist: a mitad de ciclo las dos simulaciones ven lo mismo. En el RTL el
valor de ESTIMULO no cambia nada: `make post-synth` y `make post-synth-control` con los valores por
defecto siguen dando la misma traza (mismo md5) y PASS y FAIL respectivamente, y
`asic/sim/estimulos.txt` y `asic/sim/resultado.md` quedan iguales. El control positivo con CVC
(sección 4.3) muestra qué pasa físicamente con ESTIMULO=1: violaciones de removal y de setup en los
sincronizadores de entrada.

### 2.4 Qué se anotó y qué no (conteo de mensajes de `$sdf_annotate`)

Entradas del SDF de cada esquina (`grep -c` sobre `asic_top__<esquina>.sdf`, 131.254 líneas, 11.530 CELL):
38.086 IOPATH, 14.566 INTERCONNECT y 977 bloques TIMINGCHECK (uno por flip-flop) con 7.358 checks:
1.954 SETUP, 1.954 HOLD, 2.127 WIDTH, 173 RECOVERY, 173 REMOVAL, 977 PERIOD, 0 SETUPHOLD y 0 RECREM.

Mensajes de vvp al anotar (`vvp_1.log`; los mismos mensajes y las mismas cantidades en las cuatro
esquinas, solo cambia el nombre del archivo SDF; resumen en `mensajes_sdf.txt`):

| mensaje | cantidad | qué es |
|---|---|---|
| `SDF ERROR: ... Unable to match ModPath S -> Z in post_synth_tb.dut._N_` | 1516 | los dos IOPATH S->Z de las 758 `mux2_2` |
| `SDF ERROR: ... Unable to match ModPath A1 -> Z` y `A2 -> Z` | 254 + 254 | los cuatro IOPATH de las 127 `xor2_1` |
| `SDF ERROR: ... Unable to match ModPath A1 -> ZN` y `A2 -> ZN` | 76 + 76 | los cuatro IOPATH de las 38 `xnor2_1` |
| `SDF WARNING: ... TIMINGCHECK not supported.` | 977 | los 977 bloques TIMINGCHECK, ignorados |
| `SDF ERROR: ... Could not find intermodpath!` (y `VPI error: Could not insert intermodpath!`) | 1 | `(INTERCONNECT asic_top.Z spi_miso)`: el puerto `spi_miso` es una constante (`assign spi_miso = net622`) |
| `SDF ERROR: Cannot find ... in scope` | 0 | ninguna celda sin encontrar (con las instancias renombradas) |

Los 2.176 IOPATH sin anotar (5,7 %) son exactamente los arcos que el modelo del PDK declara como
`ifnone (posedge S => (Z:S))` (y `negedge`), una forma que la norma 1364 no admite: iverilog los
descarta al compilar con 120 avisos `sorry: ifnone with an edge-sensitive path is not supported`
(uno por arco del archivo del modelo) y vvp no encuentra el arco al anotar. Esas 923 celdas quedan con
retardo cero en esos arcos (sus INTERCONNECT sí se anotan). Los otros 35.910 IOPATH y 14.565 de los
14.566 INTERCONNECT se anotan sin mensaje. Al compilar, iverilog imprime además 1.926 avisos
`warning: Timing checks are not supported.`, uno por cada `$setup`, `$hold`, `$width`, `$recovery`,
`$removal` o `$period` de los bloques specify del modelo.

Nota sobre el intento anterior (Icarus 14.0-devel del host, 25-10): vvp abortaba al anotar con
`vpi_scan(vpiHandle): Assertion 0 failed` (código 139) y solo una ejecución completó. La causa no era
la versión: el netlist plano de OpenROAD llama `\u_soc.u_core.u_rf/_2913_ ` a las celdas de los
módulos con jerarquía conservada (`SYNTH_KEEP_HIERARCHY_MODULES`) y el lector de SDF de Icarus parte
esos nombres por los puntos como si fueran una ruta jerárquica (`Cannot find u_soc in scope`); el
primer INTERCONNECT a una de ellas termina en `vpi_scan(NULL)` y aborta, en 13.0 y en 14.0.
`asic/sim/renombrar_instancias.py` renombra esas 2.828 instancias (`u_soc__u_core__u_rf___2913_`) en
el netlist y en el SDF (16.883 referencias), comprobando que no choquen con otros identificadores;
con eso ninguna ejecución abortó.

### 2.5 Escenario final (opcional): el netlist real de la corrida final, 320.000 ciclos

`make post-pnr-sdf RUN=asic/rom/runs/final ESCENARIO=final REPETIR=1` (`build/post_pnr/make_final_nom_tt.log`
y `build/post_pnr/cadena_final.log`: de 16:10 a 16:35): el netlist post-PnR de la corrida final
(`asic/rom/runs/final/final/nl/asic_top.nl.v`: ROM real de 115 palabras, `DebounceDivBits=15`) con su SDF
`asic/rom/runs/final/final/sdf/nom_tt_025C_5v00/asic_top__nom_tt_025C_5v00.sdf`, el escenario de
`make post-synth-final` (`asic/sim/estimulos_final.txt`: una pulsación de inicio real, 320.000 ciclos a
100 ns, 32 ms simulados) y el RTL de referencia con `rtl/gen/pochoco_rom.v`, `DebounceDivBits=15` y el
mismo Icarus de la imagen (ESTIMULO=50, MUESTREO=50 en los dos).

Fuente: `build/post_pnr/final/nom_tt_025C_5v00_final/resumen.md`, `tiempo_1.txt`, `traza_1.txt`, `vvp_1.log`,
`mensajes_sdf.txt`; RTL: `build/post_pnr/final/tiempo_rtl_final.txt`, `traza_rtl_final.txt`.

| esquina | ciclos | cambios de salida | con X | igual al RTL | tiempo real de vvp (s) | IOPATH anotados | INTERCONNECT anotados | timing checks |
|---|---|---|---|---|---|---|---|---|
| nom_tt_025C_5v00 | 320000 | 2 | 0 | sí (md5 `0c602ebd5532804d6c31ac54c80928ad`, el mismo de `build/post_synth/traza_rtl_final.txt`) | 1485,100 (24 min 45 s; el RTL, 4,340 s) | 35424 de 37654 | 14779 de 14780 | no evaluados (990 bloques ignorados) |

La traza tiene 3 líneas: `0 led=0000 disp=00`, `262156 led=1111 disp=00` y `262194 led=1111 disp=01`:
los cuatro LEDs y el 01 de la primera ronda unos 262.000 ciclos después de la pulsación de inicio
(el debounce real de 15 bits), lo mismo que `asic/sim/resultado_final.md` sin retardos. Se corrió una
sola vez (REPETIR=1) por su duración; el md5 coincide con el del RTL. El SDF de la corrida final tiene
37.654 IOPATH, 14.780 INTERCONNECT y 990 bloques TIMINGCHECK con 7.488 checks (1.980 SETUP, 1.980 HOLD,
2.166 WIDTH, 186 RECOVERY, 186 REMOVAL, 990 PERIOD); vvp no anota 2.230 IOPATH (los arcos `ifnone` con
flanco de las 759 `mux2_2`, 131 `xor2_1` y 47 `xnor2_1` del netlist final; `mensajes_sdf.txt`) ni el
INTERCONNECT a `spi_miso`, e ignora los 990 TIMINGCHECK, igual que en d1_pnr. Este es el escenario que
el intento del 25-10 con el Icarus 14.0-devel del host completó una sola vez y después abortaba; con las
instancias renombradas y el 13.0 de la imagen no abortó. Los tiempos de ese intento no son comparables
(otro binario y anotación incompleta, sección 2.4).

## 3. Los timing checks en Icarus: NO se evalúan

Prueba directa (`build/post_pnr/prueba_tchk/tchk.v`: un flip-flop con `$setup`, `$hold`, `$setuphold`,
`$width` y `$recovery` en su bloque specify y un testbench con una violación deliberada de setup, D
cambia 0,5 ns antes del flanco con 2 ns exigidos, y una de hold, D cambia 0,2 ns después con 1 ns exigido).
Salida exacta del iverilog 13.0 de la imagen, con `-g2012 -gspecify`:

```
build/post_pnr/prueba_tchk/tchk.v:7: warning: Timing checks are not supported.
build/post_pnr/prueba_tchk/tchk.v:8: warning: Timing checks are not supported.
build/post_pnr/prueba_tchk/tchk.v:9: warning: Timing checks are not supported. 
build/post_pnr/prueba_tchk/tchk.v:10: warning: Timing checks are not supported.
build/post_pnr/prueba_tchk/tchk.v:11: warning: Timing checks are not supported.
```

y vvp no imprime nada ante las violaciones (`fin: q=0` y `$finish`). El 14.0-devel del host
(`s20260301-403-g5ab23063f-dirty`) imprime los mismos cinco avisos y tampoco reporta nada. Sin
`-gspecify` ni siquiera avisa. En el netlist completo son los 1.926 avisos al compilar y los 977
`TIMINGCHECK not supported` al anotar de la sección 2.4.

Conclusión: la simulación con Icarus demuestra que el netlist post-PnR con los retardos de celda e
interconexión anotados ejecuta el programa igual que el RTL (misma traza, sin X) en las cuatro
esquinas simuladas, pero NO verifica ningún margen de setup, hold, ancho de pulso, recovery ni
removal: los
7.358 checks del SDF se ignoran. `make post-pnr-sdf` lo dice en su resumen y no reporta "0
violaciones". Esos márgenes los garantiza el STA de las 9 esquinas (`asic/verificar_cierre.py`:
WNS de setup 63,7 ns y de hold 0,173 ns en la peor esquina de d1_pnr) y, en simulación, CVC (sección 4).

## 4. Open Verilog CVC 7.00b: timing checks evaluados (`make post-pnr-cvc ESQUINA=<esquina>`)

### 4.1 Instalación y comandos

`git clone https://github.com/CambridgeHackers/open-src-cvc build/cvc/open-src-cvc` (commit `1c5e043`,
"Refactor makefile for cvc64, fix compilation using modern gcc version") y
`cd build/cvc/open-src-cvc/src && make cvc64` (gcc 15.2.0 del host, 1 min, log
`build/cvc/compilacion64.log`: "make cvc64 termino con codigo 0"; `make -f makefile.cvc`
fuerza `-m32` y falla por falta de la libc de 32 bits, log `build/cvc/compilacion.log`:
`/usr/include/stdio.h:28:10: fatal error: bits/libc-header-start.h: No such file or directory`).
Binario: `build/cvc/open-src-cvc/build64/cvc64`, `cvc64 -h` -> `OSS_CVC_7.00b-x86_64-rhel6x of 07/07/14 (Linux-elf)`.

`make post-pnr-cvc ESQUINA=<esquina>` llama a `asic/sim/cvc_sdf.sh asic/sim/runs/d1_pnr <esquina> sim 50 50 '' 3`
(`REPETIR=3`, igual que con Icarus):

```
python3 asic/sim/renombrar_instancias.py ...            (igual que con Icarus, a build/post_pnr/cvc/d1_pnr/<esquina>/)
python3 asic/sim/modelo_cvc.py $PDK_ROOT/.../gf180mcu_fd_sc_mcu7t5v0.v build/post_pnr/cvc/gf180mcu_fd_sc_mcu7t5v0_cvc.v
cd build/post_pnr/cvc/d1_pnr/<esquina>
# tres ejecuciones; la traza se borra antes de cada una
rm -f traza.txt; time cvc64 +interp -l cvcsim_<n>.log +typdelays +sdf_log_file sdf_cvc_<n>.log \
      defs.v tb/post_synth_tb.v asic_top.nl.v \
      $PDK_ROOT/.../primitives.v build/post_pnr/cvc/gf180mcu_fd_sc_mcu7t5v0_cvc.v        (n = 1, 2, 3)
python3 asic/sim/comparar.py build/post_pnr/d1_pnr/traza_rtl_sim.txt traza_<n>.txt        (n = 1, 2, 3)
```

`defs.v` define `NETLIST`, `SDF`, `ESTIMULOS`, `TRAZA`, `CICLOS=4500`, `MUESTREO=50` y `ESTIMULO=50` con
rutas absolutas (CVC no tiene `-D`). Tres adaptaciones, todas documentadas en los scripts:

1. Modelo (`asic/sim/modelo_cvc.py`): CVC rechaza los mismos 120 arcos `ifnone` con flanco que Icarus
   descarta, pero como error (`[1012] ifnone path illegal - has edge or is state dependent`) y no
   simula. El script quita solo la palabra `ifnone` de esos 120 arcos; en mux2, xor2 y xnor2 no hay
   arcos condicionales alternativos para esos pines, así que el modelo es equivalente, y así los
   2.176 IOPATH que Icarus no anota aquí sí se anotan (0 errores de anotación).
2. SDF: los 19 `INTERCONNECT` cuyo destino es un puerto de salida del macro (`seg1[k]`, `seg2[k]`,
   `led[k]`, `spi_miso`; 0,000 a 0,001 ns) son error 1509 para CVC y con errores no deja ejecutable;
   se quitan de la copia del SDF. Los 6 INTERCONNECT desde los puertos de entrada (`clk`, `rst_n`,
   `btn[3:0]`) dan el aviso 3106 "works because annotated as (PORT form MIPD delay": sí se anotan.
3. Modo interpretado (`+interp`): en modo compilado CVC genera `cvcsim` pero el enlace con el `ld`
   actual falla (`undefined reference to WIRE_EV_NNNN`); `+interp` simula directamente con la misma
   semántica según su documentación.

El RTL no se pudo compilar con CVC (cae con `Segmentation fault` en la elaboración, sin mensaje), así
que la referencia es la traza del RTL con el Icarus de la imagen (`build/post_pnr/d1_pnr/traza_rtl_sim.txt`,
la deja `make post-pnr-sdf`), que es la misma de `make post-synth`.

### 4.2 Resultado por esquina

Fuente: `build/post_pnr/cvc/d1_pnr/<esquina>/resumen.md`, `cvcsim_<n>.log`, `sdf_cvc_<n>.log`,
`tiempo_<n>.txt`, `traza_<n>.txt` y `comparacion_<n>.txt` (n = 1, 2, 3), y el log de `make` de cada
esquina (`build/post_pnr/make_cvc3_<esquina>.log`).

| esquina | ciclos | cambios de salida | con X | igual al RTL | 3 md5 iguales | tiempo real de cvc64 +interp (s), 3 ejecuciones | anotación: errores / avisos | violaciones de timing reportadas |
|---|---|---|---|---|---|---|---|---|
| nom_tt_025C_5v00 | 4500 | 16 | 0 | sí (3 de 3) | sí | 11,558 / 12,178 / 13,024 | 0 / 6 (aviso 3106, puertos de entrada) | 0 |
| max_ss_125C_4v50 | 4500 | 16 | 0 | sí (3 de 3) | sí | 11,369 / 12,021 / 11,877 | 0 / 6 | 0 |
| min_ff_n40C_5v50 | 4500 | 16 | 0 | sí (3 de 3) | sí | 13,159 / 13,098 / 12,220 | 0 / 6 | 0 |
| nom_ss_125C_4v50 (*) | 4500 | 16 | 0 | sí (3 de 3) | sí | 13,986 / 13,341 / 12,354 | 0 / 6 | 0 |

md5 de las doce trazas: `4f14ec05462e4789a3d873d2ba50fd97`, el mismo del RTL y el mismo de las doce
trazas de Icarus de la sección 2.2.

(*) Cuarta esquina, prueba de punta a punta de `make post-pnr-cvc`, igual que en la sección 2.2.

Las cuatro esquinas se corrieron primero una sola vez cada una (logs `build/post_pnr/cvc_<esquina>.log`,
`cvc_nom_tt.log` y `make_cvc_nom_tt.log`, de las 16:10 a las 20:59 del 27-10; mismos 16 cambios, mismo
md5 y 0 violaciones, con tiempos de 9,699 a 12,329 s) porque `asic/sim/cvc_sdf.sh` ejecutaba cvc64 una
sola vez. Se le agregó el parámetro `REPETIR` (3 por defecto, como el de `post_pnr_sdf.sh`) y se
repitieron las cuatro esquinas: esos son los números de la tabla.

CVC evalúa los 7.358 checks de los 977 bloques TIMINGCHECK (menos los 19 INTERCONNECT quitados, que
no son checks) y en 4.500 ciclos a 100 ns no reporta ninguna violación en ninguna de las esquinas ni
en ninguna de las tres ejecuciones (el script comprueba que el conteo de violaciones sea el mismo en
las tres). Es consistente con el STA: el peor WNS de setup de d1_pnr es 63,7 ns y el de hold 0,173 ns.

### 4.3 Control positivo: los checks sí se evalúan

Dos pruebas:

- Módulo mínimo (`build/post_pnr/prueba_tchk/tchk.v`, el mismo de la sección 3) con `cvc64 tchk.v && ./cvcsim`:
  reporta las violaciones deliberadas:
  ```
  **tchk.v(7) WARN** now 5000 ps [566] timing violation in tb.u (diff. 500 ps)
   $setup(d:4500 ps, (posedge clk):5000 ps, 2000 ps);
  **tchk.v(8) WARN** now 15200 ps [566] timing violation in tb.u (diff. 200 ps)
   $hold((posedge clk):15000 ps, d:15200 ps, 1000 ps);
  ```
  (más las dos de `$setuphold`, que CVC informa como `setup(of setuphold)` y `hold(of setuphold)`, y la
  de `$recovery`: 5 avisos `[566]` de violación, de los 6 avisos del log; el sexto es
  `[616] path destination q does not have a driver`, del retardo de ruta del modulito de prueba, no
  un timing check. El `$width` no se viola: el pulso del reloj es de 5 ns y exige 5 ns).
- Netlist completo con las entradas a +1 ns (`make post-pnr-cvc ESTIMULO=1 ETIQUETA=_control_estimulo1`,
  esquina `nom_tt`, `build/post_pnr/cvc/d1_pnr/nom_tt_025C_5v00_control_estimulo1/`,
  log `build/post_pnr/make_cvc3_nom_tt_025C_5v00_control_estimulo1.log`): 10 violaciones en 4
  instancias (6 `$setup`, 2 `$removal`, 2 `$recovery`; `violaciones_por_tipo.txt` y
  `violaciones_por_instancia.txt`), las mismas en las tres ejecuciones (4,828 / 4,937 / 4,599 s,
  mismo md5 `72fe2fbc5b3e0dcc51367756add6b9d1`), con los límites del SDF:
  - `$removal` y `$recovery` en `_4327_` y `_4328_` (los dos flip-flops `dffrnq_1` del sincronizador de
    reset, `rst_sync_q`): `rst_n` llega al pin RN a los 351.292 ps y el reloj al pin CLK a los 351.325 ps
    (latencia 1,325 ns desde el flanco externo de los 350 ns), 33 ps antes del flanco con 372 ps de
    removal exigidos (`(REMOVAL (posedge RN) (posedge CLK) (0.372:0.372:0.372))` en el SDF). El RECOVERY
    del SDF es `(-0.240:-0.240:-0.240)` (negativo) y CVC lo aplicó como 240 ps, sin el signo:
    pesimista. En el SDF de d1_pnr (`nom_tt`) los 173 RECOVERY son negativos y 175 de los 3.908
    SETUP/HOLD también, todos ellos HOLD (los 1.954 SETUP son positivos; p. ej.
    `(HOLD (COND ENABLE_RN === 1'b1 (posedge D)) ... (-0.059:-0.059:-0.059))` en el mismo
    `dffrnq_1`); solo se comprobó el tratamiento de CVC
    en el RECOVERY del control. Un límite negativo aplicado sin signo solo puede agregar violaciones,
    nunca ocultarlas, y con ESTIMULO=50 no apareció ninguna, así que ese pesimismo no cambia la
    sección 4.2.
  - `$setup` x6 en `_4363_` y `_4364_` (`btn_meta`, primera etapa del sincronizador de botones): el
    botón cambia 88 a 107 ps antes del flanco interno con 265 a 270 ps de setup exigidos (posedge D)
    y 105 ps (negedge D), valores del SDF de cada instancia.
  - Como los modelos del PDK tienen `notifier`, los flip-flops violados pasan a X y la traza queda
    `0 led=xxxx disp=XX` (1 cambio, con X): `comparar.py` da FAIL. Con Icarus la misma configuración
    (ESTIMULO=1) no produce ningún aviso ni X y solo corre la traza un ciclo (sección 2.3): Icarus no
    detecta el problema, CVC sí.

Con ESTIMULO=50 (las entradas a mitad de ciclo, como en 4.2) ninguna de esas violaciones aparece.

## 5. Conclusión

- El netlist post-PnR de d1_pnr con los retardos de celda e interconexión del SDF ejecuta el escenario
  de la sección 3.7 exactamente igual que el RTL en las esquinas típica, lenta y rápida, sin valores X,
  reproducible (tres ejecuciones con el mismo md5 por esquina y por simulador: 24 ejecuciones en total
  contando la cuarta esquina), con Icarus 13.0 de la imagen (43 a 66 s por ejecución) y con CVC 7.00b
  (11 a 14 s).
- El netlist real de la corrida final con su SDF de `nom_tt` completó con Icarus los 320.000 ciclos del
  escenario de `make post-synth-final` con la misma traza que el RTL (una ejecución, 24 min 45 s).
- Icarus NO evalúa los timing checks (aviso textual al compilar, 977 bloques TIMINGCHECK ignorados al
  anotar): su resultado prueba la función con retardos, no los márgenes. Los márgenes los verifica el
  STA de las 9 esquinas (criterio de cierre) y, en simulación, CVC: 0 violaciones en las cuatro
  esquinas simuladas, en las tres ejecuciones de cada una, con 7.358 checks activos, y un control
  positivo que las reporta cuando las entradas llegan antes que el reloj interno.
- Para simular con retardos las entradas tienen que aplicarse lejos del flanco (ESTIMULO=50): con el +1 ns
  de `make post-synth` el reloj interno (latencia 0,8 a 2,7 ns) captura la entrada un ciclo antes que el
  RTL; en el chip real los botones son asíncronos y el sincronizador de dos etapas resuelve ese caso,
  que es justamente lo que el control positivo muestra como violación de setup en `btn_meta`.
