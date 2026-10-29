#!/usr/bin/env bash
# Escribe asic/rutas.md: la ruta critica por tramos y el calculo del tiempo requerido
# de las corridas que la seccion 3.4 del informe necesita. Cada tabla la genera
# asic/ruta_tramos.py desde el report_checks copiado a resultados/.
#
# Uso: bash asic/rutas.sh
set -eu
cd "$(dirname "$0")/.."
MD=asic/rutas.md
E=max_ss_125C_4v50
cat > $MD <<'CAB'
# Rutas criticas por tramos (seccion 3.4)

Generado por `bash asic/rutas.sh`, que llama a `asic/ruta_tramos.py` sobre el `report_checks`
de cada corrida (`asic/<config>/resultados/<tag>/max_ss_125C_4v50_ruta_critica.rpt`). Todas las
rutas son de setup, grupo `clk`, en la esquina mas lenta `max_ss_125C_4v50`, que es la que decide
el cierre (D14).

Como leer la tabla de tramos: el camino de llegada se parte en el arbol de reloj hasta el pin CLK
del flip-flop de inicio, el arco reloj a Q de ese flip-flop, un tramo por cada bloque de la
jerarquia por el que pasa el camino, y el pin D del flip-flop de llegada. Las celdas que la
sintesis aplano no tienen nombre jerarquico y se agrupan como "logica aplanada"; para saber de que
se trata, la ultima columna lista los nets, que si conservan el nombre del RTL.

La funcion de cada tramo (fetch, decode, ejecucion, acceso a memoria o write-back) esta
interpretada en `docs/datos_informe.md`, seccion 3.4.

Los nombres de inicio y de llegada que el reporte da aplanados (`_4136_`, `_4440_`) se resuelven
en el netlist de la corrida, que si guarda el nombre del RTL en el net de salida. Por ejemplo,
para la corrida del periodo minimo:

    grep -A3 "dffrnq_1 _4440_" asic/rom/runs/f2_t21p5/final/nl/asic_top.nl.v

devuelve `.Q(\u_soc.u_periph.digit_q[4] )`, es decir que el flip-flop de llegada es el bit 4 del
registro del display del periferico. Lo mismo con el de inicio: el net de la primera fila de la
tabla de tramos ya lo nombra (`u_soc.u_core.u_id.alu_op_a_sel[2]`).

CAB
agrega() { # $1 ruta del rpt, $2 titulo
  [ -f "$1" ] || { echo "  (falta $1)"; return 0; }
  python3 asic/ruta_tramos.py "$1" --titulo "$2" --md $MD > /dev/null
  echo "  $2"
}
echo "escribiendo $MD"
agrega "asic/rom/resultados/final/${E}_ruta_critica.rpt"      "Corrida final nueva a 100 ns (tag final)"
agrega "asic/rom/resultados/f2_t21p5/${E}_ruta_critica.rpt"   "Corrida final nueva al periodo minimo (f2_t21p5, 21,5 ns)"
agrega "asic/rom/resultados/f2_t22/${E}_ruta_critica.rpt"     "Corrida final nueva a 22 ns (f2_t22)"
for t in pr_t100 pr_t22 pr_t21p5 pr_t21 pr_t23 pr_t24; do
  agrega "build/exp_pipeline/asic/rom/resultados/$t/${E}_ruta_critica.rpt" "exp/pipeline sin B2 con el flujo final ($t)"
done
agrega "asic/rom/resultados/v1_final/${E}_ruta_critica.rpt"   "Corrida final de v1 a 100 ns (historia)"
agrega "asic/rom/resultados/f1_t24p5/${E}_ruta_critica.rpt"   "Periodo minimo de v1 (f1_t24p5, 24,5 ns; historia)"
agrega "asic/main_rc/resultados/co_rcm_t22/${E}_ruta_critica.rpt" "RTL de v1 con el modelo de cable al periodo minimo (co_rcm_t22, 22 ns)"
echo "listo: $MD"
