module proc(
    input [31:0] instr_read,
    input instr_valid,
    input CLK,
    input RES,
    output [31:0] instr_adr,
    output instr_req
    );
    
    wire [31:0] instr;
    wire [31:0] alu_q;
    wire [31:0] imm;
    wire [31:0] regset_q0, regset_q1;
    wire regset_we;
    wire [31:0] alu_b;
    wire [31:0] alu_cmp;
    wire [5:0] alu_s;
    wire branch;
    
    REG_DRE_32 instr_buffer(.D(instr_read), .Q(instr), .CLK(CLK), .RES(RES), .ENABLE(instr_valid));
    regset regset(.D(alu_q), .A_D(instr[11:7]), .A_Q0(instr[19:15]), .A_Q1(instr[24:20]), .write_enable(regset_we), .RES(RES), .CLK(CLK), .Q0(regset_q0), .Q1(regset_q1));
    imm_gen IMM_GEN(.INSTR(instr), .IMM(imm));
    MUX_2x1_32 alu_src_sel(.I0(imm), .I1(regset_q1), .S(instr[5] | !instr[2]), .Y(alu_b));
    alu alu(.S({instr[30], instr[14:12], instr[6], instr[4]}), .A(regset_q0), .B(alu_b), .CMP(alu_cmp), .Q(alu_q));
    pc pc(.D(alu_q), .MODE(alu_cmp & branch), .ENABLE(instr_valid), .RES(RES), .CLK(CLK), .PC_OUT(instr_adr));
    ctrl ctrl(.INSTR(instr[6:0]), .REG_WRITE(regset_we), .INSTR_REQ(instr_req), .BRANCH(branch), .CLK(CLK), .RES(RES), .INSTR_VALID(instr_valid));
    
    
  
endmodule
