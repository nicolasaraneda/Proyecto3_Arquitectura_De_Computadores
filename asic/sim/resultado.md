```
RTL: 17 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 51 (ciclos medidos) en el ciclo 1033
  ronda 02: acierto, el display muestra 51 (ciclos medidos) en el ciclo 2131
  pulsacion incorrecta en la ronda 02: EE en el ciclo 1405
  tras EE vuelve a la ronda 02 en el ciclo 1507 (la ronda NO avanzo)
netlist: 17 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 51 (ciclos medidos) en el ciclo 1033
  ronda 02: acierto, el display muestra 51 (ciclos medidos) en el ciclo 2131
  pulsacion incorrecta en la ronda 02: EE en el ciclo 1405
  tras EE vuelve a la ronda 02 en el ciclo 1507 (la ronda NO avanzo)
trazas identicas (17 lineas RTL, 17 lineas netlist)
PASS
```

## Control negativo

Netlist con `build/post_synth/estimulos_control.txt` (`asic/sim/atrasar.py`: la pulsación de la primera ronda, la segunda de `asic/sim/estimulos.txt`, atrasada 8 ciclos; diff contra los estímulos originales abajo) contra la traza del RTL con los estímulos originales. La comparación tiene que dar FAIL; `make post-synth-control` termina bien solo en ese caso. 8 es el atraso más chico que cambia la traza: el programa lee BTN en un lazo de polling de 8 ciclos y un atraso menor cae en la misma vuelta del lazo (con 7 ciclos la traza no cambia).

```
9c9
< 635 0010
---
> 643 0010
11c11
< 695 0000
---
> 703 0000
```

```
RTL: 17 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 51 (ciclos medidos) en el ciclo 1033
  ronda 02: acierto, el display muestra 51 (ciclos medidos) en el ciclo 2131
  pulsacion incorrecta en la ronda 02: EE en el ciclo 1405
  tras EE vuelve a la ronda 02 en el ciclo 1507 (la ronda NO avanzo)
netlist: 12 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 59 (ciclos medidos) en el ciclo 1089
  ronda 02: acierto, el display muestra 99 (ciclos medidos) en el ciclo 2438
primera diferencia en la linea 5: RTL=(1033, '0010', '51') netlist=(1089, '0010', '59')
trazas DISTINTAS (17 lineas RTL, 12 lineas netlist)
FAIL
```
