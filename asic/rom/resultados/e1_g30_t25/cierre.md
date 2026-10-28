Criterios de cierre de `asic/rom/runs/e1_g30_t25`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -1.922 | NO |
| setup TNS peor esquina (ns) | -33.343 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 15.067 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -1.922 / -33.343 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 9.777 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 16.066 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 0.694 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 11.296 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 15.611 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -0.487 / -1.203 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 10.603 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.128 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.128 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.937 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.371 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.132 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.947 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.377 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.130 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.942 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.375 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 243 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 35 |
| área del die (µm²) | 419131 |
| utilización | 0.503 |

**Resultado: NO CIERRA**
