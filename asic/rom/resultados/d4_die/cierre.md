Criterios de cierre de `asic/rom/runs/d4_die`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 0 | sí |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 61.672 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 76.271 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 61.672 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 74.329 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 76.429 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 65.315 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 74.563 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 76.357 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 63.640 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 74.457 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.156 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.157 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 1.013 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.416 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.156 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 1.013 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.415 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.157 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 1.013 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.415 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 567 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 33 |
| área del die (µm²) | 408913 |
| utilización | 0.480 |

**Resultado: CIERRA**
