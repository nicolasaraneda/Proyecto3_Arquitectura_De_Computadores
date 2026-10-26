#!/usr/bin/env bash
# Versiones exactas de las herramientas de la corrida final: LibreLane y las
# que vienen dentro de su imagen de Docker (yosys, openroad, magic, klayout,
# netgen, iverilog), más la revisión del PDK y la biblioteca de celdas.
# Escribe asic/versiones.md. Uso: bash asic/versiones.sh
set -u
cd "$(dirname "$0")/.."
IMAGEN="${IMAGEN:-ghcr.io/librelane/librelane:3.0.16}"
LL="$HOME/herramientas/librelane/bin/librelane"
PDK_ROOT="${PDK_ROOT:-$HOME/.ciel/ciel/gf180mcu/versions/54435919abffb937387ec956209f9cf5fd2dfbee}"
{
  echo "# Versiones de las herramientas"
  echo
  echo "Generado por \`asic/versiones.sh\` el $(date '+%F'). Las herramientas del flujo corren dentro de la imagen de Docker de LibreLane; iverilog aparece dos veces porque la simulación se corre con el de oss-cad-suite en el anfitrión."
  echo
  echo "| herramienta | versión | cómo se obtuvo |"
  echo "|---|---|---|"
  echo "| LibreLane | $("$LL" --version 2>/dev/null | head -1 | sed 's/LibreLane //') | \`librelane --version\` (pip, entorno ~/herramientas/librelane) |"
  echo "| Imagen de Docker | \`$IMAGEN\` (id $(docker images --no-trunc --format '{{.ID}}' "$IMAGEN" | head -1 | cut -c8-19)) | \`docker images --no-trunc\` |"
  echo "| PDK | GF180MCU \`gf180mcuD\`, revisión \`$(basename "$PDK_ROOT")\` | carpeta de ciel en ~/.ciel (la revisión que fija LibreLane 3.0.16) |"
  echo "| Biblioteca de celdas | \`gf180mcu_fd_sc_mcu7t5v0\` | \`STD_CELL_LIBRARY\` en resolved.json de la corrida |"
  docker run --rm "$IMAGEN" bash -c '
    y=$(yosys -V 2>&1 | head -1)
    o=$(openroad -version 2>&1 | head -1)
    m=$(magic --version 2>&1 | head -1)
    k=$(klayout -v 2>&1 | head -1)
    n=$(netgen -batch "puts [netgen -version]" 2>&1 | grep -o "Netgen [0-9.]*" | head -1)
    [ -z "$n" ] && n=$(netgen -batch "exit" 2>&1 | grep -o "Netgen [0-9.]*" | head -1)
    i=$(iverilog -V 2>&1 | head -1)
    p=$(python3 --version 2>&1)
    echo "| Yosys | $y | \`yosys -V\` en la imagen |"
    echo "| OpenROAD | $o | \`openroad -version\` en la imagen |"
    echo "| Magic | $m | \`magic --version\` en la imagen |"
    echo "| KLayout | $k | \`klayout -v\` en la imagen |"
    echo "| Netgen | $n | \`netgen -batch\` en la imagen |"
    echo "| Icarus Verilog (imagen) | $i | \`iverilog -V\` en la imagen |"
    echo "| Python (imagen) | $p | \`python3 --version\` en la imagen |"
  ' 2>/dev/null
  if [ -f "$HOME/herramientas/oss-cad-suite/environment" ]; then
    ( source "$HOME/herramientas/oss-cad-suite/environment"
      echo "| Icarus Verilog (anfitrión, \`make check\`, \`make post-synth\`) | $(iverilog -V 2>&1 | head -1) | oss-cad-suite en ~/herramientas/oss-cad-suite |"
      echo "| Verilator (anfitrión) | $(verilator --version 2>&1 | head -1) | oss-cad-suite |" )
  fi
  echo "| Python (anfitrión) | $(python3 --version 2>&1) | \`python3 --version\` |"
  echo "| Docker | $(docker --version 2>&1 | sed 's/,.*//') | \`docker --version\` |"
  echo "| Sistema | $(uname -sr) (WSL2) | \`uname -sr\` |"
} > asic/versiones.md
cat asic/versiones.md
