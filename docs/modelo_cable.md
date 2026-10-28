# El modelo de cable del resizer

Este documento explica una de las dos mitades de la corrida final de D23: la configuración
`LAYERS_RC` más la reparación después del ruteo global. La otra mitad, el RTL del pipeline, está en
`docs/pipeline.md`. Acá está la explicación de qué hace esta configuración, por qué el flujo la
necesitaba, cómo se midieron sus números y qué se ganó.

Viene de la rama `exp/candidata-rc` y del frente C (`exp/signoff0`); los valores por capa los deriva
`asic/modelo_cable.py` y el informe generado está en `asic/modelo_cable.md`.

## 1. Qué estima el resizer, y por qué tiene que estimar

El flujo de LibreLane no rutea los cables hasta bastante tarde. El orden de los pasos de la corrida
final es, en grueso:

1. síntesis (Yosys): el RTL se convierte en celdas estándar;
2. floorplan: se decide el tamaño del die y del core;
3. placement global y detallado: cada celda recibe una posición;
4. **`RepairDesignPostGPL`**: el *resizer* arregla lo que no cumple;
5. CTS: se construye el árbol de reloj; **`ResizerTimingPostCTS`** vuelve a arreglar;
6. ruteo global: se decide por dónde va cada net, pero sin la geometría exacta;
7. **`RepairDesignPostGRT`** y **`ResizerTimingPostGRT`** (los dos pasos que agrega D23);
8. ruteo detallado: la geometría definitiva de cada cable;
9. **`OpenROAD.RCX`**: OpenRCX extrae del ruteo detallado la resistencia y la capacidad de verdad
   de cada net y las escribe en archivos SPEF;
10. **`STA` final**: el análisis de tiempos de firma, con esos SPEF.

El resizer es el paso que arregla el circuito: cambia una celda por otra más grande cuando maneja
mucha carga, y parte un net largo con buffers cuando la señal llega demasiado lenta (eso es una
violación de *max slew*: la transición de 0 a 1 tarda más de lo que la biblioteca permite). Para
decidir dónde hacerlo necesita saber **cuánto pesa cada cable**: un cable tiene resistencia y
capacidad, y las dos crecen con el largo.

El problema de orden es evidente: en el paso 4 y en el 5 **todavía no hay cables**. Solo hay celdas
puestas en el piso. Entonces el resizer **estima**: supone que el net va a ir más o menos en línea
recta entre los pines (el árbol de Steiner del placement, o el ruteo global si ya existe), mide ese
largo en micrómetros y lo multiplica por una resistencia por micrómetro y una capacidad por
micrómetro. Esa multiplicación es la función `estimate_parasitics` de OpenROAD, y esos dos números
por unidad de largo son todo el modelo de cable que tiene.

## 2. Por qué la estimación del tech LEF era optimista

El PDK describe sus capas de metal en el *tech LEF*, y ahí cada capa tiene su propia resistencia y
su propia capacidad por micrómetro. El flujo las vuelca en
`14-openroad-dumprcvalues/tlef_values.rpt`:

| capa | res (ohm/µm) | cap (pF/µm) |
|---|---|---|
| Metal1 | 0,39130 | 9,2000e-05 |
| Metal2 | 0,32143 | 8,4000e-05 |
| Metal3 | 0,32143 | 7,8400e-05 |
| Metal4 | 0,32143 | 7,7560e-05 |
| Metal5 | 0,13636 | 1,7336e-05 |

Pero el resizer **no usa la tabla**: usa un solo par de números, el promedio de las capas de ruteo.
El flujo lo deja escrito en `14-openroad-dumprcvalues/resizer_values_after.rpt`, fila `Signal Avg`:
**0,2752 ohm/µm y 64,3 aF/µm**, el mismo par en las nueve esquinas. Un attofarad son 10⁻¹⁸ faradios;
64,3 aF/µm es 0,0000643 pF/µm.

Ese promedio es optimista por dos razones que se suman:

1. **Es un promedio de la tabla, y la tabla no incluye todo.** El valor de capacidad del tech LEF de
   una capa es la capacidad de esa capa contra el sustrato, con el cable solo. En un chip real el
   cable tiene vecinos: arriba, abajo y a los lados hay otros cables, y cada vecino agrega
   capacidad de acoplamiento. OpenRCX sí cuenta eso cuando extrae del ruteo detallado, porque ahí
   ya sabe quién está al lado de quién. El tech LEF no puede saberlo.
2. **Un cable real no va en línea recta y no vive en una sola capa.** Sube y baja de capa por vías
   (que agregan resistencia), da vueltas para esquivar obstáculos y se reparte entre varias capas.

Para ver cuánto se equivoca basta comparar las dos cosas sobre la misma corrida. Eso es lo que hace
`asic/modelo_cable.py`: toma los SPEF que dejó OpenRCX, el largo ruteado de cada net
(`*-odb-reportwirelength/wire_lengths.csv`) y hace una **regresión lineal** de la capacidad de cable
extraída contra el largo, sobre los **2.399 nets de más de 20 µm** de la corrida (los nets más
cortos se descartan porque en ellos manda la ordenada, es decir la capacidad fija de las vías y los
extremos, y no la pendiente, que es lo que se quiere medir). La pendiente de esa recta es la
capacidad por micrómetro que el ruteo real tiene. Lo mismo con la resistencia total.

Resultado (`asic/modelo_cable.md`, sección 2; corrida `b5_t100` de `exp/rf-latch`):

| extracción | nets | cap medida (aF/µm) | cap que estima el resizer | factor | R medida (ohm/µm) | R que estima el resizer | factor |
|---|---|---|---|---|---|---|---|
| max | 2.399 | 188,4 | 64,3 | **2,93** | 0,599 | 0,2752 | **2,18** |
| nom | 2.399 | 166,3 | 64,3 | **2,59** | 0,549 | 0,2752 | **1,99** |
| min | 2.399 | 148,0 | 64,3 | **2,30** | 0,498 | 0,2752 | **1,81** |

O sea: **el resizer cree que los cables pesan entre 2,3 y 2,9 veces menos de lo que pesan.** Las
tres filas son las tres extracciones de parásitos del PDK (max, nom y min: el proceso puede dejar
los metales más gruesos o más delgados, y eso cambia R y C).

La consecuencia práctica es la que importa para el informe: con parásitos de menos, el resizer
**cree haber terminado antes de tiempo**. Mira un net, calcula el slew con un cable tres veces más
liviano, le sale que cumple, y no pone el buffer. Después, en el paso 10, el STA final usa el SPEF
de verdad y la violación aparece. Por eso la corrida final de v1 tenía 546 pines con violación de
max slew (`asic/rom/resultados/v1_final/metrics.json`) aunque el flujo no hubiera informado ninguna
después del ruteo global: no era un problema del diseño, era el modelo con que el flujo decidía
dónde poner buffers.

## 3. Cómo se arregla, y qué cuesta

LibreLane tiene una variable, `LAYERS_RC`, que reemplaza la tabla del tech LEF por una propia, capa
por capa y esquina por esquina, para todos los pasos de OpenROAD
(`set_layer_rc -layer -corner` y `set_wire_rc -corner`). `asic/modelo_cable.py` la escribe tomando
cada valor del tech LEF y multiplicándolo por el factor de su extracción, de modo que el promedio
con que estima el resizer coincida con la pendiente medida. Eso es el bloque `LAYERS_RC` de
`asic/rom/config.yaml`.

Con el modelo corregido el resizer sí ve las violaciones y las repara, y dos pasos más del flujo
pasan a servir de algo, así que la configuración final los activa:

| variable | qué hace |
|---|---|
| `RUN_POST_GRT_DESIGN_REPAIR: true` | corre `repair_design` después del ruteo global, cuando ya hay un largo de cable de verdad en vez de una estimación del placement |
| `GRT_DESIGN_REPAIR_MAX_SLEW_PCT: 30` y `GRT_DESIGN_REPAIR_MAX_CAP_PCT: 30` | le pide reparar hasta dejar un 30 por ciento de margen bajo el límite, no solo hasta cumplir |
| `RUN_POST_GRT_RESIZER_TIMING: true` | corre `repair_timing` después del ruteo global. Sin `LAYERS_RC` este paso no sirve (estima con el promedio optimista y no encuentra qué arreglar); con `LAYERS_RC` sí |

Lo que esto cuesta es **área de celdas**: más buffers y celdas más grandes. Lo que gana es
**período** (el resizer arregla de verdad las rutas lentas) y **slew** (deja 0 violaciones de max
slew en las nueve esquinas). El que decide si el cambio conviene es D23, y la respuesta está ahí: el
área del die y el costo no cambian, porque el die lo fija `FP_CORE_UTIL = 40` sobre el área de la
síntesis y el área que gastan los buffers cabe adentro; lo único que sube es la utilización real del
core, de 47,9 a 53,5 por ciento.

## 4. La medición que llevó a la decisión

Antes de adoptarla se corrió la misma configuración sobre los **dos** RTL, para que la comparación
fuera del diseño y no de la configuración: el de v1 (worktree `build/main_rc`, tags `co_rcm_*`) y el
de la candidata (rama `exp/candidata-rc`, tags `co_rc_*`). En esa exploración `LAYERS_RC` iba en un
archivo aparte, `asic/rom/config_rc.yaml`, y las cuatro variables del post-GRT por línea de
comandos; desde D23 las dos cosas son `asic/rom/config.yaml`.

| corrida | RTL | T (ns) | cierra | WNS setup max_ss (ns) | TNS setup (ns) | hold peor (ns) | área stdcell (µm²) | slew / cap |
|---|---|---|---|---|---|---|---|---|
| `co_rcm_t100` | v1 | 100 | sí | 65,276 | 0,000 | 0,158 | 201.309 | 2 / 1 |
| `co_rcm_t23` | v1 | 23 | sí | 0,756 | 0,000 | 0,158 | 212.530 | 0 / 1 |
| `co_rcm_t22` | v1 | 22 | sí | 0,215 | 0,000 | 0,157 | 214.348 | 0 / 1 |
| `co_rcm_t21p5` | v1 | 21,5 | **no** | -0,383 | -15,730 | 0,157 | 215.406 | 3 / 1 |
| `co_rc_t100` | candidata | 100 | sí | 65,725 | 0,000 | 0,173 | 208.439 | 0 / 1 |
| `co_rc_t25` | candidata | 25 | sí | 1,579 | 0,000 | 0,173 | 219.531 | 0 / 1 |
| `co_rc_t24` | candidata | 24 | sí | 1,755 | 0,000 | 0,173 | 220.655 | 4 / 1 |
| `co_rc_t23` | candidata | 23 | sí | 1,494 | 0,000 | 0,173 | 222.714 | 4 / 1 |
| `co_rc_t22` | candidata | 22 | sí | 0,656 | 0,000 | 0,173 | 224.767 | 0 / 1 |
| `co_rc_t21p5` | candidata | 21,5 | sí | 0,876 | 0,000 | 0,173 | 231.229 | 0 / 1 |
| `co_rc_t21` | candidata | 21 | **no** | -0,129 | -0,291 | 0,173 | 231.638 | 6 / 1 |

Reportes copiados en `asic/rom/resultados/co_rc_*/` (candidata) y `asic/main_rc/resultados/co_rcm_*/`
(v1); tablas completas en `asic/barrido_exp.md` y `asic/main_rc/barrido_rc.md`.

Qué dice esa tabla:

1. **Con el modelo de cable corregido, el RTL de la candidata es más rápido que el de v1**, no más
   lento. v1 cierra a 22 ns (45,5 MHz; a 21,5 no cierra por 0,383 ns) y la candidata a 21,5 ns
   (46,5 MHz; a 21 no cierra por 0,129 ns). Las dos cierran la regla de la sesión de dejar 0,5 ns o
   menos entre el último período que cierra y el primero que no. A 23 ns la candidata tiene el doble
   de margen que v1 (1,494 contra 0,756 ns en `max_ss_125C_4v50`). Con el CPI de cada uno eso son
   17,1 MIPS para v1 y 27,9 MIPS para la candidata.
2. **El nanosegundo de desventaja que la candidata tenía con la configuración de v1 era de la
   herramienta, no del diseño.** Con la estimación optimista, el resizer dejaba de reparar antes en
   el diseño que tiene la ruta nueva del pipeline, y de ahí salían los 25,5 ns contra 24,5 ns.
3. **El modelo corregido deja 0 violaciones de max slew en las nueve esquinas** en los dos diseños a
   100 ns, lo que cierra el diagnóstico del frente C. El pin de capacitancia que queda es la raíz
   del árbol de reloj, que `repair_design` no toca.

## 5. Cómo reproducir los valores

Los valores de `LAYERS_RC` no están escritos a mano. El script que los deriva está versionado, y el
mismo script verifica que lo que hay en la configuración es lo que se deriva de la corrida (termina
con código distinto de cero si no coincide):

```
python3 asic/modelo_cable.py build/exp_rf_latch/asic/rom/runs/b5_t100 \
    --md asic/modelo_cable.md --comparar asic/rom/config.yaml
```

`b5_t100` es la corrida que midió el frente C: es la primera corrida completa de la sesión, con el
flujo **sin** `LAYERS_RC`, y por eso sirve para medir el error de la estimación por omisión. Para
medirlo sobre cualquier otra corrida completa basta cambiar el primer argumento; sobre una corrida
que ya use `LAYERS_RC`, los factores que informa son la comprobación de que el modelo ya coincide con
la extracción (deberían quedar cerca de 1).

Para rehacer las corridas de la exploración, con la cola de LibreLane andando
(`bash asic/cola.sh &`):

```
git worktree add --detach build/main_rc v1-final
# en build/main_rc: copiar asic/rom/config.yaml de main (lleva LAYERS_RC y el post-GRT)
#   sobre su propio asic/rom/config.yaml, pero SIN el EarlyRead=1 de SYNTH_PARAMETERS
bash asic/encolar.sh build/main_rc asic/rom/config.yaml co_rcm2_t100 100
bash asic/encolar.sh .            asic/rom/config.yaml co_rc2_t100  100
# y los períodos del barrido
```

## 6. Lo que queda dicho y lo que no

- La exploración midió el período mínimo de los dos RTL con esta configuración, el área, el slew y la
  capacitancia. **No** midió con esta configuración, en la exploración, la potencia, el DRC de
  KLayout, la simulación post-PnR ni el barrido de utilización: eso se mide sobre la corrida final
  nueva y está en `asic/final.md`, `docs/datos_informe.md` y `docs/hechos_flujo.md`.
- La corrida `b5_t100` sobre la que se derivaron los valores vive en un worktree
  (`build/exp_rf_latch`), que no está versionado: lo versionado es el script, su informe
  (`asic/modelo_cable.md`) y la comprobación de que la configuración coincide con lo derivado.
