#!/usr/bin/env bash
# Potencia con actividad real de la corrida final (Proyecto 3, frente D3).
#
#   bash asic/potencia/correr.sh [todo|sim|resumen|pc|contar|sta|tabla|xinit|xinit_sta]
#   (desde la raiz del repo)
#
#   sim    compila asic/potencia/potencia_tb.v con el netlist post-PnR de la
#          corrida final (asic/rom/runs/final/final/nl/asic_top.nl.v, constantes
#          reales del juego, DebounceDivBits=15) y los modelos de celdas del PDK
#          (-DFUNCTIONAL, sin retardos), y simula una vez por ventana (de a dos
#          simulaciones, no mas) volcando un VCD de profundidad 2 en build/potencia/.
#          Ademas simula la ventana polling con profundidad 1 (solo los puertos
#          del macro) como calibracion de lo que OpenSTA alcanza a anotar.
#   resumen tamano, variables y extremos de tiempo de cada VCD (resultados/ventanas.txt).
#   pc     simula el RTL (mismo testbench con -DRTL, mismos estimulos) y escribe
#          el histograma del PC de cada ventana (que instrucciones se ejecutan);
#          compara la traza de salidas del RTL con la del netlist de cada ventana.
#   contar cuenta en cada VCD las transiciones de las senales de la sonda
#          (asic/potencia/contar_vcd.py) para contrastar con lo que anota OpenSTA.
#   sta    OpenSTA de la imagen de LibreLane (asic/potencia/potencia.tcl): por
#          esquina, report_power sin actividad (defecto), con actividad global 0
#          (cero) y con el VCD de cada ventana; mas calibraciones en nom_tt.
#          Reportes en asic/potencia/resultados/<modo o ventana>_<esquina>.rpt.
#   tabla  asic/potencia/tabla.py: tablas en asic/potencia/resultados/tablas.md
#          y ventanas_pc.md.
#   xinit  experimento de sensibilidad: los flip-flops sin reset (dffq_1: banco de
#          registros, RAM de datos) arrancan en x y los nodos de sus muxes de
#          lectura conmutan a x, transiciones que OpenSTA no cuenta. Se repiten
#          las 4 ventanas con el modelo asic/potencia/dffq_func_init.v (estado
#          inicial 0 y 1) y se corre OpenSTA en las 3 esquinas principales:
#          resultados/<ventana>_init<0|1>_<esquina>.rpt y conteo_x_<ventana>.txt.
#   xinit_sta  solo el OpenSTA de xinit, reusando los VCD ya simulados y
#          saltando los reportes que ya existen (para retomar tras una
#          interrupcion); termina con la fase tabla.
#
# Ventanas (ciclos contados como en tb/post_synth_tb.v: ciclo 0 = primer flanco
# con rst_n en 1; estimulos asic/sim/estimulos_final.txt: boton 0001 en el ciclo
# 1000, suelto en 150000). Las justifica el histograma del PC
# (resultados/ventanas_pc.md).
#
# Con el core de D23 la traza del netlist muestra los 4 LEDs en el ciclo 262151 y
# el 01 en el 262172 (build/post_synth/traza_netlist_final.txt, make
# post-synth-final); con el core de v1 eran 262156 y 262194, y con la candidata sin
# modelo de cable los mismos 262151 y 262172 (el RTL es el mismo). Las dos ventanas
# que dependen de ese instante se corrieron de 22 ciclos para que sigan centradas
# en el mismo evento del programa; las otras dos son lazos en regimen y no se
# mueven, para que la comparacion con v1 sea de la misma fase del juego:
#   polling  [500, 20500)      pantalla de inicio: lazo ss_wait_press (lw BTN / beq)
#   espera   [265000, 285000)  los 3 s de la ronda 1: lazo wt_wait_loop (lw CYCLES / sub / bltu)
#   display  [261172, 263172)  2000 ciclos centrados en el cambio del display al 01
#                              (v1: [261194, 263194))
#   rafaga   [262151, 262491)  solo la rafaga: round_begin, show_bcd (div), sw LEDS,
#                              sw DISP y la multiplicacion de wait_tenths (30 vueltas)
#                              (v1: [262150, 262490))
set -euo pipefail
cd "$(dirname "$0")/../.."
export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH

PDK_ROOT=${PDK_ROOT:-$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee}
SCL=gf180mcu_fd_sc_mcu7t5v0
CELDAS_V="$PDK_ROOT/gf180mcuD/libs.ref/$SCL/verilog/primitives.v $PDK_ROOT/gf180mcuD/libs.ref/$SCL/verilog/$SCL.v"
NL=asic/rom/runs/final/final/nl/asic_top.nl.v
TB=asic/potencia/potencia_tb.v
B=build/potencia
R=asic/potencia/resultados
IMG=ghcr.io/librelane/librelane:3.0.16
DOCKER="docker run --rm --user $(id -u):$(id -g) -v $HOME:$HOME -w $(pwd) -e HOME=$HOME -e PDK_ROOT=$PDK_ROOT"
ESQUINAS="nom_tt_025C_5v00 nom_ss_125C_4v50 nom_ff_n40C_5v50 min_tt_025C_5v00 min_ss_125C_4v50 min_ff_n40C_5v50 max_tt_025C_5v00 max_ss_125C_4v50 max_ff_n40C_5v50"
VENTANAS=("polling 500 20500" "espera 265000 285000" "display 261172 263172" "rafaga 262151 262491")

mkdir -p $B $R
fase=${1:-todo}

versiones() {
  {
    echo "fecha: $(date '+%Y-%m-%d %H:%M')"
    echo "iverilog: $(iverilog -V 2>/dev/null | head -1)"
    echo "sta (imagen $IMG): $($DOCKER $IMG sta -version 2>/dev/null | tail -1)"
    echo "netlist: $NL ($(md5sum $NL | cut -c1-32))"
    for rc in min nom max; do f=asic/rom/runs/final/final/spef/$rc/asic_top.$rc.spef; echo "spef $rc: $f ($(md5sum $f | cut -c1-32))"; done
    echo "sdc: asic/rom/runs/final/final/sdc/asic_top.sdc ($(md5sum asic/rom/runs/final/final/sdc/asic_top.sdc | cut -c1-32))"
    echo "liberty: $PDK_ROOT/gf180mcuD/libs.ref/$SCL/lib/${SCL}__{tt_025C_5v00,ss_125C_4v50,ff_n40C_5v50}.lib"
    echo "estimulos: asic/sim/estimulos_final.txt"
    echo "testbench: $TB ($(md5sum $TB | cut -c1-32))"
    echo "tcl: asic/potencia/potencia.tcl ($(md5sum asic/potencia/potencia.tcl | cut -c1-32))"
  } > $R/versiones.txt
  cat $R/versiones.txt
}

# una <ventana> <ini> <fin> [<binario> <sufijo>]: una simulacion del netlist con VCD.
una() {
  local v=$1 ini=$2 fin=$3 bin=${4:-$B/tb_netlist} suf=${5:-}
  ( time vvp $bin +ini=$ini +fin=$fin +vcd=$B/$v$suf.vcd +traza=$B/traza_$v$suf.txt ) > $B/sim_$v$suf.log 2>&1
  echo "== sim: $v$suf [$ini, $fin) lista: $(grep real $B/sim_$v$suf.log)"
}

sim() {
  echo "== sim: compilando el netlist final con $TB (profundidad 2 y 1)"
  iverilog -g2012 -DFUNCTIONAL -o $B/tb_netlist $TB $NL $CELDAS_V
  iverilog -g2012 -DFUNCTIONAL -DPROF=1 -o $B/tb_netlist_prof1 $TB $NL $CELDAS_V
  # De a dos simulaciones (regla comun: no mas de 2 pesadas a la vez).
  local n=${#VENTANAS[@]} k
  for ((k = 0; k < n; k += 2)); do
    una ${VENTANAS[k]} &
    if (( k + 1 < n )); then una ${VENTANAS[k+1]} & fi
    wait
  done
  # Calibracion: la ventana polling con $dumpvars de profundidad 1.
  una polling 500 20500 $B/tb_netlist_prof1 _prof1
}

resumen() {
  # Tamano, variables y extremos de tiempo de cada VCD, y tiempo de simulacion.
  : > $R/ventanas.txt
  for v in "${VENTANAS[@]}" "polling_prof1 500 20500"; do set -- $v
    local bytes vars codigos t0 t1 seg
    bytes=$(stat -c %s $B/$1.vcd)
    vars=$(grep -c '^\$var' $B/$1.vcd)
    codigos=$(grep '^\$var' $B/$1.vcd | awk '{print $4}' | sort -u | wc -l)
    t0=$(awk '/^#/{print substr($0, 2); exit}' $B/$1.vcd)
    t1=$(tail -c 200000 $B/$1.vcd | awk '/^#/{t=substr($0, 2)} END{print t}')
    seg=$(grep real $B/sim_$1.log | awk '{print $2}')
    echo "$1 $2 $3 $(( $3 - $2 )) $bytes $vars $codigos $t0 $t1 $seg" >> $R/ventanas.txt
    cp $B/sim_$1.log $R/sim_$1.log; cp $B/traza_$1.txt $R/traza_$1.txt
  done
  echo "== resumen (ventana ini fin ciclos bytes vars codigos t0_ps t1_ps tiempo) en $R/ventanas.txt"; cat $R/ventanas.txt
}

pc() {
  echo "== pc: histograma del PC con el RTL (DebounceDivBits=15, misma ROM)"
  iverilog -g2012 -DRTL -I rtl/gen -o $B/tb_rtl $TB rtl/*.v rtl/espino_core/*.v rtl/gen/pochoco_rom.v
  for v in "${VENTANAS[@]}"; do set -- $v
    vvp $B/tb_rtl +ini=$2 +fin=$3 +traza=$B/traza_rtl_$1.txt +pc=$R/pc_$1.txt | grep "ciclos," | sed "s/^/   $1: /"
    cp $B/traza_rtl_$1.txt $R/traza_rtl_$1.txt
    if [ -f $R/traza_$1.txt ]; then
      if cmp -s $R/traza_$1.txt $R/traza_rtl_$1.txt; then echo "   $1: traza del netlist identica a la del RTL"
      else echo "   $1: AVISO: la traza del netlist difiere de la del RTL"; fi
    fi
  done
}

contar() {
  echo "== contar: transiciones de las senales de la sonda en cada VCD (asic/potencia/contar_vcd.py)"
  for v in "${VENTANAS[@]}"; do set -- $v
    python3 asic/potencia/contar_vcd.py $B/$1.vcd > $R/conteo_$1.txt
    echo "   $1: $(sed -n 2p $R/conteo_$1.txt)"
  done
}

sta_una() {  # salida modo esquina [VAR=VAL ...]
  local salida=$1 modo=$2 esquina=$3; shift 3
  local extra=""; for kv in "$@"; do extra="$extra -e $kv"; done
  $DOCKER -e ESQUINA=$esquina -e MODO=$modo $extra $IMG sta -no_splash -exit asic/potencia/potencia.tcl > $R/$salida.rpt 2>&1 \
    || { echo "== sta: FALLO $salida (ver $R/$salida.rpt)"; return 1; }
  echo "   $salida: $(grep -E '^Total' $R/$salida.rpt | head -1 | awk '{print $5" W"}') $(grep -E '^Annotated' $R/$salida.rpt || true)"
}

sta() {
  echo "== sta: $(grep 'sta (' $R/versiones.txt 2>/dev/null || true)"
  for e in $ESQUINAS; do
    sta_una defecto_$e defecto $e
    sta_una cero_$e cero $e
    for v in "${VENTANAS[@]}"; do set -- $v
      sta_una ${1}_$e vcd $e VCD=$B/$1.vcd SCOPE=potencia_tb/dut
    done
  done
  # Calibraciones en la esquina tipica: que supone el modo defecto, el duty del
  # modo cero, y cuanto anota un VCD de profundidad 1.
  local e=nom_tt_025C_5v00
  sta_una entrada_$e entrada $e ACTIVIDAD=0.1 DUTY=0.5
  sta_una entrada05_$e entrada $e ACTIVIDAD=0.5 DUTY=0.5
  sta_una cero_duty0_$e cero $e DUTY=0
  sta_una polling_prof1_$e vcd $e VCD=$B/polling_prof1.vcd SCOPE=potencia_tb/dut
  # El mismo VCD de polling desplazado a t = 0: OpenSTA usa t_max - t_min del VCD.
  awk 'BEGIN{t0=-1} /^#/{t=substr($0,2)+0; if(t0<0){t0=t}; printf "#%.0f\n", t-t0; next} {print}' $B/polling.vcd > $B/polling_t0.vcd
  sta_una polling_t0_$e vcd $e VCD=$B/polling_t0.vcd SCOPE=potencia_tb/dut
}

tabla() {
  python3 asic/potencia/tabla.py
}

# Lineas de valor 0/1 y x de un VCD fuera del volcado inicial, y cuantas
# senales tienen x (para dimensionar lo que OpenSTA no cuenta).
contar_x() {
  local suf v
  for suf in "" _init0 _init1; do for v in "${VENTANAS[@]}"; do set -- $v
    [ -s $B/$1$suf.vcd ] || continue
    awk 'BEGIN{defs=1} /^\$enddefinitions/{defs=0; next} defs{next}
         /^#/{t=substr($0,2); if(t0=="")t0=t; next}
         { if(t==t0) next; ch=substr($0,1,1); if(ch=="0"||ch=="1") v01++;
           else if(ch=="x"){ vx++; c=substr($0,2); if(!(c in seen)){seen[c]=1; nc++} } }
         END{printf "lineas_01 %d\nlineas_x %d\nporcentaje_x %.2f\nsenales_con_x %d\n", v01, vx, 100*vx/v01, nc}' \
      $B/$1$suf.vcd > $R/conteo_x_$1$suf.txt
    echo "   $1$suf: $(tr '\n' ' ' < $R/conteo_x_$1$suf.txt)"
  done; done
}

xinit() {
  echo "== xinit: flip-flops sin reset inicializados a 0 y a 1 (asic/potencia/dffq_func_init.v)"
  echo "== xinit: lineas x en los VCD originales"
  contar_x
  for I in 0 1; do
    iverilog -g2012 -DFUNCTIONAL -DINIT_FF=$I -DGF180MCU_FD_SC_MCU7T5V0__DFFQ_FUNC_V \
      -o $B/tb_netlist_init$I $TB asic/potencia/dffq_func_init.v $NL $CELDAS_V
  done
  # 8 simulaciones, de a dos (regla comun: no mas de 2 pesadas a la vez).
  local trabajos=() I v
  for I in 0 1; do for v in "${VENTANAS[@]}"; do trabajos+=("$v $B/tb_netlist_init$I _init$I"); done; done
  local n=${#trabajos[@]} k
  for ((k = 0; k < n; k += 2)); do
    una ${trabajos[k]} &
    if (( k + 1 < n )); then una ${trabajos[k+1]} & fi
    wait
  done
  for I in 0 1; do for v in "${VENTANAS[@]}"; do set -- $v
    cp $B/sim_$1_init$I.log $R/sim_$1_init$I.log; cp $B/traza_$1_init$I.txt $R/traza_$1_init$I.txt
    if cmp -s $R/traza_$1_init$I.txt $R/traza_rtl_$1.txt; then echo "   $1_init$I: traza identica a la del RTL"
    else echo "   $1_init$I: AVISO: la traza difiere de la del RTL"; fi
    echo "$1_init$I $2 $3 $(( $3 - $2 )) $(stat -c %s $B/$1_init$I.vcd) $(grep -c '^\$var' $B/$1_init$I.vcd) $(grep '^\$var' $B/$1_init$I.vcd | awk '{print $4}' | sort -u | wc -l) $(awk '/^#/{print substr($0, 2); exit}' $B/$1_init$I.vcd) $(tail -c 200000 $B/$1_init$I.vcd | awk '/^#/{t=substr($0, 2)} END{print t}') $(grep real $B/sim_$1_init$I.log | awk '{print $2}')" >> $R/ventanas.txt
  done; done
  xinit_sta
}

# OpenSTA de las 8 simulaciones de xinit en las 3 esquinas principales. Es
# idempotente: si el reporte ya existe y trae la linea "Annotated", no lo repite
# (la fase xinit se interrumpio por el limite de uso de la sesion con 5 de los 24
# reportes hechos, y volver a simular las 8 ventanas cuesta unos 22 minutos).
xinit_sta() {
  local e I v hechos=0 nuevos=0
  for e in nom_tt_025C_5v00 max_ss_125C_4v50 min_ff_n40C_5v50; do
    for I in 0 1; do for v in "${VENTANAS[@]}"; do set -- $v
      local salida=${1}_init${I}_$e
      if [ -s $R/$salida.rpt ] && grep -q '^Annotated' $R/$salida.rpt; then
        hechos=$((hechos + 1))
        echo "   $salida: ya estaba ($(grep -E '^Total' $R/$salida.rpt | head -1 | awk '{print $5" W"}'))"
      else
        sta_una $salida vcd $e VCD=$B/$1_init$I.vcd SCOPE=potencia_tb/dut
        nuevos=$((nuevos + 1))
      fi
    done; done
  done
  echo "== xinit_sta: $nuevos reportes nuevos, $hechos ya estaban"
}

case $fase in
  todo)    versiones; sim; resumen; pc; contar; sta; tabla ;;
  sim)     sim; resumen ;;
  resumen) resumen ;;
  pc)     pc ;;
  contar) contar ;;
  sta)    versiones; sta ;;
  tabla)  tabla ;;
  xinit)  xinit; tabla ;;
  xinit_sta) xinit_sta; tabla ;;
  contar_x) contar_x ;;
  *) echo "fase desconocida: $fase (todo|sim|resumen|pc|contar|contar_x|sta|tabla|xinit|xinit_sta)"; exit 1 ;;
esac
