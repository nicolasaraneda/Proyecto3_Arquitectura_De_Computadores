- [hecho] cierre.md de pa_b2_t100/t26/t25p5/t25 regenerados en la rama (verificar_cierre.py).
- [hecho] Figuras y ruta critica de pa_b2_t100 y pa_b2_t25p5 (asic/layout/anotar.sh).
- [hecho] asic/tablas.sh adaptado y asic/final.md con pa_b2_* y m_final (enlace a la final de main).
- [hecho] Commit 6c4b418 (primera parte).
- [en curso] DRC de KLayout y control positivo sobre pa_b2_t100 (log asic/logs/e1_layout_drc.log).
- [encolado] 89 e1_g30_t100, 90 e1_h100, 91 e1_full_t100, 92 e2_t100, 93 e1_sim_rom, 94 e1_pnr,
  95 e1_u75, 96 e1_u78.
- [pendiente] post-synth con el netlist e1_sim_rom; SDF sobre e1_pnr en 3 esquinas; e1_u70 y el
  resto del barrido de utilizacion; periodo minimo de la estrategia 2; asic/sintesis.md con
  e1_h100; docs/candidata.md, docs/datos_informe.md y docs/progreso.md; push.

## Estado a las 08:05
- Terminadas y procesadas: e1_g30_t100 (cierra; slew 279, cap 32, area 188.798), e1_h100
  (sintesis jerarquica, asic/sintesis.md), e1_full_t100 (cierra; slew 0, cap 0, area 209.185 =
  114,8 % de main, fuera del limite), e1_sim_rom (netlist de simulacion), e1_pnr (corrida
  completa de config_pnr.yaml), e1_u75 (cierra; die 229.251, utilizacion real 86,9 %),
  e2_t100 (cierra; area 843.767, die 1.801.610, WNS 30,802 ns en max_ss).
- make post-synth PASS con el netlist e1_sim_rom y control negativo FAIL con ATRASO=8.
- SDF: nom_tt PASS (3 de 3, md5 iguales), max_ss PASS; min_ff en curso (log asic/logs/e1_sdf_otras.log).
- En la cola: 96 e1_u78 (corriendo), 100 e1_g30_t25p5 (corriendo), 101 e1_g30_t25, 102 e1_u70,
  103 e2_t70, 104 e2_t65.
- Decision pendiente: si e1_g30 cierra a 25,5 ns se usa esa configuracion para el paquete
  (slew 279 contra 571 y area 188.798 < 191.378, el limite de 105 % de main); si pierde periodo,
  se queda la base (MIPS es la metrica principal).

## Estado a las 09:15
- Todo el paquete hecho y empujado: git push -u origin exp/candidata (12 commits sobre be50893).
- Barrido de utilizacion completo (50 a 78 cierran, 80 y 90 fallan con falla.txt).
- Estrategia 2: periodo minimo 69,5 ns (e2_t69p5 cierra, e2_t69 no), 7,5 ns peor que main.
- Signoff: el paquete se queda con la configuracion base porque e1_g30 no cierra a 25,5 ns.
- En curso: make post-synth-final con el netlist de pa_b2_t100 (320.000 ciclos), log
  asic/logs/e1_post_synth_final.log. Es lo unico que falta del paquete.
- NO se hizo: CVC (timing checks evaluados) ni las ventanas espera/display/rafaga de potencia.
