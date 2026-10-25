// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// ROM combinacional del programa (estrategia 1 de la sección 3.2). Su
// contenido es la función game_word del include que genera el assembler a
// partir de sw/game.s (rtl/gen/game_image.vh): un case con una palabra por
// dirección. No tiene reloj ni flip-flops; la síntesis la convierte en
// lógica combinacional. Una dirección fuera del programa entrega 0.

module pochoco_rom (
  input  wire [31:0] addr_i,   // dirección de byte
  output reg  [31:0] data_o
);

`include "game_image.vh"

  localparam integer AW = (GAME_WORDS > 1) ? $clog2(GAME_WORDS) : 1;

  wire [AW-1:0] word   = addr_i[AW+1:2];
  wire [31:0]   word32 = {{(32-AW){1'b0}}, word};

  always @* data_o = game_word(word32);

  wire _unused = &{1'b0, addr_i[31:AW+2], addr_i[1:0]};
endmodule
