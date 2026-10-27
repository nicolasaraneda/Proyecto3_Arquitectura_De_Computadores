Criterios de cierre de `asic/rom/runs/pa_t40`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 2.555 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 26.566 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 2.555 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 19.270 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 27.885 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 5.563 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 20.987 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 27.325 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 4.194 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 20.208 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.134 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.134 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.957 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.382 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.136 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.963 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.385 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.135 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.960 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.383 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 506 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 32 |
| área del die (µm²) | 418503 |
| utilización | 0.478 |

**Resultado: CIERRA**
