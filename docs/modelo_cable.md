# El modelo de cable del resizer explica la diferencia de período entre main y la candidata

Rama `exp/candidata-rc` (worktree `build/exp_candidata_rc`), sesión del 28-10-2026. Exploración
del coordinador, fuera del paquete del frente E. El RTL es exactamente el de `exp/candidata`
(creada desde `exp/pipeline-b2`, commit `be50893`): no hay ningún cambio de RTL en esta rama, solo
una configuración de flujo distinta en `asic/rom/config_rc.yaml`.

## 1. La pregunta

Con la configuración del enunciado, la candidata (lectura del banco de registros y decodificación
en el fetch, más el offset de byte registrado en la LSU) cierra a 25,5 ns y `main` a 24,5 ns. Esa
diferencia de 1 ns es la única desventaja de temporización de la candidata y pesa en la decisión
D23. La pregunta es si el nanosegundo viene del diseño o de la herramienta.

El frente C (rama `exp/signoff0`, `docs/signoff0.md`) midió que el resizer de OpenROAD estima la
capacidad de los cables con 2,3 a 2,9 veces menos de la que OpenRCX extrae del ruteo detallado,
porque usa el promedio del tech LEF (0,275 ohm/µm y 64,3 aF/µm) en vez de los valores por capa. Con
ese modelo optimista el resizer cree haber terminado antes de tiempo, y las violaciones aparecen
recién en el STA final. La variable `LAYERS_RC` de LibreLane permite darle los valores medidos.

## 2. Qué se corrió

`asic/rom/config_rc.yaml` es `asic/rom/config.yaml` (la configuración final: D15, D20, D21,
`EarlyRead=1`) más el bloque `LAYERS_RC` que escribió el frente C: el tech LEF escalado por esquina
con los factores de la regresión de 2.399 nets (capacidad 2,93 / 2,59 / 2,30 y resistencia 2,18 /
1,99 / 1,81 para max, nom y min). Las corridas agregan además, por línea de comandos:

```
RUN_POST_GRT_DESIGN_REPAIR=true
GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30
GRT_DESIGN_REPAIR_MAX_CAP_PCT=30
RUN_POST_GRT_RESIZER_TIMING=true
```

La misma configuración se corrió sobre los dos RTL, para que la comparación sea del diseño y no de
la configuración:

| tags | RTL | worktree |
|---|---|---|
| `co_rc_*` | la candidata (A+B2) | `build/exp_candidata_rc` (esta rama) |
| `co_rcm_*` | el de `main` | `build/main_rc`, worktree desprendido de `main` |

Los reportes de las corridas de `main` están copiados a `asic/main_rc/resultados/<tag>/` de esta
rama, y los de la candidata a `asic/rom/resultados/<tag>/`, los dos con `asic/recolectar.py`.
Tablas en `asic/barrido_exp.md` (candidata) y `asic/main_rc/barrido_rc.md` (main).

## 3. Resultado

| corrida | RTL | T (ns) | cierra | WNS setup max_ss (ns) | TNS setup (ns) | hold peor (ns) | área stdcell (µm²) | slew / cap |
|---|---|---|---|---|---|---|---|---|
| `co_rcm_t100` | main | 100 | sí | 65.276 | 0.000 | 0.158 | 201.309 (110,4 por ciento de main) | 2 / 1 |
| `co_rcm_t23` | main | 23 | sí | 0.756 | 0.000 | 0.158 | 212.530 | 0 / 1 |
| `co_rcm_t22` | main | 22 | sí | 0.215 | 0.000 | 0.157 | 214.348 | 0 / 1 |
| `co_rcm_t21p5` | main | 21,5 | **no** | -0.383 | -15.730 | 0.157 | 215.406 | 3 / 1 |
| `co_rc_t100` | candidata | 100 | sí | 65.725 | 0.000 | 0.173 | 208.439 (114,4 por ciento de main) | 0 / 1 |
| `co_rc_t25` | candidata | 25 | sí | 1.579 | 0.000 | 0.173 | 219.531 | 0 / 1 |
| `co_rc_t24` | candidata | 24 | sí | 1.755 | 0.000 | 0.173 | 220.655 | 4 / 1 |
| `co_rc_t23` | candidata | 23 | sí | 1.494 | 0.000 | 0.173 | 222.714 | 4 / 1 |
| `co_rc_t22` | candidata | 22 | sí | 0.656 | 0.000 | 0.173 | 224.767 | 0 / 1 |
| `co_rc_t21p5` | candidata | 21,5 | sí | 0.876 | 0.000 | 0.173 | 231.229 | 0 / 1 |
| `co_rc_t21` | candidata | 21 | **no** | -0.129 | -0.291 | 0.173 | 231.638 | 6 / 1 |
Período mínimo con esta configuración: **22 ns** para el RTL de `main` (45,5 MHz; 21,5 ns no cierra
por 0,383 ns) y **21,5 ns** para el de la candidata (46,5 MHz; 21 ns no cierra por 0,129 ns). Las
dos cierran la regla de 0,5 ns de resolución. Con el CPI de cada uno eso son 17,1 MIPS para `main`
y **27,9 MIPS** para la candidata.


## 4. Qué dice

1. **La candidata no es intrínsecamente más lenta que `main`.** Con los parásitos medidos los dos
   bajan de 24,5 y 25,5 ns a 22 y 21,5 ns, y a 23 ns la candidata cierra con el doble de
   margen que `main` (1,494 contra 0,756 ns en `max_ss_125C_4v50`). El nanosegundo de diferencia de
   la configuración del enunciado lo produce la estimación de parásitos con la que el resizer
   decide dónde poner buffers, no la ruta nueva del pipeline.
2. **Esta configuración no puede ser la corrida final** del enunciado: su área de celdas estándar a
   100 ns es 110,4 por ciento de la de `main` sobre el RTL de `main` y 114,4 por ciento sobre el de
   la candidata, las dos por encima del límite de 105 por ciento que fijó la regla de selección de
   la sesión. Por eso el período mínimo que se reporta en `asic/exploraciones.md` y en
   `docs/propuesta_d23.md` sigue siendo el de la configuración del enunciado.
3. **Deja 0 violaciones de max slew en las 9 esquinas** en los dos diseños a 100 ns, lo que
   confirma el diagnóstico del frente C: las 546 violaciones de slew de la corrida final no son un
   problema del diseño sino del modelo con que el flujo decide el buffering. El pin de capacitancia
   que queda es siempre la raíz del árbol de reloj, que `repair_design` no toca.

## 5. Reproducción

Desde la raíz del repositorio principal, con la cola de corridas andando (`bash asic/cola.sh &`):

```
OPC="RUN_POST_GRT_DESIGN_REPAIR=true GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30 \
     GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 RUN_POST_GRT_RESIZER_TIMING=true"
git worktree add -b exp/candidata-rc build/exp_candidata_rc exp/pipeline-b2
git worktree add --detach build/main_rc main
# config_rc.yaml de cada worktree: su config.yaml más el bloque LAYERS_RC de este archivo
bash asic/encolar.sh build/exp_candidata_rc asic/rom/config_rc.yaml co_rc_t100 100 $OPC
bash asic/encolar.sh build/main_rc          asic/rom/config_rc.yaml co_rcm_t100 100 $OPC
# y los períodos del barrido
```
