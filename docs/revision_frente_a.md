# Revisión independiente del frente A (sesión del 27 y 28-10-2026)

Revisión de la rama `exp/pipeline` y de sus variantes `exp/pipeline-b2` y `exp/pipeline-b5` hecha
por un agente que no escribió ese código, con el encargo de intentar refutar que el core nuevo se
comporta igual que el de `main` en todo programa válido y que su verificación es suficiente. El
informe es el que entregó la revisión, sin editar salvo este encabezado. Los archivos de prueba
que agregó (`sw/hazard_review.s`, `sw/hazard_cycles.s`, `tb/revision_a_mutaciones.sh`) están en la
rama `exp/pipeline`.

# Revisión independiente del frente A (rama `exp/pipeline`), 28-10-2026

## Veredicto: APROBADA CON OBSERVACIONES

No encontré ningún error funcional. Reproduje por mi cuenta toda la verificación obligatoria, escribí un programa de riesgos propio con 48 comprobaciones nuevas y dos mutaciones propias, y verifiqué uno por uno los números del informe contra su archivo de origen: **todos cuadran**. Las observaciones son de integración, de método y de redacción, ninguna bloquea la candidatura de A ni de A+B2.

---

## 1. Lo que verifiqué del RTL (riesgo por riesgo, con archivo y línea)

Worktree `/home/nicolasaraneda/proyectos/Proyecto3_Arquitectura_De_Computadores/build/exp_pipeline`. No modifiqué ni un archivo del RTL de la rama (las mutaciones propias se aplicaron sobre copias en el scratchpad).

El argumento central que hace correcto el diseño, y que el informe menciona pero no enuncia como invariante, es este: `rf_we_o = rf_we_dec & instr_valid_i & ~stall_i` (`espino_id_stage.v:262` y `:272`) y `rf_rd_en_o = ~stall_i` (`:138`), de modo que **toda escritura al banco coincide con un flanco en que los puertos de lectura están habilitados**. El write-through no se puede saltar nunca. Verifiqué que no existe ningún camino que asserte `rf_we_o` con `rf_rd_en_o = 0`.

| riesgo | dónde se resuelve | prueba que lo cubre |
|---|---|---|
| escritura seguida de lectura (rs1 y rs2, inmediata y subsiguiente) | `espino_register_file.v:62` (`wr = we_i & (waddr_i != 4'd0)`), `:73-74` (`fwd_a/fwd_b`), `:79-80` | `hazard_test.s` sección 1; mi `hazard_review.s` R1 (c01 a c04, cadenas cruzadas) |
| carga seguida de uso | `espino_id_stage.v:138` (`rf_rd_en_o = advance`) más el write-through; la carga comete en su segundo ciclo (`espino_load_store_unit.v:45,53`) | `hazard_test.s` sección 3; `hazard_review.s` R3, R4, R5, R8, R13 |
| operandos retenidos durante el stall de la LSU (alineación por `addr_i[1:0]`) | `rf_rd_en_o = ~stall_i` y `dec_load = advance` (`:124`): ni los operandos ni `lsu_type/sign` cambian en el segundo ciclo | `hazard_review.s` R4 (sb/lb/lbu offsets 0 a 3) la detecta: mi mutación M4 la rompe y las pruebas la ven |
| jal/jalr seguido de uso del link | el link se escribe en el commit (flanco N+1) y el destino se carga en N+2 | `hazard_test.s` sección 5; `hazard_review.s` R6, R7, R12 |
| salto tomado, descarte de la lectura anticipada | `espino_if_stage.v:35` (`valid_d = ~pc_set_i`); `lsu_req_o` (`:249`), `rf_we_o` (`:272`) y `pc_set_o` (`espino_controller.v:28`) condicionados a `instr_valid_i` | `hazard_test.s` secciones 7 y 8; `hazard_review.s` R2, R8, R13 y el contador x12 de instrucciones descartadas (tiene que quedar en 0) |
| escrituras a x0 | doble exclusión: `wr` excluye `waddr_i == 0`, y el test `raddr == 0 ? 0` va **antes** del mux de bypass (`:79-80`) | `hazard_test.s` sección 6; `hazard_review.s` R11 (addi, lw y jal a x0 con lectura inmediata). Mi mutación M3 ataca justo esto |
| periférico con lectura registrada (BTN y CYCLES) | el mecanismo es el mismo que en main: `data_req` en el ciclo de ejecución, `rd_is_per` latcheado en `pochoco_soc.v:87`, dato en el ciclo siguiente, commit un flanco después | `hazard_review.s` R10 (BTN) y `hazard_cycles.s` (CYCLES, 5 comprobaciones) |
| reset, registros sin reset leídos antes de cargarse | los registros de decode y `rdata_a_o/rdata_b_o` no tienen reset, pero todo lo que los consume está condicionado a `instr_valid_i` (= 0 el primer ciclo) y `lsu_req_o = lsu_req_dec & instr_valid_i & ...` da 0 porque `X & 0 = 0`, así que la X no llega a `stall` | monitor de X: 0 usados en 620.217 escrituras al banco (game_tb 10 rondas) |
| estrategia 2 con la temporización antigua | `pochoco_soc.v:18`, `EarlyRead = (MemStrategy == 1) ? 1 : 0`; bloque `g_wait` (`espino_id_stage.v:140-153`) idéntico a main | con estrategia 2 las **cuatro** mutaciones son invisibles (trazas idénticas a main), lo que confirma que el camino viejo no se tocó |

---

## 2. Pruebas que corrí yo mismo y resultados exactos

Todo desde `build/exp_pipeline` con `export PATH=$HOME/herramientas/oss-cad-suite/bin:$PATH`. Salidas completas en `/tmp/claude-1000/-home-nicolasaraneda-proyectos-Proyecto3-Arquitectura-De-Computadores/510fd3a8-3937-480f-af8f-e65ada226b06/scratchpad/rev/`.

| prueba | comando | resultado |
|---|---|---|
| `make check` | `make check` | **PASS**, código 0. 80 tests del assembler OK; los seis testbenches PASS. **CPI del juego 1,665** (1.595.814 ciclos / 958.358 retiradas, estrategia 1) y **2,665** (1.599.759 / 600.218, estrategia 2). Monitor de X: 0 usados en 620.217 / 298.803 / 388.411 / 187.627 escrituras |
| equiv isa_test | `flock /tmp/claude-1000/equiv.lock make equiv MODO=funcional` | **equivalente** en las dos estrategias: rf 46, bus 22, io 2 eventos iguales. CPI isa_test: ref 2,953, act 1,969 |
| equiv hazard_test | `make equiv PROG=hazard_test REF=main MODO=funcional` | **equivalente** en las dos estrategias: rf 348, bus 63, io 2. Y comprobé que el programa **pasa sus 56 comprobaciones** en las dos versiones: `io led=1111 seg=1001111_1111111`, o sea DISP = 0x38 = 56, LEDS = 0xF |
| equiv `hazard_review` (mío, 48 comprobaciones) | `make equiv PROG=hazard_review REF=main MODO=funcional` | **equivalente** en las dos estrategias: rf 271, bus 66, io 2. DISP = 0x30 = 48, LEDS = 0xF en main y en la rama. 0 X usados |
| equiv `hazard_cycles` (mío, CYCLES) | `make equiv PROG=hazard_cycles REF=main MODO=funcional` | estrategia 1: `DIFIEREN (rf) en el evento 3: ref='rf x3 = 00000006' act='rf x3 = 00000003'` (**esperado**: el valor de CYCLES depende del ciclo), pero **bus 10 e io 2 iguales** y DISP = 0x05 = 5 de 5 comprobaciones, LEDS = 0xF en las dos versiones. Estrategia 2: todo idéntico |
| mutación `MUTA_FWD` (del frente) | `bash tb/revision_a_mutaciones.sh hazard_test . mfwd -DMUTA_FWD` | **detectada**, reproduce el informe al carácter: `DIFIEREN (rf) en el evento 6: ref='rf x5 = 0000000f' act='rf x5 = xxxxxxxx'`, `DIFIEREN (bus) en el evento 1`, monitor de X: **77** usados (rf_wdata 36, ALU 41). Con `hazard_review`: 63 X usados, io 0 de 2 |
| mutación `MUTA_LOADUSE` (del frente) | idem con `-DMUTA_LOADUSE` | **detectada**, también al carácter: `DIFIEREN (rf) en el evento 84: ref='rf x5 = 00000002' act='rf x5 = 00000795'`, `DIFIEREN (io) en el evento 1`. Con `hazard_review`: 713 X usados |
| **mutación propia M3**: el bypass no excluye x0 (`wr_fwd = we_i` y el mux de bypass antes del test `raddr == 0`) | copia mutada de `espino_register_file.v` | **detectada** por `hazard_test` (DISP 0x35 = 53 de 56, LEDS 0101) y por `hazard_review` (DISP 0x2A… tras ampliarlo, `io act: seg=1011011_0111001`, LEDS 1100), `DIFIEREN (rf) en el evento 225: ref='rf x5 = 00000000' act='rf x5 = 000000f6'`. **No la detecta `isa_test`** (trazas idénticas) |
| **mutación propia M4**: `rf_rd_en_o = 1'b1` en `g_early` (el banco relee durante el stall, la LSU alinea el dato con la dirección de la instrucción siguiente) | copia mutada de `espino_id_stage.v` | **detectada** por `hazard_test` (DISP 0x30 = 48 de 56) y por `hazard_review` (`DIFIEREN (rf) en el evento 97: ref='rf x5 = 0000beef' act='rf x5 = 0000XXXx'`, 70 X usados). **No la detecta `isa_test`** |
| mis tres programas contra el RTL de **b2 y b5** | `bash tb/revision_a_mutaciones.sh <prog> ../exp_pipeline_b{2,5} ...` | **equivalentes a main** en las dos estrategias para las dos sub-ramas (hazard_review rf 271/bus 66/io 2; hazard_test rf 348/bus 63/io 2; hazard_cycles igual que arriba). Las variantes también pasan mis 48 + 5 comprobaciones |

Caso mínimo que reproduce M3 (para que quede escrito): `addi x3, x0, 0x55` / `sw x3, 0(x8)` / `lw x0, 0(x8)` / `add x5, x0, x0`; con la exclusión de x0 fuera del bypass, x5 queda en 0x55 en vez de 0.

---

## 3. Números del informe contra su archivo de origen

Revisé **todos** los números de las dos tablas. Cuadran sin excepción.

- `pa_t26`: WNS max_ss **0,198** (`asic/rom/resultados/pa_t26/cierre.md`, y `slack (MET) 0.198481` al final del `.rpt`), hold 0,135, área **195.281**, slew/cap **447 / 33**, 9.216 celdas. Startpoint `_4263_` (dffrnq_1) saliendo a `u_soc.g_mem_rom.u_mem.a_addr_i[2]`, endpoint `u_soc.u_core.u_rf/_4133_`, que en el netlist es **`.Q(rdata_b_o[3])`** (lo resolví en `asic/rom/runs/pa_t26/06-yosys-synthesis/asic_top.nl.v`, módulo `espino_register_file`). La ruta pasa por `u_soc.g_mem_rom.u_mem.a_next_o[21]` (celda 12 de 25 en `resultados/pa_t26/layout/ruta_critica.txt`): confirma que la ruta crítica nueva es exactamente la que crea EarlyRead.
- `pa_t100` / `pa_t40` 186.087; `pa_t32` 187.744; `pa_t25p5` -0,302; `pa_t25` -0,802; `pa_t24p5` -1,302. Todos OK.
- `pa_b2_t100` 186.432 (571/37); `pa_b2_t25p5` WNS **0,091**, área 194.212, 508/40, endpoint `_4114_` = **`rdata_a_o[16]`**, startpoint `_4288_` (dffrnq_2) a `a_addr_i[3]`; `pa_b2_t25` -0,409 (TNS -1,027). OK.
- `pa_b5_*`: t100 165.211 / 386/3; t34 165.700; t32 167.050; t30 170.589; **t29 cierra** con 174.933 y 223/5; t26 -7,102 (TNS -310,392); t25 -8,102. OK. `pa_b5_t28` **sin `final/`** (incompleta, confirmado), cortada en `OpenROAD.ResizerTimingPostCTS` (`asic/logs/cola_estado.txt`, 07:41:10, "detenida a los 40 min").
- Secuenciales de síntesis: main **990** (804 dffq_1 + 186 dffrnq_1), A **962**, A+B2 **964**, A+B5 **514** FF + **480 latq_1** + **15 icgtp_1**. Exacto.
- main: `f1_t24p5` **CIERRA** con WNS 0,496 y hold 0,178; `f1_t24` **NO CIERRA** por -0,004; área 182.265 a 100 ns y 189.817 al mínimo; slew/cap 546/36 y 532/36. El límite de área 191.378 = 1,05 x 182.265. OK.
- `EarlyRead=1` está de verdad en la síntesis: `asic/rom/config.yaml:14` y `resolved.json` de `pa_t26` y `pa_t100` traen `SYNTH_PARAMETERS = ['MemStrategy=1','DataWords=4','EarlyRead=1']`. Las cifras de temporización son del core nuevo, no del viejo.
- post-synth: `docs/verificacion/make_post_synth.txt`, `b2_make_post_synth.txt` y `b5_make_post_synth.txt` tienen **PASS** en la línea 71 (17 cambios de salida, 0 X, display 51 en las dos rondas) y **FAIL** en la 93, que es el control negativo con `ATRASO=8` y es lo que corresponde. `asic/sim/resultado.md` tiene el mismo md5 (`9359e9be…`) en los tres worktrees, como dice el informe.
- Commits y push: `exp/pipeline` 011cd0e, `exp/pipeline-b2` 58d32de, `exp/pipeline-b5` fd10cc4, los tres iguales en `origin`. `docs/pipeline.md` con md5 `eb9cc10f…` idéntico en las tres ramas.

**MIPS recalculados** (= (1000 / T_min) / CPI_juego): main (1000/24,5)/2,665 = **15,32**; A (1000/26)/1,665 = **23,10**; A+B2 (1000/25,5)/1,665 = **23,55**; A+B5 (1000/29)/1,665 = **20,71**. Idénticos al informe. El CPI del juego 1,665 lo medí yo en mi propio `make check`.

**Verificación independiente del hallazgo de b5.** En `asic/rom/runs/pa_b5_t29/55-openroad-stapostpnr/max_ss_125C_4v50/max.rpt` conté **1.185 rutas: 480 con endpoint de latch y préstamo de tiempo** (`time borrowed from endpoint 3.600442`, `0.000000 slack (MET)`) y **705 entre flip-flops**, cuya peor es `_4305_` (= `a_addr_i[2]`, bit 2 del PC) a `u_soc.u_core.u_rf/_2385_` (= `rdata_a_o[1]`) con slack **+3,2919 ns**. El hallazgo del frente es correcto y está bien medido. También confirmé que las seis corridas de b5 que cierran informan WNS y TNS de setup **0,000 exactos**, que es la firma del préstamo.

---

## 4. Observaciones, por gravedad

### O1. Integración: la rama está dos días atrás de main y el `Makefile` choca (media)

`git merge-base main exp/pipeline` = `50f8a39`; desde ahí main avanzó **290 archivos**. El único archivo tocado por los dos lados es el `Makefile`: `git merge-tree 50f8a39 main exp/pipeline-b2` informa `changed in both: Makefile`. La versión de la rama **elimina** lo que main agregó después (`post-pnr-cvc`, la regla de `asic/sim/config_pnr.yaml`, la invocación de `asic/sim/cvc_sdf.sh`) y reescribe `post-pnr-sdf` a una forma anterior. Además main cambió `tb/post_synth_tb.v` (+43/-9) y la rama no, así que el `make post-synth` PASS del frente se obtuvo con el testbench viejo.

Acción para el coordinador: antes de adoptar la rama, mezclar el `Makefile` a mano (quedarse con el de main y agregarle `PROG`, `ATRASO ?= 8` y `POLL_CICLOS ?= 8`) y **volver a correr `make check` y `make post-synth`** con `tb/post_synth_tb.v` de main.

### O2. A+B5 no está verificada al mismo nivel que main, A y A+B2 (media)

Además del préstamo de tiempo que el frente ya documentó bien, agrego algo que el informe no dice: el banco de latches de b5 (`rtl/gf180_cells.v`, `always_latch` fuera de síntesis) solo se validó con `make post-synth`, que es una comparación **sin retardos**. Una ventana de transparencia de latch no se puede ver en simulación de retardo cero, y b5 nunca pasó por la simulación post-PnR con SDF que main sí tiene (`asic/sim/resultado_sdf.md`, cuatro esquinas y dos simuladores). Si A+B5 llegara a presentarse, hay que decir las dos cosas: que su cierre de setup se apoya en préstamo y que su banco de latches no tiene verificación con retardos anotados.

### O3. `illegal_insn_o` queda desfasado una instrucción con EarlyRead (baja)

`espino_id_stage.v:105` y `:178`: el decodificador trabaja sobre `dec_instr = instr_next_i`, así que `illegal_insn_o` es combinacional **de la instrucción siguiente**, no de la actual. Hoy es inocuo porque `illegal_insn` se declara en `espino_core.v:56`, se conecta en `:97` y **no se usa en ninguna parte** (no hay trap). Pero el informe no lo menciona y, si alguien agregara un trap, la señal apuntaría a la instrucción equivocada. Debería registrarse junto con el resto del decode, o al menos comentarse en el RTL.

### O4. Tres cifras del informe que no reproducen (baja, ninguna cambia la recomendación)

1. `docs/pipeline.md` tiene **529** líneas, no 526 (el md5 sí es idéntico en los tres worktrees, como dice).
2. Recomendación 4: "2,9 ns son buffers de fanout entre la ROM y el banco y 6,1 ns son buffers dentro del banco". Recalculando con la columna Delay de `build/exp_pipeline_b2/asic/rom/resultados/pa_b2_t25p5/max_ss_125C_4v50_ruta_critica.rpt` me dan **2,18 ns** de buffers fuera de `u_rf` y **9,02 ns** dentro de `u_rf`, sobre 22,213 ns de lógica (los 22,2 ns sí cuadran: llegada 27,001841 menos 4,789268 en el pin Q del startpoint). La conclusión se sostiene (cerca de la mitad de la ruta es bufferizado, y el camino para bajar de 25,5 ns es el fanout de los bits de rs), pero esos dos números no deberían citarse como medidos.
3. En b5, `_2426_` es `rdata_b_o[10]` del banco; llamarlo `lsu_wdata[10]` describe bien su función (`lsu_wdata_o = rf_rdata_b_i`, `espino_id_stage.v:254`) pero ese mismo registro es también `operand_b`.

### O5. `hazard_test` no es un extra, es verificación que sostiene la rama (baja, pero importante decirla)

Dos datos que conviene que el coordinador tenga a mano para la defensa: el juego **nunca toca la RAM de datos** (`make check`: "uso de memoria: 0 lecturas y 0 escrituras de datos"), y `make equiv` con `isa_test` **no detecta ninguna de mis dos mutaciones** (trazas idénticas). Las dos las detectan `hazard_test` y `hazard_review`. Es decir: sin esos programas, la verificación obligatoria de la rama tendría un hueco justo en el riesgo que el diseño introduce.

### O6. `tb/comparar_trazas.py` en modo funcional puede dar un PASS vacío (baja)

Compara solo hasta `n = min(len(ref), len(act))` por tipo de evento (líneas 48-57), así que una versión que produjera **menos** eventos pasaría sin que se note. Acá no es un problema (los conteos son iguales y las dos versiones llegan a la escritura final de DISP y LEDS, que verifiqué una por una), pero le falta el control de largo que el modo `ciclo` sí tiene.

### O7. Estado de la corrida pendiente (informativo)

`pa_b5_t28p5` seguía corriendo cuando terminé: `asic/logs/cola_estado.txt` dice "2026-10-28 08:01:05 99 pa_b5_t28p5 lanzada" y a las 08:08 no había `final/metrics.json`. Consistente con el informe. La regla de 0,5 ns queda **cerrada** para A (26 cierra, 25,5 no) y para A+B2 (25,5 cierra, 25 no), y **abierta** para A+B5 (29 cierra, 28 incompleta, 26 falla por -7,102 ns).

---

## 5. Archivos que agregué y commit

Commit propio en `exp/pipeline`: **`4fdf9e7`** "Revisión independiente del frente A: sw/hazard_review.s (48 comprobaciones de riesgos que hazard_test.s no cubría), sw/hazard_cycles.s (CYCLES con uso inmediato) y tb/revision_a_mutaciones.sh (arnés para comparar contra main y para las mutaciones propias)", empujado (`origin/exp/pipeline` = `4fdf9e7`). No toqué el RTL, el `Makefile` ni ningún resultado existente; `PROGRESO_A.md` y `NOTA_COORDINADOR.md` siguen sin commit.

- `/home/nicolasaraneda/proyectos/Proyecto3_Arquitectura_De_Computadores/build/exp_pipeline/sw/hazard_review.s` (389 palabras): 48 comprobaciones, 13 secciones. Cadenas rs1/rs2 cruzadas; dependencia a dos instrucciones a través de un salto tomado hacia adelante y hacia atrás; carga cuyo destino es la base de la carga siguiente y carga cuyo rd es su propia base; carga seguida de store del dato cargado con `sb` en los offsets 0 a 3 y `sh` en las dos mitades, releído con lb/lbu/lh/lhu/lw; `lb`/`lh` negativos seguidos de `slt`/`sltu` como rs1 y como rs2; `jalr` con base recién cargada de memoria y con base recién escrita; `jal` a la instrucción siguiente; saltos condicionales con los operandos escritos una y dos instrucciones antes y con operando recién cargado (`beq`, `bne`, `bge`, `bgeu`); `auipc` y `lui` con uso inmediato; BTN con uso inmediato como operando, como operando de salto y como dato de store; escrituras a x0 con `addi`, `lw` y `jal` seguidas de lecturas de x0. Lleva un contador x12 de instrucciones descartadas que alcanzaron a ejecutarse, que tiene que quedar en 0.
- `.../sw/hazard_cycles.s` (34 palabras): 5 comprobaciones de lectura de CYCLES con uso inmediato, escritas para que su valor de verdad no dependa del ciclo. Va aparte a propósito: el valor leído sí depende del ciclo, así que las escrituras al banco no son comparables con main, pero el bus y las salidas sí.
- `.../tb/revision_a_mutaciones.sh`: arnés que compara la traza funcional del RTL de main contra otro árbol de RTL (la rama, otra rama, o una copia mutada), para que las mutaciones sean reproducibles sin tocar el RTL versionado. El encabezado documenta las dos mutaciones propias.

## 6. Qué recomiendo al coordinador

1. **Aprobar A+B2 (`exp/pipeline-b2`, 58d32de) como candidata y A (`exp/pipeline`, ahora 4fdf9e7) como respaldo**, como propone el frente. La diferencia de 0,45 MIPS contra la ventaja de A en slew y capacitancia (506/32 contra 571/37 a 100 ns) es un desempate legítimo y el informe lo plantea bien.
2. **Antes de adoptarla, rebasar la rama sobre main y volver a correr `make check` y `make post-synth`** (O1). Es el único trabajo que falta de verdad.
3. **Si se presenta A+B5, decir las dos limitaciones**, no solo la del préstamo de tiempo (O2).
4. Considerar llevar `sw/hazard_review.s` y `sw/hazard_cycles.s` a la rama que finalmente se adopte: ya comprobé que las dos sub-ramas los pasan y que son equivalentes a main con las dos estrategias de memoria.
5. Dos arreglos de una línea que no son de ningún frente y que el informe ya pide: `mkdir -p` en `asic/verificar_cierre.py` antes de escribir el `--md`, y el `LIBRELANE` con `--docker-no-tty --dockerized` en el `Makefile` de main.
