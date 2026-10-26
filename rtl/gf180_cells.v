// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Envoltorios de dos celdas de la biblioteca gf180mcu_fd_sc_mcu7t5v0 que el
// banco de registros con latches instancia directamente (Proyecto 3,
// experimento B5, rama exp/rf-latch). En síntesis (Yosys define SYNTHESIS) se
// instancia la celda; en simulación y lint, un modelo de comportamiento
// equivalente (always_latch, para que el linter sepa que el latch es a propósito).

// Clock gating integrado, flanco positivo (icgtp_1): un latch transparente
// con el reloj en bajo guarda el enable, y la salida es CLK & enable. El
// pulso alto del reloj solo pasa si el enable valía 1 en la fase baja
// anterior; así la salida nunca tiene glitches.
module gf180_clock_gate (
  input  wire clk_i,
  input  wire en_i,
  output wire gclk_o
);
`ifdef SYNTHESIS
  gf180mcu_fd_sc_mcu7t5v0__icgtp_1 u_icg (.CLK(clk_i), .E(en_i), .TE(1'b0), .Q(gclk_o));
`else
  reg en_l;
  always_latch if (!clk_i) en_l = en_i;
  assign gclk_o = clk_i & en_l;
`endif
endmodule

// Latch D transparente con enable en alto (latq_1).
module gf180_latch (
  input  wire e_i,
  input  wire d_i,
  output wire q_o
);
`ifdef SYNTHESIS
  gf180mcu_fd_sc_mcu7t5v0__latq_1 u_lat (.E(e_i), .D(d_i), .Q(q_o));
`else
  reg q;
  always_latch if (e_i) q = d_i;
  assign q_o = q;
`endif
endmodule
