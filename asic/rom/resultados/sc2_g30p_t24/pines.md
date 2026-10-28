# Violaciones de slew y capacitancia de `sc2_g30p_t24`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc2_g30p_t24/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 191 en 53 nets (límite 3.0 ns); de max capacitancia: 1 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 14 | 33 |
| nand2_1/ZN | 3 | 30 |
| dffq_1/Q | 4 | 21 |
| dffrnq_1/Q | 2 | 20 |
| aoi21_1/ZN | 4 | 19 |
| aoi22_1/ZN | 5 | 15 |
| oai21_1/ZN | 6 | 13 |
| clkinv_1/ZN | 2 | 10 |
| oai211_1/ZN | 3 | 9 |
| nor3_1/ZN | 2 | 4 |
| aoi221_1/ZN | 2 | 4 |
| nor4_1/ZN | 1 | 3 |
| oai222_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |
| aoi211_1/ZN | 1 | 2 |
| oai32_1/ZN | 1 | 2 |
| oai31_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| nor2_1/ZN | salida | 14 |
| icgtp_1/E | entrada | 13 |
| buf_2/I | entrada | 12 |
| nand2_1/A2 | entrada | 10 |
| nand2_1/A1 | entrada | 9 |
| dffq_1/D | entrada | 8 |
| mux2_2/I0 | entrada | 7 |
| oai21_1/A1 | entrada | 7 |
| oai21_1/ZN | salida | 6 |
| aoi22_1/A1 | entrada | 6 |
| aoi21_1/A1 | entrada | 6 |
| oai211_1/A2 | entrada | 5 |
| aoi22_1/ZN | salida | 5 |
| aoi211_1/B | entrada | 4 |
| dffq_1/Q | salida | 4 |
| oai21_1/A2 | entrada | 4 |
| aoi21_1/ZN | salida | 4 |
| nor2_1/A1 | entrada | 4 |
| oai211_1/ZN | salida | 3 |
| nor2_1/A2 | entrada | 3 |
| nand2_1/ZN | salida | 3 |
| aoi221_1/A2 | entrada | 3 |
| antenna/I | entrada | 3 |
| nor3_1/ZN | salida | 2 |
| aoi221_1/ZN | salida | 2 |
| oai222_1/B1 | entrada | 2 |
| dffrnq_1/Q | salida | 2 |
| oai211_1/A1 | entrada | 2 |
| and4_1/A1 | entrada | 2 |
| nand3_1/A2 | entrada | 2 |
| clkinv_1/ZN | salida | 2 |
| nand3_1/A1 | entrada | 2 |
| oai21_1/B | entrada | 2 |
| and2_1/A2 | entrada | 1 |
| mux2_2/I1 | entrada | 1 |
| oai222_1/ZN | salida | 1 |
| aoi22_1/B1 | entrada | 1 |
| xor2_1/A1 | entrada | 1 |
| and4_1/A2 | entrada | 1 |
| xor2_1/A2 | entrada | 1 |
| aoi211_1/A2 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| or4_2/A2 | entrada | 1 |
| oai211_1/B | entrada | 1 |
| aoi22_1/B2 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| oai221_1/A2 | entrada | 1 |
| nand3_4/A3 | entrada | 1 |
| nand3_4/A2 | entrada | 1 |
| and3_1/A3 | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| oai32_1/ZN | salida | 1 |
| oai31_1/ZN | salida | 1 |
| aoi211_1/C | entrada | 1 |
| aoi21_1/B | entrada | 1 |
| oai32_1/A2 | entrada | 1 |
| clkinv_1/I | entrada | 1 |
| nor4_1/ZN | salida | 1 |
| aoi221_1/C | entrada | 1 |
| oai33_1/A1 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 66.0 | 3.4 | 182 | 5.763 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | n/d | 43.6 | 4.1 | 91 | 4.507 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | n/d | 78.2 | 3.4 | 167 | 4.466 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | n/d | 76.3 | 2.4 | 180 | 4.363 ns | 3.0 |
| u_soc.u_core.rf_we | nor3_1/ZN | 1 | n/d | 45.6 | 5.1 | 132 | 4.332 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | n/d | 58.4 | 15.1 | 164 | 4.178 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | n/d | 72.2 | 3.4 | 173 | 4.152 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | n/d | 72.1 | 3.4 | 182 | 4.147 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | n/d | 64.7 | 2.4 | 176 | 3.847 ns | 3.0 |
| u_soc.u_core.lsu_addr[15] | oai21_1/ZN | 2 | n/d | 58.1 | 10.1 | 197 | 3.816 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | n/d | 100.0 | 36.9 | 339 | 3.793 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | n/d | 65.2 | 3.4 | 160 | 3.791 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | n/d | 65.1 | 3.4 | 154 | 3.782 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[3].en | nor2_1/ZN | 1 | n/d | 63.2 | 3.4 | 130 | 3.684 ns | 3.0 |
| _0680_ | oai222_1/ZN | 1 | n/d | 35.2 | 4.8 | 62 | 3.639 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[6].en | nor2_1/ZN | 1 | n/d | 61.8 | 3.4 | 148 | 3.609 ns | 3.0 |
| _0709_ | aoi22_1/ZN | 2 | n/d | 47.9 | 9.7 | 119 | 3.485 ns | 3.0 |
| u_soc.u_core.pc_id[16] | dffrnq_1/Q | 8 | n/d | 82.2 | 42.3 | 286 | 3.478 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | n/d | 58.6 | 3.4 | 160 | 3.444 ns | 3.0 |
| _1097_ | nand2_1/ZN | 8 | n/d | 74.7 | 35.8 | 275 | 3.411 ns | 3.0 |
| _0782_ | aoi222_1/ZN | 1 | n/d | 21.6 | 5.1 | 73 | 3.358 ns | 3.0 |
| u_soc.u_core.lsu_wdata[13] | dffq_1/Q | 3 | n/d | 106.4 | 14.5 | 237 | 3.357 ns | 3.0 |
| u_soc.u_core.lsu_addr[4] | aoi21_1/ZN | 3 | n/d | 43.1 | 14.1 | 126 | 3.347 ns | 3.0 |
| u_soc.u_core.rf_wdata[3] | oai21_1/ZN | 1 | n/d | 56.2 | 2.4 | 147 | 3.341 ns | 3.0 |
| _0943_ | aoi21_1/ZN | 4 | n/d | 36.3 | 20.2 | 106 | 3.315 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 151.2 | 181.7 | 528 | 0.333 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


