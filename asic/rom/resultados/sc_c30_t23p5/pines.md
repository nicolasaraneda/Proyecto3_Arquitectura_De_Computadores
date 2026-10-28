# Violaciones de slew y capacitancia de `sc_c30_t23p5`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_c30_t23p5/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 323 en 82 nets (límite 3.0 ns); de max capacitancia: 1 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 19 | 60 |
| nand2_1/ZN | 4 | 40 |
| aoi21_1/ZN | 8 | 35 |
| dffq_1/Q | 5 | 33 |
| aoi22_1/ZN | 11 | 31 |
| dffrnq_1/Q | 3 | 29 |
| oai211_1/ZN | 5 | 16 |
| oai21_1/ZN | 6 | 13 |
| inv_1/ZN | 1 | 11 |
| clkinv_1/ZN | 2 | 10 |
| oai32_1/ZN | 4 | 8 |
| aoi221_1/ZN | 3 | 7 |
| nor3_1/ZN | 2 | 6 |
| oai222_1/ZN | 3 | 6 |
| nand4_1/ZN | 1 | 6 |
| aoi211_1/ZN | 2 | 6 |
| oai221_1/ZN | 1 | 2 |
| nor4_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| buf_2/I | entrada | 25 |
| nor2_1/ZN | salida | 19 |
| nand2_1/A2 | entrada | 19 |
| mux2_2/I0 | entrada | 15 |
| icgtp_1/E | entrada | 14 |
| nand2_1/A1 | entrada | 12 |
| aoi22_1/ZN | salida | 11 |
| dffq_1/D | entrada | 11 |
| oai21_1/A1 | entrada | 11 |
| aoi22_1/A1 | entrada | 9 |
| aoi21_1/A1 | entrada | 9 |
| oai21_1/A2 | entrada | 9 |
| aoi21_1/ZN | salida | 8 |
| aoi22_1/B1 | entrada | 8 |
| nor2_1/A2 | entrada | 7 |
| nor2_1/A1 | entrada | 7 |
| oai21_1/ZN | salida | 6 |
| oai211_1/A2 | entrada | 6 |
| dffq_1/Q | salida | 5 |
| oai211_1/ZN | salida | 5 |
| oai21_1/B | entrada | 5 |
| nand3_1/A2 | entrada | 5 |
| aoi211_1/B | entrada | 4 |
| oai32_1/ZN | salida | 4 |
| nand2_1/ZN | salida | 4 |
| clkinv_1/I | entrada | 3 |
| oai211_1/A1 | entrada | 3 |
| and2_1/A2 | entrada | 3 |
| mux2_2/I1 | entrada | 3 |
| oai222_1/ZN | salida | 3 |
| aoi221_1/ZN | salida | 3 |
| dffrnq_1/Q | salida | 3 |
| oai222_1/B1 | entrada | 3 |
| nor3_1/ZN | salida | 2 |
| and4_1/A1 | entrada | 2 |
| and4_1/A2 | entrada | 2 |
| aoi211_1/A2 | entrada | 2 |
| aoi211_1/ZN | salida | 2 |
| clkinv_1/ZN | salida | 2 |
| nand4_1/A1 | entrada | 2 |
| aoi21_1/B | entrada | 2 |
| aoi22_1/B2 | entrada | 2 |
| nand3_1/A1 | entrada | 2 |
| aoi21_1/A2 | entrada | 2 |
| or2_1/A2 | entrada | 2 |
| nor2_4/A1 | entrada | 1 |
| aoi222_1/A1 | entrada | 1 |
| nand4_1/ZN | salida | 1 |
| mux2_2/S | entrada | 1 |
| nand3_1/A3 | entrada | 1 |
| and2_1/A1 | entrada | 1 |
| oai211_1/C | entrada | 1 |
| aoi22_1/A2 | entrada | 1 |
| aoi211_1/A1 | entrada | 1 |
| aoi221_1/A2 | entrada | 1 |
| xor2_1/A1 | entrada | 1 |
| xor2_1/A2 | entrada | 1 |
| oai221_1/ZN | salida | 1 |
| nor4_1/A1 | entrada | 1 |
| oai32_1/B2 | entrada | 1 |
| inv_1/ZN | salida | 1 |
| aoi222_1/B1 | entrada | 1 |
| oai22_1/A2 | entrada | 1 |
| nor4_1/ZN | salida | 1 |
| oai31_1/A2 | entrada | 1 |
| and3_1/A3 | entrada | 1 |
| or4_2/A2 | entrada | 1 |
| nand4_1/A2 | entrada | 1 |
| oai211_1/B | entrada | 1 |
| aoi22_2/A1 | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| aoi221_1/C | entrada | 1 |
| oai33_1/A1 | entrada | 1 |
| nor3_1/A2 | entrada | 1 |
| aoi221_1/B1 | entrada | 1 |
| oai32_1/A2 | entrada | 1 |
| aoi22_4/A1 | entrada | 1 |
| xnor2_1/A2 | entrada | 1 |
| or4_2/A4 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| aoi22_2/B1 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 75.7 | 3.4 | 165 | 6.510 ns | 3.0 |
| u_soc.u_core.lsu_addr[16] | aoi21_1/ZN | 3 | n/d | 72.2 | 27.4 | 206 | 5.563 ns | 3.0 |
| u_soc.u_core.lsu_addr[2] | aoi22_1/ZN | 3 | n/d | 69.5 | 15.2 | 174 | 4.903 ns | 3.0 |
| u_soc.data_wdata[5] | dffq_1/Q | 8 | n/d | 139.9 | 36.9 | 375 | 4.879 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | n/d | 70.1 | 15.1 | 175 | 4.785 ns | 3.0 |
| _0711_ | oai222_1/ZN | 1 | n/d | 52.4 | 4.8 | 105 | 4.649 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | n/d | 81.1 | 3.4 | 201 | 4.615 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | n/d | 77.5 | 2.4 | 183 | 4.423 ns | 3.0 |
| u_soc.data_wdata[6] | dffq_1/Q | 8 | n/d | 122.2 | 36.9 | 354 | 4.394 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | n/d | 76.6 | 3.4 | 168 | 4.381 ns | 3.0 |
| u_soc.u_core.u_rf/_0648_ | nor2_1/ZN | 4 | n/d | 59.1 | 20.4 | 175 | 4.360 ns | 3.0 |
| _0689_ | oai222_1/ZN | 1 | n/d | 46.8 | 4.8 | 104 | 4.323 ns | 3.0 |
| _0700_ | oai222_1/ZN | 1 | n/d | 46.4 | 4.6 | 101 | 4.283 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | n/d | 74.0 | 3.4 | 162 | 4.246 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | n/d | 40.0 | 4.1 | 97 | 4.237 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | n/d | 73.4 | 3.4 | 162 | 4.218 ns | 3.0 |
| _1485_ | nor2_1/ZN | 3 | n/d | 62.0 | 14.8 | 176 | 4.211 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | n/d | 71.4 | 3.4 | 174 | 4.113 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | n/d | 71.0 | 3.4 | 170 | 4.090 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | n/d | 68.3 | 3.4 | 179 | 3.949 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | n/d | 67.7 | 3.4 | 173 | 3.918 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | n/d | 66.0 | 2.4 | 177 | 3.916 ns | 3.0 |
| u_soc.u_core.lsu_addr[15] | oai21_1/ZN | 2 | n/d | 58.9 | 10.1 | 192 | 3.855 ns | 3.0 |
| u_soc.u_core.rf_wdata[4] | oai21_1/ZN | 1 | n/d | 66.5 | 2.4 | 172 | 3.850 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[1].en | nor2_1/ZN | 1 | n/d | 66.1 | 3.4 | 180 | 3.833 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 159.4 | 181.7 | 606 | 0.341 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


