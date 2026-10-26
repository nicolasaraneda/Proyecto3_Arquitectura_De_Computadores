# Versiones de las herramientas

Generado por `asic/versiones.sh` el 2026-10-26. Las herramientas del flujo corren dentro de la imagen de Docker de LibreLane; iverilog aparece dos veces porque la simulación se corre con el de oss-cad-suite en el anfitrión.

| herramienta | versión | cómo se obtuvo |
|---|---|---|
| LibreLane | v3.0.16 | `librelane --version` (pip, entorno ~/herramientas/librelane) |
| Imagen de Docker | `ghcr.io/librelane/librelane:3.0.16` (id 02d50f259d48) | `docker images --no-trunc` |
| PDK | GF180MCU `gf180mcuD`, revisión `54435919abffb937387ec956209f9cf5fd2dfbee` | carpeta de ciel en ~/.ciel (la revisión que fija LibreLane 3.0.16) |
| Biblioteca de celdas | `gf180mcu_fd_sc_mcu7t5v0` | `STD_CELL_LIBRARY` en resolved.json de la corrida |
| Yosys | Yosys 0.62 (git sha1 7326bb7d6641500ecb285c291a54a662cb1e76cf, clang++ 21.1.2 -fPIC -O3) | `yosys -V` en la imagen |
| OpenROAD | dcf36133a369abc8f3c5e5738cd4d82e4903c0e0  | `openroad -version` en la imagen |
| Magic | 8.3.623 | `magic --version` en la imagen |
| KLayout | KLayout 0.30.7 | `klayout -v` en la imagen |
| Netgen | Netgen 1.5.316 | `netgen -batch` en la imagen |
| Icarus Verilog (imagen) | Icarus Verilog version 13.0 (devel) () | `iverilog -V` en la imagen |
| Python (imagen) | Python 3.13.9 | `python3 --version` en la imagen |
| Icarus Verilog (anfitrión, `make check`, `make post-synth`) | Icarus Verilog version 14.0 (devel) (s20260301-403-g5ab23063f-dirty) | oss-cad-suite en ~/herramientas/oss-cad-suite |
| Verilator (anfitrión) | Verilator 5.053 devel rev v5.052-22-g7cf8c5cca (mod) | oss-cad-suite |
| Python (anfitrión) | Python 3.11.6 | `python3 --version` |
| Docker | Docker version 29.8.0 | `docker --version` |
| Sistema | Linux 6.18.33.2-microsoft-standard-WSL2 (WSL2) | `uname -sr` |
