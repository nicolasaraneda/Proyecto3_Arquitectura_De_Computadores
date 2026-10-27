# Violaciones de slew y capacitancia de `sc_sdc2_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_sdc2_t100/55-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 85 en 31 nets (límite 3.0 ns); de max capacitancia: 2 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| aoi22_1/ZN | 9 | 25 |
| nor2_1/ZN | 9 | 18 |
| dffq_1/Q | 4 | 16 |
| clkinv_1/ZN | 2 | 10 |
| oai21_1/ZN | 3 | 6 |
| aoi21_1/ZN | 2 | 6 |
| nor3_1/ZN | 1 | 2 |
| aoi211_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| buf_2/I | entrada | 12 |
| icgtp_1/E | entrada | 10 |
| nor2_1/ZN | salida | 9 |
| aoi22_1/ZN | salida | 9 |
| nand2_1/A2 | entrada | 8 |
| dffq_1/D | entrada | 4 |
| dffq_1/Q | salida | 4 |
| oai21_1/ZN | salida | 3 |
| mux2_2/I0 | entrada | 3 |
| oai222_1/B1 | entrada | 3 |
| nor2_1/A1 | entrada | 2 |
| clkinv_1/ZN | salida | 2 |
| aoi21_1/ZN | salida | 2 |
| mux2_2/I1 | entrada | 2 |
| nor3_1/ZN | salida | 1 |
| and3_1/A3 | entrada | 1 |
| oai22_1/B1 | entrada | 1 |
| aoi21_1/A1 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| aoi22_1/B1 | entrada | 1 |
| and2_1/A2 | entrada | 1 |
| oai221_1/A2 | entrada | 1 |
| oai22_1/A2 | entrada | 1 |
| nor2_1/A2 | entrada | 1 |
| aoi22_1/A1 | entrada | 1 |
| or4_1/A4 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 359 | 55.0 | 3.4 | 149 | 4.920 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | 385 | 79.0 | 3.4 | 190 | 4.510 ns | 3.0 |
| u_soc.u_core.u_rf/_0622_ | clkinv_1/ZN | 4 | 574 | 122.3 | 17.6 | 293 | 3.870 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | 363 | 65.3 | 3.4 | 172 | 3.794 ns | 3.0 |
| u_soc.u_core.u_rf/_0508_ | clkinv_1/ZN | 4 | 531 | 114.5 | 20.4 | 285 | 3.735 ns | 3.0 |
| _0650_ | aoi22_1/ZN | 2 | 218 | 51.6 | 9.6 | 113 | 3.675 ns | 3.0 |
| u_soc.u_core.rf_wdata[13] | oai21_1/ZN | 1 | 323 | 62.6 | 2.4 | 166 | 3.646 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | 368 | 61.9 | 3.4 | 157 | 3.617 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[7].en | nor2_1/ZN | 1 | 279 | 61.3 | 3.4 | 141 | 3.584 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | 351 | 61.2 | 3.4 | 158 | 3.579 ns | 3.0 |
| u_soc.data_wdata[4] | dffq_1/Q | 3 | 571 | 111.3 | 14.9 | 280 | 3.501 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | 374 | 59.6 | 3.4 | 145 | 3.497 ns | 3.0 |
| u_soc.u_core.rf_wdata[22] | aoi21_1/ZN | 1 | 285 | 57.3 | 2.4 | 143 | 3.477 ns | 3.0 |
| _2050_ | aoi211_1/ZN | 1 | 124 | 30.2 | 4.6 | 73 | 3.356 ns | 3.0 |
| _0698_ | aoi22_1/ZN | 2 | 214 | 44.8 | 9.7 | 108 | 3.325 ns | 3.0 |
| _0761_ | aoi22_1/ZN | 1 | 204 | 49.0 | 4.8 | 112 | 3.289 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[5].en | nor2_1/ZN | 1 | 286 | 55.2 | 3.4 | 134 | 3.268 ns | 3.0 |
| u_soc.data_wdata[3] | dffq_1/Q | 3 | 538 | 99.4 | 14.8 | 274 | 3.179 ns | 3.0 |
| _0678_ | aoi22_1/ZN | 2 | 194 | 41.5 | 9.7 | 100 | 3.152 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | 338 | 53.0 | 3.4 | 133 | 3.152 ns | 3.0 |
| _0721_ | aoi22_1/ZN | 2 | 221 | 43.4 | 7.4 | 115 | 3.133 ns | 3.0 |
| _0670_ | aoi22_1/ZN | 2 | 208 | 41.2 | 9.4 | 105 | 3.125 ns | 3.0 |
| _0660_ | aoi22_1/ZN | 2 | 187 | 41.1 | 9.6 | 106 | 3.122 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[2].en | nor2_1/ZN | 1 | 287 | 52.4 | 3.4 | 153 | 3.119 ns | 3.0 |
| u_soc.u_core.rf_wdata[3] | oai21_1/ZN | 1 | 291 | 52.4 | 2.4 | 164 | 3.115 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | 1105 | 159.4 | 181.7 | 565 | 0.341 pF | 0.2 |
| net948 | buf_2/Z | 9 | 895 | 159.9 | 43.4 | 487 | 0.203 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|
| max | 2564 | 187.3 | 633 | 197.1 | 0.596 | 25.7 | 0.955 | 2.91 | 2.17 |
| nom | 2564 | 165.4 | 513 | 173.4 | 0.546 | 25.6 | 0.904 | 2.57 | 1.98 |
| min | 2564 | 147.3 | 415 | 153.7 | 0.496 | 25.5 | 0.852 | 2.29 | 1.80 |

Bloque `LAYERS_RC` equivalente (tech LEF de `14-openroad-dumprcvalues/tlef_values.rpt` escalado por el factor de cada extracción, de modo que el promedio que usa el resizer coincida con la pendiente medida; unidades ohm/µm y pF/µm):

```yaml
LAYERS_RC:
  "max_*":
    Metal1: {res: 0.84780, cap: 2.6787e-04}
    Metal2: {res: 0.69640, cap: 2.4458e-04}
    Metal3: {res: 0.69640, cap: 2.2827e-04}
    Metal4: {res: 0.69640, cap: 2.2583e-04}
    Metal5: {res: 0.29544, cap: 5.0476e-05}
  "nom_*":
    Metal1: {res: 0.77655, cap: 2.3663e-04}
    Metal2: {res: 0.63788, cap: 2.1605e-04}
    Metal3: {res: 0.63788, cap: 2.0165e-04}
    Metal4: {res: 0.63788, cap: 1.9949e-04}
    Metal5: {res: 0.27062, cap: 4.4589e-05}
  "min_*":
    Metal1: {res: 0.70531, cap: 2.1068e-04}
    Metal2: {res: 0.57937, cap: 1.9236e-04}
    Metal3: {res: 0.57937, cap: 1.7953e-04}
    Metal4: {res: 0.57937, cap: 1.7761e-04}
    Metal5: {res: 0.24579, cap: 3.9699e-05}
```

