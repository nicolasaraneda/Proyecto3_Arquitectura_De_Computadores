#!/usr/bin/env bash
# Control positivo del DRC de KLayout: demuestra que el deck asic/drc/gf180mcu.drc
# detecta errores. Copia el GDS de la corrida final a build/drc_control/, le
# agrega en una zona vacía del die dos violaciones conocidas de Metal1
# (asic/drc/control_positivo.py: ancho mínimo M1.1 y espaciado mínimo M1.2a),
# corre asic/drc_klayout.sh sobre la copia y verifica que los marcadores son
# exactamente esos, en esas coordenadas.
#
# Uso: bash asic/drc/control_positivo.sh [corrida]     (por defecto asic/rom/runs/final)
# Deja el GDS, el lyrdb y el log en build/drc_control/ (sin versionar) y el
# informe en asic/<config>/resultados/<tag>/drc_klayout/control_positivo.md.
set -eu
cd "$(dirname "$0")/../.."
RUN="${1:-asic/rom/runs/final}"; RUN="${RUN%/}"
TAG=$(basename "$RUN")
CFG=$(dirname "$(dirname "$RUN")")
IMAGEN="${IMAGEN:-ghcr.io/librelane/librelane:3.0.16}"
DIR="build/drc_control"
GDS="$DIR/asic_top_control.gds"
MD="$CFG/resultados/$TAG/drc_klayout/control_positivo.md"
mkdir -p "$DIR" "$(dirname "$MD")"

echo "== 1. copia del GDS con las violaciones =="
docker run --rm --user "$(id -u):$(id -g)" -v "$HOME:$HOME" -w "$(pwd)" -e HOME="$HOME" "$IMAGEN" \
  klayout -b -r asic/drc/control_positivo.py -rd modo=insertar \
    -rd "entrada=$RUN/final/gds/asic_top.gds" -rd "salida=$GDS" 2>&1 | grep -v "^Warning"

echo "== 2. DRC de KLayout sobre la copia =="
OUT="$(pwd)/$DIR" bash asic/drc_klayout.sh "$RUN" "$GDS"

echo "== 3. verificación de los marcadores =="
python3 asic/drc/control_positivo.py verificar "$DIR/drc.lyrdb" "$MD" "$GDS"
