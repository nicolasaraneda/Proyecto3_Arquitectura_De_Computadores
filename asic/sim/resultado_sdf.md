# Simulación post-PnR con retardos (SDF), sección 3.7

Netlist post-PnR y SDF de la corrida **`d2_pnr`** (flujo completo con la configuración de
simulación de D23, abajo), simulados con el mismo testbench de puertos y el mismo escenario de
`make post-synth` (`tb/post_synth_tb.v`, `asic/sim/estimulos.txt`, 4.500 ciclos a 100 ns: pulsación
de inicio, ronda correcta de **51** ciclos medidos, pulsación incorrecta con EE y reintento), en
tres esquinas: típica `nom_tt_025C_5v00`, lenta `max_ss_125C_4v50` y rápida `min_ff_n40C_5v50`.
Dos simuladores:

- Icarus Verilog 13.0 de la imagen de LibreLane (`make post-pnr-sdf`, `asic/sim/post_pnr_sdf.sh`):
  anota los retardos del SDF pero NO evalúa los timing checks (sección 3).
- Open Verilog CVC 7.00b (`make post-pnr-cvc`, `asic/sim/cvc_sdf.sh`): anota los retardos y SÍ
  evalúa `$setup`, `$hold`, `$width`, `$recovery`, `$removal` y `$period` con los valores del SDF
  (sección 4), con un control positivo que demuestra que los evalúa.

**Resultado con Icarus: en las tres esquinas la traza del netlist con retardos es idéntica a la del
RTL (md5 `5b6cebfb898a90a258b592fb29e64651`), sin valores X, y reproducible en las tres ejecuciones
de cada esquina (nueve trazas, un solo md5).** El resultado con CVC está en la sección 4.

`d1_pnr` era la corrida equivalente de v1 y sus resultados quedan en
`asic/sim/resultados/d1_pnr/`; el documento de v1 con sus números (57 ciclos medidos, md5
`4f14ec05462e4789a3d873d2ba50fd97`, cuatro esquinas) está en el historial de git de este archivo.

## 1. Corrida d2_pnr: flujo completo con la configuración de simulación (asic/sim/config_pnr.yaml)

`asic/sim/config_pnr.yaml` la genera `asic/sim/generar_config.py --pnr` desde `asic/rom/config.yaml`:
es la configuración final completa de D23 (D15, D20, D21, `EarlyRead = 1`, el bloque `LAYERS_RC` y
las cuatro variables de la reparación post-GRT, incluido `IO_PIN_ORDER_CFG: dir::../rom/pines.cfg`,
que `asic/sim/config.yaml` omite porque solo se corre hasta la síntesis) con la ROM del programa de
simulación (`asic/sim/gen/pochoco_rom.v`, `CYCLES_PER_TENTH=1`) y `DebounceDivBits=2`.
Encolada con `bash asic/encolar.sh . asic/sim/config_pnr.yaml d2_pnr 100` (CLOCK_PERIOD 100,
FP_CORE_UTIL 40); terminó con código 0 en **5 min 31 s** (`asic/logs/cola_estado.txt`, 20:58:49 a
21:04:20). Cierre: `asic/sim/resultados/d2_pnr/cierre.md` (`asic/verificar_cierre.py`): DRC 0,
LVS 0, antena 0, setup y hold con WNS >= 0 y TNS = 0 en las 9 esquinas: **CIERRA** (setup WNS
59,174 ns y hold 0,082 ns en la peor esquina). Archivos copiados por `asic/recolectar.py` a
`asic/sim/resultados/d2_pnr/`.

Datos de la corrida (`asic/sim/resultados/d2_pnr/metrics.json`): área de celdas estándar
**207.624 µm²**, **951** flip-flops, die **414.282 µm²**, utilización real 0,540, 5 violaciones de
max slew y 1 de max capacitancia.

Difiere de la corrida final (`asic/final.md`: 208.439 µm², 964 flip-flops, die 419.131 µm²) solo por
el programa (113 palabras en vez de 115, porque `CYCLES_PER_TENTH = 1` convierte dos `li` en dos
`addi`) y el debounce de 2 bits en vez de 15 (13 flip-flops menos). Las 5 violaciones de slew contra
las 0 de la corrida final son de ese mismo cambio: el diseño es un poco distinto y el resizer llega
a otro punto.

Latencia del árbol de reloj de `d2_pnr`
(`asic/sim/runs/d2_pnr/*-openroad-stapostpnr/<esquina>/skew.max.rpt`, latencia de fuente y de
destino en la ruta del peor skew): **1,541 y 1,298 ns** en `nom_tt`, **2,804 y 2,357 ns** en
`max_ss`, **0,982 y 0,828 ns** en `min_ff`. Este dato explica el corrimiento de la sección 2.3 y es
por lo que `MUESTREO` y `ESTIMULO` valen 50 ns y no 1.

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

### 2.2 Resultado por esquina (netlist post-PnR de d2_pnr, 3 ejecuciones de vvp por esquina)

Fuente: `build/post_pnr/d2_pnr/<esquina>/resumen.md`, `tiempo_<n>.txt`, `traza_<n>.txt`, `vvp_<n>.log`.

| esquina | ciclos | cambios de salida | con X | igual al RTL | 3 md5 iguales | tiempo real de vvp (s), 3 ejecuciones | IOPATH anotados | INTERCONNECT anotados | timing checks |
|---|---|---|---|---|---|---|---|---|---|
| nom_tt_025C_5v00 | 4500 | 16 | 0 | **sí (3 de 3)** | sí | 80,007 / 76,862 / 82,264 | 34005 de 36473 | 16300 de 16301 | no evaluados (951 bloques ignorados) |
| max_ss_125C_4v50 | 4500 | 16 | 0 | **sí (3 de 3)** | sí | 99,260 / 98,917 / 92,420 | 34005 de 36473 | 16300 de 16301 | no evaluados (951 bloques ignorados) |
| min_ff_n40C_5v50 | 4500 | 16 | 0 | **sí (3 de 3)** | sí | 103,107 / 90,978 / 76,987 | 34005 de 36473 | 16300 de 16301 | no evaluados (951 bloques ignorados) |

md5 de las nueve trazas del netlist y de la del RTL: **`5b6cebfb898a90a258b592fb29e64651`** (17
líneas: la inicial y 16 cambios). El RTL con el mismo Icarus tarda de 0,100 a 0,181 s; el netlist
anotado, de 76,9 a 103,1 s (`time` de bash dentro de la imagen: real, usuario y sistema en
`tiempo_<n>.txt`). Es la misma traza de `make post-synth` (`build/post_synth/traza_rtl.txt`, mismo
md5): 4 LEDs en el ciclo 383 y display 01 en el 404, **51** ciclos medidos en el 1033, EE en el
1405, ronda 02 repetida en el 1507 y 51 de nuevo en el 2131. Los tres binarios de vvp (uno por
esquina) no abortaron en ninguna de las nueve ejecuciones (código 0 en los `tiempo_<n>.txt`).

El SDF de cada esquina trae 36.473 IOPATH, 16.301 INTERCONNECT y 951 bloques TIMINGCHECK con 7.173
checks (SETUP 1.902, HOLD 1.902, WIDTH 2.074, RECOVERY 172, REMOVAL 172, PERIOD 951). Qué se anota y
qué no, en la sección 2.4.

### 2.3 Instante de aplicación de las entradas (ESTIMULO) y el corrimiento de un ciclo

El testbench de `make post-synth` aplica `rst_n` y los botones 1 ns después del flanco de subida y
muestrea las salidas 1 ns después. Con el SDF anotado eso NO sirve: el reloj llega a los flip-flops
después de la latencia del árbol de reloj (sección 1: entre 0,98 y 2,80 ns según la esquina), es
decir después de ese +1 ns, así que el netlist captura cada entrada en el flanco del MISMO ciclo en
que el testbench la aplica, y el RTL (sin retardos) en el siguiente, y toda la traza sale corrida un
ciclo. Por eso `tb/post_synth_tb.v` tiene el parámetro `ESTIMULO` (ns después del flanco en que se
aplican las entradas; 1 por defecto) además de `MUESTREO`, y `make post-pnr-sdf` usa **50 y 50** en
el RTL de referencia y en el netlist: a mitad de ciclo las dos simulaciones ven lo mismo. En el RTL
el valor de `ESTIMULO` no cambia nada: `make post-synth` y `make post-synth-control` con los valores
por defecto siguen dando PASS y FAIL respectivamente.

El corrimiento de un ciclo está medido con Icarus sobre el diseño de v1 y no se repitió acá, porque
el mecanismo no depende del diseño: está en `docs/equivalencia_v1.md`... (corresponde al historial de
git de este archivo, corrida `d1_pnr`, control
`make post-pnr-sdf ESTIMULO=1 ETIQUETA=_control_estimulo1`). Sobre el diseño nuevo lo que sí se
midió, y muestra lo mismo pero físicamente, es el **control positivo con CVC** de la sección 4.3:
con `ESTIMULO=1` el netlist anotado reporta violaciones de `$recovery` y `$removal` en el
sincronizador de reset y de `$setup` en el sincronizador de botones, y la traza se cae a X.

### 2.4 Qué se anotó y qué no (conteo de mensajes de `$sdf_annotate`)

Entradas del SDF de cada esquina (`asic_top__<esquina>.sdf`, **138.072 líneas, 14.110 CELL**):
**36.473 IOPATH, 16.301 INTERCONNECT y 951 bloques TIMINGCHECK** (uno por flip-flop) con **7.173
checks**: 1.902 SETUP, 1.902 HOLD, 2.074 WIDTH, 172 RECOVERY, 172 REMOVAL, 951 PERIOD, 0 SETUPHOLD y
0 RECREM (`build/post_pnr/d2_pnr/<esquina>/resumen.md`).

Mensajes de vvp al anotar (`vvp_1.log`; los mismos mensajes y las mismas cantidades en las tres
esquinas, solo cambia el nombre del archivo SDF; resumen en `mensajes_sdf.txt`):

| mensaje | cantidad | qué es |
|---|---|---|
| `SDF ERROR: ... Unable to match ModPath S -> Z` | 1.768 | los dos IOPATH S->Z de las 884 `mux2_2` |
| `SDF ERROR: ... Unable to match ModPath A1 -> Z` y `A2 -> Z` | 266 + 266 | los cuatro IOPATH de las 133 `xor2_1` |
| `SDF ERROR: ... Unable to match ModPath A1 -> ZN` y `A2 -> ZN` | 84 + 84 | los cuatro IOPATH de las 42 `xnor2_1` |
| `SDF WARNING: ... TIMINGCHECK not supported.` | 951 | los 951 bloques TIMINGCHECK, ignorados |
| `SDF ERROR: ... Could not find intermodpath!` (y `VPI error: Could not insert intermodpath!`) | 1 | `(INTERCONNECT asic_top.Z spi_miso)`: el puerto `spi_miso` es una constante |
| `SDF ERROR: Cannot find ... in scope` | 0 | ninguna celda sin encontrar (con las instancias renombradas) |

Los **2.468 IOPATH sin anotar (6,8 por ciento)** son exactamente los arcos que el modelo del PDK
declara como `ifnone (posedge S => (Z:S))` (y `negedge`), una forma que la norma 1364 no admite:
iverilog los descarta al compilar con 120 avisos `sorry: ifnone with an edge-sensitive path is not
supported` (uno por arco del archivo del modelo) y vvp no encuentra el arco al anotar. Esas celdas
quedan con retardo cero en esos arcos (sus INTERCONNECT sí se anotan). Los otros **34.005 IOPATH y
16.300 de los 16.301 INTERCONNECT** se anotan sin mensaje. Al compilar, iverilog imprime además
**1.926 avisos** `warning: Timing checks are not supported.`, uno por cada `$setup`, `$hold`,
`$width`, `$recovery`, `$removal` o `$period` de los bloques specify del modelo.

El renombrado de instancias sigue siendo necesario y creció con el diseño nuevo:
`asic/sim/renombrar_instancias.py` renombra **3.787 instancias** con nombre jerárquico escapado
(`\u_soc.u_core.u_rf/_2913_ ` pasa a `u_soc__u_core__u_rf___2913_`) en el netlist y **20.939
referencias** en el SDF, comprobando que no choquen con otros identificadores. Sin eso vvp aborta
con `vpi_scan(vpiHandle): Assertion 0 failed` en el primer INTERCONNECT a una de esas celdas, en
Icarus 13.0 y en 14.0: el lector de SDF parte el nombre por los puntos como si fuera una ruta
jerárquica. Con el renombrado, ninguna de las nueve ejecuciones abortó.

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
`-gspecify` ni siquiera avisa. En el netlist completo son los 1.926 avisos al compilar y los 951
`TIMINGCHECK not supported` al anotar de la sección 2.4.

Conclusión: la simulación con Icarus demuestra que el netlist post-PnR con los retardos de celda e
interconexión anotados ejecuta el programa igual que el RTL (misma traza, sin X) en las tres esquinas
simuladas, pero NO verifica ningún margen de setup, hold, ancho de pulso, recovery ni removal: los
**7.173 checks** del SDF se ignoran. `make post-pnr-sdf` lo dice en su resumen y no reporta "0
violaciones". Esos márgenes los garantiza el STA de las 9 esquinas (`asic/verificar_cierre.py`:
WNS de setup 59,174 ns y de hold 0,082 ns en la peor esquina de `d2_pnr`,
`asic/sim/resultados/d2_pnr/cierre.md`) y, en simulación, CVC (sección 4).

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

Fuente: `build/post_pnr/cvc/d2_pnr/<esquina>/resumen.md`, `cvcsim_<n>.log`, `sdf_cvc_<n>.log`,
`tiempo_<n>.txt`, `traza_<n>.txt` y `comparacion_<n>.txt` (n = 1, 2, 3).

| esquina | ciclos | cambios de salida | con X | igual al RTL | 3 md5 iguales | tiempo real de cvc64 +interp (s), 3 ejecuciones | anotación: errores / avisos | violaciones de timing reportadas |
|---|---|---|---|---|---|---|---|---|
| nom_tt_025C_5v00 | 4500 | 16 | 0 | **sí (3 de 3)** | sí | 19,576 / 19,279 / 18,195 | 0 / 6 (aviso 3106, puertos de entrada) | **0** |
| max_ss_125C_4v50 | 4500 | 16 | 0 | **sí (3 de 3)** | sí | 20,582 / 21,556 / 18,167 | 0 / 6 | **0** |
| min_ff_n40C_5v50 | 4500 | 16 | 0 | **sí (3 de 3)** | sí | 20,636 / 19,864 / 18,520 | 0 / 6 | **0** |

md5 de las nueve trazas: **`5b6cebfb898a90a258b592fb29e64651`**, el mismo del RTL y el mismo de las
nueve trazas de Icarus de la sección 2.2. La referencia del RTL es la de Icarus, porque CVC no
compila el RTL (cae con Segmentation fault, sección 4.1).

CVC evalúa los **7.173 checks** de los 951 bloques TIMINGCHECK (menos los 19 INTERCONNECT quitados,
que no son checks) y en 4.500 ciclos a 100 ns **no reporta ninguna violación** en ninguna de las tres
esquinas ni en ninguna de las tres ejecuciones (el script comprueba que el conteo de violaciones sea
el mismo en las tres). Es consistente con el STA: el peor WNS de setup de `d2_pnr` es 59,174 ns y el
de hold 0,082 ns. La anotación es completa: 0 errores y 6 avisos (el 3106, de puertos de entrada)
sobre los 36.473 IOPATH, los 16.301 INTERCONNECT menos los 19 quitados y los 951 bloques
TIMINGCHECK, contra los 2.468 IOPATH que Icarus no puede anotar (sección 2.4). Esa es la razón de
correr los dos simuladores.

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
  esquina `nom_tt`, `build/post_pnr/cvc/d2_pnr/nom_tt_025C_5v00_control_estimulo1/`): **8 violaciones
  en 4 instancias (4 `$setup`, 2 `$removal`, 2 `$recovery`)**, las mismas en las tres ejecuciones
  (4,720 / 4,798 / 4,624 s, mismo md5 `72fe2fbc5b3e0dcc51367756add6b9d1`), y la traza se cae: 1 cambio
  de salida y ese cambio con valores X, contra los 16 sin X de la configuración buena. `comparar.py`
  da FAIL y el objetivo falla, que es lo que el control exige. Con los límites del SDF:
  - **`$removal` y `$recovery` en `_4334_` y `_4335_`**, que son los dos flip-flops `dffrnq_1` del
    sincronizador de reset (`rst_sync_q[0]` y `rst_sync_q[1]` en
    `asic/sim/runs/d2_pnr/final/nl/asic_top.nl.v`): `rst_n` llega al pin RN a los 351.296 ps y el
    reloj al pin CLK a los 351.410 ps, o sea **114 ps** de diferencia, contra 359 ps de removal y
    229 ps de recovery exigidos por el SDF.
  - **`$setup` en `_4340_` y `_4341_`**, los dos primeros flip-flops del sincronizador de botones
    (`u_soc.u_periph.btn_meta[0]` y `[1]`): el dato llega **146 ps** antes del flanco en `btn_meta[0]`
    con 289 ps exigidos, y **176 ps** antes en `btn_meta[1]` con 282 ps exigidos. Cada uno viola dos
    veces, en los dos flancos de la pulsación.

  Los cuatro son exactamente los flip-flops que reciben una entrada del exterior, que es lo que el
  control manipula: con `ESTIMULO = 1` la entrada cambia 1 ns después del flanco externo, y el reloj
  llega a esos flip-flops 1,4 ns después del flanco externo (sección 1), así que la entrada cambia
  dentro de la ventana de setup o de recovery. **Esto es lo que demuestra el control**: CVC sí evalúa
  los checks con los valores del SDF, y los reporta con el instante y el límite exacto.

## 5. Conclusión

- **El netlist post-PnR de `d2_pnr` con los retardos de celda e interconexión del SDF ejecuta el
  escenario de la sección 3.7 exactamente igual que el RTL** en las esquinas típica, lenta y rápida,
  sin valores X y de forma reproducible: 18 ejecuciones en total (tres por esquina y por simulador)
  con un solo md5, `5b6cebfb898a90a258b592fb29e64651`, que es también el de la traza del RTL y el de
  `make post-synth`. Icarus 13.0 de la imagen tarda 77 a 103 s por ejecución y CVC 7.00b, 18 a 22 s.
- **Icarus NO evalúa los timing checks** (aviso textual al compilar, 951 bloques TIMINGCHECK
  ignorados al anotar): su resultado prueba la función con retardos, no los márgenes. Los márgenes
  los verifica el STA de las 9 esquinas (criterio de cierre) y, en simulación, **CVC: 0 violaciones
  en las tres esquinas, en las tres ejecuciones de cada una, con 7.173 checks activos**, y un control
  positivo que reporta 8 violaciones en los cuatro flip-flops que reciben entradas del exterior
  cuando esas entradas llegan antes que el reloj interno.
- **Los dos simuladores se complementan en la anotación**: Icarus deja 2.468 IOPATH sin anotar (los
  arcos `ifnone` con flanco de `mux2_2`, `xor2_1` y `xnor2_1`, que la norma 1364 no admite) y CVC
  anota todo con 0 errores, a cambio de necesitar el modelo sin esos `ifnone` y el SDF sin los 19
  INTERCONNECT hacia puertos de salida. Que las dos anotaciones distintas den la misma traza es
  evidencia de que la diferencia no cambia el comportamiento.
- **Para simular con retardos las entradas tienen que aplicarse lejos del flanco** (`ESTIMULO = 50`):
  con el +1 ns de `make post-synth` el reloj interno (latencia 0,98 a 2,80 ns según la esquina)
  captura la entrada un ciclo antes que el RTL. En el chip real los botones son asíncronos y el
  sincronizador de dos etapas resuelve ese caso, que es justamente lo que el control positivo muestra
  como violación de setup en `btn_meta`.
