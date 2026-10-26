#!/usr/bin/env bash
# Vigila las corridas de LibreLane que corren en Docker (regla de memoria del
# grupo: WSL tiene 32 GB y se colgó con 7 corridas a la vez).
#   - cada minuto anota en asic/logs/vigilancia.txt la memoria usada (free -m)
#     y las corridas activas con su tiempo transcurrido;
#   - detiene con docker kill toda corrida que pase de MAX_MIN minutos, y la
#     más antigua si la memoria usada pasa de MAX_MB; cada kill queda anotado
#     en asic/logs/detenidas.txt.
# El contenedor de una corrida se identifica por su --run-tag en docker ps.
# Uso: bash asic/vigilar.sh &   (termina solo cuando no queda ninguna corrida
# y han pasado ESPERA_FIN minutos sin corridas; o con kill).
set -u
cd "$(dirname "$0")/.."
MAX_MB="${MAX_MB:-26000}"
MAX_MIN="${MAX_MIN:-40}"
ESPERA_FIN="${ESPERA_FIN:-3}"
mkdir -p asic/logs
sin_corridas=0
while true; do
  usados=$(free -m | awk '/^Mem:/ {print $3}')
  ahora=$(date +%s)
  lista=""
  mas_vieja=""; mas_vieja_t=0
  while read -r id creado resto; do
    tag=$(echo "$resto" | grep -o -- '--run-tag [^ ]*' | awk '{print $2}')
    [ -z "$tag" ] && continue
    inicio=$(date -d "$creado" +%s 2>/dev/null || echo "$ahora")
    min=$(( (ahora - inicio) / 60 ))
    lista="$lista $tag(${min}min)"
    if [ "$min" -ge "$MAX_MIN" ]; then
      docker kill "$id" > /dev/null 2>&1
      echo "$(date '+%F %T') $tag detenida por tiempo (${min} min >= ${MAX_MIN})" >> asic/logs/detenidas.txt
    fi
    if [ "$min" -ge "$mas_vieja_t" ]; then mas_vieja="$id $tag"; mas_vieja_t=$min; fi
  done < <(docker ps --no-trunc --format '{{.ID}} {{.CreatedAt}} {{.Command}}' | grep -- '--run-tag' | sed 's/"//g')
  if [ "$usados" -gt "$MAX_MB" ] && [ -n "$mas_vieja" ]; then
    docker kill "${mas_vieja%% *}" > /dev/null 2>&1
    echo "$(date '+%F %T') ${mas_vieja#* } detenida por memoria (${usados} MB > ${MAX_MB})" >> asic/logs/detenidas.txt
  fi
  echo "$(date '+%F %T') usados=${usados}MB corridas:${lista:- ninguna}" >> asic/logs/vigilancia.txt
  if [ -z "$lista" ]; then sin_corridas=$((sin_corridas + 1)); else sin_corridas=0; fi
  [ "$sin_corridas" -ge "$ESPERA_FIN" ] && { echo "$(date '+%F %T') fin de la vigilancia" >> asic/logs/vigilancia.txt; exit 0; }
  sleep 60
done
