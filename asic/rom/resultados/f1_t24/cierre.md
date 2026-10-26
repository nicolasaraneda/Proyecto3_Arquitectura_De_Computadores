Criterios de cierre de `asic/rom/runs/f1_t24`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -0.004 | NO |
| setup TNS peor esquina (ns) | -0.004 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 15.367 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -0.004 / -0.004 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 10.671 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 15.764 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 1.548 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 11.558 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 15.710 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 0.843 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 11.160 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.178 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.181 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 1.081 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.453 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.178 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 1.074 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.449 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.179 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 1.077 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.450 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 532 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 36 |
| área del die (µm²) | 408957 |
| utilización | 0.500 |

**Resultado: NO CIERRA**
