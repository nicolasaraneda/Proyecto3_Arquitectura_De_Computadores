# Progreso del cierre del Proyecto 3

Lista de tareas del bloque final, con su estado y el comando para retomar cada una.
Se actualiza al cerrar cada tarea para que otra sesión pueda continuar.

Convenciones: las corridas de LibreLane se lanzan desde la raíz con el entorno
activado (`source ~/herramientas/librelane/bin/activate`); máximo 3 a la vez
(`PAR=3 bash asic/barrido.sh < lista.txt`) y con `bash asic/vigilar.sh &` corriendo
(detiene las que pasen de 40 min o si la memoria usada pasa de 26000 MB). No lanzar
corridas nuevas si `free -m` muestra más de 20000 MB usados.

| Tarea | Estado | Cómo retomar / verificar |
|---|---|---|
| A0 metrics.json versionados | hecha | `git check-ignore -v asic/rom/resultados/p1_t100/metrics.json` debe devolver la regla `!asic/**/resultados/**/metrics.json` |
| A1 D20 y D21 en la configuración | hecha | `asic/rom/config.yaml`, `asic/rom/pines.cfg`, `docs/decisiones.md` (D20, D21). Prueba: `librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag prueba_pines --to Odb.CustomIOPlacement` |
| A2 `make final` | hecha: `asic/final.sh --sin-corrida` corrió de punta a punta (9 min, exit 0) y regeneró tablas, síntesis, figuras, DRC de KLayout, simulaciones y versiones | `make final` (asic/final.sh); `bash asic/final.sh --sin-corrida` regenera solo los análisis |
| A3 barrido de período con la configuración final | hecha: cierra a 100, 32, 30, 26 y 25 ns; 24 no (-0,004 ns); período mínimo 25 ns (40 MHz); f1_t28 detenida a los 40 min; RTL 116fa20: r0_t100 cierra (WNS 54,6), r0_t26 no (-3,175). Tablas en asic/final.md, gráfico docs/figuras/periodo.png | `PAR=3 bash asic/barrido.sh < lista` con `asic/rom/config.yaml f1_tNN NN`; tabla: `python3 asic/recolectar.py --md asic/barrido.md --titulo ... asic/rom/runs/f1_*`; gráfico: `python3 asic/graficos.py --periodo ...` |
| A4 barrido de FP_CORE_UTIL, pines automáticos, costo | hecha: 50, 60 y 70 % cierran (mínima 0,239 mm² a 70 %), 80 % falla en CTS, 90 % en placement global; u1_auto comparada con D21. Tabla en asic/final.md, gráfico docs/figuras/utilizacion.png, costo en docs/datos_informe.md | `asic/rom/config.yaml u1_uNN 100 FP_CORE_UTIL=NN`; gráfico: `python3 asic/graficos.py --util asic/rom/runs/final asic/rom/runs/u1_u*` |
| A5 síntesis jerárquica y `asic/sintesis.md` | hecha | `python3 asic/analisis_sintesis.py --final asic/rom/runs/final --jerarquica asic/rom/runs/h2_t100 --md asic/sintesis.md` |
| A6a figuras del layout (`asic/layout/anotar.py`) | hecha para final, f1_t25, f1_t26, s1_t55 y p1_t42 | `make layout RUN=asic/rom/runs/<tag>` (KLayout en Docker) |
| A6b antena de la estrategia 2 | hecha: s2_t100_diodos 0 violaciones (36.385 celdas de antena, +18 % de área) y s2_t100_antrep 0 violaciones (258 celdas); figura antes en asic/ff/resultados/s2_t100/layout, evidencia del después en los antenna_summary.rpt (en esas corridas net3342 es otro net con el mismo nombre; ver datos_informe.md 3.6) | `bash asic/layout/anotar.sh asic/ff/runs/s2_t100 -rd net=net3342 -rd nombre=antena_antes` |
| A6c DRC de KLayout con el deck del PDK | hecha: 0 marcadores en 684 reglas (asic/rom/resultados/final/drc_klayout/resumen.md) | `bash asic/drc_klayout.sh asic/rom/runs/final` (deck en asic/drc, ver asic/drc/ORIGEN.md) |
| A6d avisos de la corrida final | hecha | `asic/rom/resultados/final/avisos.md` |
| A6e `docs/layout.md` | hecha | `docs/layout.md` |
| A7 simulación post-síntesis (`make post-synth`) | hecha: PASS, 0 X; post-synth-final PASS (pulsación real, 320k ciclos); SDF: iverilog necesita -gspecify -ginterconnect, en prueba | `make post-synth`; estímulos: `python3 asic/sim/calibrar.py`; resultado en asic/sim/resultado.md |
| A8 README final | hecha (versiones, corrida final, make final, estructura) | README.md |
| A9 `docs/datos_informe.md` y `docs/defensa.md` | hechas; se completan con los resultados del bloque B a medida que llegan | |
| B1 exp/signoff | hecha: 9 variantes a 100 ns y las dos mejores a 26 ns; no se llega a cero; dentro del 1 % de área la mejor es b1c (489/19, +0,5 %), b1g da 259/21 con +1,2 %; las dos cierran a 26 ns | `build/exp_signoff`, asic/exploraciones.md |
| B2 exp/lsu-offset | hecha: cierra a 24 ns (41,7 MHz; main 25) y no a 23 ni 22, área -0,6 %; datos en la rama (asic/barrido_exp.md) | `build/exp_lsu_offset`, commit eb29650 |
| B3 exp/branch-cmp | hecha: sola no mejora (26 cierra, 24 no), área +0,9 %; combinación B2+B3 (exp/lsu-branch): 100 cierra, 24 no (-0,84), 26 detenida a los 40 min | commits 6ef475f (b3) y 35b2d5d (b23) |
| B4 exp/cpi | hecha: área -13,3 %, cierra a 60 ns y no a 55, 50 ni 45; CPI 1,31 en el juego; MIPS 12,7 contra 15,0 | `build/exp_cpi`, commit dbc8018 |
| B5 exp/rf-latch (opcional) | hecha: b5_t100 y b5_t26 cierran con DRC, LVS y antenas limpios (latches con préstamo de tiempo y chequeos de clock gating en el STA); área -9,3 % a 100 ns y -3,6 % a 26 ns; queda por barrer bajo 26 ns | `build/exp_rf_latch`, commit ba26813 |
| C1 GIF del chip construyéndose (opcional) | hecha: docs/figuras/construccion.gif (12 etapas) | `make animacion RUN=asic/rom/runs/final` |

## Rama exp/candidata (frente E, 28-10-2026): paquete de la candidata

Documento del frente: `docs/candidata.md`. Las corridas de LibreLane se encolan SOLO con la cola
de la sesión, desde la raíz del repo principal:
`bash asic/encolar.sh build/exp_candidata <config> <tag> <T> [VAR=VAL ...]` y
`bash asic/esperar.sh <tag> ...`; estado en `asic/logs/cola_estado.txt`.

| Tarea | Estado | Cómo retomar / verificar |
|---|---|---|
| E0 verificación de la rama | hecha por el frente A con el mismo RTL (commit be50893): make check PASS, make equiv funcional isa_test y hazard_test equivalentes con las dos estrategias, 0 X usados, mutaciones detectadas | `docs/verificacion/*.txt`, `docs/candidata.md` sección 1 |
| E1 corrida base a 100 ns y 40 % | hecha (reusada, no repetida): `pa_b2_t100` cierra; área de celdas 186.432 µm² = 102,3 % de main (límite 105 %) | `asic/rom/resultados/pa_b2_t100/cierre.md`; enlace en `asic/rom/runs/pa_b2_t100` |
| E2 barrido de período y ruta crítica | hecha (reusada): cierra a 100, 26 y 25,5; 25 no; mínimo 25,5 ns (39,2 MHz), brecha 0,5 ns. Ruta crítica anotada a 25,5 ns y a 100 ns | `asic/final.md`; `asic/rom/resultados/pa_b2_t25p5/layout/ruta_critica.txt` |
| E3 barrido de utilización a 100 ns | 70, 75 y 78 % cierran; 50, 60, 72, 80 y 90 % encolados | `bash asic/encolar.sh build/exp_candidata asic/rom/config.yaml e1_uNN 100 FP_CORE_UTIL=NN`; gráfico `docs/figuras/utilizacion.png` |
| E4 estrategia 2 con este RTL | e2_t100 cierra (área 843.767 µm², die 1.801.610 µm², WNS 30,802 ns); barrido de período en curso (e2_t70, e2_t65) | `asic/ff/resultados/e2_t100/cierre.md`, `asic/final.md` |
| E5 síntesis jerárquica | hecha: `e1_h100` y `asic/sintesis.md` regenerado | `python3 asic/analisis_sintesis.py --final asic/rom/runs/pa_b2_t100 --jerarquica asic/rom/runs/e1_h100 --md asic/sintesis.md` |
| E6 figuras del layout | hechas para pa_b2_t100 y pa_b2_t25p5 | `bash asic/layout/anotar.sh asic/rom/runs/<tag>` |
| E7 post-síntesis y SDF | hechas: post-synth PASS con el netlist `e1_sim_rom` y control negativo FAIL (ATRASO=8); SDF de `e1_pnr` PASS en nom_tt, max_ss y min_ff (3 de 3, mismo md5) | `make post-synth NETLIST_SIM=asic/sim/runs/e1_sim_rom/06-yosys-synthesis/asic_top.nl.v`; `make post-pnr-sdf ESQUINA=<esquina>`; `asic/sim/resultado.md`, `asic/sim/resultado_sdf.md` |
| E8 DRC de KLayout y control positivo | hechos: 0 marcadores en 684 reglas; el control marca M1.1 y M1.2a | `bash asic/drc_klayout.sh asic/rom/runs/pa_b2_t100`; `bash asic/drc/control_positivo.sh asic/rom/runs/pa_b2_t100` |
| E9 variantes de signoff del frente C sobre este RTL | hechas: e1_g30_t100 (279/32, +1,27 % de área) y e1_full_t100 (0/0, +12,2 %, fuera del límite de 105 % de main); e1_g30 NO cierra a 25,5 ns, así que el paquete se queda con la configuración base | `asic/final.md` sección de signoff, `docs/candidata.md` sección 7 |
| E10 potencia | hecha: sin actividad 8,597 mW (nom_tt) y con actividad real de la ventana polling 12,392 mW; método reducido del frente D3 | `SOLO_POLLING=1 bash asic/potencia/correr.sh sim` y `... sta`; `asic/potencia/resultado.md` |
| E11 tablas, datos del informe y progreso | hechas: `asic/tablas.sh` adaptado a los tags de la rama, `asic/final.md`, `asic/sintesis.md`, `docs/datos_informe.md` con un bloque Candidata por sección | `bash asic/tablas.sh` |
