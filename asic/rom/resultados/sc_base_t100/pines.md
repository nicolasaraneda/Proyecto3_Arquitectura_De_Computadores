# Violaciones de slew y capacitancia de `sc_base_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_base_t100/55-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 327 en 83 nets (límite 3.0 ns); de max capacitancia: 1 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 18 | 60 |
| aoi21_1/ZN | 10 | 46 |
| dffq_1/Q | 5 | 35 |
| aoi22_1/ZN | 11 | 32 |
| nand2_1/ZN | 3 | 30 |
| clkinv_1/ZN | 3 | 21 |
| dffrnq_1/Q | 2 | 19 |
| oai211_1/ZN | 5 | 16 |
| oai21_1/ZN | 7 | 15 |
| oai32_1/ZN | 5 | 10 |
| aoi221_1/ZN | 3 | 7 |
| nor4_2/ZN | 1 | 6 |
| nor3_1/ZN | 2 | 6 |
| oai222_1/ZN | 3 | 6 |
| nand4_1/ZN | 1 | 6 |
| aoi211_1/ZN | 1 | 4 |
| nor4_1/ZN | 1 | 4 |
| oai221_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| buf_2/I | entrada | 29 |
| nand2_1/A2 | entrada | 23 |
| nor2_1/ZN | salida | 18 |
| mux2_2/I0 | entrada | 16 |
| oai21_1/A1 | entrada | 16 |
| dffq_1/D | entrada | 13 |
| icgtp_1/E | entrada | 12 |
| aoi22_1/ZN | salida | 11 |
| oai21_1/A2 | entrada | 11 |
| aoi21_1/ZN | salida | 10 |
| nand2_1/A1 | entrada | 10 |
| aoi22_1/A1 | entrada | 9 |
| aoi21_1/A1 | entrada | 9 |
| nor2_1/A2 | entrada | 7 |
| aoi22_1/B1 | entrada | 7 |
| oai21_1/ZN | salida | 7 |
| mux2_2/S | entrada | 5 |
| oai211_1/ZN | salida | 5 |
| dffq_1/Q | salida | 5 |
| oai21_1/B | entrada | 5 |
| oai32_1/ZN | salida | 5 |
| and2_1/A2 | entrada | 4 |
| oai211_1/A2 | entrada | 4 |
| nand3_1/A2 | entrada | 4 |
| aoi221_1/ZN | salida | 3 |
| aoi211_1/B | entrada | 3 |
| oai211_1/A1 | entrada | 3 |
| mux2_2/I1 | entrada | 3 |
| oai222_1/ZN | salida | 3 |
| nand3_1/A3 | entrada | 3 |
| nand2_1/ZN | salida | 3 |
| aoi221_1/A2 | entrada | 3 |
| oai222_1/B1 | entrada | 3 |
| clkinv_1/ZN | salida | 3 |
| nand4_1/A1 | entrada | 3 |
| nor2_1/A1 | entrada | 3 |
| clkinv_1/I | entrada | 2 |
| nor3_1/ZN | salida | 2 |
| and2_1/A1 | entrada | 2 |
| aoi21_1/A2 | entrada | 2 |
| nor3_1/A2 | entrada | 2 |
| aoi22_1/B2 | entrada | 2 |
| aoi21_1/B | entrada | 2 |
| dffrnq_1/Q | salida | 2 |
| or2_1/A2 | entrada | 2 |
| oai211_1/B | entrada | 2 |
| nor4_2/ZN | salida | 1 |
| buf_4/I | entrada | 1 |
| aoi222_1/A1 | entrada | 1 |
| oai211_1/C | entrada | 1 |
| aoi22_1/A2 | entrada | 1 |
| aoi211_1/A1 | entrada | 1 |
| nand4_1/ZN | salida | 1 |
| and4_1/A1 | entrada | 1 |
| oai221_1/ZN | salida | 1 |
| aoi222_1/B1 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| nor4_1/A1 | entrada | 1 |
| oai32_1/B2 | entrada | 1 |
| and3_1/A3 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| xor2_1/A1 | entrada | 1 |
| and4_1/A2 | entrada | 1 |
| xor2_1/A2 | entrada | 1 |
| aoi211_1/A2 | entrada | 1 |
| nor4_1/ZN | salida | 1 |
| oai22_1/A2 | entrada | 1 |
| oai22_1/B1 | entrada | 1 |
| oai32_1/A2 | entrada | 1 |
| or4_1/A2 | entrada | 1 |
| nand4_1/A2 | entrada | 1 |
| aoi221_1/B1 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| _1609_ | nor4_2/ZN | 5 | 215 | 43.2 | 51.1 | 131 | 5.486 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | 213 | 51.7 | 4.1 | 107 | 5.134 ns | 3.0 |
| u_soc.u_core.lsu_addr[16] | aoi21_1/ZN | 3 | 355 | 72.5 | 13.6 | 224 | 4.857 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 363 | 54.2 | 3.4 | 162 | 4.855 ns | 3.0 |
| _1485_ | nor2_1/ZN | 3 | 346 | 71.7 | 14.8 | 180 | 4.718 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | 393 | 79.1 | 2.4 | 238 | 4.507 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | 320 | 64.5 | 15.1 | 198 | 4.495 ns | 3.0 |
| u_soc.u_core.lsu_addr[2] | aoi22_1/ZN | 3 | 304 | 61.6 | 15.2 | 178 | 4.494 ns | 3.0 |
| u_soc.data_wdata[5] | dffq_1/Q | 8 | 677 | 122.1 | 36.9 | 390 | 4.394 ns | 3.0 |
| u_soc.u_core.u_rf/_0648_ | nor2_1/ZN | 4 | 286 | 58.8 | 20.4 | 175 | 4.340 ns | 3.0 |
| u_soc.data_wdata[6] | dffq_1/Q | 8 | 690 | 119.6 | 36.9 | 364 | 4.320 ns | 3.0 |
| _0711_ | oai222_1/ZN | 1 | 230 | 45.6 | 4.8 | 104 | 4.247 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | 358 | 71.1 | 3.4 | 171 | 4.094 ns | 3.0 |
| _0700_ | oai222_1/ZN | 1 | 216 | 42.7 | 4.6 | 108 | 4.067 ns | 3.0 |
| _0689_ | oai222_1/ZN | 1 | 227 | 41.9 | 4.8 | 103 | 4.034 ns | 3.0 |
| _1175_ | nor2_1/ZN | 5 | 202 | 48.1 | 24.6 | 181 | 4.002 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | 368 | 69.0 | 3.4 | 190 | 3.987 ns | 3.0 |
| u_soc.u_core.u_rf/_0920_ | oai32_1/ZN | 1 | 136 | 33.9 | 2.4 | 69 | 3.960 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | 402 | 65.8 | 2.4 | 177 | 3.915 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | 367 | 67.3 | 3.4 | 174 | 3.899 ns | 3.0 |
| _0884_ | nand4_1/ZN | 5 | 267 | 52.8 | 27.0 | 205 | 3.891 ns | 3.0 |
| _0925_ | aoi21_1/ZN | 4 | 204 | 47.3 | 20.2 | 159 | 3.886 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | 602 | 102.2 | 36.9 | 339 | 3.851 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | 376 | 65.6 | 3.4 | 168 | 3.809 ns | 3.0 |
| u_soc.u_core.rf_wdata[13] | oai21_1/ZN | 1 | 322 | 65.1 | 2.4 | 156 | 3.790 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | 1095 | 156.2 | 181.7 | 626 | 0.338 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|
| max | 2386 | 186.1 | 791 | 196.7 | 0.592 | 27.3 | 0.951 | 2.89 | 2.15 |
| nom | 2386 | 164.4 | 646 | 173.3 | 0.542 | 27.2 | 0.900 | 2.56 | 1.97 |
| min | 2386 | 146.4 | 525 | 153.8 | 0.491 | 27.1 | 0.848 | 2.28 | 1.79 |

Bloque `LAYERS_RC` equivalente (tech LEF de `14-openroad-dumprcvalues/tlef_values.rpt` escalado por el factor de cada extracción, de modo que el promedio que usa el resizer coincida con la pendiente medida; unidades ohm/µm y pF/µm):

```yaml
LAYERS_RC:
  "max_*":
    Metal1: {res: 0.84192, cap: 2.6617e-04}
    Metal2: {res: 0.69157, cap: 2.4303e-04}
    Metal3: {res: 0.69157, cap: 2.2683e-04}
    Metal4: {res: 0.69157, cap: 2.2440e-04}
    Metal5: {res: 0.29339, cap: 5.0156e-05}
  "nom_*":
    Metal1: {res: 0.77035, cap: 2.3518e-04}
    Metal2: {res: 0.63279, cap: 2.1473e-04}
    Metal3: {res: 0.63279, cap: 2.0041e-04}
    Metal4: {res: 0.63279, cap: 1.9826e-04}
    Metal5: {res: 0.26846, cap: 4.4315e-05}
  "min_*":
    Metal1: {res: 0.69879, cap: 2.0943e-04}
    Metal2: {res: 0.57401, cap: 1.9122e-04}
    Metal3: {res: 0.57401, cap: 1.7847e-04}
    Metal4: {res: 0.57401, cap: 1.7656e-04}
    Metal5: {res: 0.24352, cap: 3.9464e-05}
```

