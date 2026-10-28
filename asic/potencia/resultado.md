# Potencia con actividad real de la corrida final (frente D3)

Potencia del macro de la corrida final (`asic/rom/runs/final`, T = 100 ns, FP_CORE_UTIL = 40 %)
calculada por OpenSTA con la actividad de conmutacion de una simulacion del netlist post-PnR
ejecutando el juego real, en vez de la actividad por defecto que uso el flujo (los 8,97 mW de
`55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`, docs/hechos_flujo.md, seccion 10).

Todo lo de este documento es un calculo de OpenSTA sobre el netlist, los parasitos y el liberty, con
actividad tomada de una simulacion funcional sin retardos; no es una medicion sobre silicio. Cada
numero tiene su archivo de origen en `asic/potencia/resultados/`.

## 1. Resumen

| Esquina | Flujo (sin actividad) | Solo reloj | Pantalla de inicio (polling) | Espera de 3 s de la ronda | Alrededor del 01 en el display | Rafaga round_begin |
|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 8,971 mW | 9,084 mW | 11,504 mW (+28,2 %) | 12,755 mW (+42,2 %) | 12,379 mW (+38,0 %) | 12,172 mW (+35,7 %) |
| `max_ss_125C_4v50` | 7,399 mW | 7,491 mW | 9,514 mW (+28,6 %) | 10,548 mW (+42,6 %) | 10,236 mW (+38,3 %) | 10,061 mW (+36,0 %) |
| `min_ff_n40C_5v50` | 10,997 mW | 11,110 mW | 14,040 mW (+27,7 %) | 15,558 mW (+41,5 %) | 15,105 mW (+37,4 %) | 14,856 mW (+35,1 %) |

Origen: `resultados/{defecto,cero,polling,espera,display,rafaga}_<esquina>.rpt`, fila `Total` de
`report_power`. Las 9 esquinas estan en `resultados/tablas.md`.

- La estimacion del flujo (8,97 mW en nom_tt) solo cuenta el arbol de reloj (3,71 mW) y la energia
  interna de los pines CLK de los 990 flip-flops (5,26 mW): la actividad por defecto de OpenSTA
  (0,1 transiciones por ciclo en las entradas, duty 0,5, propagada) se extingue en los registros y
  deja 0,0 % de logica combinacional. Con la actividad real del programa la logica combinacional
  pasa a 2,3 a 3,5 mW (20 a 28 % del total) y el total sube entre 28 % y 42 % segun la fase del
  juego: 11,5 a 12,8 mW en la esquina tipica.
- El reloj sigue dominando: el arbol (3,71 mW, independiente de la actividad) mas los pines CLK de
  los flip-flops (5,3 mW) son 8,9 a 9,1 mW, el 70 a 78 % del total con actividad real. El diseno no
  tiene clock gating y todos los flip-flops reciben el reloj cada ciclo.
- La fase mas larga del juego (los 3 s de espera de cada ronda, lazo `wt_wait_loop`) es tambien la
  de mayor potencia: 12,76 mW en nom_tt, 15,56 mW en min_ff y 10,55 mW en max_ss.
- OpenSTA leyo de verdad la actividad: 20679 de 20679 pines anotados desde el VCD en todas las
  ventanas y esquinas (`report_activity_annotation`), y la actividad anotada en pines con nombre
  coincide con las transiciones contadas directamente en el VCD (seccion 5).
- Incertidumbre declarada: los 804 flip-flops sin reset arrancan en x en la simulacion y OpenSTA no
  cuenta las transiciones a y desde x. Repitiendo las 4 ventanas con esos flip-flops en 0 y en 1
  (seccion 7.4, 24 reportes mas) el total se mueve entre -1,2 % y +1,8 %, con la base siempre entre
  los dos valores. Es la cota de error de todos los totales de este documento.

## 2. Que se uso (archivos de origen y versiones)

De `resultados/versiones.txt` (md5 de 32 caracteres):

| Que | Archivo | md5 |
|---|---|---|
| Netlist post-PnR | `asic/rom/runs/final/final/nl/asic_top.nl.v` (identico a `52-openroad-fillinsertion/asic_top.nl.v`) | `14b9a3c4728d0ec6d2df1304ece1f84a` |
| SPEF min | `asic/rom/runs/final/final/spef/min/asic_top.min.spef` | `20b4494747869e3958ffdea287a4dbcd` |
| SPEF nom | `asic/rom/runs/final/final/spef/nom/asic_top.nom.spef` (identico a `54-openroad-rcx/nom/`) | `bcc30d8f9cbfb0e595acc80ab821f593` |
| SPEF max | `asic/rom/runs/final/final/spef/max/asic_top.max.spef` | `7f2f0c77c7be7e1a6de9933963d33149` |
| SDC | `asic/rom/runs/final/final/sdc/asic_top.sdc` (reloj de 100 ns propagado, `set_propagated_clock`) | `84709c30e945cd68da18d4c713df65a2` |
| Liberty | `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__{tt_025C_5v00,ss_125C_4v50,ff_n40C_5v50}.lib` | |
| Modelos de celdas (simulacion) | `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/{primitives.v,gf180mcu_fd_sc_mcu7t5v0.v}` con `-DFUNCTIONAL` | |
| Estimulos | `asic/sim/estimulos_final.txt` (boton 0001 en el ciclo 1000, suelto en el 150000) | |
| Testbench | `asic/potencia/potencia_tb.v` | `4a682c29c30dcb1c1578d3e9f39d0fb0` |
| Script de OpenSTA | `asic/potencia/potencia.tcl` | `53a208bdcd6d0a0cd43d7e98a2e8ea54` |

PDK_ROOT = `$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee`. Las 9 esquinas
son las de `STA_CORNERS` de la corrida (`55-openroad-stapostpnr/nom_tt_025C_5v00/_env_*.tcl`):
{min, nom, max} de parasitos por {tt_025C_5v00, ss_125C_4v50, ff_n40C_5v50} de liberty.

Herramientas:

- Icarus Verilog 14.0 (devel) (s20260301-403-g5ab23063f-dirty) del host
  (`export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH`), para compilar y simular el netlist.
- OpenSTA 2.7.0 (`sta -version`) de la imagen `ghcr.io/librelane/librelane:3.0.16`, el mismo binario
  que corrio el paso `OpenROAD.STAPostPNR` de la corrida final (`55-openroad-stapostpnr/COMMANDS`:
  `sta -no_splash -exit .../openroad/sta/corner.tcl`). Se invoca como
  `docker run --rm --user "$(id -u):$(id -g)" -v "$HOME:$HOME" -w "$(pwd)" -e HOME="$HOME" -e PDK_ROOT=...
  -e ESQUINA=... -e MODO=... [-e VCD=... -e SCOPE=...] ghcr.io/librelane/librelane:3.0.16 sta -no_splash -exit asic/potencia/potencia.tcl`.
- No hubo corridas de LibreLane (este frente no usa la cola).

Todo lo hace `bash asic/potencia/correr.sh todo` desde la raiz del repo (fases `sim`, `resumen`,
`pc`, `contar`, `sta`, `tabla`; logs en `build/potencia/correr_todo.log` y `correr_resto.log`). El
experimento de sensibilidad de la seccion 7.4 son las fases `xinit` (simula) y `xinit_sta` (solo el
OpenSTA, retomable), con el modelo `asic/potencia/dffq_func_init.v`; logs
`build/potencia/correr_xinit.log` y `correr_xinit_sta.log`.

## 3. Simulacion del netlist y ventanas de actividad

### 3.1 Testbench

`asic/potencia/potencia_tb.v` es una copia adaptada de `tb/post_synth_tb.v`: mismo reset (4 flancos
con `rst_n` en 0, ciclo 0 = primer flanco de subida con `rst_n` en 1), mismos estimulos
(`asic/sim/estimulos_final.txt`), misma traza de salidas, y ademas una ventana `[ini, fin)` de ciclos
por plusargs: en el flanco del ciclo `ini` llama a `$dumpfile`/`$dumpvars(2, dut)` y en el del ciclo
`fin` cierra la simulacion, asi que el VCD abarca exactamente `fin - ini` periodos de 100 ns. El
periodo del testbench es el del macro (100 ns) porque OpenSTA convierte la densidad del VCD
(transiciones por segundo) a transiciones por periodo de la SDC.

Profundidad 2 de `$dumpvars`: el `read_vcd` de OpenSTA 2.7.0 anota actividad por nombre de pin
(`<instancia>/<puerto>`), no por net. Con `$dumpvars(1, dut)` el VCD solo trae los nets del nivel
superior del netlist plano y OpenSTA anota 28 pines (los puertos del macro:
`resultados/polling_prof1_nom_tt_025C_5v00.rpt`, "Annotated 28 pin activities", 20651 sin anotar, y
una potencia de 8,981 mW, igual a la del flujo). Con profundidad 2 cada celda es un `$scope` del VCD
con sus puertos y OpenSTA anota los 20679 pines. Icarus asigna el mismo codigo de VCD a un net y a
los puertos conectados a el, por eso el archivo crece poco (27462 variables, 6894 codigos distintos).

Con `-DRTL` el mismo testbench instancia el RTL (`DebounceDivBits=15`, la ROM real `rtl/gen/pochoco_rom.v`)
sin VCD y escribe el histograma del PC de la etapa IF (`u_soc.u_core.u_if.pc_q`) dentro de la
ventana, que es lo que justifica que ciclos cubre cada una (el netlist plano no permite leer el PC).

### 3.2 Ventanas

| Ventana | Que cubre | Ciclos [ini, fin) | Ciclos | VCD (MB) | Variables / codigos | Duracion del VCD | Tiempo de simulacion (vvp) |
|---|---|---|---|---|---|---|---|
| polling | pantalla de inicio: lazo `ss_wait_press` (lw BTN / beq) | [500, 20500) | 20000 | 81,1 | 27462 / 6894 | 2.000.000 ns | 18,0 s |
| espera | los 3 s de la ronda 1: lazo `wt_wait_loop` (lw CYCLES / sub / bltu) | [265000, 285000) | 20000 | 89,9 | 27462 / 6894 | 2.000.000 ns | 3 min 24 s |
| display | 2000 ciclos centrados en el cambio del display al 01 (ciclo 262194) | [261194, 263194) | 2000 | 10,7 | 27462 / 6894 | 200.000 ns | 3 min 9 s |
| rafaga | solo la rafaga `round_begin` + `show_bcd` + multiplicacion de `wait_tenths` | [262150, 262490) | 340 | 3,2 | 27462 / 6894 | 34.000 ns | 3 min 5 s |
| polling_prof1 | calibracion: polling con `$dumpvars(1, dut)` | [500, 20500) | 20000 | 69,8 | 5821 / 5821 | 2.000.000 ns | 15,5 s |

Origen: `resultados/ventanas.txt` (tamano con `stat`, variables y codigos contando `$var`, extremos
de tiempo del VCD) y `resultados/sim_<ventana>.log` (`time vvp`). Los VCD estan en `build/potencia/`
y no se versionan. El tiempo de simulacion lo fija el numero de ciclos hasta `fin`, no el tamano del
VCD: unos 1.100 a 1.400 ciclos por segundo con este netlist (20.822 instancias incluidas las de
relleno), asi que una ventana cerca del ciclo 285.000 cuesta unos 3,5 minutos. No hizo falta el
netlist de simulacion con el debounce corto: la medida principal es con el netlist real.

Las ventanas (a), (b) y (c) son las pedidas en el brief; `rafaga` es extra, para aislar el unico
tramo con escrituras a los perifericos y division (show_bcd) sin mezclarlo con los lazos de espera.

`resultados/ventanas.txt` tiene 13 filas: estas 5 mas las 8 del experimento de sensibilidad de la
seccion 7.4 (`<ventana>_init0` y `<ventana>_init1`, mismos ciclos, con el modelo
`asic/potencia/dffq_func_init.v`).

### 3.3 Justificacion de los ciclos (traza, debounce y programa)

- Estimulos: boton 0 apretado en el ciclo 1000 y soltado en el 150000 (`asic/sim/estimulos_final.txt`).
- Debounce (`rtl/debounce.v`, `DebounceDivBits=15`, `Ticks=3`): un tick cada 32768 ciclos (contador
  libre desde el reset: ticks en 32767, 65535, 98303, 131071, ...); en cada tick el registro de
  desplazamiento toma la muestra y `clean_o` cambia cuando las 3 muestras ANTERIORES son iguales,
  o sea en el 4.o tick despues del cambio. Pulsacion: ticks 32767, 65535 y 98303 con 1, aceptada en
  el tick 131071. Liberacion (150000): ticks 163839, 196607 y 229375 con 0, aceptada en el tick 262143.
- Traza del netlist (`build/post_synth/traza_netlist_final.txt`, identica a la del RTL
  `traza_rtl_final.txt`, `asic/sim/resultado_final.md`: PASS): `262156 led=1111 disp=00` y
  `262194 led=1111 disp=01`. 262156 = 262143 + 13 ciclos (ultima vuelta de `ss_wait_release` mas
  `li`/`sw` de `round_begin`); el 01 llega 38 ciclos despues, tras `show_bcd` (division por 10 con
  restas, 4 duplicaciones, `sw` al display).
- Histograma del PC del RTL (`resultados/pc_<ventana>.txt`, tabla completa en
  `resultados/ventanas_pc.md`; instrucciones de `rtl/gen/pochoco_rom.v` = `sw/game.s` ensamblado):
  - polling [500, 20500): solo 0x0024 `lw x9, 8(x2)` (3333 ciclos), 0x0028 `beq x9, x0, L0024`
    (10001) y 0x002c (6666, la busqueda especulativa de PC+4 que el salto descarta): 20000 ciclos de
    `ss_wait_press`, 6 ciclos por vuelta. El boton apretado en el 1000 no cambia nada hasta el
    131071: `resultados/pc_pulsacion.txt` (ventana [130000, 133000)) muestra el paso de
    `ss_wait_press` a la semilla (0x002c `lw x3, 12(x2)`, 0x0030) y a `ss_wait_release`
    (0x0038/0x003c) justo ahi.
  - espera [265000, 285000): solo 0x01bc `lw x13, 12(x2)` (2500), 0x01c0 `sub x14, x13, x9` (7500),
    0x01c4 `bltu x14, x11, L01bc` (5000) y 0x01c8 (5000, especulativa): 2500 vueltas de
    `wt_wait_loop`, 8 ciclos por vuelta. El lazo dura ESPERA_TENTHS x CYCLES_PER_TENTH =
    30.000.000 ciclos (3 s), desde ~262490 hasta ~30.262.500, asi que la ventana esta entera dentro
    y, como el lazo es periodico, 20000 ciclos lo representan.
  - display [261194, 263194): 958 ciclos de `ss_wait_release` (0x0038/0x003c/0x0040) hasta el tick
    262143, la rafaga (`round_begin`, `show_bcd` con `div`, `sw LEDS`, `sw DISP`, las 30 vueltas de la
    multiplicacion de `wait_tenths`) y 711 ciclos de `wt_wait_loop`. Es una mezcla; sirve como
    "ventana corta alrededor de la escritura al display" del brief.
  - rafaga [262150, 262490): solo la rafaga (340 ciclos), 81 % de ellos en las 30 vueltas del lazo
    de multiplicacion de `wait_tenths` (0x01a8 a 0x01b4 mas la busqueda especulativa de 0x01b8).
- Trazas de salidas: en cada ventana la traza del netlist es identica a la del RTL con el mismo
  testbench (`resultados/traza_<ventana>.txt` contra `resultados/traza_rtl_<ventana>.txt`,
  `correr.sh pc`: "traza del netlist identica a la del RTL" en las 4), y ningun cambio de salida
  tiene X.

La fase WAIT_PRESS (lazo de 13 ciclos con el paso del LFSR, cuando el jugador reacciona) no se
simulo: empieza despues de los 30 M ciclos de la espera, entre 6 y 8 horas de vvp con este netlist
(estimacion a partir de los 1.100 a 1.400 ciclos/s medidos; no se midio). Queda como pendiente
(seccion 8).

## 4. OpenSTA: carga y modos (`asic/potencia/potencia.tcl`)

El script carga lo mismo que `librelane/scripts/openroad/sta/corner.tcl` (via `io.tcl`:
`read_timing_info`, `read_current_netlist`, `read_current_sdc`, `read_spefs`) pero con los archivos
que la corrida dejo en `final/`:

```
set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um
set sta_report_default_digits 6
define_corners $esquina
read_liberty -corner $esquina $lib        ;# tt_025C_5v00 | ss_125C_4v50 | ff_n40C_5v50
read_verilog asic/rom/runs/final/final/nl/asic_top.nl.v
link_design asic_top
read_sdc asic/rom/runs/final/final/sdc/asic_top.sdc
read_spef -corner $esquina asic/rom/runs/final/final/spef/<rc>/asic_top.<rc>.spef   ;# min | nom | max
<modo>
report_activity_annotation [-report_unannotated]
report_power -corner $esquina
report_power -corner $esquina -highest_power_instances 20
get_property <pin> activity   (sonda, 3 puertos y 8 pines)
report_power -corner $esquina -instances <celdas de la sonda>
sta::design_power
```

Modos (`MODO`):

| Modo | Comando | Para que |
|---|---|---|
| `defecto` | ninguno | lo que hizo el flujo: actividad por defecto de OpenSTA |
| `cero` | `set_power_activity -global -activity 0 -duty $DUTY` (DUTY 0,5; variante `cero_duty0` con 0) | solo conmuta el reloj: separa el consumo del arbol y de los pines CLK |
| `entrada` | `set_power_activity -input -activity $ACTIVIDAD -duty $DUTY` (0,1/0,5 y 0,5/0,5) | comprobar que supone el modo defecto en las entradas |
| `vcd` | `read_vcd -scope potencia_tb/dut build/potencia/<ventana>.vcd` | actividad real |

`read_power_activities -scope ... -vcd ...` (el comando del brief) existe en 2.7.0 pero esta
deprecado desde 9/2024 y solo llama a `read_vcd` con un aviso (`power/Power.tcl` de la imagen,
linea 470: `sta_warn 305 "read_power_activities is deprecated. Use read_vcd."`; copia en
`build/potencia/opensta_Power.tcl.txt`). Por eso el script usa `read_vcd` directamente; es la misma
funcion `read_vcd_file`. La ayuda de los comandos de potencia de esta version esta en
`resultados/ayuda_opensta.txt` (`help set_power_activity`, `read_vcd`, `read_saif`,
`report_activity_annotation`, `report_power`).

Cada esquina se corre en un proceso `sta` propio (2 a 4 s cada uno); los 83 reportes de
`resultados/*.rpt` son 9 esquinas x {defecto, cero, polling, espera, display, rafaga} (54), las 5
calibraciones en nom_tt (`entrada`, `entrada05`, `cero_duty0`, `polling_prof1`, `polling_t0`) y los
24 del experimento de sensibilidad de la seccion 7.4 (4 ventanas x {init0, init1} x 3 esquinas).
El 27-10 a las 21:00 se repitieron `defecto_nom_tt` y `espera_nom_tt` con el mismo script: reportes
identicos linea a linea (`build/potencia/repro_*.rpt`).

## 5. Verificacion de que OpenSTA leyo la actividad

1. `read_vcd` imprime `Annotated 20679 pin activities.` y `report_activity_annotation` da
   `vcd 20679 / unannotated 0` (y `-report_unannotated` no lista ningun pin) en las 4 ventanas y las
   9 esquinas (`resultados/<ventana>_<esquina>.rpt`). En modo `defecto` el mismo comando da
   `unannotated 20679`: 20679 es el total de pines que OpenSTA considera.
2. Sonda: `get_property <pin> activity` devuelve `densidad(1/s) duty origen`. Con VCD el origen es
   `vcd` en todos los pines sondeados; en `defecto` es `input` en los puertos y `propagated` en los
   demas; en `cero`, `global`; el reloj siempre `clock` (lo fija la SDC, 2 transiciones por ciclo).
3. Contraste con el VCD: `asic/potencia/contar_vcd.py` cuenta las transiciones de las senales de la
   sonda directamente en el VCD (`resultados/conteo_<ventana>.txt`) y calcula densidad y duty como
   OpenSTA (transiciones / (t_max - t_min)). Coinciden con lo anotado (tabla "Contraste" de
   `resultados/tablas.md`), por ejemplo en nom_tt, transiciones por ciclo VCD / OpenSTA:

   | Senal | polling | espera | display | rafaga |
   |---|---|---|---|---|
   | `cycles_q[0]` (`u_soc.u_periph.u_cycles/_164_/Q`) | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 |
   | `cycles_q[2]` (`.../_166_/Q`) | 0,2500 / 0,2500 | 0,2500 / 0,2500 | 0,2500 / 0,2500 | 0,2500 / 0,2500 |
   | `pc_id[2]` (`_4418_/Q`) | 0,3333 / 0,3333 | 0,5000 / 0,5000 | 0,4120 / 0,4120 | 0,4500 / 0,4500 |
   | `regs[9][0]` (`u_soc.u_core.u_rf/_3050_/Q`) | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0020 / 0,0020 | 0,0088 / 0,0088 |
   | `operand_a[0]` (`_2617_/ZN`) | 0,0000 / 0,0000 | 0,2500 / 0,2500 | 0,2795 / 0,2790 | 0,1912 / 0,1882 |
   | `btn[0]` (puerto) | 0,0001 / 0,0000 (1 transicion en 20000 ciclos, duty 0,975 en los dos) | 0 / 0 | 0 / 0 | 0 / 0 |

   Las dos diferencias en `operand_a[0]` son exactamente una transicion (559 contra 558 y 65 contra
   64): en display y rafaga esa senal vale x durante 2 ciclos (ciclos 262164 y 262165, dentro de
   `show_bcd`), `contar_vcd.py` cuenta 0 -> x -> 1 como dos transiciones y OpenSTA como una, o sea
   que OpenSTA no cuenta las transiciones hacia o desde x. En espera no hay x y los dos dan 5000.
   Los x del netlist y su efecto en la potencia se cuantifican en la seccion 7.4.
4. `report_power -instances` de la sonda: el flip-flop `cycles_q[0]`, que conmuta cada ciclo, pasa de
   5,53 uW (defecto) a 14,43 uW con cualquier VCD; `pc_id[2]` varia con la ventana (7,99 a 9,27 uW);
   el inversor `_2617_` pasa de 0 a 0,87 a 1,30 uW cuando la ALU trabaja. Los 20 mayores consumidores
   (`-highest_power_instances 20`) son buffers del arbol de reloj en todos los modos
   (`clkbuf_0_clk` 115,6 uW, los 8 `clkbuf_3_*` de 74 a 94 uW, luego `clkbuf_leaf_*` de ~40 uW), y
   sus valores no cambian con el VCD.
5. Desplazamiento temporal: el VCD de polling empieza en t = 50.450.000 ps (ciclo 500). Un VCD
   identico desplazado a t = 0 (`polling_t0`) da exactamente la misma potencia (1,150412e-02 W):
   OpenSTA usa t_max - t_min, no el instante absoluto.

## 6. Calibracion sin VCD

### 6.1 El modo `defecto` reproduce el flujo

`resultados/defecto_<esquina>.rpt` da, en las 9 esquinas, exactamente la fila `Total` de
`asic/rom/runs/final/55-openroad-stapostpnr/<esquina>/power.rpt` (docs/hechos_flujo.md, seccion 10):

| Esquina | Interna | Conmutacion | Fuga | Total (W) |
|---|---|---|---|---|
| `nom_tt_025C_5v00` | 7.021405e-03 | 1.947522e-03 | 1.861619e-06 | 8.970790e-03 |
| `nom_ss_125C_4v50` | 5.711199e-03 | 1.585355e-03 | 1.225439e-05 | 7.308809e-03 |
| `nom_ff_n40C_5v50` | 8.766427e-03 | 2.356705e-03 | 2.258794e-06 | 1.112539e-02 |
| `min_tt_025C_5v00` | 7.004653e-03 | 1.866169e-03 | 1.861619e-06 | 8.872684e-03 |
| `min_ss_125C_4v50` | 5.702248e-03 | 1.519460e-03 | 1.225439e-05 | 7.233962e-03 |
| `min_ff_n40C_5v50` | 8.736267e-03 | 2.258268e-03 | 2.258794e-06 | 1.099679e-02 |
| `max_tt_025C_5v00` | 7.041669e-03 | 2.045552e-03 | 1.861619e-06 | 9.089082e-03 |
| `max_ss_125C_4v50` | 5.721958e-03 | 1.664760e-03 | 1.225439e-05 | 7.398973e-03 |
| `max_ff_n40C_5v50` | 8.802732e-03 | 2.475321e-03 | 2.258794e-06 | 1.128031e-02 |

Los grupos tambien coinciden (nom_tt: Sequential 5.258494e-03, Combinational 3.148489e-06, Clock
3.709155e-03). Es decir, la carga de liberty, netlist, SDC y SPEF es la misma que la del flujo.

### 6.2 Solo reloj (`cero`) y la energia de los pines CLK

Con `set_power_activity -global -activity 0` nada conmuta salvo el reloj (origen `clock`, de la
SDC). En nom_tt:

| Modo | Sequential interna | Combinational | Clock | Total |
|---|---|---|---|---|
| `cero` (duty 0,5) | 5,374 mW | 0,001 mW (solo fuga) | 3,709 mW | 9,084 mW |
| `cero_duty0` (duty 0) | 5,191 mW | 0,001 mW | 3,709 mW | 8,901 mW |
| `defecto` | 5,258 mW | 0,003 mW | 3,709 mW | 8,971 mW |

El grupo Clock (3,709 mW: 1,762 interna + 1,946 de conmutacion de los buffers del arbol que
genero CTS, con sus parasitos del SPEF: la raiz `clkbuf_0_clk`, 8 `clkbuf_3_*` y 66 `clkbuf_leaf_*`
mas 35 `clkload*` de balanceo, celdas `clkbuf_16` y `clkbuf_8` del netlist) es el consumo del arbol
de reloj y no depende de la actividad: el total del grupo Clock es identico en todos los reportes de
una misma esquina (3,709155e-03 W en los 19 de nom_tt, 3,059237e-03 W en los 14 de max_ss y
4,518509e-03 W en los 14 de min_ff, incluidos los 24 del experimento de la seccion 7.4). Los 297 `clkinv_1` del
netlist no son del arbol: Yosys los usa como inversores logicos (p. ej. `_2617_`, que maneja
`operand_a[0]`). El grupo Sequential con actividad 0 es la energia interna
del pin CLK de los 990 flip-flops (804 `dffq_1` + 186 `dffrnq_1`), unos 5,2 a 5,4 uW cada uno,
cargada en cada flanco aunque D no cambie. Que dependa del duty se explica por el liberty: el
`internal_power` del pin CLK del `dffq_1` tiene dos tablas, `when : "!D"` y `when : "D"`
(`gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib`, celda `dffq_1`), y OpenSTA las pondera con el duty
de D; con duty 0 usa solo "!D", y el modo defecto deja la mayoria de los D en duty 0 o 1
(constantes propagadas), de ahi los 5,19, 5,26 y 5,37 mW.

### 6.3 Que supone el modo defecto (actividad por defecto de OpenSTA)

- Sonda en `defecto` (nom_tt): `btn[0]` y `rst_n` tienen densidad 1,00000e+06 1/s, duty 0,500,
  origen `input`, o sea 0,1 transiciones por periodo de 100 ns; todos los pines internos sondeados
  (salidas de flip-flops del contador de ciclos, del PC, del banco de registros, del divisor del
  debounce, de la ROM y la entrada de la ALU) tienen densidad 0 con duty 0 o 1, origen `propagated`.
- `entrada` = `set_power_activity -input -activity 0.1 -duty 0.5` reproduce `defecto` con los 6
  digitos en todos los grupos (8,970790e-03 W): esa ES la actividad por defecto. Con 0,5 en las
  entradas (`entrada05`) el total solo sube a 8,987 mW: la actividad de las entradas apenas llega a
  la logica (btn pasa por el debounce, rst_n por el sincronizador).
- Fuente de OpenSTA: la ayuda de `set_power_activity` no lo documenta y la imagen no trae el
  manual ni `Power.cc`. En `power/Power.cc` de la rama master de github.com/parallaxsw/OpenSTA
  (descargado el 27-10-2026 a `build/potencia/opensta_Power_master.cc`; la etiqueta de la version
  2.7.0 no esta disponible como ruta raw, asi que es la referencia mas cercana, no la del binario),
  `Power::ensureActivities` inicializa `input_activity_` con `density = 0.1 / min_period` y duty
  0,5 (origen `input`) cuando el usuario no fijo ninguna, siembra con eso los puertos de entrada
  (`seedActivities`), propaga por la logica combinacional y cruza los registros D a Q
  (`seedRegOutputActivities`, hasta `max_activity_passes_` pasadas); las actividades del reloj
  "vienen horneadas" de la SDC. Es consistente con lo observado en el binario 2.7.0 (sonda y modo
  `entrada`). En `Power.tcl` de la imagen (linea 368), `-activity` se convierte a densidad
  dividiendo por el periodo minimo de reloj, por eso 0,1 por ciclo = 1e6 1/s a 100 ns.
- Consecuencia: en este diseno la propagacion por defecto se extingue en los registros
  realimentados (contadores, PC, banco de registros, LFSR en registro), que no reciben actividad de
  ninguna entrada, y la estimacion del flujo queda con 0,0 % de logica combinacional y 5,9e-7 W de
  conmutacion secuencial. Solo cuenta el reloj y los pines CLK: 8,97 mW es un piso, no un
  consumo de operacion.

## 7. Resultados con actividad real

### 7.1 Total por modo y esquina (mW) y diferencia contra el modo defecto

| Esquina | defecto | cero | polling | espera | display | rafaga |
|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 8,971 | 9,084 (+1,3 %) | 11,504 (+28,2 %) | 12,755 (+42,2 %) | 12,379 (+38,0 %) | 12,172 (+35,7 %) |
| `nom_ss_125C_4v50` | 7,309 | 7,401 (+1,3 %) | 9,325 (+27,6 %) | 10,316 (+41,1 %) | 10,017 (+37,1 %) | 9,853 (+34,8 %) |
| `nom_ff_n40C_5v50` | 11,125 | 11,239 (+1,0 %) | 14,304 (+28,6 %) | 15,883 (+42,8 %) | 15,411 (+38,5 %) | 15,149 (+36,2 %) |
| `min_tt_025C_5v00` | 8,873 | 8,986 (+1,3 %) | 11,300 (+27,4 %) | 12,504 (+40,9 %) | 12,143 (+36,9 %) | 11,946 (+34,6 %) |
| `min_ss_125C_4v50` | 7,234 | 7,326 (+1,3 %) | 9,169 (+26,7 %) | 10,123 (+39,9 %) | 9,836 (+36,0 %) | 9,679 (+33,8 %) |
| `min_ff_n40C_5v50` | 10,997 | 11,110 (+1,0 %) | 14,040 (+27,7 %) | 15,558 (+41,5 %) | 15,105 (+37,4 %) | 14,856 (+35,1 %) |
| `max_tt_025C_5v00` | 9,089 | 9,202 (+1,2 %) | 11,750 (+29,3 %) | 13,058 (+43,7 %) | 12,664 (+39,3 %) | 12,444 (+36,9 %) |
| `max_ss_125C_4v50` | 7,399 | 7,491 (+1,2 %) | 9,514 (+28,6 %) | 10,548 (+42,6 %) | 10,236 (+38,3 %) | 10,061 (+36,0 %) |
| `max_ff_n40C_5v50` | 11,280 | 11,394 (+1,0 %) | 14,622 (+29,6 %) | 16,275 (+44,3 %) | 15,780 (+39,9 %) | 15,502 (+37,4 %) |

Origen: `resultados/<modo>_<esquina>.rpt`, fila Total; tabla generada por `asic/potencia/tabla.py`
en `resultados/tablas.md`, que ademas tiene el desglose interna / conmutacion / fuga y los
porcentajes de reloj, secuencial y combinacional de cada modo en las 9 esquinas.

### 7.2 Desglose por ventana en las tres esquinas principales (mW y % del total)

| Esquina | Modo | Total | Interna | Conmutacion | Fuga | Reloj (arbol) | Secuencial (flip-flops) | Combinacional |
|---|---|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | defecto | 8,971 | 7,021 | 1,948 | 0,0019 | 3,709 (41,3 %) | 5,258 (58,6 %) | 0,003 (0,0 %) |
| | cero | 9,084 | 7,136 | 1,946 | 0,0019 | 3,709 (40,8 %) | 5,374 (59,2 %) | 0,001 (0,0 %) |
| | polling | 11,504 | 7,985 | 3,517 | 0,0019 | 3,709 (32,2 %) | 5,470 (47,5 %) | 2,325 (20,2 %) |
| | espera | 12,755 | 8,529 | 4,224 | 0,0019 | 3,709 (29,1 %) | 5,509 (43,2 %) | 3,537 (27,7 %) |
| | display | 12,379 | 8,370 | 4,007 | 0,0019 | 3,709 (30,0 %) | 5,498 (44,4 %) | 3,172 (25,6 %) |
| | rafaga | 12,172 | 8,304 | 3,866 | 0,0019 | 3,709 (30,5 %) | 5,463 (44,9 %) | 2,999 (24,6 %) |
| `max_ss_125C_4v50` | defecto | 7,399 | 5,722 | 1,665 | 0,0123 | 41,3 % | 58,6 % | 0,1 % |
| | cero | 7,491 | 5,816 | 1,664 | 0,0123 | 40,8 % | 59,1 % | 0,0 % |
| | polling | 9,514 | 6,467 | 3,035 | 0,0123 | 32,2 % | 47,5 % | 20,4 % |
| | espera | 10,548 | 6,885 | 3,651 | 0,0123 | 29,0 % | 43,1 % | 27,9 % |
| | display | 10,236 | 6,762 | 3,462 | 0,0123 | 29,9 % | 44,3 % | 25,8 % |
| | rafaga | 10,061 | 6,711 | 3,337 | 0,0123 | 30,4 % | 44,8 % | 24,8 % |
| `min_ff_n40C_5v50` | defecto | 10,997 | 8,736 | 2,258 | 0,0023 | 41,1 % | 58,9 % | 0,0 % |
| | cero | 11,110 | 8,851 | 2,257 | 0,0023 | 40,7 % | 59,3 % | 0,0 % |
| | polling | 14,040 | 9,994 | 4,043 | 0,0023 | 32,2 % | 47,9 % | 20,0 % |
| | espera | 15,558 | 10,705 | 4,851 | 0,0023 | 29,0 % | 43,5 % | 27,5 % |
| | display | 15,105 | 10,499 | 4,604 | 0,0023 | 29,9 % | 44,7 % | 25,4 % |
| | rafaga | 14,856 | 10,409 | 4,444 | 0,0023 | 30,4 % | 45,2 % | 24,4 % |

Origen: tabla `report_power` de cada `resultados/<modo>_<esquina>.rpt` (grupos Clock, Sequential y
Combinational; los grupos Macro y Pad son 0). La fuga es 1,9 uW en tt, 2,3 uW en ff y 12,3 uW en ss
(125 C), despreciable en todos los casos.

### 7.3 Que cambia con la actividad real (nom_tt)

| Componente | defecto | espera (maximo) | polling (minimo) | Comentario |
|---|---|---|---|---|
| Clock, grupo completo | 3,709 | 3,709 | 3,709 | arbol de reloj; fijo, lo manda la SDC |
| Sequential interna | 5,258 | 5,341 | 5,325 | pines CLK de los 990 flip-flops mas la energia de D y Q |
| Sequential conmutacion | 0,001 | 0,167 | 0,145 | cargas de las salidas Q que conmutan |
| Combinational interna | 0,002 | 1,426 | 0,899 | compuertas que conmutan (ALU, decodificacion, ROM, mux) |
| Combinational conmutacion | 0,001 | 2,111 | 1,426 | cargas (parasitos del SPEF) de los nets combinacionales |
| Total | 8,971 | 12,755 | 11,504 | |

Toda la diferencia esta en la logica combinacional (2,3 a 3,5 mW) y en los 0,2 a 0,25 mW extra
de los flip-flops; el arbol de reloj no cambia. La diferencia entre ventanas la explica el
programa: `wt_wait_loop` lee CYCLES (32 bits que cambian cada ciclo), resta y compara cada 8
ciclos, mientras `ss_wait_press` solo lee BTN (constante) y salta cada 6 ciclos; `pc_id[2]` conmuta
0,50 veces por ciclo en espera y 0,33 en polling, y `operand_a[0]` 0,25 contra 0.

### 7.4 Sensibilidad al estado inicial de los flip-flops sin reset (x, 0 y 1)

De los 990 flip-flops del netlist final, 804 son `gf180mcu_fd_sc_mcu7t5v0__dffq_1` sin reset
(banco de registros, D4; RAM de datos; registros de la segmentacion) y 186 son `dffrnq_1` con reset
(`grep -c` en `asic/rom/runs/final/final/nl/asic_top.nl.v`). En la simulacion base los `dffq_1`
arrancan en x (el modelo funcional del PDK guarda su estado en la primitiva `udp_n_iq_ff`) y, como
el programa nunca escribe la mayor parte del banco de registros ni la RAM de datos, esos x llegan a
los nodos de los muxes de lectura. `read_vcd` de OpenSTA solo cuenta transiciones entre 0 y 1, asi
que esas lineas quedan fuera: son entre el 3,69 % y el 9,40 % de las lineas de valor de cada VCD
(226 a 1600 senales distintas; `resultados/conteo_x_<ventana>.txt`).

Para acotar cuanto esconde eso se repitieron las 4 ventanas con un modelo de reemplazo,
`asic/potencia/dffq_func_init.v`: mismo comportamiento (`Q <= D` en el flanco de subida, sin
retardos, igual que el modelo del PDK con `-DFUNCTIONAL`) pero con estado inicial `INIT_FF` = 0 o 1.
Se compila definiendo la guarda del modulo original (`-DGF180MCU_FD_SC_MCU7T5V0__DFFQ_FUNC_V`) para
que el del PDK quede fuera; el netlist, el SPEF, la SDC y el liberty son los mismos. Son 8
simulaciones mas (unos 13 minutos de reloj, de a dos; tiempos en `resultados/ventanas.txt`) y 24
reportes de OpenSTA en las 3 esquinas principales
(`resultados/<ventana>_init<0|1>_<esquina>.rpt`; fases `correr.sh xinit` y `correr.sh xinit_sta`,
logs `build/potencia/correr_xinit.log` y `correr_xinit_sta.log`).

Comprobaciones antes de leer los numeros:

- Los 8 VCD no tienen ninguna linea x (`resultados/conteo_x_<ventana>_init<0|1>.txt`, columna
  `lineas_x` = 0): todos los x de la base venian de esos 804 flip-flops, no de otra parte.
- Las 8 simulaciones dan la misma traza de salidas (LEDs, display, estado) que el RTL:
  `correr.sh` compara `resultados/traza_<ventana>_init<I>.txt` con `resultados/traza_rtl_<ventana>.txt`
  y `build/potencia/correr_xinit.log` dice "traza identica a la del RTL" en los 8 casos. El estado
  inicial no cambia lo que hace el juego en estas ventanas.
- OpenSTA anoto 20679 de 20679 pines en los 24 reportes, igual que en la base
  (`report_activity_annotation`): el circuito es el mismo, solo cambio el modelo de simulacion.

| Ventana | Lineas x / lineas 0/1 del VCD base | Esquina | base (x) | init 0 | init 1 | Combinacional base / 0 / 1 |
|---|---|---|---|---|---|---|
| polling | 9,40 % (448 senales) | `nom_tt_025C_5v00` | 11,504 | 11,376 (-1,1 %) | 11,711 (+1,8 %) | 2,325 / 2,255 / 2,456 |
| | | `max_ss_125C_4v50` | 9,514 | 9,403 (-1,2 %) | 9,687 (+1,8 %) | 1,940 / 1,879 / 2,047 |
| | | `min_ff_n40C_5v50` | 14,040 | 13,893 (-1,0 %) | 14,253 (+1,5 %) | 2,801 / 2,721 / 2,963 |
| espera | 3,69 % (226 senales) | `nom_tt_025C_5v00` | 12,755 | 12,748 (-0,1 %) | 12,811 (+0,4 %) | 3,537 / 3,530 / 3,585 |
| | | `max_ss_125C_4v50` | 10,548 | 10,540 (-0,1 %) | 10,593 (+0,4 %) | 2,940 / 2,933 / 2,978 |
| | | `min_ff_n40C_5v50` | 15,558 | 15,551 (-0,0 %) | 15,611 (+0,3 %) | 4,279 / 4,272 / 4,339 |
| display | 7,40 % (1600 senales) | `nom_tt_025C_5v00` | 12,379 | 12,294 (-0,7 %) | 12,495 (+0,9 %) | 3,172 / 3,116 / 3,247 |
| | | `max_ss_125C_4v50` | 10,236 | 10,163 (-0,7 %) | 10,335 (+1,0 %) | 2,638 / 2,590 / 2,700 |
| | | `min_ff_n40C_5v50` | 15,105 | 15,006 (-0,7 %) | 15,216 (+0,7 %) | 3,836 / 3,771 / 3,925 |
| rafaga | 5,55 % (1599 senales) | `nom_tt_025C_5v00` | 12,172 | 12,108 (-0,5 %) | 12,288 (+1,0 %) | 2,999 / 2,942 / 3,098 |
| | | `max_ss_125C_4v50` | 10,061 | 10,008 (-0,5 %) | 10,155 (+0,9 %) | 2,493 / 2,446 / 2,572 |
| | | `min_ff_n40C_5v50` | 14,856 | 14,778 (-0,5 %) | 14,980 (+0,8 %) | 3,628 / 3,559 / 3,753 |

Totales en mW, fila `Total` de `report_power` de cada `.rpt`; columna Combinacional, fila
`Combinational`. Tabla generada por `asic/potencia/tabla.py` en `resultados/tablas.md`, que ademas
trae las lineas de valor 0/1 de cada VCD de init 0 y init 1.

Lectura:

- El rango completo es de -1,2 % a +1,8 % respecto de la base, en las tres esquinas y las cuatro
  ventanas. La base (x) siempre queda entre init 0 e init 1.
- El orden es el mismo en los 12 casos: init 0 por debajo de la base e init 1 por encima. Va en la
  misma direccion que las lineas de valor del VCD: en `polling`, init 1 tiene 19.536.565 lineas 0/1
  e init 0 tiene 17.123.429, contra 18.050.021 de la base
  (`resultados/conteo_x_polling*.txt`). Un 1 en un registro que nunca se escribe hace conmutar mas
  nodos de los muxes de lectura que un 0, que coincide con el valor que ya tienen varios de esos
  nodos.
- Todo el movimiento esta en el grupo `Combinational` (por ejemplo 2,255 a 2,456 mW en `polling`,
  nom_tt); el arbol de reloj y los pines CLK, que son el 70 a 78 % del total, no dependen del estado
  inicial.
- La ventana mas afectada es `polling`, la que mas x tiene (9,40 %) y la que menos logica usa; la
  ventana de mayor potencia, `espera`, se mueve 0,4 % o menos porque el lazo `wt_wait_loop` trabaja
  con registros que ya estan escritos y con CYCLES, que cambia cada ciclo.

Conclusion: los valores x de la simulacion base introducen en los numeros de 7.1 a 7.3 una
incertidumbre acotada por -1,2 % y +1,8 %, un orden de magnitud menor que lo que separa las ventanas
entre si y que el +28 % a +44 % contra la estimacion del flujo. No cambia ninguna conclusion. Si se
quiere un valor conservador, el de init 1 (el mas alto) es el techo medido: 11,711 mW en `polling`,
12,811 mW en `espera`, 12,495 mW en `display` y 12,288 mW en `rafaga`, en nom_tt.

## 8. Limitaciones y pendientes

- La actividad viene de una simulacion funcional sin retardos (`-DFUNCTIONAL`): el VCD no tiene
  glitches de la logica combinacional, asi que la conmutacion combinacional real puede ser algo
  mayor que la calculada. Una simulacion con el SDF anotado (`make post-pnr-sdf`, Icarus de la
  imagen) daria un VCD con glitches; no se hizo en este frente, y no esta cuantificado cuanto
  sumarian.
- Los 804 flip-flops sin reset arrancan en x en la simulacion base y OpenSTA no cuenta las
  transiciones a y desde x (3,69 a 9,40 % de las lineas de valor de cada VCD). El experimento de la
  seccion 7.4 acota el efecto: repitiendo las 4 ventanas con esos flip-flops en 0 y en 1 el total se
  mueve entre -1,2 % y +1,8 %, con la base siempre entre los dos. Queda como incertidumbre
  declarada de todos los totales de las secciones 7.1 a 7.3.
- Ventanas: cubren la pantalla de inicio, la espera de 3 s de la ronda (y, por ser el mismo lazo,
  las esperas de MOSTRAR, ERROR y PROMEDIO) y la rafaga de escrituras. No cubren WAIT_PRESS (lazo
  de polling con el LFSR, unos cientos de ms por ronda) ni la medicion HIT (`cyc2tenths`), que estan
  despues de los 30 M ciclos de la primera espera. Para cubrirlas con el netlist real hay que
  simular ~30,3 M ciclos (horas de vvp) o aceptar el contraste con el netlist de simulacion
  (`asic/sim/runs/sim_rom`, CYCLES_PER_TENTH=1, DebounceDivBits=2), que no es el mismo circuito
  (post-sintesis, sin arbol de reloj ni SPEF) y por eso no se uso.
- Esquinas: las 9 de STA. La potencia que reporta `metrics.json` de la corrida (`power__total` =
  11,28 mW) es la de la ultima esquina procesada, max_ff; la comparable con los 8,97 mW es nom_tt.
- El modelo de potencia es el de OpenSTA (tablas del liberty, parasitos del SPEF, actividad por pin);
  no incluye caida de tension ni temperatura de union distinta de la de la esquina.

## 9. Como repetir

```
export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH
bash asic/potencia/correr.sh todo       # ~12 min: 5 simulaciones (de a 2), 59 corridas de sta, tablas
bash asic/potencia/correr.sh sta        # solo OpenSTA (VCD ya en build/potencia/), ~3 min
bash asic/potencia/correr.sh tabla      # solo resultados/tablas.md y ventanas_pc.md
bash asic/potencia/correr.sh xinit      # seccion 7.4: ~13 min de simulacion + 24 corridas de sta
bash asic/potencia/correr.sh xinit_sta  # solo el OpenSTA de 7.4 (salta los .rpt que ya existen)
bash asic/potencia/correr.sh contar_x   # lineas de valor 0/1 y x de cada VCD (base e init0/init1)
```

Una esquina y ventana a mano:

```
docker run --rm --user "$(id -u):$(id -g)" -v "$HOME:$HOME" -w "$(pwd)" -e HOME="$HOME" \
  -e ESQUINA=nom_tt_025C_5v00 -e MODO=vcd -e VCD=build/potencia/espera.vcd -e SCOPE=potencia_tb/dut \
  ghcr.io/librelane/librelane:3.0.16 sta -no_splash -exit asic/potencia/potencia.tcl
```

## 10. Archivos

- `asic/potencia/potencia_tb.v`: testbench (netlist con VCD por ventana; `-DRTL` para el histograma del PC).
- `asic/potencia/correr.sh`: todo el procedimiento por fases
  (`sim`, `resumen`, `pc`, `contar`, `contar_x`, `sta`, `tabla`, `xinit`, `xinit_sta`).
- `asic/potencia/dffq_func_init.v`: reemplazo del modelo funcional del `dffq` del PDK con estado
  inicial 0 o 1, para el experimento de sensibilidad de la seccion 7.4.
- `asic/potencia/potencia.tcl`: OpenSTA por esquina y modo.
- `asic/potencia/contar_vcd.py`: transiciones y duty de senales del VCD, para contrastar con OpenSTA.
- `asic/potencia/tabla.py`: genera `resultados/tablas.md` y `resultados/ventanas_pc.md`.
- `asic/potencia/resultados/<modo o ventana>_<esquina>.rpt`: 83 reportes de OpenSTA (cada uno con
  `report_activity_annotation`, `report_power`, los 20 mayores consumidores, la sonda y `design_power`);
  los 24 de la seccion 7.4 son `<ventana>_init<0|1>_<esquina>.rpt`.
- `asic/potencia/resultados/tablas.md`, `ventanas_pc.md`, `ventanas.txt`, `versiones.txt`,
  `conteo_<ventana>.txt`, `conteo_x_<ventana>.txt`, `conteo_x_<ventana>_init<0|1>.txt`,
  `pc_<ventana>.txt`, `pc_pulsacion.txt`, `sim_<ventana>.log`, `sim_<ventana>_init<0|1>.log`,
  `traza_<ventana>.txt`, `traza_<ventana>_init<0|1>.txt`, `traza_rtl_<ventana>.txt`,
  `ayuda_opensta.txt`.
- `build/potencia/` (no versionado): VCD, binarios de vvp, logs, reproducciones (`repro_*.rpt`),
  `opensta_Power.tcl.txt`, `opensta_Power_master.cc`, `lib_dffq_1.txt`.
