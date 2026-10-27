# Violaciones de slew y capacitancia de `sc_rccd_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_rccd_t100/55-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 44 en 17 nets (límite 3.0 ns); de max capacitancia: 3 (límite 0.2 pF); de max fanout: 10.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 10 | 24 |
| nor4_4/ZN | 1 | 6 |
| aoi22_1/ZN | 2 | 5 |
| nor4_1/ZN | 1 | 3 |
| nor3_1/ZN | 1 | 2 |
| aoi211_1/ZN | 1 | 2 |
| aoi221_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| icgtp_1/E | entrada | 10 |
| nor2_1/ZN | salida | 10 |
| mux2_2/S | entrada | 4 |
| buf_2/I | entrada | 3 |
| buf_4/I | entrada | 2 |
| nand2_1/A2 | entrada | 2 |
| aoi22_1/ZN | salida | 2 |
| nor3_1/ZN | salida | 1 |
| aoi22_1/B1 | entrada | 1 |
| aoi222_1/B1 | entrada | 1 |
| nand3_1/A2 | entrada | 1 |
| oai21_1/B | entrada | 1 |
| aoi211_1/ZN | salida | 1 |
| nor4_1/ZN | salida | 1 |
| xor2_1/A2 | entrada | 1 |
| oai21_1/A2 | entrada | 1 |
| aoi221_1/ZN | salida | 1 |
| nor4_4/ZN | salida | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 366 | 77.5 | 3.4 | 173 | 6.665 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | 389 | 84.7 | 3.4 | 182 | 4.804 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | 401 | 77.4 | 3.4 | 186 | 4.423 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | 374 | 74.6 | 3.4 | 167 | 4.278 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | 398 | 71.0 | 3.4 | 194 | 4.089 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | 357 | 67.7 | 3.4 | 153 | 3.918 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[5].en | nor2_1/ZN | 1 | 337 | 66.0 | 3.4 | 153 | 3.831 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | 335 | 65.9 | 3.4 | 152 | 3.828 ns | 3.0 |
| _1518_ | nor2_1/ZN | 5 | 166 | 35.5 | 28.2 | 117 | 3.534 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | 340 | 59.5 | 3.4 | 154 | 3.490 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[7].en | nor2_1/ZN | 1 | 267 | 57.7 | 3.4 | 127 | 3.399 ns | 3.0 |
| _0746_ | aoi22_1/ZN | 1 | 199 | 48.9 | 4.6 | 102 | 3.275 ns | 3.0 |
| _1466_ | aoi211_1/ZN | 1 | 129 | 27.8 | 5.1 | 66 | 3.204 ns | 3.0 |
| u_soc.u_periph.u_cycles/_079_ | nor4_1/ZN | 2 | 85 | 12.3 | 12.8 | 68 | 3.192 ns | 3.0 |
| _0718_ | aoi22_1/ZN | 2 | 183 | 40.6 | 9.6 | 95 | 3.101 ns | 3.0 |
| _0755_ | aoi221_1/ZN | 1 | 91 | 24.1 | 5.1 | 52 | 3.084 ns | 3.0 |
| _1609_ | nor4_4/ZN | 5 | 208 | 37.0 | 51.1 | 124 | 3.008 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_3_3_0_clk_regs | clkbuf_8/Z | 8 | 641 | 118.5 | 90.3 | 367 | 0.209 pF | 0.2 |
| clknet_3_6_0_clk_regs | clkbuf_8/Z | 8 | 590 | 114.3 | 90.3 | 343 | 0.205 pF | 0.2 |
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 366 | 77.5 | 3.4 | 173 | 0.081 pF | 0.07985 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.5487 ohm/µm y 166.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|
| max | 2577 | 190.5 | 296 | 196.1 | 0.596 | 24.9 | 0.912 | 1.15 | 1.09 |
| nom | 2577 | 168.1 | 231 | 172.5 | 0.546 | 24.8 | 0.861 | 1.01 | 1.00 |
| min | 2577 | 149.5 | 182 | 153.1 | 0.496 | 24.7 | 0.809 | 0.90 | 0.90 |

Bloque `LAYERS_RC` equivalente (tech LEF de `14-openroad-dumprcvalues/tlef_values.rpt` escalado por el factor de cada extracción, de modo que el promedio que usa el resizer coincida con la pendiente medida; unidades ohm/µm y pF/µm):

```yaml
LAYERS_RC:
  "max_*":
    Metal1: {res: 0.42520, cap: 1.0539e-04}
    Metal2: {res: 0.34927, cap: 9.6228e-05}
    Metal3: {res: 0.34927, cap: 8.9813e-05}
    Metal4: {res: 0.34927, cap: 8.8851e-05}
    Metal5: {res: 0.14818, cap: 1.9860e-05}
  "nom_*":
    Metal1: {res: 0.38942, cap: 9.3012e-05}
    Metal2: {res: 0.31988, cap: 8.4924e-05}
    Metal3: {res: 0.31988, cap: 7.9262e-05}
    Metal4: {res: 0.31988, cap: 7.8413e-05}
    Metal5: {res: 0.13571, cap: 1.7527e-05}
  "min_*":
    Metal1: {res: 0.35363, cap: 8.2708e-05}
    Metal2: {res: 0.29048, cap: 7.5516e-05}
    Metal3: {res: 0.29048, cap: 7.0481e-05}
    Metal4: {res: 0.29048, cap: 6.9726e-05}
    Metal5: {res: 0.12324, cap: 1.5585e-05}
```

