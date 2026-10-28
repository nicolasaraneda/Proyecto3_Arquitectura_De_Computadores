Criterios de cierre de `asic/rom/runs/fb_d4_t23`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 1 | NO |
| setup WNS peor esquina (ns) | -2.342 | NO |
| setup TNS peor esquina (ns) | -174.290 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -2.342 / -174.290 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | -0.183 / -1.214 | NO |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -1.163 / -30.414 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.158 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.179 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.158 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.451 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.177 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.294 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.447 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.178 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.232 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.449 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 1102 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 13 |
| área del die (µm²) | 417255 |
| utilización | 0.495 |

**Resultado: NO CIERRA**
