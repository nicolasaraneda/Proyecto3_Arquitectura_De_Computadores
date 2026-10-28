# Post-sintesis con el netlist real de la candidata (make post-synth-final)

Netlist de `asic/rom/runs/pa_b2_t100/final/nl/asic_top.nl.v` (constantes reales del juego,
`DebounceDivBits=15`) contra el RTL con la misma ROM (`rtl/gen/pochoco_rom.v`), mismos estimulos
`asic/sim/estimulos_final.txt` y 320.000 ciclos:

```
make post-synth-final NETLIST_FINAL=asic/rom/runs/pa_b2_t100/final/nl/asic_top.nl.v
```

Salida de `asic/sim/comparar.py` (log completo: `asic/logs/e1_post_synth_final.log`):

```
RTL: 3 cambios de salida, 0 con valores X
netlist: 3 cambios de salida, 0 con valores X
trazas identicas (3 lineas RTL, 3 lineas netlist)
PASS
```

Traza (`build/post_synth/traza_netlist_final.txt`, idéntica a la del RTL): reposo
`led=0000 disp=00` en el ciclo 0, los cuatro LEDs en el ciclo 262.151 y el `01` de la primera
ronda en el 262.172. En `main` esos dos eventos caen en los ciclos 262.156 y 262.194
(`asic/sim/resultado_final.md` del repo principal): la candidata llega antes porque ejecuta el
mismo programa con menos ciclos por instrucción, y los eventos siguen igual entre su RTL y su
netlist, que es lo que prueba esta comparación.
