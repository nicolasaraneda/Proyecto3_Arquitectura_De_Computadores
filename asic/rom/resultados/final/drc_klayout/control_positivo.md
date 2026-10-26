# Control positivo del DRC de KLayout

Deck `asic/drc/gf180mcu.drc` sobre `build/drc_control/asic_top_control.gds`: el GDS de la corrida final con dos violaciones conocidas de Metal1 agregadas por `asic/drc/control_positivo.sh` en una zona vacía del die (esquina suroeste, de (2.500, 2.500) a (6.500, 6.500) µm, sin ninguna forma en 2 µm a la redonda). El GDS modificado no se versiona (está en `build/`).

## Figuras agregadas (Metal1, capa 34/0, coordenadas en µm)

| regla que debe marcar | figura | x0 | y0 | x1 | y1 |
|---|---|---|---|---|---|
| M1.1 | rectangulo angosto (ancho 0,20 um) | 3.500 | 3.000 | 3.700 | 5.000 |
| M1.2a | rectangulo A (ancho 0,50 um) | 5.000 | 3.000 | 5.500 | 5.000 |
| M1.2a | rectangulo B, a 0,15 um de A | 5.650 | 3.000 | 6.150 | 5.000 |

## Marcadores que dejó el deck

2 marcadores en 2 reglas (de 684 reglas evaluadas; el GDS original tiene 0 marcadores).

| regla | descripción del deck | marcador (coordenadas en µm) | dónde debía caer | cae ahí |
|---|---|---|---|---|
| M1.1 | M1.1 : min. metal1 width : 0.23µm | polygon: (3.499,2.999;3.499,5.001;3.701,5.001;3.701,2.999) | dentro del rectangulo angosto, (3.500, 3.000) a (3.700, 5.000) | sí |
| M1.2a | M1.2a : min. metal1 spacing : 0.23µm | polygon: (5.499,2.999;5.499,5.001;5.651,5.001;5.651,2.999) | en el hueco entre A y B, (5.500, 3.000) a (5.650, 5.000) | sí |

## Resultado

Reglas marcadas: M1.1, M1.2a; esperadas: M1.1, M1.2a. Marcadores dentro de su figura: todos.

**PASA**: el deck detecta las dos violaciones y no marca nada más.
