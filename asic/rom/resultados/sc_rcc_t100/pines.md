# Violaciones de slew y capacitancia de `sc_rcc_t100`, esquina `max_ss_125C_4v50`

Fuente: `asic/rom/runs/sc_rcc_t100/56-openroad-stapostpnr/max_ss_125C_4v50/checks.rpt`, netlist `final/nl/asic_top.nl.v`, SPEF `final/spef/max/asic_top.max.spef` (capacidad de cable, sin pines), `50-odb-reportwirelength/wire_lengths.csv`, liberty `ss_125C_4v50` (dirección y capacidad de pines). Generado por `asic/signoff_pines.py`.

Pines con violación de max slew: 2 en 1 nets (límite 3.0 ns); de max capacitancia: 1 (límite 0.2 pF); de max fanout: 10.

## Violaciones de slew por celda que maneja el net

| celda/pin que maneja | nets | pines con violación |
|---|---|---|
| nor3_1/ZN | 1 | 2 |

## Pines con violación de slew por tipo de pin

| celda/pin | tipo | pines |
|---|---|---|
| nor3_1/ZN | salida | 1 |
| buf_4/I | entrada | 1 |

## Los 25 nets con peor slew

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | peor slew | límite |
|---|---|---|---|---|---|---|---|---|
| u_soc.u_core.u_rf/g_reg[4].en | nor3_1/ZN | 1 | n/d | 30.5 | 9.5 | 81 | 3.498 ns | 3.0 |

## Nets con violación de capacitancia

| net | celda/pin que maneja | fanout | largo (µm) | cap. cable SPEF (fF) | cap. pines lib (fF) | R total (ohm) | cap. total STA | límite |
|---|---|---|---|---|---|---|---|---|
| clknet_0_clk_regs | clkbuf_16/Z | 8 | n/d | 150.3 | 181.7 | 546 | 0.332 pF | 0.2 |

## Capacidad y resistencia de cable extraídas contra largo ruteado

Valores que usa el resizer para estimar, iguales en las 9 esquinas (`14-openroad-dumprcvalues/resizer_values_after.rpt`, Signal Avg, promedio del tech LEF de las capas de ruteo): 0.5487 ohm/µm y 166.3 aF/µm.

| extracción | nets (largo > 20 µm) | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|


