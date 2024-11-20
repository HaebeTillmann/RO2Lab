`include "riscv_isa_defines.v"

module imm_gen(
    input [31:0] INSTR,
    output reg [31:0] IMM
    );
    
    always @(INSTR) begin
        casez(INSTR[6:0])
            `OPCODE_OPIMM: IMM = INSTR[11:0];
            `OPCODE_JALR: IMM = INSTR[11:0];
            `OPCODE_AUIPC: IMM = INSTR[31:12];
            `OPCODE_LUI: IMM = INSTR[31:12];
        endcase
    end
    
endmodule
