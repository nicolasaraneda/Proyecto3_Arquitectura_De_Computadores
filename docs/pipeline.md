# Rama exp/pipeline (frente A): lectura del banco de registros y decode en el fetch

Sesión del 27-10-2026. Rama `exp/pipeline`, creada desde `main` (50f8a39); worktree
`build/exp_pipeline`. Sub-ramas `exp/pipeline-b5` (banco de latches de B5) y
`exp/pipeline-b2` (offset de byte registrado de B2), creadas desde `exp/pipeline`.
Tags de las corridas: `pa_*`. Tabla de corridas generada por `asic/recolectar.py`:
`asic/barrido_exp.md`. Salidas completas de la verificación: `docs/verificacion/*.txt`.

## 1. Idea y diseño

En `main` (D18) cada instrucción tarda dos ciclos (tres las cargas): se carga en el
registro de instrucción en el flanco N, en el ciclo N espera (`ops_valid_q = 0`)
mientras el banco de registros lee rs1 y rs2 y el decodificador trabaja, en el flanco
N+1 se registran operandos y decode, en el ciclo N+1 ejecuta y comete en el flanco N+2.

La ROM de la estrategia 1 (`rtl/gen/pochoco_rom.v`, instanciada en
`rtl/pochoco_mem_rom.v`) es combinacional: su salida `rom_data` es la instrucción de la
dirección que pide la etapa IF (`pc_q`) un ciclo antes de que se cargue en el registro
de instrucción. Esta rama usa esa salida para pedir la lectura sincrónica del banco de
registros (direcciones rs1 y rs2 tomadas de `rom_data`) y registrar la salida del
decodificador en el mismo flanco en que se carga la instrucción. Al llegar a ejecución,
operandos y decode ya están listos y desaparece el ciclo de espera, sin volver
combinacional el banco (como hizo B4, exp/cpi, que por eso cerró recién a 60 ns).

Temporización nueva (`EarlyRead = 1`):

| instrucción | flanco N | ciclo N | flanco N+1 | ciclo N+1 | flanco N+2 |
|---|---|---|---|---|---|
| aritmética, store, salto no tomado | se cargan a la vez registro de instrucción (en la memoria), operandos (lectura registrada del banco con rs1/rs2 de `rom_data`) y decode registrado; `pc_q` avanza | ejecuta | commit: `rf_we`, `pc_q` avanza, se carga i+1 con sus operandos | | |
| carga | igual | `lsu_req`, `busy` de la LSU detiene el pipeline (`stall = 1`); la memoria registra el dato | nada avanza; el banco no vuelve a leer (`rd_en = 0`), conserva los operandos de la carga | el dato registrado llega por `lsu_rdata`, alineado con `addr_i[1:0]` de la ALU | commit de la carga y, en el mismo flanco, lectura de operandos de i+1 con write-through |
| salto tomado, jal, jalr | igual | `pc_set = 1` | `pc_q <= destino`; se carga la secuencial i+1 con `instr_valid = 0` (sus operandos y decode se registran igual, sin efecto) | burbuja: nada comete | se carga la instrucción destino con sus operandos |

Un ciclo por instrucción, dos las cargas y dos los saltos tomados (en `main`: dos, tres
y tres, contando la burbuja de la secuencial descartada).

Qué cambia en el RTL (diff resumido contra `main`, `git diff main..exp/pipeline -- rtl/`):

- `rtl/espino_core/espino_id_stage.v`: parámetro `EarlyRead`; puerto `instr_next_i`
  (instrucción combinacional de la dirección pedida); `dec_instr` elige entre
  `instr_next_i` (EarlyRead) y el registro de instrucción (temporización de `main`);
  `rf_raddr_a/b` y el decodificador trabajan sobre `dec_instr`; `rf_waddr_o` (rd) sigue
  saliendo del registro de instrucción, que se carga en el mismo flanco y con la misma
  condición que el decode registrado. Con EarlyRead `rf_ready_o = 1` (sin ciclo de
  espera), el decode se registra cuando `~stall_i` (`dec_load = advance`) y el banco
  lee solo cuando `~stall_i` (`rf_rd_en_o`). Con `EarlyRead = 0` queda el bloque
  `g_wait` con `ops_valid_q`, idéntico a `main`.
- `rtl/espino_core/espino_register_file.v`: entrada `rd_en_i` (los puertos de lectura
  solo se cargan cuando vale 1) y write-through: si `we_i`, `waddr_i != 0` y
  `raddr == waddr`, la salida registrada toma `wdata_i` en vez del valor viejo del
  arreglo. x0 nunca se escribe ni se adelanta.
- `rtl/espino_core/espino_core.v`: parámetro `EarlyRead` y puerto `instr_next_i`,
  cableados a la etapa ID; `rf_rd_en` al banco.
- `rtl/pochoco_mem_rom.v` y `rtl/pochoco_mem_ff.v`: salida `a_next_o`, la palabra de
  `a_addr_i` sin registrar (la misma que se registra en `a_rdata_o`).
- `rtl/pochoco_soc.v` y `rtl/asic_top.v`: parámetro `EarlyRead` con valor por defecto
  `(MemStrategy == 1) ? 1 : 0`, y `instr_next` cableado desde la memoria al core.
- `asic/rom/config.yaml` y `asic/sim/config.yaml`: `EarlyRead=1` en `SYNTH_PARAMETERS`.
- Sin cambios en `espino_if_stage.v`, `espino_controller.v`, `espino_decoder.v`,
  `espino_alu.v` ni `espino_load_store_unit.v` (en la rama base).

Efecto en la síntesis (`asic/rom/resultados/pa_t100/sintesis_stat.rpt` contra
`asic/rom/resultados/final/sintesis_stat.rpt` de `main`): 962 flip-flops contra 990. Los
28 de menos son el registro de instrucción: con EarlyRead solo se usa `instr_rdata_i[10:7]`
(rd), así que Yosys elimina los otros 28 bits de `a_rdata_o`. `espino_register_file`
pasa de 73.656 a 80.349 µm² (+6.693 µm²: los mux2_2 suben de 622 a 796 por el
write-through y el enable de lectura). Área de celdas de síntesis 155.855 contra
152.169 µm² (+2,4 %).

### Estrategia 2 (`pochoco_mem_ff`)

La memoria en flip-flops tiene lectura registrada en el puerto A, pero `a_next_o` existe
igual (es el mux sobre los flip-flops que se registra en `a_rdata_o`), de modo que las
dos memorias tienen la misma interfaz. Elección: `pochoco_soc` instancia el core con
`EarlyRead = 0` cuando `MemStrategy = 2`, es decir la temporización de `main` con ciclo
de espera, y el core ignora `instr_next_i`. Razón: la estrategia 2 no es la de la
corrida final (D17) y así `make check` y `make equiv` siguen cubriendo el camino
antiguo del core en la misma rama (sim2 da exactamente los números de `main`: CPI del
juego 2,665, 388.411 escrituras al banco). Si se quisiera EarlyRead con la estrategia 2
bastaría pasar `EarlyRead=1` por `SYNTH_PARAMETERS`: `a_next_o` es el mux combinacional
y el core funcionaría, pero la ruta mux de 119 palabras -> rs -> banco sería la crítica.

## 2. Riesgos de datos y de control, y cómo se resuelven

Todas las referencias son a `rtl/espino_core/espino_id_stage.v` (ID) y
`rtl/espino_core/espino_register_file.v` (RF).

1. Escritura seguida de lectura del mismo registro. En el flanco N+1 se escribe rd de
   la instrucción i (`rf_we = rf_we_dec & commit`) y a la vez se registran los
   operandos de i+1. RF: `fwd_a = wr & (raddr_a_i == waddr_i)` (ídem b), con
   `wr = we_i & (waddr_i != 0)`; la salida registrada toma `wdata_i`. Una distancia de
   dos o más instrucciones ya lee el arreglo actualizado. Prueba: `sw/hazard_test.s`
   sección 1 (c01 a c10: rs1 y rs2, inmediata y subsiguiente, cadena, lui/auipc) y
   sección 2 (dirección y dato de un store).
2. Carga seguida de uso. La carga comete en su segundo ciclo; mientras `stall_i = 1` el
   banco no vuelve a leer (`rf_rd_en_o = ~stall_i`, ID bloque `g_early`), así que la
   lectura de operandos de i+1 ocurre en el flanco del commit de la carga, y el
   write-through entrega `rf_wdata_o = lsu_rdata_i`. Además los operandos de la carga se
   conservan durante el stall, que es lo que necesita la LSU para alinear el dato con
   `addr_i[1:0]` (la ALU sigue calculando la dirección en el segundo ciclo). Prueba:
   `hazard_test.s` sección 3 (c14 a c33: lb/lbu/lh/lhu/lw, offsets 0 a 3, con y sin
   signo, uso como rs1, rs2, dirección de store, dato de store, operando de salto, base
   de jalr, desde la RAM y desde el periférico BTN) y sección 9.
3. jal o jalr seguido de uso del link. x1 (o rd) se escribe en el commit del salto
   (flanco N+1); la instrucción destino se carga en el flanco N+2 (después de la
   burbuja de la secuencial descartada), cuando el arreglo ya tiene el valor. Prueba:
   sección 5 (c38 a c41: retorno inmediato, copia del link, jalr con base recién escrita,
   jal encadenado) y sección 9 (link modificado y usado por jalr).
4. Escrituras a x0. RF: `wr` excluye `waddr_i == 0` tanto de la escritura como del
   write-through, y la lectura de la dirección 0 entrega 0 por hardware. Prueba: sección
   6 (c42 a c45: addi, add con rs recién escrito, lw y jal a x0, seguidos de lecturas de
   x0).
5. Salto tomado. La secuencial que se cargó junto con `pc_set` llega con
   `instr_valid_i = 0` (`valid_d = ~pc_set_i` en la etapa IF, sin cambios). Sus
   operandos y su decode se registran igual, pero `lsu_req_o`, `rf_we_o` (vía `commit`)
   y `pc_set_o` (controlador) están condicionados a `instr_valid_i`, así que no tienen
   efecto; la lectura anticipada del banco tampoco, porque solo carga registros de
   salida. Prueba: sección 7 (los 12 saltos condicionales tomados y no tomados con la
   instrucción siguiente dependiente, salto sobre registro recién escrito, lazo hacia
   atrás, destino que usa un registro escrito justo antes) y sección 8 (saltos
   encadenados: salto tomado cuyo destino es otro salto tomado, jal que llega de un
   salto, jalr que llega de un jal).
6. Reset. `valid_q` arranca en 0 y durante el reset `pc_q = BootAddr`, así que el
   registro de instrucción, los operandos y el decode (sin reset) se cargan con la
   primera instrucción en cada flanco del reset; todo lo que los usa está condicionado
   a `instr_valid_i`. El monitor de X (sección 3.5) confirma que ningún valor
   desconocido llega a una escritura, al bus, a la ALU en un commit ni a una salida.

## 3. Verificación (desde `build/exp_pipeline`, con `export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH`)

### 3.1 `make check` (`docs/verificacion/make_check.txt`)

80 pruebas del assembler OK y los seis testbenches PASS (game_top_tb, game_tb con 10
rondas y game_tb con 4 rondas, estrategias 1 y 2). CPI que imprime `game_tb`:

| simulación | ciclos | instrucciones | CPI |
|---|---|---|---|
| estrategia 1 (EarlyRead = 1), 10 rondas | 1.595.814 | 958.358 | 1,665 |
| estrategia 1, 4 rondas | 782.048 | 465.094 | 1,681 |
| estrategia 2 (EarlyRead = 0), 10 rondas | 1.599.759 | 600.218 | 2,665 |
| estrategia 2, 4 rondas | 783.951 | 292.252 | 2,682 |

Los ciclos totales casi no cambian (el juego espera por tiempo, no por instrucciones):
el mismo juego ejecuta 60 % más instrucciones en los mismos ciclos, es decir el lazo de
polling da más vueltas por décima. La estrategia 2 reproduce exactamente los números de
`main` (CPI 2,665, 388.411 escrituras al banco).

### 3.2 `make equiv MODO=funcional` (`docs/verificacion/make_equiv_funcional.txt`)

`flock /tmp/claude-1000/equiv.lock make equiv MODO=funcional`: traza de `sw/isa_test.s`
contra 116fa20, las dos estrategias. Secuencias de escrituras al banco (46), accesos al
bus (22) y salidas (2) idénticas. CPI de isa_test: 1,969 con EarlyRead (3.000 ciclos,
1.524 instrucciones) contra 2,953 en la referencia (1.016 instrucciones); con la
estrategia 2, 2,953 igual que la referencia.

### 3.3 `sw/hazard_test.s` y `make equiv PROG=hazard_test` (`docs/verificacion/hazard_test_y_mutaciones.txt`)

El Makefile de la rama agrega la variable `PROG` (por defecto `isa_test`):
`make equiv PROG=hazard_test REF=main MODO=funcional` corre `sw/hazard_test.s` con el RTL
de `main` y con el de la rama, para las dos estrategias. hazard_test tiene 56
comprobaciones (483 palabras), cada una compara un resultado con su valor esperado;
x14 cuenta las que pasan y x15 suma los resultados; al final escribe x14 a DISP (0x38,
"38" en el display) y 0xF a LEDS si pasaron todas. Resultado: `rf: 348 eventos
iguales`, `bus: 63 eventos iguales`, `io: 2 eventos iguales`, `secuencias de eventos
equivalentes` con las dos estrategias; la traza de salidas es `io led=0000
seg=1001111_1111111` (display 38) y luego `led=1111`. CPI de hazard_test: 1,769 en la
rama (2.999 ciclos, 1.695 instrucciones) contra 2,654 en `main`.

### 3.4 Prueba de mutación

Dos mutaciones bajo `ifdef`, activadas solo desde la línea de comandos (el RTL versionado
no las tiene activas; `grep -n MUTA rtl/ -r` muestra solo los `ifdef`):

- `MUTA_FWD` (RF): `fwd_a = fwd_b = 0`, sin write-through.
  `make equiv PROG=hazard_test REF=main MODO=funcional IVERILOG="iverilog -DMUTA_FWD"`:
  `DIFIEREN (rf) en el evento 6: ref='rf x5 = 0000000f' act='rf x5 = xxxxxxxx'`,
  `DIFIEREN (bus) en el evento 1`, `secuencias DISTINTAS`; el monitor de X cuenta 77
  valores desconocidos usados (rf_wdata 36, operandos ALU 41). Con isa_test:
  `DIFIEREN (rf) en el evento 5: ref='rf x4 = 00000001' act='rf x4 = 0000000X'`.
- `MUTA_LOADUSE` (ID): `rf_rd_en_o = ~stall_q` (stall registrado), de modo que la
  lectura de operandos de la instrucción que sigue a una carga ocurre un flanco antes
  del commit de la carga y no se repite en el flanco del commit.
  `make equiv PROG=hazard_test REF=main MODO=funcional IVERILOG="iverilog -DMUTA_LOADUSE"`:
  `DIFIEREN (rf) en el evento 84: ref='rf x5 = 00000002' act='rf x5 = 00000795'`,
  `DIFIEREN (bus) en el evento 24`, `DIFIEREN (io) en el evento 1` (el display muestra
  otro valor), `secuencias DISTINTAS`. Con isa_test: `DIFIEREN (bus) en el evento 10:
  ref='bus R be=0011 addr=00000130 wdata=56785678' act='... wdata=00010001'`.

Con la estrategia 2 (EarlyRead = 0) ninguna mutación cambia nada, lo que confirma que
ese camino no depende del write-through ni del enable de lectura.

### 3.5 Monitor de valores desconocidos usados

`tb/core_trace_tb.v` y `tb/game_tb.v` cuentan, en cada flanco: `rf_wdata` con bits X
cuando `rf_we`; `data_addr`, `data_be` o `data_wdata` (en escrituras) con X cuando
`data_req`; operandos de la ALU con X en un ciclo de commit en que su resultado se usa
(escritura del resultado de la ALU, dirección de la LSU, comparación de un salto o
destino de jalr); salidas (LEDs y segmentos) con X.

| simulación | resultado |
|---|---|
| game_tb, estrategia 1, 10 rondas | 0 valores desconocidos usados en 620.217 escrituras al banco |
| game_tb, estrategia 1, 4 rondas | 0 en 298.803 |
| game_tb, estrategia 2, 10 rondas | 0 en 388.411 |
| game_tb, estrategia 2, 4 rondas | 0 en 187.627 |
| core_trace_tb, isa_test, estrategia 1 | 0 en 1.502 |
| core_trace_tb, hazard_test, estrategia 1 | 0 en 1.588 |

La mutación MUTA_FWD hace que el monitor cuente 77 (sección 3.4), así que el monitor
detecta lo que debe.

### 3.6 `make post-synth` (`asic/sim/resultado.md`)

Netlist de la rama sintetizado por la cola con `asic/sim/config.yaml` de la rama
(`EarlyRead=1`, `DebounceDivBits=2`): `bash asic/encolar.sh build/exp_pipeline
asic/sim/config.yaml pa_sim_rom 100 --to Yosys.Synthesis`
(`asic/sim/runs/pa_sim_rom/06-yosys-synthesis/asic_top.nl.v`). Los estímulos se
recalibraron para la temporización nueva con `python3 asic/sim/calibrar.py --salida
asic/sim/estimulos.txt` (el LED objetivo de la ronda 1 se enciende en el ciclo 615 en vez
de 781; las pulsaciones quedan en 635, 1373 y 1733).

`make post-synth NETLIST_SIM=asic/sim/runs/pa_sim_rom/06-yosys-synthesis/asic_top.nl.v
-o asic/sim/runs/pa_sim_rom/06-yosys-synthesis/asic_top.nl.v` (la opción `-o` evita que
make relance LibreLane): PASS, trazas idénticas (17 cambios de salida en 4.500 ciclos, 0
X), el display muestra 51 ciclos medidos en las dos rondas correctas (57 en `main`: 20
ciclos hasta la pulsación, 2 del sincronizador, 12 a 15 del debounce y el resto del lazo
de polling, que ahora es más corto), EE en el ciclo 1405 y la ronda que no avanza.

Control negativo: con la temporización nueva el lazo de polling de BTN son 8 ciclos
(lw 2 + blt 1 + add 1 + j 2 + beq 2, o lw 2 + blt tomado 2 + add 1 + xor 1 + beq 2;
13 en `main`), así que el atraso mínimo que cambia la traza pasa de 6 a 8: con ATRASO
de 1 a 7 el netlist da la misma traza (PASS) y con 8 da 59 ciclos medidos en el ciclo
1089 (FAIL). El Makefile de la rama deja `ATRASO ?= 8` y `POLL_CICLOS ?= 8` y
`make post-synth-control` terminó bien (sección "Control negativo" de
`asic/sim/resultado.md`).

## 4. Corridas de LibreLane (cola `pa_*`, `asic/barrido_exp.md`)

Configuración: `asic/rom/config.yaml` de la rama (la de `main`, D20 y D21, más
`EarlyRead=1`), `FP_CORE_UTIL = 40`. Cierre según `asic/verificar_cierre.py`
(`asic/rom/resultados/pa_<tag>/cierre.md`): DRC de Magic 0, LVS 0, 0 nets de antena,
WNS >= 0 y TNS = 0 de setup y de hold en las 9 esquinas. Datos de
`asic/rom/resultados/pa_<tag>/metrics.json`; tabla completa en `asic/barrido_exp.md`.

| tag | T (ns) | cierra | setup WNS max_ss (ns) | hold WNS peor (ns) | área stdcell (µm²) | celdas | slew / cap | DRC / LVS / antena |
|---|---|---|---|---|---|---|---|---|
| pa_t100 | 100 | sí | 62,555 | 0,134 | 186.087 | 9.180 | 506 / 32 | 0 / 0 / 0 |
| pa_t40 | 40 | sí | 2,555 | 0,134 | 186.087 | 9.180 | 506 / 32 | 0 / 0 / 0 |
| pa_t32 | 32 | sí | 1,591 | 0,134 | 187.744 | 9.185 | 463 / 33 | 0 / 0 / 0 |
| pa_t26 | 26 | sí | 0,198 | 0,135 | 195.281 | 9.216 | 447 / 33 | 0 / 0 / 0 |
| pa_t25p5 | 25,5 | no (setup max_ss) | -0,302 (TNS -0,527) | 0,135 | 195.281 | 9.216 | 447 / 33 | 0 / 0 / 0 |
| pa_t25 | 25 | no (setup max_ss) | -0,802 (TNS -8,088) | 0,135 | 195.281 | 9.216 | 447 / 33 | 0 / 0 / 0 |
| pa_t24p5 | 24,5 | no (setup max_ss) | -1,302 (TNS -26,813) | 0,135 | 195.281 | 9.216 | 447 / 33 | 0 / 0 / 0 |

- A 100 ns cierra con 186.087 µm² de celdas estándar: +2,1 % contra `main` (182.265),
  dentro del límite de 105 % (191.378). Slew y capacitancia 506 / 32 (main 546 / 36).
- Período mínimo: 26 ns (38,5 MHz). 25,5 ns no cierra por 0,302 ns en
  `max_ss_125C_4v50` (las otras 8 esquinas cierran: `nom_ss` +0,836, típica +11,66);
  queda 0,5 ns entre el último período que cierra y el primero que no. Las corridas de
  26, 25,5, 25 y 24,5 ns tienen exactamente el mismo layout (9.216 celdas, 195.281 µm²,
  371.045 µm de cables, `route__wirelength` de `metrics.json`): con el margen de 10 ns
  de D20 el resizer llega a su límite en 26 ns y de ahí para abajo solo cambia el slack,
  1 ns por ns de período, igual que pasó en `main` entre 26 y 24 ns (`asic/final.md`).
- La corrida de 100 ns (`pa_t100`) y la de 40 ns tienen el mismo layout (9.180 celdas):
  a 40 ns todavía sobran 2,6 ns en la esquina lenta sin redimensionar nada.

### Ruta crítica a 26 ns (`asic/rom/resultados/pa_t26/max_ss_125C_4v50_ruta_critica.rpt`, `layout/ruta_critica.txt`)

`bash asic/layout/anotar.sh asic/rom/runs/pa_t26` (KLayout): startpoint `_4263_`
(`dffrnq_1`, el bit 2 del PC de la etapa IF, red `u_soc.g_mem_rom.u_mem.a_addr_i[2]`),
endpoint `u_soc.u_core.u_rf/_4133_` (`dffq_1`, el bit 3 del puerto de lectura B del
banco, `rdata_b_o[3]`, red `u_soc.data_wdata[3]`). Llegada 27,490 ns contra 27,689
requeridos (reloj 26 + 2,318 de latencia hasta el endpoint, -0,25 de incertidumbre,
+0,109 de pesimismo, -0,488 de setup): slack 0,198 ns. 25 celdas:

| tramo | celdas | desde | hasta | ns |
|---|---|---|---|---|
| reloj a Q del PC | 1 | 2,544 | 4,441 | 1,9 |
| ROM combinacional (`pochoco_rom`, lógica aplanada): buffers de fanout del bit del PC, inv, nand3, aoi21, oai21, and4, oai21 | 11 | 4,441 | 13,746 | 9,3 |
| `a_next_o[21]` (bit 1 de rs2) hasta el banco: buffer de capacitancia y dos buffers de fanout | 3 | 13,746 | 17,184 | 3,4 |
| decodificación de rs2 y mux 16:1 del puerto B dentro de `espino_register_file`: inversor, cuatro buffers de fanout, aoi21, aoi221, nor3, oai32 | 10 | 17,184 | 27,490 | 10,3 |

Es la ruta nueva de un ciclo que crea el diseño: la dirección del fetch pasa por la
ROM, elige el registro y atraviesa el mux de lectura antes del flanco en que se carga
la instrucción. De los 23 ns de lógica, 11,6 ns son buffers de fanout (`fanout*`,
`max_cap*`): el bit del PC alimenta toda la ROM y cada bit de rs2 alimenta 32 x 15
entradas de mux. En `main` la ruta crítica al período mínimo (24,5 ns; f1_t26, f1_t25 y
f1_t24p5 comparten layout y ruta: startpoint `_4189_`, endpoint
`u_soc.u_core.u_rf/_2933_`) era la del write-back de la carga
(ALU -> alineación -> banco); esa ruta ya no aparece entre las primeras porque la
instrucción que sigue a la carga lee el banco en el flanco del commit (write-through
sobre `wdata_i`, un mux2 más), y el decode sigue fuera de las rutas de ejecución.

Figuras: `asic/rom/resultados/pa_t26/layout/ruta_critica.png`, `bloques.png`, `slew.png`.


## 5. Variantes

Las dos variantes salen de `exp/pipeline` (worktrees `build/exp_pipeline_b5` y
`build/exp_pipeline_b2`, creados con `git worktree add -b <rama> <dir> exp/pipeline`).
Las dos pasan la verificación obligatoria completa y las dos se midieron a 100 ns y en su
período mínimo con la regla de 0,5 ns.

### 5.1 exp/pipeline-b5 (banco de latches de B5)

Cherry-pick de 792d410 y ef957ef de exp/rf-latch sobre exp/pipeline (commits 0876577 y
966a36b), con el write-through reimplementado sobre la salida registrada (el dato entra a
los latches en la fase alta siguiente al flanco, así que en el flanco del commit la
lectura del mismo registro toma `wdata_i`; una lectura en el flanco siguiente ya ve el
latch actualizado) y `rd_en_i` conservado; `LINTER_ERROR_ON_LATCH: false` en las dos
configs (`asic/rom/config.yaml` y `asic/sim/config.yaml`, regenerada con
`python3 asic/sim/generar_config.py`).

Verificación (commit 092ec33, `docs/verificacion/b5_*.txt`):

| paso | comando | resultado |
|---|---|---|
| assembler y seis testbenches | `make check` | PASS (80 pruebas del assembler, game_top_tb, game_tb 10 y 4 rondas, estrategias 1 y 2). CPI del juego 1,665 (estrategia 1, 10 rondas) y 2,665 (estrategia 2) |
| equivalencia funcional isa_test | `flock /tmp/claude-1000/equiv.lock make equiv MODO=funcional` | rf 46, bus 22, io 2 eventos iguales con las dos estrategias; CPI de isa_test 1,969 (referencia 2,953) |
| equivalencia funcional hazard_test | `make equiv PROG=hazard_test REF=main MODO=funcional` | rf 348, bus 63, io 2 eventos iguales con las dos estrategias; CPI 1,769 |
| monitor de X | game_tb completa y core_trace_tb | 0 valores desconocidos usados en 620.217 escrituras al banco (estrategia 1) y 388.411 (estrategia 2) |
| RTL contra netlist | `make post-synth` y `make post-synth-control` (28-10-2026, `docs/verificacion/b5_make_post_synth.txt`) | PASS: 17 cambios de salida idénticos, display 51, 0 valores X; control negativo con ATRASO = 8 da FAIL como corresponde. `asic/sim/resultado.md` regenerado queda idéntico al de exp/pipeline |

Corridas (`asic/barrido_exp.md`, `asic/rom/resultados/pa_b5_*/cierre.md` y `metrics.json`):

| tag | T (ns) | cierra | setup WNS max_ss (ns) | hold WNS peor (ns) | área stdcell (µm²) | celdas | slew / cap | DRC / LVS / antena |
|---|---|---|---|---|---|---|---|---|
| pa_b5_t100 | 100 | sí | 0,000 (préstamo de los latches) | 0,134 | 165.211 | 8.254 | 386 / 3 | 0 / 0 / 0 |
| pa_b5_t34 | 34 | sí | 0,000 (préstamo de los latches) | 0,136 | 165.700 | 8.255 | 386 / 3 | 0 / 0 / 0 |
| pa_b5_t32 | 32 | sí | 0,000 (préstamo de los latches) | 0,137 | 167.050 | 8.258 | 329 / 3 | 0 / 0 / 0 |
| pa_b5_t30 | 30 | sí | 0,000 (préstamo de los latches) | 0,119 | 170.589 | 8.262 | 300 / 4 | 0 / 0 / 0 |
| pa_b5_t29 | 29 | sí | 0,000 (préstamo de los latches) | 0,118 | 174.933 | 8.280 | 223 / 5 | 0 / 0 / 0 |
| pa_b5_t28 | 28 | incompleta: cortada a los 40 min en `OpenROAD.ResizerTimingPostCTS` (paso 37 de 76) | sin dato | sin dato | sin dato | sin dato | sin dato | sin dato |
| pa_b5_t26 | 26 | no (setup max_ss) | -7,102 (TNS -310,392) | 0,139 | 171.700 | 8.276 | 403 / 3 | 0 / 0 / 0 |
| pa_b5_t25 | 25 | no (setup max_ss) | -8,102 (TNS -374,392) | 0,139 | 171.700 | 8.276 | 403 / 3 | 0 / 0 / 0 |

- A 100 ns cierra con 165.211 µm² de celdas estándar: -9,4 % contra `main` (182.265) y
  -11,2 % contra `exp/pipeline` (186.087). Slew y capacitancia 386 / 3, mejor que `main`
  (546 / 36) y que `exp/pipeline` (506 / 32).
- Síntesis (`asic/rom/resultados/pa_b5_t100/sintesis_stat.rpt`): 130.930,509 µm² de
  celdas (contra 155.854,810 de `exp/pipeline`), banco de registros 55.628,563 µm²
  (contra 80.348,710: -30,8 %), con 480 `latq_1` (2,11E+04 µm²), 15 `icgtp_1` de clock
  gating y 96 `dffq_1` en los puertos de lectura. OJO con la columna "flip-flops" de
  `asic/barrido_exp.md`: `asic/recolectar.py` cuenta las celdas cuyo nombre contiene
  "dff" o "latch", y la celda de latch del PDK se llama `latq_1`, así que la tabla
  informa 514 flip-flops y NO suma los 480 latches; lo mismo pasa con el área secuencial
  que informa Yosys (34.752,211 µm², solo los flip-flops). Sumando los latches el área
  secuencial real es del orden de 55.900 µm² contra 63.272,250 de `exp/pipeline`.
- **El WNS de setup no sirve como medida de margen en esta variante.** Cuando la corrida
  cierra, `metrics.json` informa setup WNS = 0,000 y TNS = 0,000 EXACTOS en las nueve
  esquinas. La razón está en el reporte de la ruta crítica
  (`asic/rom/resultados/pa_b5_t100/max_ss_125C_4v50_ruta_critica.rpt`): el endpoint es el
  pin D de un latch (`u_soc.u_core.u_rf/g_reg[6].g_bit[2].u_lat.u_lat`, `latq_1`) y
  OpenSTA cierra la ruta con `time borrowed from endpoint 3,538487` (préstamo de tiempo
  de la fase transparente del latch), con lo que el slack queda `0.000000 slack (MET)`.
  Son 480 endpoints de latch, todos con slack 0,000 y préstamos de hasta 7,154 ns
  (`max.rpt` de `pa_b5_t29`, 1.185 rutas revisadas con un script sobre el reporte).
  Consecuencias prácticas:
  (1) el criterio de cierre (WNS >= 0 y TNS = 0 en las nueve esquinas) se cumple, pero el
  margen reportado es cero por construcción, no medido;
  (2) el margen real de las rutas entre flip-flops sí se puede leer del mismo reporte y es
  holgado: la ruta de mayor retardo de `pa_b5_t29` llega a 28,710 ns con 3,292 ns de slack
  (startpoint `_4305_`, el bit 2 del PC, red `u_soc.g_mem_rom.u_mem.a_addr_i[2]`; endpoint
  `u_soc.u_core.u_rf/_2385_`, `u_soc.u_core.rf_rdata_a[1]`), es decir la misma ruta
  PC -> ROM -> mux de lectura del banco que limita a A y a A+B2;
  (3) el resizer de OpenROAD recibe como peor endpoint un pin D de latch con slack 0,000 y
  gasta ahí sus iteraciones: en `asic/logs/pa_b5_t28.log` se ven más de 7.000 pasadas de
  `repair_timing` con `+0,1 %` de área y slack 0,000 sobre
  `u_soc.u_core.u_rf/g_reg[10].g_bit[0].u_lat.u_lat/D`, y esa corrida se quedó en
  `OpenROAD.ResizerTimingPostCTS` hasta el corte de 40 minutos de la cola. En las corridas
  que no cierran el efecto se ve claro: en `pa_b5_t26` la violación no está en un latch
  sino en una ruta normal entre flip-flops que el flujo dejó sin arreglar
  (`_4307_`, bit 4 del PC, a `u_soc.u_core.u_rf/_2426_`, `u_soc.u_core.lsu_wdata[10]`:
  llegada 36,238 ns contra 29,136 requeridos, slack -7,102);
  (4) el período mínimo hay que buscarlo corrida por corrida, porque el slack no permite
  extrapolar. Para el coordinador: la comparación de márgenes entre `main`, A y A+B2 (que
  informan slack real) y A+B5 no es homogénea, y el límite de 29 ns de A+B5 es un límite
  del flujo (el paso de resizer se va en los latches y se corta por tiempo), no un límite
  de la lógica, que a 29 ns todavía tiene 3,292 ns de sobra.
- Período mínimo 29 ns (34,5 MHz): 29 ns es el último período medido que cierra
  (`pa_b5_t29`) y 26 ns el primero que no (`pa_b5_t26`). La regla de la sesión de dejar
  0,5 ns o menos entre los dos NO queda cerrada en esta variante: `pa_b5_t28` se cortó a
  los 40 minutos en `OpenROAD.ResizerTimingPostCTS` sin llegar a `final/metrics.json`, así
  que 28 ns no está medido. El 28-10-2026 a las 07:45 se encoló `pa_b5_t28p5` (28,5 ns,
  número 99 de la cola) para cerrarla por arriba: si 28,5 ns no cierra, el par queda
  (29 cierra, 28,5 no) y la regla se cumple con período mínimo 29 ns; si cierra, el
  período mínimo baja a 28,5 ns y la regla sigue abierta por abajo mientras 28 ns no se
  pueda medir dentro del límite de 40 minutos. MIPS con el dato medido:
  (1000 / 29) / 1,665 = 20,71.

#### Ruta crítica a 29 ns (`asic/rom/resultados/pa_b5_t29/max_ss_125C_4v50_ruta_critica.rpt`, `layout/ruta_critica.txt`)

`bash asic/layout/anotar.sh asic/rom/runs/pa_b5_t29`: la ruta que OpenSTA informa como
peor es corta y no es la que manda el período. Son 4 celdas, todas dentro del banco:
startpoint `u_soc.u_core.u_rf/_2450_` (`dffq_1`, un bit del dato de escritura), dos
buffers de fanout (`fanout524`, `fanout523`) y endpoint
`u_soc.u_core.u_rf/g_reg[1].g_bit[2].u_lat.u_lat` (`latq_1`, el latch del bit 2 de x1).
Llegada 7,153 ns, de los cuales 3,600 son préstamo del latch: slack 0,000 (MET). La ruta
que de verdad fija el período es la de mayor retardo entre flip-flops (28,710 ns de
llegada, 3,292 ns de slack, PC -> ROM -> mux de lectura del puerto A -> `rf_rdata_a[1]`),
la misma familia que en A y A+B2. En el layout el banco ocupa 2.074 celdas y 61.334 µm²
(37,3 % del área), la ALU 632 celdas y 13.964 µm² (8,5 %). Figuras:
`asic/rom/resultados/pa_b5_t29/layout/ruta_critica.png`, `bloques.png`, `slew.png`.


### 5.2 exp/pipeline-b2 (offset de byte registrado de B2)

Cherry-pick de 7ff1d06 de exp/lsu-offset sobre exp/pipeline (commit 3b5b452): la LSU
guarda `addr_i[1:0]` en `boff_q` al emitir la carga y alinea el dato con ese registro, con
lo que la ALU sale de la ruta de alineación y write-back de la carga.

Verificación (commit be50893, `docs/verificacion/b2_*.txt`):

| paso | comando | resultado |
|---|---|---|
| assembler y seis testbenches | `make check` | PASS. CPI del juego 1,665 (estrategia 1) y 2,665 (estrategia 2), iguales a exp/pipeline |
| equivalencia funcional isa_test | `flock /tmp/claude-1000/equiv.lock make equiv MODO=funcional` | rf 46, bus 22, io 2 eventos iguales con las dos estrategias; CPI de isa_test 1,969 |
| equivalencia funcional hazard_test | `make equiv PROG=hazard_test REF=main MODO=funcional` | rf 348, bus 63, io 2 eventos iguales con las dos estrategias; CPI 1,769 |
| monitor de X | game_tb completa y core_trace_tb | 0 valores desconocidos usados en 620.217 escrituras al banco (estrategia 1) y 388.411 (estrategia 2) |
| RTL contra netlist | `make post-synth` y `make post-synth-control` (28-10-2026, `docs/verificacion/b2_make_post_synth.txt`) | PASS: 17 cambios de salida idénticos, display 51, 0 valores X; control negativo con ATRASO = 8 da FAIL como corresponde. `asic/sim/resultado.md` regenerado queda idéntico al de exp/pipeline |

Corridas (`asic/barrido_exp.md`, `asic/rom/resultados/pa_b2_*/cierre.md` y `metrics.json`):

| tag | T (ns) | cierra | setup WNS max_ss (ns) | hold WNS peor (ns) | área stdcell (µm²) | celdas | slew / cap | DRC / LVS / antena |
|---|---|---|---|---|---|---|---|---|
| pa_b2_t100 | 100 | sí | 63,191 | 0,134 | 186.432 | 9.224 | 571 / 37 | 0 / 0 / 0 |
| pa_b2_t26 | 26 | sí | 0,591 | 0,135 | 194.212 | 9.224 | 508 / 40 | 0 / 0 / 0 |
| pa_b2_t25p5 | 25,5 | sí | 0,091 | 0,135 | 194.212 | 9.224 | 508 / 40 | 0 / 0 / 0 |
| pa_b2_t25 | 25 | no (setup max_ss) | -0,409 (TNS -1,027) | 0,135 | 194.212 | 9.224 | 508 / 40 | 0 / 0 / 0 |

- A 100 ns cierra con 186.432 µm²: +2,3 % contra `main` (182.265), dentro del límite de
  105 % (191.378), y +0,2 % contra `exp/pipeline`. Slew y capacitancia 571 / 37 a 100 ns,
  peor que `exp/pipeline` (506 / 32) y que `main` en slew (546) aunque mejor en
  capacitancia (36).
- Período mínimo 25,5 ns (39,2 MHz): medio nanosegundo menos que `exp/pipeline`, con
  0,091 ns de slack en `max_ss_125C_4v50`; 25 ns no cierra por 0,409 ns. Queda 0,5 ns
  entre el último período que cierra y el primero que no, como pide la regla. Las
  corridas de 26, 25,5 y 25 ns tienen el mismo layout (9.224 celdas, 194.212 µm²,
  373.251 µm de cables).
- Síntesis: 156.098,477 µm², 964 flip-flops, banco de registros 80.348,710 µm² (igual que
  `exp/pipeline`); el costo de B2 son dos flip-flops más (el offset `boff_q`).

#### Ruta crítica a 25,5 ns (`asic/rom/resultados/pa_b2_t25p5/max_ss_125C_4v50_ruta_critica.rpt`, `layout/ruta_critica.txt`)

`bash asic/layout/anotar.sh asic/rom/runs/pa_b2_t25p5`: startpoint `_4288_`
(`dffrnq_2`, el bit 3 del PC de la etapa IF, red `u_soc.g_mem_rom.u_mem.a_addr_i[3]`),
endpoint `u_soc.u_core.u_rf/_4114_` (`dffq_1`, el bit 16 del puerto de lectura A del
banco, `u_soc.u_core.rf_rdata_a[16]` en
`asic/rom/runs/pa_b2_t25p5/final/nl/asic_top.nl.v`). Llegada 27,002 ns contra 27,093
requeridos (reloj 25,5 + 2,319 de latencia al endpoint, -0,25 de incertidumbre, +0,109 de
pesimismo, -0,585 de setup): slack 0,091 ns. 24 celdas, 3 de ellas del camino de reloj:

| tramo | celdas | desde | hasta | ns |
|---|---|---|---|---|
| reloj a Q del PC | 1 | 2,607 | 4,789 | 2,2 |
| ROM combinacional (`pochoco_rom`, lógica aplanada): dos buffers de fanout, inversor, buffer de fanout, nor2, nand2, oai22, nor3, nor2 | 9 | 4,789 | 14,111 | 9,3 |
| `a_next_o[17]` (bit 2 de rs1) hasta el banco: tres buffers de fanout | 3 | 14,111 | 17,016 | 2,9 |
| decodificación de rs1 y mux 16:1 del puerto A dentro de `espino_register_file`: inversor, dos buffers de fanout, nand2, tres buffers de fanout, aoi21, nor3, oai32 | 10 | 17,016 | 27,002 | 10,0 |

Es la misma ruta nueva que fija el período en `exp/pipeline` (PC -> ROM -> bit de rs ->
mux de lectura del banco), ahora por el puerto A y con medio nanosegundo menos de retardo:
B2 sirve justamente porque saca de la ruta de la carga la alineación con la ALU, que en
`exp/pipeline` era la segunda ruta más lenta. El límite sigue siendo ROM -> banco.

## 6. Comparación con main y entre las tres opciones del frente

`main` es la referencia de la sesión con el dato nuevo del frente D4: cierra a 24,5 ns
(`asic/rom/resultados/f1_t24p5/cierre.md`, WNS 0,496 ns en `max_ss_125C_4v50`) y 24 ns no
cierra por 0,004 ns, así que su período mínimo es 24,5 ns (40,8 MHz) y su MIPS es
(1000 / 24,5) / 2,665 = 15,32.

| | main | A (exp/pipeline) | A+B2 (exp/pipeline-b2) | A+B5 (exp/pipeline-b5) |
|---|---|---|---|---|
| ciclos por instrucción (aritmética / carga / salto tomado) | 2 / 3 / 3 | 1 / 2 / 2 | 1 / 2 / 2 | 1 / 2 / 2 |
| CPI isa_test (core_trace_tb) | 2,953 | 1,969 | 1,969 | 1,969 |
| CPI del juego (game_tb, 10 rondas) | 2,665 | 1,665 | 1,665 | 1,665 |
| período mínimo que cierra todo (ns) | 24,5 (f1_t24p5) | 26 (pa_t26) | 25,5 (pa_b2_t25p5) | 29 (pa_b5_t29) |
| primer período que no cierra (ns) | 24 (WNS -0,004) | 25,5 (WNS -0,302) | 25 (WNS -0,409) | 26 (WNS -7,102); 28 quedó incompleta |
| f máx (MHz) | 40,8 | 38,5 | 39,2 | 34,5 |
| **MIPS = f máx / CPI del juego** | **15,32** | **23,10** | **23,55** | **20,71** |
| área de celdas estándar a 100 ns (µm²) | 182.265 | 186.087 (+2,1 %) | 186.432 (+2,3 %) | 165.211 (-9,4 %) |
| área de celdas estándar al período mínimo (µm²) | 189.817 | 195.281 | 194.212 | 174.933 |
| celdas a 100 ns (`design__instance__count__stdcell`) | 8.670 | 9.180 | 9.224 | 8.254 |
| flip-flops (síntesis) | 990 | 962 | 964 | 514 más 480 latches `latq_1` y 15 `icgtp_1` |
| slew / cap a 100 ns | 546 / 36 | 506 / 32 | 571 / 37 | 386 / 3 |
| slew / cap al período mínimo | 532 / 36 | 447 / 33 | 508 / 40 | 223 / 5 |
| hold WNS peor a 100 ns (ns) | 0,178 | 0,134 | 0,134 | 0,134 |
| setup WNS en max_ss al período mínimo (ns) | 0,496 | 0,198 | 0,091 | 0,000 con préstamo de los latches (no es margen medido) |
| ruta crítica al período mínimo | write-back de la carga (ALU -> alineación -> banco) | PC -> ROM -> rs2 -> mux de lectura del puerto B -> registro de operando | PC -> ROM -> rs1 -> mux de lectura del puerto A -> registro de operando | la peor que informa OpenSTA está dentro del banco (registro de escritura -> latch, 4 celdas, slack 0,000 con préstamo); la de mayor retardo real es PC -> ROM -> mux de lectura del puerto A -> registro de operando, con 3,292 ns de slack |
| verificación | check PASS, equiv ciclo a ciclo | check PASS, equiv funcional (isa_test y hazard_test contra main), mutaciones detectadas, 0 X usados, post-synth PASS con control negativo | lo mismo | lo mismo |

Límites de la regla de selección: área de celdas estándar a 100 ns hasta 191.378 µm²
(105 % de main) y cierre completo a 100 ns y 40 %. Las tres opciones del frente cumplen
las dos cosas.

Lectura de la tabla:

- El cambio que paga es el del frente A: el CPI del juego baja 37,5 % (2,665 a 1,665)
  porque desaparece el ciclo de espera de operandos, y el período solo sube 1,5 ns
  (24,5 a 26). Resultado: 23,10 MIPS contra 15,32, un 51 % más, con 2,1 % más de área.
- B2 es el mejor de los tres en la métrica principal: 23,55 MIPS. Cuesta dos flip-flops y
  0,2 % de área contra A, y empeora slew y capacitancia (571 / 37 contra 506 / 32 a
  100 ns).
- B5 es el mejor en área (165.211 µm², -9,4 % contra main y -11,2 % contra A) y en slew y
  capacitancia (386 / 3 a 100 ns, 223 / 5 a 29 ns), pero es el peor en la métrica
  principal (20,71 MIPS). Dos advertencias para leer su fila (sección 5.1): su cierre se
  apoya en el préstamo de tiempo de los latches, con slack reportado 0,000 en los 480
  endpoints de latch, de modo que ese número no mide margen (el margen real de las rutas
  entre flip-flops a 29 ns es 3,292 ns); y su período mínimo de 29 ns es un límite del
  flujo, no de la lógica: el paso `OpenROAD.ResizerTimingPostCTS` se va iterando sobre los
  endpoints de latch y `pa_b5_t28` se cortó ahí a los 40 minutos, así que 28 ns no está
  medido y la regla de 0,5 ns queda abierta en esta variante (`pa_b5_t28p5` encolada).
  Dicho eso, la conclusión no cambia con el dato que falta: incluso si cerrara a 28 ns,
  B5 daría 21,45 MIPS, menos que A (23,10) y que A+B2 (23,55). Es la opción a elegir solo
  si el criterio cambia de rendimiento a área.
- Lo que limita a A y a A+B2 es la ruta nueva PC -> ROM -> bit de rs -> mux de lectura del
  banco: de los 22,2 ns que la ruta de A+B2 pasa en lógica (de 4,789 a 27,002 ns, sin
  contar el clk -> Q del PC), 2,9 ns son buffers de fanout entre la ROM y el banco y
  6,1 ns son buffers dentro del banco. Lo que bajaría el
  período no es la ALU ni la LSU, sino acortar esa ruta: registrar las direcciones rs1 y
  rs2 ya decodificadas (sacarlas del camino combinacional de la ROM) o reducir el fanout
  de los bits de rs en el banco (32 registros por 15 entradas de mux cada bit).

Recomendación del frente: **A+B2 (`exp/pipeline-b2`, 25,5 ns, 23,55 MIPS)** como
candidata, con A (`exp/pipeline`, 26 ns, 23,10 MIPS) como respaldo si se prefiere el
diseño con menos cambios respecto de main y mejores números de slew y capacitancia, y
A+B5 si el criterio pasa a ser el área.
