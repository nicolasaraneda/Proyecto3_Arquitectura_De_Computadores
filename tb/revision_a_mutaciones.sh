#!/bin/bash
# revision_a_mutaciones.sh -- arnes de la revision independiente del frente A
# (rama exp/pipeline). Compara la traza funcional del RTL de main contra la de
# otro arbol de RTL (la rama, o una copia con una mutacion aplicada), para un
# programa ya ensamblado en build/<PROG>/pochoco_rom.v.
#
# Uso, desde el worktree de la rama:
#   export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH
#   make equiv PROG=hazard_review REF=main MODO=funcional   # ensambla el programa
#   bash tb/revision_a_mutaciones.sh hazard_review . base
#   bash tb/revision_a_mutaciones.sh hazard_review . mfwd -DMUTA_FWD
#   bash tb/revision_a_mutaciones.sh hazard_review /tmp/mut m3   # copia mutada
#
#   $1 PROG      programa de sw/<PROG>.s ya ensamblado en build/<PROG>/
#   $2 RTLDIR    arbol con rtl/ y rtl/espino_core/ para el lado "act"
#   $3 ETIQUETA  prefijo de los archivos de salida en build/revision/
#   $4..         defines extra para iverilog (p. ej. -DMUTA_FWD)
#
# El lado "ref" es siempre el RTL de main (MAIN_DIR, por defecto el repo
# principal dos niveles arriba). Mutaciones propias usadas en la revision:
#   M3: en espino_register_file.v, quitar `waddr_i != 0` del bypass y poner el
#       bypass ANTES de la lectura de x0 (rompe la exclusion de x0).
#   M4: en espino_id_stage.v, bloque g_early, `assign rf_rd_en_o = 1'b1;`
#       (el banco relee durante el stall de la carga y la LSU alinea el dato
#       con la direccion equivocada).
set -e
PROG=$1; ACT=$2; ET=$3; shift 3
MAIN_DIR=${MAIN_DIR:-../..}
O=build/revision; mkdir -p $O
for m in 1 2; do
  for lado in ref act; do
    [ $lado = ref ] && D=$MAIN_DIR || D=$ACT
    iverilog -g2012 -DMEM_STRATEGY=$m -DTRAZA=\"$O/${ET}_${lado}_m$m.txt\" "$@" \
      -I build/$PROG -o $O/${ET}_${lado}_m$m tb/core_trace_tb.v \
      $D/rtl/*.v $D/rtl/espino_core/*.v build/$PROG/pochoco_rom.v
    vvp $O/${ET}_${lado}_m$m | grep "CPI\|monitor de X" | sed "s/^/  $lado m$m: /"
  done
  echo "--- $ET / $PROG / estrategia $m / main contra $ACT $* ---"
  python3 tb/comparar_trazas.py --modo funcional $O/${ET}_ref_m$m.txt $O/${ET}_act_m$m.txt | sed 's/^/    /' || true
  echo "    salidas (act): $(grep ' io ' $O/${ET}_act_m$m.txt | tr '\n' ' ')"
done
