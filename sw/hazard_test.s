# =============================================================================
# hazard_test.s -- Riesgos de datos y de control del Espino Core (Proyecto 3,
# rama exp/pipeline, frente A; docs/pipeline.md)
#
# No es parte del juego. Ejercita, uno por uno y encadenados, los riesgos que
# aparecen cuando el banco de registros se lee y la instrucción se decodifica
# en el fetch (EarlyRead): escritura seguida de lectura del mismo registro
# (como rs1 y como rs2, en la instrucción inmediata y en la subsiguiente),
# carga seguida de uso inmediato (lw, lh, lhu, lb, lbu, con y sin signo,
# offsets 0 a 3, desde la RAM y desde un periférico), store de byte y media
# palabra, jal y jalr seguidos de uso del link, escrituras a x0 seguidas de
# lecturas de x0, cada salto condicional tomado y no tomado con la
# instrucción siguiente dependiente del resultado, y saltos encadenados.
#
# Cada comprobación compara un resultado con su valor esperado; x14 cuenta
# las que pasan y x15 suma todos los resultados. Al final se escribe x14 a
# DISP (en hexadecimal: con las 56 comprobaciones muestra "38") y a LEDS
# 0xF si pasaron todas, o los 4 bits bajos de x14 si no. Lo usa
# tb/core_trace_tb.v con `make equiv PROG=hazard_test REF=main MODO=funcional`:
# la traza de escrituras al banco, accesos al bus y salidas tiene que ser la
# misma que con el RTL de main, que no tiene ninguno de estos riesgos.
#
# Solo instrucciones que soporta el assembler (docs/assembler.md), sin
# shifts. La zona de datos empieza en la etiqueta "datos" (4 palabras).
# =============================================================================

.equ PERIPH_HI, 0x80000
.equ OFF_DISP,  0
.equ OFF_LEDS,  4
.equ OFF_BTN,   8
.equ TOTAL,     56           # comprobaciones

_start:
    lui   x2, PERIPH_HI          # base de periféricos
    la    x8, datos              # base de la zona de datos
    addi  x14, x0, 0             # comprobaciones que pasaron
    addi  x15, x0, 0             # suma de los resultados

# -----------------------------------------------------------------------------
# 1. Escritura seguida de lectura del mismo registro (write-through del banco)
# -----------------------------------------------------------------------------
    # 1a: como rs1, en la instrucción inmediata
    addi  x1, x0, 5
    addi  x5, x1, 10             # 15
    addi  x13, x0, 15
    bne   x5, x13, c01
    addi  x14, x14, 1
c01: add  x15, x15, x5

    # 1b: como rs2, en la instrucción inmediata (y x1 como rs1 subsiguiente)
    addi  x1, x0, 5
    addi  x4, x0, 7
    add   x5, x1, x4             # 12
    addi  x13, x0, 12
    bne   x5, x13, c02
    addi  x14, x14, 1
c02: add  x15, x15, x5

    # 1c: como rs1, en la subsiguiente (una instrucción de por medio)
    addi  x6, x0, 3
    addi  x9, x0, 100
    addi  x5, x6, 1              # 4
    addi  x13, x0, 4
    bne   x5, x13, c03
    addi  x14, x14, 1
c03: add  x15, x15, x5

    # 1d: como rs2, en la subsiguiente; rs1 inmediata
    addi  x9, x0, 20
    addi  x10, x0, 1
    sub   x5, x10, x9            # -19
    addi  x13, x0, -19
    bne   x5, x13, c04
    addi  x14, x14, 1
c04: add  x15, x15, x5

    # 1e: los dos operandos son el registro recién escrito
    addi  x1, x0, 6
    add   x5, x1, x1             # 12
    addi  x13, x0, 12
    bne   x5, x13, c05
    addi  x14, x14, 1
c05: add  x15, x15, x5

    # 1f: cadena, cada instrucción depende de la anterior
    addi  x1, x0, 1
    add   x1, x1, x1             # 2
    add   x1, x1, x1             # 4
    add   x1, x1, x1             # 8
    addi  x5, x1, -3             # 5
    addi  x13, x0, 5
    bne   x5, x13, c06
    addi  x14, x14, 1
c06: add  x15, x15, x5

    # 1g: lui y auipc recién escritos, usados de inmediato
    lui   x3, 0x12345
    addi  x5, x3, 0x678          # 0x12345678
    li    x13, 0x12345678
    bne   x5, x13, c07
    addi  x14, x14, 1
c07: add  x15, x15, x5
pc_auipc:
    auipc x3, 0                  # dirección de esta instrucción
    la    x4, pc_auipc
    sub   x5, x3, x4             # 0
    bne   x5, x0, c08
    addi  x14, x14, 1
c08: add  x15, x15, x5

    # 1h: la lógica y las comparaciones con operandos recién escritos
    addi  x1, x0, -7
    xori  x5, x1, -1             # 6
    addi  x13, x0, 6
    bne   x5, x13, c09
    addi  x14, x14, 1
c09: add  x15, x15, x5
    addi  x1, x0, -7
    addi  x3, x0, 3
    slt   x4, x1, x3             # 1 (con signo)
    sltu  x5, x1, x3             # 0 (sin signo)
    add   x5, x5, x4             # 1
    addi  x13, x0, 1
    bne   x5, x13, c10
    addi  x14, x14, 1
c10: add  x15, x15, x5

# -----------------------------------------------------------------------------
# 2. Escritura seguida de uso como dirección y como dato de un store
# -----------------------------------------------------------------------------
    addi  x4, x8, 4              # dirección datos+4
    addi  x5, x0, 0x55           # dato
    sw    x5, 0(x4)              # rs1 subsiguiente, rs2 inmediata
    lw    x5, 4(x8)              # 0x55
    addi  x13, x0, 0x55
    bne   x5, x13, c11
    addi  x14, x14, 1
c11: add  x15, x15, x5

    addi  x4, x8, 8
    sw    x4, 0(x4)              # rs1 y rs2 inmediatas: datos+8 guarda su propia dirección
    lw    x5, 8(x8)
    addi  x13, x8, 8
    bne   x5, x13, c12
    addi  x14, x14, 1
c12: add  x15, x15, x5

    # store seguido de carga de la misma dirección (RAW por la memoria)
    addi  x3, x0, 0x321
    sw    x3, 12(x8)
    lw    x5, 12(x8)             # 0x321
    addi  x13, x0, 0x321
    bne   x5, x13, c13
    addi  x14, x14, 1
c13: add  x15, x15, x5

# -----------------------------------------------------------------------------
# 3. Carga seguida de uso inmediato: lb, lbu, lh, lhu, lw, offsets 0 a 3
#    Palabra de prueba en datos+0: 0x80FF7F01 (bytes 01, 7F, FF, 80;
#    medias palabras 7F01 y 80FF).
# -----------------------------------------------------------------------------
    li    x3, 0x80FF7F01
    sw    x3, 0(x8)

    lb    x4, 0(x8)              # 0x01
    addi  x5, x4, 1              # 2 (uso inmediato como rs1)
    addi  x13, x0, 2
    bne   x5, x13, c14
    addi  x14, x14, 1
c14: add  x15, x15, x5

    lb    x4, 1(x8)              # 0x7F
    add   x5, x4, x4             # 0xFE (uso inmediato como rs1 y rs2)
    addi  x13, x0, 0xFE
    bne   x5, x13, c15
    addi  x14, x14, 1
c15: add  x15, x15, x5

    lb    x4, 2(x8)              # -1 (con signo)
    addi  x5, x4, 1              # 0
    bne   x5, x0, c16
    addi  x14, x14, 1
c16: add  x15, x15, x5

    lb    x4, 3(x8)              # -128
    sub   x5, x0, x4             # 128 (uso inmediato como rs2)
    addi  x13, x0, 128
    bne   x5, x13, c17
    addi  x14, x14, 1
c17: add  x15, x15, x5

    lbu   x4, 0(x8)              # 1
    addi  x5, x4, 1              # 2
    addi  x13, x0, 2
    bne   x5, x13, c18
    addi  x14, x14, 1
c18: add  x15, x15, x5

    lbu   x4, 1(x8)              # 0x7F
    addi  x5, x4, 1              # 0x80
    addi  x13, x0, 0x80
    bne   x5, x13, c19
    addi  x14, x14, 1
c19: add  x15, x15, x5

    lbu   x4, 2(x8)              # 0xFF
    addi  x5, x4, 1              # 0x100
    addi  x13, x0, 0x100
    bne   x5, x13, c20
    addi  x14, x14, 1
c20: add  x15, x15, x5

    lbu   x4, 3(x8)              # 0x80
    addi  x5, x4, 1              # 0x81
    addi  x13, x0, 0x81
    bne   x5, x13, c21
    addi  x14, x14, 1
c21: add  x15, x15, x5

    lh    x4, 0(x8)              # 0x7F01
    addi  x5, x4, 1              # 0x7F02
    li    x13, 0x7F02
    bne   x5, x13, c22
    addi  x14, x14, 1
c22: add  x15, x15, x5

    lh    x4, 2(x8)              # 0xFFFF80FF (-32513)
    addi  x5, x4, 1              # 0xFFFF8100
    li    x13, -32512
    bne   x5, x13, c23
    addi  x14, x14, 1
c23: add  x15, x15, x5

    lhu   x4, 0(x8)              # 0x7F01
    addi  x5, x4, 1              # 0x7F02
    li    x13, 0x7F02
    bne   x5, x13, c24
    addi  x14, x14, 1
c24: add  x15, x15, x5

    lhu   x4, 2(x8)              # 0x80FF
    addi  x5, x4, 1              # 0x8100
    li    x13, 0x8100
    bne   x5, x13, c25
    addi  x14, x14, 1
c25: add  x15, x15, x5

    lw    x4, 0(x8)              # 0x80FF7F01
    addi  x5, x4, 1              # 0x80FF7F02
    li    x13, 0x80FF7F02
    bne   x5, x13, c26
    addi  x14, x14, 1
c26: add  x15, x15, x5

    # carga seguida de uso en la subsiguiente
    lw    x4, 0(x8)
    addi  x6, x0, 2
    add   x5, x4, x6             # 0x80FF7F03
    li    x13, 0x80FF7F03
    bne   x5, x13, c27
    addi  x14, x14, 1
c27: add  x15, x15, x5

    # carga desde un periférico (BTN, vale 0 en el testbench) y uso inmediato
    lw    x4, OFF_BTN(x2)
    addi  x5, x4, 1              # 1
    addi  x13, x0, 1
    bne   x5, x13, c28
    addi  x14, x14, 1
c28: add  x15, x15, x5

    # carga seguida de store del dato cargado (rs2) y de la dirección cargada (rs1)
    lw    x4, 0(x8)
    sw    x4, 4(x8)              # datos+4 = 0x80FF7F01
    lw    x5, 4(x8)
    li    x13, 0x80FF7F01
    bne   x5, x13, c29
    addi  x14, x14, 1
c29: add  x15, x15, x5
    addi  x3, x8, 12
    sw    x3, 8(x8)              # datos+8 guarda la dirección datos+12
    addi  x6, x0, 0x77
    lw    x4, 8(x8)
    sw    x6, 0(x4)              # dirección recién cargada
    lw    x5, 12(x8)             # 0x77
    addi  x13, x0, 0x77
    bne   x5, x13, c30
    addi  x14, x14, 1
c30: add  x15, x15, x5

    # carga seguida de salto condicional sobre el dato cargado
    lw    x4, 12(x8)             # 0x77
    addi  x3, x0, 0x77
    lw    x5, 12(x8)
    beq   x5, x3, c31t           # tomado
    addi  x14, x14, 100          # no se ejecuta
c31t:
    addi  x14, x14, 1
    add   x15, x15, x5

    # carga seguida de jalr sobre la dirección cargada
    la    x3, c32t
    sw    x3, 12(x8)
    lw    x4, 12(x8)
    jalr  x1, 0(x4)
    addi  x14, x14, 100          # no se ejecuta
c32t:
    la    x5, c32t
    sub   x5, x5, x1             # link = dirección de la instrucción que sigue al jalr: c32t - link = 4
    addi  x13, x0, 4
    bne   x5, x13, c32
    addi  x14, x14, 1
c32: add  x15, x15, x5

    # carga seguida de escritura del mismo registro (WAW) y de su uso
    lw    x4, 0(x8)
    addi  x4, x0, 3
    addi  x5, x4, 0              # 3
    addi  x13, x0, 3
    bne   x5, x13, c33
    addi  x14, x14, 1
c33: add  x15, x15, x5

# -----------------------------------------------------------------------------
# 4. Store de byte y media palabra (con datos recién escritos y recién cargados)
# -----------------------------------------------------------------------------
    sw    x0, 4(x8)              # limpia datos+4
    addi  x3, x0, 0x11
    sb    x3, 4(x8)              # byte 0
    addi  x3, x0, 0x22
    sb    x3, 5(x8)              # byte 1
    addi  x3, x0, 0x33
    sb    x3, 6(x8)              # byte 2
    addi  x3, x0, 0x44
    sb    x3, 7(x8)              # byte 3
    lw    x5, 4(x8)              # 0x44332211
    li    x13, 0x44332211
    bne   x5, x13, c34
    addi  x14, x14, 1
c34: add  x15, x15, x5

    li    x3, 0xABCD
    sh    x3, 4(x8)              # media palabra baja
    li    x3, 0x1234
    sh    x3, 6(x8)              # media palabra alta
    lw    x5, 4(x8)              # 0x1234ABCD
    li    x13, 0x1234ABCD
    bne   x5, x13, c35
    addi  x14, x14, 1
c35: add  x15, x15, x5

    lbu   x4, 1(x8)              # 0x7F, recién cargado
    sb    x4, 5(x8)              # va al byte 1 de datos+4
    lbu   x5, 5(x8)              # 0x7F
    addi  x13, x0, 0x7F
    bne   x5, x13, c36
    addi  x14, x14, 1
c36: add  x15, x15, x5

    lhu   x4, 2(x8)              # 0x80FF
    sh    x4, 6(x8)
    lh    x5, 6(x8)              # 0xFFFF80FF
    li    x13, -32513
    bne   x5, x13, c37
    addi  x14, x14, 1
c37: add  x15, x15, x5

# -----------------------------------------------------------------------------
# 5. jal y jalr seguidos de uso del link
# -----------------------------------------------------------------------------
    # jal cuyo destino usa el link de inmediato (retorno)
    jal   x1, ret_ya
jal_vuelve:
    la    x5, jal_vuelve
    sub   x5, x1, x5             # 0: el link es la dirección de esta instrucción
    bne   x5, x0, c38
    addi  x14, x14, 1
c38: add  x15, x15, x5

    # jal cuyo destino copia el link y vuelve con jalr x0
    jal   x1, copia_link
jal_vuelve2:
    la    x5, jal_vuelve2
    sub   x5, x3, x5             # x3 = link copiado en el destino
    bne   x5, x0, c39
    addi  x14, x14, 1
c39: add  x15, x15, x5

    # jalr con rs1 recién escrito y uso del link en el destino
    la    x4, jalr_dest
    jalr  x1, 0(x4)
jalr_vuelve:
    addi  x14, x14, 100          # no se ejecuta
jalr_dest:
    la    x5, jalr_vuelve
    sub   x5, x1, x5             # 0
    bne   x5, x0, c40
    addi  x14, x14, 1
c40: add  x15, x15, x5

    # jal encadenado: el destino es otro jal, y el segundo link se usa de inmediato
    jal   x1, salto_a
jal_fin:
    la    x5, jal_fin
    sub   x5, x6, x5             # x6 = link del primer jal, copiado por el segundo destino
    bne   x5, x0, c41
    addi  x14, x14, 1
c41: add  x15, x15, x5

# -----------------------------------------------------------------------------
# 6. Escrituras a x0 seguidas de lecturas de x0
# -----------------------------------------------------------------------------
    addi  x0, x0, 5              # x0 no cambia
    addi  x5, x0, 1              # 1 (si se adelantara x0 valdría 6)
    addi  x13, x0, 1
    bne   x5, x13, c42
    addi  x14, x14, 1
c42: add  x15, x15, x5
    addi  x1, x0, 9
    add   x0, x1, x1             # x0 no cambia (rs recién escrito)
    add   x5, x0, x0             # 0
    bne   x5, x0, c43
    addi  x14, x14, 1
c43: add  x15, x15, x5
    lw    x0, 0(x8)              # carga a x0: no escribe
    addi  x5, x0, 2              # 2
    addi  x13, x0, 2
    bne   x5, x13, c44
    addi  x14, x14, 1
c44: add  x15, x15, x5
    jal   x0, x0_sigue           # j: no escribe el link
    addi  x14, x14, 100          # no se ejecuta
x0_sigue:
    add   x5, x0, x0             # 0
    bne   x5, x0, c45
    addi  x14, x14, 1
c45: add  x15, x15, x5

# -----------------------------------------------------------------------------
# 7. Cada salto condicional tomado y no tomado, con la instrucción siguiente
#    dependiente del resultado (se ejecuta solo si no se toma)
# -----------------------------------------------------------------------------
    addi  x6, x0, -1
    addi  x7, x0, 1
    addi  x5, x0, 0              # cuenta de saltos tomados
    beq   x6, x7, b1             # no tomado
    addi  x5, x5, 1
b1: beq   x7, x7, b2             # tomado
    addi  x5, x5, 100
b2: bne   x7, x7, b3             # no tomado
    addi  x5, x5, 1
b3: bne   x6, x7, b4             # tomado
    addi  x5, x5, 100
b4: blt   x7, x6, b5             # no tomado (1 < -1 con signo: no)
    addi  x5, x5, 1
b5: blt   x6, x7, b6             # tomado
    addi  x5, x5, 100
b6: bge   x6, x7, b7             # no tomado
    addi  x5, x5, 1
b7: bge   x7, x6, b8             # tomado
    addi  x5, x5, 100
b8: bltu  x6, x7, b9             # no tomado (0xFFFFFFFF < 1 sin signo: no)
    addi  x5, x5, 1
b9: bltu  x7, x6, b10            # tomado
    addi  x5, x5, 100
b10: bgeu x7, x6, b11            # no tomado
    addi  x5, x5, 1
b11: bgeu x6, x7, b12            # tomado
    addi  x5, x5, 100
b12: addi x13, x0, 6
    bne   x5, x13, c46
    addi  x14, x14, 1
c46: add  x15, x15, x5

    # salto sobre un registro escrito por la instrucción inmediatamente anterior
    addi  x1, x0, 9
    addi  x3, x0, 9
    beq   x1, x3, c47t           # tomado; x3 inmediato y x1 subsiguiente
    addi  x14, x14, 100
c47t:
    addi  x14, x14, 1
    addi  x5, x0, 4
    addi  x3, x3, 1              # 10
    beq   x1, x3, c47            # no tomado
    addi  x5, x5, 1              # 5, depende del resultado del salto
c47: addi x13, x0, 5
    bne   x5, x13, c48
    addi  x14, x14, 1
c48: add  x15, x15, x5

    # lazo hacia atrás: el salto compara el registro recién decrementado
    addi  x5, x0, 0
    addi  x4, x0, 4
lazo:
    add   x5, x5, x4             # 4+3+2+1 = 10
    addi  x4, x4, -1
    bne   x4, x0, lazo
    addi  x13, x0, 10
    bne   x5, x13, c49
    addi  x14, x14, 1
c49: add  x15, x15, x5

    # el destino de un salto tomado usa un registro escrito justo antes del salto
    addi  x3, x0, 21
    beq   x0, x0, usa_x3
    addi  x3, x0, 0              # no se ejecuta
usa_x3:
    addi  x5, x3, 1              # 22
    addi  x13, x0, 22
    bne   x5, x13, c50
    addi  x14, x14, 1
c50: add  x15, x15, x5

# -----------------------------------------------------------------------------
# 8. Saltos encadenados: el destino de un salto tomado es otro salto tomado
# -----------------------------------------------------------------------------
    addi  x5, x0, 0
    beq   x7, x7, e1
    addi  x5, x5, 100
e1: bne   x6, x7, e2             # tomado, llega de un salto tomado
    addi  x5, x5, 100
e2: jal   x0, e3                 # jal al que se llega de un salto tomado
    addi  x5, x5, 100
e3: blt   x6, x7, e4             # tomado, llega de un jal
    addi  x5, x5, 100
e4: beq   x6, x7, e5             # no tomado, llega de un salto tomado
    addi  x5, x5, 1
e5: jal   x1, e6                 # jal a un jalr inmediato
    addi  x5, x5, 100
e7: addi  x5, x5, 1              # 2
    addi  x13, x0, 2
    bne   x5, x13, c51
    addi  x14, x14, 1
c51: add  x15, x15, x5
    jal   x0, e8
e6: la    x3, e7
    jalr  x0, 0(x3)              # jalr que llega de un jal (sus operandos se leyeron tras la burbuja)
e8:

    # tres saltos tomados seguidos con el contador actualizado entre medio
    addi  x5, x0, 0
    addi  x5, x5, 1
    beq   x0, x0, g1
g3: addi  x5, x5, 1              # 3
    addi  x13, x0, 3
    bne   x5, x13, c52
    addi  x14, x14, 1
c52: add  x15, x15, x5
    jal   x0, g4
g1: addi  x5, x5, 1              # 2
    beq   x0, x0, g3
    addi  x5, x5, 100
g4:

# -----------------------------------------------------------------------------
# 9. Todo junto: carga, uso, store, salto y link encadenados sin huecos
# -----------------------------------------------------------------------------
    addi  x3, x0, 40
    sw    x3, 0(x8)
    lw    x4, 0(x8)              # 40
    addi  x4, x4, 2              # 42
    sw    x4, 4(x8)
    lw    x5, 4(x8)              # 42
    beq   x5, x4, h1             # tomado: dato recién cargado contra registro recién escrito
    addi  x5, x0, 0
h1: jal   x1, h2                 # link
    addi  x5, x5, 100            # no se ejecuta
h3: addi  x5, x5, 1              # 43
    addi  x13, x0, 43
    bne   x5, x13, c53
    addi  x14, x14, 1
c53: add  x15, x15, x5
    jal   x0, h4
h2: addi  x1, x1, 4              # salta el addi que sigue al jal
    jalr  x0, 0(x1)              # vuelve a h3 con el link recién modificado
h4:

    # lb con offset 3 seguido de sb con el dato, y de lh del resultado
    li    x3, 0x80FF7F01
    sw    x3, 0(x8)
    lb    x4, 3(x8)              # -128
    sb    x4, 2(x8)              # byte 2 = 0x80
    lh    x5, 2(x8)              # 0x8080 con signo: 0xFFFF8080
    li    x13, -32640
    bne   x5, x13, c54
    addi  x14, x14, 1
c54: add  x15, x15, x5

    # carga seguida de uso como rs2 de un slt y de un salto sin signo
    addi  x3, x0, -5
    sw    x3, 8(x8)
    lw    x4, 8(x8)              # -5
    slt   x5, x4, x0             # 1
    lw    x4, 8(x8)
    bltu  x0, x4, h5             # tomado (0 < 0xFFFFFFFB sin signo)
    addi  x5, x5, 100
h5: addi  x13, x0, 1
    bne   x5, x13, c55
    addi  x14, x14, 1
c55: add  x15, x15, x5

    # suma de comprobación sobre un registro recién escrito, antes de mostrar
    addi  x5, x15, 0
    beq   x5, x15, c56t
    addi  x14, x14, 100
c56t:
    addi  x14, x14, 1

# -----------------------------------------------------------------------------
# Resultado: DISP = comprobaciones que pasaron; LEDS = F si pasaron todas
# -----------------------------------------------------------------------------
fin_test:
    sw    x14, OFF_DISP(x2)
    addi  x13, x0, TOTAL
    addi  x5, x14, 0
    bne   x14, x13, fin_leds
    addi  x5, x0, 0xF
fin_leds:
    sw    x5, OFF_LEDS(x2)

fin:
    j     fin

# --- subrutinas ---
ret_ya:
    jalr  x0, 0(x1)              # usa el link de inmediato

copia_link:
    addi  x3, x1, 0              # copia el link de inmediato
    jalr  x0, 0(x1)

salto_a:
    addi  x6, x1, 0              # link del primer jal
    jal   x1, salto_b            # segundo jal
    jalr  x0, 0(x6)              # vuelve al primer llamador
salto_b:
    addi  x7, x1, 0              # usa el segundo link de inmediato
    jalr  x0, 0(x1)

datos:
