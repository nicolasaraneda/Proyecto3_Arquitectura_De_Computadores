Criterios de cierre de `asic/rom/runs/pa_t32`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 1.591 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 20.837 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 1.591 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 14.899 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 21.872 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 4.321 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 16.476 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 21.400 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 3.079 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 15.758 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.134 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.134 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.958 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.383 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.136 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.964 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.385 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.135 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.962 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.384 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 463 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 33 |
| área del die (µm²) | 418503 |
| utilización | 0.482 |

**Resultado: CIERRA**
