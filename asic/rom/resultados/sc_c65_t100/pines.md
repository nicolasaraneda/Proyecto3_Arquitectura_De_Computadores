# Violaciones de slew y capacitancia de `sc_c65_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_c65_t100/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 811 en 116 nets (límite 3.0 ns); de max capacitancia: 1 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| clkbuf_1/Z | 58 | 620 |
| nor2_1/ZN | 14 | 35 |
| dffrnq_1/Q | 3 | 26 |
| dffq_1/Q | 3 | 22 |
| inv_1/ZN | 3 | 21 |
| aoi22_1/ZN | 6 | 18 |
| nor4_1/ZN | 4 | 11 |
| oai21_1/ZN | 5 | 11 |
| oai222_1/ZN | 4 | 8 |
| oai32_1/ZN | 4 | 8 |
| oai211_1/ZN | 3 | 7 |
| nand4_1/ZN | 1 | 6 |
| oai31_1/ZN | 2 | 5 |
| aoi21_1/ZN | 1 | 3 |
| nor3_1/ZN | 1 | 2 |
| aoi221_1/ZN | 1 | 2 |
| oai221_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |
| aoi211_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| clkbuf_1/Z | salida | 58 |
| nor2_1/A1 | entrada | 51 |
| nand2_1/A1 | entrada | 51 |
| oai21_1/B | entrada | 46 |
| buf_2/I | entrada | 40 |
| aoi22_1/A2 | entrada | 37 |
| oai32_1/A1 | entrada | 34 |
| oai21_1/A1 | entrada | 34 |
| nand2_1/A2 | entrada | 23 |
| and3_1/A3 | entrada | 23 |
| aoi22_1/B1 | entrada | 22 |
| aoi211_1/C | entrada | 20 |
| aoi221_1/C | entrada | 19 |
| oai31_1/A1 | entrada | 18 |
| aoi22_1/B2 | entrada | 18 |
| aoi21_1/A1 | entrada | 17 |
| oai31_1/B | entrada | 16 |
| nor2_1/ZN | salida | 14 |
| mux2_2/I0 | entrada | 13 |
| icgtp_1/E | entrada | 12 |
| nor2_1/A2 | entrada | 12 |
| dffq_1/D | entrada | 10 |
| aoi21_1/B | entrada | 10 |
| aoi22_1/A1 | entrada | 10 |
| clkbuf_1/I | entrada | 10 |
| aoi21_1/A2 | entrada | 9 |
| nand3_1/A1 | entrada | 8 |
| oai211_1/A1 | entrada | 7 |
| nor3_1/A1 | entrada | 7 |
| aoi211_1/A1 | entrada | 7 |
| oai211_1/A2 | entrada | 6 |
| aoi221_1/B1 | entrada | 6 |
| aoi22_1/ZN | salida | 6 |
| oai221_1/A2 | entrada | 6 |
| nor4_1/A1 | entrada | 5 |
| aoi221_1/A2 | entrada | 5 |
| mux4_1/S1 | entrada | 5 |
| oai21_1/ZN | salida | 5 |
| nand3_1/A3 | entrada | 5 |
| aoi211_1/A2 | entrada | 5 |
| oai222_1/ZN | salida | 4 |
| oai211_1/B | entrada | 4 |
| nor4_1/ZN | salida | 4 |
| oai32_1/ZN | salida | 4 |
| oai22_1/B1 | entrada | 4 |
| oai211_1/ZN | salida | 3 |
| clkinv_1/I | entrada | 3 |
| and2_1/A2 | entrada | 3 |
| dffq_1/Q | salida | 3 |
| inv_1/ZN | salida | 3 |
| oai211_1/C | entrada | 3 |
| dffrnq_1/Q | salida | 3 |
| oai222_1/B1 | entrada | 3 |
| aoi221_1/A1 | entrada | 3 |
| mux2_2/I1 | entrada | 2 |
| aoi211_1/B | entrada | 2 |
| dffrnq_1/RN | entrada | 2 |
| nand4_1/A1 | entrada | 2 |
| oai221_1/C | entrada | 2 |
| aoi221_1/B2 | entrada | 2 |
| nand3_1/A2 | entrada | 2 |
| xor2_1/A1 | entrada | 2 |
| xor2_1/A2 | entrada | 2 |
| nor3_1/A2 | entrada | 2 |
| nand4_1/A2 | entrada | 2 |
| oai22_1/A2 | entrada | 2 |
| oai221_1/A1 | entrada | 2 |
| oai31_1/ZN | salida | 2 |
| oai21_1/A2 | entrada | 2 |
| nor3_1/ZN | salida | 1 |
| aoi221_1/ZN | salida | 1 |
| nand4_1/ZN | salida | 1 |
| mux2_2/S | entrada | 1 |
| nand3_2/A3 | entrada | 1 |
| and2_1/A1 | entrada | 1 |
| oai32_1/B2 | entrada | 1 |
| oai221_1/B2 | entrada | 1 |
| nand4_1/A4 | entrada | 1 |
| and4_1/A2 | entrada | 1 |
| oai221_1/ZN | salida | 1 |
| or2_1/A2 | entrada | 1 |
| aoi21_1/ZN | salida | 1 |
| nand4_1/A3 | entrada | 1 |
| oai221_1/B1 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| oai22_1/B2 | entrada | 1 |
| inv_1/I | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| and4_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| nor3_1/A3 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| oai31_1/A2 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 74.4 | 3.4 | 183 | 6.416 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | n/d | 78.7 | 2.4 | 176 | 4.570 ns | 3.0 |
| _1485_ | nor2_1/ZN | 3 | n/d | 68.4 | 14.8 | 179 | 4.549 ns | 3.0 |
| _0689_ | oai222_1/ZN | 1 | n/d | 50.2 | 4.8 | 73 | 4.515 ns | 3.0 |
| net472 | clkbuf_1/Z | 6 | n/d | 135.3 | 27.2 | 388 | 4.490 ns | 3.0 |
| u_soc.data_wdata[5] | dffq_1/Q | 8 | n/d | 125.0 | 36.9 | 381 | 4.473 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | n/d | 76.1 | 3.4 | 165 | 4.359 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | n/d | 41.0 | 4.1 | 93 | 4.307 ns | 3.0 |
| _0711_ | oai222_1/ZN | 1 | n/d | 46.3 | 4.8 | 102 | 4.290 ns | 3.0 |
| u_soc.u_core.u_rf/_0648_ | nor2_1/ZN | 4 | n/d | 57.7 | 20.4 | 191 | 4.283 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[1].en | nor2_1/ZN | 1 | n/d | 73.2 | 3.4 | 146 | 4.207 ns | 3.0 |
| net540 | clkbuf_1/Z | 5 | n/d | 118.5 | 30.1 | 379 | 4.111 ns | 3.0 |
| _0700_ | oai222_1/ZN | 1 | n/d | 43.1 | 4.6 | 98 | 4.087 ns | 3.0 |
| u_soc.u_core.u_rf/net423 | clkbuf_1/Z | 10 | n/d | 99.2 | 48.1 | 332 | 4.078 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[6].en | nor2_1/ZN | 1 | n/d | 70.4 | 3.4 | 121 | 4.060 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | n/d | 69.5 | 3.4 | 169 | 4.014 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | n/d | 107.8 | 36.9 | 352 | 4.004 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | n/d | 68.9 | 3.4 | 161 | 3.980 ns | 3.0 |
| _0884_ | nand4_1/ZN | 5 | n/d | 47.9 | 32.7 | 159 | 3.925 ns | 3.0 |
| _0680_ | oai222_1/ZN | 1 | n/d | 40.0 | 4.8 | 62 | 3.919 ns | 3.0 |
| net438 | clkbuf_1/Z | 10 | n/d | 96.7 | 44.6 | 307 | 3.911 ns | 3.0 |
| _0426_ | inv_1/ZN | 10 | n/d | 94.5 | 45.3 | 345 | 3.898 ns | 3.0 |
| net164 | clkbuf_1/Z | 10 | n/d | 90.6 | 49.2 | 318 | 3.874 ns | 3.0 |
| u_soc.u_core.u_rf/net220 | clkbuf_1/Z | 10 | n/d | 100.7 | 38.5 | 370 | 3.854 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | n/d | 66.4 | 3.4 | 184 | 3.850 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 150.8 | 181.7 | 539 | 0.332 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


