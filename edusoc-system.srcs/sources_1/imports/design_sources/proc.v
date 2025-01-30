`include "riscv_isa_defines.v"

module proc(
    input [31:0] instr_read, data_read, core_id,
    input [4:0] irq_id,
    input instr_valid, data_valid,irq, 
    input CLK,
    input RES,
    
    output instr_req, data_req, data_write_enable,irq_ack,
    output [4:0] irq_ack_id,
    output [31:0] pc_out, data_write,
    output [31:0] data_adr,
    output [2:0] s
    );
    
    wire [31:0] instr;
    wire [31:0] alu_q;
    wire [31:0] imm;
    wire [31:0] regset_q0, regset_q1;
    wire regset_we;
    wire [31:0] alu_b, alu_a;
    wire alu_cmp;
    wire [5:0] alu_s;
    wire branch;
    wire pc_enable;
    wire mret;
    wire [31:0] pc_d, regset_d, regset_d2, regset_d3;
    wire [31:0] csr_read;
    
    assign data_adr = regset_q0 + imm;
    assign data_write = regset_q1;
    
    assign s = instr[14:12];
    
    REG_DRE_32 instr_buffer(
        .D(instr_read),
        .Q(instr),
        .CLK(CLK),
        .RES(RES),
        .ENABLE(instr_valid)
    );
    
    MUX_2x1_32 regset_d_src_sel(
        .I0(alu_q),
        .I1(pc_out + 4),
        .S(instr[6:0] == `OPCODE_JAL || instr[6:0] == `OPCODE_JALR),
        .Y(regset_d)
    );
    
    MUX_2x1_32 regset_d2_src_sel(
        .I0(regset_d),
        .I1(data_read),
        .S(instr[6:0] == `OPCODE_LOAD),
        .Y(regset_d2)
    );
    
    MUX_2x1_32 regset_d3_src_sel(
        .I0(regset_d2),
        .I1(csr_read | regset_q0),
        .S(instr[6:0] == 7'h73 && instr[14:12] == 3'b010),
        .Y(regset_d3)
    );

    regset regset(
        .D(regset_d3),
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
        .I1(pc_out),    // AUIPC, JAL
        .S(instr[6:0] === `OPCODE_AUIPC || instr[6:0] === `OPCODE_JAL),
        .Y(alu_a));

    MUX_2x1_32 alu_b_src_sel(
        .I0(imm),
        .I1(regset_q1),
        .S(instr[5] & ~instr[2]),
        .Y(alu_b)
    );
    

    alu alu(
        .S(instr[7:0] == `OPCODE_AUIPC?8'b00000001:instr[6:0] == `OPCODE_LUI?8'b0:{((instr[6:0] == `OPCODE_OPIMM && instr[14:12] == 3'b101) || instr[6:0] == `OPCODE_OP)?instr[30]:0, {((instr[6:0] == 7'b0110011) && instr[25])?1'b1:1'b0}, instr[14:12], instr[6], instr[4]}),
        .A(alu_a),
        .B(alu_b),
        .CMP(alu_cmp),
        .Q(alu_q)
    );
    
    MUX_2x1_32 pc_d_src_sel(
        .I0(imm + pc_out),
        .I1(regset_q0 + imm),
        .S(instr[6:0] === `OPCODE_JALR),
        .Y(pc_d)
    );
    
    pc pc(
        .D(pc_d),
        .MODE(branch || irq),
        .ENABLE(pc_enable),
        .RES(RES),
        .CLK(CLK),
        .PC_OUT(pc_out),
        .IRQ(irq),
        .IRQ_J_ADR((irq_id << 2) + 32'h1C000000),
        .mret(mret),
        .IRQ_ACK(irq_ack),
        .IRQ_ID(irq_id),
        .IRQ_ACK_ID(irq_ack_id)
    );

    ctrl ctrl(
        .INSTR(instr[6:0]),
        .REG_WRITE(regset_we),
        .INSTR_REQ(instr_req),
        .BRANCH(brancore_idch),
        .CLK(CLK),
        .RES(RES),
        .INSTR_VALID(instr_valid),
        .DATA_VALID(data_valid),
        .ALU_CMP(alu_cmp),
        .DATA_REQ(data_req),
        .DATA_WRITE_ENABLE(data_write_enable),
        .PC_ENABLE(pc_enable),
        .MRET(mret)
    );
    
    csr csr(
        .CLK(CLK),
        .RES(RES),
        .RDINSTRET_EN(pc_enable),
        .CSR_ADR(instr[31:20]),
        .CSR_READ(csr_read),
        .CORE_ID(core_id)
    );
endmodule
