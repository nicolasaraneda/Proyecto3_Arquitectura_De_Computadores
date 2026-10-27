Margen real de setup en `asic/rom/runs/fb_d1_t100/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack 63.959 ns, de `_4331_` (rising edge-triggered flip-flop clocked by clk) a `_4297_` (rising edge-triggered flip-flop clocked by clk).
- Mayor préstamo de tiempo en latches: 3.473 ns de 49.370 ns disponibles, en `u_soc.u_core.u_rf/g_reg[11].g_bit[6].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_3382_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[11].g_bit[6].u_lat.u_lat`).
