# Violaciones de slew y capacitancia de `sc_rccs_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_rccs_t100/55-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 37 en 16 nets (límite 3.0 ns); de max capacitancia: 4 (límite 0.2 pF); de max fanout: 0.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 12 | 28 |
| aoi22_1/ZN | 2 | 4 |
| nor4_1/ZN | 1 | 3 |
| nor3_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| icgtp_1/E | entrada | 12 |
| nor2_1/ZN | salida | 12 |
| aoi22_1/ZN | salida | 2 |
| nor3_1/ZN | salida | 1 |
| oai21_1/B | entrada | 1 |
| aoi22_1/B1 | entrada | 1 |
| aoi222_1/B1 | entrada | 1 |
| nand3_1/A2 | entrada | 1 |
| buf_4/I | entrada | 1 |
| nand2_1/A2 | entrada | 1 |
| nor4_1/ZN | salida | 1 |
| xor2_1/A2 | entrada | 1 |
| buf_2/I | entrada | 1 |
| aoi221_1/B1 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 362 | 70.4 | 3.4 | 154 | 6.112 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | 384 | 79.7 | 3.4 | 198 | 4.542 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | 351 | 73.1 | 3.4 | 177 | 4.198 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | 360 | 71.7 | 3.4 | 163 | 4.126 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | 358 | 71.4 | 3.4 | 198 | 4.110 ns | 3.0 |
| _1518_ | nor2_1/ZN | 5 | 176 | 38.9 | 28.2 | 139 | 3.709 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[7].en | nor2_1/ZN | 1 | 277 | 61.2 | 3.4 | 140 | 3.580 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | 385 | 57.7 | 3.4 | 153 | 3.398 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[5].en | nor2_1/ZN | 1 | 290 | 57.6 | 3.4 | 154 | 3.392 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | 367 | 56.6 | 3.4 | 174 | 3.342 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | 393 | 56.3 | 3.4 | 135 | 3.326 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[2].en | nor2_1/ZN | 1 | 288 | 56.2 | 3.4 | 145 | 3.318 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[1].en | nor2_1/ZN | 1 | 350 | 55.4 | 3.4 | 123 | 3.277 ns | 3.0 |
| _0740_ | aoi22_1/ZN | 1 | 207 | 47.7 | 4.6 | 95 | 3.212 ns | 3.0 |
| u_soc.u_periph.u_cycles/_079_ | nor4_1/ZN | 2 | 86 | 12.1 | 12.8 | 68 | 3.169 ns | 3.0 |
| _0771_ | aoi22_1/ZN | 1 | 191 | 44.8 | 4.5 | 99 | 3.053 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | 1243 | 175.8 | 181.7 | 651 | 0.358 pF | 0.2 |
| clknet_3_3__leaf_clk_regs | clkbuf_16/Z | 9 | 678 | 138.3 | 101.6 | 387 | 0.240 pF | 0.2 |
| clknet_3_6__leaf_clk_regs | clkbuf_16/Z | 9 | 624 | 115.2 | 101.6 | 384 | 0.217 pF | 0.2 |
| clknet_3_2__leaf_clk_regs | clkbuf_16/Z | 10 | 529 | 98.5 | 101.7 | 326 | 0.200 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.5487 ohm/µm y 166.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|
| max | 2608 | 188.1 | 631 | 196.7 | 0.603 | 25.1 | 0.941 | 1.13 | 1.10 |
| nom | 2608 | 166.1 | 509 | 173.2 | 0.553 | 25.0 | 0.890 | 1.00 | 1.01 |
| min | 2608 | 147.9 | 409 | 153.5 | 0.503 | 24.9 | 0.839 | 0.89 | 0.92 |

Bloque `LAYERS_RC` equivalente (tech LEF de `14-openroad-dumprcvalues/tlef_values.rpt` escalado por el factor de cada extracción, de modo que el promedio que usa el resizer coincida con la pendiente medida; unidades ohm/µm y pF/µm):

```yaml
LAYERS_RC:
  "max_*":
    Metal1: {res: 0.43037, cap: 1.0406e-04}
    Metal2: {res: 0.35352, cap: 9.5015e-05}
    Metal3: {res: 0.35352, cap: 8.8681e-05}
    Metal4: {res: 0.35352, cap: 8.7731e-05}
    Metal5: {res: 0.14998, cap: 1.9609e-05}
  "nom_*":
    Metal1: {res: 0.39453, cap: 9.1908e-05}
    Metal2: {res: 0.32408, cap: 8.3916e-05}
    Metal3: {res: 0.32408, cap: 7.8321e-05}
    Metal4: {res: 0.32408, cap: 7.7482e-05}
    Metal5: {res: 0.13749, cap: 1.7319e-05}
  "min_*":
    Metal1: {res: 0.35869, cap: 8.1801e-05}
    Metal2: {res: 0.29464, cap: 7.4688e-05}
    Metal3: {res: 0.29464, cap: 6.9709e-05}
    Metal4: {res: 0.29464, cap: 6.8962e-05}
    Metal5: {res: 0.12500, cap: 1.5414e-05}
```

