#!/usr/bin/env bash
# Regenera asic/final.md (tablas de la corrida final y de los barridos con la
# configuración final) y los gráficos de docs/figuras/ a partir de las corridas
# que existan en asic/rom/runs. Lo llama asic/final.sh; también se puede correr
# solo: bash asic/tablas.sh
set -eu
cd "$(dirname "$0")/.."
PY=python3
existen() { for r in "$@"; do [ -f "$r/final/metrics.json" ] && echo "$r"; done; return 0; }
rm -f asic/final.md
$PY asic/recolectar.py --md asic/final.md --titulo "Corrida final (tag final): T = 100 ns, FP_CORE_UTIL = 40 %" \
  --nota "Configuración: asic/rom/config.yaml (D15, D20, D21). Criterios de cierre: asic/rom/resultados/final/cierre.md. Las tablas de este archivo las genera asic/tablas.sh con asic/recolectar.py." \
  asic/rom/runs/final > /dev/null

F1=$(existen asic/rom/runs/final asic/rom/runs/f1_t32 asic/rom/runs/f1_t30 asic/rom/runs/f1_t28 asic/rom/runs/f1_t26 asic/rom/runs/f1_t25 asic/rom/runs/f1_t24)
if [ -n "$F1" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de CLOCK_PERIOD con la configuración final (sección 3.4)" \
    --nota "Corridas f1_* (mismo RTL y configuración que la final, solo cambia CLOCK_PERIOD). Cierra a 100, 32, 30, 26 y 25 ns; 24 ns no cierra por 0,004 ns en max_ss_125C_4v50. f1_t28 se detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (regla de tiempo del grupo) y no se cuenta. f1_t26, f1_t25 y f1_t24 tienen exactamente el mismo layout (celdas, área y largo de cables): con el margen de 10 ns de D20 el resizer llega a su límite y de ahí para abajo solo cambia el slack." \
    $F1 > /dev/null
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --periodo $F1 --salida-periodo docs/figuras/periodo.png > /dev/null
fi

R0=$(existen asic/rom/runs/r0_t100 asic/rom/runs/r0_t26)
if [ -n "$R0" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "RTL sin pre-decodificación (116fa20) con la configuración final (sección 3.4, efecto de D18)" \
    --nota "Corridas r0_* del RTL del commit 116fa20 (sin D18) en un worktree (build/ref116, enlazado en asic/rom/runs/r0_*) con la misma asic/rom/config.yaml y pines.cfg de la corrida final, a 100 ns y al período mínimo del diseño final (26 ns, el primer punto que cerró; el final cierra también a 25 ns). Comparar con final y f1_t26." \
    $R0 > /dev/null
fi

U1=$(existen asic/rom/runs/final asic/rom/runs/u1_u50 asic/rom/runs/u1_u60 asic/rom/runs/u1_u70)
if [ -n "$U1" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de FP_CORE_UTIL a 100 ns con la configuración final (sección 3.5)" \
    --nota "Corridas final (40 %) y u1_u50 a u1_u90. u1_u80 falla en OpenROAD.CTS ([DPL-0036] Detailed placement failed, asic/logs/u1_u80.log) y u1_u90 en el placement global ([GPL-0301] Utilization 100.531 % exceeds 100%, asic/logs/u1_u90.log): no tienen métricas finales. Gráfico: docs/figuras/utilizacion.png (asic/graficos.py --util)." \
    $U1 asic/rom/runs/u1_u80 asic/rom/runs/u1_u90 > /dev/null 2>&1
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --util $U1 asic/rom/runs/u1_u80 asic/rom/runs/u1_u90 --salida-util docs/figuras/utilizacion.png > /dev/null
fi

UA=$(existen asic/rom/runs/u1_auto)
if [ -n "$UA" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Terminales ubicados por el flujo (sin D21), sección 3.5" \
    --nota "Corrida u1_auto: asic/rom/config_pines_auto.yaml, idéntica a la final salvo que no define IO_PIN_ORDER_CFG y OpenROAD.IOPlacement ubica los terminales donde acorta los cables. Comparar con final (D21): largo de cables, DRC de ruteo por iteración (route__drc_errors__iter:N en metrics.json), slew y WNS." \
    asic/rom/runs/final $UA > /dev/null
fi
echo "asic/final.md regenerado"
