# Exploraciones en ramas exp/* (bloque B)

Cada exploración vive en su rama `exp/<nombre>`, creada desde `main` y no fusionada,
con sus corridas y sus datos. Acá queda el resumen y el commit de cada rama. Las
corridas de cada rama se lanzan desde su worktree (`git worktree add build/exp_<nombre> exp/<nombre>`)
con la misma configuración final (`asic/rom/config.yaml`), y se verifican con
`make check` (80 tests del assembler y seis testbenches) y `make equiv` (traza de
`sw/isa_test.s` contra el commit 116fa20: idéntica ciclo a ciclo, o en el modo
funcional, misma secuencia de escrituras al banco, accesos al bus y salidas).

Referencia (main, configuración final D20 y D21): período mínimo 26 ns (f1_t26,
WNS 1,996 ns en max_ss; 24 ns no cierra por 0,004 ns), 38,5 MHz; área de celdas
estándar 182.265 µm² a 100 ns; CPI 2,953 en `isa_test.s` y 2,665 en el juego
completo (`game_tb`); 546 violaciones de max slew y 36 de max capacitancia a 100 ns.

## Tabla resumen

(se completa con las corridas de cada rama; `asic/recolectar.py` en cada worktree)

| rama | commit | cambio | verificación | T mínimo (ns) | f máx (MHz) | CPI isa_test | CPI juego | MIPS = f/CPI (juego) | área stdcell a 100 ns (µm²) | slew / cap (100 ns) |
|---|---|---|---|---|---|---|---|---|---|---|
| main (referencia) | ver `git log` | | check PASS, equiv ciclo a ciclo | 26 | 38,5 | 2,953 | 2,665 | 14,4 | 182.265 | 546 / 36 |
| exp/lsu-offset (B2) | 7ff1d06 | offset de byte de la carga registrado en la LSU | check PASS, equiv ciclo a ciclo (1018 eventos) | pendiente | | 2,953 | 2,665 | | | |
| exp/branch-cmp (B3) | e7d3de6 | comparador de saltos alimentado por el banco de registros | check PASS, equiv ciclo a ciclo | pendiente | | 2,953 | 2,665 | | | |
| exp/lsu-branch (B2+B3) | 71f9170 | los dos anteriores | check PASS, equiv ciclo a ciclo | pendiente | | 2,953 | 2,665 | | | |
| exp/cpi (B4) | 91a6c3b | ROM y banco combinacionales, decode en el fetch, 1 instrucción por ciclo | check PASS, equiv funcional (46 escrituras, 22 accesos, 2 salidas iguales) | pendiente | | 1,004 | 1,312 | | | |
| exp/signoff (B1) | pendiente | solo configuración del flujo | | | | | | | | |

## B2: exp/lsu-offset

- Qué cambia: `rtl/espino_core/espino_load_store_unit.v` guarda `addr_i[1:0]` en `boff_q`
  al emitir la carga y alinea el dato leído con ese registro. El dato llega un ciclo
  después, con el pipeline detenido, así que `addr_i[1:0]` vale lo mismo en los dos
  ciclos: el comportamiento no cambia, pero la ALU sale de la ruta de alineación y
  write-back (la ruta crítica de f1_t26: `alu_operator[1]` -> ALU -> `lsu_addr[1]`
  -> alineación -> `rf_wdata[11]` -> banco).
- Verificación: `make check` PASS (6 testbenches, 80 tests); `make equiv` trazas
  idénticas ciclo a ciclo (1018 eventos, dos estrategias de memoria).

## B3: exp/branch-cmp

- Qué cambia: `rtl/espino_core/espino_id_stage.v` agrega un comparador (igualdad,
  menor con signo y sin signo) que toma `rf_rdata_a_i` y `rf_rdata_b_i` directo del
  banco de registros, y `branch_taken_o` usa ese resultado en vez de `cmp_result_o`
  de la ALU, que pasa por los muxes de operandos. Un salto siempre compara rs1 con
  rs2, así que el resultado es el mismo. La ALU conserva sus comparadores para SLT y
  SLTU; su `cmp_result_o` queda sin uso y la síntesis lo elimina.
- Verificación: `make check` PASS; `make equiv` idéntica ciclo a ciclo.

## B2 + B3: exp/lsu-branch

- Los dos cambios anteriores (cherry-pick de ambas ramas). Verificación igual: PASS e idéntica ciclo a ciclo.

## B4: exp/cpi

- Qué cambia: la memoria de instrucciones entrega la instrucción de `pc_q` en el
  mismo ciclo (ROM combinacional, sin registro de instrucción; en la estrategia 2 la
  lectura del arreglo de flip-flops también es combinacional), el banco de registros
  se lee de forma combinacional (sin los 64 flip-flops de salida), el decodificador
  trabaja en el mismo ciclo (sin los 82 registros de pre-decodificación de D18) y
  desaparece el ciclo de espera (`rf_ready_o = 1`). Cada instrucción ejecuta en un
  ciclo salvo las cargas, que esperan un ciclo el dato de la memoria o del periférico
  (lectura registrada). Un salto tomado tampoco deja una instrucción de más que
  invalidar. Archivos: `espino_if_stage.v`, `espino_id_stage.v`, `espino_register_file.v`,
  `pochoco_mem_rom.v`, `pochoco_mem_ff.v`.
- Verificación: `make check` PASS (las seis simulaciones, incluido el juego completo
  con las dos estrategias); `make equiv MODO=funcional`: las secuencias de escrituras
  al banco (46, sin x0), accesos al bus (22) y salidas (2) son idénticas a las de
  116fa20; ciclo a ciclo no puede serlo porque cambia el número de ciclos.
- CPI (Ley de Hierro, tiempo = instrucciones x CPI x T): `isa_test.s` 1,004 (3000 ciclos,
  2988 instrucciones) contra 2,953; juego completo (`game_tb`, 10 rondas con error y
  reintento): 1,312 (1.595.008 ciclos, 1.216.019 instrucciones) contra 2,665
  (1.599.759 ciclos, 600.218 instrucciones). El juego pasa la mitad de los ciclos en
  lazos de espera con `lw`, de ahí que el CPI no llegue a 1.
- Pendiente: frecuencia máxima y área (corridas b4_*), y MIPS = f/CPI.
