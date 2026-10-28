# Modelo de cable del resizer derivado de `build/exp_rf_latch/asic/rom/runs/b5_t100`

Generado por `python3 asic/modelo_cable.py build/exp_rf_latch/asic/rom/runs/b5_t100`. Ningún valor de este archivo
está escrito a mano: todos salen de la extracción y del tech LEF de esa corrida.

## 1. Lo que estima el resizer

`14-openroad-dumprcvalues/resizer_values_after.rpt`, fila `Signal Avg`: **0.2752 ohm/µm** y **64.3 aF/µm**, el mismo par en las 9 esquinas. Es el promedio de las capas de ruteo del tech LEF, y es lo único con lo que `estimate_parasitics` alimenta a `repair_design`, `repair_timing` y al CTS.

Valores por capa del tech LEF (`tlef_values.rpt`), que son los que LAYERS_RC reemplaza:

| capa | res (ohm/µm) | cap (pF/µm) |
|---|---|---|
| Metal1 | 0.39130 | 9.2000e-05 |
| Metal2 | 0.32143 | 8.4000e-05 |
| Metal3 | 0.32143 | 7.8400e-05 |
| Metal4 | 0.32143 | 7.7560e-05 |
| Metal5 | 0.13636 | 1.7336e-05 |

## 2. Lo que la extracción mide

Regresión lineal sobre los nets de más de 20 µm de la corrida: capacidad de cable del SPEF contra largo ruteado, y resistencia total del SPEF contra largo ruteado. El factor es la pendiente medida dividida por el valor que usa el resizer, y es lo que la estimación deja de ver.

| extracción | nets | cap: pendiente (aF/µm) | cap: ordenada (aF) | cap/largo mediana (aF/µm) | R: pendiente (ohm/µm) | R: ordenada (ohm) | R/largo mediana (ohm/µm) | factor cap | factor R |
|---|---|---|---|---|---|---|---|---|---|
| max | 2399 | 188.4 | 652 | 197.0 | 0.599 | 26.7 | 0.949 | 2.93 | 2.18 |
| nom | 2399 | 166.3 | 527 | 173.3 | 0.549 | 26.7 | 0.898 | 2.59 | 1.99 |
| min | 2399 | 148.0 | 425 | 153.6 | 0.498 | 26.6 | 0.846 | 2.30 | 1.81 |

## 3. El bloque LAYERS_RC que sale de ahí

Cada valor por capa del tech LEF multiplicado por el factor de su extracción, de modo que el promedio con que estima el resizer coincida con la pendiente medida. Los patrones los expande LibreLane a las 9 esquinas. Unidades: ohm/µm y pF/µm.

```yaml
LAYERS_RC:
  "max_*":
    Metal1: {res: 0.85199, cap: 2.6941e-04}
    Metal2: {res: 0.69985, cap: 2.4598e-04}
    Metal3: {res: 0.69985, cap: 2.2958e-04}
    Metal4: {res: 0.69985, cap: 2.2712e-04}
    Metal5: {res: 0.29691, cap: 5.0766e-05}
  "nom_*":
    Metal1: {res: 0.78028, cap: 2.3788e-04}
    Metal2: {res: 0.64095, cap: 2.1719e-04}
    Metal3: {res: 0.64095, cap: 2.0271e-04}
    Metal4: {res: 0.64095, cap: 2.0054e-04}
    Metal5: {res: 0.27192, cap: 4.4824e-05}
  "min_*":
    Metal1: {res: 0.70858, cap: 2.1165e-04}
    Metal2: {res: 0.58205, cap: 1.9324e-04}
    Metal3: {res: 0.58205, cap: 1.8036e-04}
    Metal4: {res: 0.58205, cap: 1.7843e-04}
    Metal5: {res: 0.24693, cap: 3.9882e-05}
```

## 4. Comparación con `asic/rom/config.yaml`

**Coincide**: los 15 pares (capa, extracción) del bloque LAYERS_RC de `asic/rom/config.yaml` son exactamente los que se derivan de `build/exp_rf_latch/asic/rom/runs/b5_t100`, a los decimales con que se escriben (res con 5 decimales, cap con 4 cifras significativas).

