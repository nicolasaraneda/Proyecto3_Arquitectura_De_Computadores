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
| exp/rf-latch (B5) | ver rama | banco de registros con latches y clock gating | check PASS, equiv ciclo a ciclo | pendiente | | 2,953 | 2,665 | | | |

## B2: exp/lsu-offset

- Qué cambia: `rtl/espino_core/espino_load_store_unit.v` guarda `addr_i[1:0]` en `boff_q`
  al emitir la carga y alinea el dato leído con ese registro. El dato llega un ciclo
  después, con el pipeline detenido, así que `addr_i[1:0]` vale lo mismo en los dos
  ciclos: el comportamiento no cambia, pero la ALU sale de la ruta de alineación y
  write-back (la ruta crítica de f1_t26: `alu_operator[1]` -> ALU -> `lsu_addr[1]`
  -> alineación -> `rf_wdata[11]` -> banco).
- Verificación: `make check` PASS (6 testbenches, 80 tests); `make equiv` trazas
  idénticas ciclo a ciclo (1018 eventos, dos estrategias de memoria).
- Corridas (`asic/barrido_exp.md` de la rama): b2_t100 cierra con WNS 67,04 ns en max_ss
  (main 65,22) y 181.170 µm² de celdas (main 182.265, -0,6 %); b2_t26 cierra con 4,54 ns
  (main 2,00); b2_t24 cierra con 0,09 ns (main no cierra por 0,004). Período mínimo 24 ns
  (41,7 MHz) contra 25 ns; b2_t23 y b2_t22 en el lote 7. La ruta crítica a 24 ns ya no
  pasa por la ALU: va de `rf_ready` (ops_valid_q) por el control de stall y `rf_we` a los
  muxes de retención del banco (`build/exp_lsu_offset/asic/rom/resultados/b2_t24/layout/ruta_critica.txt`).
  Slew y capacitancia a 100 ns: 672 / 40 (main 546 / 36).

## B3: exp/branch-cmp

- Qué cambia: `rtl/espino_core/espino_id_stage.v` agrega un comparador (igualdad,
  menor con signo y sin signo) que toma `rf_rdata_a_i` y `rf_rdata_b_i` directo del
  banco de registros, y `branch_taken_o` usa ese resultado en vez de `cmp_result_o`
  de la ALU, que pasa por los muxes de operandos. Un salto siempre compara rs1 con
  rs2, así que el resultado es el mismo. La ALU conserva sus comparadores para SLT y
  SLTU; su `cmp_result_o` queda sin uso y la síntesis lo elimina.
- Verificación: `make check` PASS; `make equiv` idéntica ciclo a ciclo.
- Corridas: b3_t100 WNS 67,00 ns, 183.962 µm² (+0,9 % por los comparadores nuevos);
  b3_t26 cierra con 1,92 ns (main 2,00); b3_t24 no cierra (-0,085 ns). Solo no mejora el
  período mínimo: el salto no estaba en la ruta crítica (la ruta de la carga lo tapa).
  Slew y capacitancia a 100 ns: 554 / 29.

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

## B5: exp/rf-latch (opcional)

- Qué cambia: `rtl/espino_core/espino_register_file.v` guarda los 480 bits en latches
  `latq_1` (43,9 µm²) en vez de flip-flops `dffq_1` (63,7 µm²) con mux de retención
  `mux2_2` (32,9 µm²), y cada uno de los 15 registros tiene una celda de clock gating
  integrado `icgtp_1` (61,5 µm²) que deja pasar un solo pulso de reloj cuando ese
  registro se escribe. El enable del clock gate es combinacional (`we_i` y la
  comparación de `waddr_i`), lo muestrea la celda en la fase baja previa al flanco en
  que el core comete la escritura; el dato se registra en ese flanco (`wdata_q`, 32
  flip-flops) y entra a los latches durante la fase alta siguiente. Las celdas se
  instancian directamente a través de dos envoltorios (`rtl/gf180_cells.v`) con un
  modelo de comportamiento para simulación y lint (`ifdef SYNTHESIS`). Los puertos de
  lectura siguen registrados y el resto del core no cambia.
- Ahorro esperado: 480 x (63,7 + 32,9 - 43,9) - 15 x 61,5 - 32 x 63,7 = unos 22.000 µm²
  (12 % del área de celdas de síntesis). La medida real sale de las corridas b5_*.
- Verificación: `make check` PASS; `make equiv` idéntica ciclo a ciclo (1018 eventos).
  Un primer intento con el enable registrado (`we_q`, `waddr_q`) falló (X en las
  lecturas): el clock gate muestrea el enable en la fase baja anterior al flanco, así
  que un enable registrado llega un ciclo tarde respecto del dato.
- Pendiente: STA (chequeos de clock gating y latches), DRC, LVS y área en las corridas.
