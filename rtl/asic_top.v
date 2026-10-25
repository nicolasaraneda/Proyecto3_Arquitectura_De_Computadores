// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Módulo superior del macro ASIC. Reemplaza a game_top.v, que exponía los
// pines de la Go Board. Los puertos son las funciones lógicas del juego
// (reloj, reset, LEDs, botones, displays de 7 segmentos y SPI) y no pads
// físicos: en un chip completo cada uno se conectaría a un pad de I/O con
// su protección y su capacidad de manejar carga.
//
// Lo único que agrega sobre pochoco_soc es el sincronizador de reset
// (decisión D6): rst_n se aplica en cualquier momento y se libera
// sincronizado con clk, para que todos los flip-flops salgan del reset en
// el mismo flanco.

module asic_top #(
  parameter NumWords        = 512,
  parameter MemFile         = "sw/game.hex",
  parameter DebounceTicks   = 3,
  parameter DebounceDivBits = 15
) (
  input  wire       clk,
  input  wire       rst_n,      // reset externo, activo en bajo, asíncrono

  output wire [3:0] led,
  input  wire [3:0] btn,        // activos en alto, asíncronos

  output wire [6:0] seg1,       // dígito izquierdo, {G,F,E,D,C,B,A}, activo en alto
  output wire [6:0] seg2,       // dígito derecho,   {G,F,E,D,C,B,A}, activo en alto

  input  wire       spi_sclk,
  input  wire       spi_mosi,
  input  wire       spi_cs_n,
  output wire       spi_miso
);

  // Sincronizador de reset: aserción asíncrona, liberación sincrónica.
  reg [1:0] rst_sync_q;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rst_sync_q <= 2'b00;
    else        rst_sync_q <= {rst_sync_q[0], 1'b1};
  end

  pochoco_soc #(
    .NumWords        (NumWords),
    .MemFile         (MemFile),
    .DebounceTicks   (DebounceTicks),
    .DebounceDivBits (DebounceDivBits)
  ) u_soc (
    .i_Clk        (clk),
    .rst_ni       (rst_sync_q[1]),

    .o_LED        (led),
    .i_Switch     (btn),

    .o_Segment1_A (seg1[0]), .o_Segment1_B (seg1[1]),
    .o_Segment1_C (seg1[2]), .o_Segment1_D (seg1[3]),
    .o_Segment1_E (seg1[4]), .o_Segment1_F (seg1[5]),
    .o_Segment1_G (seg1[6]),
    .o_Segment2_A (seg2[0]), .o_Segment2_B (seg2[1]),
    .o_Segment2_C (seg2[2]), .o_Segment2_D (seg2[3]),
    .o_Segment2_E (seg2[4]), .o_Segment2_F (seg2[5]),
    .o_Segment2_G (seg2[6]),

    .i_SPI_SCLK   (spi_sclk),
    .i_SPI_MOSI   (spi_mosi),
    .i_SPI_CS_n   (spi_cs_n),
    .o_SPI_MISO   (spi_miso)
  );

endmodule
