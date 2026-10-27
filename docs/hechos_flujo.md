# Hechos de la corrida final del flujo ASIC

Valores tomados de la corrida `asic/rom/runs/final` (LibreLane 3.0.16, PDK `gf180mcuD`,
biblioteca `gf180mcu_fd_sc_mcu7t5v0`, diseño `asic_top`, `CLOCK_PERIOD = 100` ns).
Cada dato indica el archivo de donde sale. Las rutas son relativas a la raíz del repositorio,
salvo las del PDK, que se indican con el prefijo `$PDK_ROOT/gf180mcuD`, donde

```
PDK_ROOT = /home/nicolasaraneda/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee
```

(`asic/rom/runs/final/resolved.json`, claves `PDK_ROOT`, `PDK`, `STD_CELL_LIBRARY`, `meta.librelane_version`).

Donde un dato no existe en la corrida se escribe "no disponible" y por qué. No hay valores estimados.

---

## 1. Restricciones de la SDC

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
| `IO_DELAY_CONSTRAINT` | 20 (% del período) | con `CLOCK_PERIOD = 100` ns da 20.0 ns: `set_input_delay 20.0000` y `set_output_delay 20.0000` en todos los puertos | `resolved.json` | `13-openroad-floorplan/openroad-floorplan.log`: "Setting output delay to: 20.0", "Setting input delay to: 20.0"; `13-openroad-floorplan/asic_top.sdc` |
| `OUTPUT_CAP_LOAD` | 72.91 fF | `set_load -pin_load 0.0729` en cada puerto de salida (19 puertos) | `resolved.json` | `13-openroad-floorplan/openroad-floorplan.log`: "Setting load to: 0.07291"; `13-openroad-floorplan/asic_top.sdc` |
| `MAX_FANOUT_CONSTRAINT` | 10 | `set_max_fanout 10.0000 [current_design]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `MAX_TRANSITION_CONSTRAINT` | 3 ns | `set_max_transition 3.0000 [current_design]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `MAX_CAPACITANCE_CONSTRAINT` | 0.2 pF | `set_max_capacitance 0.2000 [current_design]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `SYNTH_DRIVING_CELL` | `gf180mcu_fd_sc_mcu7t5v0__inv_1/ZN` | `set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__inv_1 -pin {ZN}` en `rst_n`, `spi_cs_n`, `spi_mosi`, `spi_sclk`, `btn[3:0]` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `SYNTH_CLK_DRIVING_CELL` | `gf180mcu_fd_sc_mcu7t5v0__inv_4/ZN` | `set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__inv_4 -pin {ZN}` en `clk` | `resolved.json` | `13-openroad-floorplan/asic_top.sdc` |
| `SYNTH_STRATEGY` | `AREA 0` | no aparece en la SDC: es la estrategia de mapeo de Yosys/ABC | `resolved.json` | - |

Detalles adicionales de la SDC (`13-openroad-floorplan/asic_top.sdc`):

- `create_clock -name clk -period 100.0000 [get_ports {clk}]`.
- `set_input_delay` en 8 puertos: `btn[0..3]`, `rst_n`, `spi_cs_n`, `spi_mosi`, `spi_sclk`.
- `set_output_delay` en 19 puertos: `led[0..3]`, `seg1[0..6]`, `seg2[0..6]`, `spi_miso`.
- Las dos transiciones de entrada de `set_driving_cell` son 0.0000 (rise y fall).

## 2. Floorplan

Fuente: `asic/rom/runs/final/13-openroad-floorplan/openroad-floorplan.log` y
`asic/rom/runs/final/final/metrics.json`.

| Dato | Valor | Fuente |
|---|---|---|
| Comando | `initialize_floorplan -site GF018hv5v_mcu_sc7 -utilization 40.0 -aspect_ratio 1.0 -core_space 15.68 15.68 6.720000000000001 6.720000000000001` | `13-openroad-floorplan/openroad-floorplan.log` |
| Modo de dimensionado | `FP_SIZING = relative`, `FP_CORE_UTIL = 40`, `FP_ASPECT_RATIO = 1`; `DIE_AREA` y `CORE_AREA` sin definir | `resolved.json` |
| Die (bbox) | (0.000, 0.000) a (630.600, 648.520) µm | `13-openroad-floorplan/openroad-floorplan.log` (IFP-0100); métrica `design__die__bbox` = `0.0 0.0 630.6 648.52` |
| Core (bbox) | (6.720, 15.680) a (623.840, 631.120) µm | `13-openroad-floorplan/openroad-floorplan.log` (IFP-0101); métrica `design__core__bbox` = `6.72 15.68 623.84 631.12` |
| Área del die | 408957 µm² | métrica `design__die__area` en `final/metrics.json` |
| Área del core | 379800.333 µm² | `13-openroad-floorplan/openroad-floorplan.log` (IFP-0102); métrica `design__core__area` = 379800 |
| Sitio | `GF018hv5v_mcu_sc7`, 0.56 µm de ancho por 3.92 µm de alto | `13-openroad-floorplan/openroad-floorplan.log`: "Using site height: 3.92 and site width: 0.56"; `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef`: `SITE GF018hv5v_mcu_sc7 ... SIZE 0.56 BY 3.92 ;` |
| Alto de fila | 3.92 µm (igual al alto del sitio) | mismo tech LEF y log de floorplan |
| Número de filas | 157 filas de 1102 sitios cada una | `13-openroad-floorplan/openroad-floorplan.log` (IFP-0001): "Added 157 rows of 1102 site GF018hv5v_mcu_sc7"; métricas `design__rows` = 157, `design__sites` = 173014 (= 157 x 1102) |
| Márgenes del core | abajo y arriba 15.68 µm; izquierda y derecha 6.72 µm | argumento `-core_space 15.68 15.68 6.72 6.72` en `13-openroad-floorplan/openroad-floorplan.log` |
| Multiplicadores de margen | `BOTTOM_MARGIN_MULT = 4`, `TOP_MARGIN_MULT = 4`, `LEFT_MARGIN_MULT = 12`, `RIGHT_MARGIN_MULT = 12` | `resolved.json` |
| Utilización efectiva al cerrar el floorplan | 0.401 (área de instancias 152353.466 µm², 5118 instancias) | `13-openroad-floorplan/openroad-floorplan.log` (IFP-0103 a IFP-0105) |

Los márgenes son los multiplicadores por la dimensión del sitio: 4 x 3.92 = 15.68 µm en vertical
y 12 x 0.56 = 6.72 µm en horizontal.

## 3. Celdas de tap y de borde

Fuente: `asic/rom/runs/final/resolved.json`,
`asic/rom/runs/final/19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` y
`asic/rom/runs/final/53-odb-cellfrequencytables/cell.rpt`.

| Dato | Valor | Fuente |
|---|---|---|
| Celda de tap (`WELLTAP_CELL`) | `gf180mcu_fd_sc_mcu7t5v0__filltie` | `resolved.json` |
| Celda de borde (`ENDCAP_CELL`) | `gf180mcu_fd_sc_mcu7t5v0__endcap` | `resolved.json` |
| `FP_TAPCELL_DIST` | 20 µm | `resolved.json`; argumento `-distance 20.0` del comando `tapcell` |
| Comando ejecutado | `tapcell -halo_width_x 10.0 -halo_width_y 10.0 -distance 20.0 -tapcell_master gf180mcu_fd_sc_mcu7t5v0__filltie -endcap_master gf180mcu_fd_sc_mcu7t5v0__endcap` | `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` |
| Taps insertados | 2466 | `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` (TAP-0005: "Inserted 2466 tapcells"); corroborado en `53-odb-cellfrequencytables/cell.rpt` (`__filltie` = 2466) y en la métrica `design__instance__count__class:tap_cell` |
| Endcaps insertados | 314 | `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` (TAP-0004: "Inserted 314 endcaps"); corroborado en `53-odb-cellfrequencytables/cell.rpt` (`__endcap` = 314) |
| Área de taps | 10826.73 µm² | reporte de tipos de celda en `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` |
| Área de endcaps | 1378.59 µm² | reporte de tipos de celda en `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` |
| Halos usados por `tapcell` | 10 µm en X y 10 µm en Y (`FP_MACRO_HORIZONTAL_HALO = 10`, `FP_MACRO_VERTICAL_HALO = 10`) | `resolved.json`; `19-openroad-tapendcapinsertion/openroad-tapendcapinsertion.log` |
| `RUN_TAP_ENDCAP_INSERTION` | `True` | `resolved.json` |

El paso previo `18-openroad-cutrows` corrió `cut_rows -halo_width_x 10.0 -halo_width_y 10.0
-endcap_master gf180mcu_fd_sc_mcu7t5v0__endcap` sin cambiar la cuenta de instancias (5118 antes y
después), porque el diseño no tiene macros
(`18-openroad-cutrows/openroad-cutrows.log`; `resolved.json`, `MACROS = None`).

## 4. Red de alimentación (PDN) y caída de tensión

### Variables usadas

La corrida no define `PDN_CFG` (usa el script de PDN de LibreLane) ni `PDN_OBSTRUCTIONS`.
Todas las variables provienen de `asic/rom/runs/final/resolved.json`. En LibreLane 3.0.16 las
variables se llaman `PDN_*`; no existen claves con prefijo `FP_PDN_*` en `resolved.json` (eran el
nombre antiguo en OpenLane 1), con la única excepción de `FP_TAPCELL_DIST`, que no es de PDN.

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

### Redes de alimentación

| Dato | Valor | Fuente |
|---|---|---|
| Red de alimentación | `VDD` (`VDD_PIN = VDD`; `VDD_NETS = None`) | `resolved.json` |
| Red de tierra | `VSS` (`GND_PIN = VSS`; `GND_NETS = None`) | `resolved.json` |
| Pines de alimentación de la biblioteca | `SCL_POWER_PINS = ['VDD', 'VNW']` | `resolved.json` |
| Pines de tierra de la biblioteca | `SCL_GROUND_PINS = ['VSS', 'VPW']` | `resolved.json` |
| Grilla generada | una sola, `stdcell_grid` | `21-openroad-generatepdn/openroad-generatepdn.log` (PDN-0001: "Inserting grid: stdcell_grid") |
| Conectividad | `All shapes on net VDD are connected` y `All shapes on net VSS are connected` | `21-openroad-generatepdn/openroad-generatepdn.log` (PSM-0040) |
| Violaciones de grilla | 0 en VDD y 0 en VSS | métricas `design__power_grid_violation__count__net:VDD` y `__net:VSS` en `final/metrics.json`; `21-openroad-generatepdn/VDD-grid-errors.rpt` y `VSS-grid-errors.rpt` quedaron vacíos (1 línea cada uno); `flow.log`: "Check for power grid violations ... clear" |

Lo que quedó en el DEF del paso de PDN
(`asic/rom/runs/final/21-openroad-generatepdn/asic_top.def`, sección `SPECIALNETS`, DBU = 2000):
158 segmentos de rieles en `Metal1` de 1200 DBU = 0.6 µm (coincide con `PDN_RAIL_WIDTH`),
8 straps en `Metal4` y 8 en `Metal5` de 3200 DBU = 1.6 µm (coinciden con `PDN_VWIDTH` y
`PDN_HWIDTH`), más vías en `Metal1`, `Metal2`, `Metal3` y `Metal4`. No hay formas de anillo,
consistente con `PDN_CORE_RING = False`.

### Caída de tensión (IR drop)

El paso `56-openroad-irdropreport` corrió (`RUN_IRDROP_REPORT = True` en `resolved.json`).
Fuente: `asic/rom/runs/final/56-openroad-irdropreport/irdrop.rpt` y las métricas de
`asic/rom/runs/final/final/metrics.json`.

| Red | Esquina | Potencia total | Tensión de alimentación | Peor tensión | Tensión promedio | IR drop promedio | Peor IR drop | Porcentaje |
|---|---|---|---|---|---|---|---|---|
| VDD | `nom_tt_025C_5v00` | 8.97e-03 W | 5.00e+00 V | 5.00e+00 V | 5.00e+00 V | 3.10e-05 V | 1.48e-04 V | 0.00 % |
| VSS | `nom_tt_025C_5v00` | 8.97e-03 W | 0.00e+00 V | 2.48e-04 V | 2.96e-05 V | 2.96e-05 V | 2.48e-04 V | 0.00 % |

Métricas correspondientes en `final/metrics.json`:

```
ir__drop__avg                                                      = 3.1e-05
ir__drop__worst                                                    = 0.000148
ir__voltage__worst                                                 = 5
design_powergrid__drop__average__net:VDD__corner:nom_tt_025C_5v00  = 4.99997
design_powergrid__drop__average__net:VSS__corner:nom_tt_025C_5v00  = 2.96219e-05
design_powergrid__drop__worst__net:VDD__corner:nom_tt_025C_5v00    = 0.000148163
design_powergrid__drop__worst__net:VSS__corner:nom_tt_025C_5v00    = 0.000247773
design_powergrid__drop__worst                                      = 0.000247773
design_powergrid__voltage__worst__net:VDD__corner:nom_tt_025C_5v00 = 4.99985
design_powergrid__voltage__worst__net:VSS__corner:nom_tt_025C_5v00 = 0.000247773
design_powergrid__voltage__worst                                   = 0.000247773
```

IR drop en el resto de las esquinas: **no disponible**. El paso `56-openroad-irdropreport` solo
analizó la esquina por defecto. En `56-openroad-irdropreport/irdrop.rpt` y en el log del paso
aparece únicamente `Corner : nom_tt_025C_5v00`, y todas las métricas `design_powergrid__*` de
`final/metrics.json` llevan el sufijo `__corner:nom_tt_025C_5v00`; no hay métricas
`design_powergrid__*` para ninguna otra esquina. La esquina analizada es la de
`DEFAULT_CORNER = nom_tt_025C_5v00` (`resolved.json`). La tensión no viene de una variable de la
corrida sino del liberty: `56-openroad-irdropreport/openroad-irdropreport.log` dice
"Using voltage extracted from lib (5V) for power nets and 0V for ground nets".

## 5. Placement

| Dato | Valor | Fuente |
|---|---|---|
| `PL_TARGET_DENSITY_PCT` | `None` (no fijada explícitamente) | `resolved.json` |
| Densidad objetivo usada | 0.533277 (53.3277 %), calculada dinámicamente por el flujo | `flow.log`: "'PL_TARGET_DENSITY_PCT' not explicitly set, using dynamically calculated target density: 53.327700"; `28-openroad-globalplacement/openroad-globalplacement.log`: `global_placement -density 0.533277 ...` y GPL-0023 "Placement target density: 0.5333" |
| Densidad mínima factible informada | 0.4500 (área de celdas / área libre) | `28-openroad-globalplacement/openroad-globalplacement.log` (GPL-1004) |
| `GPL_CELL_PADDING` | 0 | `resolved.json`; en el comando: `-pad_right 0 -pad_left 0` en `28-openroad-globalplacement/openroad-globalplacement.log` |
| `DPL_CELL_PADDING` | 0 | `resolved.json` |
| Comando de global placement | `global_placement -density 0.533277 -routability_driven -pad_right 0 -pad_left 0 -init_wirelength_coef 0.25` | `28-openroad-globalplacement/openroad-globalplacement.log` |
| Otras variables de GPL | `PL_ROUTABILITY_DRIVEN = True`, `PL_WIRE_LENGTH_COEF = 0.25`, `PL_TIMING_DRIVEN = False`, `PL_SKIP_INITIAL_PLACEMENT = False`, `PL_OPTIMIZE_MIRRORING = True` | `resolved.json` |
| Comando de detailed placement | `detailed_placement -max_displacement 500 100` (`PL_MAX_DISPLACEMENT_X = 500`, `PL_MAX_DISPLACEMENT_Y = 100`) | `34-openroad-detailedplacement/openroad-detailedplacement.log`; `resolved.json` |
| Áreas que vio GPL | instancias movibles 152353.466 µm²; instancias totales 163180.192 µm²; ajuste por densidad de pines 11422.369 µm² | `28-openroad-globalplacement/openroad-globalplacement.log` (GPL-0035 a GPL-0037) |
| Utilización final de instancias | 0.479898 | métricas `design__instance__utilization` y `design__instance__utilization__stdcell` en `final/metrics.json` |

## 6. CTS

Fuente: `asic/rom/runs/final/resolved.json`,
`asic/rom/runs/final/35-openroad-cts/openroad-cts.log`,
`asic/rom/runs/final/35-openroad-cts/cts.rpt`,
`asic/rom/runs/final/55-openroad-stapostpnr/<esquina>/clock.rpt` y
`asic/rom/runs/final/final/metrics.json`.

### Celdas de reloj permitidas

| Variable | Valor | Fuente |
|---|---|---|
| `CTS_CLK_BUFFERS` | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_2`, `gf180mcu_fd_sc_mcu7t5v0__clkbuf_4`, `gf180mcu_fd_sc_mcu7t5v0__clkbuf_8` | `resolved.json` |
| `CTS_ROOT_BUFFER` | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_16` | `resolved.json` |
| Buffer de sumidero elegido | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_8` | `35-openroad-cts/openroad-cts.log` (CTS-0051) |
| Buffer de caracterización | `gf180mcu_fd_sc_mcu7t5v0__clkbuf_8` | `35-openroad-cts/openroad-cts.log` (CTS-0049) |
| Otras variables | `CTS_APPLY_NDR = half`, `CTS_SINK_CLUSTERING_ENABLE = True`, `CTS_CLK_MAX_WIRE_LENGTH = 0`, `CTS_DISTANCE_BETWEEN_BUFFERS = 0`, `CTS_DISABLE_POST_PROCESSING = False`; `CTS_MAX_CAP`, `CTS_MAX_SLEW`, `CTS_SINK_CLUSTERING_SIZE`, `CTS_SINK_CLUSTERING_MAX_DIAMETER`, `CTS_BALANCE_LEVELS`, `CTS_CORNERS` sin definir | `resolved.json` |
| Comando ejecutado | `clock_tree_synthesis -buf_list gf180mcu_fd_sc_mcu7t5v0__clkbuf_2 gf180mcu_fd_sc_mcu7t5v0__clkbuf_4 gf180mcu_fd_sc_mcu7t5v0__clkbuf_8 -root_buf gf180mcu_fd_sc_mcu7t5v0__clkbuf_16 -sink_clustering_enable -apply_ndr half` | `35-openroad-cts/openroad-cts.log` |

### Buffers de reloj insertados

De `asic/rom/runs/final/35-openroad-cts/cts.rpt`:

```
Total number of Clock Roots: 1.
Total number of Buffers Inserted: 75.
Total number of Clock Subnets: 75.
Total number of Sinks: 990.
Cells used:
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_8: 66
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_16: 9
Dummys used:
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_2: 14
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_4: 14
  gf180mcu_fd_sc_mcu7t5v0__clkbuf_8: 7
  gf180mcu_fd_sc_mcu7t5v0__clkinv_1: 3
  gf180mcu_fd_sc_mcu7t5v0__clkinv_2: 5
  gf180mcu_fd_sc_mcu7t5v0__clkinv_3: 2
  gf180mcu_fd_sc_mcu7t5v0__clkinv_8: 2
  gf180mcu_fd_sc_mcu7t5v0__clkinv_12: 1
  gf180mcu_fd_sc_mcu7t5v0__inv_1: 1
  gf180mcu_fd_sc_mcu7t5v0__inv_2: 4
  gf180mcu_fd_sc_mcu7t5v0__inv_3: 6
  gf180mcu_fd_sc_mcu7t5v0__inv_4: 2
```

El log del paso agrega (`35-openroad-cts/openroad-cts.log`): 75 buffers de reloj creados
(CTS-0018), 75 redes de reloj (CTS-0015), 61 cargas ficticias insertadas (CTS-0207), mínimo y
máximo de buffers en el camino de reloj = 3 (CTS-0012 y CTS-0013), nivel máximo del árbol = 3
(CTS-0017). El reporte de tipos de celda tras el CTS cuenta 110 "Clock buffer" (5830.45 µm²) y
26 "Clock inverter" (474.16 µm²), que incluyen las cargas ficticias.

### Skew y latencia de reloj por esquina

Skew: métricas `clock__skew__worst_setup__corner:*` y `clock__skew__worst_hold__corner:*` de
`asic/rom/runs/final/final/metrics.json`, en ns. Latencia de red: bloque `report_clock_latency`
de `asic/rom/runs/final/55-openroad-stapostpnr/<esquina>/clock.rpt`, transición rise a rise, en ns.
La latencia de fuente es 0.000000 en las nueve esquinas (el reloj es virtual y no propagado:
`clock.rpt` dice `Propagated: no`, `Virtual: yes`).

| Esquina | Skew peor setup | Skew peor hold | Latencia de red mín. | Latencia de red máx. | Skew de `clock.rpt` | Período mínimo / fmax |
|---|---|---|---|---|---|---|
| `nom_tt_025C_5v00` | 0.420465 | -0.539914 | 1.248330 | 1.479394 | 0.231064 | 18.36 ns / 54.46 MHz |
| `nom_ss_125C_4v50` | 0.548744 | -0.758591 | 2.207133 | 2.612925 | 0.405792 | 33.24 ns / 30.08 MHz |
| `nom_ff_n40C_5v50` | 0.361814 | -0.439984 | 0.816749 | 0.967861 | 0.151111 | 11.71 ns / 85.38 MHz |
| `min_tt_025C_5v00` | 0.411331 | -0.527254 | 1.217309 | 1.436798 | 0.219488 | 17.64 ns / 56.69 MHz |
| `min_ss_125C_4v50` | 0.532823 | -0.736573 | 2.155312 | 2.540206 | 0.384895 | 31.97 ns / 31.28 MHz |
| `min_ff_n40C_5v50` | 0.355849 | -0.431690 | 0.795132 | 0.939097 | 0.143965 | 11.25 ns / 88.92 MHz |
| `max_tt_025C_5v00` | 0.431513 | -0.555359 | 1.281476 | 1.531420 | 0.249944 | 19.23 ns / 52.00 MHz |
| `max_ss_125C_4v50` | 0.567977 | -0.785412 | 2.262984 | 2.701743 | 0.438759 | 34.78 ns / 28.76 MHz |
| `max_ff_n40C_5v50` | 0.369057 | -0.450142 | 0.839676 | 1.003014 | 0.163338 | 12.27 ns / 81.48 MHz |

Los valores agregados (sin sufijo de esquina) de `final/metrics.json` son
`clock__skew__worst_setup = 0.355849` (de `min_ff_n40C_5v50`) y
`clock__skew__worst_hold = -0.431690` (de `min_ff_n40C_5v50`).

El desglose del skew de setup en la esquina típica
(`55-openroad-stapostpnr/nom_tt_025C_5v00/skew.max.rpt`) es: latencia de fuente 1.479265 en
`_4536_/CLK`, latencia de destino -1.249277 en `_4199_/CLK`, incertidumbre de reloj 0.250000,
CRPR -0.059524, skew de setup 0.420465.

### Topología

El log sí la informa (`35-openroad-cts/openroad-cts.log`):

- CTS-0027: "Generating H-Tree topology for net clk" (topología H-Tree).
- CTS-0010 y CTS-0028: la red `clk` tiene 990 sumideros.
- CTS-0090 y CTS-0206: los sumideros se agrupan por capacidad máxima del buffer; la mejor solución
  fue tamaño de cluster 10 y diámetro 50.
- CTS-0019: 66 sumideros después del agrupamiento.
- CTS-0020: unidad de segmento de cable 39200 DBU (19 µm).
- CTS-0024 a CTS-0026: región normalizada de sumideros [(1.50217, 3.0875), (30.5396, 30.9118)],
  ancho 29.0374, alto 27.8243.
- Niveles: nivel 1 horizontal (33 sumideros por subregión, largo de segmento 8), nivel 2 vertical
  (17 sumideros, largo 6), nivel 3 horizontal (9 sumideros, largo 4); criterio de parada con
  máximo de 10 sumideros (CTS-0032).
- CTS-0016: distribución de fanout `4:1, 8:7, 9:3, 10:1, 11:1, 12:3, 13:2, 14:8, 15:15, 16:17, 17:11, 18:5`.
- CTS-0098 a CTS-0102: red `clk`, 1051 sumideros, 66 buffers de hoja, largo promedio de cable a
  sumidero 755.12 µm, profundidad de camino 2 a 3.
- Tras el CTS, `repair_clock_nets` usó largo máximo de cable 11309 µm (RSZ-0058).

## 7. Ruteo

| Dato | Valor | Fuente |
|---|---|---|
| `RT_MIN_LAYER` | `Metal2` | `resolved.json`; `39-openroad-globalrouting/openroad-globalrouting.log`: "Setting signal min routing layer to: Metal2 and clock min routing layer to Metal2" y GRT-0020 "Min routing layer: Metal2" |
| `RT_MAX_LAYER` | `Metal5` | `resolved.json`; `39-openroad-globalrouting/openroad-globalrouting.log`: "Setting signal max routing layer to: Metal5 ..." y GRT-0021 "Max routing layer: Metal5" |
| `RT_CLOCK_MIN_LAYER` / `RT_CLOCK_MAX_LAYER` | `None`; el log muestra que el reloj heredó `Metal2` y `Metal5` | `resolved.json`; `39-openroad-globalrouting/openroad-globalrouting.log` |
| `GRT_ADJUSTMENT` | 0.3 | `resolved.json` |
| `GRT_LAYER_ADJUSTMENTS` | `[0, 0, 0, 0, 0]` | `resolved.json` |
| Comando de global routing | `global_route -congestion_iterations 50 -verbose` (`GRT_OVERFLOW_ITERS = 50`) | `39-openroad-globalrouting/openroad-globalrouting.log` |
| Comando de detailed routing | `detailed_route -droute_end_iter 64 -or_seed 42 -verbose 1 -output_drc ...` (`DRT_OPT_ITERS = 64`) | `44-openroad-detailedrouting/openroad-detailedrouting.log` |

### Capas de metal del tech LEF

Del tech LEF que leyó la corrida,
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef`
(la ruta exacta aparece en `13-openroad-floorplan/openroad-floorplan.log` y en
`resolved.json`, clave `TECH_LEFS`, patrón `nom_*`). El archivo es `VERSION 5.7`,
`DATABASE MICRONS 2000`, `MANUFACTURINGGRID 0.0050`, y declara 15 capas y 56 vías
(`13-openroad-floorplan/openroad-floorplan.log`, ODB-0227).

| Capa | Tipo | Dirección preferida | Pitch (µm) | Ancho mínimo = WIDTH (µm) | Offset (µm) | Área mínima (µm²) | Espesor (µm) |
|---|---|---|---|---|---|---|---|
| `Metal1` | ROUTING | HORIZONTAL | 0.56 | 0.230 | 0.0 | 0.1444 | 0.54 |
| `Metal2` | ROUTING | VERTICAL | 0.56 | 0.280 | 0.0 | 0.1444 | - |
| `Metal3` | ROUTING | HORIZONTAL | 0.56 | 0.280 | 0.0 | 0.1444 | - |
| `Metal4` | ROUTING | VERTICAL | 0.56 | 0.280 | 0.0 | 0.1444 | - |
| `Metal5` | ROUTING | HORIZONTAL | 0.9 | 0.440 | 0.0 | 0.5625 | 1.19 |

En las cinco capas `MINWIDTH` y `WIDTH` coinciden. Espesor: el tech LEF solo declara `THICKNESS`
en `Metal1` (0.54 µm) y `Metal5` (1.19 µm); para `Metal2`, `Metal3` y `Metal4` el dato no está en
el archivo, por eso aparece como "-".

Capas no de ruteo del mismo archivo: `Pwell` y `Nwell` (`LEF58_TYPE`), `Poly2` y `PR_bndry`
(MASTERSLICE), `CON`, `Via1`, `Via2`, `Via3` y `Via4` (CUT, con `WIDTH 0.26` en las cuatro vías)
y `OVERLAP`.

Pitches por capa que informó el ruteador global
(`39-openroad-globalrouting/openroad-globalrouting.log`, GRT-0088):

| Capa | Track-Pitch | line-2-Via Pitch |
|---|---|---|
| `Metal1` | 0.5600 | 0.4750 |
| `Metal2` | 0.5600 | 0.5600 |
| `Metal3` | 0.5600 | 0.5600 |
| `Metal4` | 0.5600 | 0.5600 |
| `Metal5` | 0.9000 | 0.8200 |

## 8. Relleno (fill y decap)

| Dato | Valor | Fuente |
|---|---|---|
| `FILL_CELLS` | `gf180mcu_fd_sc_mcu7t5v0__fill_*` | `resolved.json` |
| `DECAP_CELLS` | `gf180mcu_fd_sc_mcu7t5v0__fillcap_*` | `resolved.json` |
| `RUN_FILL_INSERTION` | `True` | `resolved.json` |
| Patrones pasados al paso | `gf180mcu_fd_sc_mcu7t5v0__fillcap_* gf180mcu_fd_sc_mcu7t5v0__fill_*` | `52-openroad-fillinsertion/openroad-fillinsertion.log` |
| Total de rellenos colocados | 12152 | `52-openroad-fillinsertion/openroad-fillinsertion.log` (DPL-0001: "Placed 12152 filler instances"); métrica `design__instance__count__class:fill_cell` en `final/metrics.json` |
| Área total de relleno | 197535.07 µm² | reporte de tipos de celda en `52-openroad-fillinsertion/openroad-fillinsertion.log`; métrica `design__instance__area__class:fill_cell` |

Desglose por celda, de `asic/rom/runs/final/53-odb-cellfrequencytables/cell.rpt` (tabla
"Cells by Master", generada después de la inserción de relleno):

| Celda | Cantidad | Tipo | Ancho x alto del cell LEF (µm) |
|---|---|---|---|
| `gf180mcu_fd_sc_mcu7t5v0__fill_1` | 2853 | fill | 0.560 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fill_2` | 2688 | fill | 1.120 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_4` | 2763 | decap | 2.240 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_8` | 1864 | decap | 4.480 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_16` | 1143 | decap | 8.960 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_32` | 510 | decap | 17.920 x 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__fillcap_64` | 331 | decap | 35.840 x 3.920 |

Subtotales: 5541 celdas de fill (`fill_1` + `fill_2`) y 6611 celdas de decap (los cinco
`fillcap_*`); juntas dan los 12152 rellenos del log. Las dimensiones vienen de
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lef/gf180mcu_fd_sc_mcu7t5v0.lef`
(sentencia `SIZE` de cada `MACRO`), no del liberty.

Área de las celdas de relleno por separado (fill contra decap): **no disponible**. El reporte de
tipos de celda de los logs y la métrica `design__instance__area__class:fill_cell` agrupan ambos
grupos en una sola clase "Fill cell" de 197535.07 µm², y `53-odb-cellfrequencytables/cell.rpt`
solo da cantidades, no áreas.

## 9. Extracción de parásitos (RCX)

`RUN_SPEF_EXTRACTION = True` y `RCX_MERGE_VIA_WIRE_RES = True` (`resolved.json`). El paso
`54-openroad-rcx` corrió tres veces, una por grupo de esquinas, según `RCX_RULESETS` de
`resolved.json` (patrones `nom_*`, `min_*`, `max_*`):

| Grupo | Conjunto de reglas usado | SPEF generado |
|---|---|---|
| `nom_*` | `$PDK_ROOT/gf180mcuD/libs.tech/openlane/rules.openrcx.gf180mcuD.nom` | `asic/rom/runs/final/54-openroad-rcx/nom/asic_top.nom.spef` |
| `min_*` | `$PDK_ROOT/gf180mcuD/libs.tech/openlane/rules.openrcx.gf180mcuD.min` | `asic/rom/runs/final/54-openroad-rcx/min/asic_top.min.spef` |
| `max_*` | `$PDK_ROOT/gf180mcuD/libs.tech/openlane/rules.openrcx.gf180mcuD.max` | `asic/rom/runs/final/54-openroad-rcx/max/asic_top.max.spef` |

Fuentes: `asic/rom/runs/final/54-openroad-rcx/{nom,min,max}/rcx.log`, línea
"Using RCX ruleset '...'" y el comando `extract_parasitics -ext_model_file ... -lef_res`;
`asic/rom/runs/final/flow.log`, líneas 165 a 167 ("Running RCX for corners matching nom_*", etc.).
Los tres SPEF quedaron copiados en `asic/rom/runs/final/final/spef/{nom,min,max}/`.

Qué SPEF leyó el STA de firma, por esquina
(`asic/rom/runs/final/55-openroad-stapostpnr/<esquina>/sta.log`, línea "Reading top-level design
parasitics for the '<esquina>' corner at '...'"):

| Esquinas | SPEF leído |
|---|---|
| `nom_tt_025C_5v00`, `nom_ss_125C_4v50`, `nom_ff_n40C_5v50` | `54-openroad-rcx/nom/asic_top.nom.spef` |
| `min_tt_025C_5v00`, `min_ss_125C_4v50`, `min_ff_n40C_5v50` | `54-openroad-rcx/min/asic_top.min.spef` |
| `max_tt_025C_5v00`, `max_ss_125C_4v50`, `max_ff_n40C_5v50` | `54-openroad-rcx/max/asic_top.max.spef` |

Las nueve esquinas de STA son `STA_CORNERS` de `resolved.json`:
`nom_tt_025C_5v00`, `nom_ss_125C_4v50`, `nom_ff_n40C_5v50`, `min_tt_025C_5v00`,
`min_ss_125C_4v50`, `min_ff_n40C_5v50`, `max_tt_025C_5v00`, `max_ss_125C_4v50`,
`max_ff_n40C_5v50`. `DEDUPLICATE_CORNERS = False`, por eso el STA posterior al PnR
(`55-openroad-stapostpnr`) corrió las nueve (`flow.log`, líneas 175 a 185), a diferencia del
STA previo al PnR (`12-openroad-staprepnr`), donde el flujo omitió las esquinas `min_*` y `max_*`
por ser idénticas a las `nom_*` sin parásitos (`flow.log`, líneas 30 a 37).

Tech LEF por grupo de esquinas (`resolved.json`, clave `TECH_LEFS`): `nom_*` usa
`gf180mcu_fd_sc_mcu7t5v0__nom.tlef`, con entradas análogas para `min_*` y `max_*`.

## 10. Potencia

### Corrida final, por esquina

De `asic/rom/runs/final/55-openroad-stapostpnr/<esquina>/power.rpt`, fila `Total`, en vatios:

| Esquina | Interna | Conmutación | Fuga | Total |
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

Las métricas de `asic/rom/runs/final/final/metrics.json` no llevan sufijo de esquina y corresponden
a la última esquina procesada, `max_ff_n40C_5v50`:

```
power__internal__total  = 0.008802732452750206
power__switching__total = 0.0024753210600465536
power__leakage__total   = 2.258793529108516e-06
power__total            = 0.011280312202870846
```

Desglose por grupo en la esquina típica
(`55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`), en vatios:

| Grupo | Interna | Conmutación | Fuga | Total | % |
|---|---|---|---|---|---|
| Sequential | 5.257507e-03 | 5.884253e-07 | 3.983518e-07 | 5.258494e-03 | 58.6 % |
| Combinational | 1.758122e-06 | 7.133403e-07 | 6.770268e-07 | 3.148489e-06 | 0.0 % |
| Clock | 1.762148e-03 | 1.946220e-03 | 7.861973e-07 | 3.709155e-03 | 41.3 % |
| Macro | 0 | 0 | 0 | 0 | 0.0 % |
| Pad | 0 | 0 | 0 | 0 | 0.0 % |
| Total | 7.021405e-03 | 1.947522e-03 | 1.861619e-06 | 8.970790e-03 | 100.0 % |

Reparto de la fila Total en la esquina típica: 78.3 % interna, 21.7 % de conmutación, 0.0 % de fuga
(mismo archivo).

El valor de potencia total que usó el análisis de IR drop, 8.97e-03 W
(`56-openroad-irdropreport/irdrop.rpt`), coincide con el total de `nom_tt_025C_5v00`.

### Corrida f1_t25, esquina `nom_tt_025C_5v00`

`f1_t25` es la misma configuración con `CLOCK_PERIOD = 25` ns
(`asic/rom/runs/f1_t25/resolved.json`: `CLOCK_PERIOD = 25`, `SYNTH_PARAMETERS =
['MemStrategy=1', 'DataWords=4']`, `SYNTH_STRATEGY = AREA 0`, `FP_CORE_UTIL = 40`,
iguales a los de la corrida final salvo el período).

De `asic/rom/runs/f1_t25/55-openroad-stapostpnr/nom_tt_025C_5v00/power.rpt`, en vatios:

| Grupo | Interna | Conmutación | Fuga | Total | % |
|---|---|---|---|---|---|
| Sequential | 2.102811e-02 | 2.323531e-06 | 3.985847e-07 | 2.103083e-02 | 58.7 % |
| Combinational | 7.032634e-06 | 2.853361e-06 | 7.173606e-07 | 1.060335e-05 | 0.0 % |
| Clock | 7.042590e-03 | 7.746496e-03 | 7.721910e-07 | 1.478986e-02 | 41.3 % |
| Macro | 0 | 0 | 0 | 0 | 0.0 % |
| Pad | 0 | 0 | 0 | 0 | 0.0 % |
| **Total** | **2.807777e-02** | **7.751673e-03** | **1.888180e-06** | **3.583133e-02** | 100.0 % |

Reparto de la fila Total: 78.4 % interna, 21.6 % de conmutación, 0.0 % de fuga (mismo archivo).

Las métricas agregadas de `asic/rom/runs/f1_t25/final/metrics.json` (sin sufijo de esquina, de la
última esquina procesada) son `power__internal__total = 0.03519558161497116`,
`power__switching__total = 0.009846615605056286`,
`power__leakage__total = 2.291018063260708e-06`, `power__total = 0.045044489204883575`.

### Actividad de conmutación supuesta

**No disponible.** Ningún archivo de la corrida la informa. La corrida no anota actividad: no hay
VCD ni SAIF leído en ningún paso (una búsqueda de `activity`, `set_power`, `saif` y `.vcd` sobre
todos los logs, los `COMMANDS` y los `_env.tcl` de `asic/rom/runs/final` no devuelve
coincidencias), `power.rpt` no imprime la actividad que asumió y los `COMMANDS` de
`55-openroad-stapostpnr` solo invocan `sta -no_splash -exit .../openroad/sta/corner.tcl` sin
argumentos de actividad. El valor que usa OpenSTA por defecto queda implícito y la corrida no lo
escribe en ningún lado.

## 11. Datos del liberty (esquina típica y lenta)

Archivos (`resolved.json`, clave `LIB`; rutas confirmadas en los logs de cada paso):

- Esquina típica, `*_tt_025C_5v00`:
  `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib`
  (`operating_conditions`: process 1, temperature 25, voltage 5).
- Esquina lenta, `*_ss_125C_4v50`:
  `$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__ss_125C_4v50.lib`.

Unidades de ambos liberty: `time_unit : 1ns`, `voltage_unit : 1V`, `current_unit : 1mA`,
`capacitive_load_unit(1, pf)`, `leakage_power_unit : 1uW`, `default_fanout_load : 1.0`,
umbrales de slew 30 % y 70 %, `slew_derate_from_library : 0.5`.

### Área, ancho y alto

El atributo `area` sale del liberty. **El ancho y el alto no están en el liberty**: los liberty de
`gf180mcu_fd_sc_mcu7t5v0` no tienen atributos de ancho ni de alto de celda, así que se toman de la
sentencia `SIZE` del cell LEF que leyó la misma corrida,
`$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lef/gf180mcu_fd_sc_mcu7t5v0.lef`
(ruta en `13-openroad-floorplan/openroad-floorplan.log`; `resolved.json`, clave `CELL_LEFS`).

Las áreas son idénticas en la esquina típica y en la lenta (el liberty no cambia la geometría):

| Celda | `area` (µm²) típica | `area` (µm²) lenta | Ancho (µm), cell LEF | Alto (µm), cell LEF |
|---|---|---|---|---|
| `gf180mcu_fd_sc_mcu7t5v0__dffq_1` | 63.660800 | 63.660800 | 16.240 | 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__dffrnq_1` | 74.636800 | 74.636800 | 19.040 | 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__mux2_2` | 32.928000 | 32.928000 | 8.400 | 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__nand2_1` | 10.976000 | 10.976000 | 2.800 | 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__buf_2` | 17.561600 | 17.561600 | 4.480 | 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__clkbuf_16` | 109.760000 | 109.760000 | 28.000 | 3.920 |
| `gf180mcu_fd_sc_mcu7t5v0__icgtp_1` | 61.465600 | 61.465600 | 15.680 | 3.920 |

El alto de 3.920 µm es común a todas: coincide con el alto de fila del sitio
`GF018hv5v_mcu_sc7` (sección 2).

### Setup, hold y retardo reloj a Q de `dffq_1`

Las restricciones de setup y de hold de `dffq_1` están en el grupo `pin(D)` como tablas 10x10
`cnst_ctin_rtin_10x10`, con `index_1` = transición del pin restringido (D) e `index_2` =
transición del pin relacionado (CLK). El retardo reloj a Q está en `pin(Q)`,
`timing_type : rising_edge`, `related_pin : "CLK"`, como tablas 10x10 `tmg_ntin_oload_10x10`
con `index_1` = transición de entrada e `index_2` = capacitancia total de salida.

Punto elegido en la esquina típica: `index_1` = `index_2` = 0.1439 ns para setup y hold (tercer
punto de la grilla, el más cercano a `CLOCK_TRANSITION_CONSTRAINT = 0.15` ns de la SDC), y
transición 0.1439 ns con carga 0.06075 pF para el retardo reloj a Q (sexto punto de carga, el más
cercano a `OUTPUT_CAP_LOAD = 72.91` fF = 0.07291 pF).

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

Otros datos de `dffq_1` en la esquina típica (mismo liberty): `min_pulse_width_high : 0.406`,
`min_pulse_width_low : 0.446` sobre CLK, y restricciones `minimum_period` asociadas a CLK.

### `max_transition` por defecto de la biblioteca

Los dos liberty **no declaran un atributo `default_max_transition` a nivel de biblioteca**
(no aparece en el encabezado de ninguno de los dos archivos). El límite se declara pin por pin,
con un valor único por esquina:

| Liberty | Valor de `max_transition` | Ocurrencias |
|---|---|---|
| `gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib` | 4 ns | 836 |
| `gf180mcu_fd_sc_mcu7t5v0__ss_125C_4v50.lib` | 7 ns | 836 |

En la corrida, `DEFAULT_MAX_TRAN` no está definida (`resolved.json`), y la SDC impone un límite más
estricto: `set_max_transition 3.0000 [current_design]` (sección 1).

## 12. Pasos que corrió la corrida final

Orden y nombres de carpeta de `asic/rom/runs/final`; nombre del paso y motivo de omisión de
`asic/rom/runs/final/flow.log`; tiempo de `<carpeta>/runtime.txt` de cada paso.
Los pasos omitidos se marcan con "omitido" y conservan su carpeta, que queda solo con
`config.json`, `runtime.txt`, `state_in.json` y `state_out.json`.

| # | Carpeta | Paso | Tiempo | Estado |
|---|---|---|---|---|
| 01 | `01-verilator-lint` | `Verilator.Lint` | 00:00:00.476 | corrió |
| 02 | `02-checker-linttimingconstructs` | `Checker.LintTimingConstructs` | 00:00:00.000 | corrió |
| 03 | `03-checker-linterrors` | `Checker.LintErrors` | 00:00:00.000 | corrió |
| 04 | `04-checker-lintwarnings` | `Checker.LintWarnings` | 00:00:00.000 | corrió |
| 05 | `05-yosys-jsonheader` | `Yosys.JsonHeader` | 00:00:00.716 | corrió |
| 06 | `06-yosys-synthesis` | `Yosys.Synthesis` | 00:00:07.315 | corrió |
| 07 | `07-checker-yosysunmappedcells` | `Checker.YosysUnmappedCells` | 00:00:00.000 | corrió |
| 08 | `08-checker-yosyssynthchecks` | `Checker.YosysSynthChecks` | 00:00:00.000 | corrió |
| 09 | `09-checker-netlistassignstatements` | `Checker.NetlistAssignStatements` | 00:00:00.007 | corrió |
| 10 | `10-openroad-checksdcfiles` | `OpenROAD.CheckSDCFiles` | 00:00:00.001 | corrió (reportó que usa la SDC genérica) |
| 11 | `11-openroad-checkmacroinstances` | `OpenROAD.CheckMacroInstances` | 00:00:00.000 | omitido: "No macros found, skipping instance check" |
| 12 | `12-openroad-staprepnr` | `OpenROAD.STAPrePNR` | 00:00:03.898 | corrió (solo 3 esquinas: omitió `min_*` y `max_*` por idénticas a `nom_*` en esta etapa) |
| 13 | `13-openroad-floorplan` | `OpenROAD.Floorplan` | 00:00:00.807 | corrió |
| 14 | `14-openroad-dumprcvalues` | `OpenROAD.DumpRCValues` | 00:00:00.706 | corrió |
| 15 | `15-odb-checkmacroantennaproperties` | `Odb.CheckMacroAntennaProperties` | 00:00:00.001 | omitido: "No cells provided" |
| 16 | `16-odb-setpowerconnections` | `Odb.SetPowerConnections` | 00:00:00.605 | corrió |
| 17 | `17-odb-manualmacroplacement` | `Odb.ManualMacroPlacement` | 00:00:00.001 | omitido: "No instances found" |
| 18 | `18-openroad-cutrows` | `OpenROAD.CutRows` | 00:00:00.706 | corrió |
| 19 | `19-openroad-tapendcapinsertion` | `OpenROAD.TapEndcapInsertion` | 00:00:00.806 | corrió |
| 20 | `20-odb-addpdnobstructions` | `Odb.AddPDNObstructions` | 00:00:00.001 | omitido: "'PDN_OBSTRUCTIONS' is not defined" |
| 21 | `21-openroad-generatepdn` | `OpenROAD.GeneratePDN` | 00:00:01.009 | corrió |
| 22 | `22-odb-removepdnobstructions` | `Odb.RemovePDNObstructions` | 00:00:00.001 | omitido: "'PDN_OBSTRUCTIONS' is not defined" |
| 23 | `23-odb-addroutingobstructions` | `Odb.AddRoutingObstructions` | 00:00:00.001 | omitido: "'ROUTING_OBSTRUCTIONS' is not defined" |
| 24 | `24-openroad-globalplacementskipio` | `OpenROAD.GlobalPlacementSkipIO` | 00:00:00.001 | omitido: "I/O pins to be placed from .../asic/rom/pines.cfg. Returning state unaltered" |
| 25 | `25-openroad-ioplacement` | `OpenROAD.IOPlacement` | 00:00:00.001 | omitido: "IO_PIN_ORDER_CFG is set" |
| 26 | `26-odb-customioplacement` | `Odb.CustomIOPlacement` | 00:00:00.607 | corrió |
| 27 | `27-odb-applydeftemplate` | `Odb.ApplyDEFTemplate` | 00:00:00.001 | omitido: "No DEF template provided" |
| 28 | `28-openroad-globalplacement` | `OpenROAD.GlobalPlacement` | 00:00:02.314 | corrió |
| 29 | `29-odb-writeverilogheader` | `Odb.WriteVerilogHeader` | 00:00:00.505 | corrió |
| 30 | `30-checker-powergridviolations` | `Checker.PowerGridViolations` | 00:00:00.001 | corrió (limpio) |
| 31 | `31-openroad-stamidpnr` | `OpenROAD.STAMidPNR` | 00:00:03.926 | corrió |
| 32 | `32-openroad-repairdesignpostgpl` | `OpenROAD.RepairDesignPostGPL` | 00:00:12.156 | corrió |
| 33 | `33-odb-manualglobalplacement` | `Odb.ManualGlobalPlacement` | 00:00:00.001 | omitido: "'MANUAL_GLOBAL_PLACEMENTS' not set" |
| 34 | `34-openroad-detailedplacement` | `OpenROAD.DetailedPlacement` | 00:00:00.907 | corrió |
| 35 | `35-openroad-cts` | `OpenROAD.CTS` | 00:00:14.058 | corrió |
| 36 | `36-openroad-stamidpnr-1` | `OpenROAD.STAMidPNR-1` | 00:00:03.427 | corrió |
| 37 | `37-openroad-resizertimingpostcts` | `OpenROAD.ResizerTimingPostCTS` | 00:00:10.047 | corrió |
| 38 | `38-openroad-stamidpnr-2` | `OpenROAD.STAMidPNR-2` | 00:00:03.424 | corrió |
| 39 | `39-openroad-globalrouting` | `OpenROAD.GlobalRouting` | 00:00:01.310 | corrió |
| 40 | `40-openroad-checkantennas` | `OpenROAD.CheckAntennas` | 00:00:03.619 | corrió |
| - | sin carpeta | `OpenROAD.RepairDesignPostGRT` ("Repair Design (Post-Global Routing)") | - | omitido: variable de habilitación en `False` (`RUN_POST_GRT_DESIGN_REPAIR = False`) |
| 41 | `41-odb-diodesonports` | `Odb.DiodesOnPorts` | 00:00:00.001 | omitido: "'DIODE_ON_PORTS' is set to 'none'" |
| - | sin carpeta | `Odb.HeuristicDiodeInsertion` ("Heuristic Diode Insertion") | - | omitido: variable de habilitación en `False` (`RUN_HEURISTIC_DIODE_INSERTION = False`) |
| 42 | `42-openroad-repairantennas` | `OpenROAD.RepairAntennas` | 00:00:08.056 | corrió, con dos subpasos |
| 42.1 | `42-openroad-repairantennas/1-openroad-diodeinsertion` | `OpenROAD.DiodeInsertion` | 00:00:04.024 | corrió |
| 42.2 | `42-openroad-repairantennas/2-openroad-checkantennas` | `OpenROAD.CheckAntennas` | 00:00:04.025 | corrió |
| - | sin carpeta | `OpenROAD.ResizerTimingPostGRT` ("Resizer Timing Optimizations (Post-Global Routing)") | - | omitido: variable de habilitación en `False` (`RUN_POST_GRT_RESIZER_TIMING = False`) |
| 43 | `43-openroad-stamidpnr-3` | `OpenROAD.STAMidPNR-3` | 00:00:03.724 | corrió |
| 44 | `44-openroad-detailedrouting` | `OpenROAD.DetailedRouting` | 00:00:22.864 | corrió (TritonRoute con 24 hilos) |
| 45 | `45-odb-removeroutingobstructions` | `Odb.RemoveRoutingObstructions` | 00:00:00.001 | omitido: "'ROUTING_OBSTRUCTIONS' is not defined" |
| 46 | `46-openroad-checkantennas-1` | `OpenROAD.CheckAntennas-1` | 00:00:02.415 | corrió |
| 47 | `47-checker-trdrc` | `Checker.TrDRC` | 00:00:00.000 | corrió (limpio) |
| 48 | `48-odb-reportdisconnectedpins` | `Odb.ReportDisconnectedPins` | 00:00:00.806 | corrió |
| 49 | `49-checker-disconnectedpins` | `Checker.DisconnectedPins` | 00:00:00.000 | corrió (limpio) |
| 50 | `50-odb-reportwirelength` | `Odb.ReportWireLength` | 00:00:00.605 | corrió |
| 51 | `51-checker-wirelength` | `Checker.WireLength` | 00:00:00.001 | omitido: "Threshold for Threshold-surpassing long wires is not set" (`WIRE_LENGTH_THRESHOLD` sin definir) |
| 52 | `52-openroad-fillinsertion` | `OpenROAD.FillInsertion` | 00:00:01.007 | corrió |
| 53 | `53-odb-cellfrequencytables` | `Odb.CellFrequencyTables` | 00:00:01.410 | corrió |
| 54 | `54-openroad-rcx` | `OpenROAD.RCX` | 00:00:01.228 | corrió (tres grupos: `nom_*`, `max_*`, `min_*`) |
| 55 | `55-openroad-stapostpnr` | `OpenROAD.STAPostPNR` | 00:00:09.731 | corrió (las nueve esquinas) |
| 56 | `56-openroad-irdropreport` | `OpenROAD.IRDropReport` | 00:00:07.687 | corrió (solo `nom_tt_025C_5v00`) |
| 57 | `57-magic-streamout` | `Magic.StreamOut` | 00:00:02.130 | corrió |
| 58 | `58-klayout-streamout` | `KLayout.StreamOut` | 00:00:01.408 | corrió |
| 59 | `59-klayout-render` | `KLayout.Render` | 00:00:01.308 | corrió |
| 60 | `60-magic-writelef` | `Magic.WriteLEF` | 00:00:02.114 | corrió |
| 61 | `61-odb-checkdesignantennaproperties` | `Odb.CheckDesignAntennaProperties` | 00:00:00.605 | corrió |
| 62 | `62-klayout-xor` | `KLayout.XOR` | 00:00:03.518 | corrió (24 hilos) |
| 63 | `63-checker-xor` | `Checker.XOR` | 00:00:00.001 | corrió (limpio) |
| 64 | `64-magic-drc` | `Magic.DRC` | 00:00:21.902 | corrió |
| 65 | `65-klayout-drc` | `KLayout.DRC` | 00:00:00.001 | omitido: "KLAYOUT_DRC_RUNSET is unset. KLayout.DRC may not be supported for the gf180mcuD PDK" |
| 66 | `66-checker-magicdrc` | `Checker.MagicDRC` | 00:00:00.001 | corrió (limpio) |
| 67 | `67-checker-klayoutdrc` | `Checker.KLayoutDRC` | 00:00:00.001 | corrió sin dato: "The KLayout DRC errors metric was not found" (el paso 65 fue omitido) |
| 68 | `68-magic-spiceextraction` | `Magic.SpiceExtraction` | 00:00:05.648 | corrió |
| 69 | `69-checker-illegaloverlap` | `Checker.IllegalOverlap` | 00:00:00.001 | corrió (limpio) |
| 70 | `70-netgen-lvs` | `Netgen.LVS` | 00:00:01.227 | corrió |
| 71 | `71-checker-lvs` | `Checker.LVS` | 00:00:00.001 | corrió (limpio) |
| - | sin carpeta | `Yosys.EQY` ("Equivalence Check") | - | omitido: variable de habilitación en `False` (`RUN_EQY = False`) |
| 72 | `72-checker-setupviolations` | `Checker.SetupViolations` | 00:00:00.001 | corrió: "No setup violations found" |
| 73 | `73-checker-holdviolations` | `Checker.HoldViolations` | 00:00:00.001 | corrió: "No hold violations found" |
| 74 | `74-checker-maxslewviolations` | `Checker.MaxSlewViolations` | 00:00:00.002 | corrió: lista esquinas con slew (`max_ss_125C_4v50`, `max_tt_025C_5v00`, `min_ss_125C_4v50`, `nom_ss_125C_4v50`) y concluye "No max slew violations found" al filtrar por `MAX_SLEW_VIOLATION_CORNERS = ['']` |
| 75 | `75-checker-maxcapviolations` | `Checker.MaxCapViolations` | 00:00:00.002 | corrió: lista las nueve esquinas y concluye "No max cap violations found" al filtrar por `MAX_CAP_VIOLATION_CORNERS = ['']` |
| 76 | `76-misc-reportmanufacturability` | `Misc.ReportManufacturability` | 00:00:00.001 | corrió: "klayout__drc_error__count not reported. KLayout.DRC may have been skipped" |

Los cuatro pasos sin carpeta (`OpenROAD.RepairDesignPostGRT`, `Odb.HeuristicDiodeInsertion`,
`OpenROAD.ResizerTimingPostGRT`, `Yosys.EQY`) fueron omitidos por su variable de habilitación antes
de crear directorio, por eso no tienen `runtime.txt` y aparecen con tiempo "-"
(`flow.log`, líneas 119 a 131 y 273 a 274).

Al terminar, el flujo copió las vistas a `asic/rom/runs/final/final`
(`flow.log`, última línea: "Saving views to '.../asic/rom/runs/final/final'").
