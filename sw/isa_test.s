# =============================================================================
# isa_test.s -- Programa de prueba del Espino Core (Proyecto 3)
#
# No es parte del juego. Ejecuta todas las instrucciones que soporta el
# assembler (menos los shifts, que la ALU no implementa), con operandos
# positivos y negativos, cargas y almacenamientos de byte, media palabra y
# palabra, saltos tomados y no tomados, llamadas y retornos. Lo usa
# tb/core_trace_tb.v para comparar dos versiones del core ciclo a ciclo
# (docs/decisiones.md, D18): si el cambio de RTL no altera el
# comportamiento, la traza de escrituras al banco de registros y de accesos
# al bus de datos es idéntica.
#
# La zona de datos empieza justo después del programa (etiqueta "datos"),
# que es donde la estrategia 2 pone sus DataWords palabras de datos; la
# estrategia 1 usa la dirección módulo DataWords, así que también funciona.
# Se usan 4 palabras (16 bytes).
# =============================================================================

.equ PERIPH_HI, 0x80000
.equ OFF_DISP,  0
.equ OFF_LEDS,  4

_start:
    lui   x2, PERIPH_HI          # base de periféricos
    la    x8, datos              # base de la zona de datos

    # --- aritmética y lógica con inmediato ---
    addi  x1, x0, 5
    addi  x3, x0, -7
    slti  x4, x3, 3              # -7 < 3 con signo -> 1
    sltiu x5, x3, 3              # 0xFFFFFFF9 < 3 sin signo -> 0
    xori  x6, x1, -1             # not 5
    ori   x7, x3, 0x0F0
    andi  x9, x3, 0x7F0

    # --- registro a registro ---
    add   x10, x1, x3            # -2
    sub   x11, x1, x3            # 12
    slt   x12, x3, x1            # 1
    sltu  x13, x3, x1            # 0
    xor   x14, x1, x3
    or    x15, x1, x3
    and   x10, x10, x11

    # --- superior ---
    lui   x11, 0xABCDE
    auipc x12, 0x12
    li    x13, 0x12345678
    li    x14, -2048

    # --- almacenamientos y cargas ---
    sw    x13, 0(x8)
    sh    x3, 4(x8)
    sh    x1, 6(x8)
    sb    x3, 8(x8)
    sb    x1, 9(x8)
    sb    x11, 10(x8)
    sb    x6, 11(x8)
    sw    x14, 12(x8)
    lw    x4, 0(x8)
    lh    x5, 4(x8)              # con signo
    lhu   x6, 4(x8)              # sin signo
    lh    x7, 6(x8)
    lb    x9, 8(x8)
    lbu   x10, 8(x8)
    lb    x11, 9(x8)
    lbu   x12, 10(x8)
    lb    x13, 11(x8)
    lw    x14, 12(x8)
    lb    x15, 1(x8)             # byte 1 de una palabra
    lhu   x1, 2(x8)              # media palabra alta

    # --- saltos: cada uno tomado y no tomado ---
    addi  x5, x0, 0              # contador de saltos tomados
    addi  x6, x0, -1
    addi  x7, x0, 1
    beq   x6, x7, b1
    addi  x5, x5, 1
b1: beq   x7, x7, b2
    addi  x5, x5, 100            # no se ejecuta
b2: bne   x7, x7, b3
    addi  x5, x5, 1
b3: bne   x6, x7, b4
    addi  x5, x5, 100
b4: blt   x7, x6, b5             # 1 < -1 con signo: no
    addi  x5, x5, 1
b5: blt   x6, x7, b6             # -1 < 1 con signo: sí
    addi  x5, x5, 100
b6: bge   x6, x7, b7             # no
    addi  x5, x5, 1
b7: bge   x7, x6, b8             # sí
    addi  x5, x5, 100
b8: bltu  x6, x7, b9             # 0xFFFFFFFF < 1 sin signo: no
    addi  x5, x5, 1
b9: bltu  x7, x6, b10            # sí
    addi  x5, x5, 100
b10: bgeu x7, x6, b11            # no
    addi  x5, x5, 1
b11: bgeu x6, x7, b12            # sí
    addi  x5, x5, 100
b12:

    # --- llamada y retorno, con jal y jalr ---
    jal   x1, sub_doble
    jal   x1, sub_doble
    sw    x5, OFF_DISP(x2)
    sw    x5, OFF_LEDS(x2)

fin:
    j     fin

sub_doble:
    add   x5, x5, x5
    jalr  x0, 0(x1)

datos:
