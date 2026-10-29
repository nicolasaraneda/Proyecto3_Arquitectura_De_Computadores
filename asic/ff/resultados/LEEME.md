# Qué corrida es cada tag de asic/ff/ (estrategia 2 de memoria)

Aviso de colisión de tags, agregado al integrar D23. Este directorio tiene corridas de tres épocas
distintas y dos de ellas usan el mismo nombre en ramas distintas. Para no confundirlas:

| tag | de qué época es | configuración | RTL | cifras clave |
|---|---|---|---|---|
| `s2_*` | las primeras corridas completas de la estrategia 2 (barrido de período de la sección 3.2 de v1) | `asic/ff/config.yaml` | el de v1 | período mínimo 62 ns; `s2_t100`: 838.173 µm² de celdas, 4.602 flip-flops, die 1.794.180 µm², 1 net con violación de antena |
| `s2_t100_diodos` y `s2_t100_antrep` | las dos soluciones de esa violación de antena | `asic/ff/config.yaml` más las perillas de antena | el de v1 | 0 nets en violación; ver `docs/datos_informe.md` 3.6 |
| `b2_*` | exploración del bloque B sobre la estrategia 2 | `asic/ff/config.yaml` | el de v1 | en `asic/barrido.md` |
| **`e2_t100`** | **una de las primeras corridas completas (commit `fbc16a0`), NO la de la candidata** | `asic/ff/config.yaml` | el de v1 | 906.413 µm² de celdas, 4.602 flip-flops, die 1.792.600 µm², 1 net con violación de antena |
| **`s4_*`** | **la estrategia 2 con el core y la configuración de D23** | `asic/ff/config_final.yaml` | el de la corrida final (`EarlyRead = 0` por omisión con `MemStrategy = 2`) | en `asic/final.md`, sección "Estrategia 2 de memoria con la configuración final" |

**Cuidado con `e2_t100`.** En la rama `exp/candidata` hay otra corrida con ese mismo tag, que sí es
la estrategia 2 con el core nuevo y la configuración de v1
(`build/exp_candidata/asic/ff/resultados/e2_t100/metrics.json`: 843.767 µm², 4.673 flip-flops, die
1.801.610 µm² y **0** nets con violación de antena). Las dos existen y dan números distintos, así
que cualquier cifra de la estrategia 2 hay que citarla diciendo de qué árbol sale. **Para el informe
la fuente de la estrategia 2 son las corridas `s4_*`**, que son las únicas con el core y la
configuración de la corrida final.
