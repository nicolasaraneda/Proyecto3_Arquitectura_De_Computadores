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
