Criterios de cierre de `asic/rom/runs/fb_a1_t23`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -4.401 | NO |
| setup TNS peor esquina (ns) | -625.951 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -4.401 / -625.951 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | -2.547 / -325.979 | NO |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -3.388 / -461.902 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.142 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.142 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.182 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.393 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.143 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.324 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.395 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.143 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.262 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.394 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 402 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 1 |
| área del die (µm²) | 350869 |
| utilización | 0.518 |

**Resultado: NO CIERRA**
