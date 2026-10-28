Criterios de cierre de `asic/rom/runs/fb_a2_t23`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -2.141 | NO |
| setup TNS peor esquina (ns) | -68.150 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -2.141 / -68.150 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | -0.031 / -0.055 | NO |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -0.989 / -8.098 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.104 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.173 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.104 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.440 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.172 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.265 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.439 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.172 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.193 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.439 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 349 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 3 |
| área del die (µm²) | 348061 |
| utilización | 0.523 |

**Resultado: NO CIERRA**
