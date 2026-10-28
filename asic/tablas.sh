#!/usr/bin/env bash
# Regenera asic/final.md (tablas de la corrida final y de los barridos con la
# configuración final) y los gráficos de docs/figuras/ a partir de las corridas
# que existan en asic/rom/runs y asic/ff/runs. Lo llama asic/final.sh; también se
# puede correr solo: bash asic/tablas.sh
#
# Orden de las secciones: primero la corrida final de D23 y sus barridos (f2_* de
# período, u2_* de utilización, s3_*/s4_* de estrategias, pr_* del pipeline sin
# B2), después la historia de v1 (v1_final, f1_*, r0_*, u1_*, u1_auto, d4_die),
# que el informe conserva para la tabla de evolución de la sección 3.4.
set -eu
cd "$(dirname "$0")/.."
PY=python3
existen() { for r in "$@"; do [ -f "$r/final/metrics.json" ] && echo "$r"; done; return 0; }
# corridas que existen pero no llegaron a final/metrics.json (fallidas o incompletas)
faltan() { for r in "$@"; do [ -d "$r" ] && [ ! -f "$r/final/metrics.json" ] && echo "$r"; done; return 0; }
rm -f asic/final.md

$PY asic/recolectar.py --md asic/final.md --titulo "Corrida final (tag final): T = 100 ns, FP_CORE_UTIL = 40 %" \
  --nota "Configuración: asic/rom/config.yaml (D15, D20, D21 y D23: EarlyRead = 1, LAYERS_RC con los RC de cable medidos y la reparación después del ruteo global). Criterios de cierre: asic/rom/resultados/final/cierre.md; avisos revisados uno por uno en avisos.md. La corrida final de v1 (antes de integrar exp/candidata-rc) está en asic/rom/resultados/v1_final/ y bajo el tag v1-final. Las tablas de este archivo las genera asic/tablas.sh con asic/recolectar.py." \
  asic/rom/runs/final > /dev/null

F2=$(existen asic/rom/runs/final asic/rom/runs/f2_t30 asic/rom/runs/f2_t25 asic/rom/runs/f2_t24 asic/rom/runs/f2_t23 asic/rom/runs/f2_t22 asic/rom/runs/f2_t21p5 asic/rom/runs/f2_t21)
F2_FALLAN=$(faltan asic/rom/runs/f2_t30 asic/rom/runs/f2_t25 asic/rom/runs/f2_t24 asic/rom/runs/f2_t23 asic/rom/runs/f2_t22 asic/rom/runs/f2_t21p5 asic/rom/runs/f2_t21)
if [ -n "$F2" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de CLOCK_PERIOD con la configuración final (sección 3.4)" \
    --nota "Corridas f2_* (mismo RTL y configuración que la final, solo cambia CLOCK_PERIOD); el punto de 100 ns es la corrida final. Período mínimo 21,5 ns (46,5 MHz): f2_t21p5 cierra con WNS de setup 0,876 ns y TNS 0 en max_ss_125C_4v50, y f2_t21 no cierra por 0,129 ns (TNS -0,291 ns), con lo que la regla de la sesión de dejar 0,5 ns o menos entre el último período que cierra y el primero que no queda cerrada. A diferencia de lo que pasaba en v1, acá cada período da su propio layout: con los parásitos de cable medidos el resizer sigue encontrando qué reparar, así que el área de celdas sube de 208.439 µm² a 100 ns a 231.229 µm² a 21,5 ns y el WNS deja de bajar 1 ns por cada ns de período (1,579 a 25 ns, 1,755 a 24, 1,494 a 23, 0,656 a 22 y 0,876 a 21,5). Las violaciones de max slew son 0 a 100, 25, 22 y 21,5 ns, y 4 a 24 y 23 ns; la de max capacitancia es siempre 1 y es siempre el mismo pin, la raíz del árbol de reloj (asic/rom/resultados/final/avisos.md, aviso 4). Gráfico: docs/figuras/periodo.png (asic/graficos.py --periodo). Las rutas críticas por tramos están en asic/rutas.md." \
    $F2 $F2_FALLAN > /dev/null 2>&1
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --periodo $F2 --salida-periodo docs/figuras/periodo.png > /dev/null
fi

U2=$(existen asic/rom/runs/final asic/rom/runs/u2_u50 asic/rom/runs/u2_u60 asic/rom/runs/u2_u65 asic/rom/runs/u2_u68 asic/rom/runs/u2_u70 asic/rom/runs/u2_u72 asic/rom/runs/u2_u75 asic/rom/runs/u2_u78 asic/rom/runs/u2_u80 asic/rom/runs/u2_u90)
U2_FALLAN=$(faltan asic/rom/runs/u2_u50 asic/rom/runs/u2_u60 asic/rom/runs/u2_u65 asic/rom/runs/u2_u68 asic/rom/runs/u2_u70 asic/rom/runs/u2_u72 asic/rom/runs/u2_u75 asic/rom/runs/u2_u78 asic/rom/runs/u2_u80 asic/rom/runs/u2_u90)
if [ -n "$U2" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de FP_CORE_UTIL a 100 ns con la configuración final (sección 3.5)" \
    --nota "Corridas final (40 %) y u2_*. La columna utilización es la real que mide el flujo (design__instance__utilization), no la pedida: con el modelo de cable el resizer agrega celdas, así que la real queda bastante por encima de la pedida. El valor que el informe reporta como utilización máxima que cierra es el de FP_CORE_UTIL pedido en la corrida de menor die que cierra todo; las que fallan no tienen métricas finales y su extracto de la falla está en asic/rom/resultados/<tag>/falla.txt. Gráfico: docs/figuras/utilizacion.png (asic/graficos.py --util). La comparación con v1 (que cerraba hasta 78 % con un die de 0,216 mm²) está en docs/datos_informe.md, sección 3.5." \
    $U2 $U2_FALLAN > /dev/null 2>&1
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --util $U2 $U2_FALLAN --salida-util docs/figuras/utilizacion.png > /dev/null
fi

S3=$(existen asic/rom/runs/s3_t100)
if [ -n "$S3" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Estrategia 1 con la configuración final, reproducción independiente (sección 3.2)" \
    --nota "Corrida s3_t100: la misma configuración y el mismo RTL que la corrida final, con otro tag. Sirve de reproducción: si da los mismos números que final, el flujo es determinista con esta configuración. El barrido de período de la estrategia 1 es el de las f2_* de más arriba; no se repitió con otro tag." \
    asic/rom/runs/final $S3 > /dev/null
fi

S4=$(existen asic/ff/runs/s4_t100 asic/ff/runs/s4_t65 asic/ff/runs/s4_t60 asic/ff/runs/s4_t55 asic/ff/runs/s4_t50 asic/ff/runs/s4_t45 asic/ff/runs/s4_t42)
S4_FALLAN=$(faltan asic/ff/runs/s4_t100 asic/ff/runs/s4_t65 asic/ff/runs/s4_t60 asic/ff/runs/s4_t55 asic/ff/runs/s4_t50 asic/ff/runs/s4_t45 asic/ff/runs/s4_t42)
if [ -n "$S4" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Estrategia 2 de memoria con la configuración final (sección 3.2)" \
    --nota "Corridas s4_* con asic/ff/config_final.yaml: memoria unificada de instrucciones y datos en flip-flops, el core nuevo con EarlyRead = 0 (el valor por omisión cuando MemStrategy = 2: la memoria en flip-flops lee registrado y no puede anticipar la lectura del banco) y las mismas perillas de flujo de la corrida final, incluido el modelo de cable. Por eso su CPI es el de v1 (2,665 en el juego completo, docs/verificacion/integracion_01_make_check.txt) y no el 1,665 de la estrategia 1. Comparar con las s2_* de v1 (asic/barrido.md), que usaban asic/ff/config.yaml." \
    $S4 $S4_FALLAN > /dev/null 2>&1
fi

PR=$(existen build/exp_pipeline/asic/rom/runs/pr_t100 build/exp_pipeline/asic/rom/runs/pr_t24 build/exp_pipeline/asic/rom/runs/pr_t23 build/exp_pipeline/asic/rom/runs/pr_t22 build/exp_pipeline/asic/rom/runs/pr_t21p5 build/exp_pipeline/asic/rom/runs/pr_t21)
PR_FALLAN=$(faltan build/exp_pipeline/asic/rom/runs/pr_t100 build/exp_pipeline/asic/rom/runs/pr_t24 build/exp_pipeline/asic/rom/runs/pr_t23 build/exp_pipeline/asic/rom/runs/pr_t22 build/exp_pipeline/asic/rom/runs/pr_t21p5 build/exp_pipeline/asic/rom/runs/pr_t21)
if [ -n "$PR" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "El pipeline sin B2 con la configuración final (sección 3.4, efecto de B2)" \
    --nota "Corridas pr_* en el worktree build/exp_pipeline (rama exp/pipeline, asic/rom/config_final.yaml: la configuración final de D23 aplicada al RTL del frente A sin el offset de byte de la carga registrado en la LSU). Mide cuánto aporta B2 con el flujo final, igual que exp/lsu-offset lo midió con el flujo de v1. El CPI es el mismo que el de la corrida final (1,665): B2 no cambia ningún ciclo, solo acorta la ruta de alineación y write-back. Comparar contra las f2_* del mismo período." \
    $PR $PR_FALLAN > /dev/null 2>&1
fi

# --- historia de v1: se conserva para la tabla de evolución de la sección 3.4 ---
V1=$(existen asic/rom/runs/v1_final_run asic/rom/runs/f1_t32 asic/rom/runs/f1_t30 asic/rom/runs/f1_t26 asic/rom/runs/f1_t25 asic/rom/runs/f1_t24p5 asic/rom/runs/f1_t24)
if [ -n "$V1" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Historia: la corrida final de v1 y su barrido de período" \
    --nota "v1 es main antes de integrar exp/candidata-rc (tag v1-final); su corrida final quedó en asic/rom/runs/v1_final_run y sus reportes versionados en asic/rom/resultados/v1_final/. Cerraba a 24,5 ns (40,8 MHz, 15,3 MIPS) con 182.265 µm² de celdas, 546 violaciones de max slew y 36 de max capacitancia. f1_t26, f1_t25, f1_t24p5 y f1_t24 daban exactamente el mismo layout (8.708 celdas, 189.817 µm² y 354.897 µm de cables): con el margen de 10 ns de D20 y la estimación de parásitos del tech LEF el resizer llegaba a su límite y de ahí para abajo solo cambiaba el slack. f1_t28 se detuvo a los 40 minutos en OpenROAD.ResizerTimingPostCTS (regla de tiempo del grupo) y no se cuenta." \
    $V1 > /dev/null 2>&1
fi

R0=$(existen asic/rom/runs/r0_t100 asic/rom/runs/r0_t26)
if [ -n "$R0" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Historia: RTL sin pre-decodificación (116fa20) con la configuración de v1 (sección 3.4, efecto de D18)" \
    --nota "Corridas r0_* del RTL del commit 116fa20 (sin D18) en un worktree (build/ref116, enlazado en asic/rom/runs/r0_*) con la asic/rom/config.yaml y pines.cfg que tenía v1, a 100 ns y a 26 ns. Comparar con v1_final_run y f1_t26, no con la corrida final nueva." \
    $R0 > /dev/null 2>&1
fi

U1=$(existen asic/rom/runs/v1_final_run asic/rom/runs/u1_u50 asic/rom/runs/u1_u60 asic/rom/runs/u1_u70 asic/rom/runs/u1_u72 asic/rom/runs/u1_u75 asic/rom/runs/u1_u78)
U1_FALLAN=$(faltan asic/rom/runs/u1_u79 asic/rom/runs/u1_u80 asic/rom/runs/u1_u90)
if [ -n "$U1" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Historia: barrido de FP_CORE_UTIL de v1 a 100 ns" \
    --nota "Corridas u1_* con la configuración de v1. Cerraban 50, 60, 70, 72, 75 y 78 %: la utilización máxima que cerraba era 78 % (u1_u78: die 455,4 x 473,3 µm = 215.545 µm², utilización real 90,3 %, WNS de setup 59,6 ns en max_ss_125C_4v50 y hold 0,182 ns). u1_u79 y u1_u80 fallaban en OpenROAD.CTS (al legalizar después de insertar los buffers del árbol de reloj quedan instancias sin lugar: el log informa [INFO DPL-0034] con la lista de 6 instancias en u1_u79 y 22 en u1_u80, y después [ERROR DPL-0036] Detailed placement failed; extractos versionados en asic/rom/resultados/u1_u79/falla.txt y u1_u80/falla.txt) y u1_u90 en el placement global ([GPL-0301] Utilization 100.531 % exceeds 100%, extracto en u1_u90/falla.txt). A 78 % la ruta crítica dejaba de ser la de la ALU al banco de registros (slack 60,5 ns) y pasaba a ser la salida seg2[2] del display (59,6 ns; 69,2 ns a 75 %), y las violaciones de slew subían de 424 a 880 pines." \
    $U1 $U1_FALLAN > /dev/null 2>&1
fi

UA=$(existen asic/rom/runs/u1_auto)
if [ -n "$UA" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Historia: terminales ubicados por el flujo (sin D21), sección 3.5" \
    --nota "Corrida u1_auto con la configuración de v1: idéntica a la final de v1 salvo que no define IO_PIN_ORDER_CFG y OpenROAD.IOPlacement ubica los terminales donde acorta los cables. Comparar con v1_final_run (D21): largo de cables, DRC de ruteo por iteración (route__drc_errors__iter:N en metrics.json), slew y WNS. No se repitió con la configuración nueva." \
    asic/rom/runs/v1_final_run $UA > /dev/null 2>&1
fi

D4=$(existen asic/rom/runs/d4_die)
if [ -n "$D4" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Historia: floorplan con DIE_AREA absoluto y aspecto 1,6:1 (sección 3.5)" \
    --nota "Corrida d4_die con la configuración de v1 (asic/rom/config_die.yaml): idéntica a la final de v1 salvo FP_SIZING: absolute y DIE_AREA 0 0 808,64 505,68 µm (aspecto 1,6:1; 408.913 µm², 0,011 % menos que los 408.957 µm² de la final de v1, que medía 630,60 x 648,52 µm). CORE_AREA no se define: floorplan.tcl de LibreLane la calcula restando los márgenes de siempre (6,72 µm a los lados y 15,68 µm arriba y abajo), 795,20 x 474,32 µm = 377.179 µm² en 121 filas de 1420 sitios (final de v1: 379.800 µm², 157 filas de 1102 sitios). Contra la final de v1: cables 364.879 contra 352.253 µm (+3,6 %), cable más largo 975 contra 1.409 µm, WNS de setup 61,672 contra 65,223 ns en max_ss_125C_4v50, slew 567 contra 546 pines y área de celdas 180.939 contra 182.265 µm². No se repitió con la configuración nueva." \
    asic/rom/runs/v1_final_run $D4 > /dev/null 2>&1
fi
echo "asic/final.md regenerado"
