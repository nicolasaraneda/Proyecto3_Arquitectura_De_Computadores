// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
// 
// Authors:
// - Nicolás Villegas <navillegas@miuandes.cl>

module espino_id_stage (
  input  wire        clk_i,
  input  wire        rst_ni,

  input  wire        instr_valid_i,
  input  wire [31:0] instr_rdata_i,
  input  wire [31:0] pc_id_i,
  input  wire        stall_i,

  // Register file
  output wire [3:0]  rf_raddr_a_o,
  output wire [3:0]  rf_raddr_b_o,
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

  // Register addresses
  assign rf_raddr_a_o = instr_rdata_i[18:15];
  assign rf_raddr_b_o = instr_rdata_i[23:20];
  assign rf_waddr_o   = instr_rdata_i[10:7];

  // ---- synchronous-read wait FSM ----
  reg  ops_valid_q;
  wire advance = ~stall_i;
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)      ops_valid_q <= 1'b0;
    else if (advance) ops_valid_q <= 1'b0;
    else              ops_valid_q <= 1'b1;
  end
  assign rf_ready_o = ops_valid_q;

  // Decode, registrado (pre-decodificación; Proyecto 3, docs/decisiones.md,
  // D18). Toda instrucción pasa un ciclo esperando la lectura sincrónica del
  // banco de registros (ops_valid_q = 0) y recién ejecuta en el ciclo
  // siguiente. Durante ese ciclo de espera la instrucción ya está estable en
  // instr_rdata_i, así que el decodificador trabaja ahí y sus salidas se
  // registran al final del ciclo. En el ciclo de ejecución la ALU, la LSU,
  // el salto y el write-back usan las salidas registradas, y el decode sale
  // de la ruta crítica. Cada instrucción sigue tomando los mismos ciclos.
  //
  // Los registros no necesitan reset: todo lo que los usa está condicionado
  // a ops_valid_q (rf_ready_o, lsu_req_o) o a commit, que valen 0 en el ciclo
  // de espera, y para entonces ya se cargaron con la instrucción actual.
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
    .instr_i        (instr_rdata_i),
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
    if (!ops_valid_q) begin
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

  // Comparador dedicado de los saltos (Proyecto 3, experimento B3, rama
  // exp/branch-cmp): toma los operandos directo del banco de registros, sin
  // pasar por los muxes de operandos de la ALU. Un salto condicional siempre
  // compara rs1 con rs2 (el decodificador fija OP_A_REG y OP_B_REG), así que
  // el resultado es el mismo que cmp_result_o de la ALU; la ALU conserva sus
  // comparadores para SLT y SLTU. Los códigos son los de espino_alu.
  localparam [3:0] ALU_EQ = 4'd10, ALU_NE = 4'd11, ALU_LT = 4'd12,
                   ALU_GE = 4'd13, ALU_LTU = 4'd14, ALU_GEU = 4'd15;
  wire signed [31:0] br_a_s = rf_rdata_a_i;
  wire signed [31:0] br_b_s = rf_rdata_b_i;
  wire br_eq  = (rf_rdata_a_i == rf_rdata_b_i);
  wire br_lt  = (br_a_s < br_b_s);
  wire br_ltu = (rf_rdata_a_i < rf_rdata_b_i);
  reg  br_cmp;
  always @* begin
    case (alu_operator)
      ALU_EQ:  br_cmp =  br_eq;
      ALU_NE:  br_cmp = ~br_eq;
      ALU_LT:  br_cmp =  br_lt;
      ALU_GE:  br_cmp = ~br_lt;
      ALU_LTU: br_cmp =  br_ltu;
      ALU_GEU: br_cmp = ~br_ltu;
      default: br_cmp = 1'b0;
    endcase
  end
  wire _unused_alu_cmp = &{1'b0, alu_cmp_result};

  // LSU control
  assign lsu_req_o   = lsu_req_dec & instr_valid_i & ops_valid_q;
  assign lsu_we_o    = lsu_we_dec;
  assign lsu_type_o  = lsu_type_dec;
  assign lsu_sign_o  = lsu_sign_dec;
  assign lsu_addr_o  = alu_result;
  assign lsu_wdata_o = rf_rdata_b_i;

  // Control transfer
  assign branch_taken_o = is_branch & br_cmp;
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