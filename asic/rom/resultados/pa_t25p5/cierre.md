Criterios de cierre de `asic/rom/runs/pa_t25p5`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -0.302 | NO |
| setup TNS peor esquina (ns) | -0.527 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 16.004 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -0.302 / -0.527 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 10.945 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 16.863 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 1.785 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 12.226 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 16.473 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 0.836 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 11.658 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.135 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.135 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.959 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.383 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.136 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.964 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.385 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.135 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.962 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.384 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 447 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 33 |
| área del die (µm²) | 418503 |
| utilización | 0.502 |

**Resultado: NO CIERRA**
