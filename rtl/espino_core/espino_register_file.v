// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Authors:
// - Nicolás Villegas <navillegas@miuandes.cl>
//
// Banco de registros de RV32E (x0 a x15) implementado con flip-flops.
//
// La versión del Proyecto 2 instanciaba dos SB_RAM40_4K por puerto de
// lectura (BRAM del iCE40), que no existen en una biblioteca de celdas
// estándar. Esta versión mantiene el mismo comportamiento visto desde el
// core:
//   - dos puertos de lectura con salida registrada: el dato aparece un
//     ciclo después de presentar la dirección, igual que en la BRAM, así
//     que espino_id_stage (rf_ready) y espino_controller no cambian;
//   - un puerto de escritura que nunca escribe x0.
// Con flip-flops ya no hace falta duplicar el banco para tener dos puertos
// de lectura: cada puerto es un multiplexor sobre los mismos registros.
//
// En la BRAM, x0 valía 0 porque la memoria partía en cero (INIT_0) y nunca
// se escribía. En silicio un flip-flop arranca en cualquier valor, así que
// x0 no se almacena: leer la dirección 0 entrega 0 por hardware. x1 a x15
// no tienen reset, igual que en la BRAM.

module espino_register_file (
  input  wire        clk_i,
  input  wire        rst_ni,     // sin uso
  input  wire [3:0]  raddr_a_i,
  output wire [31:0] rdata_a_o,
  input  wire [3:0]  raddr_b_i,
  output wire [31:0] rdata_b_o,
  input  wire [3:0]  waddr_i,
  input  wire [31:0] wdata_i,
  input  wire        we_i
);

  reg [31:0] regs [1:15];

  always @(posedge clk_i) begin
    if (we_i && (waddr_i != 4'd0)) regs[waddr_i] <= wdata_i;
  end

  // Experimento B4 (rama exp/cpi): lectura combinacional. Los operandos
  // están disponibles en el mismo ciclo en que llega la instrucción, así que
  // desaparece el ciclo de espera de la lectura sincrónica (y los 64
  // flip-flops de salida). Una escritura se ve en la lectura del ciclo
  // siguiente, que es cuando ejecuta la instrucción siguiente.
  assign rdata_a_o = (raddr_a_i == 4'd0) ? 32'b0 : regs[raddr_a_i];
  assign rdata_b_o = (raddr_b_i == 4'd0) ? 32'b0 : regs[raddr_b_i];

  // rst_ni queda sin uso a propósito
  wire _unused = &{1'b0, rst_ni};
endmodule
