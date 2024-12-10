`include "riscv_isa_defines.v"

module imm_gen(
    input [31:0] INSTR,
    output reg [31:0] IMM
    );
    
    always @(INSTR) begin
        casez(INSTR[6:0])
            `OPCODE_OPIMM: IMM = {{20{INSTR[31]}}, INSTR[31:20]};
            `OPCODE_JALR: IMM = {{20{INSTR[31]}}, INSTR[31:20]};
            `OPCODE_AUIPC: IMM = INSTR[31:12];
            `OPCODE_LUI: IMM = INSTR[31:12];
	        `OPCODE_STORE: IMM = {INSTR[31:25], INSTR[11:7]};
            `OPCODE_LOAD: IMM = INSTR[31:20];
            `OPCODE_BRANCH: IMM = {{19{INSTR[31]}}, INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8], 1'b0};
            `OPCODE_JAL: IMM = {{11{INSTR[31]}}, INSTR[31], INSTR[21:12], INSTR[22], INSTR[30:23], 1'b0} * 4;
        endcase
    end
    
endmodule
