Margen real de setup en `asic/rom/runs/fb_pgrt_t100/56-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack 67.962 ns, de `_4670_` (rising edge-triggered flip-flop clocked by clk) a `_4551_` (rising edge-triggered flip-flop clocked by clk).
- Mayor préstamo de tiempo en latches: 3.609 ns de 49.329 ns disponibles, en `u_soc.u_core.u_rf/g_reg[6].g_bit[2].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_2016_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[6].g_bit[2].u_lat.u_lat`).
