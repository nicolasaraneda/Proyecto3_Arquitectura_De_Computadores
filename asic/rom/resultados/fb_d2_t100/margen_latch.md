Margen real de setup en `asic/rom/runs/fb_d2_t100/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack 61.974 ns, de `_4590_` (rising edge-triggered flip-flop clocked by clk) a `_4325_` (rising edge-triggered flip-flop clocked by clk).
- Mayor préstamo de tiempo en latches: 3.536 ns de 49.356 ns disponibles, en `u_soc.u_core.u_rf/g_reg[1].g_bit[1].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_3395_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[1].g_bit[1].u_lat.u_lat`).
