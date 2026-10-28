Criterios de cierre de `asic/sim/runs/d1_pnr`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 63.717 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 76.435 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 63.717 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 74.595 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 76.559 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 66.699 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 74.775 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 76.503 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 65.347 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 74.695 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.173 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.175 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 1.063 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.443 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.173 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 1.060 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.441 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.174 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 1.061 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.442 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 516 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 30 |
| área del die (µm²) | 403659 |
| utilización | 0.479 |

**Resultado: CIERRA**
