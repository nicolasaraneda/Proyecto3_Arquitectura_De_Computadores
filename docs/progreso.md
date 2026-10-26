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
| A2 `make final` | hecha (script; README lo documenta); al final se corre `bash asic/final.sh --sin-corrida` para regenerar todo | `make final` (asic/final.sh); `bash asic/final.sh --sin-corrida` regenera solo los análisis |
| A3 barrido de período con la configuración final | hecha: cierra a 100, 32, 30, 26 y 25 ns; 24 no (-0,004 ns); período mínimo 25 ns (40 MHz); f1_t28 detenida a los 40 min; RTL 116fa20: r0_t100 cierra (WNS 54,6), r0_t26 no (-3,175). Tablas en asic/final.md, gráfico docs/figuras/periodo.png | `PAR=3 bash asic/barrido.sh < lista` con `asic/rom/config.yaml f1_tNN NN`; tabla: `python3 asic/recolectar.py --md asic/barrido.md --titulo ... asic/rom/runs/f1_*`; gráfico: `python3 asic/graficos.py --periodo ...` |
| A4 barrido de FP_CORE_UTIL, pines automáticos, costo | hecha: 50, 60 y 70 % cierran (mínima 0,239 mm² a 70 %), 80 % falla en CTS, 90 % en placement global; u1_auto comparada con D21. Tabla en asic/final.md, gráfico docs/figuras/utilizacion.png, costo en docs/datos_informe.md | `asic/rom/config.yaml u1_uNN 100 FP_CORE_UTIL=NN`; gráfico: `python3 asic/graficos.py --util asic/rom/runs/final asic/rom/runs/u1_u*` |
| A5 síntesis jerárquica y `asic/sintesis.md` | hecha | `python3 asic/analisis_sintesis.py --final asic/rom/runs/final --jerarquica asic/rom/runs/h2_t100 --md asic/sintesis.md` |
| A6a figuras del layout (`asic/layout/anotar.py`) | hecha para final, f1_t26, s1_t55 y p1_t42 | `make layout RUN=asic/rom/runs/<tag>` (KLayout en Docker) |
| A6b antena de la estrategia 2 | hecha: s2_t100_diodos 0 violaciones (36.385 diodos, +18 % de área); figuras antes y después en asic/ff/resultados/s2_t100*/layout | `bash asic/layout/anotar.sh asic/ff/runs/s2_t100 -rd net=net3342 -rd nombre=antena_antes`; después lo mismo con s2_t100_diodos y nombre=antena_despues |
| A6c DRC de KLayout con el deck del PDK | hecha: 0 marcadores en 684 reglas (asic/rom/resultados/final/drc_klayout/resumen.md) | `bash asic/drc_klayout.sh asic/rom/runs/final` (deck en asic/drc, ver asic/drc/ORIGEN.md) |
| A6d avisos de la corrida final | hecha | `asic/rom/resultados/final/avisos.md` |
| A6e `docs/layout.md` | hecha | `docs/layout.md` |
| A7 simulación post-síntesis (`make post-synth`) | hecha: PASS, 0 X; post-synth-final PASS (pulsación real, 320k ciclos); SDF: iverilog necesita -gspecify -ginterconnect, en prueba | `make post-synth`; estímulos: `python3 asic/sim/calibrar.py`; resultado en asic/sim/resultado.md |
| A8 README final | hecha (versiones, corrida final, make final, estructura) | README.md |
| A9 `docs/datos_informe.md` y `docs/defensa.md` | hechas; se completan con los resultados del bloque B a medida que llegan | |
| B1 exp/signoff | primera ronda lista (b1a: 272/1 pero +5,3 % de área; b1c: 489/19 con +0,5 %; b1d peor; b1e sin efecto); segunda ronda b1f (fanout 8), b1g (márgenes 30 %), b1h (fanout 8 + post-GRT) en el lote 8; falta la mejor a 26 ns | `build/exp_signoff`, asic/exploraciones.md |
| B2 exp/lsu-offset | hecha: cierra a 24 ns (41,7 MHz; main 25), área -0,6 %; b2_t23 y b2_t22 en el lote 7; datos en la rama (asic/barrido_exp.md) | `build/exp_lsu_offset`, commit 84e5e10 |
| B3 exp/branch-cmp | hecha: sola no mejora (26 cierra, 24 no), área +0,9 %; combinación B2+B3 (exp/lsu-branch): 100 y 24 (no cierra, -0,84) listas, 26 en curso | commits 6ef475f (b3) y 71f9170 (b23) |
| B4 exp/cpi | hecha: área -13,3 %, cierra a 60 ns (1,73 ns) y no a 45 (-1,75); b4_t55 y b4_t50 en el lote 8; MIPS 12,7 contra 15,0 (provisorio) | `build/exp_cpi`, datos en la rama |
| B5 exp/rf-latch (opcional) | b5_t100 cierra (DRC, LVS, antenas limpios; latches con préstamo de tiempo y chequeos de clock gating en el STA), área -9,3 %, slew/cap 312/2; b5_t26 en curso | `build/exp_rf_latch`, commit ef957ef |
| C1 GIF del chip construyéndose (opcional) | hecha: docs/figuras/construccion.gif (12 etapas) | `make animacion RUN=asic/rom/runs/final` |
