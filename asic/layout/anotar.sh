#!/usr/bin/env bash
# Lanza asic/layout/anotar.py con KLayout en modo batch dentro de la imagen de
# Docker de LibreLane. Uso: bash asic/layout/anotar.sh <corrida> [opciones -rd ...]
#   bash asic/layout/anotar.sh asic/rom/runs/final
#   bash asic/layout/anotar.sh asic/ff/runs/s2_t100 -rd net=net3342 -rd nombre=antena_antes
set -eu
cd "$(dirname "$0")/../.."
RUN="$1"; shift
IMAGEN="${IMAGEN:-ghcr.io/librelane/librelane:3.0.16}"
PDK_ROOT="${PDK_ROOT:-$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee}"
docker run --rm --user "$(id -u):$(id -g)" -v "$HOME:$HOME" -w "$(pwd)" -e HOME="$HOME" -e PDK_ROOT="$PDK_ROOT" \
  "$IMAGEN" klayout -b -r asic/layout/anotar.py -rd "run=$RUN" "$@" 2>&1 | grep -v "^Warning: No mapping"
