Criterios de cierre de `asic/rom/runs/final`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 65.223 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 76.437 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 65.223 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 74.594 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 76.559 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 68.029 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 74.775 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 76.504 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 66.757 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 74.694 / 0.000 | sí |
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
| max slew (design__max_slew_violation__count, peor esquina) | 546 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 36 |
| área del die (µm²) | 408957 |
| utilización | 0.480 |

**Resultado: CIERRA**
