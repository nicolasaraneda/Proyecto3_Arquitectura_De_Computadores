Criterios de cierre de `asic/rom/runs/pa_b2_t25`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -0.409 | NO |
| setup TNS peor esquina (ns) | -1.027 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 15.730 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -0.409 / -1.027 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 10.750 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 16.473 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 1.957 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 12.090 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 16.191 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 0.883 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 11.482 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.135 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.135 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.955 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.382 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.136 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.957 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.383 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.135 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.954 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.381 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 508 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 40 |
| área del die (µm²) | 419131 |
| utilización | 0.499 |

**Resultado: NO CIERRA**
