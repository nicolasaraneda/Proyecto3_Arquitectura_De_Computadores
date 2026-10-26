# Proyecto 3: Pochoco SoC de FPGA a ASIC

> README provisorio: se completa a medida que avanzan las corridas. La corrida final y las versiones de las herramientas internas se agregan cuando estén cerradas.

Este repositorio lleva el juego de reflejos del Proyecto 2 (Pochoco SoC con el Espino Core, RV32E) desde la FPGA de la Go Board hasta un macro digital en GF180MCU, usando el flujo abierto LibreLane. El resultado es un macro implementado con celdas estándar, no un chip completo: los puertos de `asic_top` son conexiones lógicas que en un chip completo irían a pads de I/O.

El punto de partida es el commit `1227fa5` del repositorio del Proyecto 2 ([Vcalderone/Proyecto2_Arquitectura_De_Computadores](https://github.com/Vcalderone/Proyecto2_Arquitectura_De_Computadores)), importado con su historial: `git diff 1227fa5` muestra todo lo que se cambió para el ASIC. El SoC base es [nic0villegasc/pochoco_soc](https://github.com/nic0villegasc/pochoco_soc).

Grupo: Nicolás Araneda, Vicente Calderón y Santiago Muñoz.

## Versiones

| Componente | Versión |
|---|---|
| LibreLane | 3.0.16 (`pip install librelane==3.0.16`) |
| Imagen de Docker | `ghcr.io/librelane/librelane:3.0.16` |
| PDK | GF180MCU, variante `gf180mcuD`, revisión `54435919abffb937387ec956209f9cf5fd2dfbee` (la que fija LibreLane 3.0.16; la descarga ciel) |
| Biblioteca de celdas estándar | `gf180mcu_fd_sc_mcu7t5v0` |
| Simulación | Icarus Verilog, de oss-cad-suite |

Las versiones de Yosys, OpenROAD, Magic, KLayout y Netgen vienen dentro de la imagen de Docker y se registran desde la corrida final.

## Instalación de LibreLane

Probado en Windows con WSL2 (Ubuntu 26.04) y Docker. Desde una terminal de Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y build-essential python3-dev python3-venv python3-tk
python3 -m venv ~/herramientas/librelane
source ~/herramientas/librelane/bin/activate
pip install librelane==3.0.16
librelane --version
librelane --dockerized --pdk gf180mcuD --smoke-test
```

- Docker tiene que funcionar sin `sudo` (`docker ps`).
- `build-essential` y `python3-dev` hacen falta porque, con Python 3.14, la dependencia `lln-libparse` se compila al instalar.
- El entorno virtual se activa con `source ~/herramientas/librelane/bin/activate` en cada terminal nueva.
- La primera corrida descarga la imagen de Docker y el PDK, que queda en `~/.ciel`. La opción `--pdk gf180mcuD` va en cada comando: LibreLane descarga el PDK antes de leer la configuración, y sin ella usa sky130.

## Corridas

Todas se lanzan desde la raíz del repositorio, con el entorno activado:

```bash
librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag <tag>
```

| Configuración | Contenido |
|---|---|
| `asic/rom/config.yaml` | Estrategia 1 de memoria: ROM combinacional generada por el assembler más una RAM de datos de 4 palabras |
| `asic/ff/config.yaml` | Estrategia 2 de memoria: memoria unificada de instrucciones y datos en flip-flops |
| `asic/p2_original/config.yaml` | Serie de corridas 0 (sección 3.1), con su evidencia en `asic/p2_original/evidencia.md` |

Parámetros comunes: T = 100 ns (`CLOCK_PERIOD`) y U = 40 % (`FP_CORE_UTIL`). Las configuraciones de las dos estrategias conservan la jerarquía del register file, la ALU y el contador de ciclos (`SYNTH_KEEP_HIERARCHY_MODULES`) para poder ubicarlos en los reportes y en el layout. Cada corrida queda en `asic/<configuración>/runs/<tag>/`, que no se versiona; los reportes que usa el informe se copian a `asic/<configuración>/resultados/<tag>/`.

Un parámetro se puede cambiar solo para una corrida con `-c`, sin editar la configuración. Así se hacen los barridos y la síntesis jerárquica de la sección 3.3:

```bash
librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml -c CLOCK_PERIOD=70 --run-tag b1_t70
librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml -c SYNTH_HIERARCHY_MODE=keep --run-tag e1_jerarquia --to Yosys.Synthesis
```

**Corrida final:** por definir.

## Programa del juego

El juego está en `sw/game.s` y se traduce con el assembler propio (`assembler/`); no se usa ningún assembler externo. En silicio no hay un `.hex` que se cargue al encender, así que el assembler genera el programa como código Verilog: la ROM `rtl/gen/pochoco_rom.v` (estrategia 1) y la imagen `rtl/gen/game_image.vh` (estrategia 2). Después de cambiar `game.s`:

```bash
make image
```

Es equivalente a `python3 assembler/asm.py sw/game.s -o build/game.hex --vh rtl/gen/game_image.vh --rom rtl/gen/pochoco_rom.v`. Los dos archivos están versionados para que LibreLane los encuentre sin correr `make`, y un test del assembler falla si quedaron desactualizados.

Las constantes de tiempo están ajustadas al período del macro: con T = 100 ns el reloj es de 10 MHz, así que `CLK_HZ = 10000000` y `CYCLES_PER_TENTH = 1000000`. El resto de las constantes (`RONDAS`, `ESPERA_TENTHS` y otras) están al inicio de `game.s`, y también se pueden fijar al ensamblar con `-D NOMBRE=VALOR`.

## Verificación sin LibreLane

```bash
make check
```

Corre los 80 tests del assembler y los tres testbenches para cada estrategia de memoria (`make sim1` y `make sim2`). Las simulaciones ensamblan el juego con `CYCLES_PER_TENTH = 2500`, para que una partida dure segundos de simulación. Necesita `iverilog` y `vvp` (oss-cad-suite).

## El juego

Al encender, el display muestra `00` y una pulsación empieza la partida. En cada ronda se encienden los cuatro LEDs por 3 segundos y después uno solo, elegido al azar: hay que apretar su botón lo antes posible. Un acierto muestra el tiempo de reacción en décimas de segundo; un botón incorrecto muestra `EE` y reinicia la ronda. Tras 10 aciertos se muestra `AA` y después el promedio.

## Estructura del repositorio

```
.
├── Makefile              tests del assembler, imagen del programa y simulación
├── asic/                 configuraciones de LibreLane
│   ├── p2_original/      serie de corridas 0 (sección 3.1) y su evidencia
│   ├── rom/              estrategia 1 de memoria
│   └── ff/               estrategia 2 de memoria
├── assembler/            assembler propio (Python 3), con las opciones --rom y --vh
├── docs/                 decisiones, mapa de memoria y assembler
├── informe/              informe del Proyecto 2
├── rtl/
│   ├── asic_top.v        top del macro
│   ├── pochoco_soc.v     core, memoria y periféricos
│   ├── pochoco_mem_rom.v memoria de la estrategia 1 (ROM generada + RAM de datos)
│   ├── pochoco_mem_ff.v  memoria de la estrategia 2
│   ├── pochoco_cycle_counter.v  contador de ciclos (CYCLES)
│   ├── gen/              ROM e imagen del programa, generadas por el assembler
│   └── espino_core/      Espino Core (RV32E)
├── sw/                   programas en assembly (game.s es el juego)
└── tb/                   testbenches de Icarus Verilog
```

## Documentación

- `docs/decisiones.md`: cada decisión del proyecto, con sus opciones y la razón.
- `docs/memory_map.md`: mapa de memoria, periféricos y estrategias de memoria.
- `docs/assembler.md`: uso del assembler, incluidas la ROM y la imagen Verilog.
- `asic/p2_original/evidencia.md`: construcciones dependientes de la FPGA y lo que dijo el flujo de cada una (sección 3.1).
