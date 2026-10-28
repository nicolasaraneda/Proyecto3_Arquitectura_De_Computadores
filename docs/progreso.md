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

## Sesión del 27 y 28-10-2026: reapertura de la optimización y paquete de decisión

La entrega y la defensa se aplazaron al 11-11-2026. Esta sesión reabrió todo lo que se podía
optimizar o verificar mejor, con una regla de selección fija (métrica principal
MIPS = f máx / CPI del juego completo, período barrido hasta 0,5 ns de resolución, límite de área
de 105 por ciento de la de `main` y cierre completo a 100 ns y 40 por ciento), siete frentes en
paralelo y una cola única de corridas de LibreLane.

Infraestructura nueva: `asic/cola.sh` (daemon que lanza como máximo 3 corridas a la vez, corta a
los 40 minutos, no lanza con menos de 6 GB de memoria disponible ni menos de 60 GB de disco),
`asic/encolar.sh` y `asic/esperar.sh`; estado de cada corrida en `asic/logs/cola_estado.txt`.
Tablas: `asic/tabla_sesion.py` con `asic/ramas_sesion.json`.

| Frente | Estado | Dónde está |
|---|---|---|
| A: lectura del banco y decode en el fetch | hecha: `exp/pipeline` (26 ns, 23,1 MIPS), `exp/pipeline-b2` (25,5 ns, 23,6 MIPS, base de la candidata) y `exp/pipeline-b5` (30 ns, 20,0 MIPS). Verificación completa: check, equiv funcional, `sw/hazard_test.s`, mutaciones, monitor de X, post-synth y revisión independiente | ramas `exp/pipeline*`, `docs/pipeline.md` de la rama, `asic/exploraciones.md` |
| B: frecuencia máxima con el core actual | hecha: `exp/fmax` (B2+B5) cierra a 23,5 ns y, con `RUN_POST_GRT_RESIZER_TIMING`, a 23,25 ns (43,0 MHz), con 9,3 por ciento menos de área; con el CPI actual son 16,1 MIPS. Las estrategias de síntesis y la biblioteca de 9 pistas no aportan | rama `exp/fmax`, `docs/fmax.md` de la rama |
| C: cero violaciones de slew y capacitancia | hecha: se alcanza 0 slew (`sc_full_t100`) pero cuesta 7,5 por ciento de área; dentro del 1 por ciento la mejor deja 214 slew y pierde período | rama `exp/signoff0`, `docs/signoff0.md` de la rama |
| D1: simulación post-PnR con SDF | hecha: corrida completa `d1_pnr`, Icarus 13.0 de la imagen (no evalúa los timing checks, se dice explícitamente) y Open Verilog CVC 7.00b (sí los evalúa, con control positivo), tres esquinas, tres repeticiones | `asic/sim/resultado_sdf.md`, `asic/sim/post_pnr_sdf.sh`, `asic/sim/cvc_sdf.sh` |
| D2: equivalencia formal | hecha: eqy con el liberty típico como modelo de celda, RTL contra el netlist de síntesis y contra el post-PnR sin celdas físicas, con control negativo; el paso `Yosys.EQY` del flujo no sirve para este PDK | `docs/equivalencia.md`, `asic/eqy/` |
| D3: potencia con actividad real | hecha: VCD del netlist de la corrida final en cuatro ventanas del juego, OpenSTA con SPEF y liberty de las 9 esquinas: 11,5 a 12,8 mW contra los 8,97 mW sin actividad en nom_tt | `asic/potencia/resultado.md`, `asic/potencia/` |
| D4: barridos finos de `main` | hecha: utilización 72, 75 y 78 por ciento cierran (área mínima 0,216 mm²), 79 por ciento falla en CTS; `DIE_AREA` absoluto 1,6:1 cierra sin ganancia; 24,5 ns cierra, así que el período mínimo de `main` es 24,5 ns (40,8 MHz, 15,3 MIPS) | `asic/final.md`, `docs/datos_informe.md`, commit `b8770c1` |
| E: paquete de la rama candidata | en curso: `exp/candidata` (A+B2) con corrida a 100 ns, barrido de período, utilización, las dos estrategias de memoria, síntesis jerárquica, figuras, post-synth, SDF y DRC de KLayout | rama `exp/candidata` |
| Paquete de decisión | hecha: `docs/propuesta_d23.md` y D23 en estado de propuesta, con "Elegida: pendiente (Nicolás)" | `docs/propuesta_d23.md`, `docs/decisiones.md` |
