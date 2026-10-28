#!/usr/bin/env bash
# Simulación post-PnR con retardos anotados (SDF) de una esquina, repetida
# REPETIR veces, con el Icarus Verilog 13.0 de la imagen de LibreLane (no el
# 14.0-devel del host). La llama `make post-pnr-sdf`; también sirve sola:
#   bash asic/sim/post_pnr_sdf.sh <RUN> <ESQUINA> <REPETIR> <ESCENARIO> [MUESTREO] [ESTIMULO]
#   RUN        corrida completa de LibreLane (asic/sim/runs/d1_pnr o asic/rom/runs/final)
#   ESQUINA    nom_tt_025C_5v00, max_ss_125C_4v50, min_ff_n40C_5v50, ...
#   REPETIR    ejecuciones de vvp con el mismo binario (3: demuestra que es reproducible)
#   ESCENARIO  sim:   asic/sim/estimulos.txt, 4500 ciclos, ROM de simulación
#                     (CYCLES_PER_TENTH=1) y DebounceDivBits=2 (corridas de asic/sim/config_pnr.yaml)
#              final: asic/sim/estimulos_final.txt, 320000 ciclos, ROM real y
#                     DebounceDivBits=15 (corridas de asic/rom/config.yaml)
#   MUESTREO   ns después del flanco en que el testbench muestrea las salidas (50)
#   ESTIMULO   ns después del flanco en que el testbench aplica rst_n y los botones (50).
#              Tiene que superar la latencia del árbol de reloj (0,8 a 2,7 ns en
#              d1_pnr según la esquina): con el +1 ns de make post-synth el netlist
#              anotado captura cada entrada un ciclo antes que el RTL (ver tb/post_synth_tb.v).
# Variables de entorno: IMAGEN_DOCKER (imagen con iverilog y vvp; por defecto la
# de LibreLane 3.0.16), PDK_ROOT.
#
# Qué hace:
#   1. Traza de referencia del RTL con el mismo testbench, estímulos, ciclos,
#      MUESTREO y ESTIMULO, con el mismo Icarus (build/post_pnr/<tag>/traza_rtl_<escenario>.txt).
#   2. Renombra las instancias de nombre jerárquico del netlist y del SDF
#      (asic/sim/renombrar_instancias.py): sin eso vvp aborta en el primer
#      INTERCONNECT a una de ellas y no encuentra esas celdas.
#   3. Compila el netlist con los modelos del PDK con sus bloques specify
#      (-gspecify -ginterconnect, sin -DFUNCTIONAL) y el $sdf_annotate del testbench.
#      Cuenta los avisos "Timing checks are not supported" de iverilog.
#   4. Corre vvp REPETIR veces; antes de cada una borra la traza (un aborto no
#      puede dar un PASS falso). Guarda la salida completa, el tiempo (time de
#      bash dentro de la imagen) y el md5 de cada traza.
#   5. Cuenta las entradas del SDF por tipo (IOPATH, INTERCONNECT, TIMINGCHECK y
#      sus SETUP, HOLD, WIDTH, RECOVERY, REMOVAL, PERIOD), los mensajes del SDF
#      que imprime vvp (IOPATH sin ModPath, INTERCONNECT no creados, TIMINGCHECK
#      no soportado) y los de timing checks evaluados, si el simulador los emite.
#   6. Compara cada traza con la del RTL (asic/sim/comparar.py) y escribe
#      build/post_pnr/<tag>/<esquina>[_final]/resumen.md.
# Termina con código distinto de 0 si vvp falla, si una traza difiere del RTL o
# si los md5 de las repeticiones no coinciden.
set -u
cd "$(dirname "$0")/../.."
RUN="${1:?RUN}"; ESQ="${2:?ESQUINA}"; REP="${3:-3}"; ESC="${4:-sim}"; MUESTREO="${5:-50}"; ESTIMULO="${6:-50}"
PDK_ROOT="${PDK_ROOT:-$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee}"
SCL=gf180mcu_fd_sc_mcu7t5v0
CELDAS="$PDK_ROOT/gf180mcuD/libs.ref/$SCL/verilog/primitives.v $PDK_ROOT/gf180mcuD/libs.ref/$SCL/verilog/$SCL.v"
IMAGEN_DOCKER="${IMAGEN_DOCKER:-ghcr.io/librelane/librelane:3.0.16}"
# iverilog y vvp de la imagen, con el home montado y el directorio actual como cwd
dk() { docker run --rm --user "$(id -u):$(id -g)" -v "$HOME:$HOME" -w "$PWD" -e HOME="$HOME" "$IMAGEN_DOCKER" "$@"; }
IV="dk iverilog"
case "$ESC" in
  sim)   EST=asic/sim/estimulos.txt;       CICLOS=4500;   DIV=2;  ROMDIR=asic/sim/gen; ROM=asic/sim/gen/pochoco_rom.v; SUF="" ;;
  final) EST=asic/sim/estimulos_final.txt; CICLOS=320000; DIV=15; ROMDIR=rtl/gen;      ROM=rtl/gen/pochoco_rom.v;      SUF="_final" ;;
  *) echo "escenario $ESC desconocido (sim|final)" >&2; exit 2 ;;
esac
TAG=$(basename "$RUN")
NL="$RUN/final/nl/asic_top.nl.v"
SDF="$RUN/final/sdf/$ESQ/asic_top__$ESQ.sdf"
[ -f "$NL" ] || { echo "no existe $NL" >&2; exit 2; }
[ -f "$SDF" ] || { echo "no existe $SDF" >&2; exit 2; }
D="build/post_pnr/$TAG"; E="$D/$ESQ$SUF"
mkdir -p "$E"
VERS="$($IV -V 2>&1 | head -1); $(dk vvp -V 2>&1 | head -1); imagen $IMAGEN_DOCKER ($(docker images --no-trunc --format '{{.ID}}' "$IMAGEN_DOCKER" | head -1 | cut -c1-19))"
echo "post-pnr-sdf: corrida $RUN, esquina $ESQ, escenario $ESC ($EST, $CICLOS ciclos, DebounceDivBits=$DIV), $REP repeticiones, estimulos a +$ESTIMULO ns, muestreo a +$MUESTREO ns"
echo "versiones: $VERS"

# 1. referencia del RTL
TR="$D/traza_rtl_$ESC.txt"
rm -f "$TR"
$IV -g2012 -I "$ROMDIR" -DESTIMULOS="\"$EST\"" -DTRAZA="\"$TR\"" -DCICLOS=$CICLOS -DDIV_BITS=$DIV -DMUESTREO=$MUESTREO -DESTIMULO=$ESTIMULO \
    -o "$D/tb_rtl_$ESC" tb/post_synth_tb.v rtl/*.v rtl/espino_core/*.v "$ROM" || exit 1
dk bash -c "TIMEFORMAT='real %R s, usuario %U s, sistema %S s'; { time vvp $D/tb_rtl_$ESC > $D/vvp_rtl_$ESC.log 2>&1 ; } 2> $D/tiempo_rtl_$ESC.txt; echo \"codigo \$?\" >> $D/tiempo_rtl_$ESC.txt"
[ "$(grep codigo "$D/tiempo_rtl_$ESC.txt" | awk '{print $2}')" = 0 ] && [ -s "$TR" ] || { tail -3 "$D/vvp_rtl_$ESC.log"; exit 1; }
echo "RTL: $(grep 'ciclos,' "$D/vvp_rtl_$ESC.log" | sed 's/post_synth_tb: //; s/, traza en.*//'); $(head -1 "$D/tiempo_rtl_$ESC.txt"); md5 $(md5sum "$TR" | cut -c1-32)"

# 2. instancias renombradas
python3 asic/sim/renombrar_instancias.py --netlist "$NL" --salida "$E" "$SDF" | tee "$E/renombrar.log" || exit 1
NL2="$E/asic_top.nl.v"; SDF2="$E/asic_top__$ESQ.sdf"

# 3. compilación con specify y SDF
$IV -g2012 -gspecify -ginterconnect -DNETLIST -DSDF="\"$SDF2\"" -DESTIMULOS="\"$EST\"" -DTRAZA="\"$E/traza.txt\"" \
    -DCICLOS=$CICLOS -DMUESTREO=$MUESTREO -DESTIMULO=$ESTIMULO -o "$E/tb_sdf" tb/post_synth_tb.v "$NL2" $CELDAS > "$E/iverilog.log" 2>&1
c=$?; [ -s "$E/tb_sdf" ] || { echo "iverilog fallo (codigo $c), ver $E/iverilog.log"; tail -5 "$E/iverilog.log"; exit 1; }
TC_NOSOP=$(grep -c "Timing checks are not supported" "$E/iverilog.log")
IFNONE=$(grep -c "ifnone with an edge-sensitive path is not supported" "$E/iverilog.log")
echo "iverilog: $TC_NOSOP avisos 'Timing checks are not supported', $IFNONE 'ifnone with an edge-sensitive path is not supported' (ver $E/iverilog.log)"

# 4. repeticiones
fallo=0; md5s=""
for n in $(seq 1 "$REP"); do
  rm -f "$E/traza.txt"
  dk bash -c "TIMEFORMAT='real %R s, usuario %U s, sistema %S s'; { time vvp $E/tb_sdf > $E/vvp_$n.log 2>&1 ; } 2> $E/tiempo_$n.txt; echo \"codigo \$?\" >> $E/tiempo_$n.txt"
  cod=$(grep codigo "$E/tiempo_$n.txt" | awk '{print $2}')
  if [ "$cod" != 0 ] || [ ! -s "$E/traza.txt" ]; then
    echo "repeticion $n: vvp termino con codigo $cod (ver $E/vvp_$n.log)"; grep -v "^SDF" "$E/vvp_$n.log" | tail -3; fallo=1
    cp -f "$E/traza.txt" "$E/traza_$n.txt" 2>/dev/null; continue
  fi
  cp -f "$E/traza.txt" "$E/traza_$n.txt"
  m=$(md5sum "$E/traza_$n.txt" | cut -c1-32); md5s="$md5s $m"
  echo "repeticion $n: $(head -1 "$E/tiempo_$n.txt"); $(grep 'ciclos,' "$E/vvp_$n.log" | sed 's/post_synth_tb: //; s/, traza en.*//'); md5 $m"
done

# 5. entradas del SDF por tipo, mensajes del SDF y de timing checks (de la primera repetición)
L="$E/vvp_1.log"
cuenta() { grep -c "$1" "$L" 2>/dev/null || true; }
SDF_TC=$(cuenta "TIMINGCHECK not supported")
SDF_NOCELL=$(cuenta "Cannot find .* in scope")
SDF_MODPATH=$(cuenta "Unable to match ModPath")
SDF_INTER=$(cuenta "Could not find intermodpath")
SDF_OTROS=$(grep "^SDF" "$L" | grep -vc "TIMINGCHECK not supported\|Cannot find .* in scope\|Unable to match ModPath\|Could not find intermodpath" || true)
VIOL=$(grep -v "^SDF" "$L" | grep -ci "timing violation\|\$setup\|\$hold\|\$width\|\$recovery\|\$removal\|\$period\|setup check\|hold check" || true)
IOPATH_SDF=$(grep -c "(IOPATH" "$SDF2"); INTER_SDF=$(grep -c "(INTERCONNECT" "$SDF2"); TC_SDF=$(grep -c "(TIMINGCHECK" "$SDF2")
SETUP_SDF=$(grep -c "(SETUP " "$SDF2"); HOLD_SDF=$(grep -c "(HOLD " "$SDF2"); SETUPHOLD_SDF=$(grep -c "(SETUPHOLD " "$SDF2")
WIDTH_SDF=$(grep -c "(WIDTH " "$SDF2"); REC_SDF=$(grep -c "(RECOVERY " "$SDF2"); REM_SDF=$(grep -c "(REMOVAL " "$SDF2")
RECREM_SDF=$(grep -c "(RECREM " "$SDF2"); PER_SDF=$(grep -c "(PERIOD " "$SDF2")
CHECKS_SDF=$((SETUP_SDF + HOLD_SDF + SETUPHOLD_SDF + WIDTH_SDF + REC_SDF + REM_SDF + RECREM_SDF + PER_SDF))
IOPATH_OK=$((IOPATH_SDF - SDF_MODPATH)); INTER_OK=$((INTER_SDF - SDF_INTER))
echo "SDF ($SDF2): $IOPATH_SDF IOPATH, $INTER_SDF INTERCONNECT, $TC_SDF bloques TIMINGCHECK con $CHECKS_SDF checks (SETUP $SETUP_SDF, HOLD $HOLD_SDF, SETUPHOLD $SETUPHOLD_SDF, WIDTH $WIDTH_SDF, RECOVERY $REC_SDF, REMOVAL $REM_SDF, RECREM $RECREM_SDF, PERIOD $PER_SDF)"
echo "  vvp: $SDF_NOCELL celdas no encontradas, $SDF_MODPATH IOPATH sin ModPath que case (quedan $IOPATH_OK), $SDF_INTER INTERCONNECT no creados (quedan $INTER_OK), $SDF_TC avisos 'TIMINGCHECK not supported', $SDF_OTROS otros mensajes SDF"
if [ "$TC_NOSOP" -gt 0 ] || [ "$SDF_TC" -gt 0 ]; then
  TCHK="no evaluados ($TC_SDF bloques ignorados)"
  echo "  timing checks: NO EVALUADOS por este simulador ($TC_NOSOP avisos de iverilog, $SDF_TC de vvp); los $CHECKS_SDF checks de los $TC_SDF bloques TIMINGCHECK del SDF no se verifican en la simulacion (el cierre de setup/hold lo da el STA de las 9 esquinas: asic/verificar_cierre.py)"
else
  TCHK="evaluados: $VIOL violaciones reportadas"
  echo "  timing checks: $VIOL mensajes de violacion reportados por el simulador"
fi
grep "^SDF\|^VPI" "$L" | sed 's/sdf:[0-9]*:/sdf:N:/; s/_[0-9]\+_/_N_/g; s/in post_synth_tb.dut[^ ]*/in INST/' | sort | uniq -c | sort -rn > "$E/mensajes_sdf.txt"

# 6. comparación con el RTL
iguales_rtl=0; distintas=0
for n in $(seq 1 "$REP"); do
  [ -s "$E/traza_$n.txt" ] || { distintas=$((distintas + 1)); continue; }
  if python3 asic/sim/comparar.py "$TR" "$E/traza_$n.txt" --md "$E/comparacion_$n.md" > "$E/comparacion_$n.txt"; then iguales_rtl=$((iguales_rtl + 1)); else distintas=$((distintas + 1)); fi
done
nmd5=$(echo $md5s | tr ' ' '\n' | sort -u | grep -c .)
[ "$nmd5" = 1 ] && [ "$(echo $md5s | wc -w)" = "$REP" ] && md5ok="sí" || md5ok="no"
[ "$iguales_rtl" = "$REP" ] && rtlok="sí" || rtlok="no"
cambios=$(grep 'ciclos,' "$L" | sed 's/.*ciclos, \([0-9]*\) cambios de salida (\([0-9]*\) con X).*/\1/'); conx=$(grep 'ciclos,' "$L" | sed 's/.*(\([0-9]*\) con X).*/\1/')
tiempos=$(for n in $(seq 1 "$REP"); do head -1 "$E/tiempo_$n.txt" | sed 's/real \([0-9.]*\) s.*/\1/'; done | paste -sd/)
{
  echo "## $TAG, esquina $ESQ, escenario $ESC"
  echo
  echo "Comandos: ver asic/sim/post_pnr_sdf.sh (iverilog -g2012 -gspecify -ginterconnect -DNETLIST -DSDF -DMUESTREO=$MUESTREO -DESTIMULO=$ESTIMULO; $REP ejecuciones de vvp del mismo binario). Versiones: $VERS."
  echo
  echo "| esquina | ciclos | cambios de salida | con X | igual al RTL | $REP md5 iguales | tiempo real de vvp (s) | IOPATH anotados | INTERCONNECT anotados | timing checks |"
  echo "|---|---|---|---|---|---|---|---|---|---|"
  echo "| $ESQ | $CICLOS | ${cambios:-?} | ${conx:-?} | $rtlok ($iguales_rtl de $REP) | $md5ok | $tiempos | $IOPATH_OK de $IOPATH_SDF | $INTER_OK de $INTER_SDF | $TCHK |"
  echo
  echo "md5 de las trazas: $md5s (RTL: $(md5sum "$TR" | cut -c1-32), $(head -1 "$D/tiempo_rtl_$ESC.txt"))"
  echo
  echo "SDF: $IOPATH_SDF IOPATH, $INTER_SDF INTERCONNECT, $TC_SDF bloques TIMINGCHECK con $CHECKS_SDF checks (SETUP $SETUP_SDF, HOLD $HOLD_SDF, SETUPHOLD $SETUPHOLD_SDF, WIDTH $WIDTH_SDF, RECOVERY $REC_SDF, REMOVAL $REM_SDF, RECREM $RECREM_SDF, PERIOD $PER_SDF)."
  echo
  echo "Mensajes de vvp (repetición 1): $SDF_NOCELL celdas no encontradas, $SDF_MODPATH IOPATH sin ModPath, $SDF_INTER INTERCONNECT no creados, $SDF_TC 'TIMINGCHECK not supported', $SDF_OTROS otros; iverilog: $TC_NOSOP 'Timing checks are not supported', $IFNONE 'ifnone with an edge-sensitive path is not supported'. Detalle en $E/mensajes_sdf.txt."
  echo
  cat "$E/comparacion_1.txt" 2>/dev/null | sed 's/^/    /'
} > "$E/resumen.md"
echo "resumen en $E/resumen.md"
[ "$fallo" = 0 ] && [ "$rtlok" = "sí" ] && [ "$md5ok" = "sí" ] && { echo "post-pnr-sdf $ESQ: PASS (igual al RTL en $REP de $REP, md5 iguales)"; exit 0; }
echo "post-pnr-sdf $ESQ: FAIL (vvp fallo=$fallo, igual al RTL $iguales_rtl de $REP, md5 iguales=$md5ok)"; exit 1
