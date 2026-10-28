Criterios de cierre de `asic/rom/runs/fb_flat_t23`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -4.388 | NO |
| setup TNS peor esquina (ns) | -219.112 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -4.388 / -219.112 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | -1.821 / -40.550 | NO |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -2.997 / -87.564 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.132 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.132 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.189 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.378 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.134 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.329 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.382 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.134 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.267 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.380 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 400 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 5 |
| área del die (µm²) | 353332 |
| utilización | 0.529 |

**Resultado: NO CIERRA**
