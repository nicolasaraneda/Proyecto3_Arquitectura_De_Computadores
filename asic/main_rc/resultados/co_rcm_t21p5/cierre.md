Criterios de cierre de `asic/rom/runs/co_rcm_t21p5`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -0.383 | NO |
| setup TNS peor esquina (ns) | -15.730 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 13.549 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -0.383 / -15.730 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 9.502 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 13.690 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 0.085 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 9.785 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 13.626 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -0.109 / -1.051 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 9.675 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.157 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.158 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 1.021 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.418 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.157 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 1.017 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.416 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.158 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 1.019 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.417 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 3 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 1 |
| área del die (µm²) | 408957 |
| utilización | 0.567 |

**Resultado: NO CIERRA**
