# Violaciones de slew y capacitancia de `sc_j30_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_j30_t100/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 214 en 64 nets (límite 3.0 ns); de max capacitancia: 1 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 16 | 40 |
| aoi21_1/ZN | 8 | 32 |
| dffq_1/Q | 4 | 21 |
| aoi22_1/ZN | 8 | 21 |
| nand2_1/ZN | 2 | 20 |
| dffrnq_1/Q | 2 | 20 |
| oai211_1/ZN | 4 | 14 |
| oai21_1/ZN | 6 | 13 |
| nor4_1/ZN | 2 | 6 |
| clkinv_1/ZN | 1 | 5 |
| nor3_1/ZN | 2 | 4 |
| aoi221_1/ZN | 2 | 4 |
| oai222_1/ZN | 1 | 2 |
| oai32_1/ZN | 1 | 2 |
| oai221_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |
| oai31_1/ZN | 1 | 2 |
| aoi211_1/ZN | 1 | 2 |
| nor4_2/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| nand2_1/A2 | entrada | 18 |
| nor2_1/ZN | salida | 16 |
| icgtp_1/E | entrada | 14 |
| buf_2/I | entrada | 13 |
| dffq_1/D | entrada | 8 |
| aoi22_1/A1 | entrada | 8 |
| aoi21_1/ZN | salida | 8 |
| aoi22_1/ZN | salida | 8 |
| mux2_2/I0 | entrada | 7 |
| oai21_1/A1 | entrada | 7 |
| nand2_1/A1 | entrada | 6 |
| oai21_1/ZN | salida | 6 |
| aoi21_1/A1 | entrada | 6 |
| oai21_1/A2 | entrada | 5 |
| oai211_1/ZN | salida | 4 |
| dffq_1/Q | salida | 4 |
| aoi22_1/B1 | entrada | 4 |
| nor2_1/A1 | entrada | 4 |
| oai211_1/A2 | entrada | 3 |
| nand3_1/A2 | entrada | 3 |
| nor2_1/A2 | entrada | 3 |
| aoi221_1/A2 | entrada | 3 |
| nor3_1/ZN | salida | 2 |
| aoi221_1/ZN | salida | 2 |
| aoi211_1/B | entrada | 2 |
| and2_1/A2 | entrada | 2 |
| oai222_1/B1 | entrada | 2 |
| oai211_1/B | entrada | 2 |
| nand2_1/ZN | salida | 2 |
| aoi22_1/B2 | entrada | 2 |
| oai21_1/B | entrada | 2 |
| or2_1/A2 | entrada | 2 |
| and4_1/A1 | entrada | 2 |
| dffrnq_1/Q | salida | 2 |
| nor4_1/ZN | salida | 2 |
| nand3_1/A1 | entrada | 2 |
| mux2_2/I1 | entrada | 1 |
| oai222_1/ZN | salida | 1 |
| or4_1/A2 | entrada | 1 |
| oai32_1/ZN | salida | 1 |
| oai221_1/ZN | salida | 1 |
| aoi221_1/B1 | entrada | 1 |
| oai211_1/A1 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| oai221_1/A2 | entrada | 1 |
| oai31_1/ZN | salida | 1 |
| aoi211_1/C | entrada | 1 |
| clkinv_1/I | entrada | 1 |
| xor2_1/A1 | entrada | 1 |
| and4_1/A2 | entrada | 1 |
| xor2_1/A2 | entrada | 1 |
| aoi211_1/A2 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| and3_1/A3 | entrada | 1 |
| clkinv_1/ZN | salida | 1 |
| nand4_1/A2 | entrada | 1 |
| nand3_1/A3 | entrada | 1 |
| oai22_1/B1 | entrada | 1 |
| oai33_1/A1 | entrada | 1 |
| aoi221_1/C | entrada | 1 |
| aoi21_1/A2 | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| nor4_2/ZN | salida | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 71.5 | 3.4 | 182 | 6.191 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | n/d | 81.0 | 2.4 | 187 | 4.690 ns | 3.0 |
| u_soc.u_core.rf_we | nor3_1/ZN | 1 | n/d | 49.3 | 5.1 | 121 | 4.611 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | n/d | 74.8 | 3.4 | 169 | 4.289 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | n/d | 72.8 | 3.4 | 181 | 4.183 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | n/d | 70.8 | 3.4 | 189 | 4.081 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | n/d | 37.9 | 4.1 | 93 | 4.069 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | n/d | 70.3 | 3.4 | 173 | 4.056 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | n/d | 70.3 | 3.4 | 165 | 4.054 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | n/d | 70.0 | 3.4 | 183 | 4.041 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | n/d | 55.6 | 15.1 | 169 | 4.031 ns | 3.0 |
| u_soc.u_core.lsu_addr[15] | oai21_1/ZN | 2 | n/d | 57.7 | 10.1 | 157 | 3.792 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | n/d | 99.3 | 36.9 | 320 | 3.774 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[3].en | nor2_1/ZN | 1 | n/d | 64.4 | 3.4 | 138 | 3.748 ns | 3.0 |
| _0847_ | nor2_1/ZN | 3 | n/d | 51.1 | 15.3 | 174 | 3.675 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[6].en | nor2_1/ZN | 1 | n/d | 62.7 | 3.4 | 136 | 3.657 ns | 3.0 |
| _0680_ | oai222_1/ZN | 1 | n/d | 35.4 | 4.8 | 62 | 3.651 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | n/d | 62.5 | 2.4 | 162 | 3.640 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[2].en | nor2_1/ZN | 1 | n/d | 62.0 | 3.4 | 168 | 3.622 ns | 3.0 |
| _0946_ | aoi21_1/ZN | 4 | n/d | 42.3 | 18.4 | 137 | 3.534 ns | 3.0 |
| _0709_ | aoi22_1/ZN | 2 | n/d | 48.8 | 9.7 | 119 | 3.532 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | n/d | 60.2 | 3.4 | 161 | 3.528 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | n/d | 59.1 | 3.4 | 154 | 3.469 ns | 3.0 |
| u_soc.u_core.rf_wdata[3] | oai21_1/ZN | 1 | n/d | 58.2 | 2.4 | 159 | 3.437 ns | 3.0 |
| u_soc.u_core.rf_wdata[0] | oai21_1/ZN | 1 | n/d | 58.6 | 2.4 | 145 | 3.437 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 151.7 | 181.7 | 577 | 0.333 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


