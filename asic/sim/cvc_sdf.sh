#!/usr/bin/env bash
# Simulación post-PnR con SDF y timing checks EVALUADOS, con Open Verilog CVC
# (OSS CVC 7.00b, compilado en el host desde
# https://github.com/CambridgeHackers/open-src-cvc). Complementa a
# asic/sim/post_pnr_sdf.sh (Icarus), que no evalúa $setup/$hold/$width.
#   bash asic/sim/cvc_sdf.sh <RUN> <ESQUINA> [ESCENARIO] [MUESTREO] [ESTIMULO] [ETIQUETA] [REPETIR]
#   (mismos parámetros que post_pnr_sdf.sh; ESCENARIO sim|final; 50 y 50 por defecto;
#   ETIQUETA es un sufijo del directorio de salida, para controles como ESTIMULO=1;
#   REPETIR son las ejecuciones de cvc64 sobre la misma entrada, 3 por defecto, para
#   demostrar con md5 que el resultado es reproducible, igual que en post_pnr_sdf.sh)
# Requisitos: build/cvc/open-src-cvc/build64/cvc64, construido con
#   git clone https://github.com/CambridgeHackers/open-src-cvc build/cvc/open-src-cvc
#   (cd build/cvc/open-src-cvc/src && make cvc64)      (gcc y make del host; ~1 min)
# Qué hace (todo en build/post_pnr/cvc/<tag>/<esquina>[_final]/):
#   1. Renombra las instancias jerárquicas del netlist y del SDF
#      (asic/sim/renombrar_instancias.py), igual que el flujo con Icarus.
#   2. Modelo de celdas para CVC (asic/sim/modelo_cvc.py): el del PDK sin el
#      `ifnone` de los 120 arcos con flanco, que CVC rechaza con el error 1012.
#   3. Traza de referencia del RTL con CVC (mismo testbench, estímulos,
#      MUESTREO y ESTIMULO), para comparar simulador contra simulador. Si CVC
#      no compila el RTL (7.00b cae con Segmentation fault), la referencia es la
#      traza del RTL con el Icarus de la imagen (build/post_pnr/<tag>/traza_rtl_<esc>.txt,
#      la deja make post-pnr-sdf).
#   4. Elabora el netlist con los modelos (bloques specify, timing checks) y el
#      $sdf_annotate del testbench y simula en modo interpretado (cvc64 +interp
#      +typdelays) REPETIR veces, borrando la traza antes de cada ejecución (un
#      aborto no puede dar un PASS falso) y midiendo el tiempo y el md5 de cada una.
#   5. Cuenta las violaciones de timing que reporta el simulador ("[566] timing
#      violation"), por tipo de check, y los mensajes de la anotación del SDF
#      (sdf_cvc_1.log); compara cada traza con la del RTL (asic/sim/comparar.py) y
#      con la del RTL de Icarus si existe (build/post_pnr/<tag>/traza_rtl_<esc>.txt).
# Termina con código distinto de 0 si CVC no compila, si cvc64 falla, si una traza
# difiere del RTL o si los md5 de las repeticiones no coinciden. Las violaciones de
# timing NO son criterio de fallo del script: se cuentan y se listan (resumen.md)
# para analizarlas.
set -u
cd "$(dirname "$0")/../.."
R=$(pwd)
RUN="${1:?RUN}"; ESQ="${2:?ESQUINA}"; ESC="${3:-sim}"; MUESTREO="${4:-50}"; ESTIMULO="${5:-50}"; ETIQUETA="${6:-}"; REP="${7:-3}"
PDK_ROOT="${PDK_ROOT:-$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee}"
SCL=gf180mcu_fd_sc_mcu7t5v0
MODELO="$PDK_ROOT/gf180mcuD/libs.ref/$SCL/verilog/$SCL.v"
PRIM="$PDK_ROOT/gf180mcuD/libs.ref/$SCL/verilog/primitives.v"
CVC="${CVC:-$R/build/cvc/open-src-cvc/build64/cvc64}"
[ -x "$CVC" ] || { echo "no existe $CVC (ver el encabezado de este script)" >&2; exit 2; }
case "$ESC" in
  sim)   EST=asic/sim/estimulos.txt;       CICLOS=4500;   DIV=2;  ROMDIR=asic/sim/gen; ROM=asic/sim/gen/pochoco_rom.v; SUF="" ;;
  final) EST=asic/sim/estimulos_final.txt; CICLOS=320000; DIV=15; ROMDIR=rtl/gen;      ROM=rtl/gen/pochoco_rom.v;      SUF="_final" ;;
  *) echo "escenario $ESC desconocido (sim|final)" >&2; exit 2 ;;
esac
TAG=$(basename "$RUN")
NL="$RUN/final/nl/asic_top.nl.v"; SDF="$RUN/final/sdf/$ESQ/asic_top__$ESQ.sdf"
[ -f "$NL" ] || { echo "no existe $NL" >&2; exit 2; }
[ -f "$SDF" ] || { echo "no existe $SDF" >&2; exit 2; }
C="$R/build/post_pnr/cvc/$TAG/$ESQ$SUF$ETIQUETA"; mkdir -p "$C/rtl"
MOD_CVC="$R/build/post_pnr/cvc/${SCL}_cvc.v"
echo "cvc-sdf: corrida $RUN, esquina $ESQ, escenario $ESC ($EST, $CICLOS ciclos, DebounceDivBits=$DIV), $REP repeticiones, estimulos a +$ESTIMULO ns, muestreo a +$MUESTREO ns"
echo "version: $("$CVC" -h 2>&1 | head -1)"

# 1. instancias renombradas
python3 asic/sim/renombrar_instancias.py --netlist "$NL" --salida "$C" "$SDF" | tee "$C/renombrar.log" || exit 1
NL2="$C/asic_top.nl.v"; SDF2="$C/asic_top__$ESQ.sdf"
# Los INTERCONNECT cuyo destino es un puerto de salida del macro (seg1[k], seg2[k],
# led[k], spi_miso: destino sin punto) son errores 1509 para CVC ("destination out
# port ... annotated as (DEVICE delay does not have flattened gate driver") y con
# errores CVC no deja el ejecutable. Son cables de 0,000 a 0,001 ns del buffer de
# salida al terminal, así que se quitan de la copia del SDF para CVC y se cuentan.
mv "$SDF2" "$SDF2.orig"
grep -v -E '^\s*\(INTERCONNECT \S+ [A-Za-z_][A-Za-z0-9_]*(\[[0-9]+\])? ' "$SDF2.orig" > "$SDF2"
INTER_PUERTO=$(( $(grep -c "(INTERCONNECT" "$SDF2.orig") - $(grep -c "(INTERCONNECT" "$SDF2") ))
echo "sdf para CVC: $INTER_PUERTO INTERCONNECT hacia puertos de salida quitados (error 1509 de CVC; retardos de 0,000 a 0,001 ns)"
# 2. modelo para CVC
python3 asic/sim/modelo_cvc.py "$MODELO" "$MOD_CVC" || exit 1

# 3. referencia del RTL con CVC
cat > "$C/rtl/defs.v" <<FIN
\`define ESTIMULOS "$R/$EST"
\`define TRAZA "$C/rtl/traza.txt"
\`define CICLOS $CICLOS
\`define DIV_BITS $DIV
\`define MUESTREO $MUESTREO
\`define ESTIMULO $ESTIMULO
FIN
TRI="$R/build/post_pnr/$TAG/traza_rtl_$ESC.txt"
TR="$C/rtl/traza.txt"; rm -f "$TR" "$C/rtl/cvcsim"
if ( cd "$C/rtl" && "$CVC" -l cvc_compila.log +incdir+"$R/$ROMDIR" defs.v "$R/tb/post_synth_tb.v" "$R"/rtl/*.v "$R"/rtl/espino_core/*.v "$R/$ROM" > cvc_salida.txt 2>&1 \
     && TIMEFORMAT='real %R s, usuario %U s, sistema %S s' && { time ./cvcsim > cvcsim.log 2>&1 ; } 2> tiempo.txt ) && [ -s "$TR" ]; then
  echo "RTL (CVC): $(grep 'ciclos,' "$C/rtl/cvcsim.log" | sed 's/post_synth_tb: //; s/, traza en.*//'); $(head -1 "$C/rtl/tiempo.txt"); md5 $(md5sum "$TR" | cut -c1-32)"
  if [ -s "$TRI" ]; then
    if cmp -s "$TR" "$TRI"; then echo "RTL (CVC) == RTL (Icarus de la imagen): mismas trazas ($TRI)"; rtl_cmp="sí"; else echo "RTL (CVC) != RTL (Icarus): $TRI"; rtl_cmp="no"; fi
  else rtl_cmp="sin traza de Icarus"; fi
else
  # CVC 7.00b no compila el RTL (cae con "Segmentation fault" en la elaboración,
  # sin mensaje; el RTL usa construcciones que CVC no soporta). La referencia
  # es entonces la traza del RTL simulada con el Icarus de la imagen por
  # asic/sim/post_pnr_sdf.sh (make post-pnr-sdf), que es la misma en todas las esquinas.
  echo "RTL en CVC fallo ($(tail -1 "$C/rtl/cvc_salida.txt" 2>/dev/null | cut -c1-80)); referencia: traza del RTL con Icarus $TRI"
  [ -s "$TRI" ] || { echo "no existe $TRI: correr antes make post-pnr-sdf ESQUINA=$ESQ" >&2; exit 1; }
  TR="$TRI"; rtl_cmp="RTL no compila en CVC; referencia de Icarus"
fi

# 4. netlist con SDF
cat > "$C/defs.v" <<FIN
\`define NETLIST
\`define SDF "$SDF2"
\`define ESTIMULOS "$R/$EST"
\`define TRAZA "$C/traza.txt"
\`define CICLOS $CICLOS
\`define MUESTREO $MUESTREO
\`define ESTIMULO $ESTIMULO
FIN
cd "$C" && rm -f traza.txt cvcsim
# Los modelos van como fuentes (no como biblioteca -v): con -v CVC deja una UDP sin
# resolver; las celdas no instanciadas quedan como módulos de nivel superior y
# CVC avisa [679] que ignora sus specify, lo que no afecta a las instanciadas.
# Modo interpretado (+interp): en modo compilado CVC 7.00b genera el ejecutable
# cvcsim pero el enlace falla con el ld actual ("undefined reference to
# WIRE_EV_NNNN") y no deja ejecutable; con +interp simula directamente (misma
# semántica según su documentación, más lento). El log de cvc64 (cvcsim_<n>.log)
# contiene la elaboración, la anotación y la simulación de cada repetición.
TIMEFORMAT='real %R s, usuario %U s, sistema %S s'
fallo=0; md5s=""
for n in $(seq 1 "$REP"); do
  rm -f traza.txt "sdf_cvc_$n.log"
  { time "$CVC" +interp -l "cvcsim_$n.log" +typdelays +sdf_log_file "sdf_cvc_$n.log" defs.v "$R/tb/post_synth_tb.v" "$NL2" "$PRIM" "$MOD_CVC" > "cvc_salida_$n.txt" 2>&1 ; } 2> "tiempo_$n.txt"; echo "codigo $?" >> "tiempo_$n.txt"
  cod=$(grep codigo "tiempo_$n.txt" | awk '{print $2}')
  if [ "$cod" != 0 ] || [ ! -s traza.txt ]; then
    echo "repeticion $n: cvc64 +interp termino con codigo $cod o sin traza (ver $C/cvcsim_$n.log)"
    grep "ERROR" "cvcsim_$n.log" | head -5; grep -v "timing violation\|^ \\$" "cvcsim_$n.log" | tail -5; fallo=1
    cp -f traza.txt "traza_$n.txt" 2>/dev/null; continue
  fi
  cp -f traza.txt "traza_$n.txt"
  m=$(md5sum "traza_$n.txt" | cut -c1-32); md5s="$md5s $m"
  ERRC=$(grep -c "ERROR\*\*" "cvcsim_$n.log"); WARNC=$(grep -c "WARN\*\*" "cvcsim_$n.log")
  echo "repeticion $n: $(head -1 "tiempo_$n.txt"); $(grep 'ciclos,' "cvcsim_$n.log" | sed 's/post_synth_tb: //; s/, traza en.*//'); md5 $m; $ERRC errores y $WARNC avisos de elaboracion en $C/cvcsim_$n.log"
done
[ "$fallo" = 0 ] || exit 1
L=cvcsim_1.log
ERRC=$(grep -c "ERROR\*\*" "$L"); WARNC=$(grep -c "WARN\*\*" "$L")
nmd5=$(echo $md5s | tr ' ' '\n' | sort -u | grep -c .)
[ "$nmd5" = 1 ] && [ "$(echo $md5s | wc -w)" = "$REP" ] && md5ok="sí" || md5ok="no"

# 5. violaciones, mensajes del SDF y comparación (análisis de la repetición 1)
VIOL=$(grep -c "timing violation" "$L")
grep -A1 "timing violation" "$L" | grep -v "timing violation\|^--" | sed 's/^ *//; s/(.*//' | sort | uniq -c | sort -rn > violaciones_por_tipo.txt
grep -B0 -A1 "timing violation" "$L" | grep -o "in post_synth_tb\.dut\.[^ ]*" | sort | uniq -c | sort -rn > violaciones_por_instancia.txt
NINST=$(wc -l < violaciones_por_instancia.txt)
# Las violaciones tienen que ser las mismas en todas las repeticiones (mismo
# simulador, misma entrada): si no, el resultado no sería reproducible.
violok="sí"; for n in $(seq 1 "$REP"); do [ "$(grep -c 'timing violation' "cvcsim_$n.log")" = "$VIOL" ] || violok="no"; done
IOPATH_SDF=$(grep -c "(IOPATH" "$SDF2"); INTER_SDF=$(grep -c "(INTERCONNECT" "$SDF2.orig"); TC_SDF=$(grep -c "(TIMINGCHECK" "$SDF2")
SDF_ERR=$(grep -c "ERROR" sdf_cvc_1.log 2>/dev/null || true); SDF_WARN=$(grep -c "WARN" sdf_cvc_1.log 2>/dev/null || true); SDF_INF=$(grep -c "INFORM" sdf_cvc_1.log 2>/dev/null || true)
grep -o "\(ERROR\|WARN\|INFORM\)\*\* \[[0-9]*\] .*" sdf_cvc_1.log 2>/dev/null | sed 's/_[0-9]\+_/_N_/g; s/[0-9]\+\.[0-9]*/N/g; s/[0-9]\+ ps/N ps/g' | sort | uniq -c | sort -rn | head -20 > mensajes_sdf.txt
echo "SDF: $IOPATH_SDF IOPATH, $INTER_SDF INTERCONNECT, $TC_SDF bloques TIMINGCHECK; anotacion (sdf_cvc_1.log): $SDF_ERR errores, $SDF_WARN avisos, $SDF_INF informes (detalle en $C/mensajes_sdf.txt)"
echo "timing checks EVALUADOS por CVC: $VIOL violaciones reportadas en $NINST instancias, iguales en las $REP repeticiones: $violok (por tipo en $C/violaciones_por_tipo.txt)"
cat violaciones_por_tipo.txt | sed 's/^/    /'
iguales_rtl=0
for n in $(seq 1 "$REP"); do
  if python3 "$R/asic/sim/comparar.py" "$TR" "traza_$n.txt" --md "comparacion_$n.md" > "comparacion_$n.txt"; then iguales_rtl=$((iguales_rtl + 1)); fi
done
[ "$iguales_rtl" = "$REP" ] && igual="sí" || igual="no"
{
  echo "## CVC: $TAG, esquina $ESQ, escenario $ESC"
  echo
  echo "Comandos: ver asic/sim/cvc_sdf.sh (cvc64 +interp +typdelays, modelo sin ifnone en arcos con flanco, SDF sin los INTERCONNECT hacia puertos de salida, MUESTREO=$MUESTREO ESTIMULO=$ESTIMULO). Versión: $("$CVC" -h 2>&1 | head -1)."
  echo
  echo "| esquina | ciclos | cambios de salida | con X | igual al RTL | $REP md5 iguales | referencia del RTL | tiempo real de cvc64 +interp (s), $REP ejecuciones | violaciones de timing reportadas | instancias con violación |"
  echo "|---|---|---|---|---|---|---|---|---|---|"
  echo "| $ESQ | $CICLOS | $(grep 'ciclos,' "$L" | sed 's/.*ciclos, \([0-9]*\) cambios.*/\1/') | $(grep 'ciclos,' "$L" | sed 's/.*(\([0-9]*\) con X).*/\1/') | $igual ($iguales_rtl de $REP) | $md5ok | $rtl_cmp | $(for n in $(seq 1 "$REP"); do head -1 "tiempo_$n.txt" | sed 's/real \([0-9.]*\) s.*/\1/'; done | paste -sd/) | $VIOL | $NINST |"
  echo
  echo "md5 de las trazas del netlist: $md5s (referencia del RTL: $(md5sum "$TR" | cut -c1-32), $TR). Violaciones iguales en las $REP repeticiones: $violok."
  echo
  echo "Anotación (sdf_cvc_1.log): $SDF_ERR errores, $SDF_WARN avisos, $SDF_INF informes sobre $IOPATH_SDF IOPATH, $INTER_SDF INTERCONNECT (menos $INTER_PUERTO hacia puertos de salida, quitados del SDF para CVC) y $TC_SDF bloques TIMINGCHECK. Compilación (cvcsim_1.log): $ERRC errores, $WARNC avisos."
  echo
  echo "Violaciones por tipo de check:"; echo; sed 's/^/    /' violaciones_por_tipo.txt; echo
  sed 's/^/    /' comparacion_1.txt
} > resumen.md
echo "resumen en $C/resumen.md"
[ "$igual" = "sí" ] && [ "$md5ok" = "sí" ] && { echo "cvc-sdf $ESQ: traza igual al RTL en $REP de $REP, md5 iguales; $VIOL violaciones de timing reportadas"; exit 0; }
echo "cvc-sdf $ESQ: FAIL (igual al RTL $iguales_rtl de $REP, md5 iguales=$md5ok)"; exit 1
