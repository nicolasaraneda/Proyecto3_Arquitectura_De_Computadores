# Violaciones de slew y capacitancia de `sc_c30_t24`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_c30_t24/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 342 en 84 nets (límite 3.0 ns); de max capacitancia: 2 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 20 | 61 |
| nand2_1/ZN | 5 | 48 |
| aoi21_1/ZN | 9 | 40 |
| aoi22_1/ZN | 12 | 35 |
| dffrnq_1/Q | 4 | 35 |
| dffq_1/Q | 4 | 31 |
| oai211_1/ZN | 5 | 17 |
| oai21_1/ZN | 5 | 11 |
| inv_1/ZN | 1 | 11 |
| clkinv_1/ZN | 2 | 10 |
| oai222_1/ZN | 4 | 8 |
| oai32_1/ZN | 4 | 8 |
| aoi221_1/ZN | 3 | 7 |
| nor3_1/ZN | 2 | 6 |
| nand4_1/ZN | 1 | 6 |
| aoi211_1/ZN | 1 | 4 |
| oai221_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| buf_2/I | entrada | 27 |
| nor2_1/ZN | salida | 20 |
| nand2_1/A2 | entrada | 19 |
| mux2_2/I0 | entrada | 16 |
| icgtp_1/E | entrada | 15 |
| nand2_1/A1 | entrada | 14 |
| oai21_1/A1 | entrada | 14 |
| aoi22_1/ZN | salida | 12 |
| aoi21_1/A1 | entrada | 11 |
| aoi22_1/A1 | entrada | 11 |
| dffq_1/D | entrada | 10 |
| oai21_1/A2 | entrada | 10 |
| aoi21_1/ZN | salida | 9 |
| aoi22_1/B1 | entrada | 7 |
| nor2_1/A2 | entrada | 7 |
| oai211_1/A2 | entrada | 6 |
| nand3_1/A2 | entrada | 6 |
| and2_1/A2 | entrada | 5 |
| oai21_1/ZN | salida | 5 |
| oai211_1/ZN | salida | 5 |
| oai21_1/B | entrada | 5 |
| nand2_1/ZN | salida | 5 |
| nor2_1/A1 | entrada | 5 |
| dffq_1/Q | salida | 4 |
| oai211_1/A1 | entrada | 4 |
| oai222_1/ZN | salida | 4 |
| oai32_1/ZN | salida | 4 |
| dffrnq_1/Q | salida | 4 |
| oai222_1/B1 | entrada | 4 |
| clkinv_1/I | entrada | 3 |
| aoi221_1/ZN | salida | 3 |
| aoi211_1/B | entrada | 3 |
| mux2_2/I1 | entrada | 3 |
| nand3_1/A1 | entrada | 3 |
| aoi222_1/A1 | entrada | 2 |
| nor3_1/ZN | salida | 2 |
| nand3_1/A3 | entrada | 2 |
| and4_1/A1 | entrada | 2 |
| nand4_1/A1 | entrada | 2 |
| aoi21_1/B | entrada | 2 |
| and4_1/A2 | entrada | 2 |
| xor2_1/A2 | entrada | 2 |
| aoi211_1/A2 | entrada | 2 |
| clkinv_1/ZN | salida | 2 |
| aoi21_1/A2 | entrada | 2 |
| aoi22_1/B2 | entrada | 2 |
| nand4_1/A2 | entrada | 2 |
| oai211_1/B | entrada | 2 |
| or2_1/A2 | entrada | 2 |
| aoi22_2/A1 | entrada | 2 |
| nor2_4/A1 | entrada | 1 |
| oai211_1/C | entrada | 1 |
| aoi22_1/A2 | entrada | 1 |
| aoi211_1/A1 | entrada | 1 |
| mux2_2/S | entrada | 1 |
| nand4_1/ZN | salida | 1 |
| and2_1/A1 | entrada | 1 |
| aoi221_1/A2 | entrada | 1 |
| nor4_1/A1 | entrada | 1 |
| oai32_1/B2 | entrada | 1 |
| inv_1/ZN | salida | 1 |
| oai221_1/ZN | salida | 1 |
| or4_2/A2 | entrada | 1 |
| xor2_1/A1 | entrada | 1 |
| and3_1/A3 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| nor3_1/A2 | entrada | 1 |
| oai22_1/B1 | entrada | 1 |
| oai22_1/A2 | entrada | 1 |
| aoi222_1/B1 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| oai22_1/A1 | entrada | 1 |
| or4_2/A4 | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| oai32_1/A2 | entrada | 1 |
| xnor2_1/A2 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.lsu_addr[16] | aoi21_1/ZN | 3 | n/d | 77.6 | 27.4 | 222 | 5.847 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 64.0 | 3.4 | 173 | 5.607 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | n/d | 51.1 | 4.1 | 107 | 5.087 ns | 3.0 |
| u_soc.data_wdata[5] | dffq_1/Q | 8 | n/d | 139.0 | 36.9 | 434 | 4.852 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | n/d | 83.7 | 3.4 | 178 | 4.755 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | n/d | 82.9 | 2.4 | 214 | 4.706 ns | 3.0 |
| u_soc.u_core.lsu_addr[2] | aoi22_1/ZN | 3 | n/d | 65.6 | 15.2 | 190 | 4.700 ns | 3.0 |
| _1485_ | nor2_1/ZN | 3 | n/d | 68.3 | 14.8 | 176 | 4.544 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | n/d | 65.1 | 15.1 | 189 | 4.526 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | n/d | 76.6 | 3.4 | 193 | 4.384 ns | 3.0 |
| u_soc.u_core.u_rf/_0648_ | nor2_1/ZN | 4 | n/d | 57.4 | 20.4 | 175 | 4.267 ns | 3.0 |
| u_soc.data_wdata[6] | dffq_1/Q | 8 | n/d | 115.9 | 36.9 | 363 | 4.221 ns | 3.0 |
| _0711_ | oai222_1/ZN | 1 | n/d | 44.4 | 4.8 | 115 | 4.183 ns | 3.0 |
| _0700_ | oai222_1/ZN | 1 | n/d | 44.5 | 4.6 | 100 | 4.171 ns | 3.0 |
| _0689_ | oai222_1/ZN | 1 | n/d | 43.9 | 4.8 | 104 | 4.151 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | n/d | 110.2 | 36.9 | 343 | 4.070 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[6].en | nor2_1/ZN | 1 | n/d | 70.5 | 3.4 | 147 | 4.067 ns | 3.0 |
| _1175_ | nor2_1/ZN | 5 | n/d | 48.6 | 24.6 | 172 | 4.030 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | n/d | 69.3 | 3.4 | 173 | 4.000 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | n/d | 68.8 | 3.4 | 161 | 3.978 ns | 3.0 |
| u_soc.u_core.lsu_addr[15] | oai21_1/ZN | 2 | n/d | 60.4 | 10.1 | 179 | 3.932 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | n/d | 67.3 | 3.4 | 174 | 3.898 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | n/d | 65.5 | 2.4 | 178 | 3.896 ns | 3.0 |
| _0884_ | nand4_1/ZN | 5 | n/d | 50.4 | 27.0 | 201 | 3.782 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | n/d | 63.8 | 3.4 | 166 | 3.717 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 155.0 | 181.7 | 579 | 0.337 pF | 0.2 |
| net514 | buf_2/Z | 9 | n/d | 156.9 | 43.4 | 489 | 0.200 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


