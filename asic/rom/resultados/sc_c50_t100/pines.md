# Violaciones de slew y capacitancia de `sc_c50_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_c50_t100/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 321 en 79 nets (límite 3.0 ns); de max capacitancia: 2 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| aoi21_1/ZN | 12 | 53 |
| dffq_1/Q | 5 | 35 |
| nor2_1/ZN | 13 | 33 |
| aoi22_1/ZN | 11 | 31 |
| inv_1/ZN | 4 | 31 |
| clkbuf_1/Z | 3 | 29 |
| nand2_1/ZN | 3 | 29 |
| dffrnq_1/Q | 2 | 20 |
| oai211_1/ZN | 4 | 14 |
| oai21_1/ZN | 6 | 13 |
| oai32_1/ZN | 4 | 8 |
| aoi221_1/ZN | 3 | 7 |
| oai222_1/ZN | 3 | 6 |
| nor3_1/ZN | 1 | 2 |
| nor4_1/ZN | 1 | 2 |
| oai221_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |
| aoi211_1/ZN | 1 | 2 |
| oai31_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| buf_2/I | entrada | 26 |
| oai21_1/A1 | entrada | 20 |
| nand2_1/A2 | entrada | 19 |
| mux2_2/I0 | entrada | 16 |
| dffrnq_1/RN | entrada | 15 |
| nor2_1/ZN | salida | 13 |
| aoi21_1/ZN | salida | 12 |
| icgtp_1/E | entrada | 11 |
| dffq_1/D | entrada | 11 |
| aoi22_1/ZN | salida | 11 |
| oai21_1/A2 | entrada | 11 |
| aoi22_1/A1 | entrada | 9 |
| nor2_1/A1 | entrada | 8 |
| nand2_1/A1 | entrada | 8 |
| aoi21_1/A1 | entrada | 8 |
| aoi22_1/B1 | entrada | 7 |
| oai21_1/ZN | salida | 6 |
| oai211_1/A2 | entrada | 6 |
| dffq_1/Q | salida | 5 |
| nor2_1/A2 | entrada | 5 |
| oai211_1/A1 | entrada | 5 |
| and2_1/A2 | entrada | 4 |
| oai211_1/ZN | salida | 4 |
| oai32_1/ZN | salida | 4 |
| inv_1/ZN | salida | 4 |
| clkbuf_1/Z | salida | 3 |
| mux2_2/I1 | entrada | 3 |
| oai222_1/ZN | salida | 3 |
| aoi221_1/ZN | salida | 3 |
| aoi211_1/B | entrada | 3 |
| clkinv_1/I | entrada | 3 |
| aoi21_1/B | entrada | 3 |
| nand2_1/ZN | salida | 3 |
| aoi211_1/A1 | entrada | 2 |
| aoi22_1/B2 | entrada | 2 |
| aoi211_1/A2 | entrada | 2 |
| dffrnq_1/Q | salida | 2 |
| nand4_1/A1 | entrada | 2 |
| and4_1/A1 | entrada | 2 |
| aoi221_1/A2 | entrada | 2 |
| oai222_1/B1 | entrada | 2 |
| nand3_1/A1 | entrada | 2 |
| nand4_1/A2 | entrada | 2 |
| nand3_1/A2 | entrada | 2 |
| nor3_1/ZN | salida | 1 |
| aoi222_1/A1 | entrada | 1 |
| nor4_1/ZN | salida | 1 |
| oai221_1/ZN | salida | 1 |
| oai22_1/B1 | entrada | 1 |
| xor2_1/A1 | entrada | 1 |
| and4_1/A2 | entrada | 1 |
| xor2_1/A2 | entrada | 1 |
| nor4_1/A1 | entrada | 1 |
| oai32_1/B2 | entrada | 1 |
| or2_1/A2 | entrada | 1 |
| and3_1/A3 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| oai21_1/B | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| oai211_1/B | entrada | 1 |
| nand3_1/A3 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| oai32_1/A2 | entrada | 1 |
| or4_1/A2 | entrada | 1 |
| oai31_1/ZN | salida | 1 |
| aoi211_1/C | entrada | 1 |
| oai22_1/A2 | entrada | 1 |
| nor3_1/A1 | entrada | 1 |
| aoi21_1/A2 | entrada | 1 |
| aoi221_1/B1 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 70.5 | 3.4 | 186 | 6.109 ns | 3.0 |
| net514 | clkbuf_1/Z | 9 | n/d | 159.4 | 43.4 | 476 | 5.579 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | n/d | 84.8 | 3.4 | 186 | 4.812 ns | 3.0 |
| net539 | clkbuf_1/Z | 7 | n/d | 124.5 | 49.6 | 403 | 4.795 ns | 3.0 |
| u_soc.data_wdata[5] | dffq_1/Q | 8 | n/d | 132.8 | 36.9 | 414 | 4.684 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | n/d | 81.4 | 3.4 | 160 | 4.633 ns | 3.0 |
| _0689_ | oai222_1/ZN | 1 | n/d | 50.6 | 4.8 | 104 | 4.538 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | n/d | 43.9 | 4.1 | 94 | 4.536 ns | 3.0 |
| _1485_ | nor2_1/ZN | 3 | n/d | 67.8 | 14.8 | 188 | 4.515 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | n/d | 79.0 | 3.4 | 174 | 4.508 ns | 3.0 |
| u_soc.u_core.lsu_addr[16] | aoi21_1/ZN | 3 | n/d | 65.9 | 13.6 | 249 | 4.507 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | n/d | 79.0 | 3.4 | 167 | 4.506 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | n/d | 64.5 | 15.1 | 176 | 4.495 ns | 3.0 |
| _0700_ | oai222_1/ZN | 1 | n/d | 50.0 | 4.6 | 98 | 4.494 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | n/d | 78.8 | 2.4 | 218 | 4.494 ns | 3.0 |
| u_soc.data_wdata[6] | dffq_1/Q | 8 | n/d | 120.8 | 36.9 | 378 | 4.352 ns | 3.0 |
| _0711_ | oai222_1/ZN | 1 | n/d | 45.3 | 4.8 | 104 | 4.229 ns | 3.0 |
| u_soc.u_core.lsu_addr[2] | aoi22_1/ZN | 3 | n/d | 56.2 | 15.2 | 181 | 4.212 ns | 3.0 |
| u_soc.u_core.u_rf/_0648_ | nor2_1/ZN | 4 | n/d | 54.8 | 20.4 | 175 | 4.134 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | n/d | 70.9 | 3.4 | 171 | 4.087 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[1].en | nor2_1/ZN | 1 | n/d | 69.6 | 3.4 | 159 | 4.018 ns | 3.0 |
| net520 | clkbuf_1/Z | 10 | n/d | 70.8 | 71.8 | 268 | 3.947 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | n/d | 103.4 | 36.9 | 337 | 3.885 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | n/d | 66.0 | 3.4 | 170 | 3.830 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | n/d | 63.6 | 2.4 | 176 | 3.778 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 158.0 | 181.7 | 566 | 0.340 pF | 0.2 |
| net514 | clkbuf_1/Z | 9 | n/d | 159.4 | 43.4 | 476 | 0.203 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


