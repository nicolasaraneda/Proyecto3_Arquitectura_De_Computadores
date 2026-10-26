// Generado por assembler/asm.py a partir de sw/game.s.
// No editar a mano: se regenera desde el .s (ver Makefile, objetivo image).
//
// ROM combinacional del programa (estrategia 1 de la sección 3.2): un case
// con una palabra por dirección. No tiene reloj ni flip-flops; la síntesis
// la convierte en lógica combinacional. Una dirección fuera del programa
// entrega 0.
// 115 palabras de programa (460 bytes), 7 bits de dirección de palabra.

module pochoco_rom (
  input  wire [31:0] addr_i,   // dirección de byte
  output reg  [31:0] data_o
);

  wire [6:0] word = addr_i[8:2];

  always @* begin
    case (word)
      7'd0  : data_o = 32'h80000137;  // 0x0000: lui x2, 0x80000
      7'd1  : data_o = 32'h04c12237;  // 0x0004: lui x4, 0x4c12
      7'd2  : data_o = 32'hdb720213;  // 0x0008: addi x4, x4, -585
      7'd3  : data_o = 32'h00100193;  // 0x000c: addi x3, x0, 1
      7'd4  : data_o = 32'h00000293;  // 0x0010: addi x5, x0, 0
      7'd5  : data_o = 32'h00000313;  // 0x0014: addi x6, x0, 0
      7'd6  : data_o = 32'h00000493;  // 0x0018: addi x9, x0, 0
      7'd7  : data_o = 32'h00912023;  // 0x001c: sw x9, 0(x2)
      7'd8  : data_o = 32'h00012223;  // 0x0020: sw x0, 4(x2)
      7'd9  : data_o = 32'h00812483;  // 0x0024: lw x9, 8(x2)
      7'd10 : data_o = 32'hfe048ee3;  // 0x0028: beq x9, x0, L0024
      7'd11 : data_o = 32'h00c12183;  // 0x002c: lw x3, 12(x2)
      7'd12 : data_o = 32'h00019463;  // 0x0030: bne x3, x0, L0038
      7'd13 : data_o = 32'h00100193;  // 0x0034: addi x3, x0, 1
      7'd14 : data_o = 32'h00812483;  // 0x0038: lw x9, 8(x2)
      7'd15 : data_o = 32'hfe049ee3;  // 0x003c: bne x9, x0, L0038
      7'd16 : data_o = 32'h00f00493;  // 0x0040: addi x9, x0, 15
      7'd17 : data_o = 32'h00912223;  // 0x0044: sw x9, 4(x2)
      7'd18 : data_o = 32'h00128513;  // 0x0048: addi x10, x5, 1
      7'd19 : data_o = 32'h124000ef;  // 0x004c: jal x1, L0170
      7'd20 : data_o = 32'h01e00513;  // 0x0050: addi x10, x0, 30
      7'd21 : data_o = 32'h144000ef;  // 0x0054: jal x1, L0198
      7'd22 : data_o = 32'h00812483;  // 0x0058: lw x9, 8(x2)
      7'd23 : data_o = 32'hfe049ee3;  // 0x005c: bne x9, x0, L0058
      7'd24 : data_o = 32'h0031f493;  // 0x0060: andi x9, x3, 3
      7'd25 : data_o = 32'h00100393;  // 0x0064: addi x7, x0, 1
      7'd26 : data_o = 32'h00048863;  // 0x0068: beq x9, x0, L0078
      7'd27 : data_o = 32'h007383b3;  // 0x006c: add x7, x7, x7
      7'd28 : data_o = 32'hfff48493;  // 0x0070: addi x9, x9, -1
      7'd29 : data_o = 32'hff5ff06f;  // 0x0074: jal x0, L0068
      7'd30 : data_o = 32'h00712223;  // 0x0078: sw x7, 4(x2)
      7'd31 : data_o = 32'h00c12403;  // 0x007c: lw x8, 12(x2)
      7'd32 : data_o = 32'h00812483;  // 0x0080: lw x9, 8(x2)
      7'd33 : data_o = 32'h0001c663;  // 0x0084: blt x3, x0, L0090
      7'd34 : data_o = 32'h003181b3;  // 0x0088: add x3, x3, x3
      7'd35 : data_o = 32'h00c0006f;  // 0x008c: jal x0, L0098
      7'd36 : data_o = 32'h003181b3;  // 0x0090: add x3, x3, x3
      7'd37 : data_o = 32'h0041c1b3;  // 0x0094: xor x3, x3, x4
      7'd38 : data_o = 32'hfe0484e3;  // 0x0098: beq x9, x0, L0080
      7'd39 : data_o = 32'h00748e63;  // 0x009c: beq x9, x7, L00b8
      7'd40 : data_o = 32'h0ee00493;  // 0x00a0: addi x9, x0, 238
      7'd41 : data_o = 32'h00912023;  // 0x00a4: sw x9, 0(x2)
      7'd42 : data_o = 32'h00012223;  // 0x00a8: sw x0, 4(x2)
      7'd43 : data_o = 32'h00a00513;  // 0x00ac: addi x10, x0, 10
      7'd44 : data_o = 32'h0e8000ef;  // 0x00b0: jal x1, L0198
      7'd45 : data_o = 32'hf8dff06f;  // 0x00b4: jal x0, L0040
      7'd46 : data_o = 32'h00c12483;  // 0x00b8: lw x9, 12(x2)
      7'd47 : data_o = 32'h40848533;  // 0x00bc: sub x10, x9, x8
      7'd48 : data_o = 32'h084007ef;  // 0x00c0: jal x15, L0144
      7'd49 : data_o = 32'h00a30333;  // 0x00c4: add x6, x6, x10
      7'd50 : data_o = 32'h00128293;  // 0x00c8: addi x5, x5, 1
      7'd51 : data_o = 32'h0a4000ef;  // 0x00cc: jal x1, L0170
      7'd52 : data_o = 32'h00c00513;  // 0x00d0: addi x10, x0, 12
      7'd53 : data_o = 32'h0c4000ef;  // 0x00d4: jal x1, L0198
      7'd54 : data_o = 32'h00a00493;  // 0x00d8: addi x9, x0, 10
      7'd55 : data_o = 32'hf69292e3;  // 0x00dc: bne x5, x9, L0040
      7'd56 : data_o = 32'h0aa00493;  // 0x00e0: addi x9, x0, 170
      7'd57 : data_o = 32'h00912023;  // 0x00e4: sw x9, 0(x2)
      7'd58 : data_o = 32'h00a00513;  // 0x00e8: addi x10, x0, 10
      7'd59 : data_o = 32'h0ac000ef;  // 0x00ec: jal x1, L0198
      7'd60 : data_o = 32'h00030513;  // 0x00f0: addi x10, x6, 0
      7'd61 : data_o = 32'h00a00613;  // 0x00f4: addi x12, x0, 10
      7'd62 : data_o = 32'h028007ef;  // 0x00f8: jal x15, L0120
      7'd63 : data_o = 32'h074000ef;  // 0x00fc: jal x1, L0170
      7'd64 : data_o = 32'h00000393;  // 0x0100: addi x7, x0, 0
      7'd65 : data_o = 32'h00f3c393;  // 0x0104: xori x7, x7, 15
      7'd66 : data_o = 32'h00712223;  // 0x0108: sw x7, 4(x2)
      7'd67 : data_o = 32'h00500513;  // 0x010c: addi x10, x0, 5
      7'd68 : data_o = 32'h088000ef;  // 0x0110: jal x1, L0198
      7'd69 : data_o = 32'h00812483;  // 0x0114: lw x9, 8(x2)
      7'd70 : data_o = 32'hfe0486e3;  // 0x0118: beq x9, x0, L0104
      7'd71 : data_o = 32'hee5ff06f;  // 0x011c: jal x0, L0000
      7'd72 : data_o = 32'h00000493;  // 0x0120: addi x9, x0, 0
      7'd73 : data_o = 32'h00060a63;  // 0x0124: beq x12, x0, L0138
      7'd74 : data_o = 32'h00c56863;  // 0x0128: bltu x10, x12, L0138
      7'd75 : data_o = 32'h40c50533;  // 0x012c: sub x10, x10, x12
      7'd76 : data_o = 32'h00148493;  // 0x0130: addi x9, x9, 1
      7'd77 : data_o = 32'hff5ff06f;  // 0x0134: jal x0, L0128
      7'd78 : data_o = 32'h00050593;  // 0x0138: addi x11, x10, 0
      7'd79 : data_o = 32'h00048513;  // 0x013c: addi x10, x9, 0
      7'd80 : data_o = 32'h00078067;  // 0x0140: jalr x0, 0(x15)
      7'd81 : data_o = 32'h00000493;  // 0x0144: addi x9, x0, 0
      7'd82 : data_o = 32'h000f4637;  // 0x0148: lui x12, 0xf4
      7'd83 : data_o = 32'h24060613;  // 0x014c: addi x12, x12, 576
      7'd84 : data_o = 32'h06300693;  // 0x0150: addi x13, x0, 99
      7'd85 : data_o = 32'h00d48a63;  // 0x0154: beq x9, x13, L0168
      7'd86 : data_o = 32'h00c56863;  // 0x0158: bltu x10, x12, L0168
      7'd87 : data_o = 32'h40c50533;  // 0x015c: sub x10, x10, x12
      7'd88 : data_o = 32'h00148493;  // 0x0160: addi x9, x9, 1
      7'd89 : data_o = 32'hff1ff06f;  // 0x0164: jal x0, L0154
      7'd90 : data_o = 32'h00048513;  // 0x0168: addi x10, x9, 0
      7'd91 : data_o = 32'h00078067;  // 0x016c: jalr x0, 0(x15)
      7'd92 : data_o = 32'h00a00613;  // 0x0170: addi x12, x0, 10
      7'd93 : data_o = 32'hfadff7ef;  // 0x0174: jal x15, L0120
      7'd94 : data_o = 32'h00050493;  // 0x0178: addi x9, x10, 0
      7'd95 : data_o = 32'h009484b3;  // 0x017c: add x9, x9, x9
      7'd96 : data_o = 32'h009484b3;  // 0x0180: add x9, x9, x9
      7'd97 : data_o = 32'h009484b3;  // 0x0184: add x9, x9, x9
      7'd98 : data_o = 32'h009484b3;  // 0x0188: add x9, x9, x9
      7'd99 : data_o = 32'h00b484b3;  // 0x018c: add x9, x9, x11
      7'd100: data_o = 32'h00912023;  // 0x0190: sw x9, 0(x2)
      7'd101: data_o = 32'h00008067;  // 0x0194: jalr x0, 0(x1)
      7'd102: data_o = 32'h00000593;  // 0x0198: addi x11, x0, 0
      7'd103: data_o = 32'h000f4637;  // 0x019c: lui x12, 0xf4
      7'd104: data_o = 32'h24060613;  // 0x01a0: addi x12, x12, 576
      7'd105: data_o = 32'h00050693;  // 0x01a4: addi x13, x10, 0
      7'd106: data_o = 32'h00068863;  // 0x01a8: beq x13, x0, L01b8
      7'd107: data_o = 32'h00c585b3;  // 0x01ac: add x11, x11, x12
      7'd108: data_o = 32'hfff68693;  // 0x01b0: addi x13, x13, -1
      7'd109: data_o = 32'hff5ff06f;  // 0x01b4: jal x0, L01a8
      7'd110: data_o = 32'h00c12483;  // 0x01b8: lw x9, 12(x2)
      7'd111: data_o = 32'h00c12683;  // 0x01bc: lw x13, 12(x2)
      7'd112: data_o = 32'h40968733;  // 0x01c0: sub x14, x13, x9
      7'd113: data_o = 32'hfeb76ce3;  // 0x01c4: bltu x14, x11, L01bc
      7'd114: data_o = 32'h00008067;  // 0x01c8: jalr x0, 0(x1)
      default: data_o = 32'h00000000;
    endcase
  end

  wire _unused = &{1'b0, addr_i[31:9], addr_i[1:0]};
endmodule
