#!/usr/bin/env bash
# Corre en paralelo una lista de corridas de LibreLane, una por línea de la
# entrada estándar: <config.yaml> <tag> <CLOCK_PERIOD>.
# Uso: bash asic/barrido.sh < lista.txt   (PAR=4 corridas a la vez por defecto)
# Cada corrida deja su salida en asic/logs/<tag>.log y, al terminar, una
# línea en asic/logs/estado.txt con su código de salida.
set -u
cd "$(dirname "$0")/.."
source ~/herramientas/librelane/bin/activate
PAR="${PAR:-4}"
mkdir -p asic/logs
corrida() {
  cfg="$1"; tag="$2"; t="$3"
  librelane --docker-no-tty --dockerized --pdk gf180mcuD "$cfg" \
    -c CLOCK_PERIOD="$t" --run-tag "$tag" --overwrite \
    > "asic/logs/$tag.log" 2>&1
  echo "$(date '+%F %T') $tag codigo $?" >> asic/logs/estado.txt
}
export -f corrida
xargs -P "$PAR" -L 1 bash -c 'corrida "$@"' _
