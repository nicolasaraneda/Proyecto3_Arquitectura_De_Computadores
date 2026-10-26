// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Traza del core para comparar dos versiones del RTL (Proyecto 3, D18).
// Corre el programa de la imagen que se le pasa con -I (por defecto,
// sw/isa_test.s) durante CICLOS ciclos después del reset y escribe en
// TRAZA, una línea por evento y con el número de ciclo:
//   - cada escritura al banco de registros (registro y valor);
//   - cada acceso al bus de datos (lectura o escritura, bytes, dirección y
//     dato escrito);
//   - cada cambio de LEDs y display.
// Si dos versiones del RTL producen la misma traza, ejecutan el programa
// igual, ciclo a ciclo. Ver Makefile, objetivo trace.

`timescale 1ns/1ps

`ifndef MEM_STRATEGY
  `define MEM_STRATEGY 1
`endif
`ifndef TRAZA
  `define TRAZA "build/traza.txt"
`endif
`ifndef CICLOS
  `define CICLOS 3000
`endif

module core_trace_tb;

  reg        clk = 1'b0;
  reg        rst_n = 1'b0;
  wire [3:0] led;
  wire [6:0] seg1, seg2;

  asic_top #(.MemStrategy(`MEM_STRATEGY)) dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .led      (led),
    .btn      (4'b0000),
    .seg1     (seg1),
    .seg2     (seg2),
    .spi_sclk (1'b0),
    .spi_mosi (1'b0),
    .spi_cs_n (1'b1),
    .spi_miso ()
  );

  always #20 clk = ~clk;

  integer f, ciclo;
  reg [3:0]  led_prev;
  reg [13:0] seg_prev;

  initial begin
    f = $fopen(`TRAZA, "w");
    repeat (4) @(posedge clk);
    #1 rst_n = 1'b1;
    wait (dut.u_soc.rst_ni);
    ciclo    = 0;
    led_prev = led;
    seg_prev = {seg1, seg2};
    repeat (`CICLOS) begin
      @(posedge clk);
      ciclo = ciclo + 1;
      if (dut.u_soc.u_core.rf_we)
        $fdisplay(f, "%0d rf x%0d = %h", ciclo,
                  dut.u_soc.u_core.rf_waddr, dut.u_soc.u_core.rf_wdata);
      if (dut.u_soc.u_core.data_req_o)
        $fdisplay(f, "%0d bus %s be=%b addr=%h wdata=%h", ciclo,
                  dut.u_soc.u_core.data_we_o ? "W" : "R",
                  dut.u_soc.u_core.data_be_o, dut.u_soc.u_core.data_addr_o,
                  dut.u_soc.u_core.data_wdata_o);
      if (led !== led_prev || {seg1, seg2} !== seg_prev)
        $fdisplay(f, "%0d io led=%b seg=%b_%b", ciclo, led, seg1, seg2);
      led_prev = led;
      seg_prev = {seg1, seg2};
    end
    $fclose(f);
    $display("core_trace_tb: %0d ciclos, traza en %0s", `CICLOS, `TRAZA);
    $finish;
  end

endmodule
