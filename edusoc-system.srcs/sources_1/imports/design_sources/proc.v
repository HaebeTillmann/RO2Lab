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
    wire [31:0] alu1_q, alu2_q;
    wire [31:0] simd_data;
    wire [31:0] imm;
    wire [31:0] regset1_q0, regset1_q1, regset2_q0, regset2_q1;
    wire regset_we;
    wire [31:0] alu1_b1, alu1_b2, alu1_a, alu2_b1, alu2_b2, alu2_a;
    wire alu1_cmp, alu2_cmp;
    wire [5:0] alu_s;
    wire branch;
    wire pc_enable;
    wire mret;
    wire [31:0] pc_d, regset1_d, regset1_d2, regset1_d3, regset2_d, regset2_d2, regset2_d3;
    wire [31:0] csr_read;
    
    assign data_adr = regset1_q0 + imm;
    assign data_write = regset1_q1;
    
    assign s = instr[14:12];
    
    REG_DRE_32 instr_buffer(
        .D(instr_read),
        .Q(instr),
        .CLK(CLK),
        .RES(RES),
        .ENABLE(instr_valid)
    );
       
//Alu1----------------------------------------------------------------------------------------------------------------
    MUX_2x1_32 regset1_d_src_sel(
        .I0(alu1_q),
        .I1(pc_out + 4),
        .S(instr[6:0] == `OPCODE_JAL || instr[6:0] == `OPCODE_JALR),
        .Y(regset1_d)
    );
    
    MUX_2x1_32 regset1_d2_src_sel(
        .I0(regset1_d),
        .I1(data_read),
        .S(instr[6:0] == `OPCODE_LOAD),
        .Y(regset1_d2)
    );
    
    MUX_2x1_32 regset1_d3_src_sel(
        .I0(regset1_d2),
        .I1(csr_read | regset1_q0),
        .S(instr[6:0] == 7'h73 && instr[14:12] == 3'b010),
        .Y(regset1_d3)
    );

    regset regset1(
        .D(regset1_d3),
        .A_D(instr[11:7]),
        .A_Q0((instr[6:0] == `OPCODE_IOP && imm[5:4]!=0) ? instr[11:7]: instr[19:15]), //wenn IOP nehme D addrese Als Q0 asdresse
        .A_Q1(instr[24:20]),
        .write_enable(regset_we && ((instr[6:0] != `OPCODE_IOP)|(imm[0] && instr[6:0] === `OPCODE_IOP))), //entweder normales reg_we oder bei IOP wenn nach reg1 geschrieben werden soll
        .RES(RES),
        .CLK(CLK),
        .Q0(regset1_q0),
        .Q1(regset1_q1)
    );

    MUX_2x1_32 alu1_a1_src_sel(
        .I0(regset1_q0), // Other
        .I1(pc_out),    // AUIPC, JAL
        .S(instr[6:0] === `OPCODE_AUIPC || instr[6:0] === `OPCODE_JAL),
        .Y(alu1_a));

    MUX_2x1_32 alu1_b_src_sel(
        .I0(imm),
        .I1(regset1_q1),
        .S(instr[5] & ~instr[2]),
        .Y(alu1_b1)
    );
    
    MUX_2x1_32 alu1_b2_src_sel(
        .I0(alu1_b1),
        .I1(simd_data + {{26{imm[11]}},imm[11:6]}),// addiert den immidiate von iop1 hinzu   
        .S(instr[6:0] === `OPCODE_IOP && imm[0]),
        .Y(alu1_b2));
        
    alu alu1(
        .S(instr[7:0] == `OPCODE_AUIPC?8'b00000001:instr[6:0] == `OPCODE_LUI?8'b0:{((instr[6:0] == `OPCODE_OPIMM && instr[14:12] == 3'b101) || instr[6:0] == `OPCODE_OP)?instr[30]:0, {((instr[6:0] == 7'b0110011) && instr[25])?1'b1:1'b0}, instr[14:12], instr[6], instr[4]}),
        .A(alu1_a),
        .B(alu1_b2),
        .CMP(alu1_cmp),
        .Q(alu1_q)
    );
    
//Alu2----------------------------------------------------------------------------------------------------------------    
    MUX_2x1_32 regset2_d_src_sel(
        .I0(alu2_q),
        .I1(pc_out + 4),
        .S(instr[6:0] == `OPCODE_JAL || instr[6:0] == `OPCODE_JALR),
        .Y(regset2_d)
    );
    
    MUX_2x1_32 regset2_d2_src_sel(
        .I0(regset2_d),
        .I1(data_read),
        .S(instr[6:0] == `OPCODE_LOAD),
        .Y(regset2_d2)
    );
    
    MUX_2x1_32 regset2_d3_src_sel(
        .I0(regset2_d2),
        .I1(csr_read | regset2_q0),
        .S(instr[6:0] == 7'h73 && instr[14:12] == 3'b010),
        .Y(regset2_d3)
    );

    regset regset2(
        .D(regset2_d3),
        .A_D(instr[11:7]),
        .A_Q0((instr[6:0] == `OPCODE_IOP && imm[5:4]!=1) ? instr[11:7]: instr[19:15]), //wenn IOP nehme D addrese Als Q0 asdresse
        .A_Q1(instr[24:20]),
        .write_enable(regset_we && ((instr[6:0] != `OPCODE_IOP)|(imm[1] && instr[6:0] === `OPCODE_IOP))), //entweder normales reg_we oder bei IOP wenn nach reg2 geschrieben werden soll
        .RES(RES),
        .CLK(CLK),
        .Q0(regset2_q0),
        .Q1(regset2_q1)
    );

    MUX_2x1_32 alu2_a1_src_sel(
        .I0(regset2_q0), // Other
        .I1(pc_out),    // AUIPC, JAL
        .S(instr[6:0] === `OPCODE_AUIPC || instr[6:0] === `OPCODE_JAL),
        .Y(alu2_a));

    MUX_2x1_32 alu2_b1_src_sel(
        .I0(imm),
        .I1(regset2_q1),
        .S(instr[5] & ~instr[2]),
        .Y(alu2_b1)
    );
    
    MUX_2x1_32 alu2_b2_src_sel(
        .I0(alu2_b1),
        .I1(simd_data + {{26{imm[11]}},imm[11:6]}),// addiert den immidiate von iop1 hinzu   
        .S(instr[6:0] === `OPCODE_IOP && imm[1]),
        .Y(alu2_b2));
    
    alu alu2(
        .S(instr[7:0] == `OPCODE_AUIPC?8'b00000001:instr[6:0] == `OPCODE_LUI?8'b0:{((instr[6:0] == `OPCODE_OPIMM && instr[14:12] == 3'b101) || instr[6:0] == `OPCODE_OP)?instr[30]:0, {((instr[6:0] == 7'b0110011) && instr[25])?1'b1:1'b0}, instr[14:12], instr[6], instr[4]}),
        .A(alu2_a),
        .B(alu2_b2),
        .CMP(),
        .Q(alu2_q)
    );

//SIMD----------------------------------------------------------------------------------------------------------------  

    MUX_2x1_32 simd_src_sel(
        .I0(regset1_q0),
        .I1(regset2_q0),
        .S(imm[4]),
        .Y(simd_data)
    );
   
//imm_gen----------------------------------------------------------------------------------------------------------------     
    imm_gen IMM_GEN(
        .INSTR(instr),
        .IMM(imm)
    );

//programmcounter----------------------------------------------------------------------------------------------------------------    
    MUX_2x1_32 pc_d_src_sel(
        .I0(imm + pc_out),
        .I1(regset1_q0 + imm),
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
        .BRANCH(branch),
        .CLK(CLK),
        .RES(RES),
        .INSTR_VALID(instr_valid),
        .DATA_VALID(data_valid),
        .ALU_CMP(alu1_cmp),
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
