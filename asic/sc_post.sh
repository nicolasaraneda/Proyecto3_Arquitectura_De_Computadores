#!/usr/bin/env bash
# Post-proceso de una tanda de corridas del frente C (exp/signoff0), desde la raíz
# del worktree:
#   bash asic/sc_post.sh "<título>" "<nota>" <tag> [<tag> ...]
# 1. asic/recolectar.py: copia los reportes a asic/rom/resultados/<tag>/ y agrega la
#    tabla de la tanda a asic/barrido_exp.md;
# 2. asic/verificar_cierre.py: criterios de cierre -> resultados/<tag>/cierre.md;
# 3. asic/signoff_pines.py: violaciones de slew y capacitancia agrupadas, nets
#    restantes y regresión RC -> resultados/<tag>/pines.md.
set -u
cd "$(dirname "$0")/.."
titulo="$1"; nota="$2"; shift 2
runs=()
for tag in "$@"; do runs+=("asic/rom/runs/$tag"); done
python3 asic/recolectar.py --md asic/barrido_exp.md --titulo "$titulo" --nota "$nota" "${runs[@]}" > /dev/null
for tag in "$@"; do
  run=asic/rom/runs/$tag
  [ -f "$run/final/metrics.json" ] || { echo "$tag: incompleta (sin final/metrics.json)"; continue; }
  mkdir -p "asic/rom/resultados/$tag"
  python3 asic/verificar_cierre.py "$run" --md "asic/rom/resultados/$tag/cierre.md" > /dev/null && c=CIERRA || c="NO CIERRA"
  python3 asic/signoff_pines.py "$run" --md "asic/rom/resultados/$tag/pines.md" > /dev/null
  python3 - "$run" "$tag" "$c" <<'PY'
import json, sys
run, tag, c = sys.argv[1:4]
m = json.load(open(f"{run}/final/metrics.json"))
g = m.get
print(f"{tag}: {c}; setup WNS max_ss {g('timing__setup__ws__corner:max_ss_125C_4v50'):.3f} ns; hold WNS peor {g('timing__hold__ws'):.3f} ns; "
      f"área stdcell {g('design__instance__area__stdcell'):.0f} µm²; slew {g('design__max_slew_violation__count')} / cap {g('design__max_cap_violation__count')} "
      f"/ fanout {g('design__max_fanout_violation__count')}; DRC {g('magic__drc_error__count')} LVS {g('design__lvs_error__count')} antena {g('antenna__violating__nets')}")
PY
done
