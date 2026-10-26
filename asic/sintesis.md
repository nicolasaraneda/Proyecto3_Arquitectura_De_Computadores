# Síntesis: área por módulo y celdas más usadas (sección 3.3)

Generado por `asic/analisis_sintesis.py` a partir de `asic/rom/runs/final` (corrida final) y `asic/rom/runs/h2_t100` (síntesis jerárquica). Áreas en µm² del liberty de la esquina típica que usa Yosys.

## Método

La corrida final sintetiza aplanando el diseño salvo tres módulos cuya jerarquía se conserva (`SYNTH_KEEP_HIERARCHY_MODULES`: register file, ALU y contador de ciclos, D12), así que su reporte solo separa esos tres bloques del resto. Para repartir el área y las celdas entre todos los módulos se corrió además la misma configuración con `SYNTH_HIERARCHY_MODE=keep` solo hasta `Yosys.Synthesis` (`librelane --dockerized --pdk gf180mcuD asic/rom/config.yaml -c SYNTH_HIERARCHY_MODE=keep --to Yosys.Synthesis --run-tag h2_t100`). Esa síntesis conserva todos los módulos y Yosys informa cada uno por separado (`reports/stat.json`). Las dos síntesis usan el mismo RTL, la misma configuración y las mismas celdas; difieren solo en que la aplanada optimiza a través de los bordes de módulo, por eso sus totales no son idénticos y la tabla final los compara.

## Área por módulo (síntesis jerárquica)

Área local: celdas del propio módulo. Área total: incluye sus submódulos. El porcentaje es sobre el área total del diseño en esta síntesis.

| módulo (instancia) | función | celdas locales | flip-flops locales | área local (µm²) | área total (µm²) | % del total |
|---|---|---|---|---|---|---|
| `asic_top` (top) | sincronizador de reset | 3 | 2 | 158 | 157.980 | 100.0 |
| &nbsp;&nbsp;`pochoco_soc` (u_soc) | decodificador de direcciones y mux de lectura del bus | 78 | 2 | 1.242 | 157.822 | 99.9 |
| &nbsp;&nbsp;&nbsp;&nbsp;`pochoco_periph` (u_soc.u_periph) | registros DISP, LEDS, BTN y lectura registrada | 236 | 52 | 6.667 | 14.409 | 9.1 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`debounce4` (u_soc.u_periph.u_debounce) | solo instancias | 0 | 0 | 0 | 3.800 | 2.4 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`debounce` x4 (u_soc.u_periph.u_debounce.g_btn[0..3].u_db (4 instancias)) | filtro de un botón (3 muestras) | 12 | 4 | 481 | 481 | 0.3 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`debounce_tick` (u_soc.u_periph.u_debounce.u_tick) | divisor del debounce (contador de 15 bits) | 55 | 15 | 1.877 | 1.877 | 1.2 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`pochoco_cycle_counter` (u_soc.u_periph.u_cycles) | contador de ciclos CYCLES (32 bits) | 114 | 32 | 3.943 | 3.943 | 2.5 |
| &nbsp;&nbsp;&nbsp;&nbsp;`espino_core` (u_soc.u_core) | solo instancias | 0 | 0 | 0 | 114.712 | 72.6 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`espino_if_stage` (u_soc.u_core.u_if) | fetch: PC, PC+4 y registro de PC de la etapa ID | 249 | 65 | 8.511 | 8.511 | 5.4 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`espino_controller` (u_soc.u_core.u_ctrl) | control de stall y salto | 5 | 0 | 70 | 70 | 0.0 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`espino_id_stage` (u_soc.u_core.u_id) | decode y ejecución: pre-decodificación registrada, muxes de operandos, salto y write-back | 729 | 83 | 17.647 | 29.765 | 18.8 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`espino_alu` (u_soc.u_core.u_id.u_alu) | ALU: suma, resta, lógica y comparaciones | 589 | 0 | 10.153 | 10.153 | 6.4 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`espino_decoder` (u_soc.u_core.u_id.u_decoder) | decodificador de instrucciones (combinacional) | 158 | 0 | 1.965 | 1.965 | 1.2 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`espino_load_store_unit` (u_soc.u_core.u_lsu) | LSU: alineación de bytes y medias palabras | 218 | 1 | 2.711 | 2.711 | 1.7 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`espino_register_file` (u_soc.u_core.u_rf) | banco de registros x1 a x15 con dos puertos de lectura registrados | 1845 | 544 | 73.656 | 73.656 | 46.6 |
| &nbsp;&nbsp;&nbsp;&nbsp;`pochoco_mem_rom` (u_soc.g_mem_rom.u_mem) | registro de instrucción y RAM de datos de 4 palabras | 480 | 192 | 20.009 | 27.458 | 17.4 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`pochoco_rom` (u_soc.g_mem_rom.u_mem.u_rom) | ROM combinacional del programa (generada por el assembler) | 439 | 0 | 7.448 | 7.448 | 4.7 |

Área total de celdas en la síntesis jerárquica: 157.980 µm²; en la corrida final (aplanada): 152.169 µm² (-3.7 %, la optimización a través de los bordes de módulo).

**Módulo que más área aporta:** `espino_register_file` (u_soc.u_core.u_rf), 73.656 µm², 46.6 % del total de la síntesis jerárquica; en la corrida final el módulo conservado `espino_register_file` mide 73.656 µm² (48.4 % de 152.169 µm²).

**Fracción del contador de ciclos (`u_soc.u_periph.u_cycles`):** 3.943 µm², 2.50 % de la síntesis jerárquica y 2.59 % de la corrida final (3.943 de 152.169 µm²). Son 32 flip-flops con reset (2.388 µm², 61 % del módulo) más el incrementador de 32 bits.

## Las 5 celdas más usadas de la corrida final

La corrida final tiene 5.118 celdas de 34 tipos. El desglose por módulo sale de la síntesis jerárquica (misma configuración), por eso su total puede diferir en algunas celdas del de la corrida final.

| # | celda | cantidad (final) | % de las celdas | cantidad (jerárquica) | qué la explica |
|---|---|---|---|---|---|
| 1 | `dffq_1` | 804 | 15.7 | 818 | flip-flop D sin reset. Los usa todo registro que no necesita valor de reset: el banco de registros (D4), la RAM de datos, el registro de instrucción y los registros de pre-decodificación. |
| 2 | `mux2_2` | 759 | 14.8 | 968 | multiplexor 2:1. La biblioteca no tiene flip-flops con enable, así que cada bit que se escribe bajo condición lleva un mux2 de retención delante del flip-flop; los demás forman los árboles de lectura del banco de registros y los muxes de operandos. |
| 3 | `nand2_1` | 758 | 14.8 | 623 | NAND de 2 entradas, la compuerta más chica de la biblioteca: ABC con la estrategia AREA mapea sobre ella la lógica aleatoria (ROM, decodificador, ALU, comparadores). |
| 4 | `oai21_1` | 309 | 6.0 | 222 | OR-AND-inversor: lógica aleatoria de la ROM, la ALU y el decodificador de direcciones. |
| 5 | `clkinv_1` | 284 | 5.5 | 307 | inversor chico; la síntesis lo usa como inversor de lógica común, no solo en el reloj. |

### 1. `dffq_1`: desglose por módulo

| módulo | cantidad | esperado desde el RTL | comentario |
|---|---|---|---|
| `espino_register_file` | 544 | 544 | 15 registros x 32 bits = 480 de almacenamiento + 2 puertos de lectura registrados x 32 = 64 (coincide) |
| `pochoco_mem_rom` | 192 | 192 | registro de instrucción a_rdata_o (32) + RAM de 4 x 32 (128) + b_rdata_o (32) (coincide) |
| `espino_id_stage` | 82 | 82 | pre-decodificación (D18): alu_operator 4 + alu_op_a_sel 2 + alu_op_b_sel 1 + imm_operand 32 + imm_target 32 + rf_we 1 + rf_wd_sel 2 + is_branch/is_jal/is_jalr 3 + lsu_req/lsu_we 2 + lsu_type 2 + lsu_sign 1 (coincide) |

Total esperado desde el RTL: 818; síntesis jerárquica: 818; corrida final: 804. La diferencia de 14 entre la jerárquica y la final son flip-flops que la síntesis aplanada elimina al propagar constantes a través de los bordes de módulo (por ejemplo, bits de inmediato que siempre valen 0).

### 2. `mux2_2`: desglose por módulo

| módulo | cantidad | esperado desde el RTL | comentario |
|---|---|---|---|
| `espino_register_file` | 622 | >= 480 | retención de los 480 bits de almacenamiento (regs[waddr] <= wdata solo si we_i); el resto son los árboles de lectura; quedan 142 muxes funcionales |
| `pochoco_mem_rom` | 160 | >= 160 | retención de los 128 bits de la RAM (escritura por byte) + 32 del registro de instrucción (carga solo si a_req_i); quedan 0 muxes funcionales |
| `espino_id_stage` | 116 | >= 82 | retención de los 82 registros de pre-decodificación (cargan solo si !ops_valid_q); el resto son los muxes de operandos, de write-back y de pc_target; quedan 34 muxes funcionales |
| `espino_if_stage` | 30 |  |  |
| `espino_load_store_unit` | 14 |  |  |
| `pochoco_periph` | 12 |  |  |
| `debounce` x4 | 12 |  |  |
| `pochoco_soc` | 1 |  |  |
| `pochoco_rom` | 1 |  |  |

### 3. `nand2_1`: desglose por módulo

| módulo | cantidad | esperado desde el RTL | comentario |
|---|---|---|---|
| `espino_alu` | 106 |  |  |
| `espino_load_store_unit` | 94 |  |  |
| `espino_register_file` | 88 |  |  |
| `espino_id_stage` | 85 |  |  |
| `pochoco_rom` | 74 |  |  |
| `pochoco_periph` | 72 |  |  |
| `espino_decoder` | 53 |  |  |
| `espino_if_stage` | 25 |  |  |
| `pochoco_mem_rom` | 13 |  |  |
| `pochoco_cycle_counter` | 6 |  |  |
| `debounce` x4 | 4 |  |  |
| `debounce_tick` | 2 |  |  |
| `pochoco_soc` | 1 |  |  |

### 4. `oai21_1`: desglose por módulo

| módulo | cantidad | esperado desde el RTL | comentario |
|---|---|---|---|
| `pochoco_rom` | 49 |  |  |
| `espino_alu` | 47 |  |  |
| `espino_id_stage` | 38 |  |  |
| `espino_register_file` | 32 |  |  |
| `espino_if_stage` | 18 |  |  |
| `espino_decoder` | 16 |  |  |
| `espino_load_store_unit` | 8 |  |  |
| `pochoco_periph` | 6 |  |  |
| `debounce` x4 | 4 |  |  |
| `pochoco_soc` | 2 |  |  |
| `espino_controller` | 2 |  |  |

### 5. `clkinv_1`: desglose por módulo

| módulo | cantidad | esperado desde el RTL | comentario |
|---|---|---|---|
| `espino_register_file` | 70 |  |  |
| `espino_alu` | 54 |  |  |
| `espino_id_stage` | 47 |  |  |
| `pochoco_soc` | 34 |  |  |
| `espino_decoder` | 20 |  |  |
| `pochoco_mem_rom` | 18 |  |  |
| `pochoco_rom` | 15 |  |  |
| `espino_load_store_unit` | 10 |  |  |
| `espino_if_stage` | 10 |  |  |
| `pochoco_cycle_counter` | 9 |  |  |
| `pochoco_periph` | 8 |  |  |
| `debounce_tick` | 6 |  |  |
| `debounce` x4 | 4 |  |  |
| `espino_controller` | 2 |  |  |

## Comparación con lo esperado antes de sintetizar

- Flip-flops: el RTL tiene 818 bits de registro sin reset y 186 con reset (1004 en total, contados módulo por módulo arriba). La síntesis jerárquica da 818 + 186 y la final 804 + 186 = 990.
- Se esperaba que el banco de registros dominara el área: 480 bits de almacenamiento más dos árboles de lectura de 15 a 1 por 32 bits, sin celdas de memoria en la biblioteca. Resultó el 47 % del área y concentra los flip-flops sin reset y los multiplexores.
- Se esperaba que los flip-flops fueran la celda más numerosa y los multiplexores la segunda, por los muxes de retención (un mux2 por bit escrito bajo condición). La tabla anterior lo confirma; la novedad es que `nand2_1` queda casi a la par de `mux2_2`: la ROM combinacional, el decodificador y la ALU se mapean sobre la compuerta más chica.
- El contador de ciclos es un bloque chico: 2.5 % del área, casi todo flip-flops con reset.

