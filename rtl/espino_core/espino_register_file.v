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
//     ciclo después de presentar la dirección, igual que en la BRAM;
//   - un puerto de escritura que nunca escribe x0.
// Con flip-flops ya no hace falta duplicar el banco para tener dos puertos
// de lectura: cada puerto es un multiplexor sobre los mismos registros.
//
// En la BRAM, x0 valía 0 porque la memoria partía en cero (INIT_0) y nunca
// se escribía. En silicio un flip-flop arranca en cualquier valor, así que
// x0 no se almacena: leer la dirección 0 entrega 0 por hardware. x1 a x15
// no tienen reset, igual que en la BRAM.
//
// Proyecto 3, rama exp/pipeline (frente A, docs/pipeline.md): dos agregados
// para la lectura anticipada del banco (EarlyRead del core).
//   - rd_en_i: los puertos de lectura solo se cargan cuando rd_en_i = 1. El
//     core lo deja en 1 con la temporización de main (lee en todos los
//     flancos) y en ~stall con EarlyRead, para conservar los operandos de
//     una carga durante su ciclo de espera.
//   - Write-through: si en el mismo flanco se escribe el registro que se
//     está leyendo (we_i, waddr_i == raddr, waddr_i != 0), la salida
//     registrada toma wdata_i, no el valor viejo del arreglo. Con EarlyRead
//     es lo que resuelve "escritura seguida de lectura" y "carga seguida de
//     uso" (la lectura de operandos de la instrucción siguiente coincide con
//     el flanco del commit de la anterior). Con la temporización de main es
//     inocuo: ahí la lectura que coincide con una escritura es la del ciclo
//     de commit, cuyo valor nadie consume (la instrucción siguiente vuelve a
//     leer en su ciclo de espera); make equiv ciclo a ciclo lo confirma.
// El módulo no tiene parámetros a propósito: la síntesis conserva su
// jerarquía por nombre (SYNTH_KEEP_HIERARCHY_MODULES, D12) y un módulo
// parametrizado cambiaría de nombre en Yosys.

module espino_register_file (
  input  wire        clk_i,
  input  wire        rst_ni,     // sin uso
  input  wire        rd_en_i,    // carga de los puertos de lectura
  input  wire [3:0]  raddr_a_i,
  output reg  [31:0] rdata_a_o,
  input  wire [3:0]  raddr_b_i,
  output reg  [31:0] rdata_b_o,
  input  wire [3:0]  waddr_i,
  input  wire [31:0] wdata_i,
  input  wire        we_i
);

  reg [31:0] regs [1:15];

  wire wr = we_i & (waddr_i != 4'd0);

  always @(posedge clk_i) begin
    if (wr) regs[waddr_i] <= wdata_i;
  end

`ifdef MUTA_FWD
  // MUTACIÓN (solo para la prueba de docs/pipeline.md): sin write-through.
  wire fwd_a = 1'b0;
  wire fwd_b = 1'b0;
`else
  wire fwd_a = wr & (raddr_a_i == waddr_i);
  wire fwd_b = wr & (raddr_b_i == waddr_i);
`endif

  always @(posedge clk_i) begin
    if (rd_en_i) begin
      rdata_a_o <= (raddr_a_i == 4'd0) ? 32'b0 : fwd_a ? wdata_i : regs[raddr_a_i];
      rdata_b_o <= (raddr_b_i == 4'd0) ? 32'b0 : fwd_b ? wdata_i : regs[raddr_b_i];
    end
  end

  // rst_ni queda sin uso a propósito
  wire _unused = &{1'b0, rst_ni};
endmodule
