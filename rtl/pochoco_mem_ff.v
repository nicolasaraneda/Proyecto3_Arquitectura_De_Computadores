// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Estrategia 2 de memoria (sección 3.2): memoria unificada de instrucciones
// y datos, implementada con flip-flops y dimensionada según el uso real del
// juego: GAME_WORDS palabras de programa más DataWords de datos.
//
// En silicio no hay un archivo que se cargue al encender: el programa entra
// como valor de reset. Mientras rst_ni está activo, cada palabra toma el
// valor de game_word (el include que genera el assembler), así que cada bit
// queda como un flip-flop con reset o con set según el programa. Todas las
// palabras se pueden escribir desde el puerto de datos, como en la RAM
// unificada del Proyecto 2.
//
// Interfaz y temporización iguales a la pochoco_ram del Proyecto 2: lectura
// registrada en ambos puertos y escritura por byte en el puerto B. Una
// dirección fuera de la memoria lee 0 y no escribe nada.
//
// Proyecto 3, rama exp/pipeline (frente A): a_next_o entrega, de forma
// combinacional, la palabra de a_addr_i (el mux sobre los flip-flops que se
// registra en a_rdata_o). pochoco_soc instancia el core con EarlyRead = 0
// para esta estrategia (conserva la temporización de main), así que el core
// no usa este puerto; existe para que las dos memorias tengan la misma
// interfaz y la elección quede en un solo parámetro (docs/pipeline.md).

module pochoco_mem_ff #(
  parameter integer DataWords = 4
) (
  input  wire        clk_i,
  input  wire        rst_ni,

  // Puerto A: instrucciones
  input  wire        a_req_i,
  input  wire [31:0] a_addr_i,
  output reg  [31:0] a_rdata_o,
  output wire [31:0] a_next_o,    // palabra de a_addr_i, combinacional

  // Puerto B: datos
  input  wire        b_req_i,
  input  wire        b_we_i,
  input  wire [3:0]  b_be_i,
  input  wire [31:0] b_addr_i,
  input  wire [31:0] b_wdata_i,
  output reg  [31:0] b_rdata_o
);

`include "game_image.vh"

  localparam integer Words = GAME_WORDS + DataWords;
  localparam integer AW    = (Words > 1) ? $clog2(Words) : 1;

  wire [AW-1:0] a_word = a_addr_i[AW+1:2];
  wire [AW-1:0] b_word = b_addr_i[AW+1:2];
  wire          a_in   = ({1'b0, a_word} < Words[AW:0]);
  wire          b_in   = ({1'b0, b_word} < Words[AW:0]);
  wire          b_wr   = b_req_i & b_we_i & b_in;

  // Una palabra por bloque: su valor de reset es la palabra del programa
  // (o 0 en la zona de datos), así que la síntesis deja cada bit como un
  // flip-flop con reset o con set según el programa.
  wire [32*Words-1:0] mem_q;

  genvar w;
  generate
    for (w = 0; w < Words; w = w + 1) begin : g_word
      localparam [31:0] Init = (w < GAME_WORDS) ? game_word(w) : 32'b0;

      reg  [31:0] q;
      wire        sel = b_wr & (b_word == w);

      always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          q <= Init;
        end else if (sel) begin
          if (b_be_i[0]) q[7:0]   <= b_wdata_i[7:0];
          if (b_be_i[1]) q[15:8]  <= b_wdata_i[15:8];
          if (b_be_i[2]) q[23:16] <= b_wdata_i[23:16];
          if (b_be_i[3]) q[31:24] <= b_wdata_i[31:24];
        end
      end

      assign mem_q[32*w +: 32] = q;
    end
  endgenerate

  wire [31:0] a_data = a_in ? mem_q[32*a_word +: 32] : 32'b0;
  assign a_next_o = a_data;

  always @(posedge clk_i) begin
    if (a_req_i) a_rdata_o <= a_data;
    b_rdata_o <= b_in ? mem_q[32*b_word +: 32] : 32'b0;
  end

  wire _unused = &{1'b0, a_addr_i[31:AW+2], a_addr_i[1:0],
                         b_addr_i[31:AW+2], b_addr_i[1:0]};
endmodule
