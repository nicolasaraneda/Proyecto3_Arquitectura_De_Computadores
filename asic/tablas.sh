#!/usr/bin/env bash
# Regenera asic/final.md (tablas de la candidata: corrida base, barrido de
# período, variantes de signoff, estrategias de memoria y barrido de
# utilización) y los gráficos de docs/figuras/ a partir de las corridas que
# existan en asic/rom/runs y asic/ff/runs. Adaptado por el frente E a los tags
# de la rama exp/candidata: bash asic/tablas.sh
#
# Tags de la rama (ver docs/candidata.md):
#   pa_b2_*  corridas de la configuración base de la candidata, heredadas de
#            exp/pipeline-b2 (MISMO árbol, commit be50893): enlazadas en
#            asic/rom/runs/ a build/exp_pipeline_b2. No se repitieron.
#   e1_*     corridas nuevas del frente E con la estrategia 1 (signoff,
#            utilización, síntesis jerárquica, PnR de la simulación).
#   e2_*     corridas nuevas del frente E con la estrategia 2 (asic/ff).
#   m_*      corridas de main enlazadas para comparar (m_final es la final del
#            enunciado, m_f1_t24p5 su período mínimo). Solo se leen.
set -eu
cd "$(dirname "$0")/.."
PY=python3
existen() { for r in "$@"; do [ -f "$r/final/metrics.json" ] && echo "$r"; done; return 0; }
faltan() { for r in "$@"; do [ -f "$r/final/metrics.json" ] || echo "$r"; done; return 0; }
rm -f asic/final.md

$PY asic/recolectar.py --md asic/final.md --titulo "Candidata (rama exp/candidata) a 100 ns y 40 %, contra la corrida final de main" \
  --nota "pa_b2_t100 es la corrida base de la candidata (asic/rom/config.yaml de la rama: la configuración final de main, D15, D20 y D21, más EarlyRead=1 en SYNTH_PARAMETERS); el RTL es el del frente A (lectura del banco y decode en el fetch) más B2 (offset de byte registrado en la LSU). m_final es la corrida final de main (enlace a asic/rom/runs/final del repo principal) y m_f1_t24p5 su período mínimo. Criterios de cierre: asic/rom/resultados/<tag>/cierre.md." \
  asic/rom/runs/pa_b2_t100 asic/rom/runs/m_final > /dev/null

P=$(existen asic/rom/runs/pa_b2_t100 asic/rom/runs/pa_b2_t26 asic/rom/runs/pa_b2_t25p5 asic/rom/runs/pa_b2_t25)
if [ -n "$P" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de CLOCK_PERIOD de la candidata (configuración base)" \
    --nota "Corridas pa_b2_* (mismo RTL y configuración, solo cambia CLOCK_PERIOD), medidas por el frente A en build/exp_pipeline_b2 y enlazadas acá. Cierra a 100, 26 y 25,5 ns; 25 ns no cierra (setup en max_ss_125C_4v50, WNS -0,409 ns). Período mínimo 25,5 ns (39,2 MHz) y la brecha con el primero que no cierra es 0,5 ns, lo que cumple la regla de la sesión. Las corridas de 26, 25,5 y 25 ns tienen el mismo layout (9.224 celdas, 194.212 µm², 373.251 µm de cables)." \
    $P > /dev/null
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --periodo $P --salida-periodo docs/figuras/periodo.png > /dev/null 2>&1 || echo "aviso: graficos.py --periodo falló"
fi

G=$(existen asic/rom/runs/pa_b2_t100 asic/rom/runs/e1_g30_t100 asic/rom/runs/e1_full_t100)
if [ -n "$G" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Variantes de signoff de slew y capacitancia sobre la candidata a 100 ns" \
    --nota "e1_g30_t100: asic/rom/config.yaml más DESIGN_REPAIR_MAX_SLEW_PCT=30 y DESIGN_REPAIR_MAX_CAP_PCT=30 (la variante que el frente C midió dentro del 1 % de área sobre el RTL B2+B5, docs/signoff0.md). e1_full_t100: asic/rom/config_rc.yaml de la rama (LAYERS_RC medidos por el frente C, con EarlyRead=1) más RUN_POST_GRT_DESIGN_REPAIR=true, GRT_DESIGN_REPAIR_MAX_SLEW_PCT=30, GRT_DESIGN_REPAIR_MAX_CAP_PCT=30 y CTS_DISTANCE_BETWEEN_BUFFERS=100. Comparar con pa_b2_t100 (571 pines de slew y 37 de capacitancia, 186.432 µm²)." \
    $G > /dev/null
fi

E2=$(existen asic/ff/runs/e2_t100 asic/ff/runs/e2_t62 asic/ff/runs/e2_t60 asic/ff/runs/e2_t58)
if [ -n "$E2" ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Estrategia 2 (memoria en flip-flops) con el RTL de la candidata" \
    --nota "Corridas e2_* con asic/ff/config.yaml de la rama (MemStrategy=2, EarlyRead en su valor por defecto 0 para esa estrategia, igual que en main: ver docs/candidata.md). Referencia de main con la estrategia 2: período mínimo 62 ns (asic/exploraciones.md)." \
    $E2 > /dev/null
fi

U=$(existen asic/rom/runs/pa_b2_t100 asic/rom/runs/e1_u50 asic/rom/runs/e1_u60 asic/rom/runs/e1_u70 asic/rom/runs/e1_u72 asic/rom/runs/e1_u75 asic/rom/runs/e1_u78 asic/rom/runs/e1_u80 asic/rom/runs/e1_u90)
UF=$(faltan asic/rom/runs/e1_u50 asic/rom/runs/e1_u60 asic/rom/runs/e1_u70 asic/rom/runs/e1_u72 asic/rom/runs/e1_u75 asic/rom/runs/e1_u78 asic/rom/runs/e1_u80 asic/rom/runs/e1_u90)
if [ "$(echo "$U" | wc -w)" -gt 1 ]; then
  $PY asic/recolectar.py --md asic/final.md --titulo "Barrido de FP_CORE_UTIL a 100 ns sobre la candidata" \
    --nota "pa_b2_t100 es el 40 %; e1_u50 a e1_u90 cambian solo FP_CORE_UTIL. Las que no tienen métricas finales fallaron: el paso y el mensaje están en asic/rom/resultados/<tag>/falla.txt. Gráfico: docs/figuras/utilizacion.png (asic/graficos.py --util)." \
    $U $UF > /dev/null 2>&1 || true
  $HOME/herramientas/librelane/bin/python3 asic/graficos.py --util $U $UF --salida-util docs/figuras/utilizacion.png > /dev/null 2>&1 || echo "aviso: graficos.py --util falló"
fi
echo "asic/final.md regenerado"
