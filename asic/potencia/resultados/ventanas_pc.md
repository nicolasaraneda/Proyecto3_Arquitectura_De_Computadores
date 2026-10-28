# Histograma del PC por ventana (RTL, asic/potencia/potencia_tb.v con -DRTL)

Ciclos en los que `u_soc.u_core.u_if.pc_q` (la direccion que busca la etapa IF) vale cada direccion, dentro de la ventana [ini, fin). Las instrucciones son las de `rtl/gen/pochoco_rom.v` (sw/game.s ensamblado). Una direccion que aparece pocas veces justo despues de un salto es la busqueda especulativa de PC+4 que el salto descarta. Fuente: `resultados/pc_<ventana>.txt`.

## polling [500, 20500): polling de botones, pantalla de inicio (20000 ciclos)

| PC | Instruccion | Ciclos | % |
|---|---|---|---|
| 0x0024 | `lw x9, 8(x2)` | 5000 | 25.0 |
| 0x0028 | `beq x9, x0, L0024` | 10000 | 50.0 |
| 0x002c | `lw x3, 12(x2)` | 5000 | 25.0 |

## espera [265000, 285000): espera de 3 s de la ronda (wt_wait_loop) (20000 ciclos)

| PC | Instruccion | Ciclos | % |
|---|---|---|---|
| 0x01bc | `lw x13, 12(x2)` | 4000 | 20.0 |
| 0x01c0 | `sub x14, x13, x9` | 8000 | 40.0 |
| 0x01c4 | `bltu x14, x11, L01bc` | 4000 | 20.0 |
| 0x01c8 | `jalr x0, 0(x1)` | 4000 | 20.0 |

## display [261172, 263172): 2000 ciclos alrededor del 01 en el display (2000 ciclos)

| PC | Instruccion | Ciclos | % |
|---|---|---|---|
| 0x0038 | `lw x9, 8(x2)` | 244 | 12.2 |
| 0x003c | `bne x9, x0, L0038` | 488 | 24.4 |
| 0x0040 | `addi x9, x0, 15` | 245 | 12.2 |
| 0x0044 | `sw x9, 4(x2)` | 1 | 0.1 |
| 0x0048 | `addi x10, x5, 1` | 1 | 0.1 |
| 0x004c | `jal x1, L0170` | 1 | 0.1 |
| 0x0050 | `addi x10, x0, 30` | 2 | 0.1 |
| 0x0054 | `jal x1, L0198` | 1 | 0.1 |
| 0x0058 | `lw x9, 8(x2)` | 1 | 0.1 |
| 0x0120 | `addi x9, x0, 0` | 1 | 0.1 |
| 0x0124 | `beq x12, x0, L0138` | 1 | 0.1 |
| 0x0128 | `bltu x10, x12, L0138` | 1 | 0.1 |
| 0x012c | `sub x10, x10, x12` | 1 | 0.1 |
| 0x0138 | `addi x11, x10, 0` | 1 | 0.1 |
| 0x013c | `addi x10, x9, 0` | 1 | 0.1 |
| 0x0140 | `jalr x0, 0(x15)` | 1 | 0.1 |
| 0x0144 | `addi x9, x0, 0` | 1 | 0.1 |
| 0x0170 | `addi x12, x0, 10` | 1 | 0.1 |
| 0x0174 | `jal x15, L0120` | 1 | 0.1 |
| 0x0178 | `addi x9, x10, 0` | 2 | 0.1 |
| 0x017c | `add x9, x9, x9` | 1 | 0.1 |
| 0x0180 | `add x9, x9, x9` | 1 | 0.1 |
| 0x0184 | `add x9, x9, x9` | 1 | 0.1 |
| 0x0188 | `add x9, x9, x9` | 1 | 0.1 |
| 0x018c | `add x9, x9, x11` | 1 | 0.1 |
| 0x0190 | `sw x9, 0(x2)` | 1 | 0.1 |
| 0x0194 | `jalr x0, 0(x1)` | 1 | 0.1 |
| 0x0198 | `addi x11, x0, 0` | 2 | 0.1 |
| 0x019c | `lui x12, 0xf4` | 1 | 0.1 |
| 0x01a0 | `addi x12, x12, 576` | 1 | 0.1 |
| 0x01a4 | `addi x13, x10, 0` | 1 | 0.1 |
| 0x01a8 | `beq x13, x0, L01b8` | 31 | 1.6 |
| 0x01ac | `add x11, x11, x12` | 31 | 1.6 |
| 0x01b0 | `addi x13, x13, -1` | 30 | 1.5 |
| 0x01b4 | `jal x0, L01a8` | 30 | 1.5 |
| 0x01b8 | `lw x9, 12(x2)` | 31 | 1.6 |
| 0x01bc | `lw x13, 12(x2)` | 169 | 8.4 |
| 0x01c0 | `sub x14, x13, x9` | 336 | 16.8 |
| 0x01c4 | `bltu x14, x11, L01bc` | 167 | 8.3 |
| 0x01c8 | `jalr x0, 0(x1)` | 167 | 8.3 |

## rafaga [262151, 262491): solo la rafaga round_begin + show_bcd + wait_tenths (340 ciclos)

| PC | Instruccion | Ciclos | % |
|---|---|---|---|
| 0x004c | `jal x1, L0170` | 1 | 0.3 |
| 0x0050 | `addi x10, x0, 30` | 2 | 0.6 |
| 0x0054 | `jal x1, L0198` | 1 | 0.3 |
| 0x0058 | `lw x9, 8(x2)` | 1 | 0.3 |
| 0x0120 | `addi x9, x0, 0` | 1 | 0.3 |
| 0x0124 | `beq x12, x0, L0138` | 1 | 0.3 |
| 0x0128 | `bltu x10, x12, L0138` | 1 | 0.3 |
| 0x012c | `sub x10, x10, x12` | 1 | 0.3 |
| 0x0138 | `addi x11, x10, 0` | 1 | 0.3 |
| 0x013c | `addi x10, x9, 0` | 1 | 0.3 |
| 0x0140 | `jalr x0, 0(x15)` | 1 | 0.3 |
| 0x0144 | `addi x9, x0, 0` | 1 | 0.3 |
| 0x0170 | `addi x12, x0, 10` | 1 | 0.3 |
| 0x0174 | `jal x15, L0120` | 1 | 0.3 |
| 0x0178 | `addi x9, x10, 0` | 2 | 0.6 |
| 0x017c | `add x9, x9, x9` | 1 | 0.3 |
| 0x0180 | `add x9, x9, x9` | 1 | 0.3 |
| 0x0184 | `add x9, x9, x9` | 1 | 0.3 |
| 0x0188 | `add x9, x9, x9` | 1 | 0.3 |
| 0x018c | `add x9, x9, x11` | 1 | 0.3 |
| 0x0190 | `sw x9, 0(x2)` | 1 | 0.3 |
| 0x0194 | `jalr x0, 0(x1)` | 1 | 0.3 |
| 0x0198 | `addi x11, x0, 0` | 2 | 0.6 |
| 0x019c | `lui x12, 0xf4` | 1 | 0.3 |
| 0x01a0 | `addi x12, x12, 576` | 1 | 0.3 |
| 0x01a4 | `addi x13, x10, 0` | 1 | 0.3 |
| 0x01a8 | `beq x13, x0, L01b8` | 31 | 9.1 |
| 0x01ac | `add x11, x11, x12` | 31 | 9.1 |
| 0x01b0 | `addi x13, x13, -1` | 30 | 8.8 |
| 0x01b4 | `jal x0, L01a8` | 30 | 8.8 |
| 0x01b8 | `lw x9, 12(x2)` | 31 | 9.1 |
| 0x01bc | `lw x13, 12(x2)` | 33 | 9.7 |
| 0x01c0 | `sub x14, x13, x9` | 63 | 18.5 |
| 0x01c4 | `bltu x14, x11, L01bc` | 31 | 9.1 |
| 0x01c8 | `jalr x0, 0(x1)` | 31 | 9.1 |
