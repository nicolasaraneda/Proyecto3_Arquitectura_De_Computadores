# Reportes de la corrida final de v1

Copia completa de `asic/rom/resultados/final/` tal como quedó antes de integrar `exp/candidata-rc`
(D23). "v1" quiere decir `main` con el RTL y la configuración del 28-10-2026, marcado con el tag
`v1-final`. Esta copia se conserva porque `asic/rom/resultados/final/` se sobrescribe con la corrida
final nueva, y el informe necesita las dos para la tabla de evolución de la sección 3.4 y para la
segunda vuelta atrás de D23.

Qué hay acá, con su archivo:

| Dato | Valor | Archivo |
|---|---|---|
| Período de la corrida | 100 ns, `FP_CORE_UTIL` 40 | `resolved.json` (no versionado) y `metrics.json` |
| Área de celdas estándar | 182.265 µm² | `metrics.json`, `design__instance__area__stdcell` |
| Área del die | 408.957 µm² (0,409 mm²) | `metrics.json`, `design__die__area` |
| Utilización real del core | 0,479898 | `metrics.json`, `design__instance__utilization` |
| Celdas estándar | 8.670 | `metrics.json`, `design__instance__count__stdcell` |
| Largo de cables | 352.253 µm | `metrics.json`, `route__wirelength` |
| Setup WNS peor de las 9 esquinas | 65,223 ns (`max_ss_125C_4v50`) | `cierre.md` |
| Hold WNS peor de las 9 esquinas | 0,178 ns | `cierre.md` |
| DRC de Magic, LVS, antenas | 0, 0, 0 | `cierre.md` |
| Violaciones de max slew / max cap | 546 / 36 | `metrics.json` |
| DRC de KLayout con el deck del PDK | 0 marcadores en 684 reglas | `drc_klayout/resumen.md` |
| Período mínimo del diseño de v1 | 24,5 ns (40,8 MHz) | no está acá: `asic/rom/resultados/f1_t24p5/cierre.md` |
| CPI del juego y MIPS de v1 | 2,665 y 15,3 | no está acá: `make check` de v1 y el cálculo de la Ley de Hierro |

Los cuatro archivos que no están versionados (`resolved.json`, `sintesis_stat.json`, `warning.log` y
`drc_klayout/drc.log`) quedan excluidos por `.gitignore` igual que en `resultados/final/`; están en
el disco de quien corrió el flujo y se pueden regenerar con `git checkout v1-final` más
`bash asic/final.sh`.
