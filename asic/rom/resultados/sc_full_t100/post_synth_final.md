# Simulación post-PnR funcional del netlist de sc_full_t100

Comando (desde el worktree, Icarus del host 14.0-devel): `make post-synth-final NETLIST_FINAL=asic/rom/runs/sc_full_t100/final/nl/asic_top.nl.v`
(tb/post_synth_tb.v, 320.000 ciclos, estímulos asic/sim/estimulos_final.txt, DebounceDivBits=15, comparación con asic/sim/comparar.py).

```
RTL: 3 cambios de salida, 0 con valores X
netlist: 3 cambios de salida, 0 con valores X
trazas identicas (3 lineas RTL, 3 lineas netlist)
PASS
```

Traza del netlist (build/post_synth/traza_netlist_final.txt):
```
0 led=0000 disp=00
262156 led=1111 disp=00
262194 led=1111 disp=01
```
