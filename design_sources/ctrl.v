`include "riscv_isa_defines.v"
`define STATES 5

module ctrl(
    input [31:0] INSTR,
    input CLK, RES,
    input INSTR_VALID,
    output reg REG_WRITE, INSTR_REQ, BRANCH,
    output reg [5:0] ALU_S
    );
    
    parameter IDLE = `STATES'b0001;
    parameter FETCH = `STATES'b0010;
    parameter EX = `STATES'b0100;
    parameter WB = `STATES'b1000;
    
    reg [`STATES-1 : 0] state = IDLE;
    
    always @(posedge CLK, posedge RES) begin
        if(RES == 1'b1) state <= IDLE;
        else
        case(state)
            IDLE:state <= (INSTR_VALID == 1'b1)?FETCH:IDLE;
            FETCH:state <= EX;
            EX:state <= WB;
            WB:state <= FETCH;
        endcase
    end
    
    always @(state) begin
        case(state)
            IDLE: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b0;
                BRANCH = 1'b0;
                ALU_S = 6'b0;
            end
            
            FETCH: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b0;
                BRANCH = 1'b0;
                ALU_S = 6'b0;
            end
            
            EX: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b0;
                BRANCH = 1'b0;
                ALU_S = 6'b0;
            end
            
            WB: begin
                REG_WRITE = 1'b1;
                INSTR_REQ = 1'b1;
                if ()
                BRANCH = 1'b0;
                ALU_S = 6'b0;
            end
        endcase
    end
endmodule
