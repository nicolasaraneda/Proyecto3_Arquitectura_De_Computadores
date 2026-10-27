#!/usr/bin/env bash
# Encola una corrida de LibreLane para asic/cola.sh. Imprime el id.
# Uso: bash asic/encolar.sh <directorio> <config.yaml> <tag> <CLOCK_PERIOD> [VAR=VAL ...] [--opcion ...]
#   bash asic/encolar.sh . asic/rom/config.yaml d4_u72 100 FP_CORE_UTIL=72
#   bash asic/encolar.sh build/exp_fmax asic/rom/config.yaml fb_t100 100 SYNTH_STRATEGY="DELAY 1"
# El tag tiene que ser único en toda la sesión (la cola identifica el contenedor por el tag).
set -eu
cd "$(dirname "$0")/.."
COLA=asic/logs/cola.txt
mkdir -p asic/logs; touch "$COLA"
dir="$1"; cfg="$2"; tag="$3"; t="$4"; shift 4
[ -d "$dir" ] || { echo "no existe el directorio $dir" >&2; exit 1; }
[ -f "$dir/$cfg" ] || { echo "no existe $dir/$cfg" >&2; exit 1; }
if grep -q "^[0-9]* [^ ]* [^ ]* $tag " "$COLA"; then
  echo "el tag $tag ya está en la cola: esa corrida ya se encoló antes (quizás por una ejecución previa e interrumpida de tu mismo frente)." >&2
  echo "Estado: $(grep " $tag " asic/logs/cola_estado.txt | tail -1). Si terminó, usa su resultado en $dir/$(dirname "$cfg")/runs/$tag en vez de repetirla; si falló o quedó incompleta y quieres repetirla, usa otro tag (p. ej. ${tag}_b)." >&2
  exit 1
fi
id=$(( $(grep -c "^[0-9]" "$COLA" 2>/dev/null || true) + 1 ))
extra=""
for kv in "$@"; do
  case "$kv" in *" "*) extra="$extra '$kv'" ;; *) extra="$extra $kv" ;; esac
done
printf '%s %s %s %s %s%s\n' "$id" "$dir" "$cfg" "$tag" "$t" "$extra" >> "$COLA"
echo "$(date '+%F %T') $id $tag encolada" >> asic/logs/cola_estado.txt
echo "$id"
