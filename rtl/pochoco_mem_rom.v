// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Estrategia 1 de memoria (sección 3.2): ROM combinacional para las
// instrucciones y una RAM de datos reducida, separadas.
//
// Mantiene la interfaz y la temporización de la pochoco_ram del Proyecto 2,
// así que el core no cambia:
//   - puerto A (instrucciones): la ROM es combinacional y su salida pasa
//     por un registro, que cumple el papel del puerto A registrado de la
//     RAM original (el dato aparece un ciclo después de pedirlo);
//   - puerto B (datos): RAM de DataWords palabras en flip-flops, con
//     escritura por byte y lectura registrada. La dirección se toma módulo
//     DataWords (DataWords debe ser potencia de 2). El puerto de datos ya
//     no ve las instrucciones: el juego nunca las lee como datos.

module pochoco_mem_rom #(
  parameter integer DataWords = 4
) (
  input  wire        clk_i,

  // Puerto A: instrucciones
  input  wire        a_req_i,
  input  wire [31:0] a_addr_i,
  output reg  [31:0] a_rdata_o,

  // Puerto B: datos
  input  wire        b_req_i,
  input  wire        b_we_i,
  input  wire [3:0]  b_be_i,
  input  wire [31:0] b_addr_i,
  input  wire [31:0] b_wdata_i,
  output reg  [31:0] b_rdata_o
);

  wire [31:0] rom_data;

  pochoco_rom u_rom (
    .addr_i (a_addr_i),
    .data_o (rom_data)
  );

  always @(posedge clk_i) begin
    if (a_req_i) a_rdata_o <= rom_data;
  end

  generate
    if (DataWords > 0) begin : g_ram
      localparam integer DAW = (DataWords > 1) ? $clog2(DataWords) : 1;

      reg  [31:0]    ram [0:DataWords-1];
      wire [DAW-1:0] b_word = b_addr_i[DAW+1:2];

      always @(posedge clk_i) begin
        if (b_req_i && b_we_i) begin
          if (b_be_i[0]) ram[b_word][7:0]   <= b_wdata_i[7:0];
          if (b_be_i[1]) ram[b_word][15:8]  <= b_wdata_i[15:8];
          if (b_be_i[2]) ram[b_word][23:16] <= b_wdata_i[23:16];
          if (b_be_i[3]) ram[b_word][31:24] <= b_wdata_i[31:24];
        end
        b_rdata_o <= ram[b_word];
      end

      wire _unused = &{1'b0, b_addr_i[31:DAW+2], b_addr_i[1:0]};
    end else begin : g_no_ram
      always @(posedge clk_i) b_rdata_o <= 32'b0;
      wire _unused = &{1'b0, b_req_i, b_we_i, b_be_i, b_addr_i, b_wdata_i};
    end
  endgenerate

endmodule
