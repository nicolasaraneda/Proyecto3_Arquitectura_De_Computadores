// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Contador de ciclos (registro CYCLES), agregado en el Proyecto 2 como única
// base de tiempo del SoC: libre, de 32 bits, suma 1 por ciclo desde el reset
// y no se puede detener ni reiniciar por software.
//
// En el Proyecto 2 era un registro dentro de pochoco_periph. En el Proyecto 3
// se separó en su propio módulo, sin cambiar su comportamiento, para que la
// síntesis conserve su jerarquía (instancia u_soc.u_periph.u_cycles) y se
// pueda medir su área y ubicarlo en el layout (secciones 3.3 y 3.6;
// docs/decisiones.md, D12).

module pochoco_cycle_counter (
  input  wire        clk_i,
  input  wire        rst_ni,
  output reg  [31:0] count_o
);

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) count_o <= 32'b0;
    else         count_o <= count_o + 32'd1;
  end

endmodule
