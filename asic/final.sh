#!/usr/bin/env bash
# Corrida final reproducible (enunciado, sección 2) y todo lo que depende de ella.
#
# Uso: bash asic/final.sh [--sin-corrida] [--solo-figuras]
#   --sin-corrida  no vuelve a correr LibreLane si asic/rom/runs/final ya existe
#                  (regenera solo los análisis).
# Pasos:
#   1. librelane ... asic/rom/config.yaml --run-tag final   (T = 100 ns, FP_CORE_UTIL = 40)
#   2. asic/verificar_cierre.py: DRC, LVS, antenas, setup y hold en las 9 esquinas
#      (se detiene si no cierra)
#   3. asic/tablas.sh: copia los reportes a asic/rom/resultados/ y escribe asic/final.md
#      (corrida final y los barridos f1_*, r0_*, u1_* que existan) y los gráficos
#   4. síntesis jerárquica (h3_t100, solo hasta Yosys.Synthesis) y
#      asic/analisis_sintesis.py -> asic/sintesis.md          (sección 3.3)
#   5. asic/layout/anotar.py (KLayout en la imagen de Docker) ->
#      asic/rom/resultados/final/layout/                      (sección 3.6)
#   6. asic/drc_klayout.sh: segundo DRC con el deck de KLayout del PDK, y
#      asic/drc/control_positivo.sh: el control positivo de ese DRC
#   7. make post-synth y make post-synth-final                (sección 3.7)
#   8. asic/versiones.sh -> asic/versiones.md
# Los barridos de período y de utilización se lanzan aparte (asic/barridos.sh).
set -eu
cd "$(dirname "$0")/.."
LL="${LIBRELANE:-$HOME/herramientas/librelane/bin/librelane --dockerized --pdk gf180mcuD}"
SIN_CORRIDA=0
for a in "$@"; do [ "$a" = "--sin-corrida" ] && SIN_CORRIDA=1; done

if [ "$SIN_CORRIDA" = 0 ] || [ ! -f asic/rom/runs/final/final/metrics.json ]; then
  echo "== 1. corrida final =="
  $LL asic/rom/config.yaml --run-tag final --overwrite
fi

echo "== 2. criterios de cierre =="
mkdir -p asic/rom/resultados/final
python3 asic/verificar_cierre.py asic/rom/runs/final --md asic/rom/resultados/final/cierre.md

echo "== 3. reportes y tablas (final y barridos que existan) =="
bash asic/tablas.sh
cp asic/rom/runs/final/resolved.json asic/rom/resultados/final/resolved.json
cp asic/rom/runs/final/warning.log asic/rom/resultados/final/warning.log
# Los pasos van numerados y el numero cambia con la configuracion (la de D23
# agrega RepairDesignPostGRT en el 41 y ResizerTimingPostGRT en el 44, que no van
# seguidos: stapostpnr pasa de 55 a 57 y checkantennas-1 de 46 a 48, pero
# diodesonports y repairantennas se corren solo un lugar): se buscan por nombre.
STA=$(ls -d asic/rom/runs/final/*-openroad-stapostpnr | tail -1)
ANT=$(ls -d asic/rom/runs/final/*-openroad-checkantennas-1 | tail -1)
for e in nom_tt_025C_5v00 max_ss_125C_4v50; do
  cp "$STA/$e/checks.rpt" "asic/rom/resultados/final/${e}_checks.rpt"
done
cp "$ANT/reports/antenna.rpt" asic/rom/resultados/final/antenna.rpt 2>/dev/null || true

echo "== 4. síntesis jerárquica y análisis (3.3) =="
if [ -z "$(ls -d asic/rom/runs/h3_t100/*-yosys-synthesis 2>/dev/null)" ]; then
  $LL asic/rom/config.yaml -c SYNTH_HIERARCHY_MODE=keep --to Yosys.Synthesis --run-tag h3_t100 --overwrite
fi
mkdir -p asic/rom/resultados/h3_t100
SJ=$(ls -d asic/rom/runs/h3_t100/*-yosys-synthesis | tail -1)
SF=$(ls -d asic/rom/runs/final/*-yosys-synthesis | tail -1)
cp "$SJ/reports/stat.rpt" asic/rom/resultados/h3_t100/sintesis_jerarquica.rpt
cp "$SJ/reports/stat.json" asic/rom/resultados/h3_t100/sintesis_jerarquica.json
cp "$SF/reports/stat.json" asic/rom/resultados/final/sintesis_stat.json
python3 asic/analisis_sintesis.py --final asic/rom/runs/final --jerarquica asic/rom/runs/h3_t100 --md asic/sintesis.md > /dev/null

echo "== 5. figuras del layout (3.6) =="
bash asic/layout/anotar.sh asic/rom/runs/final

echo "== 6. DRC de KLayout con el deck del PDK y su control positivo =="
bash asic/drc_klayout.sh asic/rom/runs/final
bash asic/drc/control_positivo.sh asic/rom/runs/final

echo "== 7. simulación post-síntesis (3.7) =="
make post-synth
make post-synth-final

echo "== 8. versiones =="
bash asic/versiones.sh > /dev/null
echo "listo: asic/final.md, asic/sintesis.md, asic/rom/resultados/final/, asic/sim/resultado.md, asic/versiones.md"
