Criterios de cierre de `asic/rom/runs/fb_t22`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -1.670 | NO |
| setup TNS peor esquina (ns) | -39.765 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -1.670 / -39.765 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -0.590 / -6.807 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | -0.077 | NO |
| hold TNS peor esquina (ns) | -0.154 | NO |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.165 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | -0.077 / -0.154 | NO |
|   hold max_tt_025C_5v00: WNS / TNS | 0.441 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.174 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.081 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.443 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.174 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.011 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.444 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 368 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 1 |
| área del die (µm²) | 353921 |
| utilización | 0.524 |

**Resultado: NO CIERRA**
