# Hechos de la corrida final del flujo ASIC

Valores tomados de la corrida `asic/rom/runs/final` (LibreLane 3.0.16, PDK `gf180mcuD`,
biblioteca `gf180mcu_fd_sc_mcu7t5v0`, diseño `asic_top`, `CLOCK_PERIOD = 100` ns), cuyos reportes
quedaron versionados en `asic/rom/resultados/final/`. Cada dato indica el archivo de donde sale.
Las rutas son relativas a la raíz del repositorio, salvo las del PDK, que se indican con el
prefijo `$PDK_ROOT/gf180mcuD`, donde

```
PDK_ROOT = /home/nicolasaraneda/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee
```

(`asic/rom/runs/final/resolved.json`, claves `PDK_ROOT`, `PDK`, `STD_CELL_LIBRARY`,
`meta.librelane_version` = `3.0.16`).

## Qué corrida es esta y en qué se diferencia de v1

Esta es la corrida de la decisión D23: el RTL del pipeline con lectura del banco de registros y
decodificación en el fetch (`EarlyRead`), banco write-through y offset de byte de la carga
registrado en la LSU, **más** la configuración del modelo de cable del resizer y la reparación
después del ruteo global. "v1" es `main` antes de integrar (tag `v1-final`); su corrida quedó en
disco en `asic/rom/runs/v1_final_run` y sus reportes en `asic/rom/resultados/v1_final/`.

El `resolved.json` de las dos corridas difiere en exactamente seis claves (comparación clave por
clave de `asic/rom/runs/v1_final_run/resolved.json` contra
`asic/rom/runs/final/resolved.json`; el resto de las claves son idénticas):

| Clave | v1 | Corrida final nueva |
|---|---|---|
| `SYNTH_PARAMETERS` | `['MemStrategy=1', 'DataWords=4']` | `['MemStrategy=1', 'DataWords=4', 'EarlyRead=1']` |
| `LAYERS_RC` | `None` (sin definir) | definido por grupo de esquinas, con los RC medidos (sección 7.2) |
| `RUN_POST_GRT_DESIGN_REPAIR` | `False` | `True` |
| `RUN_POST_GRT_RESIZER_TIMING` | `False` | `True` |
| `GRT_DESIGN_REPAIR_MAX_SLEW_PCT` | 10 | 30 |
| `GRT_DESIGN_REPAIR_MAX_CAP_PCT` | 10 | 30 |

Esas seis claves son el único cambio de configuración; todo lo demás que cambia en este documento
lo trae el netlist (el RTL nuevo) o es consecuencia de esas seis claves.

**Los números de paso se corrieron.** Como `RUN_POST_GRT_DESIGN_REPAIR` y
`RUN_POST_GRT_RESIZER_TIMING` pasaron a `True`, los dos pasos que antes se omitían antes de crear
directorio ahora crean carpeta: `41-openroad-repairdesignpostgrt` y
`44-openroad-resizertimingpostgrt`. El flujo pasa de 76 a **78** pasos con carpeta (76 carpetas en
`asic/rom/runs/v1_final_run`, 78 en `asic/rom/runs/final`). El corrimiento no es uniforme, porque
las dos carpetas nuevas no están pegadas: las carpetas 1 a 40 conservan su número; las dos que en
v1 eran la 41 (`Odb.DiodesOnPorts`) y la 42 (`OpenROAD.RepairAntennas`) se corren **un** número, al
quedar solo el paso 41 nuevo delante de ellas; y desde la que en v1 era la 43
(`OpenROAD.STAMidPNR-3`) hasta el final se corren **dos**, porque ahí ya quedan delante los dos
pasos nuevos. Los cambios de cita que importan:

| Paso | Carpeta en v1 | Carpeta en la corrida final nueva |
|---|---|---|
| Diodos en puertos | `41-odb-diodesonports` | `42-odb-diodesonports` (un número) |
| Reparación de antenas | `42-openroad-repairantennas` | `43-openroad-repairantennas` (un número) |
| Tercer STA intermedio | `43-openroad-stamidpnr-3` | `45-openroad-stamidpnr-3` |
| Ruteo detallado | `44-openroad-detailedrouting` | `46-openroad-detailedrouting` |
| Segundo chequeo de antenas | `46-openroad-checkantennas-1` | `48-openroad-checkantennas-1` |
| Inserción de relleno | `52-openroad-fillinsertion` | `54-openroad-fillinsertion` |
| Tablas de frecuencia de celdas | `53-odb-cellfrequencytables` | `55-odb-cellfrequencytables` |
| Extracción de parásitos | `54-openroad-rcx` | `56-openroad-rcx` |
| STA posterior al PnR | `55-openroad-stapostpnr` | `57-openroad-stapostpnr` |
| Informe de caída de tensión | `56-openroad-irdropreport` | `58-openroad-irdropreport` |
| Escritura del LEF | `60-magic-writelef` | `62-magic-writelef` |
| Chequeo de antenas del LEF | `61-odb-checkdesignantennaproperties` | `63-odb-checkdesignantennaproperties` |

La lista completa está en la sección 12.

Donde un dato no existe en la corrida se escribe "no disponible" o "no medido" y por qué. No hay
valores estimados. Donde la comparación con v1 aporta algo, el valor de v1 va entre paréntesis con
su archivo.

---

## 1. Restricciones de la SDC

**La SDC generada no cambió.** `diff` entre
`asic/rom/runs/v1_final_run/13-openroad-floorplan/asic_top.sdc` y
`asic/rom/runs/final/13-openroad-floorplan/asic_top.sdc` da salida vacía: los dos archivos son
idénticos byte a byte. Toda esta sección se verificó contra la corrida nueva y no cambia ningún
valor.

La corrida no define `PNR_SDC_FILE` ni `SIGNOFF_SDC_FILE`, así que todos los pasos de OpenROAD
leyeron la SDC genérica de LibreLane
(`asic/rom/runs/final/flow.log`, líneas 22 y 23: "'PNR_SDC_FILE' is not defined. Using generic
fallback SDC"; `resolved.json`, clave `FALLBACK_SDC`). La SDC escrita por el floorplan,
`asic/rom/runs/final/13-openroad-floorplan/asic_top.sdc`, es la materialización de esas variables.

| Variable | Valor | Efecto en la SDC | Fuente del valor | Fuente del efecto |
|---|---|---|---|---|
| `CLOCK_UNCERTAINTY_CONSTRAINT` | 0.25 ns | `set_clock_uncertainty 0.2500 clk` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `CLOCK_TRANSITION_CONSTRAINT` | 0.15 ns | `set_clock_transition 0.1500 [get_clocks {clk}]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `TIME_DERATING_CONSTRAINT` | 5 (%) | `set_timing_derate -early 0.9500` y `set_timing_derate -late 1.0500` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `IO_DELAY_CONSTRAINT` | 20 (% del período) | con `CLOCK_PERIOD = 100` ns da 20.0 ns: `set_input_delay 20.0000` y `set_output_delay 20.0000` en todos los puertos | `resolved.json` | `13-openroad-floorplan/openroad-floorplan.log`, líneas 19 y 20: "Setting output delay to: 20.0", "Setting input delay to: 20.0"; `13-openroad-floorplan/asic_top.sdc` |
| `OUTPUT_CAP_LOAD` | 72.91 fF | `set_load -pin_load 0.0729` en cada puerto de salida (19 puertos) | `resolved.json` | `13-openroad-floorplan/openroad-floorplan.log`, línea 21: "Setting load to: 0.07291"; `13-openroad-floorplan/asic_top.sdc` |
| `MAX_FANOUT_CONSTRAINT` | 10 | `set_max_fanout 10.0000 [current_design]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `MAX_TRANSITION_CONSTRAINT` | 3 ns | `set_max_transition 3.0000 [current_design]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `MAX_CAPACITANCE_CONSTRAINT` | 0.2 pF | `set_max_capacitance 0.2000 [current_design]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `SYNTH_DRIVING_CELL` | `gf180mcu_fd_sc_mcu7t5v0__inv_1/ZN` | `set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__inv_1 -pin {ZN}` en `rst_n`, `spi_cs_n`, `spi_mosi`, `spi_sclk`, `btn[3:0]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `SYNTH_CLK_DRIVING_CELL` | `gf180mcu_fd_sc_mcu7t5v0__inv_4/ZN` | `set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__inv_4 -pin {ZN}` en `clk` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `SYNTH_STRATEGY` | `AREA 0` | no aparece en la SDC: es la estrategia de mapeo de Yosys/ABC | `resolved.json` | - |

Detalles adicionales de la SDC (`13-openroad-floorplan/asic_top.sdc`):

- `create_clock -name clk -period 100.0000 [get_ports {clk}]`.
- `set_input_delay` en 8 puertos: `btn[0..3]`, `rst_n`, `spi_cs_n`, `spi_mosi`, `spi_sclk`
  (conteo verificado: `grep -c set_input_delay` da 8).
- `set_output_delay` en 19 puertos: `led[0..3]`, `seg1[0..6]`, `seg2[0..6]`, `spi_miso`
  (`grep -c set_output_delay` da 19, igual que `grep -c set_load`).
- Las dos transiciones de entrada de `set_driving_cell` son 0.0000 (rise y fall).

El RTL nuevo no cambió los puertos del top: el DEF del floorplan de la corrida nueva declara 28
pines, los mismos 8 de entrada más 19 de salida más `clk`
(`14-openroad-dumprcvalues/openroad-dumprcvalues.log`, ODB-0130: "Created 28 pins").

## 2. Floorplan

Fuente: `asic/rom/runs/final/13-openroad-floorplan/openroad-floorplan.log` y
`asic/rom/runs/final/final/metrics.json` (copia idéntica en `asic/rom/resultados/final/metrics.json`,
verificado con `diff`).

Todo lo que crece en esta sección lo trae el RTL nuevo, no la configuración del modelo de cable: el
floorplan corre en el paso 13, mucho antes de cualquier reparación.

| Dato | Valor | Fuente |
|---|---|---|
| Comando | `initialize_floorplan -site GF018hv5v_mcu_sc7 -utilization 40.0 -aspect_ratio 1.0 -core_space 15.68 15.68 6.720000000000001 6.720000000000001` | `13-openroad-floorplan/openroad-floorplan.log`, línea 27 (idéntico al de v1) |
| Modo de dimensionado | `FP_SIZING = relative`, `FP_CORE_UTIL = 40`, `FP_ASPECT_RATIO = 1`; `DIE_AREA` y `CORE_AREA` sin definir | `resolved.json` |
| Die (bbox) | (0.000, 0.000) a (638.505, 656.425) µm (v1: 630.600 x 648.520) | `13-openroad-floorplan/openroad-floorplan.log`, línea 30 (IFP-0100); métrica `design__die__bbox` = `0.0 0.0 638.505 656.425` (v1: `asic/rom/resultados/v1_final/metrics.json`, `0.0 0.0 630.6 648.52`) |
| Core (bbox) | (6.720, 15.680) a (631.680, 638.960) µm | `13-openroad-floorplan/openroad-floorplan.log`, línea 31 (IFP-0101); métrica `design__core__bbox` = `6.72 15.68 631.68 638.96` |
| Área del die | 419131 µm² (v1: 408957) | métrica `design__die__area` en `final/metrics.json` (v1: `asic/rom/resultados/v1_final/metrics.json`) |
| Área del core | 389525.069 µm² (v1: 379800.333) | `13-openroad-floorplan/openroad-floorplan.log`, línea 32 (IFP-0102); métrica `design__core__area` = 389525 |
| Sitio | `GF018hv5v_mcu_sc7`, 0.56 µm de ancho por 3.92 µm de alto | `13-openroad-floorplan/openroad-floorplan.log`, línea 25: "Using site height: 3.92 and site width: 0.56"; `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef`: `SITE GF018hv5v_mcu_sc7 ... SIZE 0.56 BY 3.92 ;` |
| Alto de fila | 3.92 µm (igual al alto del sitio) | mismo tech LEF y log de floorplan |
| Número de filas | 159 filas de 1116 sitios cada una (v1: 157 de 1102) | `13-openroad-floorplan/openroad-floorplan.log`, línea 29 (IFP-0001): "Added 159 rows of 1116 site GF018hv5v_mcu_sc7"; métricas `design__rows` = 159, `design__sites` = 177444 (= 159 x 1116) |
| Márgenes del core | abajo y arriba 15.68 µm; izquierda y derecha 6.72 µm | argumento `-core_space 15.68 15.68 6.72 6.72` en `13-openroad-floorplan/openroad-floorplan.log` |
| Multiplicadores de margen | `BOTTOM_MARGIN_MULT = 4`, `TOP_MARGIN_MULT = 4`, `LEFT_MARGIN_MULT = 12`, `RIGHT_MARGIN_MULT = 12` | `resolved.json` |
| Área de instancias al cerrar el floorplan | 156282.874 µm² (v1: 152353.466) | `13-openroad-floorplan/openroad-floorplan.log`, línea 33 (IFP-0103) |
| Utilización efectiva al cerrar el floorplan | 0.401 (igual que en v1: es el objetivo relativo de `FP_CORE_UTIL`) | `13-openroad-floorplan/openroad-floorplan.log`, línea 34 (IFP-0104) |
| Número de instancias al cerrar el floorplan | 5577 (v1: 5118) | `13-openroad-floorplan/openroad-floorplan.log`, línea 35 (IFP-0105) |

Los márgenes son los multiplicadores por la dimensión del sitio: 4 x 3.92 = 15.68 µm en vertical
y 12 x 0.56 = 6.72 µm en horizontal. Los dos multiplicadores, el comando y el sitio son idénticos a
los de v1; el die crece porque el netlist tiene más celdas y la utilización objetivo es relativa.

## 3. Celdas de tap y de borde

Fuente: `asic/rom/runs/final/resolved.json`,
`asic/rom/runs/final/19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` y
`asic/rom/runs/final/55-odb-cellfrequencytables/cell.rpt` (en v1 esta última carpeta era la 53).

| Dato | Valor | Fuente |
|---|---|---|
| Celda de tap (`WELLTAP_CELL`) | `gf180mcu_fd_sc_mcu7t5v0__filltie` | `resolved.json` |
| Celda de borde (`ENDCAP_CELL`) | `gf180mcu_fd_sc_mcu7t5v0__endcap` | `resolved.json` |
| `FP_TAPCELL_DIST` | 20 µm | `resolved.json`; argumento `-distance 20.0` del comando `tapcell` |
| Comando ejecutado | `tapcell -halo_width_x 10.0 -halo_width_y 10.0 -distance 20.0 -tapcell_master gf180mcu_fd_sc_mcu7t5v0__filltie -endcap_master gf180mcu_fd_sc_mcu7t5v0__endcap` | `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log`, línea 12 (idéntico al de v1) |
| Taps insertados | 2497 (v1: 2466) | `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log`, línea 14 (TAP-0005: "Inserted 2497 tapcells"); corroborado en `55-odb-cellfrequencytables/cell.rpt` (`__filltie` = 2497) y en la métrica `design__instance__count__class:tap_cell` = 2497 |
| Endcaps insertados | 318 (v1: 314) | `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log`, línea 13 (TAP-0004: "Inserted 318 endcaps"); corroborado en `55-odb-cellfrequencytables/cell.rpt` (`__endcap` = 318) y en la métrica `design__instance__count__class:endcap_cell` = 318 |
| Área de taps | 10962.83 µm² (v1: 10826.73) | reporte de tipos de celda en `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log`, línea 21; métrica `design__instance__area__class:tap_cell` = 10962.8 |
| Área de endcaps | 1396.15 µm² (v1: 1378.59) | mismo reporte de tipos de celda, línea 20; métrica `design__instance__area__class:endcap_cell` = 1396.15 |
| Halos usados por `tapcell` | 10 µm en X y 10 µm en Y (`FP_MACRO_HORIZONTAL_HALO = 10`, `FP_MACRO_VERTICAL_HALO = 10`) | `resolved.json`; `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` |
| `RUN_TAP_ENDCAP_INSERTION` | `True` | `resolved.json` |

El paso previo `18-openroad-cutrows` corrió `cut_rows -halo_width_x 10.0 -halo_width_y 10.0
-endcap_master gf180mcu_fd_sc_mcu7t5v0__endcap` sin cambiar la cuenta de instancias (5577 antes y
después, contra 5118 en v1), porque el diseño no tiene macros
(`18-openroad-cutrows/openroad-cutrows.log`, línea 12 y reporte de tipos de celda de la línea 23;
`resolved.json`, `MACROS = None`).

## 4. Red de alimentación (PDN) y caída de tensión

### 4.1 Variables usadas

La corrida no define `PDN_CFG` (usa el script de PDN de LibreLane) ni `PDN_OBSTRUCTIONS`.
Todas las variables provienen de `asic/rom/runs/final/resolved.json`. En LibreLane 3.0.16 las
variables se llaman `PDN_*`; no existen claves con prefijo `FP_PDN_*` en `resolved.json` (eran el
nombre antiguo en OpenLane 1), con la única excepción de `FP_TAPCELL_DIST`, que no es de PDN.
Verificado en la corrida nueva: las claves que empiezan con `FP_` son `FP_ASPECT_RATIO`,
`FP_CORE_UTIL`, `FP_DEF_TEMPLATE`, `FP_FLIP_SITES`, `FP_MACRO_HORIZONTAL_HALO`,
`FP_MACRO_VERTICAL_HALO`, `FP_OBSTRUCTIONS`, `FP_PRUNE_THRESHOLD`, `FP_SIZING`,
`FP_TAPCELL_DIST`, `FP_TEMPLATE_COPY_POWER_PINS`, `FP_TEMPLATE_MATCH_MODE` y `FP_TRACKS_INFO`;
ninguna es `FP_PDN_*`.

**Las 36 variables `PDN_*` tienen el mismo valor que en v1**, verificado clave por clave entre
`asic/rom/runs/v1_final_run/resolved.json` y `asic/rom/runs/final/resolved.json`.

| Variable | Valor |
|---|---|
| `PDN_CFG` | `None` (se usó el script de PDN por defecto del flujo) |
| `PDN_RAIL_LAYER` | `Metal1` |
| `PDN_RAIL_WIDTH` | 0.6 µm |
| `PDN_RAIL_OFFSET` | 0 |
| `PDN_ENABLE_RAILS` | `True` |
| `PDN_VERTICAL_LAYER` | `Metal4` |
| `PDN_VWIDTH` | 1.6 µm |
| `PDN_VPITCH` | 153.6 µm |
| `PDN_VOFFSET` | 16.32 µm |
| `PDN_VSPACING` | 1.7 µm |
| `PDN_HORIZONTAL_LAYER` | `Metal5` |
| `PDN_HWIDTH` | 1.6 µm |
| `PDN_HPITCH` | 153.18 µm |
| `PDN_HOFFSET` | 16.65 µm |
| `PDN_HSPACING` | 1.7 µm |
| `PDN_MULTILAYER` | `True` |
| `PDN_CORE_RING` | `False` (no hay anillo de core) |
| `PDN_CORE_RING_HWIDTH` | 1.6 µm (sin efecto: `PDN_CORE_RING = False`) |
| `PDN_CORE_RING_VWIDTH` | 1.6 µm (sin efecto) |
| `PDN_CORE_RING_HSPACING` | 1.7 µm (sin efecto) |
| `PDN_CORE_RING_VSPACING` | 1.7 µm (sin efecto) |
| `PDN_CORE_RING_HOFFSET` | 6 µm (sin efecto) |
| `PDN_CORE_RING_VOFFSET` | 6 µm (sin efecto) |
| `PDN_CORE_RING_ALLOW_OUT_OF_DIE` | `True` (sin efecto) |
| `PDN_CORE_RING_CONNECT_TO_PADS` | `False` (sin efecto) |
| `PDN_EXTEND_TO` | `core_ring` |
| `PDN_ENABLE_PINS` | `True` |
| `PDN_ENABLE_GLOBAL_CONNECTIONS` | `True` |
| `PDN_CONNECT_MACROS_TO_GRID` | `True` (sin efecto: no hay macros) |
| `PDN_MACRO_CONNECTIONS` | `None` |
| `PDN_HORIZONTAL_HALO` | 10 µm |
| `PDN_VERTICAL_HALO` | 10 µm |
| `PDN_SKIPTRIM` | `False` |
| `PDN_OBSTRUCTIONS` | `None` |
| `PDN_CORE_HORIZONTAL_LAYER` | `None` |
| `PDN_CORE_VERTICAL_LAYER` | `None` |

### 4.2 Redes de alimentación

| Dato | Valor | Fuente |
|---|---|---|
| Red de alimentación | `VDD` (`VDD_PIN = VDD`; `VDD_NETS = None`) | `resolved.json` |
| Red de tierra | `VSS` (`GND_PIN = VSS`; `GND_NETS = None`) | `resolved.json` |
| Pines de alimentación de la biblioteca | `SCL_POWER_PINS = ['VDD', 'VNW']` | `resolved.json` |
| Pines de tierra de la biblioteca | `SCL_GROUND_PINS = ['VSS', 'VPW']` | `resolved.json` |
| Grilla generada | una sola, `stdcell_grid` | `21-openroad-generatepdn/openroad-generatepdn.log`, línea 15 (PDN-0001: "Inserting grid: stdcell_grid") |
| Conectividad | `All shapes on net VDD are connected` y `All shapes on net VSS are connected` | `21-openroad-generatepdn/openroad-generatepdn.log`, líneas 34 y 35 (PSM-0040) |
| Violaciones de grilla | 0 en VDD y 0 en VSS (igual que en v1) | métricas `design__power_grid_violation__count__net:VDD` y `__net:VSS` en `final/metrics.json`, las dos en 0; `21-openroad-generatepdn/VDD-grid-errors.rpt` y `VSS-grid-errors.rpt` quedaron vacíos (1 línea cada uno); `flow.log`, línea 79: "Check for power grid violations ... clear" |

Lo que quedó en el DEF del paso de PDN
(`asic/rom/runs/final/21-openroad-generatepdn/asic_top.def`, sección `SPECIALNETS`,
`UNITS DISTANCE MICRONS 2000`), contado con las sentencias `+ ROUTED` y `NEW` de los dos
`SPECIALNETS`:

| Forma | Corrida final nueva | v1 |
|---|---|---|
| Rieles en `Metal1` de 1200 DBU = 0.6 µm (coincide con `PDN_RAIL_WIDTH`) | 160 | 158 |
| Straps en `Metal4` de 3200 DBU = 1.6 µm (coincide con `PDN_VWIDTH`) | 8 | 8 |
| Straps en `Metal5` de 3200 DBU = 1.6 µm (coincide con `PDN_HWIDTH`) | 8 | 8 |
| Vías declaradas en `Metal1` | 640 | 632 |
| Vías declaradas en `Metal2` | 640 | 632 |
| Vías declaradas en `Metal3` | 640 | 632 |
| Vías declaradas en `Metal4` | 32 | 32 |

Fuente de la columna de v1: `asic/rom/runs/v1_final_run/21-openroad-generatepdn/asic_top.def`,
misma sección. La DBU sigue en 2000 y la cadena `RING` no aparece en la sección `SPECIALNETS` de
ninguna de las dos corridas, consistente con `PDN_CORE_RING = False`. El número de rieles sigue al
alto del core: dos rieles más porque hay dos filas más (sección 2).

### 4.3 Caída de tensión (IR drop)

El paso `58-openroad-irdropreport` corrió (`RUN_IRDROP_REPORT = True` en `resolved.json`).
En v1 este paso era el `56`.
Fuente: `asic/rom/runs/final/58-openroad-irdropreport/irdrop.rpt` y las métricas de
`asic/rom/runs/final/final/metrics.json`.

| Red | Esquina | Potencia total | Tensión de alimentación | Peor tensión | Tensión promedio | IR drop promedio | Peor IR drop | Porcentaje |
|---|---|---|---|---|---|---|---|---|
| VDD | `nom_tt_025C_5v00` | 9.62e-03 W | 5.00e+00 V | 5.00e+00 V | 5.00e+00 V | 4.10e-05 V | 6.11e-04 V | 0.01 % |
| VSS | `nom_tt_025C_5v00` | 9.62e-03 W | 0.00e+00 V | 2.19e-04 V | 3.53e-05 V | 3.53e-05 V | 2.19e-04 V | 0.00 % |

En v1 (`asic/rom/runs/v1_final_run/56-openroad-irdropreport/irdrop.rpt`) las dos filas eran
8.97e-03 W de potencia, 3.10e-05 V de IR drop promedio y 1.48e-04 V de peor IR drop en VDD, y
2.96e-05 V / 2.48e-04 V en VSS, con 0.00 % de caída en las dos. El peor IR drop de VDD sube un
factor 4.1 porque la configuración nueva pone muchos más buffers conmutando (sección 7.3), no por
un cambio en la grilla: la grilla es la misma salvo los dos rieles de más.

Métricas correspondientes en `final/metrics.json`:

```
ir__drop__avg                                                      = 4.1e-05
ir__drop__worst                                                    = 0.000611
ir__voltage__worst                                                 = 5
design_powergrid__drop__average__net:VDD__corner:nom_tt_025C_5v00  = 4.99996
design_powergrid__drop__average__net:VSS__corner:nom_tt_025C_5v00  = 3.52957e-05
design_powergrid__drop__worst__net:VDD__corner:nom_tt_025C_5v00    = 0.0006108
design_powergrid__drop__worst__net:VSS__corner:nom_tt_025C_5v00    = 0.0002192
design_powergrid__drop__worst                                      = 0.0006108
design_powergrid__voltage__worst__net:VDD__corner:nom_tt_025C_5v00 = 4.99939
design_powergrid__voltage__worst__net:VSS__corner:nom_tt_025C_5v00 = 0.0002192
design_powergrid__voltage__worst                                   = 0.0002192
```

**Cambio cualitativo que el informe tiene que recoger:** en v1 la métrica agregada
`design_powergrid__drop__worst` valía 0.000247773 y venía de VSS (era el máximo de las dos redes).
En la corrida final nueva vale 0.0006108 y **viene de VDD**, porque el peor IR drop de VDD
(6.108e-04 V) ya supera el de VSS (2.192e-04 V). Las métricas desglosadas
`design_powergrid__drop__worst__net:VDD` y `__net:VSS` lo muestran directamente.
`design_powergrid__voltage__worst`, en cambio, sigue valiendo lo mismo que la de VSS
(0.0002192), porque es el mínimo de tensión y VSS parte de 0 V.

IR drop en el resto de las esquinas: **no disponible**. El paso `58-openroad-irdropreport` solo
analizó la esquina por defecto. En `58-openroad-irdropreport/irdrop.rpt` aparece únicamente
`Corner : nom_tt_025C_5v00` (líneas 5 y 18, una por red; el archivo tiene 26 líneas en total), y
todas las métricas `design_powergrid__*` de
`final/metrics.json` llevan el sufijo `__corner:nom_tt_025C_5v00`; no hay métricas
`design_powergrid__*` para ninguna otra esquina. La esquina analizada es la de
`DEFAULT_CORNER = nom_tt_025C_5v00` (`resolved.json`). La tensión no viene de una variable de la
corrida sino del liberty: `58-openroad-irdropreport/openroad-irdropreport.log`, línea 12, dice
"Using voltage extracted from lib (5V) for power nets and 0V for ground nets". Esto no cambió
respecto de v1.

## 5. Placement

| Dato | Valor | Fuente |
|---|---|---|
| `PL_TARGET_DENSITY_PCT` | `None` (no fijada explícitamente) | `resolved.json` |
| Densidad objetivo usada | 0.532942 (53.2942 %), calculada dinámicamente por el flujo (v1: 0.533277) | `flow.log`, línea 74: "'PL_TARGET_DENSITY_PCT' not explicitly set, using dynamically calculated target density: 53.294200"; `28-openroad-globalplacement/openroad-globalplacement.log`, línea 63, GPL-0023 "Placement target density: 0.5329" |
| Densidad mínima factible informada | 0.4500 (área de celdas / área libre), igual que en v1 | `28-openroad-globalplacement/openroad-globalplacement.log`, línea 141 (GPL-1004) |
| `GPL_CELL_PADDING` | 0 | `resolved.json`; en el comando: `-pad_right 0 -pad_left 0` |
| `DPL_CELL_PADDING` | 0 | `resolved.json` |
| Comando de global placement | `global_placement -density 0.5329419999999999 -routability_driven -pad_right 0 -pad_left 0 -init_wirelength_coef 0.25` | `28-openroad-globalplacement/openroad-globalplacement.log`, línea 14 |
| Otras variables de GPL | `PL_ROUTABILITY_DRIVEN = True`, `PL_WIRE_LENGTH_COEF = 0.25`, `PL_TIMING_DRIVEN = False`, `PL_SKIP_INITIAL_PLACEMENT = False`, `PL_OPTIMIZE_MIRRORING = True` | `resolved.json` (idénticas a las de v1) |
| Comando de detailed placement | `detailed_placement -max_displacement 500 100` (`PL_MAX_DISPLACEMENT_X = 500`, `PL_MAX_DISPLACEMENT_Y = 100`) | `34-openroad-detailedplacement/openroad-detailedplacement.log`, línea 12; `resolved.json` |
| Áreas que vio GPL | instancias movibles 156282.874 µm²; instancias totales 167245.702 µm²; ajuste por densidad de pines 12904.003 µm² (v1: 152353.466, 163180.192 y 11422.369) | `28-openroad-globalplacement/openroad-globalplacement.log`, líneas 19 a 21 (GPL-0036, GPL-0037, GPL-0035) |
| Utilización final de instancias | 0.53511 (v1: 0.479898) | métricas `design__instance__utilization` y `design__instance__utilization__stdcell` en `final/metrics.json`, las dos con el mismo valor |

La densidad objetivo y las áreas de esta sección las fija el netlist de síntesis, que es anterior al
ruteo global, así que el cambio respecto de v1 lo trae el RTL. La utilización final, en cambio, se
mide después de todo el flujo y sube de 0.4799 a 0.5351 por la suma de los dos efectos: el RTL
nuevo y los buffers que agrega la reparación post-GRT.

## 6. CTS

Fuente: `asic/rom/runs/final/resolved.json`,
`asic/rom/runs/final/35-openroad-cts/openroad-cts.log`,
`asic/rom/runs/final/35-openroad-cts/cts.rpt`,
`asic/rom/runs/final/57-openroad-stapostpnr/<esquina>/clock.rpt` (en v1 era `55-`) y
`asic/rom/runs/final/final/metrics.json`.

### 6.1 Celdas de reloj permitidas

Nada de esta subsección cambia respecto de v1: las variables, los dos buffers elegidos y el comando
son idénticos.

| Variable | Valor | Fuente |
|---|---|---|
| `CTS_CLK_BUFFERS` | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_2`, `gf180mcu_fd_sc_mcu7t5v0__clkbuf_4`, `gf180mcu_fd_sc_mcu7t5v0__clkbuf_8` | `resolved.json` |
| `CTS_ROOT_BUFFER` | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_16` | `resolved.json` |
| Buffer de sumidero elegido | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_8` | `35-openroad-cts/openroad-cts.log`, línea 41 (CTS-0051) |
| Buffer de caracterización | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_8` | `35-openroad-cts/openroad-cts.log`, línea 46 (CTS-0049) |
| Otras variables | `CTS_APPLY_NDR = half`, `CTS_SINK_CLUSTERING_ENABLE = True`, `CTS_CLK_MAX_WIRE_LENGTH = 0`, `CTS_DISTANCE_BETWEEN_BUFFERS = 0`, `CTS_DISABLE_POST_PROCESSING = False`; `CTS_MAX_CAP`, `CTS_MAX_SLEW`, `CTS_SINK_CLUSTERING_SIZE`, `CTS_SINK_CLUSTERING_MAX_DIAMETER`, `CTS_BALANCE_LEVELS`, `CTS_CORNERS` sin definir | `resolved.json` |
| Comando ejecutado | `clock_tree_synthesis -buf_list gf180mcu_fd_sc_mcu7t5v0__clkbuf_2 gf180mcu_fd_sc_mcu7t5v0__clkbuf_4 gf180mcu_fd_sc_mcu7t5v0__clkbuf_8 -root_buf gf180mcu_fd_sc_mcu7t5v0__clkbuf_16 -sink_clustering_enable -apply_ndr half` | `35-openroad-cts/openroad-cts.log`, línea 39 |

Las variables son las mismas, pero **el árbol que construyen es distinto**, porque TritonCTS
dimensiona los segmentos con el modelo de cable y ese modelo cambió (sección 7.2). Las dos
subsecciones siguientes dan el árbol nuevo.

### 6.2 Buffers de reloj insertados

De `asic/rom/runs/final/35-openroad-cts/cts.rpt`:

```
Total number of Clock Roots: 1.
Total number of Buffers Inserted: 122.
Total number of Clock Subnets: 122.
Total number of Sinks: 964.
Cells used:
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_8: 121
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_16: 1
Dummys used:
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_2: 19
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_4: 24
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_8: 7
  gf180mcu_fd_sc_mcu7t5v0__clkinv_2: 9
  gf180mcu_fd_sc_mcu7t5v0__clkinv_3: 1
  gf180mcu_fd_sc_mcu7t5v0__clkinv_4: 2
  gf180mcu_fd_sc_mcu7t5v0__inv_2: 14
  gf180mcu_fd_sc_mcu7t5v0__inv_3: 1
  gf180mcu_fd_sc_mcu7t5v0__inv_4: 1
```

En v1 (`asic/rom/runs/v1_final_run/35-openroad-cts/cts.rpt`) eran 75 buffers insertados, 75
subredes de reloj, 990 sumideros, 66 `clkbuf_8` y 9 `clkbuf_16`, y el bloque de cargas ficticias
era `clkbuf_2` 14, `clkbuf_4` 14, `clkbuf_8` 7, `clkinv_1` 3, `clkinv_2` 5, `clkinv_3` 2,
`clkinv_8` 2, `clkinv_12` 1, `inv_1` 1, `inv_2` 4, `inv_3` 6, `inv_4` 2. Dos lecturas:

- Con los RC medidos el CTS reparte el árbol en muchos más buffers chicos y usa un solo
  `clkbuf_16` en la raíz, en vez de nueve. El total de buffers de reloj pasa de 75 a 122.
- Los sumideros bajan de 990 a 964 porque el RTL nuevo tiene menos flip-flops
  (`design__instance__count__class:sequential_cell` = 964 contra 990 en
  `asic/rom/resultados/v1_final/metrics.json`).
- La composición de las cargas ficticias cambia: desaparecen `clkinv_1`, `clkinv_8`, `clkinv_12` e
  `inv_1`, y aparece `clkinv_4`.

El log del paso agrega (`35-openroad-cts/openroad-cts.log`): 122 buffers de reloj creados
(línea 84, CTS-0018), 122 redes de reloj (línea 87, CTS-0015), 78 cargas ficticias insertadas
(línea 95, CTS-0207), mínimo y máximo de buffers en el camino de reloj = 3 (líneas 85 y 86,
CTS-0012 y CTS-0013, igual que en v1), nivel máximo del árbol = 4 (línea 89, CTS-0017; en v1 era 3).
El reporte de tipos de celda tras el CTS (misma bitácora, líneas 102 a 113) cuenta 172
"Clock buffer" (8486.64 µm²) y 28 "Clock inverter" (403.92 µm²), que incluyen las cargas ficticias;
en v1 eran 110 (5830.45 µm²) y 26 (474.16 µm²). Las métricas
`design__instance__count__class:clock_buffer` = 172 y `__class:clock_inverter` = 28 de
`final/metrics.json` coinciden.

### 6.3 Skew y latencia de reloj por esquina

Skew: métricas `clock__skew__worst_setup__corner:*` y `clock__skew__worst_hold__corner:*` de
`asic/rom/runs/final/final/metrics.json`, en ns. Latencia de red: bloque `report_clock_latency`
de `asic/rom/runs/final/57-openroad-stapostpnr/<esquina>/clock.rpt`, transición rise a rise, en ns.
Período mínimo y fmax: bloque `report_clock_min_period` del mismo archivo.
La latencia de fuente es 0.000000 en las nueve esquinas (el reloj es virtual y no propagado:
`clock.rpt` dice `Propagated: no`, `Virtual: yes`); verificado en los nueve archivos de la corrida
nueva.

| Esquina | Skew peor setup | Skew peor hold | Latencia de red mín. | Latencia de red máx. | Skew de `clock.rpt` | Período mínimo / fmax |
|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 0.387555 | -0.535664 | 1.294639 | 1.497700 | 0.203061 | 18.51 ns / 54.03 MHz |
| `nom_ss_125C_4v50` | 0.479851 | -0.751942 | 2.291629 | 2.635195 | 0.343566 | 32.89 ns / 30.41 MHz |
| `nom_ff_n40C_5v50` | 0.348066 | -0.438190 | 0.844189 | 0.984983 | 0.140794 | 12.06 ns / 82.89 MHz |
| `min_tt_025C_5v00` | 0.378599 | -0.527563 | 1.263510 | 1.456326 | 0.192816 | 17.77 ns / 56.28 MHz |
| `min_ss_125C_4v50` | 0.466877 | -0.738661 | 2.236271 | 2.565469 | 0.329198 | 31.81 ns / 31.44 MHz |
| `min_ff_n40C_5v50` | 0.340885 | -0.432505 | 0.823247 | 0.955945 | 0.132699 | 11.58 ns / 86.39 MHz |
| `max_tt_025C_5v00` | 0.398101 | -0.545551 | 1.332993 | 1.548298 | 0.215305 | 19.39 ns / 51.58 MHz |
| `max_ss_125C_4v50` | 0.494514 | -0.768498 | 2.359329 | 2.720373 | 0.361043 | 34.27 ns / 29.18 MHz |
| `max_ff_n40C_5v50` | 0.356460 | -0.445061 | 0.869736 | 1.020290 | 0.150553 | 12.65 ns / 79.07 MHz |

Las nueve filas mejoran respecto de v1 en skew: el peor skew de setup de cada esquina baja entre
0.0126 ns (`max_ff_n40C_5v50`) y 0.0735 ns (`max_ss_125C_4v50`). Los valores de v1, para comparar, están en
`asic/rom/resultados/v1_final/metrics.json` y en
`asic/rom/runs/v1_final_run/55-openroad-stapostpnr/<esquina>/clock.rpt`; la fila de la esquina
típica era 0.420465 / -0.539914 / 1.248330 / 1.479394 / 0.231064 / 18.36 ns y 54.46 MHz. La latencia
de red sube un poco (el árbol tiene un nivel más) y el skew baja (está mejor balanceado).

Los valores agregados (sin sufijo de esquina) de `final/metrics.json` son
`clock__skew__worst_setup = 0.340885` y `clock__skew__worst_hold = -0.432505`, los dos de
`min_ff_n40C_5v50`, igual que en v1 (donde valían 0.355849 y -0.431690 y venían de la misma
esquina).

El desglose del skew de setup en la esquina típica
(`57-openroad-stapostpnr/nom_tt_025C_5v00/skew.max.rpt`) es: latencia de fuente 1.495389 en
`u_soc.u_core.u_rf/_4126_/CLK`, latencia de destino -1.294788 en `_4407_/CLK`, incertidumbre de
reloj 0.250000, CRPR -0.063046, skew de setup 0.387555. En v1 eran 1.479265 en `_4536_/CLK`,
-1.249277 en `_4199_/CLK`, 0.250000, -0.059524 y 0.420465. Los nombres de instancia cambian porque
cambia el netlist; en la corrida nueva el pin de origen lleva prefijo jerárquico
(`u_soc.u_core.u_rf/`), que es el banco de registros del core.

Los pines de latencia mínima y máxima de red en la esquina típica son
`u_soc.u_periph.u_cycles/_171_/CLK` (mínima, 1.294639) y `_4282_/CLK` (máxima, 1.497700)
(`57-openroad-stapostpnr/nom_tt_025C_5v00/clock.rpt`, bloque `report_clock_latency`). En v1 eran
`_4555_/CLK` y `_4537_/CLK`.

### 6.4 Topología

El log sí la informa (`35-openroad-cts/openroad-cts.log`):

- CTS-0027 (línea 52): "Generating H-Tree topology for net clk" (topología H-Tree, igual que en v1).
- CTS-0010 y CTS-0028 (líneas 48 y 53): la red `clk` tiene 964 sumideros (v1: 990).
- CTS-0090 y CTS-0206 (líneas 54 y 57): los sumideros se agrupan por capacidad máxima del buffer;
  la mejor solución fue tamaño de cluster 10 y diámetro 50, igual que en v1.
- CTS-0019 (línea 58): 105 sumideros después del agrupamiento (v1: 66).
- CTS-0020 (línea 56): unidad de segmento de cable 39200 DBU (19 µm), igual que en v1.
- CTS-0024 a CTS-0026 (líneas 59 a 61): región normalizada de sumideros
  [(1.0102, 2.4), (31.1351, 31.15)], ancho 30.1249, alto 28.7500
  (v1: [(1.50217, 3.0875), (30.5396, 30.9118)], ancho 29.0374, alto 27.8243).
- Niveles (líneas 62 a 81, CTS-0034): **cuatro** niveles, no tres como en v1. Nivel 1 horizontal
  (53 sumideros por subregión, subregión 15.0624 x 28.7500, largo de segmento 8), nivel 2 vertical
  (27 sumideros, 15.0624 x 14.3750, largo 8), nivel 3 horizontal (14 sumideros, 7.5312 x 14.3750,
  largo 4), nivel 4 vertical (7 sumideros, 7.5312 x 7.1875, largo 4); criterio de parada con
  máximo de 10 sumideros (línea 82, CTS-0032, igual que en v1), 105 sumideros cubiertos
  (línea 83, CTS-0035).
- CTS-0016 (línea 88): distribución de fanout `5:2, 6:9, 7:14, 8:20, 9:33, 10:23, 11:20`. En v1 era
  `4:1, 8:7, 9:3, 10:1, 11:1, 12:3, 13:2, 14:8, 15:15, 16:17, 17:11, 18:5`: la distribución se
  corre entera hacia abajo y el fanout máximo baja de 18 a 11.
- CTS-0098 a CTS-0102 (líneas 90 a 94): red `clk`, 1042 sumideros, 105 buffers de hoja, largo
  promedio de cable a sumidero 720.41 µm, profundidad de camino 2 a 3 (v1: 1051 sumideros, 66
  buffers de hoja, 755.12 µm, misma profundidad).
- **Hecho de v1 que pasa a ser falso.** El documento de v1 decía que tras el CTS `repair_clock_nets`
  usó largo máximo de cable 11309 µm. En la corrida nueva usa **4491 µm**
  (`35-openroad-cts/openroad-cts.log`, línea 97, RSZ-0058: "Using max wire length 4491um"; en v1 la
  misma línea RSZ-0058 del archivo `asic/rom/runs/v1_final_run/35-openroad-cts/openroad-cts.log`,
  línea 92, decía 11309um). Ese largo máximo lo calcula el resizer a partir del modelo de cable:
  con los RC medidos el cable es más resistivo y más capacitivo, así que el tramo que tolera sin
  buffer baja a menos de la mitad. Es el mismo mecanismo que explica los 122 buffers de reloj.

## 7. Ruteo

| Dato | Valor | Fuente |
|---|---|---|
| `RT_MIN_LAYER` | `Metal2` | `resolved.json`; `39-openroad-globalrouting/openroad-globalrouting.log`, líneas 12 y 15: "Setting signal min routing layer to: Metal2 and clock min routing layer to Metal2" y GRT-0020 "Min routing layer: Metal2" |
| `RT_MAX_LAYER` | `Metal5` | `resolved.json`; `39-openroad-globalrouting/openroad-globalrouting.log`, líneas 13 y 16: "Setting signal max routing layer to: Metal5 ..." y GRT-0021 "Max routing layer: Metal5" |
| `RT_CLOCK_MIN_LAYER` / `RT_CLOCK_MAX_LAYER` | `None`; el log muestra que el reloj heredó `Metal2` y `Metal5` | `resolved.json`; `39-openroad-globalrouting/openroad-globalrouting.log`, líneas 12 y 13 |
| `GRT_ADJUSTMENT` | 0.3 | `resolved.json`; `39-openroad-globalrouting/openroad-globalrouting.log`, GRT-0022 "Global adjustment: 30%" |
| `GRT_LAYER_ADJUSTMENTS` | `[0, 0, 0, 0, 0]` | `resolved.json` |
| Comando de global routing | `global_route -congestion_iterations 50 -verbose` (`GRT_OVERFLOW_ITERS = 50`) | `39-openroad-globalrouting/openroad-globalrouting.log`, línea 14 |
| Comando de detailed routing | `detailed_route -droute_end_iter 64 -or_seed 42 -verbose 1 -output_drc .../drt-run-0/asic_top.drc` (`DRT_OPT_ITERS = 64`) | `46-openroad-detailedrouting/openroad-detailedrouting.log`, línea 13 |
| Hilos del ruteo detallado | 24 | `46-openroad-detailedrouting/openroad-detailedrouting.log`, línea 12 (ORD-0030: "Using 24 thread(s)") |
| Redes de reloj que vio el ruteador global | 123 | `39-openroad-globalrouting/openroad-globalrouting.log`, línea 26 (GRT-0019) |

Las variables y los dos comandos son idénticos a los de v1. Lo que cambia es el resultado:

| Dato | Corrida final nueva | v1 |
|---|---|---|
| Subcorridas del ruteo detallado | 2 (`drt-run-0` y `drt-run-1`) | 1 (`drt-run-0`) |
| Tiempo del paso de ruteo detallado | 00:00:37.079 | 00:00:22.864 |
| `route__wirelength` (largo ruteado, µm) | 377509 | 352253 |
| `route__wirelength__estimated` (µm) | 343035 | 298027 |
| `global_route__wirelength` (µm) | 536222 | 494524 |
| `route__wirelength__max` (cable más largo, µm) | 1713.94 | 1409.36 |
| DRC por iteración (`route__drc_errors__iter:N`) | 2, 0, 430, 3, 0 | 1546, 501, 379, 0 |
| `route__drc_errors` final | 0 | 0 |

Fuentes: `asic/rom/runs/final/46-openroad-detailedrouting/` (existen las dos carpetas `drt-run-0` y
`drt-run-1`), `asic/rom/runs/final/46-openroad-detailedrouting/runtime.txt`,
`asic/rom/runs/final/final/metrics.json` y, para la columna de v1,
`asic/rom/runs/v1_final_run/44-openroad-detailedrouting/runtime.txt` y
`asic/rom/resultados/v1_final/metrics.json`. Las dos corridas cierran con 0 errores de DRC de
ruteo (`flow.log` de la nueva, línea 162: "Check for Routing DRC errors clear").

### 7.1 Capas de metal del tech LEF

Del tech LEF que leyó la corrida,
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef`
(la ruta exacta aparece en `13-openroad-floorplan/openroad-floorplan.log`, línea 9, y en
`resolved.json`, clave `TECH_LEFS`, patrón `nom_*`). El archivo es `VERSION 5.7` (línea 35),
`DATABASE MICRONS 2000` (línea 40), `MANUFACTURINGGRID 0.0050` (línea 57), y declara 15 capas y
56 vías (`13-openroad-floorplan/openroad-floorplan.log`, línea 9, ODB-0227). Es un archivo del PDK:
no lo toca ni el RTL ni `LAYERS_RC`, y todos los valores de esta subsección son idénticos a los de
v1.

| Capa | Tipo | Dirección preferida | Pitch (µm) | Ancho mínimo = WIDTH (µm) | Offset (µm) | Área mínima (µm²) | Espesor (µm) | RPERSQ (ohm) | CPERSQDIST (pF/µm²) |
|---|---|---|---|---|---|---|---|---|---|
| `Metal1` | ROUTING | HORIZONTAL | 0.56 | 0.230 | 0.0 | 0.1444 | 0.54 | 0.090 | 0.0004 |
| `Metal2` | ROUTING | VERTICAL | 0.56 | 0.280 | 0.0 | 0.1444 | 0.54 | 0.090 | 0.0003 |
| `Metal3` | ROUTING | HORIZONTAL | 0.56 | 0.280 | 0.0 | 0.1444 | 0.54 | 0.090 | 0.00028 |
| `Metal4` | ROUTING | VERTICAL | 0.56 | 0.280 | 0.0 | 0.1444 | 0.54 | 0.090 | 0.000277 |
| `Metal5` | ROUTING | HORIZONTAL | 0.9 | 0.440 | 0.0 | 0.5625 | 1.19 | 0.060 | 0.0000394 |

En las cinco capas `MINWIDTH` y `WIDTH` coinciden.

**Corrección respecto de la versión anterior de este documento.** La versión de v1 decía que el
tech LEF solo declara `THICKNESS` en `Metal1` (0.54 µm) y `Metal5` (1.19 µm), y que para `Metal2`,
`Metal3` y `Metal4` el dato no estaba en el archivo. Eso es **falso**: los bloques `LAYER Metal2`,
`LAYER Metal3` y `LAYER Metal4` de
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef`
declaran `THICKNESS 0.54 ;` cada uno. Las cinco capas de ruteo tienen espesor declarado. El error
venía del documento de v1, no del cambio de corrida.

Capas no de ruteo del mismo archivo: `Pwell` y `Nwell` (MASTERSLICE con `LEF58_TYPE`), `Poly2` y
`PR_bndry` (MASTERSLICE), `CON`, `Via1`, `Via2`, `Via3` y `Via4` (CUT; las cuatro `Via*` llevan
`WIDTH 0.26` y `CON` no declara `WIDTH`) y `OVERLAP`.

Pitches por capa que informó el ruteador global
(`39-openroad-globalrouting/openroad-globalrouting.log`, líneas 19 a 23, GRT-0088), idénticos a los
de v1:

| Capa | Track-Pitch | line-2-Via Pitch |
|---|---|---|
| `Metal1` | 0.5600 | 0.4750 |
| `Metal2` | 0.5600 | 0.5600 |
| `Metal3` | 0.5600 | 0.5600 |
| `Metal4` | 0.5600 | 0.5600 |
| `Metal5` | 0.9000 | 0.8200 |

Los tech LEF de los tres grupos de esquinas son archivos distintos: `diff` entre el `__nom.tlef` y
el `__min.tlef`, y entre el `__nom.tlef` y el `__max.tlef`, da diferencias. La tabla de arriba es
la del grupo `nom_*`, que es el que leen el floorplan y todos los pasos de PnR.

### 7.2 Modelo de cable con que estima el resizer (`LAYERS_RC`)

Esta subsección es nueva: la versión de v1 de este documento no la tenía, aunque el paso
`14-openroad-dumprcvalues` ya aparecía en la lista de pasos. Es el hecho central del cambio de
configuración, y el propio flujo deja la evidencia en tres reportes del paso 14.

`LAYERS_RC` de `asic/rom/runs/final/resolved.json` define, por grupo de esquinas, la resistencia
por unidad de longitud y la capacidad por unidad de longitud de cada capa de ruteo. En v1 la clave
valía `None`.

| Capa | `nom_*` res (ohm/µm) | `nom_*` cap (pF/µm) | `min_*` res | `min_*` cap | `max_*` res | `max_*` cap |
|---|---|---|---|---|---|---|
| `Metal1` | 0.78028 | 0.00023788 | 0.70858 | 0.00021165 | 0.85199 | 0.00026941 |
| `Metal2` | 0.64095 | 0.00021719 | 0.58205 | 0.00019324 | 0.69985 | 0.00024598 |
| `Metal3` | 0.64095 | 0.00020271 | 0.58205 | 0.00018036 | 0.69985 | 0.00022958 |
| `Metal4` | 0.64095 | 0.00020054 | 0.58205 | 0.00017843 | 0.69985 | 0.00022712 |
| `Metal5` | 0.27192 | 0.000044824 | 0.24693 | 0.000039882 | 0.29691 | 0.000050766 |

La misma tabla, ya expandida a Tcl, está en `asic/rom/runs/final/14-openroad-dumprcvalues/_env.tcl`,
línea 51 (`set ::env(LAYERS_RC) ...`), que es la forma en que el valor llega a OpenROAD.

El paso `14-openroad-dumprcvalues` escribe tres reportes. Al compararlos con los del mismo paso de
v1 (`asic/rom/runs/v1_final_run/14-openroad-dumprcvalues/`) con `diff`:

| Reporte | ¿Cambia respecto de v1? |
|---|---|
| `tlef_values.rpt` | **idéntico byte a byte** |
| `layer_values_after.rpt` | **idéntico byte a byte** |
| `resizer_values_after.rpt` | difiere |

Los dos primeros contienen los valores del tech LEF tal como los lee ODB, antes y después de fijar
el RC. Son iguales en las cinco capas:

```
Metal1  HORIZONTAL  3.913043e-01 ohm/um   9.200000e-05 pF/um
Metal2  VERTICAL    3.214286e-01          8.400000e-05
Metal3  HORIZONTAL  3.214286e-01          7.840000e-05
Metal4  VERTICAL    3.214286e-01          7.756000e-05
Metal5  HORIZONTAL  1.363636e-01          1.733600e-05
```

(`14-openroad-dumprcvalues/tlef_values.rpt` y `layer_values_after.rpt`). Esos valores salen del
tech LEF por capa: `RPERSQ / WIDTH` y `CPERSQDIST x WIDTH` con los datos de la tabla de la
subsección anterior. Por ejemplo `Metal1`: 0.090 / 0.230 = 3.913043e-01 y 0.0004 x 0.230 = 9.2e-05;
`Metal5`: 0.060 / 0.440 = 1.363636e-01 y 0.0000394 x 0.440 = 1.7336e-05. Las vías llevan
`Via1` a `Via4` con 4.5 ohm de resistencia de corte y `CON` con 0.

El tercero, `resizer_values_after.rpt`, es el que el resizer usa para estimar, y es el que cambia:

| Magnitud, esquina `nom_tt_025C_5v00` | Corrida final nueva | v1 |
|---|---|---|
| RC de estimación, señal, res/longitud | 5.486925e-01 ohm/µm | 2.751623e-01 ohm/µm |
| RC de estimación, señal, cap/longitud | 1.663160e-04 pF/µm (166.3 aF/µm) | 6.432400e-05 pF/µm (64.3 aF/µm) |
| RC de estimación, reloj | igual que señal: 5.486925e-01 y 1.663160e-04 | igual que señal: 2.751623e-01 y 6.432400e-05 |
| RC por capa, `Metal1` | 7.802800e-01 y 2.378800e-04 | 0.000000e+00 y 0.000000e+00 |
| RC por capa, `Metal2` | 6.409500e-01 y 2.171900e-04 | 0.000000e+00 y 0.000000e+00 |
| RC por capa, `Metal3` | 6.409500e-01 y 2.027100e-04 | 0.000000e+00 y 0.000000e+00 |
| RC por capa, `Metal4` | 6.409500e-01 y 2.005400e-04 | 0.000000e+00 y 0.000000e+00 |
| RC por capa, `Metal5` | 2.719200e-01 y 4.482400e-05 | 0.000000e+00 y 0.000000e+00 |
| Resistencia de vía (`CON`, `Via1` a `Via4`) | 0.000000e+00 en las cinco | 0.000000e+00 en las cinco |

Fuentes: `asic/rom/runs/final/14-openroad-dumprcvalues/resizer_values_after.rpt` y
`asic/rom/runs/v1_final_run/14-openroad-dumprcvalues/resizer_values_after.rpt`. Las cinco filas de
RC por capa de la corrida nueva coinciden exactamente con el bloque `nom_*` de `LAYERS_RC` de
`resolved.json`.

Dos hechos que se pueden afirmar con esta evidencia:

1. **`LAYERS_RC` no toca el tech LEF.** `tlef_values.rpt` y `layer_values_after.rpt` son idénticos
   a los de v1, así que lo que ODB guarda por capa no cambió. Lo único que cambia es el modelo con
   que el resizer estima el cable que todavía no existe.
2. **El promedio de estimación es el promedio de las capas de ruteo.** El par de estimación de la
   corrida nueva, 5.486925e-01 y 1.663160e-04, es exactamente el promedio aritmético de las filas
   `Metal2` a `Metal5` del mismo reporte: (0.64095 x 3 + 0.27192) / 4 = 0.5486925 y
   (0.00021719 + 0.00020271 + 0.00020054 + 0.000044824) / 4 = 1.66316e-04. En v1 el mismo promedio,
   tomado sobre las filas `Metal2` a `Metal5` del tech LEF, daba (0.3214286 x 3 + 0.1363636) / 4 =
   2.751623e-01 y (8.4e-05 + 7.84e-05 + 7.756e-05 + 1.7336e-05) / 4 = 6.4324e-05. El rango de capas
   promediado es el que fijan `RT_MIN_LAYER = Metal2` y `RT_MAX_LAYER = Metal5`.

El comando con que OpenROAD aplica estos valores (`set_layer_rc` o `set_wire_rc`) **no queda
escrito en ningún log de la corrida**: una búsqueda de las dos cadenas sobre todos los archivos de
`asic/rom/runs/final` no devuelve coincidencias, y el script que lo ejecuta
(`librelane/scripts/openroad/dump_rc.tcl`, nombrado en
`14-openroad-dumprcvalues/COMMANDS`) vive dentro del entorno de LibreLane y no en el repositorio.
Por eso este documento no transcribe el comando: la evidencia de que el modelo se aplicó son los
tres reportes del paso 14, que son parte de la corrida.

**Hecho de v1 que pasa a ser falso.** Cualquier frase que diga que el resizer de esta corrida
estima con el promedio del tech LEF deja de ser cierta. En la corrida final nueva el resizer
estima con los RC medidos: una resistencia por micrón 1.99 veces mayor y una capacidad por micrón
2.59 veces mayor que la del promedio del tech LEF. Eso es lo que explica, sin ningún otro cambio de
variable, que el resizer y el CTS pongan muchos más buffers.

### 7.3 Reparación después del ruteo global: los dos pasos nuevos

Los pasos `41-openroad-repairdesignpostgrt` y `44-openroad-resizertimingpostgrt` corren en esta
corrida y no corrían en v1. Variables que los habilitan y los parametrizan
(`asic/rom/runs/final/resolved.json`):

| Variable | Valor en la corrida final nueva | Valor en v1 |
|---|---|---|
| `RUN_POST_GRT_DESIGN_REPAIR` | `True` | `False` |
| `RUN_POST_GRT_RESIZER_TIMING` | `True` | `False` |
| `GRT_DESIGN_REPAIR_MAX_SLEW_PCT` | 30 | 10 |
| `GRT_DESIGN_REPAIR_MAX_CAP_PCT` | 30 | 10 |
| `GRT_DESIGN_REPAIR_MAX_WIRE_LENGTH` | 0 (sin límite) | 0 |
| `GRT_DESIGN_REPAIR_RUN_GRT` | `True` | `True` |
| `GRT_RESIZER_SETUP_SLACK_MARGIN` | 0.025 | 0.025 |
| `GRT_RESIZER_HOLD_SLACK_MARGIN` | 0.05 | 0.05 |
| `GRT_RESIZER_SETUP_MAX_BUFFER_PCT` | 50 | 50 |
| `GRT_RESIZER_HOLD_MAX_BUFFER_PCT` | 50 | 50 |
| `GRT_RESIZER_RUN_GRT` | `True` | `True` |
| `GRT_RESIZER_SETUP_BUFFERING` | `True` | `True` |
| `GRT_RESIZER_SETUP_BUFFER_REMOVAL` | `True` | `True` |
| `GRT_RESIZER_SETUP_GATE_CLONING` | `True` | `True` |
| `GRT_RESIZER_ALLOW_SETUP_VIOS` | `False` | `False` |
| `GRT_RESIZER_FIX_HOLD_FIRST` | `False` | `False` |

Es decir: de las dieciséis variables de la tabla solo cuatro cambian de valor. Las dos de
habilitación y los dos márgenes de `repair_design`, que pasan de 10 % a 30 %.

**Paso 41, `OpenROAD.RepairDesignPostGRT`.** Secuencia de comandos, de
`41-openroad-repairdesignpostgrt/openroad-repairdesignpostgrt.log`:

1. `global_route -congestion_iterations 50 -verbose` (línea 36), que deja 528528 µm de largo total
   (línea 80, GRT-0018), el mismo que el paso 39.
2. `repair_design -verbose -max_wire_length 0.0 -slew_margin 30.0 -cap_margin 30.0` (línea 83).
3. `detailed_placement -max_displacement 500 100` (línea 99).
4. `global_route -congestion_iterations 50 -verbose` otra vez (línea 113), que ahora deja 536222 µm
   (línea 157, GRT-0018): el paso agrega 7694 µm de cable.

Resultado de `repair_design`, con los parásitos del ruteo global ya estimados:

| Dato | Valor | Fuente |
|---|---|---|
| Violaciones de slew encontradas | 415 | línea 95 (RSZ-0034) |
| Violaciones de capacidad encontradas | 209 | línea 96 (RSZ-0036) |
| Instancias redimensionadas | 120 | línea 97 (RSZ-0039) |
| Buffers insertados | 394, en 500 redes | línea 98 (RSZ-0038) |
| Crecimiento de área del paso | +5.8 % | tabla de iteraciones, fila `final`, líneas 84 a 94 |
| Redes pendientes al empezar | 6727 | misma tabla, fila 0, columna `Remaining` |

La tabla de iteraciones del log (líneas 84 a 94) muestra el avance: 0, 1000, 2000, ... 6000 y
`final`, con el área pasando de +0.0 % a +5.8 % y las redes reparadas de 0 a 500.

**Paso 44, `OpenROAD.ResizerTimingPostGRT`.** Secuencia, de
`44-openroad-resizertimingpostgrt/openroad-resizertimingpostgrt.log`:

1. `global_route -congestion_iterations 50 -verbose` (línea 36): 536222 µm (línea 80).
2. `repair_timing -verbose -setup -setup_margin 0.025 -max_buffer_percent 50.0` (línea 83; el log
   imprime el margen con todos sus decimales, `0.025000000000000001387778780781445675529539585113525390625`,
   que es el `0.025` de `GRT_RESIZER_SETUP_SLACK_MARGIN` en coma flotante).
   Resultado: línea 85, RSZ-0098 "No setup violations found". La secuencia de movimientos que
   intentó está en la línea 84 (RSZ-0100): `UnbufferMove SizeUpMove SwapPinsMove BufferMove
   CloneMove SplitLoadMove`.
3. `repair_timing -verbose -hold -setup_margin 0.025 -hold_margin 0.05 -max_buffer_percent 50.0`
   (línea 86). Resultado: línea 87, RSZ-0033 "No hold violations found.".
4. `detailed_placement -max_displacement 500 100` (línea 88) y `global_route` final (línea 102),
   que vuelve a dar 536222 µm (línea 146).

O sea: el paso 44 no tuvo que hacer nada. Con los buffers que ya había puesto el paso 41, el
temporizado cerraba en setup y en hold con los márgenes pedidos. El reporte de tipos de celda del
paso 44 (líneas 153 a 164) es idéntico al del paso 41 (líneas 164 a 175): 9927 instancias,
208434.24 µm².

**Conteos de buffers que cambia la configuración nueva.** De `final/metrics.json` contra
`asic/rom/resultados/v1_final/metrics.json`:

| Métrica | Corrida final nueva | v1 |
|---|---|---|
| `design__instance__count__class:timing_repair_buffer` | 1335 | 636 |
| `design__instance__area__class:timing_repair_buffer` | 30838.2 µm² | 11349.2 µm² |
| `design__instance__count__class:clock_buffer` | 172 | 110 |
| `design__instance__area__class:clock_buffer` | 8486.64 µm² | 5830.45 µm² |
| `design__instance__count__class:clock_inverter` | 28 | 26 |
| `design__instance__area__class:clock_inverter` | 403.917 µm² | 474.163 µm² |
| `design__instance__count__hold_buffer` | 0 | 5 |
| `design__instance__area__stdcell` | 208439 µm² | 182265 µm² |
| `design__instance__count` | 22318 | 20822 |
| `design__instance__count__stdcell` | 9928 | 8670 |
| `design__instance__count__class:sequential_cell` | 964 | 990 |

El reporte de tipos de celda de cada paso permite seguir de dónde salen los 1335 buffers de
reparación de temporización: 936 (20046.57 µm²) ya existían al terminar el CTS
(`35-openroad-cts/openroad-cts.log`, línea 108: "Timing Repair Buffer 936 20046.57") y 1335
(30838.17 µm²) hay al terminar el paso 41
(`41-openroad-repairdesignpostgrt/openroad-repairdesignpostgrt.log`, línea 170). Los 399 de
diferencia los agrega el paso 41, que informa 394 buffers insertados y 120 instancias
redimensionadas; el documento no puede atribuir los 5 restantes a una causa concreta con los
archivos de la corrida, así que no lo hace.

**Cuidado con `design__instance__count__hold_buffer`.** La métrica agregada vale 0, pero eso no
significa que el flujo no insertara buffers de hold: el paso 37 (`ResizerTimingPostCTS`) encontró 5
puntos con violación de hold e insertó 5 buffers
(`37-openroad-resizertimingpostcts/openroad-resizertimingpostcts.log`, líneas 38 y 44, RSZ-0046 y
RSZ-0032; su `or_metrics_out.json` registra `design__instance__count__hold_buffer = 5`). La métrica
final la sobrescribe el paso 44, cuyo `or_metrics_out.json` registra
`design__instance__count__hold_buffer = 0` porque ese `repair_timing -hold` no encontró nada que
arreglar. En v1 el paso 37 también insertó 5 y, al no haber paso posterior que la sobrescribiera,
la métrica final quedó en 5. El cambio de 5 a 0 es un cambio de quién escribe la métrica, no un
cambio físico.

**Violaciones de diseño al cerrar, por esquina.** De las métricas
`design__max_*_violation__count__corner:*` de `final/metrics.json` y
`asic/rom/resultados/v1_final/metrics.json`:

| Esquina | Slew nueva | Slew v1 | Cap nueva | Cap v1 | Fanout nueva | Fanout v1 |
|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 0 | 0 | 1 | 19 | 21 | 62 |
| `nom_ss_125C_4v50` | 0 | 351 | 1 | 22 | 21 | 62 |
| `nom_ff_n40C_5v50` | 0 | 0 | 1 | 17 | 21 | 62 |
| `min_tt_025C_5v00` | 0 | 0 | 1 | 12 | 21 | 62 |
| `min_ss_125C_4v50` | 0 | 171 | 1 | 14 | 21 | 62 |
| `min_ff_n40C_5v50` | 0 | 0 | 1 | 10 | 21 | 62 |
| `max_tt_025C_5v00` | 0 | 6 | 1 | 31 | 21 | 62 |
| `max_ss_125C_4v50` | 0 | 546 | 1 | 36 | 21 | 62 |
| `max_ff_n40C_5v50` | 0 | 0 | 1 | 29 | 21 | 62 |
| Agregada (peor esquina) | 0 | 546 | 1 | 36 | 21 | 62 |

**Hecho de v1 que pasa a ser falso: el flujo ya no informa violaciones de slew después del ruteo
global.** En v1 el checker de slew del cierre listaba cuatro esquinas con violaciones
(`max_ss_125C_4v50`, `max_tt_025C_5v00`, `min_ss_125C_4v50`, `nom_ss_125C_4v50`) y solo concluía
"No max slew violations found" al filtrar por `MAX_SLEW_VIOLATION_CORNERS = ['']`. En la corrida
final nueva el checker imprime directamente "No max slew violations found" sin lista de esquinas
(`flow.log`, línea 292), porque hay 0 violaciones en las nueve. Las métricas
`design__max_slew_violation__count__corner:*` valen 0 en las nueve y `max slew violation count 0`
aparece en los nueve `57-openroad-stapostpnr/<esquina>/checks.rpt`. El checker de capacidad, en
cambio, **sigue** listando las nueve esquinas (`flow.log`: encabezado "Max Cap violations found in
the following corners:" en la línea 294, las nueve esquinas en las líneas 295 a 303) y concluyendo
lo mismo en la línea 304 al filtrar por `MAX_CAP_VIOLATION_CORNERS = ['']`, pero ahora con 1
violación por esquina en vez de entre 10 y 36.

La única violación de capacidad que queda es la raíz del árbol de reloj, el mismo pin en las nueve
esquinas: `clkbuf_0_clk/Z`, con límite 0.200000 pF, capacidad 0.401561 pF y slack -0.201561
(`57-openroad-stapostpnr/nom_tt_025C_5v00/checks.rpt`, bloque `max capacitance`). Es un pin que
`repair_design` no toca porque pertenece al árbol de reloj.

**Antenas.** El paso `43-openroad-repairantennas` ahora inserta un diodo, lo que en v1 no pasaba:
`43-openroad-repairantennas/1-openroad-diodeinsertion/openroad-diodeinsertion.log`, línea 12, corre
`repair_antennas gf180mcu_fd_sc_mcu7t5v0__antenna -iterations 3 -ratio_margin 10`; la línea 13
(GRT-0012) encuentra 1 violación de antena y la línea 15 encuentra 0 después de reparar. La misma
línea en v1 (`asic/rom/runs/v1_final_run/42-openroad-repairantennas/1-openroad-diodeinsertion/`)
decía "Found 0 antenna violations". Métricas de `final/metrics.json`:
`antenna_diodes_count = 1`, `design__instance__count__class:antenna_cell = 1`,
`design__instance__area__class:antenna_cell = 4.3904` (la celda `__antenna` mide 1.120 x 3.920 µm
según el cell LEF del PDK); en v1 `antenna_diodes_count = 0`. Los chequeos de antenas de los pasos
40 y 48 y el subpaso 43.2 cierran los tres con 0 violaciones de red y 0 de pin
(ANT-0002 y ANT-0001 de cada log), y `antenna__violating__nets = 0` y `__pins = 0` en las dos
corridas.

**Maestros de celda usados.** El diseño final usa 67 maestros distintos de
`gf180mcu_fd_sc_mcu7t5v0` (`55-odb-cellfrequencytables/cell.rpt`), contra 60 en v1
(`asic/rom/runs/v1_final_run/53-odb-cellfrequencytables/cell.rpt`). Aparecen diez que v1 no usaba
(`__antenna`, `aoi22_2`, `buf_8`, `clkbuf_3`, `clkinv_4`, `dffq_2`, `nor4_2`, `or4_1`, `xnor3_1`,
`xor2_2`) y desaparecen tres (`clkinv_8`, `clkinv_12`, `nor3_2`).

**Temporizado al cerrar.** `timing__setup__ws = 65.72513386236942` ns y
`timing__hold__ws = 0.17272350705252543` ns en `final/metrics.json` (v1: 65.22344804417 y
0.17822821500890565). Las dos vienen de la peor esquina de cada chequeo: setup de
`max_ss_125C_4v50` y hold de `min_ff_n40C_5v50`, igual que en v1. TNS de setup y de hold en 0 en
las dos corridas, y `Setup Vio Count` y `Hold Vio Count` en 0 en las nueve esquinas
(`asic/rom/resultados/final/sta_summary.rpt`, tabla por esquina).

## 8. Relleno (fill y decap)

| Dato | Valor | Fuente |
|---|---|---|
| `FILL_CELLS` | `gf180mcu_fd_sc_mcu7t5v0__fill_*` | `resolved.json` |
| `DECAP_CELLS` | `gf180mcu_fd_sc_mcu7t5v0__fillcap_*` | `resolved.json` |
| `RUN_FILL_INSERTION` | `True` | `resolved.json` |
| Patrones pasados al paso | `gf180mcu_fd_sc_mcu7t5v0__fillcap_* gf180mcu_fd_sc_mcu7t5v0__fill_*` | `54-openroad-fillinsertion/openroad-fillinsertion.log`, línea 12 |
| Total de rellenos colocados | 12390 (v1: 12152) | `54-openroad-fillinsertion/openroad-fillinsertion.log`, línea 13 (DPL-0001: "Placed 12390 filler instances"); métrica `design__instance__count__class:fill_cell` en `final/metrics.json` |
| Área total de relleno | 181086.44 µm² (v1: 197535.07) | reporte de tipos de celda en `54-openroad-fillinsertion/openroad-fillinsertion.log`, línea 20; métrica `design__instance__area__class:fill_cell` = 181086 |

En v1 este paso era el `52` y la carpeta de frecuencias de celdas la `53`.

El área de relleno **baja** aunque el die sea más grande: el relleno es el complemento del área
ocupada, y la configuración nueva ocupa 208439 µm² de celdas estándar contra 182265 µm² en v1, así
que queda menos hueco. El total de instancias del die cierra: 389525.07 µm² de core repartidos en
22318 instancias (`54-openroad-fillinsertion/openroad-fillinsertion.log`, línea 31, fila `Total`
del reporte de tipos de celda), que coincide con `design__core__area` y con
`design__instance__count`.

Desglose por celda, de `asic/rom/runs/final/55-odb-cellfrequencytables/cell.rpt` (tabla
"Cells by Master", generada después de la inserción de relleno):

| Celda | Cantidad | v1 | Tipo | Ancho x alto del cell LEF (µm) |
|---|---|---|---|---|
| `gf180mcu_fd_sc_mcu7t5v0__fill_1` | 3040 | 2853 | fill | 0.560 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fill_2` | 2902 | 2688 | fill | 1.120 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_4` | 2770 | 2763 | decap | 2.240 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_8` | 1911 | 1864 | decap | 4.480 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_16` | 1085 | 1143 | decap | 8.960 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_32` | 429 | 510 | decap | 17.920 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_64` | 253 | 331 | decap | 35.840 x 3.920 |

Subtotales: 5942 celdas de fill (`fill_1` + `fill_2`) y 6448 celdas de decap (los cinco
`fillcap_*`); juntas dan los 12390 rellenos del log. En v1 eran 5541 y 6611. La mezcla se corre
hacia celdas chicas: hay más `fill_1`, `fill_2`, `fillcap_4` y `fillcap_8`, y bastante menos
`fillcap_16`, `fillcap_32` y `fillcap_64`, porque los huecos que deja el diseño más denso son más
estrechos. Las dimensiones vienen de
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lef/gf180mcu_fd_sc_mcu7t5v0.lef`
(sentencia `SIZE` de cada `MACRO`), no del liberty, y no cambian.

Área de las celdas de relleno por separado (fill contra decap): **no disponible**, igual que en v1.
El reporte de tipos de celda de los logs y la métrica `design__instance__area__class:fill_cell`
agrupan ambos grupos en una sola clase "Fill cell" de 181086.44 µm², y
`55-odb-cellfrequencytables/cell.rpt` solo da cantidades, no áreas.

## 9. Extracción de parásitos (RCX)

`RUN_SPEF_EXTRACTION = True` y `RCX_MERGE_VIA_WIRE_RES = True` (`resolved.json`), igual que en v1.
El paso `56-openroad-rcx` (en v1 era el `54`) corrió tres veces, una por grupo de esquinas, según
`RCX_RULESETS` de `resolved.json` (patrones `nom_*`, `min_*`, `max_*`):

| Grupo | Conjunto de reglas usado | SPEF generado |
|---|---|---|
| `nom_*` | `$PDK_ROOT/gf180mcuD/libs.tech/openlane/rules.openrcx.gf180mcuD.nom` | `asic/rom/runs/final/56-openroad-rcx/nom/asic_top.nom.spef` |
| `min_*` | `$PDK_ROOT/gf180mcuD/libs.tech/openlane/rules.openrcx.gf180mcuD.min` | `asic/rom/runs/final/56-openroad-rcx/min/asic_top.min.spef` |
| `max_*` | `$PDK_ROOT/gf180mcuD/libs.tech/openlane/rules.openrcx.gf180mcuD.max` | `asic/rom/runs/final/56-openroad-rcx/max/asic_top.max.spef` |

Fuentes: `asic/rom/runs/final/56-openroad-rcx/{nom,min,max}/rcx.log`, línea 20
("Using RCX ruleset '...'") y línea 23 (el comando
`extract_parasitics -ext_model_file ... -lef_res`); `asic/rom/runs/final/flow.log`, líneas 177 a
179 ("Running RCX for corners matching nom_*", etc.). Los tres SPEF quedaron copiados en
`asic/rom/runs/final/final/spef/{nom,min,max}/`.

El orden en que el flujo lanza los tres grupos **no es un hecho estable**: en v1 el `flow.log` los
lanzó nom, max, min, y en la corrida nueva nom, min, max (líneas 177 a 179). No conviene citarlo
como característica del flujo.

Qué SPEF leyó el STA de firma, por esquina
(`asic/rom/runs/final/57-openroad-stapostpnr/<esquina>/sta.log`, línea "Reading top-level design
parasitics for the '<esquina>' corner at '...'"); verificado en los nueve archivos y sin cambios
respecto de v1:

| Esquinas | SPEF leído |
|---|---|
| `nom_tt_025C_5v00`, `nom_ss_125C_4v50`, `nom_ff_n40C_5v50` | `56-openroad-rcx/nom/asic_top.nom.spef` |
| `min_tt_025C_5v00`, `min_ss_125C_4v50`, `min_ff_n40C_5v50` | `56-openroad-rcx/min/asic_top.min.spef` |
| `max_tt_025C_5v00`, `max_ss_125C_4v50`, `max_ff_n40C_5v50` | `56-openroad-rcx/max/asic_top.max.spef` |

Las nueve esquinas de STA son `STA_CORNERS` de `resolved.json`:
`nom_tt_025C_5v00`, `nom_ss_125C_4v50`, `nom_ff_n40C_5v50`, `min_tt_025C_5v00`,
`min_ss_125C_4v50`, `min_ff_n40C_5v50`, `max_tt_025C_5v00`, `max_ss_125C_4v50`,
`max_ff_n40C_5v50`. `DEDUPLICATE_CORNERS = False`, por eso el STA posterior al PnR
(`57-openroad-stapostpnr`) corrió las nueve (`flow.log`, líneas 186 a 198), a diferencia del
STA previo al PnR (`12-openroad-staprepnr`), donde el flujo omitió las esquinas `min_*` y `max_*`
por ser idénticas a las `nom_*` sin parásitos (`flow.log`, líneas 30 a 38: seis mensajes
"Skipping corner ... for STA (identical to ... at this stage)").

Tech LEF por grupo de esquinas (`resolved.json`, clave `TECH_LEFS`): `nom_*` usa
`gf180mcu_fd_sc_mcu7t5v0__nom.tlef`, `min_*` usa `__min.tlef` y `max_*` usa `__max.tlef`.

## 10. Potencia

### 10.1 Corrida final, por esquina

De `asic/rom/runs/final/57-openroad-stapostpnr/<esquina>/power.rpt`, fila `Total`, en vatios
(en v1 el paso era el `55`):

| Esquina | Interna | Conmutación | Fuga | Total |
|---|---|---|---|---|
| `nom_tt_025C_5v00` | 7.555264e-03 | 2.062282e-03 | 2.051293e-06 | 9.619598e-03 |
| `nom_ss_125C_4v50` | 6.133944e-03 | 1.678706e-03 | 1.310728e-05 | 7.825757e-03 |
| `nom_ff_n40C_5v50` | 9.444290e-03 | 2.496451e-03 | 2.488681e-06 | 1.194323e-02 |
| `min_tt_025C_5v00` | 7.540739e-03 | 1.977563e-03 | 2.051293e-06 | 9.520355e-03 |
| `min_ss_125C_4v50` | 6.125947e-03 | 1.610085e-03 | 1.310728e-05 | 7.749138e-03 |
| `min_ff_n40C_5v50` | 9.417889e-03 | 2.393940e-03 | 2.488681e-06 | 1.181432e-02 |
| `max_tt_025C_5v00` | 7.574218e-03 | 2.164635e-03 | 2.051293e-06 | 9.740905e-03 |
| `max_ss_125C_4v50` | 6.144516e-03 | 1.761613e-03 | 1.310728e-05 | 7.919236e-03 |
| `max_ff_n40C_5v50` | 9.477331e-03 | 2.620298e-03 | 2.488681e-06 | 1.210012e-02 |

Las mismas nueve filas de v1 están en
`asic/rom/runs/v1_final_run/55-openroad-stapostpnr/<esquina>/power.rpt`; la de la esquina típica
era 7.021405e-03 / 1.947522e-03 / 1.861619e-06 / 8.970790e-03. La potencia total sube entre
7.03 % (`max_ss_125C_4v50`) y 7.43 % (`min_ff_n40C_5v50`) en las nueve esquinas, y sube porque hay 699 buffers de reparación de temporización y 62
buffers de reloj más conmutando (sección 7.3).

Las métricas de `asic/rom/runs/final/final/metrics.json` no llevan sufijo de esquina y corresponden
a la última esquina procesada, `max_ff_n40C_5v50`, igual que en v1:

```
power__internal__total  = 0.009477331303060055
power__switching__total = 0.0026202979497611523
power__leakage__total   = 2.4886810479074484e-06
power__total            = 0.012100117281079292
```

Desglose por grupo en la esquina típica
(`57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`), en vatios:

| Grupo | Interna | Conmutación | Fuga | Total | % |
|---|---|---|---|---|---|
| Sequential | 5.022528e-03 | 7.904312e-07 | 3.879749e-07 | 5.023706e-03 | 52.2 % |
| Combinational | 1.746170e-06 | 9.717254e-07 | 8.469992e-07 | 3.564895e-06 | 0.0 % |
| Clock | 2.530989e-03 | 2.060520e-03 | 8.162801e-07 | 4.592326e-03 | 47.7 % |
| Macro | 0 | 0 | 0 | 0 | 0.0 % |
| Pad | 0 | 0 | 0 | 0 | 0.0 % |
| Total | 7.555264e-03 | 2.062282e-03 | 2.051293e-06 | 9.619598e-03 | 100.0 % |

El reparto entre grupos se mueve de manera notable respecto de v1: el grupo `Clock` pasa de 41.3 %
a 47.7 % del total y el grupo `Sequential` baja de 58.6 % a 52.2 %
(`asic/rom/runs/v1_final_run/55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`). En términos
absolutos la potencia de reloj sube de 3.709155e-03 W a 4.592326e-03 W (un 23.8 % más) y la
secuencial baja de 5.258494e-03 W a 5.023706e-03 W, consistente con 26 flip-flops menos y 62
buffers de reloj más.

Reparto de la fila Total en la esquina típica: 78.5 % interna, 21.4 % de conmutación, 0.0 % de fuga
(mismo archivo, línea final del bloque; en v1 era 78.3 / 21.7 / 0.0).

El valor de potencia total que usó el análisis de IR drop, 9.62e-03 W
(`58-openroad-irdropreport/irdrop.rpt`), sigue coincidiendo con el total de `nom_tt_025C_5v00`.

### 10.2 Comparación de potencia a otro período

**No medido en la corrida final nueva.** La versión de v1 de este documento comparaba la potencia
con la corrida `asic/rom/runs/f1_t25`, presentándola como "la misma configuración con
`CLOCK_PERIOD = 25` ns". **Esa frase pasa a ser falsa.** Comparando
`asic/rom/runs/f1_t25/resolved.json` con `asic/rom/runs/final/resolved.json`, las dos corridas
difieren en siete claves, no solo en el período:

| Clave | `f1_t25` | Corrida final nueva |
|---|---|---|
| `CLOCK_PERIOD` | 25 | 100 |
| `SYNTH_PARAMETERS` | `['MemStrategy=1', 'DataWords=4']` | `['MemStrategy=1', 'DataWords=4', 'EarlyRead=1']` |
| `LAYERS_RC` | `None` | definido (sección 7.2) |
| `RUN_POST_GRT_DESIGN_REPAIR` | `False` | `True` |
| `RUN_POST_GRT_RESIZER_TIMING` | `False` | `True` |
| `GRT_DESIGN_REPAIR_MAX_SLEW_PCT` | 10 | 30 |
| `GRT_DESIGN_REPAIR_MAX_CAP_PCT` | 10 | 30 |

Es decir: `f1_t25` tiene el RTL de v1 y la configuración de v1. Ya no es la misma configuración con
otro período, así que sus cifras de potencia no son comparables con las de la sección 10.1 y se
retiran de este documento. No hay en `asic/rom/runs/final` ninguna corrida con la configuración de
D23 a otro período, y este documento solo registra valores de esa corrida, así que la comparación
de potencia contra período queda **no medida** aquí. Las corridas de barrido de período con la
configuración nueva existen fuera de la corrida final y la comparación, si el informe la necesita,
tiene que citarlas por su nombre y no presentarlas como parte de esta acta.

### 10.3 Actividad de conmutación supuesta

**No disponible**, por el mismo motivo que en v1, verificado otra vez sobre los 78 pasos de la
corrida nueva. La corrida no anota actividad: no hay VCD ni SAIF leído en ningún paso (una búsqueda
de `set_power_activity`, `read_saif`, `read_vcd`, `.saif` y `.vcd` sobre todos los `*.log`, los
`COMMANDS`, los `_env.tcl` y los `*.tcl` de `asic/rom/runs/final` no devuelve ninguna
coincidencia), `power.rpt` no imprime la actividad que asumió (`grep -i activity` sobre
`57-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt` sale vacío) y ninguna de las 18 líneas del
archivo `COMMANDS` de `57-openroad-stapostpnr` pasa un argumento de actividad: nueve son
`sta -no_splash -exit .../librelane/scripts/openroad/sta/corner.tcl` sin argumentos, una por
esquina, y las otras nueve son la llamada a
`openroad ... -python .../librelane/scripts/odbpy/filter_unannotated.py --corner <esquina>
--checks-report .../checks.rpt`, que solo filtra el reporte de chequeos. El valor que usa OpenSTA
por defecto queda implícito y la corrida no lo escribe en ningún lado. La configuración nueva no
agregó ninguna anotación de actividad.

Dato adicional de la corrida nueva, que sí está y conviene no confundir con la actividad:
`57-openroad-stapostpnr/nom_tt_025C_5v00/checks.rpt`, bloque
`report_parasitic_annotation -report_unannotated`, informa 81 drivers sin anotar de parásitos. El
desglose de esa lista, contado sobre el propio archivo, es 78 cargas ficticias del árbol de reloj
(`clkload0` a `clkload77`, las mismas 78 que informa CTS-0207 en la sección 6.2) y 3 puertos de
entrada del top (`spi_cs_n`, `spi_mosi`, `spi_sclk`); no son "en su mayoría puertos del top".

## 11. Datos del liberty (esquina típica y lenta)

Archivos (`resolved.json`, clave `LIB`; rutas confirmadas en los logs de cada paso). La clave `LIB`
de la corrida nueva apunta a los mismos tres archivos que en v1, uno por grupo de temperatura y
tensión:

- Esquina típica, `*_tt_025C_5v00`:
  `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib`
  (`operating_conditions(gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00)`: `process : 1`,
  `temperature : 25`, `voltage : 5`).
- Esquina lenta, `*_ss_125C_4v50`:
  `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__ss_125C_4v50.lib`.
- Esquina rápida, `*_ff_n40C_5v50`:
  `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__ff_n40C_5v50.lib`.

Unidades de ambos liberty: `time_unit : 1ns`, `voltage_unit : 1V`, `current_unit : 1mA`,
`capacitive_load_unit(1, pf)`, `leakage_power_unit : 1uW`, `default_fanout_load : 1.0`,
umbrales de slew 30 % y 70 % (`slew_lower_threshold_pct_rise : 30`,
`slew_upper_threshold_pct_rise : 70`), `slew_derate_from_library : 0.5`.

Toda esta sección son archivos del PDK: ni el RTL ni la configuración pueden cambiarla. Los valores
se volvieron a leer de los archivos y coinciden con los de la versión de v1 de este documento,
salvo una corrección que se señala más abajo.

### 11.1 Área, ancho y alto

El atributo `area` sale del liberty. **El ancho y el alto no están en el liberty**: los liberty de
`gf180mcu_fd_sc_mcu7t5v0` no tienen atributos de ancho ni de alto de celda, así que se toman de la
sentencia `SIZE` del cell LEF que leyó la misma corrida,
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lef/gf180mcu_fd_sc_mcu7t5v0.lef`
(ruta en `13-openroad-floorplan/openroad-floorplan.log`, línea 14, que informa 229 celdas de
biblioteca; `resolved.json`, clave `CELL_LEFS`).

Las áreas son idénticas en la esquina típica y en la lenta (el liberty no cambia la geometría):

| Celda | `area` (µm²) típica | `area` (µm²) lenta | Ancho (µm), cell LEF | Alto (µm), cell LEF | Instancias en la corrida final |
|---|---|---|---|---|---|
| `gf180mcu_fd_sc_mcu7t5v0__dffq_1` | 63.660800 | 63.660800 | 16.240 | 3.920 | 778 (v1: 804) |
| `gf180mcu_fd_sc_mcu7t5v0__dffrnq_1` | 74.636800 | 74.636800 | 19.040 | 3.920 | 185 (v1: 186) |
| `gf180mcu_fd_sc_mcu7t5v0__mux2_2` | 32.928000 | 32.928000 | 8.400 | 3.920 | 889 (v1: 759) |
| `gf180mcu_fd_sc_mcu7t5v0__nand2_1` | 10.976000 | 10.976000 | 2.800 | 3.920 | 934 (v1: 758) |
| `gf180mcu_fd_sc_mcu7t5v0__buf_2` | 17.561600 | 17.561600 | 4.480 | 3.920 | 877 (v1: 613) |
| `gf180mcu_fd_sc_mcu7t5v0__clkbuf_16` | 109.760000 | 109.760000 | 28.000 | 3.920 | 1 (v1: 9) |
| `gf180mcu_fd_sc_mcu7t5v0__icgtp_1` | 61.465600 | 61.465600 | 15.680 | 3.920 | 0 (v1: 0) |

La columna de instancias sale de `asic/rom/runs/final/55-odb-cellfrequencytables/cell.rpt` y, para
v1, de `asic/rom/runs/v1_final_run/53-odb-cellfrequencytables/cell.rpt`. Se agrega para que quien
lea sepa qué celdas usa el diseño: `icgtp_1` está en la tabla como ejemplo de celda de reloj con
habilitación y **no aparece en el netlist de ninguna de las dos corridas**, y `clkbuf_16` pasa de
9 instancias a 1 por el árbol de reloj nuevo (sección 6).

El alto de 3.920 µm es común a todas: coincide con el alto de fila del sitio
`GF018hv5v_mcu_sc7` (sección 2).

### 11.2 Setup, hold y retardo reloj a Q de `dffq_1`

Las restricciones de setup y de hold de `dffq_1` están en el grupo `pin(D)` como tablas 10x10
`cnst_ctin_rtin_10x10`, con `index_1` = transición del pin restringido (D) e `index_2` =
transición del pin relacionado (CLK). El retardo reloj a Q está en `pin(Q)`,
`timing_type : rising_edge`, `related_pin : "CLK"`, como tablas 10x10 `tmg_ntin_oload_10x10`
con `index_1` = transición de entrada e `index_2` = capacitancia total de salida.

Punto elegido en la esquina típica: `index_1` = `index_2` = 0.1439 ns para setup y hold (tercer
punto de la grilla, el más cercano a `CLOCK_TRANSITION_CONSTRAINT = 0.15` ns de la SDC), y
transición 0.1439 ns con carga 0.06075 pF para el retardo reloj a Q (sexto punto de carga, el más
cercano a `OUTPUT_CAP_LOAD = 72.91` fF = 0.07291 pF). Como la SDC no cambió (sección 1), el punto
elegido tampoco.

La grilla de la esquina lenta es distinta, así que el punto análogo es otro: transición 0.2373 ns
(tercer punto) y carga 0.06262 pF (sexto punto). Se indica el índice exacto en cada caso.

| Magnitud | Típica `tt_025C_5v00` | Lenta `ss_125C_4v50` |
|---|---|---|
| Punto de la grilla (setup y hold) | transición D = transición CLK = 0.1439 ns | transición D = transición CLK = 0.2373 ns |
| `setup_rising`, `rise_constraint` | 0.213 ns | 0.444 ns |
| `setup_rising`, `fall_constraint` | 0.229 ns | 0.465 ns |
| `hold_rising`, `rise_constraint` | 0.047 ns | 0.077 ns |
| `hold_rising`, `fall_constraint` | 0.083 ns | 0.139 ns |
| Punto de la grilla (CLK a Q) | transición 0.1439 ns, carga 0.06075 pF | transición 0.2373 ns, carga 0.06262 pF |
| CLK a Q, `cell_rise` | 1.255 ns | 2.294 ns |
| CLK a Q, `cell_fall` | 1.007 ns | 1.824 ns |
| CLK a Q, `rise_transition` | 1.054 ns | 1.844 ns |
| CLK a Q, `fall_transition` | 0.6311 ns | 1.086 ns |
| `capacitance` del pin D | 0.002389 pF | 0.002378 pF |
| `capacitance` del pin CLK | 0.003247 pF | 0.003265 pF |
| `max_capacitance` del pin Q | 0.2394 pF | 0.2469 pF |

Grilla completa de `index_1` de las tablas de `dffq_1` en la esquina típica:
`0.02, 0.04747, 0.1439, 0.328, 0.6149, 1.017, 1.547, 2.214, 3.029, 4` ns; grilla de `index_2` de
las tablas de CLK a Q en la esquina típica:
`0.001, 0.002646, 0.008422, 0.01945, 0.03664, 0.06075, 0.09248, 0.1324, 0.1812, 0.2394` pF.
En la esquina lenta, `index_1` es
`0.02, 0.06818, 0.2373, 0.5602, 1.063, 1.769, 2.698, 3.869, 5.297, 7` ns e `index_2` de CLK a Q es
`0.001, 0.002697, 0.008654, 0.02003, 0.03775, 0.06262, 0.09535, 0.1366, 0.1869, 0.2469` pF.

Otros datos de `dffq_1` en la esquina típica (mismo liberty), sobre `pin(CLK)`:
`min_pulse_width_high : 0.495`, `min_pulse_width_low : 0.553`, y dos restricciones
`timing_type : minimum_period` con `rise_constraint` 1.107 y 1.058. En la esquina lenta son
`min_pulse_width_high : 0.96`, `min_pulse_width_low : 1.071` y `minimum_period` 2.139 y 1.985.

**Corrección respecto de la versión anterior de este documento.** La versión de v1 daba
`min_pulse_width_high : 0.406` y `min_pulse_width_low : 0.446` para `dffq_1` en la esquina típica.
Esos dos valores **no pertenecen a `dffq_1`**: en
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib`
aparecen dentro del bloque `cell(gf180mcu_fd_sc_mcu7t5v0__dffnq_1)`, el flip-flop de flanco de
bajada, y las cadenas `0.406` y `0.446` no están en el bloque de `dffq_1`. Los valores correctos de
`dffq_1` son 0.495 y 0.553. El error venía del documento de v1, no del cambio de corrida.

### 11.3 `max_transition` por defecto de la biblioteca

Los dos liberty **no declaran un atributo `default_max_transition` a nivel de biblioteca**:
`grep -c default_max_transition` da 0 en los dos archivos. El límite se declara pin por pin,
con un valor único por esquina:

| Liberty | Valor de `max_transition` | Ocurrencias |
|---|---|---|
| `gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib` | 4 ns | 836 |
| `gf180mcu_fd_sc_mcu7t5v0__ss_125C_4v50.lib` | 7 ns | 836 |

Conteo verificado con `grep -o "max_transition : [0-9.]*" ... | sort | uniq -c`: en cada archivo hay
un solo valor distinto y 836 ocurrencias.

En la corrida, `DEFAULT_MAX_TRAN` no está definida (`resolved.json`, clave en `null`), y la SDC
impone un límite más estricto: `set_max_transition 3.0000 [current_design]` (sección 1).

## 12. Pasos que corrió la corrida final

**Son 78 pasos con carpeta, no 76.** Los dos que se agregan son
`41-openroad-repairdesignpostgrt` y `44-openroad-resizertimingpostgrt`, que en v1 se omitían por su
variable de habilitación antes de crear directorio. Como las dos carpetas nuevas no son
consecutivas, el corrimiento respecto de v1 no es parejo: las carpetas 1 a 40 conservan su número,
las que en v1 eran la 41 y la 42 se corren un número (pasan a 42 y 43) y desde la que en v1 era la
43 hasta la 76 se corren dos (pasan a 45 y siguientes). Comprobado contando y comparando las
carpetas de `asic/rom/runs/v1_final_run` y de `asic/rom/runs/final`.

Orden y nombres de carpeta de `asic/rom/runs/final`; nombre del paso y motivo de omisión de
`asic/rom/runs/final/flow.log`; tiempo de `<carpeta>/runtime.txt` de cada paso (el mismo tiempo
aparece en `<carpeta>/state_out.json` de cada paso).
Los pasos omitidos se marcan con "omitido" y conservan su carpeta, que queda solo con
`config.json`, `runtime.txt`, `state_in.json` y `state_out.json`.

| # | Carpeta | Paso | Tiempo | Estado |
|---|---|---|---|---|
| 01 | `01-verilator-lint` | `Verilator.Lint` | 00:00:00.502 | corrió |
| 02 | `02-checker-linttimingconstructs` | `Checker.LintTimingConstructs` | 00:00:00.000 | corrió (limpio, `flow.log` línea 5) |
| 03 | `03-checker-linterrors` | `Checker.LintErrors` | 00:00:00.000 | corrió (limpio, línea 7) |
| 04 | `04-checker-lintwarnings` | `Checker.LintWarnings` | 00:00:00.000 | corrió: "12 Lint warnings found" (`flow.log`, línea 9) |
| 05 | `05-yosys-jsonheader` | `Yosys.JsonHeader` | 00:00:00.707 | corrió |
| 06 | `06-yosys-synthesis` | `Yosys.Synthesis` | 00:00:07.188 | corrió |
| 07 | `07-checker-yosysunmappedcells` | `Checker.YosysUnmappedCells` | 00:00:00.001 | corrió (limpio, línea 17) |
| 08 | `08-checker-yosyssynthchecks` | `Checker.YosysSynthChecks` | 00:00:00.000 | corrió (limpio, línea 19) |
| 09 | `09-checker-netlistassignstatements` | `Checker.NetlistAssignStatements` | 00:00:00.008 | corrió |
| 10 | `10-openroad-checksdcfiles` | `OpenROAD.CheckSDCFiles` | 00:00:00.001 | corrió (reportó que usa la SDC genérica, líneas 22 y 23) |
| 11 | `11-openroad-checkmacroinstances` | `OpenROAD.CheckMacroInstances` | 00:00:00.001 | omitido: "No macros found, skipping instance check" |
| 12 | `12-openroad-staprepnr` | `OpenROAD.STAPrePNR` | 00:00:02.784 | corrió (solo 3 esquinas: omitió `min_*` y `max_*` por idénticas a `nom_*` en esta etapa, líneas 30 a 38) |
| 13 | `13-openroad-floorplan` | `OpenROAD.Floorplan` | 00:00:01.113 | corrió |
| 14 | `14-openroad-dumprcvalues` | `OpenROAD.DumpRCValues` | 00:00:00.710 | corrió (sus tres reportes están en la sección 7.2) |
| 15 | `15-odb-checkmacroantennaproperties` | `Odb.CheckMacroAntennaProperties` | 00:00:00.001 | omitido: "No cells provided" |
| 16 | `16-odb-setpowerconnections` | `Odb.SetPowerConnections` | 00:00:00.605 | corrió |
| 17 | `17-odb-manualmacroplacement` | `Odb.ManualMacroPlacement` | 00:00:00.001 | omitido: "No instances found" |
| 18 | `18-openroad-cutrows` | `OpenROAD.CutRows` | 00:00:00.706 | corrió |
| 19 | `19-openroad-tapendcapinsertion` | `OpenROAD.TapEndcapInsertion` | 00:00:00.807 | corrió |
| 20 | `20-odb-addpdnobstructions` | `Odb.AddPDNObstructions` | 00:00:00.001 | omitido: "'PDN_OBSTRUCTIONS' is not defined" |
| 21 | `21-openroad-generatepdn` | `OpenROAD.GeneratePDN` | 00:00:01.109 | corrió |
| 22 | `22-odb-removepdnobstructions` | `Odb.RemovePDNObstructions` | 00:00:00.001 | omitido: "'PDN_OBSTRUCTIONS' is not defined" |
| 23 | `23-odb-addroutingobstructions` | `Odb.AddRoutingObstructions` | 00:00:00.001 | omitido: "'ROUTING_OBSTRUCTIONS' is not defined" |
| 24 | `24-openroad-globalplacementskipio` | `OpenROAD.GlobalPlacementSkipIO` | 00:00:00.001 | omitido: "I/O pins to be placed from .../asic/rom/pines.cfg. Returning state unaltered" |
| 25 | `25-openroad-ioplacement` | `OpenROAD.IOPlacement` | 00:00:00.001 | omitido: "IO_PIN_ORDER_CFG is set" |
| 26 | `26-odb-customioplacement` | `Odb.CustomIOPlacement` | 00:00:00.605 | corrió |
| 27 | `27-odb-applydeftemplate` | `Odb.ApplyDEFTemplate` | 00:00:00.001 | omitido: "No DEF template provided" |
| 28 | `28-openroad-globalplacement` | `OpenROAD.GlobalPlacement` | 00:00:02.213 | corrió |
| 29 | `29-odb-writeverilogheader` | `Odb.WriteVerilogHeader` | 00:00:00.504 | corrió |
| 30 | `30-checker-powergridviolations` | `Checker.PowerGridViolations` | 00:00:00.001 | corrió (limpio, línea 79) |
| 31 | `31-openroad-stamidpnr` | `OpenROAD.STAMidPNR` | 00:00:03.824 | corrió |
| 32 | `32-openroad-repairdesignpostgpl` | `OpenROAD.RepairDesignPostGPL` | 00:00:13.759 | corrió: 347 violaciones de slew, 146 de fanout y 15 de capacidad; 11 instancias redimensionadas, 913 buffers en 352 redes, 2 celdas `tieh`; área +12.6 % |
| 33 | `33-odb-manualglobalplacement` | `Odb.ManualGlobalPlacement` | 00:00:00.001 | omitido: "'MANUAL_GLOBAL_PLACEMENTS' not set" |
| 34 | `34-openroad-detailedplacement` | `OpenROAD.DetailedPlacement` | 00:00:01.008 | corrió |
| 35 | `35-openroad-cts` | `OpenROAD.CTS` | 00:00:14.661 | corrió: 122 buffers de reloj, árbol de 4 niveles (sección 6) |
| 36 | `36-openroad-stamidpnr-1` | `OpenROAD.STAMidPNR-1` | 00:00:03.933 | corrió |
| 37 | `37-openroad-resizertimingpostcts` | `OpenROAD.ResizerTimingPostCTS` | 00:00:10.245 | corrió: sin violaciones de setup; 5 puntos con violación de hold y 5 buffers de hold insertados |
| 38 | `38-openroad-stamidpnr-2` | `OpenROAD.STAMidPNR-2` | 00:00:03.625 | corrió |
| 39 | `39-openroad-globalrouting` | `OpenROAD.GlobalRouting` | 00:00:01.509 | corrió: 528528 µm de largo total |
| 40 | `40-openroad-checkantennas` | `OpenROAD.CheckAntennas` | 00:00:03.818 | corrió: 0 violaciones de red y 0 de pin |
| **41** | `41-openroad-repairdesignpostgrt` | `OpenROAD.RepairDesignPostGRT` | 00:00:15.769 | **paso nuevo** (`RUN_POST_GRT_DESIGN_REPAIR = True`): 415 violaciones de slew y 209 de capacidad, 120 instancias redimensionadas, 394 buffers en 500 redes, área +5.8 % (sección 7.3) |
| 42 | `42-odb-diodesonports` | `Odb.DiodesOnPorts` | 00:00:00.001 | omitido: "'DIODE_ON_PORTS' is set to 'none'" |
| - | sin carpeta | `Odb.HeuristicDiodeInsertion` ("Heuristic Diode Insertion") | - | omitido: variable de habilitación en `False` (`RUN_HEURISTIC_DIODE_INSERTION = False`); `flow.log`, líneas 129 y 130 |
| 43 | `43-openroad-repairantennas` | `OpenROAD.RepairAntennas` | 00:00:10.956 | corrió, con dos subpasos; insertó 1 diodo de antena |
| 43.1 | `43-openroad-repairantennas/1-openroad-diodeinsertion` | `OpenROAD.DiodeInsertion` | 00:00:07.229 | corrió: 1 violación de antena encontrada, 0 después de reparar |
| 43.2 | `43-openroad-repairantennas/2-openroad-checkantennas` | `OpenROAD.CheckAntennas` | 00:00:03.719 | corrió: 0 violaciones de red y 0 de pin |
| **44** | `44-openroad-resizertimingpostgrt` | `OpenROAD.ResizerTimingPostGRT` | 00:00:11.550 | **paso nuevo** (`RUN_POST_GRT_RESIZER_TIMING = True`): "No setup violations found" y "No hold violations found", sin cambios en el netlist (sección 7.3) |
| 45 | `45-openroad-stamidpnr-3` | `OpenROAD.STAMidPNR-3` | 00:00:03.621 | corrió |
| 46 | `46-openroad-detailedrouting` | `OpenROAD.DetailedRouting` | 00:00:37.079 | corrió (TritonRoute con 24 hilos, dos subcorridas `drt-run-0` y `drt-run-1`) |
| 47 | `47-odb-removeroutingobstructions` | `Odb.RemoveRoutingObstructions` | 00:00:00.001 | omitido: "'ROUTING_OBSTRUCTIONS' is not defined" |
| 48 | `48-openroad-checkantennas-1` | `OpenROAD.CheckAntennas-1` | 00:00:02.615 | corrió: 0 violaciones de red y 0 de pin |
| 49 | `49-checker-trdrc` | `Checker.TrDRC` | 00:00:00.000 | corrió (limpio, línea 162) |
| 50 | `50-odb-reportdisconnectedpins` | `Odb.ReportDisconnectedPins` | 00:00:00.906 | corrió |
| 51 | `51-checker-disconnectedpins` | `Checker.DisconnectedPins` | 00:00:00.001 | corrió (limpio, línea 166) |
| 52 | `52-odb-reportwirelength` | `Odb.ReportWireLength` | 00:00:00.605 | corrió |
| 53 | `53-checker-wirelength` | `Checker.WireLength` | 00:00:00.001 | omitido: "Threshold for Threshold-surpassing long wires is not set" (`WIRE_LENGTH_THRESHOLD` sin definir) |
| 54 | `54-openroad-fillinsertion` | `OpenROAD.FillInsertion` | 00:00:01.111 | corrió: 12390 rellenos |
| 55 | `55-odb-cellfrequencytables` | `Odb.CellFrequencyTables` | 00:00:01.413 | corrió |
| 56 | `56-openroad-rcx` | `OpenROAD.RCX` | 00:00:01.423 | corrió (tres grupos, lanzados `nom_*`, `min_*`, `max_*`) |
| 57 | `57-openroad-stapostpnr` | `OpenROAD.STAPostPNR` | 00:00:09.353 | corrió (las nueve esquinas, líneas 186 a 198) |
| 58 | `58-openroad-irdropreport` | `OpenROAD.IRDropReport` | 00:00:08.479 | corrió (solo `nom_tt_025C_5v00`) |
| 59 | `59-magic-streamout` | `Magic.StreamOut` | 00:00:02.526 | corrió |
| 60 | `60-klayout-streamout` | `KLayout.StreamOut` | 00:00:01.609 | corrió |
| 61 | `61-klayout-render` | `KLayout.Render` | 00:00:01.308 | corrió |
| 62 | `62-magic-writelef` | `Magic.WriteLEF` | 00:00:02.616 | corrió |
| 63 | `63-odb-checkdesignantennaproperties` | `Odb.CheckDesignAntennaProperties` | 00:00:00.705 | corrió |
| 64 | `64-klayout-xor` | `KLayout.XOR` | 00:00:03.918 | corrió (24 hilos) |
| 65 | `65-checker-xor` | `Checker.XOR` | 00:00:00.001 | corrió (limpio, línea 268) |
| 66 | `66-magic-drc` | `Magic.DRC` | 00:00:18.875 | corrió |
| 67 | `67-klayout-drc` | `KLayout.DRC` | 00:00:00.001 | omitido: "KLAYOUT_DRC_RUNSET is unset. KLayout.DRC may not be supported for the gf180mcuD PDK" |
| 68 | `68-checker-magicdrc` | `Checker.MagicDRC` | 00:00:00.001 | corrió (limpio, línea 274; `magic__drc_error__count` = 0) |
| 69 | `69-checker-klayoutdrc` | `Checker.KLayoutDRC` | 00:00:00.001 | corrió sin dato: "The KLayout DRC errors metric was not found" (el paso 67 fue omitido) |
| 70 | `70-magic-spiceextraction` | `Magic.SpiceExtraction` | 00:00:05.635 | corrió |
| 71 | `71-checker-illegaloverlap` | `Checker.IllegalOverlap` | 00:00:00.001 | corrió (limpio, línea 280) |
| 72 | `72-netgen-lvs` | `Netgen.LVS` | 00:00:01.533 | corrió |
| 73 | `73-checker-lvs` | `Checker.LVS` | 00:00:00.001 | corrió (limpio, línea 284; `design__lvs_error__count` = 0) |
| - | sin carpeta | `Yosys.EQY` ("Equivalence Check") | - | omitido: variable de habilitación en `False` (`RUN_EQY = False`); `flow.log`, líneas 285 y 286 |
| 74 | `74-checker-setupviolations` | `Checker.SetupViolations` | 00:00:00.001 | corrió: "No setup violations found" (línea 288) |
| 75 | `75-checker-holdviolations` | `Checker.HoldViolations` | 00:00:00.001 | corrió: "No hold violations found" (línea 290) |
| 76 | `76-checker-maxslewviolations` | `Checker.MaxSlewViolations` | 00:00:00.001 | corrió: "No max slew violations found" **sin lista de esquinas** (línea 292), porque hay 0 violaciones en las nueve |
| 77 | `77-checker-maxcapviolations` | `Checker.MaxCapViolations` | 00:00:00.002 | corrió: lista las nueve esquinas (encabezado en la línea 294, esquinas en las líneas 295 a 303) y concluye "No max cap violations found" en la línea 304 al filtrar por `MAX_CAP_VIOLATION_CORNERS = ['']`; 1 violación por esquina |
| 78 | `78-misc-reportmanufacturability` | `Misc.ReportManufacturability` | 00:00:00.001 | corrió: "klayout__drc_error__count not reported. KLayout.DRC may have been skipped" (línea 306) |

**Hechos de v1 que pasan a ser falsos en esta sección.** La versión de v1 de este documento decía:

1. Que el flujo tenía 76 pasos con carpeta. Ahora tiene 78, y por eso toda cita de carpeta desde la
   41 de v1 en adelante cambia de número (un número para las que en v1 eran la 41 y la 42, dos
   números desde la que en v1 era la 43).
2. Que `OpenROAD.RepairDesignPostGRT` quedaba sin carpeta y omitido por
   `RUN_POST_GRT_DESIGN_REPAIR = False`. Ahora es el paso 41 y corre.
3. Que `OpenROAD.ResizerTimingPostGRT` quedaba sin carpeta y omitido por
   `RUN_POST_GRT_RESIZER_TIMING = False`. Ahora es el paso 44 y corre.
4. Que los pasos sin carpeta eran cuatro. Ahora son **dos**: `Odb.HeuristicDiodeInsertion` y
   `Yosys.EQY`, omitidos por su variable de habilitación antes de crear directorio, por eso no
   tienen `runtime.txt` y aparecen con tiempo "-" (`flow.log`, líneas 129 a 130 y 285 a 286).
5. Que el checker de max slew listaba las esquinas `max_ss_125C_4v50`, `max_tt_025C_5v00`,
   `min_ss_125C_4v50` y `nom_ss_125C_4v50` y solo concluía que no había violaciones al filtrar por
   `MAX_SLEW_VIOLATION_CORNERS = ['']`. Ahora no lista ninguna esquina: hay 0 violaciones en las
   nueve y el mensaje de la línea 292 es directamente "No max slew violations found". La variable
   `MAX_SLEW_VIOLATION_CORNERS` sigue valiendo `['']`, pero ya no hace falta que filtre nada.
6. Que la reparación de antenas no insertaba diodos. Ahora inserta uno (celda `__antenna`).

Al terminar, el flujo copió las vistas a `asic/rom/runs/final/final`
(`flow.log`, línea 307: "Saving views to '.../asic/rom/runs/final/final'"). La última línea del
archivo es la 308, "Flow complete.", que es la que certifica que la corrida cerró el flujo completo.
Esas vistas y los reportes de cierre están versionados en `asic/rom/resultados/final/`.

## 13. Hechos que no cambian

Esta sección existe para que quien lea el informe sepa qué no hace falta remedir. Todo lo que sigue
es independiente del RTL y de las seis claves de configuración que cambiaron, y se verificó en la
corrida final nueva con la comprobación que se indica.

| Hecho | Dónde está en este documento | Verificación hecha sobre la corrida final nueva |
|---|---|---|
| La SDC generada por el floorplan, entera: reloj, retardos de entrada y salida, derates, límites de fanout, transición y capacidad, celdas de arranque | sección 1 | `diff asic/rom/runs/v1_final_run/13-openroad-floorplan/asic_top.sdc asic/rom/runs/final/13-openroad-floorplan/asic_top.sdc` da salida vacía: los dos archivos son idénticos byte a byte. Los conteos de 8 `set_input_delay` y 19 `set_output_delay` se recontaron con `grep -c` |
| Las 36 variables `PDN_*` de la red de alimentación, y que no existen claves `FP_PDN_*` | sección 4.1 | comparación clave por clave de `resolved.json` de las dos corridas: las 36 claves `PDN_*` tienen el mismo valor; el listado de claves `FP_*` no contiene ninguna `FP_PDN_*` |
| El tech LEF del PDK: versión, DBU, grilla de fabricación, 15 capas y 56 vías, la tabla de las cinco capas de ruteo, las capas no de ruteo | sección 7.1 | releído de `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef` bloque por bloque; `ODB-0227` de `13-openroad-floorplan/openroad-floorplan.log` sigue informando 15 capas y 56 vías |
| Los valores por capa que ODB guarda, antes y después de fijar el RC | sección 7.2 | `14-openroad-dumprcvalues/tlef_values.rpt` y `layer_values_after.rpt` son **idénticos byte a byte** a los de v1. Es la evidencia, del propio flujo, de que `LAYERS_RC` no toca el tech LEF |
| Los pitches por capa que informa el ruteador global (GRT-0088) | sección 7.1 | releídos de `39-openroad-globalrouting/openroad-globalrouting.log`, líneas 19 a 23: idénticos capa por capa a los de v1 |
| Las variables y los comandos de ruteo (`RT_*`, `GRT_ADJUSTMENT`, `GRT_LAYER_ADJUSTMENTS`, `global_route`, `detailed_route`) | sección 7 | releídas de `resolved.json` y de los dos logs; idénticas a las de v1 |
| Las variables de CTS y los dos buffers que elige TritonCTS | sección 6.1 | releídas de `resolved.json` y de `35-openroad-cts/openroad-cts.log`, líneas 39, 41 y 46 |
| Las dimensiones de las celdas de relleno y de las celdas de ejemplo (sentencia `SIZE` del cell LEF) | secciones 8 y 11.1 | releídas de `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lef/gf180mcu_fd_sc_mcu7t5v0.lef` |
| La estructura de la extracción de parásitos: tres rulesets del PDK, nombres de los SPEF, mapeo de SPEF a esquina, las nueve esquinas de `STA_CORNERS`, `DEDUPLICATE_CORNERS = False` | sección 9 | releídos de `resolved.json`, de los tres `rcx.log` y de los nueve `sta.log` de `57-openroad-stapostpnr` |
| Las áreas del liberty y las tablas de setup, hold y reloj a Q de `dffq_1`, con sus grillas completas de `index_1` e `index_2` | secciones 11.1 y 11.2 | reextraídas de los dos liberty del PDK con el índice exacto de cada tabla; coinciden con los valores publicados |
| Que ningún liberty declara `default_max_transition` y que el límite se declara pin por pin con 836 ocurrencias de 4 ns (típica) y 836 de 7 ns (lenta) | sección 11.3 | `grep -c default_max_transition` da 0 en los dos archivos; `grep -o "max_transition : ..." \| sort \| uniq -c` da un solo valor y 836 ocurrencias en cada uno |
| Que la corrida no informa la actividad de conmutación que asumió | sección 10.3 | búsqueda de `set_power_activity`, `read_saif`, `read_vcd`, `.saif` y `.vcd` sobre todos los `*.log`, `COMMANDS`, `_env.tcl` y `*.tcl` de los 78 pasos: sin coincidencias |
| Que el reloj es virtual y no propagado, con latencia de fuente 0.000000 en las nueve esquinas | sección 6.3 | `Propagated: no` y `Virtual: yes` verificados en los nueve `57-openroad-stapostpnr/<esquina>/clock.rpt` |
| Que el IR drop solo se analizó en la esquina por defecto y que la tensión sale del liberty | sección 4.3 | `58-openroad-irdropreport/irdrop.rpt` solo trae `Corner : nom_tt_025C_5v00`; el log del paso repite "Using voltage extracted from lib (5V)" |
| Que el diseño no tiene macros | secciones 3 y 4.1 | `MACROS = None` en `resolved.json`; los pasos 11, 15 y 17 siguen omitidos por "No macros found", "No cells provided" y "No instances found"; GRT-0003 informa `Macros: 0` |
| Que el área de las celdas de fill y de decap por separado no está disponible | sección 8 | el reporte de tipos de celda y la métrica `design__instance__area__class:fill_cell` siguen agrupando los dos grupos en la clase "Fill cell"; `cell.rpt` sigue dando solo cantidades |
| La versión de LibreLane, el PDK, la biblioteca, el nombre del diseño, el hash de `PDK_ROOT` y `CLOCK_PERIOD = 100` ns | encabezado | releídos de `asic/rom/runs/final/resolved.json`: `meta.librelane_version` = 3.0.16, `PDK` = gf180mcuD, `STD_CELL_LIBRARY` = gf180mcu_fd_sc_mcu7t5v0, `DESIGN_NAME` = asic_top, `PDK_ROOT` con el mismo hash, `CLOCK_PERIOD` = 100 |

Las dos correcciones que esta revisión encontró en el documento de v1, y que no vienen del cambio
de corrida, son el espesor de `Metal2`, `Metal3` y `Metal4` en el tech LEF (sección 7.1) y los
`min_pulse_width` de `dffq_1` (sección 11.2).

## Verificacion de este documento

Esta sección registra la revisión adversarial que se le hizo al documento después de reescribirlo:
el objetivo era encontrar cifras equivocadas, no confirmarlas.

**Alcance.** Se reabrió cada archivo que el documento cita y se comprobó en él cada valor: unos 160
archivos en total, entre los de `asic/rom/runs/final` (incluidos los 78 `runtime.txt`, los nueve
`clock.rpt`, los nueve `power.rpt`, los nueve `checks.rpt` y los nueve `sta.log` de
`57-openroad-stapostpnr`, los tres reportes de `14-openroad-dumprcvalues`, los tres `rcx.log`, el
DEF de `21-openroad-generatepdn` y los logs de los pasos 13, 18, 19, 21, 28, 32, 34, 35, 37, 39,
40, 41, 43, 44, 46, 48, 54 y 58), los seis archivos del PDK (los tres tech LEF, el cell LEF y los
dos liberty), los de `asic/rom/runs/v1_final_run` y `asic/rom/resultados/v1_final/metrics.json` que
el documento usa para comparar, y `asic/rom/runs/f1_t25/resolved.json`. Contando una por una las
cifras de las tablas, son del orden de 900 valores revisados: 57 métricas de `metrics.json` en la
corrida nueva y en v1, las 27 celdas de la tabla de violaciones por esquina más sus 27 de v1, las 54
celdas de la tabla de skew y latencia, las 36 filas de potencia, las 36 variables `PDN_*`, las cerca
de 110 claves de `resolved.json` citadas, las 78 filas de la tabla de pasos con su tiempo y su
mensaje, las cinco filas por nueve columnas del tech LEF, las 30 cifras de `LAYERS_RC` y las 15
magnitudes del liberty de `dffq_1` en las dos esquinas.

**Cuántos estaban mal: siete.** Cinco eran hechos o citas falsas y dos eran imprecisiones de cita.
Ninguna de las siete afecta a un valor medido de la corrida: todas las cifras de resultado (áreas,
conteos de celdas, largos de cable, potencias, skew, latencias, violaciones, tiempos de paso,
métricas de `metrics.json`, valores del PDK) resultaron correctas tal como estaban escritas, igual
que los nombres de instancia de las rutas de reloj (`u_soc.u_core.u_rf/_4126_/CLK`, `_4407_/CLK`,
`u_soc.u_periph.u_cycles/_171_/CLK`, `_4282_/CLK`) y los números de paso de todas las citas de
carpeta del cuerpo. Lo que estaba mal:

1. **El corrimiento de los números de paso no es de dos lugares para todas las carpetas.** El
   encabezado y la sección 12 decían "toda carpeta desde el 41 se corre dos números". Es falso,
   porque las dos carpetas nuevas no son consecutivas: comparando las carpetas de
   `asic/rom/runs/v1_final_run` con las de `asic/rom/runs/final`, las que en v1 eran la 41
   (`41-odb-diodesonports`) y la 42 (`42-openroad-repairantennas`) se corren **un** número (pasan a
   42 y 43) y solo desde la que en v1 era la 43 (`43-openroad-stamidpnr-3`, ahora la 45) el
   corrimiento es de dos. Corregido en el encabezado y en la sección 12, y se agregaron a la tabla
   del encabezado las dos filas que se corren un solo número.
2. **Las líneas del informe de caída de tensión estaban mal citadas.** La sección 4.3 decía que
   `Corner : nom_tt_025C_5v00` aparece en las líneas 18 y 31 de
   `58-openroad-irdropreport/irdrop.rpt`. Está en las líneas 5 y 18; el archivo tiene 26 líneas.
   Corregido.
3. **El `COMMANDS` del STA de firma no tiene nueve líneas, tiene 18.** La sección 10.3 decía que
   "solo invocan `sta ... corner.tcl` ... nueve veces". El archivo
   `57-openroad-stapostpnr/COMMANDS` tiene 18 líneas: nueve de `sta -no_splash -exit ... corner.tcl`
   y nueve de `openroad ... -python .../odbpy/filter_unannotated.py --corner <esquina>`. El hecho de
   fondo se sostiene (ninguna de las 18 pasa un argumento de actividad), pero la cuenta y el "solo"
   eran falsos. Corregido.
4. **Los 81 drivers sin anotar no son "en su mayoría puertos del top".** Contando la lista de
   `57-openroad-stapostpnr/nom_tt_025C_5v00/checks.rpt`, 78 de los 81 son las cargas ficticias del
   árbol de reloj (`clkload0` a `clkload77`, exactamente las 78 que informa CTS-0207) y solo 3 son
   puertos de entrada del top (`spi_cs_n`, `spi_mosi`, `spi_sclk`). Corregido con el desglose.
5. **La línea 307 de `flow.log` no es la última del archivo.** La sección 12 decía que "Saving views
   to ..." es la última línea. `flow.log` tiene 308 líneas y la última es "Flow complete.".
   Corregido.
6. **Imprecisión de cita en el checker de capacidad.** "lista las nueve esquinas (`flow.log`, líneas
   294 a 303)": la 294 es el encabezado "Max Cap violations found in the following corners:", las
   nueve esquinas están en las líneas 295 a 303 y la conclusión "No max cap violations found" en la
   304. Precisado en la sección 7.3 y en la fila 77 de la tabla de pasos.
7. **Imprecisión de cita en el comando del paso 44.** El documento transcribía
   `repair_timing ... -setup_margin 0.025`, pero el log de la línea 83 escribe el margen con todos
   sus decimales (`0.025000000000000001387778780781445675529539585113525390625`, el `0.025` de
   `GRT_RESIZER_SETUP_SLACK_MARGIN` en coma flotante). Señalado en la sección 7.3.

**Comprobaciones que se rehicieron y confirmaron lo escrito.** Las seis claves de diferencia de
`resolved.json` entre v1 y la corrida nueva (comparación clave por clave: ninguna clave sobra ni
falta en ninguna de las dos y exactamente seis difieren); las siete claves de diferencia contra
`f1_t25`; que la SDC del floorplan es idéntica byte a byte a la de v1 y que tiene 8
`set_input_delay`, 19 `set_output_delay` y 19 `set_load`; que `tlef_values.rpt` y
`layer_values_after.rpt` son idénticos byte a byte a los de v1 y que `resizer_values_after.rpt`
difiere; las dos cuentas de promedio de la sección 7.2 ((0.64095 x 3 + 0.27192) / 4 = 0.5486925 y
1.66316e-04, y los factores 1.99 y 2.59 contra el promedio del tech LEF); los conteos del DEF de la
PDN contados de nuevo sobre las sentencias `+ ROUTED` y `NEW` (160 rieles de 1200 DBU, 8 y 8 straps
de 3200 DBU, 640/640/640/32 vías, y 158 y 632 en v1), con `UNITS DISTANCE MICRONS 2000` y sin la
cadena `RING`; que el tech LEF declara `THICKNESS 0.54` en `Metal2`, `Metal3` y `Metal4` (la
corrección de la sección 7.1 es correcta); que `0.406` y `0.446` están en el bloque de
`dffnq_1` y no aparecen en el de `dffq_1`, cuyos `min_pulse_width` son 0.495 y 0.553 (la corrección
de la sección 11.2 es correcta); los 836 `max_transition : 4` y 836 `max_transition : 7` y los cero
`default_max_transition`; que v1 tiene 76 carpetas de paso y cuatro mensajes "Gating variable" y la
corrida nueva 78 carpetas y dos; que la búsqueda de `set_layer_rc` y `set_wire_rc` sobre todo
`asic/rom/runs/final` no devuelve coincidencias y que la de `set_power_activity`, `read_saif`,
`read_vcd`, `.saif` y `.vcd` sobre los `*.log`, `COMMANDS`, `_env.tcl` y `*.tcl` tampoco; que
`asic/rom/runs/final/final/metrics.json` y `asic/rom/resultados/final/metrics.json` son idénticos; y
que los 67 maestros de celda, los diez que aparecen y los tres que desaparecen, los subtotales de
fill (5942) y decap (6448) y el total de 22318 instancias salen del `cell.rpt` del paso 55.

**Lo que sigue sin medirse**, revisado y confirmado como no disponible en la corrida: la comparación
de potencia a otro período (sección 10.2), la actividad de conmutación supuesta (sección 10.3), el
área de fill contra decap por separado (sección 8), el IR drop en las esquinas distintas de
`nom_tt_025C_5v00` (sección 4.3) y el comando literal `set_layer_rc` o `set_wire_rc` (sección 7.2).
No se agregó ningún valor que no venga de un archivo de `asic/rom/runs/final`, del PDK o de los
archivos de v1 que el documento usa expresamente para comparar.
