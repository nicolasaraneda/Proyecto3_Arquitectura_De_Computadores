# Progreso del cierre del Proyecto 3

Lista de tareas del bloque final, con su estado y el comando para retomar cada una.
Se actualiza al cerrar cada tarea para que otra sesión pueda continuar.

Convenciones: las corridas de LibreLane se lanzan con la **cola única**, no a mano:
`bash asic/cola.sh &` levanta el daemon (máximo 3 simultáneas, corte a los 40 minutos,
revisión de memoria y de disco), `bash asic/encolar.sh <dir> <config.yaml> <tag> <T> [VAR=VAL]`
encola, `bash asic/esperar.sh <tag>...` espera y `touch asic/logs/cola.fin` lo termina. El
tag tiene que ser único en toda la sesión. Bitácora en `asic/logs/cola_estado.txt`. No
lanzar corridas nuevas si `free -m` muestra más de 20000 MB usados.

| Tarea | Estado | Cómo retomar / verificar |
|---|---|---|
| A0 metrics.json versionados | hecha | `git check-ignore -v asic/rom/resultados/p1_t100/metrics.json` debe devolver la regla `!asic/**/resultados/**/metrics.json` |
| A1 D20 y D21 en la configuración | hecha | `asic/rom/config.yaml`, `asic/rom/pines.cfg`, `docs/decisiones.md` (D20, D21). Prueba: `librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag prueba_pines --to Odb.CustomIOPlacement` |
| A2 `make final` | hecha: `asic/final.sh --sin-corrida` corrió de punta a punta (9 min, exit 0) y regeneró tablas, síntesis, figuras, DRC de KLayout, simulaciones y versiones | `make final` (asic/final.sh); `bash asic/final.sh --sin-corrida` regenera solo los análisis |
| A3 barrido de período con la configuración final | hecha: cierra a 100, 32, 30, 26 y 25 ns; 24 no (-0,004 ns); período mínimo 25 ns (40 MHz); f1_t28 detenida a los 40 min; RTL 116fa20: r0_t100 cierra (WNS 54,6), r0_t26 no (-3,175). Tablas en asic/final.md, gráfico docs/figuras/periodo.png | `PAR=3 bash asic/barrido.sh < lista` con `asic/rom/config.yaml f1_tNN NN`; tabla: `python3 asic/recolectar.py --md asic/barrido.md --titulo ... asic/rom/runs/f1_*`; gráfico: `python3 asic/graficos.py --periodo ...` |
| A4 barrido de FP_CORE_UTIL, pines automáticos, costo | hecha: 50, 60 y 70 % cierran (mínima 0,239 mm² a 70 %), 80 % falla en CTS, 90 % en placement global; u1_auto comparada con D21. Tabla en asic/final.md, gráfico docs/figuras/utilizacion.png, costo en docs/datos_informe.md | `asic/rom/config.yaml u1_uNN 100 FP_CORE_UTIL=NN`; gráfico: `python3 asic/graficos.py --util asic/rom/runs/final asic/rom/runs/u1_u*` |
| A5 síntesis jerárquica y `asic/sintesis.md` | hecha | `python3 asic/analisis_sintesis.py --final asic/rom/runs/final --jerarquica asic/rom/runs/h3_t100 --md asic/sintesis.md` |
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
| A: lectura del banco y decode en el fetch | hecha: `exp/pipeline` (26 ns, 23,1 MIPS), `exp/pipeline-b2` (25,5 ns, 23,6 MIPS, base de la candidata) y `exp/pipeline-b5` (29 ns, 20,7 MIPS; la de 28 ns se detuvo a los 40 min). Verificación completa: check, equiv funcional, `sw/hazard_test.s`, mutaciones, monitor de X, post-synth y revisión independiente | ramas `exp/pipeline*`, `docs/pipeline.md` de la rama, `asic/exploraciones.md` |
| B: frecuencia máxima con el core actual | hecha: `exp/fmax` (B2+B5) cierra a 23,5 ns y, con `RUN_POST_GRT_RESIZER_TIMING`, a 23,25 ns (43,0 MHz), con 9,3 por ciento menos de área; con el CPI actual son 16,1 MIPS. Las estrategias de síntesis y la biblioteca de 9 pistas no aportan | rama `exp/fmax`, `docs/fmax.md` de la rama |
| C: cero violaciones de slew y capacitancia | hecha: se alcanza 0 slew (`sc_full_t100`) pero cuesta 7,5 por ciento de área; dentro del 1 por ciento la mejor deja 214 slew y pierde período | rama `exp/signoff0`, `docs/signoff0.md` de la rama |
| D1: simulación post-PnR con SDF | hecha: corrida completa `d1_pnr`, Icarus 13.0 de la imagen (no evalúa los timing checks, se dice explícitamente) y Open Verilog CVC 7.00b (sí los evalúa, con control positivo), tres esquinas, tres repeticiones | `asic/sim/resultado_sdf.md`, `asic/sim/post_pnr_sdf.sh`, `asic/sim/cvc_sdf.sh` |
| D2: equivalencia formal | hecha: eqy con el liberty típico como modelo de celda, RTL contra el netlist de síntesis y contra el post-PnR sin celdas físicas, con control negativo; el paso `Yosys.EQY` del flujo no sirve para este PDK | `docs/equivalencia.md`, `asic/eqy/` |
| D3: potencia con actividad real | hecha: VCD del netlist de la corrida final en cuatro ventanas del juego, OpenSTA con SPEF y liberty de las 9 esquinas: 11,5 a 12,8 mW contra los 8,97 mW sin actividad en nom_tt | `asic/potencia/resultado.md`, `asic/potencia/` |
| D4: barridos finos de `main` | hecha: utilización 72, 75 y 78 por ciento cierran (área mínima 0,216 mm²), 79 por ciento falla en CTS; `DIE_AREA` absoluto 1,6:1 cierra sin ganancia; 24,5 ns cierra, así que el período mínimo de `main` es 24,5 ns (40,8 MHz, 15,3 MIPS) | `asic/final.md`, `docs/datos_informe.md`, commit `b8770c1` |
| E: paquete de la rama candidata | hecha: `exp/candidata` (A+B2) con cierre a 100 ns, período mínimo 25,5 ns, utilización de 50 a 90 por ciento (máxima 78), las dos estrategias de memoria (la 2 empeora a 69,5 ns), síntesis jerárquica, figuras, post-synth con control negativo, SDF en tres esquinas, DRC de KLayout con control positivo y potencia con actividad; 14 commits empujados. Quedó sin correr la simulación con CVC de la rama y tres de las cuatro ventanas de potencia | rama `exp/candidata`, `docs/candidata.md` |
| Revisión independiente del frente A | hecha: APROBADA CON OBSERVACIONES; agregó 48 comprobaciones de riesgos (`sw/hazard_review.s`), 5 de CYCLES y dos mutaciones propias; sin errores funcionales. Observación principal: rebasar la rama sobre main y repetir `make check` y `make post-synth` antes de adoptarla | `docs/revision_frente_a.md` |
| Exploración del modelo de cable (coordinador) | hecha: con los RC medidos del frente C el RTL de main cierra a 22 ns y el de la candidata a 21,5 ns (las dos con la regla de 0,5 ns cerrada y 0 violaciones de slew en las 9 esquinas), pero el área queda sobre el límite (110,4 y 114,4 por ciento), así que no puede ser la corrida final | `asic/exploraciones.md`, `docs/propuesta_d23.md` 6 bis, `docs/modelo_cable.md` de `exp/candidata-rc` |
| Paquete de decisión | hecha: `docs/propuesta_d23.md` y D23 en estado de propuesta, con "Elegida: pendiente (Nicolás)" | `docs/propuesta_d23.md`, `docs/decisiones.md` |

## Integración de D23 (28-10-2026): la corrida final pasa a exp/candidata-rc

| Tarea | Estado | Cómo retomar / verificar |
|---|---|---|
| E0 D23 resuelta en `docs/decisiones.md` | hecha: "Elegida: (b), variante `exp/candidata-rc`", con la nota de que el límite de 105 % de área de celdas era una regla del grupo y no del enunciado, la fecha de corte (1-11-2026 23:59) y las dos vueltas atrás | `docs/decisiones.md`, D23 |
| E1 v1 marcado y copiado | hecha: tag `v1-final` (commit `d881583`), reportes en `asic/rom/resultados/v1_final/` con `LEEME.md`, corrida en disco en `asic/rom/runs/v1_final_run/` | `git show v1-final --stat`; `git ls-remote --tags origin v1-final` |
| E2 rebase e integración | hecha: `exp/candidata-rc` rebasada sobre main (el `Makefile` se mezcló solo) y mezclada con `merge --no-ff`; el estado anterior de la rama queda en el tag `candidata-rc-pre-rebase` para que los hashes que citan los documentos sigan alcanzables | `git log --oneline v1-final..main`; `git show candidata-rc-pre-rebase` |
| E3 configuración final | hecha: `asic/rom/config.yaml` lleva `EarlyRead=1`, el bloque `LAYERS_RC` y las cuatro variables de la reparación post-GRT; `asic/ff/config_final.yaml` es la estrategia 2 con la misma configuración; `asic/rom/config_rc.yaml` se eliminó | `python3 asic/modelo_cable.py build/exp_rf_latch/asic/rom/runs/b5_t100 --comparar asic/rom/config.yaml` (código 0 si los valores coinciden) |
| E4 verificación de la integración | hecha: 15 comprobaciones en verde | `docs/verificacion/integracion.md` y los `integracion_*.txt` al lado |
| E5 corrida final nueva | hecha: cierra, 0 violaciones de slew y 1 de capacitancia | `bash asic/encolar.sh . asic/rom/config.yaml final 100`, después `bash asic/final.sh --sin-corrida` |
| E6 barrido de período (f2_*) | hecha: cierra a 100, 30, 25, 24, 23, 22 y 21,5 ns y no cierra a 21; período mínimo 21,5 ns (46,5 MHz, 27,9 MIPS) | `bash asic/encolar.sh . asic/rom/config.yaml f2_tNN NN`; tabla en `asic/final.md` |
| E7 barrido de utilización (u2_*) | hecha: cierran 40, 50, 60, 70, 72 y 73 %, y fallan 74, 75, 78, 80 y 90; máxima que cierra 73 % con die 0,235 mm² | `bash asic/encolar.sh . asic/rom/config.yaml u2_uNN 100 FP_CORE_UTIL=NN` |
| E8 pipeline sin B2 con el flujo final (pr_*) | hecha: cierra a 100, 24, 23 y 22,5 ns y no cierra a 22; período mínimo 22,5 ns (44,4 MHz, 26,7 MIPS), así que B2 vale 1 ns | `bash asic/encolar.sh build/exp_pipeline asic/rom/config_final.yaml pr_tNN NN` |
| E9 estrategias con la configuración nueva (s3, s4) | hecha: `s3_t100` reproduce la corrida final al dígito; la estrategia 2 cierra hasta 32 ns (contra 62 ns con la configuración de v1) y el punto de 30 ns no cabe en el corte de 40 minutos de la cola | `bash asic/encolar.sh . asic/ff/config_final.yaml s4_tNN NN` |
| E10 síntesis jerárquica (h3_t100) y `asic/sintesis.md` | hecha | `python3 asic/analisis_sintesis.py --final asic/rom/runs/final --jerarquica asic/rom/runs/h3_t100 --md asic/sintesis.md` |
| E11 ruta crítica por tramos y evolución | hechas | `bash asic/rutas.sh` -> `asic/rutas.md`; `python3 asic/evolucion.py --md asic/evolucion.md` |
| E12 potencia con actividad real | hecha: 9,620 mW sin actividad y 13,936 a 16,615 mW con actividad en nom_tt | `bash asic/potencia/correr.sh todo`; resultado en `asic/potencia/resultado.md` |
| E13 equivalencia formal | hecha: eqy prueba 29 de 30 particiones y deja sin decidir la grande por un estado inicial inalcanzable; la prueba la da el flujo clásico de Yosys (976 de 976 celdas contra el netlist de síntesis y 968 de 968 contra el post-PnR) y el miter desde reset, que pasa a 24 y a 100 pasos; el control negativo que discrimina es el flujo clásico (776 de 976) | `bash asic/eqy/correr.sh todo`; resultado en `docs/equivalencia.md` |
| E14 simulación post-PnR con SDF (d2_pnr) | hecha: `d2_pnr` cierra; tres esquinas con Icarus y con CVC, 18 ejecuciones con un solo md5, 0 violaciones de los 7.173 checks y control positivo con 8 | `bash asic/encolar.sh . asic/sim/config_pnr.yaml d2_pnr 100`, después `make post-pnr-sdf` y `make post-pnr-cvc` |
| E15 documentos | hecha: `asic/final.md`, `asic/sintesis.md`, `asic/rutas.md`, `asic/evolucion.md`, `asic/rom/resultados/final/{cierre,avisos}.md`, `docs/datos_informe.md` completo (2 a 3.8), `docs/hechos_flujo.md`, `asic/exploraciones.md`, `asic/sim/README.md`, `README.md`, `docs/modelo_cable.md`, `docs/cambios_informe.md` y `docs/reporte_integracion_d23.md` | los genera `bash asic/tablas.sh`, `bash asic/rutas.sh` y `python3 asic/evolucion.py --md asic/evolucion.md` |
