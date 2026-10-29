# Proyecto 3: Pochoco SoC de FPGA a ASIC

Este repositorio lleva el juego de reflejos del Proyecto 2 (Pochoco SoC con el Espino Core, RV32E) desde la FPGA de la Go Board hasta un macro digital en GF180MCU, usando el flujo abierto LibreLane. El resultado es un macro implementado con celdas estándar, no un chip completo: los puertos de `asic_top` son conexiones lógicas que en un chip completo irían a pads de I/O.

El punto de partida es el commit `1227fa5` del repositorio del Proyecto 2 ([Vcalderone/Proyecto2_Arquitectura_De_Computadores](https://github.com/Vcalderone/Proyecto2_Arquitectura_De_Computadores)), importado con su historial: `git diff 1227fa5` muestra todo lo que se cambió para el ASIC. El SoC base es [nic0villegasc/pochoco_soc](https://github.com/nic0villegasc/pochoco_soc).

Grupo: Nicolás Araneda, Vicente Calderón y Santiago Muñoz.

## Versiones

Las de la corrida final (`asic/versiones.md`, generado por `asic/versiones.sh`):

| Componente | Versión |
|---|---|
| LibreLane | 3.0.16 (`pip install librelane==3.0.16`) |
| Imagen de Docker | `ghcr.io/librelane/librelane:3.0.16` (id `02d50f259d48`) |
| PDK | GF180MCU, variante `gf180mcuD`, revisión `54435919abffb937387ec956209f9cf5fd2dfbee` (la que fija LibreLane 3.0.16; la descarga ciel a `~/.ciel`) |
| Biblioteca de celdas estándar | `gf180mcu_fd_sc_mcu7t5v0` (7 tracks, 5 V) |
| Yosys (en la imagen) | 0.62 (git 7326bb7d) |
| OpenROAD (en la imagen) | dcf36133a369abc8f3c5e5738cd4d82e4903c0e0 |
| Magic (en la imagen) | 8.3.623 |
| KLayout (en la imagen) | 0.30.7 |
| Netgen (en la imagen) | 1.5.316 |
| Icarus Verilog (en la imagen) | 13.0 (devel) |
| Icarus Verilog (anfitrión, `make check` y `make post-synth`) | 14.0 (devel, oss-cad-suite s20260301) |
| Python | 3.14 (anfitrión), 3.13.9 (imagen) |

`asic/versiones.sh` las vuelve a consultar (`librelane --version`, `yosys -V`, `openroad -version`, `magic --version`, `klayout -v`, `netgen -batch` e `iverilog -V` dentro de la imagen).

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

Para varias corridas en paralelo, `asic/barrido.sh` lee una lista con una corrida por línea (`<config.yaml> <tag> <CLOCK_PERIOD> [VARIABLE=VALOR ...]`) y deja la salida de cada una en `asic/logs/`. Después, `asic/recolectar.py` copia los reportes de cada corrida a `resultados/` y agrega sus tablas a `asic/barrido.md`:

```bash
bash asic/barrido.sh < lista.txt
python3 asic/recolectar.py --md asic/barrido.md --titulo "Título" asic/rom/runs/<tag> ...
```

**Estrategia final:** la 1 (`asic/rom/config.yaml`), por área, frecuencia y antenas (`docs/decisiones.md`, D17).

## Corrida final

La corrida final es el tag `final` de `asic/rom/config.yaml`: estrategia 1 con el core del pipeline (lectura del banco de registros y decodificación durante el fetch, `EarlyRead = 1`, banco write-through y el offset de byte de la carga registrado en la LSU; D23 y `docs/pipeline.md`), celdas de retardo y `buf_1` excluidas con margen de 10 ns en el resizer (D20), terminales ubicados por función (D21, `asic/rom/pines.cfg`), el modelo de cable del resizer con los RC medidos por extracción y la reparación después del ruteo global (D23 y `docs/modelo_cable.md`), T = 100 ns y FP_CORE_UTIL = 40 %. Se lanza con:

```bash
source ~/herramientas/librelane/bin/activate
librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml --run-tag final
```

o con `make final`, que además verifica los criterios de cierre y regenera todo lo que depende de la corrida (`asic/final.sh`):

1. la corrida (se puede saltar con `bash asic/final.sh --sin-corrida` si `asic/rom/runs/final` ya existe);
2. `asic/verificar_cierre.py`: DRC de Magic, LVS, antenas y setup y hold en las 9 esquinas (`asic/rom/resultados/final/cierre.md`);
3. `asic/recolectar.py`: reportes a `asic/rom/resultados/final/` y tabla en `asic/final.md`;
4. síntesis jerárquica (`h3_t100`) y `asic/analisis_sintesis.py` -> `asic/sintesis.md` (sección 3.3);
5. `asic/layout/anotar.py` con KLayout en la imagen de Docker -> `asic/rom/resultados/final/layout/` (sección 3.6);
6. `asic/drc_klayout.sh`: segundo DRC con el deck de KLayout de GF180MCU (`asic/drc/`);
7. `make post-synth` y `make post-synth-final` (sección 3.7, `asic/sim/`);
8. `asic/versiones.sh` -> `asic/versiones.md`.

Resultado de la corrida final (`asic/rom/resultados/final/`): cierra en las 9 esquinas (setup WNS 65,725 ns, hold WNS 0,173 ns en la peor), DRC de Magic y de KLayout limpios (0 marcadores en 684 reglas, con control positivo), LVS limpio, 0 antenas; die de 638,5 x 656,4 µm (0,419 mm²), 208.439 µm² de celdas estándar, 9.928 celdas y 964 flip-flops, utilización real del core 53,5 %. **0 violaciones de max slew** y 1 de max capacitancia en la esquina lenta (en v1 eran 546 y 36): la única que queda es la raíz del árbol de reloj, que `repair_design` no toca (`asic/rom/resultados/final/avisos.md`, aviso 4, y `docs/datos_informe.md` 3.6). Período mínimo 21,5 ns (46,5 MHz) y 27,9 MIPS con el CPI del juego de 1,665. Los barridos de período y utilización están en `asic/final.md`, la evolución del rendimiento etapa por etapa en `asic/evolucion.md` y los datos de cada sección del enunciado en `docs/datos_informe.md`.

La corrida final anterior, la de `main` antes de integrar `exp/candidata-rc`, se conserva como historia: tag `v1-final`, reportes en `asic/rom/resultados/v1_final/` (con un `LEEME.md` que lista cada cifra y su clave) y corrida en disco en `asic/rom/runs/v1_final_run/`. En todos los documentos "v1" quiere decir ese estado.

Los barridos se lanzan aparte con la **cola única** de corridas, que es lo que hay que usar desde la sesión del 27-10-2026: un solo proceso lanza todas las corridas con un máximo de tres simultáneas, corta a los 40 minutos y vigila memoria y disco.

```bash
bash asic/cola.sh &                                                  # el daemon
bash asic/encolar.sh . asic/rom/config.yaml f2_t22 22                # encolar
bash asic/encolar.sh . asic/rom/config.yaml u2_u60 100 FP_CORE_UTIL=60
bash asic/encolar.sh . asic/rom/config.yaml h3_t100 100 SYNTH_HIERARCHY_MODE=keep --to Yosys.Synthesis
bash asic/encolar.sh build/exp_pipeline asic/rom/config_final.yaml pr_t22 22   # en un worktree
bash asic/esperar.sh f2_t22 u2_u60                                   # esperar
touch asic/logs/cola.fin                                             # terminar el daemon
```

La cola está en `asic/logs/cola.txt` y su bitácora en `asic/logs/cola_estado.txt` (una línea por evento: encolada, lanzada, terminada, fallida o incompleta). El tag tiene que ser único en toda la sesión, porque la cola identifica el contenedor por el tag. `asic/barrido.sh` y `asic/vigilar.sh` siguen ahí, pero la cola los reemplaza.

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

Corre los 80 tests del assembler y los seis testbenches para cada estrategia de memoria (`make sim1` y `make sim2`). Las simulaciones ensamblan el juego con `CYCLES_PER_TENTH = 2500`, para que una partida dure segundos de simulación. Necesita `iverilog` y `vvp` (oss-cad-suite).

```bash
make equiv
```

Compara el core actual con el de otro commit (por defecto `116fa20`, antes de la pre-decodificación): corre `sw/isa_test.s`, que usa todas las instrucciones que soporta el assembler, con los dos RTL y las dos estrategias de memoria, y compara las trazas de escrituras al banco de registros, accesos al bus de datos y salidas. Se elige otra referencia con `make equiv REF=<commit>` (por ejemplo `REF=v1-final`), otro programa con `PROG=<nombre>` (`sw/hazard_test.s`, `sw/hazard_review.s`, `sw/hazard_cycles.s`) y el modo con `MODO=funcional`, que compara las secuencias de eventos sin el número de ciclo. **El core de D23 gasta un ciclo menos por instrucción que el de v1, así que la comparación con v1 es funcional y no ciclo a ciclo**: ciclo a ciclo sigue valiendo contra la estrategia 2, que usa `EarlyRead = 0` y conserva la temporización anterior. Las dos simulaciones imprimen el CPI y el monitor de valores desconocidos usados. Las 15 comprobaciones de la integración de D23, con su salida completa, están en `docs/verificacion/integracion.md`, junto con el `make check` repetido sobre el commit final de la sesión (punto 16).

```bash
make post-synth
```

Simulación post-síntesis (sección 3.7): sintetiza el diseño con la configuración final y la ROM del programa de simulación (`asic/sim/config.yaml`, hasta `Yosys.Synthesis`), corre el RTL y el netlist de celdas estándar con el mismo testbench de puertos (`tb/post_synth_tb.v`) y los mismos estímulos (`asic/sim/estimulos.txt`), y compara las trazas: PASS si son idénticas. `make post-synth-final` hace lo mismo con el netlist de la corrida final y las constantes reales; `make post-pnr-sdf` intenta la simulación post-PnR con retardos. Todo está explicado en `asic/sim/README.md`.

## El juego

Al encender, el display muestra `00` y una pulsación empieza la partida. En cada ronda se encienden los cuatro LEDs por 3 segundos y después uno solo, elegido al azar: hay que apretar su botón lo antes posible. Un acierto muestra el tiempo de reacción en décimas de segundo; un botón incorrecto muestra `EE` y reinicia la ronda. Tras 10 aciertos se muestra `AA` y después el promedio.

## Estructura del repositorio

```
.
├── Makefile              tests del assembler, imagen del programa y simulación
├── asic/                 configuraciones de LibreLane y scripts del flujo
│   ├── p2_original/      serie de corridas 0 (sección 3.1) y su evidencia
│   ├── rom/              estrategia 1 de memoria (configuración final, pines.cfg, resultados/)
│   ├── ff/               estrategia 2 de memoria
│   ├── sim/              síntesis y estímulos de la simulación post-síntesis
│   ├── layout/           anotar.py: figuras del layout con KLayout en modo batch
│   ├── drc/              deck de DRC de KLayout de GF180MCU (segundo signoff)
│   ├── final.sh          corrida final y todo lo que depende de ella (make final)
│   ├── barrido.sh, vigilar.sh, recolectar.py, graficos.py, verificar_cierre.py, analisis_sintesis.py, drc_klayout.sh, versiones.sh
│   ├── barrido.md        barridos de las secciones 3.2 y 3.4 (corridas anteriores a D20)
│   ├── final.md          corrida final y barridos con la configuración final
│   ├── sintesis.md       sección 3.3
│   └── exploraciones.md  resumen de las ramas exp/* (bloque B)
├── assembler/            assembler propio (Python 3), con las opciones --rom y --vh
├── docs/                 decisiones, mapa de memoria, assembler, datos del informe, defensa, layout, progreso
├── informe/              informe del Proyecto 3 (main.tex); el del Proyecto 2 en informe/proyecto2/
├── rtl/
│   ├── asic_top.v        top del macro
│   ├── pochoco_soc.v     core, memoria y periféricos
│   ├── pochoco_mem_rom.v memoria de la estrategia 1 (ROM generada + RAM de datos)
│   ├── pochoco_mem_ff.v  memoria de la estrategia 2
│   ├── pochoco_cycle_counter.v  contador de ciclos (CYCLES)
│   ├── gen/              ROM e imagen del programa, generadas por el assembler
│   └── espino_core/      Espino Core (RV32E)
├── sw/                   programas en assembly (game.s es el juego; isa_test.s prueba el core)
└── tb/                   testbenches de Icarus Verilog (core_trace_tb.v: traza para make equiv; post_synth_tb.v: sección 3.7)
```

## Documentación

- `docs/decisiones.md`: cada decisión del proyecto, con sus opciones y la razón (D1 a D23).
- `docs/memory_map.md`: mapa de memoria, periféricos y estrategias de memoria.
- `docs/assembler.md`: uso del assembler, incluidas la ROM y la imagen Verilog.
- `docs/datos_informe.md`: por cada sección del enunciado, los números, tablas y figuras que la responden y la corrida de origen.
- `docs/defensa.md`: preguntas probables de la defensa con su respuesta y el archivo que la respalda.
- `docs/layout.md`: cómo abrir el layout final en KLayout u OpenROAD y repetir las marcas de los bloques.
- `docs/progreso.md`: estado de cada tarea del cierre y cómo retomarla.
- `asic/p2_original/evidencia.md`: construcciones dependientes de la FPGA y lo que dijo el flujo de cada una (sección 3.1).
- `asic/exploraciones.md`: ramas `exp/*` con cambios de RTL o de configuración, con su verificación y sus medidas. Las que entraron en la corrida final están marcadas.
- `docs/pipeline.md`: el core del pipeline (lectura del banco y decodificación en el fetch, write-through, `EarlyRead`, B2), cómo se resuelve cada riesgo de datos y cómo se verificó.
- `docs/modelo_cable.md`: qué estima el resizer, por qué el promedio del tech LEF era optimista, cómo se midieron los RC de cable y qué cuesta corregirlos. Los valores los deriva `asic/modelo_cable.py` y su informe es `asic/modelo_cable.md`.
- `docs/propuesta_d23.md` y `docs/revision_frente_a.md`: el análisis que llevó a D23 y la revisión independiente del core nuevo.
- `docs/verificacion/integracion.md`: las 15 comprobaciones de la integración de D23 más el `make check` del cierre, con la salida de cada una.
- `docs/cambios_informe.md`: sección por sección del informe y pregunta por pregunta de la defensa, qué cifra cambia, de qué valor a qué valor y con qué archivo.
- `asic/evolucion.md`: la evolución del rendimiento etapa por etapa (período mínimo, f máx, CPI, MIPS, área), con el reparto del aumento de MIPS entre el RTL y el flujo.
- `asic/rutas.md`: las rutas críticas partidas en tramos y el cálculo del tiempo requerido.
- `asic/potencia/resultado.md` y `docs/equivalencia.md`: potencia con actividad real y equivalencia formal del diseño nuevo, comparadas contra v1.
