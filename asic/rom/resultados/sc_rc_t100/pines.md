# Violaciones de slew y capacitancia de `sc_rc_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_rc_t100/55-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 47 en 19 nets (límite 3.0 ns); de max capacitancia: 2 (límite 0.2 pF); de max fanout: 10.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor2_1/ZN | 14 | 32 |
| aoi22_1/ZN | 2 | 5 |
| nand4_1/ZN | 1 | 5 |
| nor4_1/ZN | 1 | 3 |
| nor3_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| icgtp_1/E | entrada | 14 |
| nor2_1/ZN | salida | 14 |
| buf_4/I | entrada | 2 |
| nand2_1/A2 | entrada | 2 |
| aoi22_1/ZN | salida | 2 |
| nor3_1/ZN | salida | 1 |
| aoi22_1/B1 | entrada | 1 |
| aoi222_1/B1 | entrada | 1 |
| nand3_1/A2 | entrada | 1 |
| oai21_1/B | entrada | 1 |
| nor4_1/ZN | salida | 1 |
| xor2_1/A2 | entrada | 1 |
| buf_2/I | entrada | 1 |
| oai21_1/A2 | entrada | 1 |
| nand4_1/ZN | salida | 1 |
| nor2_1/A2 | entrada | 1 |
| nand3_1/A3 | entrada | 1 |
| and2_1/A1 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | 360 | 69.6 | 3.4 | 153 | 6.052 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[11].en | nor2_1/ZN | 1 | 391 | 79.1 | 3.4 | 174 | 4.514 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[10].en | nor2_1/ZN | 1 | 378 | 72.9 | 3.4 | 169 | 4.189 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[8].en | nor2_1/ZN | 1 | 368 | 69.7 | 3.4 | 175 | 4.024 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[9].en | nor2_1/ZN | 1 | 349 | 66.4 | 3.4 | 177 | 3.850 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[12].en | nor2_1/ZN | 1 | 352 | 65.9 | 3.4 | 158 | 3.827 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[5].en | nor2_1/ZN | 1 | 289 | 64.8 | 3.4 | 127 | 3.766 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[6].en | nor2_1/ZN | 1 | 320 | 63.2 | 3.4 | 165 | 3.685 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[13].en | nor2_1/ZN | 1 | 342 | 62.5 | 3.4 | 164 | 3.646 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[7].en | nor2_1/ZN | 1 | 278 | 60.6 | 3.4 | 122 | 3.546 ns | 3.0 |
| _1518_ | nor2_1/ZN | 5 | 170 | 33.3 | 28.2 | 119 | 3.417 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[14].en | nor2_1/ZN | 1 | 394 | 57.9 | 3.4 | 136 | 3.408 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[15].en | nor2_1/ZN | 1 | 364 | 56.5 | 3.4 | 172 | 3.337 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[3].en | nor2_1/ZN | 1 | 278 | 56.0 | 3.4 | 141 | 3.310 ns | 3.0 |
| u_soc.u_periph.u_cycles/_079_ | nor4_1/ZN | 2 | 87 | 13.4 | 12.8 | 69 | 3.303 ns | 3.0 |
| _0740_ | aoi22_1/ZN | 1 | 206 | 46.6 | 4.6 | 95 | 3.154 ns | 3.0 |
| _0718_ | aoi22_1/ZN | 2 | 187 | 41.2 | 9.6 | 102 | 3.129 ns | 3.0 |
| _0884_ | nand4_1/ZN | 4 | 193 | 40.4 | 21.0 | 132 | 3.057 ns | 3.0 |
| u_soc.u_core.u_rf/g_reg[2].en | nor2_1/ZN | 1 | 300 | 50.7 | 3.4 | 149 | 3.031 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | 1093 | 150.3 | 181.7 | 556 | 0.332 pF | 0.2 |
| clknet_3_3__leaf_clk_regs | clkbuf_16/Z | 8 | 580 | 113.4 | 90.3 | 359 | 0.204 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.5487 ohm/µm y 166.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|
| max | 2555 | 185.5 | 657 | 194.7 | 0.592 | 25.4 | 0.931 | 1.12 | 1.08 |
| nom | 2555 | 164.1 | 529 | 171.5 | 0.543 | 25.3 | 0.879 | 0.99 | 0.99 |
| min | 2555 | 146.2 | 426 | 152.2 | 0.493 | 25.2 | 0.827 | 0.88 | 0.90 |

Bloque `LAYERS_RC` equivalente (tech LEF de `14-openroad-dumprcvalues/tlef_values.rpt` escalado por el factor de cada extracción, de modo que el promedio que usa el resizer coincida con la pendiente medida; unidades ohm/µm y pF/µm):

```yaml
LAYERS_RC:
  "max_*":
    Metal1: {res: 0.42253, cap: 1.0264e-04}
    Metal2: {res: 0.34707, cap: 9.3712e-05}
    Metal3: {res: 0.34707, cap: 8.7464e-05}
    Metal4: {res: 0.34707, cap: 8.6527e-05}
    Metal5: {res: 0.14724, cap: 1.9340e-05}
  "nom_*":
    Metal1: {res: 0.38696, cap: 9.0749e-05}
    Metal2: {res: 0.31786, cap: 8.2858e-05}
    Metal3: {res: 0.31786, cap: 7.7334e-05}
    Metal4: {res: 0.31786, cap: 7.6505e-05}
    Metal5: {res: 0.13485, cap: 1.7100e-05}
  "min_*":
    Metal1: {res: 0.35140, cap: 8.0862e-05}
    Metal2: {res: 0.28865, cap: 7.3830e-05}
    Metal3: {res: 0.28865, cap: 6.8908e-05}
    Metal4: {res: 0.28865, cap: 6.8170e-05}
    Metal5: {res: 0.12246, cap: 1.5237e-05}
```

