// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
// 
// Authors:
// - Nicolás Villegas <navillegas@miuandes.cl>

module espino_if_stage #(
  parameter [31:0] BootAddr = 32'h0000_0000
) (
  input  wire        clk_i,
  input  wire        rst_ni,

  input  wire        pc_set_i,
  input  wire [31:0] pc_target_i,
  input  wire        stall_i,

  output wire        instr_req_o,
  output wire [31:0] instr_addr_o,

  output wire [31:0] pc_id_o,
  output wire        instr_valid_id_o
);

  // Experimento B4 (rama exp/cpi): la memoria de instrucciones es
  // combinacional, así que la instrucción que se ejecuta es la de pc_q en el
  // mismo ciclo: no hay registro de instrucción ni PC de la etapa ID, y un
  // salto tomado no deja una instrucción buscada de más que invalidar. Una
  // instrucción ejecuta por ciclo salvo cuando la LSU detiene el pipeline
  // esperando el dato de una carga.
  reg  [31:0] pc_q;
  wire [31:0] pc_next;

  assign pc_next = pc_set_i ? pc_target_i : (pc_q + 32'd4);

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pc_q <= BootAddr;
    end else if (!stall_i) begin
      pc_q <= pc_next;
    end
  end

  assign instr_req_o      = ~stall_i;
  assign instr_addr_o     = pc_q;
  assign pc_id_o          = pc_q;
  assign instr_valid_id_o = 1'b1;

endmodule