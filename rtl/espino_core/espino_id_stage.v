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
// Etapa de decodificación y ejecución del Espino Core.
//
// Proyecto 3, rama exp/pipeline (frente A, docs/pipeline.md): lectura
// anticipada del banco de registros y decodificación en el fetch.
//
// EarlyRead = 0 (temporización de main, D18): la instrucción i se carga en
// el registro de instrucción en el flanco N; en el ciclo N espera
// (ops_valid_q = 0) mientras el banco de registros lee rs1 y rs2 y el
// decodificador trabaja sobre instr_rdata_i; en el flanco N+1 se registran
// operandos y decode; en el ciclo N+1 ejecuta y comete en el flanco N+2.
// Dos ciclos por instrucción, tres las cargas.
//
// EarlyRead = 1 (esta rama): la memoria de instrucciones entrega en
// instr_next_i, de forma combinacional, la instrucción de la dirección que
// la etapa IF está pidiendo (pc_q). Con ella se piden al banco de registros
// las direcciones rs1 y rs2 y se decodifica ANTES del flanco N, de modo que
// en el flanco N se cargan a la vez el registro de instrucción (en la
// memoria), los operandos (lectura registrada del banco) y el decode
// registrado. El ciclo de espera desaparece: la instrucción ejecuta en el
// ciclo N y comete en el flanco N+1 (un ciclo por instrucción, dos las
// cargas, dos los saltos tomados por la instrucción secuencial descartada).
// Todo se registra en el flanco "solo si ~stall_i", igual que el PC y el
// registro de instrucción de la etapa IF, así que las tres cosas avanzan
// juntas. Riesgos de datos y cómo se resuelven (ver docs/pipeline.md):
//   - Escritura seguida de lectura del mismo registro: en el flanco N+1 se
//     escribe rd de i y a la vez se registran los operandos de i+1. El banco
//     tiene write-through: si raddr == waddr y we (y waddr != 0) la salida
//     registrada toma wdata_i en vez del valor viejo del arreglo.
//   - Carga seguida de uso: la carga comete en su segundo ciclo (busy de la
//     LSU la detiene un ciclo). Mientras stall_i = 1 el banco no vuelve a
//     leer (rf_rd_en_o = ~stall_i), así que la lectura de operandos de i+1
//     ocurre en el mismo flanco del commit de la carga y el write-through
//     entrega el dato cargado (rf_wdata_o = lsu_rdata_i).
//   - jal/jalr seguido de uso del link: x1 se escribe en el commit del salto
//     (flanco N+1); la instrucción objetivo se carga un flanco después (N+2),
//     cuando el arreglo ya tiene el valor.
//   - Escrituras a x0: el banco no las guarda ni las adelanta; x0 lee 0.
//   - Salto tomado: la instrucción secuencial que se cargó junto con pc_set
//     llega con instr_valid_i = 0; lsu_req_o, rf_we_o y pc_set están
//     condicionados a instr_valid_i, así que su decode y sus operandos
//     (leídos y registrados igual) no tienen efecto.
// rf_waddr_o (rd) se toma del registro de instrucción, que se carga en el
// mismo flanco y con la misma condición que el decode registrado.

module espino_id_stage #(
  parameter integer EarlyRead = 0   // 1: operandos y decode registrados en el fetch
) (
  input  wire        clk_i,
  input  wire        rst_ni,

  input  wire        instr_valid_i,
  input  wire [31:0] instr_rdata_i,   // registro de instrucción (instrucción actual)
  input  wire [31:0] instr_next_i,    // instrucción combinacional de la dirección pedida (EarlyRead)
  input  wire [31:0] pc_id_i,
  input  wire        stall_i,

  // Register file
  output wire [3:0]  rf_raddr_a_o,
  output wire [3:0]  rf_raddr_b_o,
  output wire        rf_rd_en_o,
  input  wire [31:0] rf_rdata_a_i,
  input  wire [31:0] rf_rdata_b_i,
  output wire [3:0]  rf_waddr_o,
  output reg  [31:0] rf_wdata_o,
  output wire        rf_we_o,

  // LSU control
  output wire        lsu_req_o,
  output wire        lsu_we_o,
  output wire [1:0]  lsu_type_o,
  output wire        lsu_sign_o,
  output wire [31:0] lsu_addr_o,
  output wire [31:0] lsu_wdata_o,
  input  wire [31:0] lsu_rdata_i,

  // Control transfer
  output wire        branch_taken_o,
  output wire        jump_o,
  output wire [31:0] pc_target_o,

  // Sync-read handshake to controller
  output wire        rf_ready_o,

  output wire        illegal_insn_o
);

  localparam [1:0] OP_A_PC   = 2'd1;
  localparam [1:0] OP_A_ZERO = 2'd2;
  localparam       OP_B_IMM  = 1'b1;
  localparam [1:0] WD_LSU    = 2'd1;
  localparam [1:0] WD_PC4    = 2'd2;

  // Instrucción que se decodifica y cuyos registros se piden al banco:
  // la que viene de la memoria (EarlyRead) o la del registro de instrucción.
  wire [31:0] dec_instr = (EarlyRead != 0) ? instr_next_i : instr_rdata_i;

  // Register addresses. rd siempre sale del registro de instrucción.
  assign rf_raddr_a_o = dec_instr[18:15];
  assign rf_raddr_b_o = dec_instr[23:20];
  assign rf_waddr_o   = instr_rdata_i[10:7];

  // ---- Ciclo de espera (solo EarlyRead = 0) y enable de lectura del banco ----
  wire advance = ~stall_i;
  wire dec_load;   // flanco en que se registran decode y operandos

  generate
    if (EarlyRead != 0) begin : g_early
      // Sin ciclo de espera: la instrucción llega con sus operandos. El banco
      // solo vuelve a leer cuando el pipeline avanza (mismo enable que el PC
      // y el registro de instrucción); durante el stall de una carga conserva
      // los operandos de la carga (la LSU alinea el dato con addr_i[1:0] en
      // su segundo ciclo) y la lectura siguiente coincide con el commit.
      assign rf_ready_o = 1'b1;
      assign dec_load   = advance;
`ifdef MUTA_LOADUSE
      // MUTACIÓN (solo para la prueba de docs/pipeline.md): el enable de
      // lectura usa el stall registrado, así que la lectura de operandos de
      // la instrucción que sigue a una carga ocurre un flanco antes del
      // commit de la carga y no se repite en el flanco del commit: el uso
      // inmediato del registro cargado ve el valor viejo.
      reg stall_q;
      always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) stall_q <= 1'b0;
        else         stall_q <= stall_i;
      end
      assign rf_rd_en_o = ~stall_q;
`else
      assign rf_rd_en_o = advance;
`endif
    end else begin : g_wait
      // Temporización de main (D18): un ciclo de espera por instrucción
      // mientras el banco lee rs1 y rs2 del registro de instrucción.
      reg ops_valid_q;
      always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)      ops_valid_q <= 1'b0;
        else if (advance) ops_valid_q <= 1'b0;
        else              ops_valid_q <= 1'b1;
      end
      assign rf_ready_o = ops_valid_q;
      assign dec_load   = ~ops_valid_q;
      assign rf_rd_en_o = 1'b1;   // el banco lee en todos los flancos, como en main
      wire _unused_next = &{1'b0, instr_next_i};
    end
  endgenerate

  // Decode, registrado (pre-decodificación, D18). Con EarlyRead = 0 el
  // decodificador trabaja sobre el registro de instrucción durante el ciclo
  // de espera; con EarlyRead = 1 trabaja sobre instr_next_i durante el ciclo
  // anterior al flanco en que se carga la instrucción, y sus salidas se
  // registran en ese mismo flanco. En ambos casos el decode sale de las
  // rutas de ejecución.
  //
  // Los registros no necesitan reset: todo lo que los usa está condicionado
  // a rf_ready_o (lsu_req_o) o a commit (instr_valid_i), que valen 0 hasta
  // que se cargó una instrucción válida con su decode.
  wire [3:0]  alu_operator_d;
  wire [1:0]  alu_op_a_sel_d;
  wire        alu_op_b_sel_d;
  wire [31:0] imm_operand_d, imm_target_d;
  wire        rf_we_d;
  wire [1:0]  rf_wd_sel_d;
  wire        is_branch_d, is_jal_d, is_jalr_d;
  wire        lsu_req_d, lsu_we_d;
  wire [1:0]  lsu_type_d;
  wire        lsu_sign_d;

  espino_decoder u_decoder (
    .instr_i        (dec_instr),
    .illegal_insn_o (illegal_insn_o),
    .alu_operator_o (alu_operator_d),
    .alu_op_a_sel_o (alu_op_a_sel_d),
    .alu_op_b_sel_o (alu_op_b_sel_d),
    .imm_operand_o  (imm_operand_d),
    .imm_target_o   (imm_target_d),
    .rf_we_o        (rf_we_d),
    .rf_wd_sel_o    (rf_wd_sel_d),
    .is_branch_o    (is_branch_d),
    .is_jal_o       (is_jal_d),
    .is_jalr_o      (is_jalr_d),
    .lsu_req_o      (lsu_req_d),
    .lsu_we_o       (lsu_we_d),
    .lsu_type_o     (lsu_type_d),
    .lsu_sign_o     (lsu_sign_d)
  );

  reg  [3:0]  alu_operator;
  reg  [1:0]  alu_op_a_sel;
  reg         alu_op_b_sel;
  reg  [31:0] imm_operand, imm_target;
  reg         rf_we_dec;
  reg  [1:0]  rf_wd_sel;
  reg         is_branch, is_jal, is_jalr;
  reg         lsu_req_dec, lsu_we_dec;
  reg  [1:0]  lsu_type_dec;
  reg         lsu_sign_dec;

  always @(posedge clk_i) begin
    if (dec_load) begin
      alu_operator <= alu_operator_d;
      alu_op_a_sel <= alu_op_a_sel_d;
      alu_op_b_sel <= alu_op_b_sel_d;
      imm_operand  <= imm_operand_d;
      imm_target   <= imm_target_d;
      rf_we_dec    <= rf_we_d;
      rf_wd_sel    <= rf_wd_sel_d;
      is_branch    <= is_branch_d;
      is_jal       <= is_jal_d;
      is_jalr      <= is_jalr_d;
      lsu_req_dec  <= lsu_req_d;
      lsu_we_dec   <= lsu_we_d;
      lsu_type_dec <= lsu_type_d;
      lsu_sign_dec <= lsu_sign_d;
    end
  end

  // Operand muxes
  reg  [31:0] operand_a;
  wire [31:0] operand_b;
  always @* begin
    case (alu_op_a_sel)
      OP_A_PC:   operand_a = pc_id_i;
      OP_A_ZERO: operand_a = 32'b0;
      default:   operand_a = rf_rdata_a_i;
    endcase
  end
  assign operand_b = (alu_op_b_sel == OP_B_IMM) ? imm_operand : rf_rdata_b_i;

  wire [31:0] alu_result;
  wire        alu_cmp_result;
  espino_alu u_alu (
    .operator_i   (alu_operator),
    .operand_a_i  (operand_a),
    .operand_b_i  (operand_b),
    .result_o     (alu_result),
    .cmp_result_o (alu_cmp_result)
  );

  // LSU control
  assign lsu_req_o   = lsu_req_dec & instr_valid_i & rf_ready_o;
  assign lsu_we_o    = lsu_we_dec;
  assign lsu_type_o  = lsu_type_dec;
  assign lsu_sign_o  = lsu_sign_dec;
  assign lsu_addr_o  = alu_result;
  assign lsu_wdata_o = rf_rdata_b_i;

  // Control transfer
  assign branch_taken_o = is_branch & alu_cmp_result;
  assign jump_o         = is_jal | is_jalr;
  assign pc_target_o    = is_jalr ? (alu_result & ~32'h1)
                                  : (pc_id_i + imm_target);

  wire commit = instr_valid_i & ~stall_i;

  always @* begin
    case (rf_wd_sel)
      WD_LSU:  rf_wdata_o = lsu_rdata_i;
      WD_PC4:  rf_wdata_o = pc_id_i + 32'd4;
      default: rf_wdata_o = alu_result;
    endcase
  end

  assign rf_we_o = rf_we_dec & commit;

endmodule
