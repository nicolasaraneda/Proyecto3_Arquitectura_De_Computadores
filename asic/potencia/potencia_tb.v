// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Testbench para la potencia con actividad real (Proyecto 3, frente D3).
// Copia adaptada de tb/post_synth_tb.v: el mismo reset, los mismos estimulos
// (asic/sim/estimulos_final.txt) y la misma traza de salidas, mas una ventana
// de ciclos [ini, fin) en la que se vuelca un VCD con TODAS las senales del
// DUT para que OpenSTA tenga la actividad de cada net: $dumpvars(`PROF, dut)
// con PROF = 2, o sea los nets del netlist plano y ademas los puertos de cada
// celda (cada instancia es un $scope del VCD y sus puertos quedan como
// <instancia>/<puerto>). Hace falta porque el read_vcd de OpenSTA 2.7.0
// anota actividad por nombre de PIN (<instancia>/<puerto>), no por nombre de
// net: con profundidad 1 solo anota los 28 puertos del macro (comprobado,
// ver asic/potencia/resultado.md). Icarus da el mismo codigo de VCD al net y a
// los puertos conectados a el, asi que el archivo crece solo en la cabecera.
//
//   +ini=<ciclo>    primer ciclo de la ventana: $dumpvars en su flanco de subida
//   +fin=<ciclo>    ciclo en el que termina la simulacion ($finish en su flanco
//                   de subida; la ventana dura fin-ini ciclos exactos)
//   +vcd=<archivo>  VCD de salida
//   +traza=<archivo> traza de salidas (misma forma que tb/post_synth_tb.v)
//   +pc=<archivo>   solo con -DRTL: histograma del PC dentro de la ventana
//                   (ciclos por direccion de instruccion), para justificar
//                   que ciclos cubre cada ventana
//
// Con -DRTL se instancia el RTL (DebounceDivBits=`DIV_BITS, 15 como en el
// macro) y NO se escribe VCD: sirve para el histograma del PC, que el
// netlist plano no permite leer. Sin -DRTL el DUT es el netlist (sin
// parametros: los tiene horneados). Los ciclos se cuentan como en
// tb/post_synth_tb.v: ciclo 0 = primer flanco de subida con rst_n en 1.

`timescale 1ns/1ps

`ifndef ESTIMULOS
  `define ESTIMULOS "asic/sim/estimulos_final.txt"
`endif
`ifndef DIV_BITS
  `define DIV_BITS 15
`endif
`ifndef PROF
  `define PROF 2
`endif

module potencia_tb;

  reg        clk = 1'b0;
  reg        rst_n = 1'b0;
  reg  [3:0] btn = 4'b0000;
  wire [3:0] led;
  wire [6:0] seg1, seg2;
  wire       spi_miso;

`ifdef RTL
  asic_top #(.MemStrategy(1), .DataWords(4), .DebounceDivBits(`DIV_BITS)) dut (
`else
  asic_top dut (
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

  // Periodo de 100 ns, el del macro: la actividad que calcula OpenSTA es
  // "transiciones por periodo de reloj" y usa el periodo de la SDC (100 ns),
  // asi que el tiempo del VCD tiene que ir en la misma escala.
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

  // Estimulos: hasta 256 eventos ordenados por ciclo.
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
        $display("potencia_tb: no se pudo abrir %0s", `ESTIMULOS);
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

  // Ventana y archivos, por plusargs.
  integer ini, fin;
  string  vcd_nombre, traza_nombre, pc_nombre;

`ifdef RTL
  // Histograma del PC dentro de la ventana: una entrada por palabra de la
  // ROM (115 palabras de programa, 7 bits de direccion de palabra).
  integer pc_hist [0:127];
  integer pc_fuera, k;
  reg [31:0] pc_ahora;
  initial begin
    for (k = 0; k < 128; k = k + 1) pc_hist[k] = 0;
    pc_fuera = 0;
  end
`endif

  integer ciclo, f_traza, f_pc, i, cambios, con_x;
  reg [3:0] led_prev;
  reg [6:0] s1_prev, s2_prev;

  initial begin
    if (!$value$plusargs("ini=%d", ini)) ini = 500;
    if (!$value$plusargs("fin=%d", fin)) fin = 20500;
    if (!$value$plusargs("vcd=%s", vcd_nombre)) vcd_nombre = "build/potencia/ventana.vcd";
    if (!$value$plusargs("traza=%s", traza_nombre)) traza_nombre = "build/potencia/traza.txt";
    if (!$value$plusargs("pc=%s", pc_nombre)) pc_nombre = "build/potencia/pc_hist.txt";
    leer_estimulos;
    $display("potencia_tb: %0d eventos de estimulo leidos de %0s; ventana [%0d, %0d)",
             n_est, `ESTIMULOS, ini, fin);
    f_traza = $fopen(traza_nombre, "w");
    cambios = 0;
    con_x   = 0;
    i       = 0;
    // Reset: 4 flancos con rst_n en 0. El sincronizador de asic_top suelta
    // el reset interno dos flancos despues de que rst_n sube.
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
      if (ciclo == fin) begin
        // Fin de la ventana en el flanco de subida: el ultimo instante del
        // VCD es este flanco (clk sube), asi que el VCD abarca fin-ini
        // periodos exactos.
        $display("potencia_tb: fin de la ventana en el ciclo %0d, t = %0t", ciclo, $time);
`ifdef RTL
        f_pc = $fopen(pc_nombre, "w");
        for (k = 0; k < 128; k = k + 1)
          if (pc_hist[k] > 0) $fdisplay(f_pc, "0x%04x %0d", k * 4, pc_hist[k]);
        if (pc_fuera > 0) $fdisplay(f_pc, "fuera %0d", pc_fuera);
        $fclose(f_pc);
`else
        $dumpflush;
`endif
        $fclose(f_traza);
        $display("potencia_tb: %0d ciclos, %0d cambios de salida (%0d con X), traza en %0s",
                 ciclo, cambios, con_x, traza_nombre);
        $finish;
      end
      if (ciclo == ini) begin
`ifndef RTL
        $dumpfile(vcd_nombre);
        $dumpvars(`PROF, dut);
`endif
        $display("potencia_tb: inicio de la ventana en el ciclo %0d, t = %0t", ciclo, $time);
      end
      // Estimulos del ciclo actual: se aplican justo despues del flanco, asi
      // que el DUT los ve en el flanco siguiente.
      while (i < n_est && est_ciclo[i] == ciclo) begin
        #1 btn = est_btn[i];
        i = i + 1;
      end
      #1;
`ifdef RTL
      if (ciclo >= ini) begin
        pc_ahora = dut.u_soc.u_core.u_if.pc_q;
        if (pc_ahora < 32'd512) pc_hist[pc_ahora[8:2]] = pc_hist[pc_ahora[8:2]] + 1;
        else                    pc_fuera = pc_fuera + 1;
      end
`endif
      if (led !== led_prev || seg1 !== s1_prev || seg2 !== s2_prev) begin
        $fdisplay(f_traza, "%0d led=%b disp=%c%c", ciclo, led, seg2hex(seg1), seg2hex(seg2));
        cambios = cambios + 1;
        if (^led === 1'bx || ^seg1 === 1'bx || ^seg2 === 1'bx) con_x = con_x + 1;
      end
      led_prev = led;
      s1_prev  = seg1;
      s2_prev  = seg2;
    end
  end

endmodule
