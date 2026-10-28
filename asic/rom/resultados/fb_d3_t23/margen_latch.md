Margen real de setup en `asic/rom/runs/fb_d3_t23/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack -3.089 ns, de `_4333_` (rising edge-triggered flip-flop clocked by clk) a `_4183_` (rising edge-triggered flip-flop clocked by clk).
- Mayor préstamo de tiempo en latches: 3.406 ns de 10.822 ns disponibles, en `u_soc.u_core.u_rf/g_reg[13].g_bit[17].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_2173_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[13].g_bit[17].u_lat.u_lat`).
- Bloque de la peor ruta a flip-flop escrito en `asic/rom/resultados/fb_d3_t23/max_ss_125C_4v50_ruta_ff.rpt`.
