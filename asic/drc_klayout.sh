#!/usr/bin/env bash
# Segundo DRC, independiente del de Magic: el deck de KLayout de GF180MCU
# (asic/drc/gf180mcu.drc, ver asic/drc/ORIGEN.md) sobre el GDS final de una
# corrida, con KLayout en modo batch dentro de la imagen de Docker de LibreLane.
# Es el mismo comando que usa el paso KLayout.DRC de LibreLane (steps/klayout.py,
# run_gf180mcu), con las opciones de la variante D del PDK (metal_top 11K, MIM B,
# 5 metales, README del deck), FEOL y BEOL, chequeo de grilla y sin conectividad.
#
# Uso: bash asic/drc_klayout.sh <corrida> [gds]
#   bash asic/drc_klayout.sh asic/rom/runs/final
# Deja en asic/<config>/resultados/<tag>/drc_klayout/: el lyrdb (base de
# marcadores de KLayout), el log y un resumen por regla (resumen.md).
set -eu
cd "$(dirname "$0")/.."
RUN="${1%/}"
TAG=$(basename "$RUN")
CFG=$(dirname "$(dirname "$RUN")")
GDS="${2:-$RUN/final/gds/asic_top.gds}"
OUT="$CFG/resultados/$TAG/drc_klayout"
IMAGEN="${IMAGEN:-ghcr.io/librelane/librelane:3.0.16}"
HILOS="${HILOS:-8}"
mkdir -p "$OUT"
echo "DRC de KLayout sobre $GDS ($HILOS hilos)"
docker run --rm --user "$(id -u):$(id -g)" -v "$HOME:$HOME" -w "$(pwd)" -e HOME="$HOME" "$IMAGEN" \
  klayout -b -zz -r asic/drc/gf180mcu.drc \
    -rd "input=$GDS" -rd topcell=asic_top -rd "report=$OUT/drc.lyrdb" \
    -rd feol=true -rd beol=true -rd offgrid=true -rd conn_drc=false \
    -rd metal_top=11K -rd mim_option=B -rd metal_level=5LM \
    -rd run_mode=flat -rd "thr=$HILOS" > "$OUT/drc.log" 2>&1 || { echo "klayout terminó con error; ver $OUT/drc.log"; tail -5 "$OUT/drc.log"; exit 1; }
python3 asic/drc/resumir.py "$OUT/drc.lyrdb" --md "$OUT/resumen.md" --gds "$GDS"
