Criterios de cierre de `asic/rom/runs/fb_9tb_t100`

| criterio | valor | cumple |
|---|---|---|
| flujo completo (final/metrics.json) | sí | sí |
| DRC Magic (magic__drc_error__count) | 30 | NO |
| DRC KLayout (klayout__drc_error__count) | no corrido en el flujo | sí |
| LVS (design__lvs_error__count) | 0 | sí |
| antena (antenna__violating__nets) | 0 | sí |
| setup WNS peor esquina (ns) | 0.000 | sí |
| setup TNS peor esquina (ns) | 0.000 | sí |
|   setup max_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_ss_125C_4v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup max_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_ss_125C_4v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup min_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ff_n40C_5v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_ss_125C_4v50: WNS / TNS | 0.000 / 0.000 | sí |
|   setup nom_tt_025C_5v00: WNS / TNS | 0.000 / 0.000 | sí |
| hold WNS peor esquina (ns) | 0.108 | sí |
| hold TNS peor esquina (ns) | 0.000 | sí |
|   hold max_ff_n40C_5v50: WNS / TNS | 0.108 / 0.000 | sí |
|   hold max_ss_125C_4v50: WNS / TNS | 0.886 / 0.000 | sí |
|   hold max_tt_025C_5v00: WNS / TNS | 0.343 / 0.000 | sí |
|   hold min_ff_n40C_5v50: WNS / TNS | 0.111 / 0.000 | sí |
|   hold min_ss_125C_4v50: WNS / TNS | 0.899 / 0.000 | sí |
|   hold min_tt_025C_5v00: WNS / TNS | 0.350 / 0.000 | sí |
|   hold nom_ff_n40C_5v50: WNS / TNS | 0.110 / 0.000 | sí |
|   hold nom_ss_125C_4v50: WNS / TNS | 0.893 / 0.000 | sí |
|   hold nom_tt_025C_5v00: WNS / TNS | 0.347 / 0.000 | sí |

| dato informativo | valor |
|---|---|
| max slew (design__max_slew_violation__count, peor esquina) | 186 |
| max capacitancia (design__max_cap_violation__count, peor esquina) | 42 |
| área del die (µm²) | 450624 |
| utilización | 0.503 |

**Resultado: NO CIERRA**
