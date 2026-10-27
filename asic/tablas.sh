#!/usr/bin/env bash
# Regenera asic/final.md (tablas de la corrida final y de los barridos con la
# configuración final) y los gráficos de docs/figuras/ a partir de las corridas
# que existan en asic/rom/runs. Lo llama asic/final.sh; también se puede correr
# solo: bash asic/tablas.sh
set -eu
cd "$(dirname "$0")/.."
PY=python3
existen() { for r in "$@"; do [ -f "$r/final/metrics.json" ] && echo "$r"; done; return 0; }
# corridas que existen pero no llegaron a final/metrics.json (fallidas o incompletas)
faltan() { for r in "$@"; do [ -d "$r" ] && [ ! -f "$r/final/metrics.json" ] && echo "$r"; done; return 0; }
rm -f asic/final.md
$PY asic/recolectar.py --md asic/final.md --titulo "Corrida final (tag final): T = 100 ns, FP_CORE_UTIL = 40 %" \
  --nota "Configuración: asic/rom/config.yaml (D15, D20, D21). Criterios de cierre: asic/rom/resultados/final/cierre.md. Las tablas de este archivo las genera asic/tablas.sh con asic/recolectar.py." \
  asic/rom/runs/final > /dev/null

F1=$(existen asic/rom/runs/final asic/rom/runs/f1_t32 asic/rom/runs/f1_t30 asic/rom/runs/f1_t28 asic/rom/runs/f1_t26 asic/rom/runs/f1_t25 asic/rom/runs/f1_t24p5 asic/rom/runs/f1_t24)
if [ -n "$F1" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de CLOCK_PERIOD con la configuración final (sección 3.4)" \
    --nota "Corridas f1_* (mismo RTL y configuración que la final, solo cambia CLOCK_PERIOD). Cierra a 100, 32, 30, 26, 25 y 24,5 ns (f1_t24p5, WNS 0,496 ns en max_ss_125C_4v50, asic/rom/resultados/f1_t24p5/cierre.md); 24 ns no cierra por 0,004 ns en max_ss_125C_4v50. Período mínimo 24,5 ns (40,8 MHz); la corrida de 24,5 ns cierra la regla de la sesión de dejar 0,5 ns o menos entre el último período que cierra y el primero que no. f1_t28 se detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (regla de tiempo del grupo) y no se cuenta. f1_t26, f1_t25, f1_t24p5 y f1_t24 tienen exactamente el mismo layout (8.708 celdas, 189.817 µm² y 354.897 µm de cables): con el margen de 10 ns de D20 el resizer llega a su límite y de ahí para abajo solo cambia el slack, 1 ns de WNS por cada ns de período." \
    $F1 > /dev/null
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --periodo $F1 --salida-periodo docs/figuras/periodo.png > /dev/null
fi

R0=$(existen asic/rom/runs/r0_t100 asic/rom/runs/r0_t26)
if [ -n "$R0" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "RTL sin pre-decodificación (116fa20) con la configuración final (sección 3.4, efecto de D18)" \
    --nota "Corridas r0_* del RTL del commit 116fa20 (sin D18) en un worktree (build/ref116, enlazado en asic/rom/runs/r0_*) con la misma asic/rom/config.yaml y pines.cfg de la corrida final, a 100 ns y al período mínimo del diseño final (26 ns, el primer punto que cerró; el final cierra también a 25 ns). Comparar con final y f1_t26." \
    $R0 > /dev/null
fi

U1=$(existen asic/rom/runs/final asic/rom/runs/u1_u50 asic/rom/runs/u1_u60 asic/rom/runs/u1_u70 asic/rom/runs/u1_u72 asic/rom/runs/u1_u75 asic/rom/runs/u1_u78)
U1_FALLAN=$(faltan asic/rom/runs/u1_u72 asic/rom/runs/u1_u75 asic/rom/runs/u1_u78 asic/rom/runs/u1_u79 asic/rom/runs/u1_u80 asic/rom/runs/u1_u90)
if [ -n "$U1" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de FP_CORE_UTIL a 100 ns con la configuración final (sección 3.5)" \
    --nota "Corridas final (40 %) y u1_u50 a u1_u90; las de 72, 75, 78 y 79 % son del 27-10-2026. Cierran 50, 60, 70, 72, 75 y 78 %: la utilización máxima que cierra es 78 % (u1_u78: die 455,4 x 473,3 µm = 215.545 µm², utilización real 90,3 %, WNS de setup 59,6 ns en max_ss_125C_4v50 y hold 0,182 ns; asic/rom/resultados/u1_u78/cierre.md). u1_u79 y u1_u80 fallan en OpenROAD.CTS ([DPL-0036] Detailed placement failed: al legalizar después de insertar los buffers del árbol de reloj quedan instancias sin lugar, 6 del banco de registros en u1_u79 y 22 en u1_u80; asic/logs/u1_u79.log y asic/logs/u1_u80.log; extractos versionados en asic/rom/resultados/u1_u79/falla.txt y asic/rom/resultados/u1_u80/falla.txt) y u1_u90 en el placement global ([GPL-0301] Utilization 100.531 % exceeds 100%, asic/logs/u1_u90.log; extracto en asic/rom/resultados/u1_u90/falla.txt): no tienen métricas finales. A 78 % la ruta crítica deja de ser la de la ALU al banco de registros (slack 60,5 ns) y pasa a ser la salida seg2[2] del display (59,6 ns; 69,2 ns a 75 %), y las violaciones de slew suben de 424 a 880 pines. Gráfico: docs/figuras/utilizacion.png (asic/graficos.py --util)." \
    $U1 $U1_FALLAN > /dev/null 2>&1
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --util $U1 $U1_FALLAN --salida-util docs/figuras/utilizacion.png > /dev/null
fi

UA=$(existen asic/rom/runs/u1_auto)
if [ -n "$UA" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Terminales ubicados por el flujo (sin D21), sección 3.5" \
    --nota "Corrida u1_auto: asic/rom/config_pines_auto.yaml, idéntica a la final salvo que no define IO_PIN_ORDER_CFG y OpenROAD.IOPlacement ubica los terminales donde acorta los cables. Comparar con final (D21): largo de cables, DRC de ruteo por iteración (route__drc_errors__iter:N en metrics.json), slew y WNS." \
    asic/rom/runs/final $UA > /dev/null
fi
D4=$(existen asic/rom/runs/d4_die)
if [ -n "$D4" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Floorplan con DIE_AREA absoluto y aspecto 1,6:1 (sección 3.5)" \
    --nota "Corrida d4_die (asic/rom/config_die.yaml, 27-10-2026): idéntica a la final salvo FP_SIZING: absolute y DIE_AREA 0 0 808,64 505,68 µm (aspecto 1,6:1; 408.913 µm², 0,011 % menos que los 408.957 µm² de la final, que mide 630,60 x 648,52 µm). CORE_AREA no se define: floorplan.tcl de LibreLane la calcula restando los márgenes de siempre (6,72 µm a los lados y 15,68 µm arriba y abajo), 795,20 x 474,32 µm = 377.179 µm² en 121 filas de 1420 sitios (final: 379.800 µm², 157 filas de 1102 sitios; 13-openroad-floorplan de cada corrida). Cierra (asic/rom/resultados/d4_die/cierre.md). Contra la final (metrics.json de cada una): cables 364.879 contra 352.253 µm (+3,6 %; ruteo global 509.586 contra 494.524 µm), cable más largo 975 contra 1.409 µm, WNS de setup 61,672 contra 65,223 ns en max_ss_125C_4v50 (hold 0,156 contra 0,178 ns), slew 567 contra 546 pines, capacitancia 33 contra 36, DRC del ruteo detallado por iteración 1.302, 279, 271, 0 contra 1.546, 501, 379, 0, celdas estándar 8.590 contra 8.670 y área de celdas 180.939 contra 182.265 µm² (-0,7 %). Layout y ruta crítica: asic/rom/resultados/d4_die/layout/." \
    asic/rom/runs/final $D4 > /dev/null
fi
echo "asic/final.md regenerado"
