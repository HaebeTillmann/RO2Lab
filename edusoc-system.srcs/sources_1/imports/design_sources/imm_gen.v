`include "riscv_isa_defines.v"

module imm_gen(
    input [31:0] INSTR,
    output reg [31:0] IMM
    );
    
    always @(INSTR) begin
        case(INSTR[6:0])
            `OPCODE_OPIMM: IMM = {{20{INSTR[31]}}, INSTR[31:20]};
            `OPCODE_JALR: IMM = {{20{INSTR[31]}}, INSTR[31:20]};
            `OPCODE_AUIPC: IMM = {INSTR[31:12], 12'b0};
            `OPCODE_LUI: IMM = {INSTR[31:12], 12'b0};
	        `OPCODE_STORE: IMM = {INSTR[31:25], INSTR[11:7]};
            `OPCODE_LOAD: IMM = {12'b0, INSTR[31:20]};
            `OPCODE_BRANCH: IMM = {{19{INSTR[31]}}, INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8], 1'b0};
            `OPCODE_JAL: IMM = {{11{INSTR[31]}}, INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21], 1'b0};
            default: IMM = 0;
        endcase
    end
endmodule
