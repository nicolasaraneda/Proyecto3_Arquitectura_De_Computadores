Criterios de cierre de `asic/sim/runs/d2_pnr`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 59.174 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 76.297 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 59.174 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 74.372 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 76.417 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 62.549 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 74.553 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 76.363 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 61.010 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 74.470 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.082 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.100 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.846 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.324 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.082 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.799 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.297 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.090 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.820 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.309 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 5 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 1 |
| área del die (µm²) | 414282 |
| utilización | 0.540 |

**Resultado: CIERRA**
