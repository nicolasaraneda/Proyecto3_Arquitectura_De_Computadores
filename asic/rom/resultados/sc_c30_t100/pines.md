# Violaciones de slew y capacitancia de `sc_c30_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_c30_t100/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 323 en 79 nets (límite 3.0 ns); de max capacitancia: 1 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 17 | 55 |
| aoi21_1/ZN | 9 | 41 |
| dffrnq_1/Q | 4 | 39 |
| dffq_1/Q | 5 | 35 |
| nand2_1/ZN | 3 | 30 |
| aoi22_1/ZN | 8 | 24 |
| oai211_1/ZN | 5 | 16 |
| oai21_1/ZN | 6 | 13 |
| inv_1/ZN | 1 | 11 |
| clkinv_1/ZN | 2 | 10 |
| oai32_1/ZN | 4 | 8 |
| aoi221_1/ZN | 3 | 7 |
| nor3_1/ZN | 2 | 6 |
| oai222_1/ZN | 3 | 6 |
| nand4_1/ZN | 1 | 6 |
| nor4_1/ZN | 2 | 6 |
| aoi211_1/ZN | 2 | 6 |
| oai221_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| buf_2/I | entrada | 29 |
| nand2_1/A2 | entrada | 18 |
| oai21_1/A1 | entrada | 18 |
| nor2_1/ZN | salida | 17 |
| mux2_2/I0 | entrada | 16 |
| icgtp_1/E | entrada | 12 |
| nand2_1/A1 | entrada | 11 |
| aoi22_1/A1 | entrada | 11 |
| dffq_1/D | entrada | 11 |
| aoi21_1/A1 | entrada | 10 |
| nor2_1/A2 | entrada | 9 |
| aoi21_1/ZN | salida | 9 |
| oai21_1/A2 | entrada | 9 |
| aoi22_1/ZN | salida | 8 |
| aoi22_1/B1 | entrada | 6 |
| oai21_1/ZN | salida | 6 |
| dffq_1/Q | salida | 5 |
| oai211_1/ZN | salida | 5 |
| oai21_1/B | entrada | 5 |
| and2_1/A2 | entrada | 4 |
| oai211_1/A2 | entrada | 4 |
| oai32_1/ZN | salida | 4 |
| nor2_1/A1 | entrada | 4 |
| dffrnq_1/Q | salida | 4 |
| nand3_1/A2 | entrada | 4 |
| mux2_2/I1 | entrada | 3 |
| aoi221_1/ZN | salida | 3 |
| aoi211_1/B | entrada | 3 |
| oai222_1/ZN | salida | 3 |
| oai211_1/A1 | entrada | 3 |
| nand3_1/A3 | entrada | 3 |
| and2_1/A1 | entrada | 3 |
| nand2_1/ZN | salida | 3 |
| and4_1/A1 | entrada | 3 |
| aoi221_1/A2 | entrada | 3 |
| nand4_1/A1 | entrada | 3 |
| oai222_1/B1 | entrada | 3 |
| nor3_1/ZN | salida | 2 |
| clkinv_1/I | entrada | 2 |
| nor4_1/ZN | salida | 2 |
| aoi21_1/B | entrada | 2 |
| aoi211_1/ZN | salida | 2 |
| clkinv_1/ZN | salida | 2 |
| xor2_1/A2 | entrada | 2 |
| nor3_1/A2 | entrada | 2 |
| aoi22_1/B2 | entrada | 2 |
| oai211_1/B | entrada | 2 |
| or2_1/A2 | entrada | 2 |
| aoi222_1/A1 | entrada | 1 |
| oai211_1/C | entrada | 1 |
| aoi22_1/A2 | entrada | 1 |
| aoi211_1/A1 | entrada | 1 |
| nand4_1/ZN | salida | 1 |
| mux2_2/S | entrada | 1 |
| oai221_1/ZN | salida | 1 |
| aoi222_1/ZN | salida | 1 |
| oai31_1/A2 | entrada | 1 |
| nor4_1/A1 | entrada | 1 |
| oai32_1/B2 | entrada | 1 |
| inv_1/ZN | salida | 1 |
| and3_1/A3 | entrada | 1 |
| xor2_1/A1 | entrada | 1 |
| and4_1/A2 | entrada | 1 |
| aoi211_1/A2 | entrada | 1 |
| aoi21_1/A2 | entrada | 1 |
| aoi222_1/B1 | entrada | 1 |
| oai22_1/A2 | entrada | 1 |
| oai32_1/A2 | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| nand3_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| oai22_1/B1 | entrada | 1 |
| or4_1/A2 | entrada | 1 |
| nand4_1/A2 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 70.0 | 3.4 | 193 | 6.077 ns | 3.0 |
| u_soc.data_wdata[5] | dffq_1/Q | 8 | n/d | 142.7 | 36.9 | 418 | 4.953 ns | 3.0 |
| u_soc.u_core.lsu_addr[16] | aoi21_1/ZN | 3 | n/d | 70.9 | 13.6 | 207 | 4.770 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | n/d | 81.1 | 3.4 | 189 | 4.616 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | n/d | 44.9 | 4.1 | 97 | 4.610 ns | 3.0 |
| _1485_ | nor2_1/ZN | 3 | n/d | 69.0 | 14.8 | 189 | 4.577 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | n/d | 79.2 | 3.4 | 178 | 4.519 ns | 3.0 |
| _0711_ | oai222_1/ZN | 1 | n/d | 49.4 | 4.8 | 104 | 4.472 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | n/d | 63.3 | 15.1 | 178 | 4.430 ns | 3.0 |
| u_soc.u_core.lsu_addr[2] | aoi22_1/ZN | 3 | n/d | 58.7 | 15.2 | 182 | 4.340 ns | 3.0 |
| u_soc.u_core.u_rf/_0648_ | nor2_1/ZN | 4 | n/d | 57.4 | 20.4 | 176 | 4.271 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | n/d | 74.2 | 2.4 | 217 | 4.254 ns | 3.0 |
| _0700_ | oai222_1/ZN | 1 | n/d | 45.8 | 4.6 | 99 | 4.249 ns | 3.0 |
| u_soc.data_wdata[6] | dffq_1/Q | 8 | n/d | 116.0 | 36.9 | 354 | 4.224 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | n/d | 73.4 | 3.4 | 194 | 4.214 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | n/d | 73.0 | 3.4 | 174 | 4.194 ns | 3.0 |
| u_soc.u_core.lsu_addr[15] | oai21_1/ZN | 2 | n/d | 64.6 | 10.1 | 190 | 4.152 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | n/d | 70.4 | 2.4 | 176 | 4.148 ns | 3.0 |
| _0689_ | oai222_1/ZN | 1 | n/d | 43.4 | 4.8 | 103 | 4.122 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | n/d | 71.2 | 3.4 | 161 | 4.103 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | n/d | 106.6 | 36.9 | 337 | 3.971 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | n/d | 67.7 | 3.4 | 178 | 3.921 ns | 3.0 |
| _0847_ | nor2_1/ZN | 3 | n/d | 55.8 | 15.3 | 163 | 3.921 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[6].en | nor2_1/ZN | 1 | n/d | 67.7 | 3.4 | 134 | 3.918 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | n/d | 67.7 | 3.4 | 158 | 3.917 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 156.7 | 181.7 | 548 | 0.338 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


