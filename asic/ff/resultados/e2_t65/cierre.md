Criterios de cierre de `asic/ff/runs/e2_t65`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | -4.198 | NO |
| setup TNS peor esquina (ns) | -271.971 | NO |
|   setup max_ff_n40C_5v50: WNS / TNS | 38.939 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | -4.198 / -271.971 | NO |
|   setup max_tt_025C_5v00: WNS / TNS | 25.372 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 42.442 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 4.636 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 30.591 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 40.883 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 0.644 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 28.255 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.164 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.167 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 1.041 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.431 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.164 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 1.033 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.426 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.166 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 1.036 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.429 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 18557 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 209 |
| área del die (µm²) | 1801610 |
| utilización | 0.486 |

**Resultado: NO CIERRA**
