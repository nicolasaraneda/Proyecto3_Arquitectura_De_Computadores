# Barrido del modelo de cable sobre el RTL de v1 (exploración del coordinador)

Nota de contexto, agregada al integrar D23: estas corridas se hicieron cuando la configuración del
modelo de cable vivía en un archivo aparte, `asic/rom/config_rc.yaml`, y las perillas del post-GRT
iban por línea de comandos. **Desde D23 las dos cosas son `asic/rom/config.yaml`**, la configuración
final, y ese archivo aparte se eliminó. El RTL de estas corridas es el de v1 (tag `v1-final`), no el
de la corrida final. Lectura y conclusiones en `docs/modelo_cable.md`, sección 4.

## Modelo de cable medido (LAYERS_RC) sobre el RTL de main

Corridas co_rcm_* en un worktree desprendido de main (build/main_rc) con asic/rom/config_rc.yaml: la configuración final más el bloque LAYERS_RC del frente C y las perillas de reparación post-GRT. Sirven para comparar con las co_rc_* de la candidata: la pregunta es si el nanosegundo de diferencia de período entre main y la candidata viene del diseño o de la estimación de parásitos del resizer.

Esquina típica: `nom_tt_025C_5v00`; esquina más lenta: `max_ss_125C_4v50`; "peor" es la peor de las 9 esquinas. Generado por `asic/recolectar.py`.

| corrida | T (ns) | setup WS tt | setup TNS tt | setup WS ss | setup TNS ss | hold WS tt | hold TNS tt | hold WS ss | hold TNS ss | setup WS peor | setup TNS peor | hold WS peor | hold TNS peor | cierra timing | área stdcell (µm²) | utilización | área die (µm²) | antena (nets) | DRC | LVS | cierra todo | slew (peor) | cap (peor) | celdas dly |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| co_rcm_t100 | 100 | 74.593 | 0 | 65.276 | 0 | 0.419 | 0 | 1.025 | 0 | 65.276 | 0 | 0.158 | 0 | sí | 201309 | 0.530 | 408957 | 0 | 0 | 0 | sí | 2 | 1 | 0 |
| co_rcm_t23 | 23 | 11.014 | 0 | 0.756 | 0 | 0.419 | 0 | 1.025 | 0 | 0.756 | 0 | 0.158 | 0 | sí | 212530 | 0.560 | 408957 | 0 | 0 | 0 | sí | 0 | 1 | 0 |
| co_rcm_t22 | 22 | 10.218 | 0 | 0.215 | 0 | 0.417 | 0 | 1.021 | 0 | 0.215 | 0 | 0.157 | 0 | sí | 214348 | 0.564 | 408957 | 0 | 0 | 0 | sí | 0 | 1 | 0 |

| corrida | área de celdas de síntesis (µm²) | área secuencial (µm²) | flip-flops | área espino_register_file (µm²) | área espino_alu (µm²) | área pochoco_cycle_counter (µm²) |
|---|---|---|---|---|---|---|
| co_rcm_t100 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| co_rcm_t23 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
| co_rcm_t22 | 152169.069 | 65065.728 | 990 | 73655.546 | 10005.722 | 3942.579 |
