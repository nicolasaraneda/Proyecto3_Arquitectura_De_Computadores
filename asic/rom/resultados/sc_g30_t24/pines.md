# Violaciones de slew y capacitancia de `sc_g30_t24`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_g30_t24/55-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 237 en 61 nets (límite 3.0 ns); de max capacitancia: 2 (límite 0.2 pF); de max fanout: 35.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nand2_1/ZN | 6 | 56 |
| nor2_1/ZN | 16 | 44 |
| clkinv_1/ZN | 3 | 20 |
| dffrnq_1/Q | 2 | 20 |
| dffq_1/Q | 3 | 17 |
| aoi21_1/ZN | 4 | 17 |
| aoi22_1/ZN | 6 | 16 |
| oai211_1/ZN | 5 | 14 |
| oai21_1/ZN | 6 | 13 |
| oai32_1/ZN | 3 | 6 |
| nor3_1/ZN | 2 | 4 |
| aoi221_1/ZN | 2 | 4 |
| aoi211_1/ZN | 1 | 2 |
| oai31_1/ZN | 1 | 2 |
| aoi222_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| nor2_1/ZN | salida | 16 |
| icgtp_1/E | entrada | 13 |
| buf_2/I | entrada | 13 |
| nand2_1/A1 | entrada | 12 |
| nand2_1/A2 | entrada | 12 |
| dffq_1/D | entrada | 10 |
| aoi21_1/A1 | entrada | 8 |
| oai21_1/A1 | entrada | 8 |
| aoi22_1/A1 | entrada | 7 |
| oai21_1/A2 | entrada | 7 |
| oai21_1/ZN | salida | 6 |
| mux2_2/I0 | entrada | 6 |
| aoi22_1/ZN | salida | 6 |
| nor2_1/A1 | entrada | 6 |
| nand2_1/ZN | salida | 6 |
| oai211_1/ZN | salida | 5 |
| oai211_1/A2 | entrada | 5 |
| oai211_1/A1 | entrada | 5 |
| nand3_1/A2 | entrada | 5 |
| aoi211_1/B | entrada | 4 |
| aoi21_1/ZN | salida | 4 |
| aoi21_1/A2 | entrada | 4 |
| dffq_1/Q | salida | 3 |
| clkinv_1/ZN | salida | 3 |
| nor2_1/A2 | entrada | 3 |
| nand3_1/A1 | entrada | 3 |
| oai32_1/ZN | salida | 3 |
| nor3_1/ZN | salida | 2 |
| aoi221_1/ZN | salida | 2 |
| and2_1/A2 | entrada | 2 |
| aoi221_1/A2 | entrada | 2 |
| and4_1/A1 | entrada | 2 |
| aoi211_1/A2 | entrada | 2 |
| dffrnq_1/Q | salida | 2 |
| oai21_1/B | entrada | 2 |
| oai211_1/B | entrada | 2 |
| aoi22_1/B2 | entrada | 2 |
| oai22_1/A1 | entrada | 2 |
| nand4_1/A2 | entrada | 2 |
| aoi21_1/B | entrada | 2 |
| mux2_2/I1 | entrada | 1 |
| nand3_4/A3 | entrada | 1 |
| nand3_4/A2 | entrada | 1 |
| and3_1/A3 | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| xor2_1/A1 | entrada | 1 |
| and4_1/A2 | entrada | 1 |
| xor2_1/A2 | entrada | 1 |
| oai22_1/A2 | entrada | 1 |
| oai222_1/B1 | entrada | 1 |
| or2_1/A2 | entrada | 1 |
| xnor2_1/A1 | entrada | 1 |
| xor3_1/A2 | entrada | 1 |
| oai31_1/A3 | entrada | 1 |
| oai32_1/B1 | entrada | 1 |
| or4_2/A2 | entrada | 1 |
| nand3_1/A3 | entrada | 1 |
| oai31_1/ZN | salida | 1 |
| aoi211_1/C | entrada | 1 |
| oai221_1/A2 | entrada | 1 |
| aoi22_1/B1 | entrada | 1 |
| aoi222_1/ZN | salida | 1 |
| aoi211_1/A1 | entrada | 1 |
| aoi221_1/C | entrada | 1 |
| oai33_1/A1 | entrada | 1 |
| nor3_1/A1 | entrada | 1 |
| aoi222_1/A1 | entrada | 1 |
| oai32_1/A2 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 361 | 76.5 | 3.4 | 199 | 6.579 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | 212 | 43.9 | 4.1 | 97 | 4.538 ns | 3.0 |
| u_soc.u_core.rf_we | nor3_1/ZN | 1 | 256 | 47.4 | 5.1 | 123 | 4.463 ns | 3.0 |
| u_soc.u_core.rf_wdata[24] | oai21_1/ZN | 1 | 387 | 76.2 | 2.4 | 182 | 4.356 ns | 3.0 |
| u_soc.u_core.lsu_addr[3] | oai211_1/ZN | 3 | 274 | 61.9 | 15.1 | 177 | 4.356 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | 355 | 75.3 | 3.4 | 170 | 4.316 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | 349 | 74.6 | 3.4 | 186 | 4.278 ns | 3.0 |
| u_soc.u_core.rf_wdata[5] | oai211_1/ZN | 1 | 400 | 69.3 | 2.4 | 176 | 4.103 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | 400 | 70.7 | 3.4 | 195 | 4.077 ns | 3.0 |
| u_soc.u_core.lsu_addr[15] | oai21_1/ZN | 2 | 308 | 60.1 | 10.1 | 184 | 3.919 ns | 3.0 |
| u_soc.data_wdata[7] | dffq_1/Q | 8 | 590 | 101.7 | 36.9 | 334 | 3.839 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | 340 | 65.7 | 3.4 | 163 | 3.815 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[1].en | nor2_1/ZN | 1 | 354 | 65.6 | 3.4 | 161 | 3.810 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | 360 | 65.0 | 3.4 | 170 | 3.781 ns | 3.0 |
| u_soc.u_core.rf_wdata[4] | oai21_1/ZN | 1 | 334 | 63.8 | 2.4 | 180 | 3.711 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | 372 | 61.5 | 3.4 | 185 | 3.594 ns | 3.0 |
| _0721_ | aoi22_1/ZN | 2 | 217 | 50.1 | 7.4 | 117 | 3.483 ns | 3.0 |
| _0496_ | nor2_1/ZN | 3 | 104 | 21.1 | 41.4 | 85 | 3.467 ns | 3.0 |
| u_soc.g_mem_rom.u_mem.a_rdata_o[21] | dffq_1/Q | 3 | 514 | 108.0 | 15.3 | 257 | 3.422 ns | 3.0 |
| u_soc.u_core.lsu_wdata[13] | dffq_1/Q | 3 | 506 | 108.4 | 14.5 | 280 | 3.409 ns | 3.0 |
| u_soc.u_core.u_rf/_0622_ | clkinv_1/ZN | 4 | 564 | 105.1 | 17.6 | 283 | 3.405 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | 373 | 57.5 | 3.4 | 144 | 3.390 ns | 3.0 |
| _1097_ | nand2_1/ZN | 8 | 384 | 73.4 | 35.8 | 303 | 3.371 ns | 3.0 |
| u_soc.u_core.rf_wdata[0] | oai21_1/ZN | 1 | 327 | 56.9 | 2.4 | 195 | 3.362 ns | 3.0 |
| u_soc.u_core.rf_wdata[13] | oai21_1/ZN | 1 | 320 | 55.7 | 2.4 | 156 | 3.346 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | 1099 | 156.3 | 181.7 | 573 | 0.338 pF | 0.2 |
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 361 | 76.5 | 3.4 | 199 | 0.080 pF | 0.07985 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.2752 ohm/µm y 64.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|
| max | 2441 | 185.4 | 778 | 195.6 | 0.593 | 26.9 | 0.948 | 2.88 | 2.15 |
| nom | 2441 | 163.9 | 631 | 172.1 | 0.543 | 26.7 | 0.896 | 2.55 | 1.97 |
| min | 2441 | 146.0 | 510 | 152.8 | 0.492 | 26.6 | 0.845 | 2.27 | 1.79 |

Bloque `LAYERS_RC` equivalente (tech LEF de `14-openroad-dumprcvalues/tlef_values.rpt` escalado por el factor de cada extracción, de modo que el promedio que usa el resizer coincida con la pendiente medida; unidades ohm/µm y pF/µm):

```yaml
LAYERS_RC:
  "max_*":
    Metal1: {res: 0.84288, cap: 2.6516e-04}
    Metal2: {res: 0.69236, cap: 2.4210e-04}
    Metal3: {res: 0.69236, cap: 2.2596e-04}
    Metal4: {res: 0.69236, cap: 2.2354e-04}
    Metal5: {res: 0.29373, cap: 4.9965e-05}
  "nom_*":
    Metal1: {res: 0.77150, cap: 2.3437e-04}
    Metal2: {res: 0.63373, cap: 2.1399e-04}
    Metal3: {res: 0.63373, cap: 1.9972e-04}
    Metal4: {res: 0.63373, cap: 1.9758e-04}
    Metal5: {res: 0.26886, cap: 4.4163e-05}
  "min_*":
    Metal1: {res: 0.70013, cap: 2.0880e-04}
    Metal2: {res: 0.57510, cap: 1.9065e-04}
    Metal3: {res: 0.57510, cap: 1.7794e-04}
    Metal4: {res: 0.57510, cap: 1.7603e-04}
    Metal5: {res: 0.24398, cap: 3.9346e-05}
```

