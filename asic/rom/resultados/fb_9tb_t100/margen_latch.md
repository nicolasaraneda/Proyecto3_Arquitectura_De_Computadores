Margen real de setup en `asic/rom/runs/fb_9tb_t100/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` (1186 rutas: 706 a flip-flop o puerto, 480 a latch)

- Peor ruta a flip-flop o puerto: slack 70.544 ns, de `_4528_` (rising edge-triggered flip-flop clocked by clk) a `seg1[2]` (output port clocked by clk).
- Mayor préstamo de tiempo en latches: 2.926 ns de 49.327 ns disponibles, en `u_soc.u_core.u_rf/g_reg[2].g_bit[10].u_lat.u_lat` (desde `u_soc.u_core.u_rf/_2024_`); slack reportado 0.000 ns.
- Peor slack entre endpoints de latch: 0.000 ns (`u_soc.u_core.u_rf/g_reg[2].g_bit[10].u_lat.u_lat`).
- Bloque de la peor ruta a flip-flop escrito en `asic/rom/resultados/fb_9tb_t100/max_ss_125C_4v50_ruta_ff.rpt`.
