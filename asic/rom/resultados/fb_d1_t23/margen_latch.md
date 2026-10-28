Margen real de setup en `asic/rom/runs/fb_d1_t23/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack -3.817 ns, de `_4559_` (rising edge-triggered flip-flop clocked by clk) a `_4536_` (rising edge-triggered flip-flop clocked by clk).
- Mayor préstamo de tiempo en latches: 3.404 ns de 10.881 ns disponibles, en `u_soc.u_core.u_rf/g_reg[15].g_bit[6].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_3382_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[15].g_bit[6].u_lat.u_lat`).
- Bloque de la peor ruta a flip-flop escrito en `asic/rom/resultados/fb_d1_t23/max_ss_125C_4v50_ruta_ff.rpt`.
