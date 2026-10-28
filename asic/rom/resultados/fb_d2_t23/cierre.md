Criterios de cierre de `asic/rom/runs/fb_d2_t23`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -2.795 | NO |
| setup TNS peor esquina (ns) | -97.065 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -2.795 / -97.065 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | -0.459 / -4.793 | NO |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -1.523 / -29.677 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.172 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.173 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.198 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.440 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.172 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.351 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.439 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.172 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.283 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.439 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 427 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 5 |
| área del die (µm²) | 379850 |
| utilización | 0.528 |

**Resultado: NO CIERRA**
