Criterios de cierre de `asic/rom/runs/sc_g30_t24`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -2.500 | NO |
| setup TNS peor esquina (ns) | -35.248 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -2.500 / -35.248 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | -1.021 / -5.986 | NO |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | -1.688 / -15.260 | NO |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.157 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.157 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.342 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.428 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.174 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.492 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.443 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.167 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.425 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.443 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 237 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 2 |
| área del die (µm²) | 353921 |
| utilización | 0.519 |

**Resultado: NO CIERRA**
