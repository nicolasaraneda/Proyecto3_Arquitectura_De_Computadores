// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Testbench de la simulación post-síntesis (Proyecto 3, sección 3.7). Sirve
// igual para el RTL y para el netlist de celdas estándar porque solo usa los
// puertos de asic_top: no hay referencias jerárquicas a señales internas.
//
//   - Lee los estímulos de un archivo de texto (`ESTIMULOS`): una línea por
//     evento, "<ciclo> <máscara de botones en binario>", en ciclos absolutos
//     contados desde que se suelta rst_n (ciclo 0 = primer flanco de subida de
//     clk con rst_n en 1). Las líneas que empiezan con # son comentarios.
//   - Escribe una traza (`TRAZA`) con una línea por cada cambio de led o del
//     display: "<ciclo> led=<4 bits> disp=<2 dígitos>", con los 7 segmentos
//     decodificados a hexadecimal (activos en alto, orden {G,F,E,D,C,B,A},
//     la tabla de rtl/pochoco_periph.v). Un patrón con bits desconocidos se
//     escribe como X y uno que no corresponde a ningún dígito, como ?.
//   - Termina después de `CICLOS` ciclos. Si la misma traza sale del RTL y del
//     netlist, los dos ejecutan el programa igual, ciclo a ciclo.
//
// Con -DNETLIST el DUT se instancia sin parámetros (el netlist ya los tiene
// horneados: SYNTH_PARAMETERS de asic/sim/config.yaml); sin él, se pasa
// DebounceDivBits=`DIV_BITS` al RTL, que tiene que ser el mismo valor.
// Ver Makefile, objetivo post-synth.

`timescale 1ns/1ps

`ifndef ESTIMULOS
  `define ESTIMULOS "asic/sim/estimulos.txt"
`endif
`ifndef TRAZA
  `define TRAZA "build/post_synth/traza.txt"
`endif
`ifndef CICLOS
  `define CICLOS 4000
`endif
`ifndef DIV_BITS
  `define DIV_BITS 2
`endif

module post_synth_tb;

  reg        clk = 1'b0;
  reg        rst_n = 1'b0;
  reg  [3:0] btn = 4'b0000;
  wire [3:0] led;
  wire [6:0] seg1, seg2;
  wire       spi_miso;

`ifdef NETLIST
  asic_top dut (
`else
  asic_top #(.MemStrategy(1), .DataWords(4), .DebounceDivBits(`DIV_BITS)) dut (
`endif
    .clk      (clk),
    .rst_n    (rst_n),
    .led      (led),
    .btn      (btn),
    .seg1     (seg1),
    .seg2     (seg2),
    .spi_sclk (1'b0),
    .spi_mosi (1'b0),
    .spi_cs_n (1'b1),
    .spi_miso (spi_miso)
  );

  // Período de 100 ns, el del macro (T = 100 ns). En una simulación sin
  // retardos el valor no cambia el resultado.
  always #50 clk = ~clk;

  // Decodificador inverso de 7 segmentos ({G,F,E,D,C,B,A}, activo en alto).
  function [7:0] seg2hex(input [6:0] s);
    begin
      if (^s === 1'bx) seg2hex = "X";
      else case (s)
        7'b0111111: seg2hex = "0";
        7'b0000110: seg2hex = "1";
        7'b1011011: seg2hex = "2";
        7'b1001111: seg2hex = "3";
        7'b1100110: seg2hex = "4";
        7'b1101101: seg2hex = "5";
        7'b1111101: seg2hex = "6";
        7'b0000111: seg2hex = "7";
        7'b1111111: seg2hex = "8";
        7'b1101111: seg2hex = "9";
        7'b1110111: seg2hex = "A";
        7'b1111100: seg2hex = "B";
        7'b0111001: seg2hex = "C";
        7'b1011110: seg2hex = "D";
        7'b1111001: seg2hex = "E";
        7'b1110001: seg2hex = "F";
        default:    seg2hex = "?";
      endcase
    end
  endfunction

  // Estímulos: hasta 256 eventos ordenados por ciclo.
  integer   n_est = 0;
  integer   est_ciclo [0:255];
  reg [3:0] est_btn   [0:255];

  task leer_estimulos;
    integer f, c, k, r;
    reg [3:0] m;
    reg [255:0] linea;
    begin
      f = $fopen(`ESTIMULOS, "r");
      if (f == 0) begin
        $display("post_synth_tb: no se pudo abrir %0s", `ESTIMULOS);
        $finish;
      end
      while (!$feof(f)) begin
        k = $fgets(linea, f);
        if (k > 0 && linea[8*(k-1) +: 8] != "#" && linea[255-:8] != "#") begin
          r = $sscanf(linea, "%d %b", c, m);
          if (r == 2) begin
            est_ciclo[n_est] = c;
            est_btn[n_est]   = m;
            n_est = n_est + 1;
          end
        end
      end
      $fclose(f);
    end
  endtask

  integer ciclo, f_traza, i, cambios, con_x;
  reg [3:0] led_prev;
  reg [6:0] s1_prev, s2_prev;

  initial begin
    leer_estimulos;
    $display("post_synth_tb: %0d eventos de estimulo leidos de %0s", n_est, `ESTIMULOS);
    f_traza = $fopen(`TRAZA, "w");
    cambios = 0;
    con_x   = 0;
    i       = 0;
    // Reset: 4 flancos con rst_n en 0. El sincronizador de asic_top suelta
    // el reset interno dos flancos después de que rst_n sube.
    repeat (4) @(posedge clk);
    #1 rst_n = 1'b1;
    ciclo    = -1;
    led_prev = led;
    s1_prev  = seg1;
    s2_prev  = seg2;
    $fdisplay(f_traza, "%0d led=%b disp=%c%c", 0, led, seg2hex(seg1), seg2hex(seg2));
    forever begin
      @(posedge clk);
      ciclo = ciclo + 1;
      // Estímulos del ciclo actual: se aplican justo después del flanco, así
      // que el DUT los ve en el flanco siguiente.
      while (i < n_est && est_ciclo[i] == ciclo) begin
        #1 btn = est_btn[i];
        i = i + 1;
      end
      #1;
      if (led !== led_prev || seg1 !== s1_prev || seg2 !== s2_prev) begin
        $fdisplay(f_traza, "%0d led=%b disp=%c%c", ciclo, led, seg2hex(seg1), seg2hex(seg2));
        cambios = cambios + 1;
        if (^led === 1'bx || ^seg1 === 1'bx || ^seg2 === 1'bx) con_x = con_x + 1;
      end
      led_prev = led;
      s1_prev  = seg1;
      s2_prev  = seg2;
      if (ciclo >= `CICLOS) begin
        $fclose(f_traza);
        $display("post_synth_tb: %0d ciclos, %0d cambios de salida (%0d con X), traza en %0s",
                 ciclo, cambios, con_x, `TRAZA);
        $finish;
      end
    end
  end

endmodule
