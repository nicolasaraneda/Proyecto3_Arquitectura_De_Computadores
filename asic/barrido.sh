#!/usr/bin/env bash
# Corre en paralelo una lista de corridas de LibreLane, una por línea de la
# entrada estándar: <config.yaml> <tag> <CLOCK_PERIOD> [VARIABLE=VALOR ...] [--opcion ...].
# Cada VARIABLE=VALOR extra se pasa con -c y cambia esa variable solo para
# esa corrida; lo que empiece con -- (y el valor que lo siga) se pasa tal cual
# a librelane, por ejemplo "--to Yosys.Synthesis".
# Uso: bash asic/barrido.sh < lista.txt   (PAR=3 corridas a la vez por defecto: máximo acordado por la memoria de WSL)
# Cada corrida deja su salida en asic/logs/<tag>.log y, al terminar, una
# línea en asic/logs/estado.txt con su código de salida.
set -u
cd "$(dirname "$0")/.."
source ~/herramientas/librelane/bin/activate
PAR="${PAR:-3}"
mkdir -p asic/logs
corrida() {
  cfg="$1"; tag="$2"; t="$3"; shift 3
  extra=()
  for kv in "$@"; do
    case "$kv" in
      --*) extra+=("$kv") ;;
      *=*) extra+=(-c "$kv") ;;
      *)   extra+=("$kv") ;;
    esac
  done
  librelane --docker-no-tty --dockerized --pdk gf180mcuD "$cfg" \
    -c CLOCK_PERIOD="$t" "${extra[@]}" --run-tag "$tag" --overwrite \
    > "asic/logs/$tag.log" 2>&1
  echo "$(date '+%F %T') $tag codigo $?" >> asic/logs/estado.txt
}
export -f corrida
xargs -P "$PAR" -L 1 bash -c 'corrida "$@"' _
