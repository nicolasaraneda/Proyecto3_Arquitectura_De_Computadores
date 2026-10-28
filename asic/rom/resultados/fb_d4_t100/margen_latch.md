Margen real de setup en `asic/rom/runs/fb_d4_t100/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack 66.992 ns, de `_5540_` (rising edge-triggered flip-flop clocked by clk) a `_5420_` (rising edge-triggered flip-flop clocked by clk).
- Mayor préstamo de tiempo en latches: 3.945 ns de 49.285 ns disponibles, en `u_soc.u_core.u_rf/g_reg[12].g_bit[15].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_1367_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[12].g_bit[15].u_lat.u_lat`).
- Bloque de la peor ruta a flip-flop escrito en `asic/rom/resultados/fb_d4_t100/max_ss_125C_4v50_ruta_ff.rpt`.
