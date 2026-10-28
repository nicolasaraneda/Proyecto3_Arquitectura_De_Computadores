Margen real de setup en `asic/rom/runs/fb_m15_t100/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack 67.622 ns, de `_4670_` (rising edge-triggered flip-flop clocked by clk) a `_4552_` (rising edge-triggered flip-flop clocked by clk).
- Mayor préstamo de tiempo en latches: 3.521 ns de 49.324 ns disponibles, en `u_soc.u_core.u_rf/g_reg[6].g_bit[2].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_2016_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[6].g_bit[2].u_lat.u_lat`).
- Bloque de la peor ruta a flip-flop escrito en `asic/rom/resultados/fb_m15_t100/max_ss_125C_4v50_ruta_ff.rpt`.
