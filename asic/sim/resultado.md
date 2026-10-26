```
RTL: 17 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 57 (ciclos medidos) en el ciclo 1574
  ronda 02: acierto, el display muestra 57 (ciclos medidos) en el ciclo 3492
  pulsacion incorrecta en la ronda 02: EE en el ciclo 2181
  tras EE vuelve a la ronda 02 en el ciclo 2353 (la ronda NO avanzo)
netlist: 17 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 57 (ciclos medidos) en el ciclo 1574
  ronda 02: acierto, el display muestra 57 (ciclos medidos) en el ciclo 3492
  pulsacion incorrecta en la ronda 02: EE en el ciclo 2181
  tras EE vuelve a la ronda 02 en el ciclo 2353 (la ronda NO avanzo)
trazas identicas (17 lineas RTL, 17 lineas netlist)
PASS
```

## Control negativo

Netlist con `build/post_synth/estimulos_control.txt` (`asic/sim/atrasar.py`: la pulsación de la primera ronda atrasada 6 ciclos, es decir los eventos 801 y 861 de `asic/sim/estimulos.txt` corridos a 807 y 867) contra la traza del RTL con los estímulos originales. La comparación tiene que dar FAIL; `make post-synth-control` termina bien solo en ese caso. Con un atraso de 5 ciclos la traza no cambia (el programa lee CYCLES en un lazo de polling de 13 ciclos y la pulsación cae en la misma vuelta), por eso el control usa 6, el atraso más chico que la cambia.

```
RTL: 17 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 57 (ciclos medidos) en el ciclo 1574
  ronda 02: acierto, el display muestra 57 (ciclos medidos) en el ciclo 3492
  pulsacion incorrecta en la ronda 02: EE en el ciclo 2181
  tras EE vuelve a la ronda 02 en el ciclo 2353 (la ronda NO avanzo)
netlist: 11 cambios de salida, 0 con valores X
  ronda 01: acierto, el display muestra 70 (ciclos medidos) en el ciclo 1748
  ronda 02: acierto, el display muestra 99 (ciclos medidos) en el ciclo 3987
primera diferencia en la linea 5: RTL=(1574, '0010', '57') netlist=(1748, '0010', '70')
trazas DISTINTAS (17 lineas RTL, 11 lineas netlist)
FAIL
```
