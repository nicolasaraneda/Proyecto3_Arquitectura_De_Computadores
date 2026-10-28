// Generado por asic/eqy/miter_reset.py (frente D2). Miter de asic_top gold y gate desde reset.
module miter_reset (
  input  wire       clk,
  input  wire       rst_n_libre,
  input  wire [3:0] btn,
  input  wire       spi_sclk, spi_mosi, spi_cs_n
);
  // Ciclos desde el inicio (satura en 7): reset forzado en los ciclos 0 y 1,
  // comparación de salidas desde el ciclo 2.
  reg [2:0] ciclo = 3'd0;
  always @(posedge clk) if (ciclo != 3'd7) ciclo <= ciclo + 3'd1;
  wire rst_n = (ciclo < 3'd2) ? 1'b0 : rst_n_libre;

  wire [3:0] led_gold, led_gate;
  wire [6:0] seg1_gold, seg1_gate, seg2_gold, seg2_gate;
  wire       miso_gold, miso_gate;

  // Los RTLIL canónicos pasaron por "splitnets -ports": cada bit de un bus es un
  // puerto propio (\led[0], \seg2[6], ...), así que se conectan bit a bit.
  gold_top gold (.clk(clk), .rst_n(rst_n), .\led[0] (led_gold[0]), .\led[1] (led_gold[1]), .\led[2] (led_gold[2]), .\led[3] (led_gold[3]), .\btn[0] (btn[0]), .\btn[1] (btn[1]), .\btn[2] (btn[2]), .\btn[3] (btn[3]), .\seg1[0] (seg1_gold[0]), .\seg1[1] (seg1_gold[1]), .\seg1[2] (seg1_gold[2]), .\seg1[3] (seg1_gold[3]), .\seg1[4] (seg1_gold[4]), .\seg1[5] (seg1_gold[5]), .\seg1[6] (seg1_gold[6]), .\seg2[0] (seg2_gold[0]), .\seg2[1] (seg2_gold[1]), .\seg2[2] (seg2_gold[2]), .\seg2[3] (seg2_gold[3]), .\seg2[4] (seg2_gold[4]), .\seg2[5] (seg2_gold[5]), .\seg2[6] (seg2_gold[6]),
                 .spi_sclk(spi_sclk), .spi_mosi(spi_mosi), .spi_cs_n(spi_cs_n), .spi_miso(miso_gold));
  gate_top gate (.clk(clk), .rst_n(rst_n), .\led[0] (led_gate[0]), .\led[1] (led_gate[1]), .\led[2] (led_gate[2]), .\led[3] (led_gate[3]), .\btn[0] (btn[0]), .\btn[1] (btn[1]), .\btn[2] (btn[2]), .\btn[3] (btn[3]), .\seg1[0] (seg1_gate[0]), .\seg1[1] (seg1_gate[1]), .\seg1[2] (seg1_gate[2]), .\seg1[3] (seg1_gate[3]), .\seg1[4] (seg1_gate[4]), .\seg1[5] (seg1_gate[5]), .\seg1[6] (seg1_gate[6]), .\seg2[0] (seg2_gate[0]), .\seg2[1] (seg2_gate[1]), .\seg2[2] (seg2_gate[2]), .\seg2[3] (seg2_gate[3]), .\seg2[4] (seg2_gate[4]), .\seg2[5] (seg2_gate[5]), .\seg2[6] (seg2_gate[6]),
                 .spi_sclk(spi_sclk), .spi_mosi(spi_mosi), .spi_cs_n(spi_cs_n), .spi_miso(miso_gate));

  always @* begin
    if (ciclo >= 3'd2) begin
      assert (led_gold  == led_gate);
      assert (seg1_gold == seg1_gate);
      assert (seg2_gold == seg2_gate);
      assert (miso_gold == miso_gate);
    end
  end
endmodule
