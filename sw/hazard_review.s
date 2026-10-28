# =============================================================================
# hazard_review.s -- Casos de riesgo ADICIONALES a sw/hazard_test.s, escritos
# por el revisor independiente del frente A (rama exp/pipeline).
#
# Objetivo: intentar refutar que el core con EarlyRead = 1 (lectura del banco
# de registros y decode en el fetch) se comporta igual que el de main. Cubre
# los casos que hazard_test.s no tiene o tiene solo de pasada:
#   R1  cadenas rs1/rs2 cruzadas (el mismo registro como rd y como los dos rs)
#   R2  dependencia a dos instrucciones de distancia a traves de un salto
#       tomado (hacia adelante y hacia atras)
#   R3  carga cuyo destino es el registro base de la carga siguiente, y carga
#       cuyo destino es su propio registro base
#   R4  carga seguida de store del dato cargado: sw, sb con offsets 0 a 3 y
#       sh en las dos mitades, releido con lb, lbu, lh, lhu y lw
#   R5  lb y lh con signo negativo seguidos de slt y sltu (rs1 y rs2)
#   R6  jalr con base recien cargada de memoria y con base recien escrita por
#       la instruccion inmediatamente anterior
#   R7  jal a la instruccion siguiente (el destino es la propia secuencial
#       descartada) y uso inmediato del link
#   R8  salto condicional cuyos operandos se escribieron en la instruccion
#       anterior y en la anterior a esa, y operando recien cargado
#   R9  auipc y lui seguidos de uso inmediato (operando y operando de salto)
#   R10 lectura del periferico BTN seguida de uso inmediato (operando,
#       operando de salto y dato de un store)
#   R11 escrituras a x0 con addi, lw y jal seguidas de lecturas de x0
#   R12 cadena final sin huecos; R13 carga, salto tomado dependiente y
#       destino dependiente del mismo dato: carga, uso, store, salto, jal, copia del link
#       y jalr con la base recien escrita
#
# x14 cuenta las comprobaciones que pasan y x15 suma los resultados. x12
# cuenta cuantas instrucciones secuenciales DESCARTADAS por un salto tomado
# alcanzaron a ejecutarse: tiene que quedar en 0 (es la ultima comprobacion).
# Al final se escribe x14 a DISP y a LEDS 0xF si pasaron todas.
#
# Deterministico a proposito (los botones valen 0 en los testbenches y no se
# lee CYCLES), de modo que la traza de escrituras al banco, accesos al bus y
# salidas se puede comparar contra la de main:
#   make equiv PROG=hazard_review REF=main MODO=funcional
# El caso de CYCLES va en sw/hazard_cycles.s, que no se puede comparar asi
# porque el valor leido depende del ciclo y el ciclo cambia por diseno.
#
# Solo instrucciones que soporta el assembler (docs/assembler.md), sin shifts.
# La zona de datos del ASIC son 4 palabras (DataWords = 4): se usan los
# offsets 0, 4, 8 y 12 desde x8 y cada palabra se escribe antes de leerla.
# =============================================================================

.equ PERIPH_HI, 0x80000
.equ OFF_DISP,  0
.equ OFF_LEDS,  4
.equ OFF_BTN,   8
.equ TOTAL,     48           # comprobaciones

_start:
    lui   x2, PERIPH_HI          # base de perifericos
    la    x8, datos              # base de la zona de datos
    addi  x14, x0, 0             # comprobaciones que pasaron
    addi  x15, x0, 0             # suma de los resultados
    addi  x12, x0, 0             # instrucciones descartadas que se ejecutaron

# -----------------------------------------------------------------------------
# R1. Cadenas rs1/rs2 cruzadas
# -----------------------------------------------------------------------------
    # el rd de cada instruccion es rs1 de la siguiente y rs2 de la subsiguiente
    addi  x3, x0, 1
    addi  x4, x0, 2
    add   x3, x3, x4             # 3
    add   x4, x4, x3             # 5
    sub   x5, x4, x3             # 2
    addi  x13, x0, 2
    bne   x5, x13, c01
    addi  x14, x14, 1
c01: add  x15, x15, x5

    # rs1 a tres instrucciones y rs2 inmediato, cruzados
    addi  x3, x0, 7
    addi  x4, x0, 9
    sub   x6, x4, x3             # 2
    sub   x7, x3, x6             # 5
    add   x5, x6, x7             # 7
    addi  x13, x0, 7
    bne   x5, x13, c02
    addi  x14, x14, 1
c02: add  x15, x15, x5

    # el registro recien escrito es rd, rs1 y rs2 a la vez, encadenado
    addi  x3, x0, 2
    add   x3, x3, x3             # 4
    add   x3, x3, x3             # 8
    xor   x4, x3, x3             # 0
    or    x5, x3, x4             # 8
    addi  x13, x0, 8
    bne   x5, x13, c03
    addi  x14, x14, 1
c03: add  x15, x15, x5

    # and/andi/ori/xori/slti con el registro recien escrito
    addi  x3, x0, 12
    andi  x4, x3, 10             # 8
    ori   x5, x4, 1              # 9
    xori  x6, x5, 3              # 10
    slti  x7, x6, 11             # 1
    and   x5, x7, x6             # 0
    addi  x13, x0, 0
    bne   x5, x13, c04
    addi  x14, x14, 1
c04: add  x15, x15, x5

# -----------------------------------------------------------------------------
# R2. Dependencia a dos instrucciones de distancia a traves de un salto tomado
# -----------------------------------------------------------------------------
    addi  x3, x0, 11
    beq   x0, x0, r2a            # tomado
    addi  x3, x3, 100            # DESCARTADA (depende de x3)
r2a: addi x5, x3, 1              # 12: x3 escrito dos instrucciones antes
    addi  x13, x0, 12
    bne   x5, x13, c05
    addi  x14, x14, 1
c05: add  x15, x15, x5

    # registro escrito justo antes del salto, usado en el destino
    addi  x6, x0, 33
    j     r2b
    addi  x6, x0, 99             # DESCARTADA
r2b: add  x5, x6, x0             # 33
    addi  x13, x0, 33
    bne   x5, x13, c06
    addi  x14, x14, 1
c06: add  x15, x15, x5

    # lo mismo con un salto hacia atras
    j     r2d
r2c: addi x5, x9, 1              # 44: x9 escrito justo antes del j de abajo
    addi  x13, x0, 44
    bne   x5, x13, c07
    addi  x14, x14, 1
c07: add  x15, x15, x5
    j     r2e
r2d: addi x9, x0, 43
    j     r2c
r2e:

# -----------------------------------------------------------------------------
# R3. Carga cuyo destino es el registro base de la carga siguiente
# -----------------------------------------------------------------------------
    sw    x8, 0(x8)              # guarda la direccion base en la palabra 0
    lw    x4, 0(x8)              # x4 = base
    lw    x5, 0(x4)              # base recien cargada (uso inmediato)
    bne   x5, x8, c08            # y el dato recien cargado como operando
    addi  x14, x14, 1
c08: add  x15, x15, x5

    # carga cuyo rd es su propio registro base
    addi  x4, x8, 0
    lw    x4, 0(x4)
    bne   x4, x8, c09
    addi  x14, x14, 1
c09: add  x15, x15, x4

# -----------------------------------------------------------------------------
# R4. Carga seguida de store del dato cargado (sw, sb offsets 0 a 3, sh)
# -----------------------------------------------------------------------------
    li    x3, 0x11223344
    sw    x3, 0(x8)
    lw    x4, 0(x8)
    sw    x4, 4(x8)              # store del dato recien cargado
    lw    x5, 4(x8)
    bne   x5, x3, c10
    addi  x14, x14, 1
c10: add  x15, x15, x5

    sw    x0, 8(x8)              # limpia la palabra 2
    addi  x3, x0, 0xA5
    sw    x3, 0(x8)
    lw    x4, 0(x8)
    sb    x4, 8(x8)              # offset 0, dato recien cargado
    lbu   x5, 8(x8)
    addi  x13, x0, 0xA5
    bne   x5, x13, c11
    addi  x14, x14, 1
c11: add  x15, x15, x5

    lw    x4, 0(x8)
    sb    x4, 9(x8)              # offset 1
    lbu   x5, 9(x8)
    addi  x13, x0, 0xA5
    bne   x5, x13, c12
    addi  x14, x14, 1
c12: add  x15, x15, x5

    lw    x4, 0(x8)
    sb    x4, 10(x8)             # offset 2
    lb    x5, 10(x8)             # con signo: -91
    addi  x13, x0, -91
    bne   x5, x13, c13
    addi  x14, x14, 1
c13: add  x15, x15, x5

    lw    x4, 0(x8)
    sb    x4, 11(x8)             # offset 3
    lb    x5, 11(x8)             # -91
    addi  x13, x0, -91
    bne   x5, x13, c14
    addi  x14, x14, 1
c14: add  x15, x15, x5

    lw    x5, 8(x8)              # la palabra 2 quedo 0xA5A5A5A5
    li    x13, 0xA5A5A5A5
    bne   x5, x13, c15
    addi  x14, x14, 1
c15: add  x15, x15, x5

    sw    x0, 8(x8)
    li    x3, 0x0000BEEF
    sw    x3, 0(x8)
    lw    x4, 0(x8)
    sh    x4, 8(x8)              # media palabra baja, dato recien cargado
    lhu   x5, 8(x8)
    li    x13, 0xBEEF
    bne   x5, x13, c16
    addi  x14, x14, 1
c16: add  x15, x15, x5

    lw    x4, 0(x8)
    sh    x4, 10(x8)             # media palabra alta
    lhu   x5, 10(x8)
    li    x13, 0xBEEF
    bne   x5, x13, c17
    addi  x14, x14, 1
c17: add  x15, x15, x5

    lh    x5, 10(x8)             # 0xBEEF con signo
    li    x13, -16657
    bne   x5, x13, c18
    addi  x14, x14, 1
c18: add  x15, x15, x5

# -----------------------------------------------------------------------------
# R5. lb y lh con signo negativo seguidos de slt y sltu
# -----------------------------------------------------------------------------
    li    x3, 0xFF80FF80
    sw    x3, 0(x8)

    lb    x4, 0(x8)              # 0x80 -> -128
    slt   x5, x4, x0             # 1: dato recien cargado como rs1
    addi  x13, x0, 1
    bne   x5, x13, c19
    addi  x14, x14, 1
c19: add  x15, x15, x5

    lb    x4, 0(x8)
    sltu  x5, x4, x0             # 0: sin signo -128 es grande
    addi  x13, x0, 0
    bne   x5, x13, c20
    addi  x14, x14, 1
c20: add  x15, x15, x5

    lb    x4, 0(x8)
    slt   x5, x0, x4             # 0: dato recien cargado como rs2
    addi  x13, x0, 0
    bne   x5, x13, c21
    addi  x14, x14, 1
c21: add  x15, x15, x5

    lh    x4, 2(x8)              # 0xFF80 -> -128
    slt   x5, x4, x0             # 1
    addi  x13, x0, 1
    bne   x5, x13, c22
    addi  x14, x14, 1
c22: add  x15, x15, x5

    lhu   x4, 2(x8)              # 0x0000FF80 -> 65408
    slt   x5, x4, x0             # 0
    addi  x13, x0, 0
    bne   x5, x13, c23
    addi  x14, x14, 1
c23: add  x15, x15, x5

    lbu   x4, 0(x8)              # 0x80 -> 128
    sltu  x5, x0, x4             # 1
    addi  x13, x0, 1
    bne   x5, x13, c24
    addi  x14, x14, 1
c24: add  x15, x15, x5

# -----------------------------------------------------------------------------
# R6. jalr con base recien cargada de memoria y con base recien escrita
# -----------------------------------------------------------------------------
    la    x3, r6a
    sw    x3, 12(x8)
    lw    x4, 12(x8)
    jalr  x1, 0(x4)              # base = dato recien cargado (uso inmediato)
    addi  x12, x12, 1            # DESCARTADA
r6a:
    addi  x5, x1, 0              # link de inmediato
    la    x13, r6a
    addi  x13, x13, -4           # el link apunta a la descartada
    bne   x5, x13, c25
    addi  x14, x14, 1
c25: add  x15, x15, x5

    la    x4, r6b
    jalr  x0, 0(x4)              # base escrita en la instruccion anterior
    addi  x12, x12, 1            # DESCARTADA
r6b:
    addi  x5, x0, 2
    addi  x13, x0, 2
    bne   x5, x13, c26
    addi  x14, x14, 1
c26: add  x15, x15, x5

# -----------------------------------------------------------------------------
# R7. jal a la instruccion siguiente
# -----------------------------------------------------------------------------
    jal   x1, r7a                # el destino es la propia secuencial
r7a: addi x5, x1, 0              # link de inmediato = direccion de r7a
    la    x13, r7a
    bne   x5, x13, c27
    addi  x14, x14, 1
c27: add  x15, x15, x5

    jal   x3, r7b                # link en un registro que no es x1
r7b: addi x5, x3, 0
    la    x13, r7b
    bne   x5, x13, c28
    addi  x14, x14, 1
c28: add  x15, x15, x5

# -----------------------------------------------------------------------------
# R8. Salto condicional con operandos escritos justo antes
# -----------------------------------------------------------------------------
    addi  x3, x0, 5
    addi  x4, x0, 5
    beq   x3, x4, r8a            # rs1 a dos, rs2 inmediato: tomado
    addi  x12, x12, 1            # DESCARTADA
r8a: addi x5, x0, 1
    addi  x13, x0, 1
    bne   x5, x13, c29
    addi  x14, x14, 1
c29: add  x15, x15, x5

    addi  x3, x0, 7
    add   x4, x3, x0             # 7, rs1 recien escrito
    bne   x3, x4, r8b            # NO tomado
    addi  x5, x0, 2              # se ejecuta
    j     r8c
r8b: addi x12, x12, 1
    addi  x5, x0, 0
r8c: addi x13, x0, 2
    bne   x5, x13, c30
    addi  x14, x14, 1
c30: add  x15, x15, x5

    addi  x6, x0, 123
    sw    x6, 0(x8)
    lw    x4, 0(x8)
    beq   x4, x6, r8d            # rs1 recien cargado: tomado
    addi  x12, x12, 1            # DESCARTADA
r8d: addi x5, x0, 3
    addi  x13, x0, 3
    bne   x5, x13, c31
    addi  x14, x14, 1
c31: add  x15, x15, x5

    lw    x4, 0(x8)
    bge   x6, x4, r8e            # rs2 recien cargado: tomado (123 >= 123)
    addi  x12, x12, 1            # DESCARTADA
r8e: addi x5, x0, 4
    addi  x13, x0, 4
    bne   x5, x13, c32
    addi  x14, x14, 1
c32: add  x15, x15, x5

    lw    x4, 0(x8)
    bgeu  x0, x4, r8f            # NO tomado (0 >= 123 sin signo es falso)
    addi  x5, x0, 5              # se ejecuta
    j     r8g
r8f: addi x12, x12, 1
    addi  x5, x0, 0
r8g: addi x13, x0, 5
    bne   x5, x13, c33
    addi  x14, x14, 1
c33: add  x15, x15, x5

# -----------------------------------------------------------------------------
# R9. auipc y lui seguidos de uso inmediato
# -----------------------------------------------------------------------------
r9a: auipc x3, 0                 # x3 = direccion de r9a
    addi  x4, x3, 0              # uso inmediato
    la    x13, r9a
    bne   x4, x13, c34
    addi  x14, x14, 1
c34: add  x15, x15, x4

r9b: auipc x3, 0
    la    x13, r9b
    bne   x3, x13, c35           # uso inmediato como operando de salto
    addi  x14, x14, 1
c35: add  x15, x15, x3

    lui   x5, 0x12345
    addi  x6, x5, 0x678          # uso inmediato: 0x12345678
    li    x13, 0x12345678
    bne   x6, x13, c36
    addi  x14, x14, 1
c36: add  x15, x15, x6

# -----------------------------------------------------------------------------
# R10. Lectura del periferico BTN seguida de uso inmediato
# -----------------------------------------------------------------------------
    lw    x3, OFF_BTN(x2)        # 0: botones sin pulsar
    addi  x4, x3, 7              # uso inmediato
    addi  x13, x0, 7
    bne   x4, x13, c37
    addi  x14, x14, 1
c37: add  x15, x15, x4

    lw    x3, OFF_BTN(x2)
    beq   x3, x0, r10a           # uso inmediato como operando de salto
    addi  x12, x12, 1            # DESCARTADA
r10a: addi x5, x0, 6
    addi  x13, x0, 6
    bne   x5, x13, c38
    addi  x14, x14, 1
c38: add  x15, x15, x5

    lw    x3, OFF_BTN(x2)
    sw    x3, 4(x8)              # dato de un store, recien leido del periferico
    lw    x5, 4(x8)
    bne   x5, x0, c39
    addi  x14, x14, 1
c39: add  x15, x15, x5

# -----------------------------------------------------------------------------
# R11. Escrituras a x0 con addi, lw y jal, seguidas de lecturas de x0
# -----------------------------------------------------------------------------
    addi  x0, x0, 123            # no se guarda
    add   x5, x0, x0             # 0
    addi  x13, x0, 0
    bne   x5, x13, c40a
    addi  x14, x14, 1
c40a: add x15, x15, x5

    addi  x3, x0, 0x55
    sw    x3, 0(x8)
    lw    x0, 0(x8)              # escritura a x0 desde una carga
    add   x5, x0, x0             # 0 (uso inmediato)
    addi  x13, x0, 0
    bne   x5, x13, c40b
    addi  x14, x14, 1
c40b: add x15, x15, x5

    lw    x0, 0(x8)
    addi  x5, x0, 9              # 9: x0 como rs1 justo despues
    addi  x13, x0, 9
    bne   x5, x13, c40c
    addi  x14, x14, 1
c40c: add x15, x15, x5

    lw    x0, 0(x8)
    sw    x0, 4(x8)              # x0 como dato de store justo despues
    lw    x5, 4(x8)
    bne   x5, x0, c40d
    addi  x14, x14, 1
c40d: add x15, x15, x5

    jal   x0, r11a               # escritura a x0 desde jal
    addi  x12, x12, 1            # DESCARTADA
r11a: add x5, x0, x0             # 0
    addi  x13, x0, 0
    bne   x5, x13, c40e
    addi  x14, x14, 1
c40e: add x15, x15, x5

# -----------------------------------------------------------------------------
# R12. Cadena final sin huecos
# -----------------------------------------------------------------------------
    addi  x3, x0, 123
    sw    x3, 0(x8)
    lw    x4, 0(x8)              # 123
    addi  x5, x4, 1              # 124, uso inmediato
    sw    x5, 4(x8)
    lw    x6, 4(x8)              # 124
    beq   x6, x5, r12a           # los dos recien escritos/cargados
    addi  x12, x12, 1            # DESCARTADA
r12a:
    jal   x1, r12c               # llamada
    j     r12d                   # el retorno cae aqui
r12c: addi x9, x1, 0             # copia del link de inmediato
    jalr  x0, 0(x9)              # retorno con la base recien escrita
r12d:
    addi  x13, x0, 124
    bne   x6, x13, c41a
    addi  x14, x14, 1
c41a: add x15, x15, x6

# -----------------------------------------------------------------------------
# R13. Carga, salto tomado que depende del dato cargado, y destino que tambien
#      depende de el (distancia dos a traves del salto)
# -----------------------------------------------------------------------------
    addi  x3, x0, 77
    sw    x3, 0(x8)
    lw    x4, 0(x8)              # 77
    beq   x4, x3, r13a           # tomado con el dato recien cargado
    addi  x12, x12, 1            # DESCARTADA
r13a: addi x5, x4, 1             # 78: el dato cargado, a dos instrucciones
    addi  x13, x0, 78
    bne   x5, x13, c42
    addi  x14, x14, 1
c42: add  x15, x15, x5

    la    x3, r13b
    sw    x3, 12(x8)
    lw    x4, 12(x8)
    jalr  x1, 0(x4)              # base = dato recien cargado
    addi  x12, x12, 1            # DESCARTADA
r13b: sub  x5, x4, x3            # 0: los dos operandos vienen de antes del salto
    addi  x13, x0, 0
    bne   x5, x13, c43
    addi  x14, x14, 1
c43: add  x15, x15, x5

# ultima comprobacion: ninguna instruccion descartada se ejecuto
    addi  x13, x0, 0
    bne   x12, x13, c41b
    addi  x14, x14, 1
c41b:

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

datos:
    .word 0, 0, 0, 0
