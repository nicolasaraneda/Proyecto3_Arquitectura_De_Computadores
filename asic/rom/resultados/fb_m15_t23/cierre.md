Criterios de cierre de `asic/rom/runs/fb_m15_t23`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -0.447 | NO |
| setup TNS peor esquina (ns) | -3.639 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -0.447 / -3.639 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.136 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.154 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.136 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.424 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.173 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.288 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.443 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.165 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.220 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.440 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 340 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 2 |
| área del die (µm²) | 353921 |
| utilización | 0.526 |

**Resultado: NO CIERRA**
