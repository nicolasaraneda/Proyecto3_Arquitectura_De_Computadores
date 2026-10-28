// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Reemplazo del modelo funcional del flip-flop sin reset del PDK
// (gf180mcu_fd_sc_mcu7t5v0__dffq_func, que guarda su estado en la primitiva
// udp_n_iq_ff y arranca en x) para el experimento de sensibilidad del frente
// D3: mismo comportamiento (Q <= D en el flanco de subida, sin retardos, igual
// que el modelo del PDK con -DFUNCTIONAL) pero con el estado inicial definido
// por INIT_FF (0 o 1) en vez de x. Sirve para medir cuanta conmutacion esconden
// los valores x de los registros nunca escritos (banco de registros, D4, y RAM
// de datos), que OpenSTA no cuenta al leer el VCD.
//
// Se compila junto a la biblioteca del PDK definiendo su guarda, para que el
// modulo original quede fuera:
//   iverilog -g2012 -DFUNCTIONAL -DINIT_FF=0 -DGF180MCU_FD_SC_MCU7T5V0__DFFQ_FUNC_V \
//     ... asic/potencia/dffq_func_init.v <netlist> primitives.v gf180mcu_fd_sc_mcu7t5v0.v
// Solo cambia el dffq (804 celdas del netlist final: banco de registros, RAM de
// datos y registros de la segmentacion); los dffrnq tienen reset y no se tocan.

`ifndef INIT_FF
  `define INIT_FF 0
`endif

module gf180mcu_fd_sc_mcu7t5v0__dffq_func( CLK, D, Q, notifier );
  input  CLK, D, notifier;
  output reg Q;
  initial Q = `INIT_FF;
  always @(posedge CLK) Q <= D;
endmodule
