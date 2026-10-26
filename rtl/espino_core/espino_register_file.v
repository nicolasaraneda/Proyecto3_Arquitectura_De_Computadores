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
// Banco de registros de RV32E (x0 a x15) con latches y clock gating
// (Proyecto 3, experimento B5, rama exp/rf-latch).
//
// La versión en flip-flops (main) gasta, por cada uno de los 480 bits, un
// dffq_1 (63,7 µm²) más un mux2_2 de retención (32,9 µm²), porque la
// biblioteca no tiene flip-flops con enable. Acá cada bit es un latq_1
// (43,9 µm²) y cada registro tiene una celda de clock gating icgtp_1 que
// deja pasar un solo pulso de reloj cuando ese registro se escribe: no hay
// mux de retención ni flip-flop.
//
// Temporización, igual vista desde el core: la escritura que el core pide
// (we_i, waddr_i, estables durante el ciclo que termina en el flanco N) arma
// el clock gate del registro destino en la fase baja previa a N; el dato se
// registra en N (wdata_q) y se vuelca a los latches durante la fase alta que
// sigue a N (el pulso del clock gate), que se cierra en el flanco de bajada.
// Una lectura en el flanco N ve el valor anterior y una en el flanco N+1 el
// nuevo, exactamente como con los flip-flops, así que el ID stage y el
// controlador no cambian y la traza ciclo a ciclo es la misma (make equiv).
// Los puertos de lectura siguen registrados (D3); x0 no se almacena y lee 0.
// Para el STA, el enable del clock gate es un camino de medio ciclo (debe
// estar estable antes del flanco de bajada) y el dato tiene medio ciclo más
// la transparencia del latch.

module espino_register_file (
  input  wire        clk_i,
  input  wire        rst_ni,     // sin uso
  input  wire [3:0]  raddr_a_i,
  output reg  [31:0] rdata_a_o,
  input  wire [3:0]  raddr_b_i,
  output reg  [31:0] rdata_b_o,
  input  wire [3:0]  waddr_i,
  input  wire [31:0] wdata_i,
  input  wire        we_i
);

  // Dato registrado: estable durante el pulso del clock gate.
  reg [31:0] wdata_q;
  always @(posedge clk_i) begin
    wdata_q <= wdata_i;
  end

  // Almacenamiento: 15 registros x 32 latches, con un clock gate por registro.
  wire [32*16-1:0] q;   // q[32*r +: 32] es el registro r; el 0 vale 0
  assign q[31:0] = 32'b0;

  genvar r, b;
  generate
    for (r = 1; r < 16; r = r + 1) begin : g_reg
      // El enable es combinacional: el clock gate lo muestrea en la fase baja
      // anterior al flanco en que el core comete la escritura.
      wire en   = we_i && (waddr_i == r[3:0]);
      wire gclk;
      gf180_clock_gate u_cg (.clk_i(clk_i), .en_i(en), .gclk_o(gclk));
      for (b = 0; b < 32; b = b + 1) begin : g_bit
        gf180_latch u_lat (.e_i(gclk), .d_i(wdata_q[b]), .q_o(q[32*r + b]));
      end
    end
  endgenerate

  // Lectura registrada, igual que en main.
  always @(posedge clk_i) begin
    rdata_a_o <= q[32*raddr_a_i +: 32];
    rdata_b_o <= q[32*raddr_b_i +: 32];
  end

  // rst_ni queda sin uso a propósito
  wire _unused = &{1'b0, rst_ni};
endmodule
