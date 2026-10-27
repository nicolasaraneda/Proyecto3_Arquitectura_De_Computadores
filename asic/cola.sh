#!/usr/bin/env bash
# Cola única de corridas de LibreLane (sesión del 27-10-2026). Un solo proceso
# lanza TODAS las corridas, con un máximo de PAR simultáneas, para respetar la
# memoria de WSL (32 GB). Los demás procesos solo encolan con asic/encolar.sh y
# esperan con asic/esperar.sh.
#
# Cola:   asic/logs/cola.txt       una línea por trabajo:
#           <id> <directorio> <config.yaml> <tag> <CLOCK_PERIOD> [VAR=VAL ...] [--opcion ...]
#         <directorio> es la raíz del repo o de un worktree (build/exp_*), y
#         <config.yaml> es relativo a ese directorio.
# Estado: asic/logs/cola_estado.txt  una línea por evento:
#           <fecha> <id> <tag> <estado> [detalle]
#         estados: encolada, lanzada, terminada (código 0 y final/metrics.json),
#         fallida (código distinto de 0 o sin metrics), incompleta (cortada a
#         los MAX_MIN minutos o por memoria).
# Reglas: no lanza si quedan menos de MIN_LIBRE_GB libres (free -g, columna
# available) o si hay más de MAX_USADOS_MB usados; corta con docker kill toda
# corrida que pase de MAX_MIN minutos y la registra como incompleta; si el
# disco baja de MIN_DISCO_GB deja de lanzar y lo anota (no borra nada).
# Uso: bash asic/cola.sh &      (termina con: touch asic/logs/cola.fin)
set +u
cd "$(dirname "$0")/.."
RAIZ=$(pwd)
source ~/herramientas/librelane/bin/activate
PAR="${PAR:-3}"
MAX_MIN="${MAX_MIN:-40}"
MIN_LIBRE_GB="${MIN_LIBRE_GB:-6}"
MAX_USADOS_MB="${MAX_USADOS_MB:-20000}"
MIN_DISCO_GB="${MIN_DISCO_GB:-60}"
COLA=asic/logs/cola.txt
ESTADO=asic/logs/cola_estado.txt
touch "$COLA" "$ESTADO"
rm -f asic/logs/cola.fin
declare -A pid_de tag_de dir_de cfg_de inicio_de
anota() { echo "$(date '+%F %T') $*" >> "$ESTADO"; }
lanzadas() { grep -c " lanzada" "$ESTADO" 2>/dev/null || true; }
ya_lanzada() { grep -q "^[^ ]* [^ ]* $1 [^ ]* lanzada" "$ESTADO"; }
corrida() {
  # $1 id, $2 dir, $3 cfg, $4 tag, $5 T, resto extras
  local id="$1" dir="$2" cfg="$3" tag="$4" t="$5"; shift 5
  local extra=()
  for kv in "$@"; do
    case "$kv" in
      --*) extra+=("$kv") ;;
      *=*) extra+=(-c "$kv") ;;
      *)   extra+=("$kv") ;;
    esac
  done
  mkdir -p "$dir/asic/logs"
  ( cd "$dir" && librelane --docker-no-tty --dockerized --pdk gf180mcuD "$cfg" \
      -c CLOCK_PERIOD="$t" "${extra[@]}" --run-tag "$tag" --overwrite \
      > "asic/logs/$tag.log" 2>&1 )
}
anota cola iniciada "PAR=$PAR MAX_MIN=$MAX_MIN"
while true; do
  # 1. revisar las corridas activas
  for id in "${!pid_de[@]}"; do
    pid=${pid_de[$id]}; tag=${tag_de[$id]}; dir=${dir_de[$id]}; cfg=${cfg_de[$id]}
    if ! kill -0 "$pid" 2>/dev/null; then
      wait "$pid"; codigo=$?
      cfgdir=$(dirname "$cfg")
      if [ -f "$dir/$cfgdir/runs/$tag/final/metrics.json" ] && [ "$codigo" = 0 ]; then
        anota "$id" "$tag" terminada "codigo $codigo"
      elif [ -f "$dir/$cfgdir/runs/$tag/final/metrics.json" ]; then
        anota "$id" "$tag" terminada "codigo $codigo (con metrics.json; revisar el log)"
      elif grep -q "^.* $id $tag incompleta" "$ESTADO"; then
        :
      else
        anota "$id" "$tag" fallida "codigo $codigo (ver $dir/asic/logs/$tag.log)"
      fi
      unset "pid_de[$id]" "tag_de[$id]" "dir_de[$id]" "cfg_de[$id]" "inicio_de[$id]"
      continue
    fi
    min=$(( ($(date +%s) - ${inicio_de[$id]}) / 60 ))
    if [ "$min" -ge "$MAX_MIN" ]; then
      cid=$(docker ps --no-trunc --format '{{.ID}} {{.Command}}' | grep -- "--run-tag $tag " | awk '{print $1}' | head -1)
      [ -n "$cid" ] && docker kill "$cid" > /dev/null 2>&1
      anota "$id" "$tag" incompleta "detenida a los $min min (>= $MAX_MIN); contenedor ${cid:-no encontrado}"
      echo "$(date '+%F %T') $tag detenida por tiempo (${min} min >= ${MAX_MIN})" >> asic/logs/detenidas.txt
    fi
  done
  # 2. memoria: si se pasa, cortar la más vieja
  usados=$(free -m | awk '/^Mem:/ {print $3}')
  if [ "$usados" -gt 26000 ] && [ "${#pid_de[@]}" -gt 0 ]; then
    vieja=""; vt=9999999999
    for id in "${!pid_de[@]}"; do [ "${inicio_de[$id]}" -lt "$vt" ] && { vt=${inicio_de[$id]}; vieja=$id; }; done
    tag=${tag_de[$vieja]}
    cid=$(docker ps --no-trunc --format '{{.ID}} {{.Command}}' | grep -- "--run-tag $tag " | awk '{print $1}' | head -1)
    [ -n "$cid" ] && docker kill "$cid" > /dev/null 2>&1
    anota "$vieja" "$tag" incompleta "detenida por memoria (${usados} MB usados)"
    echo "$(date '+%F %T') $tag detenida por memoria (${usados} MB > 26000)" >> asic/logs/detenidas.txt
  fi
  # 3. lanzar pendientes si hay cupo
  libre=$(free -g | awk '/^Mem:/ {print $7}')
  disco=$(df -BG --output=avail . | tail -1 | tr -d 'G ')
  if [ "${#pid_de[@]}" -lt "$PAR" ] && [ "$libre" -ge "$MIN_LIBRE_GB" ] && [ "$usados" -le "$MAX_USADOS_MB" ] && [ "$disco" -ge "$MIN_DISCO_GB" ]; then
    while read -r id dir cfg tag t resto; do
      [ -z "${id:-}" ] && continue
      case "$id" in \#*) continue ;; esac
      ya_lanzada "$tag" && continue
      grep -q " $id $tag " "$ESTADO" && grep -q " $id $tag \(terminada\|fallida\|incompleta\|lanzada\)" "$ESTADO" && continue
      [ "${#pid_de[@]}" -ge "$PAR" ] && break
      # shellcheck disable=SC2086
      corrida "$id" "$dir" "$cfg" "$tag" "$t" $resto &
      pid_de[$id]=$!; tag_de[$id]=$tag; dir_de[$id]=$dir; cfg_de[$id]=$cfg; inicio_de[$id]=$(date +%s)
      anota "$id" "$tag" lanzada "en $dir ($cfg T=$t $resto); usados=${usados}MB libre=${libre}GB disco=${disco}GB"
      libre=$(free -g | awk '/^Mem:/ {print $7}')
      [ "$libre" -lt "$MIN_LIBRE_GB" ] && break
      sleep 20
    done < "$COLA"
  elif [ "$disco" -lt "$MIN_DISCO_GB" ]; then
    grep -q "disco bajo" "$ESTADO" || anota cola aviso "disco bajo: ${disco} GB libres; no se lanzan corridas nuevas"
  fi
  [ -f asic/logs/cola.fin ] && [ "${#pid_de[@]}" = 0 ] && { anota cola fin; exit 0; }
  sleep 30
done
