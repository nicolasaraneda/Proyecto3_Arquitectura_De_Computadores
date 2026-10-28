Criterios de cierre de `asic/sim/runs/e1_pnr`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 58.590 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 76.363 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 58.590 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 74.455 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 76.496 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 62.977 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 74.657 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 76.436 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 60.978 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 74.566 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.153 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.155 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 1.009 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.413 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.153 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 1.005 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.410 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.154 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 1.007 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.411 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 711 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 48 |
| área del die (µm²) | 414282 |
| utilización | 0.479 |

**Resultado: CIERRA**
