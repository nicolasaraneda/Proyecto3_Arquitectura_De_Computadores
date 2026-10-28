#!/usr/bin/env bash
# Frente D2: equivalencia formal del RTL de asic_top (MemStrategy=1, DataWords=4) contra los
# netlists de la corrida final (asic/rom/runs/final). Todo corre en el anfitrión con las
# herramientas de oss-cad-suite (~/herramientas/oss-cad-suite/bin: yosys, eqy, sby, yices,
# yosys-abc); ningún paso usa LibreLane. Método y resultados en docs/equivalencia.md. Se
# ejecuta desde la raíz del repo:
#
#   bash asic/eqy/correr.sh preparar
#       gold: RTL aplanado, en dos variantes (v1: proc, flatten y memory_map, sin optimizar;
#             v2: síntesis genérica de Yosys sin abc, `synth -flatten -noabc`, que aplica los
#             mismos pases de alto nivel que la síntesis de LibreLane: fsm, opt_dff, opt_merge,
#             wreduce, alumacc, techmap); gate: netlist de síntesis (sint) y post-PnR sin celdas
#             físicas (pnr), con las celdas leídas del liberty típico (read_liberty sin -lib).
#             Después, por variante <gate>_<gold>[ff], un solo nombre público por red común a
#             los dos lados (asic/eqy/canonizar.py; con el sufijo ff solo quedan con nombre
#             común los puertos y las salidas de flip-flop) -> build/eqy/<variante>/{gold.il,gate.il}.
#   bash asic/eqy/correr.sh canonizar <variante>  solo la canonización de una variante
#   bash asic/eqy/correr.sh eqy <variante>        eqy (asic/eqy/plantilla.eqy) -> build/eqy/<variante>/eqy
#   bash asic/eqy/correr.sh equiv <variante>      equiv_make / equiv_simple / equiv_induct de Yosys
#   bash asic/eqy/correr.sh bmc <variante>        miter completo desde reset, BMC acotado (sby)
#   bash asic/eqy/correr.sh mutar                 control negativo: una celda cambiada en la ALU (mut_v1ff)
#   bash asic/eqy/correr.sh versiones             versiones y rutas de las herramientas del anfitrión
#   bash asic/eqy/correr.sh todo                  preparar, eqy de las 8 variantes, equiv y bmc de sint_v1ff
#
# Variables: J (hilos de eqy, 6), TMAX (tope del flujo clásico en s, 2400), SEQ_SIMPLE (pasos
# de equiv_simple, 2), SEQ (pasos de equiv_induct, 4), BMC_PROF (profundidad del BMC, 24),
# VARIANTES. Los resúmenes quedan en asic/eqy/resultados/<variante>/; los logs completos en
# build/eqy/ (no se versionan).
set -eu
cd "$(dirname "$0")/../.."
RAIZ=$(pwd)
OSS=$HOME/herramientas/oss-cad-suite/bin
export PATH=$OSS:$PATH
PDK_ROOT=${PDK_ROOT:-$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee}
LIB=$PDK_ROOT/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib
NL_SINT=asic/rom/runs/final/06-yosys-synthesis/asic_top.nl.v
NL_PNR=asic/rom/runs/final/final/nl/asic_top.nl.v
RTL="rtl/asic_top.v rtl/debounce.v rtl/pochoco_cycle_counter.v rtl/pochoco_mem_ff.v rtl/pochoco_mem_rom.v rtl/pochoco_periph.v rtl/pochoco_soc.v rtl/pochoco_spi_slave.v rtl/espino_core/espino_alu.v rtl/espino_core/espino_controller.v rtl/espino_core/espino_core.v rtl/espino_core/espino_decoder.v rtl/espino_core/espino_id_stage.v rtl/espino_core/espino_if_stage.v rtl/espino_core/espino_load_store_unit.v rtl/espino_core/espino_register_file.v rtl/gen/pochoco_rom.v"
B=build/eqy
R=asic/eqy/resultados
J=${J:-6}
TMAX=${TMAX:-2400}
SEQ=${SEQ:-4}
SEQ_SIMPLE=${SEQ_SIMPLE:-2}
BMC_PROF=${BMC_PROF:-24}
VARIANTES=${VARIANTES:-"sint_v1 sint_v2 pnr_v1 pnr_v2 sint_v1ff sint_v2ff pnr_v1ff pnr_v2ff"}
TIEMPO="/usr/bin/time -f tiempo_real_%e_s;usuario_%U_s;sistema_%S_s;memoria_maxima_%M_KB"
# Leer las celdas del liberty típico: un módulo con la función lógica de cada celda y un
# $_DFF_* por cada grupo ff(). -ignore_miss_func: las icgtn/icgtp (clock gating) no tienen
# función y no se usan. -ignore_miss_dir e -ignore_miss_data_latch se dejan por seguridad; con
# Yosys 0.68+195 el liberty también se lee sin ellas (build/eqy/prueba_sin_ignore_latch.log).
LEER_LIB="read_liberty -ignore_miss_func -ignore_miss_dir -ignore_miss_data_latch $LIB"
# Mismo cierre para gold y gate: todo aplanado, un wire por bit (los nombres del netlist ya
# vienen así: \u_soc...a_addr_i[0]), sin wires ni celdas sin uso.
CIERRE="opt_clean; splitnets -ports; opt_clean"

versiones() {
  echo "yosys: $(yosys -V)"
  echo "eqy: $(grep -m1 "^release_version = 'EQY" $OSS/../libexec/eqy | sed "s/.*'\(.*\)'/\1/") ($OSS/eqy)"
  echo "sby: $(grep -m1 "^release_version = 'SBY" $OSS/../libexec/sby 2>/dev/null | sed "s/.*'\(.*\)'/\1/")"
  echo "yices: $(yices --version | head -1)"
  echo "yosys-abc: $(yosys-abc -q "version" 2>/dev/null | head -1)"
  # Solvers disponibles en el anfitrión (sby los usa con sus motores smtbmc; eqy, con smt).
  for s in yices z3 boolector bitwuzla yosys-smtbmc; do
    echo "ruta de $s: $(command -v $s || echo NO_ESTA)"
  done
  echo "ruta de make: $(command -v make || echo NO_ESTA)"
  echo "liberty: $LIB"
  echo "netlist de síntesis: $NL_SINT"
  echo "netlist post-PnR: $NL_PNR"
}

preparar() {
  mkdir -p $B
  versiones | tee $B/versiones.txt
  echo "== gold v1 (RTL aplanado, sin optimizar)"
  yosys -q -l $B/gold_v1.log -p "read_verilog -sv -I rtl/gen $RTL; hierarchy -top asic_top -chparam MemStrategy 1 -chparam DataWords 4; proc; flatten; memory_map; $CIERRE; stat; write_json $B/gold_v1.json; write_rtlil $B/gold_v1.il"
  echo "== gold v2 (síntesis genérica de Yosys sin abc: synth -flatten -noabc)"
  yosys -q -l $B/gold_v2.log -p "read_verilog -sv -I rtl/gen $RTL; hierarchy -top asic_top -chparam MemStrategy 1 -chparam DataWords 4; synth -top asic_top -flatten -noabc; $CIERRE; stat; write_json $B/gold_v2.json; write_rtlil $B/gold_v2.il"
  echo "== gate sint (netlist de síntesis)"
  yosys -q -l $B/gate_sint.log -p "$LEER_LIB; read_verilog $NL_SINT; hierarchy -top asic_top; flatten; $CIERRE; stat; write_json $B/gate_sint.json; write_rtlil $B/gate_sint.il"
  echo "== gate pnr (netlist post-PnR sin celdas físicas)"
  # Celdas sin conexión lógica: fill_*, fillcap_* (decap), filltie (tap) y endcap, todas en
  # una línea "<celda> <instancia> ();". El separador de jerarquía de OpenROAD es "/" y el
  # de Yosys "."; se reemplaza para que \u_soc.u_core.u_rf/regs[7][26] case con el RTL.
  grep -Ev '^ *gf180mcu_fd_sc_mcu7t5v0__(fill_[0-9]+|fillcap_[0-9]+|filltie|endcap) [^ ]+ \(\);' $NL_PNR | sed 's#/#.#g' > $B/gate_pnr_sin_fisicas.nl.v
  echo "   líneas quitadas: $(( $(grep -c '' $NL_PNR) - $(grep -c '' $B/gate_pnr_sin_fisicas.nl.v) )); instancias de celdas físicas en el original: $(grep -Ec '^ *gf180mcu_fd_sc_mcu7t5v0__(fill_[0-9]+|fillcap_[0-9]+|filltie|endcap) ' $NL_PNR); barras restantes: $(grep -c '/' $B/gate_pnr_sin_fisicas.nl.v)" | tee $B/gate_pnr_filtro.txt
  yosys -q -l $B/gate_pnr.log -p "$LEER_LIB; read_verilog $B/gate_pnr_sin_fisicas.nl.v; hierarchy -top asic_top; flatten; $CIERRE; stat; write_json $B/gate_pnr.json; write_rtlil $B/gate_pnr.il"
  for v in $VARIANTES; do canonizar_ $v; done
  cp $B/versiones.txt $R/
  for f in gold_v1 gold_v2 gate_sint gate_pnr; do
    sed -n '/Number of cells\|cells$/,/^$/p' $B/$f.log | head -40 > $R/stat_$f.txt
  done
}

# Variante <gate>_<gold>[ff]: gate sint o pnr, gold v1 o v2; el sufijo ff canoniza con
# --solo-ff (solo puertos y salidas de flip-flop quedan con nombre común, así eqy corta
# únicamente en registros).
canonizar_() {
  v=$1; gate=${v%_*}; gold=${v#*_}; opcion=""
  case $gold in *ff) gold=${gold%ff}; opcion=--solo-ff ;; esac
  echo "== canonizar $v (gold_$gold, gate_$gate $opcion)"
  mkdir -p $B/$v $R/$v
  python3 asic/eqy/canonizar.py $B/gold_$gold.json $B/gate_$gate.json $B/$v/canon $opcion | tee $B/$v/canon_resumen.txt
  yosys -q -l $B/$v/gold_canon.log -p "read_rtlil $B/gold_$gold.il; script $B/$v/canon/gold_renombrar.ys; write_rtlil $B/$v/gold.il"
  yosys -q -l $B/$v/gate_canon.log -p "read_rtlil $B/gate_$gate.il; script $B/$v/canon/gate_renombrar.ys; write_rtlil $B/$v/gate.il"
  cp $B/$v/canon_resumen.txt $B/$v/canon/ff_gold_sin_par.txt $B/$v/canon/ff_gate_sin_par.txt $R/$v/
}

eqy_() {
  v=$1; mkdir -p $R/$v
  sed "s#@GOLD@#$RAIZ/$B/$v/gold.il#; s#@GATE@#$RAIZ/$B/$v/gate.il#" asic/eqy/plantilla.eqy > $B/$v/asic_top.eqy
  echo "== eqy $v (eqy -j $J -f $B/$v/asic_top.eqy -d $B/$v/eqy)"
  rm -rf $B/$v/eqy
  $TIEMPO -o $B/$v/eqy_tiempo.txt eqy -j $J -f $B/$v/asic_top.eqy -d $B/$v/eqy > $B/$v/eqy.out 2>&1 || true
  tail -3 $B/$v/eqy.out
  cat $B/$v/eqy_tiempo.txt
  python3 asic/eqy/resumir_eqy.py $B/$v/eqy --md > $R/$v/eqy_resumen.md
  python3 asic/eqy/resumir_eqy.py $B/$v/eqy --particiones > $R/$v/eqy_particiones.md
  python3 asic/eqy/resumir_eqy.py $B/$v/eqy
  cp $B/$v/asic_top.eqy $B/$v/eqy_tiempo.txt $R/$v/
  grep -v "Running strategy\|Adding\|Creating\|Importing\|starting process\|finished (returncode" $B/$v/eqy/logfile.txt | tail -80 > $R/$v/eqy_logfile_extracto.txt
}

equiv_() {
  v=$1; mkdir -p $R/$v
  # Flujo clásico de Yosys: $equiv por cada señal con el mismo nombre; equiv_simple prueba cada
  # una por SAT sobre su cono desenrollado SEQ_SIMPLE pasos (2: el Q de un flip-flop se prueba
  # desde su D del paso anterior); equiv_induct prueba las restantes por inducción temporal de
  # SEQ pasos sobre todo el diseño. Tope de TMAX s con timeout (código 124).
  printf 'read_rtlil %s\nrename asic_top gold\nread_rtlil %s\nrename asic_top gate\ndelete t:$scopeinfo\nasync2sync\nequiv_make gold gate equiv\nhierarchy -top equiv\nstat\nequiv_status\nequiv_simple -seq %s\nequiv_status\nequiv_induct -seq %s\nequiv_status\n' \
    $B/$v/gold.il $B/$v/gate.il $SEQ_SIMPLE $SEQ > $B/$v/equiv.ys
  echo "== equiv $v (timeout $TMAX yosys -s $B/$v/equiv.ys)"
  $TIEMPO -o $B/$v/equiv_tiempo.txt timeout $TMAX yosys -q -l $B/$v/equiv.log -s $B/$v/equiv.ys > $B/$v/equiv.out 2>&1 || echo "código de salida $? (124 = timeout a los $TMAX s)" | tee $B/$v/equiv_codigo.txt
  cat $B/$v/equiv_tiempo.txt
  {
    echo "script: $B/$v/equiv.ys"; cat $B/$v/equiv.ys; echo
    cat $B/$v/equiv_tiempo.txt; cat $B/$v/equiv_codigo.txt 2>/dev/null || true
    echo; echo "equiv_status (en orden: tras equiv_make, tras equiv_simple, tras equiv_induct):"
    grep -n "Executing EQUIV_STATUS\|Found [0-9]* \$equiv cells\|Of those cells\|Executing EQUIV_SIMPLE\|Executing EQUIV_INDUCT\|Proved [0-9]*\|Proving \$equiv\|Trying to prove all\|Found [0-9]* unproven\|Successfully proved\|Generating problem\|Solving problem\|Warning: unproven" $B/$v/equiv.log | tail -40
    echo; echo "no probados al final:"
    awk '/Executing EQUIV_STATUS/{n++} n>=3 && /Unproven/' $B/$v/equiv.log | head -60
  } > $R/$v/equiv_resumen.txt
  cat $R/$v/equiv_resumen.txt | tail -25
}

bmc_() {
  v=$1; d=$B/$v/bmc_$BMC_PROF; mkdir -p $R/$v $d
  # Miter completo (gold y gate del mismo RTLIL canónico), todos los flip-flops partiendo en
  # un valor libre e independiente en los dos lados, rst_n forzado a 0 en los dos primeros
  # ciclos y después libre, botones libres; se prueba que las salidas (led, seg1, seg2,
  # spi_miso) coinciden en todos los ciclos desde el tercero hasta BMC_PROF (sby en modo
  # bmc, smtbmc con yices). Salidas en build/eqy/<variante>/bmc_<profundidad>/.
  python3 asic/eqy/miter_reset.py $B/$v/gold.il $B/$v/gate.il $d $BMC_PROF
  echo "== bmc $v (sby -f $d/miter_reset.sby, profundidad $BMC_PROF)"
  ( cd $d && $TIEMPO -o bmc_tiempo.txt sby -f miter_reset.sby > bmc.out 2>&1 || true )
  tail -4 $d/bmc.out; cat $d/bmc_tiempo.txt
  { cat $d/miter_reset.sby; echo; cat $d/bmc_tiempo.txt; echo; grep "summary\|DONE\|Checking assertions in step\|Assert failed\|Status" $d/miter_reset/logfile.txt | tail -12; } > $R/$v/bmc_${BMC_PROF}_resumen.txt
  cp $d/miter_reset.sv $R/$v/ 2>/dev/null || true
}

# Control negativo: el netlist de síntesis con una sola celda cambiada (en espino_alu, la
# instancia _0586_ pasa de nand2_1 a nor2_1, mismos pines A1, A2 y ZN) tiene que dar FAIL
# en la partición que contiene la ALU; si diera PASS, el método no distinguiría un error.
mutar_() {
  mkdir -p $B
  sed '/^module espino_alu/,/^endmodule/ s/gf180mcu_fd_sc_mcu7t5v0__nand2_1 _0586_ (/gf180mcu_fd_sc_mcu7t5v0__nor2_1 _0586_ (/' $NL_SINT > $B/gate_mut.nl.v
  echo "== gate mut: $(diff $NL_SINT $B/gate_mut.nl.v | grep -c '^[<>]') líneas distintas respecto de $NL_SINT:"; diff $NL_SINT $B/gate_mut.nl.v | tee $B/gate_mut_diff.txt || true
  yosys -q -l $B/gate_mut.log -p "$LEER_LIB; read_verilog $B/gate_mut.nl.v; hierarchy -top asic_top; flatten; $CIERRE; stat; write_json $B/gate_mut.json; write_rtlil $B/gate_mut.il"
  canonizar_ mut_v1ff
  eqy_ mut_v1ff
  cp $B/gate_mut_diff.txt $R/mut_v1ff/
}

case "${1:-todo}" in
  mutar) mutar_ ;;
  preparar) preparar ;;
  eqy) eqy_ "$2" ;;
  equiv) equiv_ "$2" ;;
  bmc) bmc_ "$2" ;;
  canonizar) canonizar_ "$2" ;;
  versiones) versiones ;;
  todo) preparar; for v in $VARIANTES; do eqy_ $v; done; equiv_ sint_v1ff; bmc_ sint_v1ff ;;
  *) echo "uso: bash asic/eqy/correr.sh preparar | canonizar <variante> | eqy <variante> | equiv <variante> | bmc <variante> | mutar | versiones | todo" >&2; exit 1 ;;
esac
