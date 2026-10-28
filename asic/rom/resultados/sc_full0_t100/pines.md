# Violaciones de slew y capacitancia de `sc_full0_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_full0_t100/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 9 en 3 nets (límite 3.0 ns); de max capacitancia: 2 (límite 0.2 pF); de max fanout: 12.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| aoi22_1/ZN | 2 | 6 |
| dffq_1/Q | 1 | 3 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| nand2_1/A2 | entrada | 2 |
| aoi22_1/ZN | salida | 2 |
| and2_1/A2 | entrada | 1 |
| buf_4/I | entrada | 1 |
| mux2_2/I0 | entrada | 1 |
| dffq_1/Q | salida | 1 |
| oai222_1/B1 | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| _0721_ | aoi22_1/ZN | 2 | n/d | 50.1 | 7.4 | 136 | 3.482 ns | 3.0 |
| u_soc.data_wdata[4] | dffq_1/Q | 2 | n/d | 97.8 | 14.3 | 227 | 3.122 ns | 3.0 |
| _0678_ | aoi22_1/ZN | 2 | n/d | 40.1 | 9.7 | 100 | 3.079 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_3_3_0_clk_regs | clkbuf_8/Z | 8 | n/d | 123.0 | 90.3 | 333 | 0.213 pF | 0.2 |
| clknet_3_6_0_clk_regs | clkbuf_8/Z | 8 | n/d | 119.9 | 90.3 | 358 | 0.210 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.5487 ohm/µm y 166.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


