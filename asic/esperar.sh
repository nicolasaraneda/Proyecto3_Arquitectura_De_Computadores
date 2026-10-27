#!/usr/bin/env bash
# Espera a que las corridas con esos tags lleguen a un estado final en la cola
# (terminada, fallida o incompleta) y las imprime. Uso:
#   bash asic/esperar.sh [-t minutos] <tag> [<tag> ...]
# Termina con código 0 si todas terminaron (terminada), 1 si alguna falló o
# quedó incompleta, 2 si se agotó el tiempo de espera (por defecto 240 min).
set -u
cd "$(dirname "$0")/.."
ESTADO=asic/logs/cola_estado.txt
MAXMIN=240
if [ "${1:-}" = "-t" ]; then MAXMIN="$2"; shift 2; fi
inicio=$(date +%s)
while true; do
  faltan=0; mal=0
  for tag in "$@"; do
    linea=$(grep " $tag \(terminada\|fallida\|incompleta\)" "$ESTADO" 2>/dev/null | tail -1)
    if [ -z "$linea" ]; then faltan=$((faltan + 1)); else case "$linea" in *terminada*) ;; *) mal=$((mal + 1)) ;; esac; fi
  done
  if [ "$faltan" = 0 ]; then
    for tag in "$@"; do grep " $tag \(terminada\|fallida\|incompleta\)" "$ESTADO" | tail -1; done
    [ "$mal" = 0 ] && exit 0 || exit 1
  fi
  if [ $(( ($(date +%s) - inicio) / 60 )) -ge "$MAXMIN" ]; then
    echo "tiempo de espera agotado ($MAXMIN min); faltan $faltan corridas"
    for tag in "$@"; do grep " $tag " "$ESTADO" | tail -1; done
    exit 2
  fi
  sleep 60
done
