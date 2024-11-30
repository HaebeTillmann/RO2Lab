`include "riscv_isa_defines.v"

module proc(
    input [31:0] instr_read, data_read,
    input instr_valid, data_valid,
    input CLK,
    input RES,
    
    output instr_req, data_req, data_write_enable,
    output [31:0] pc_out, data_write, data_adr
    );
    
    wire [31:0] instr;
    wire [31:0] alu_q;
    wire [31:0] imm;
    wire [31:0] regset_q0, regset_q1;
    wire regset_we;
    wire [31:0] alu_b, alu_a;
    wire [31:0] alu_cmp;
    wire [5:0] alu_s;
    wire branch;
    wire pc_enable;
    
    REG_DRE_32 instr_buffer(
        .D(instr_read),
        .Q(instr),
        .CLK(CLK),
        .RES(RES),
        .ENABLE(instr_valid)
    );

    regset regset(
        .D(alu_q),
        .A_D(instr[11:7]),
        .A_Q0(instr[19:15]),
        .A_Q1(instr[24:20]),
        .write_enable(regset_we),
        .RES(RES),
        .CLK(CLK),
        .Q0(regset_q0),
        .Q1(regset_q1)
    );

    imm_gen IMM_GEN(
        .INSTR(instr),
        .IMM(imm)
    );

    MUX_2x1_32 alu_a_src_sel(
        .I0(regset_q0), // Other
        .I1(pc_out),    // AUIPC
        .S(instr === `OPCODE_AUIPC),
        .Y(alu_a));

    MUX_2x1_32 alu_b_src_sel(
        .I0(imm),
        .I1(regset_q1),
        .S(instr[5] & ~instr[2]),
        .Y(alu_b)
    );

    alu alu(
        .S({instr[0:6] === `OPCODE_LUI, instr[0:6] === `OPCODE_AUIPC, instr[30], instr[14:12], instr[6], instr[4]}),
        .A(alu_a),
        .B(alu_b),
        .CMP(alu_cmp),
        .Q(alu_q)
    );

    pc pc(
        .D(alu_q),
        .MODE(alu_cmp & branch),
        .ENABLE(pc_enable),
        .RES(RES), .CLK(CLK),
        .PC_OUT(pc_out)
    );

    ctrl ctrl(
        .INSTR(instr[6:0]),
        .REG_WRITE(regset_we),
        .INSTR_REQ(instr_req),
        .BRANCH(branch),
        .CLK(CLK),
        .RES(RES),
        .INSTR_VALID(instr_valid),
        .DATA_VALID(data_valid),
        .DATA_REQ(data_req),
        .DATA_WRITE_ENABLE(data_write_enable),
        .PC_ENABLE(pc_enable)
    );
endmodule
