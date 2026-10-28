# =============================================================================
# hazard_cycles.s -- Lectura del contador CYCLES seguida de uso inmediato
# (revision independiente del frente A, rama exp/pipeline).
#
# Va aparte de sw/hazard_review.s porque el VALOR que devuelve CYCLES depende
# del ciclo en que se lee, y el ciclo cambia por diseno entre main y esta rama
# (1 ciclo por instruccion contra 2). Por eso las escrituras al banco NO son
# comparables con las de main, pero el RESULTADO de cada comprobacion si lo
# es: todas estan escritas para que su valor de verdad no dependa del ciclo.
# Lo que se compara entre main y la rama son las salidas (DISP y LEDS):
#   make equiv PROG=hazard_cycles REF=main MODO=funcional
# tiene que dar "io: 2 eventos iguales" (DISP = 5, LEDS = F en las dos
# versiones) y DIFIEREN en rf, que es lo esperado y no un error.
# =============================================================================

.equ PERIPH_HI, 0x80000
.equ OFF_DISP,  0
.equ OFF_LEDS,  4
.equ OFF_BTN,   8
.equ OFF_CYC,   12
.equ TOTAL,     5

_start:
    lui   x2, PERIPH_HI
    addi  x14, x0, 0

    # 1: CYCLES leido y copiado en la instruccion inmediatamente siguiente
    lw    x3, OFF_CYC(x2)
    addi  x4, x3, 0              # uso inmediato del dato del periferico
    bne   x4, x3, k1             # tienen que ser iguales: no tomado
    addi  x14, x14, 1
k1:
    # 2: dos lecturas seguidas; la segunda es mayor (uso inmediato en sltu)
    lw    x3, OFF_CYC(x2)
    lw    x4, OFF_CYC(x2)
    sltu  x5, x3, x4             # 1
    addi  x13, x0, 1
    bne   x5, x13, k2
    addi  x14, x14, 1
k2:
    # 3: CYCLES como operando de un salto, de inmediato
    lw    x3, OFF_CYC(x2)
    beq   x3, x0, k3             # no tomado: el contador ya avanzo
    addi  x14, x14, 1
k3:
    # 4: diferencia de dos lecturas, la segunda usada de inmediato
    lw    x3, OFF_CYC(x2)
    lw    x4, OFF_CYC(x2)
    sub   x5, x4, x3             # fija dentro de una version, siempre > 0
    slt   x6, x0, x5             # 1
    addi  x13, x0, 1
    bne   x6, x13, k4
    addi  x14, x14, 1
k4:
    # 5: BTN y CYCLES alternados, los dos usados de inmediato
    lw    x3, OFF_BTN(x2)        # 0
    lw    x4, OFF_CYC(x2)
    add   x5, x3, x4             # = CYCLES
    bne   x5, x4, k5
    addi  x14, x14, 1
k5:
    sw    x14, OFF_DISP(x2)
    addi  x13, x0, TOTAL
    addi  x5, x14, 0
    bne   x14, x13, k_leds
    addi  x5, x0, 0xF
k_leds:
    sw    x5, OFF_LEDS(x2)
k_fin:
    j     k_fin
