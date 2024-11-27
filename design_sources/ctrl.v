`include "riscv_isa_defines.v"
`define STATES 4

module ctrl(
    input [6:0] INSTR,
    input CLK, RES,
    input INSTR_VALID, DATA_VALID,
    
    output DATA_REQ, DATA_WRITE_ENABLE,
    output reg REG_WRITE, INSTR_REQ, BRANCH
    );
    
    parameter IDLE = `STATES'b0001;
    parameter FETCH = `STATES'b0010;
    parameter EX = `STATES'b0100;
    parameter WB = `STATES'b1000;
    
    reg [`STATES-1 : 0] state = IDLE;
    
    always @(posedge CLK, posedge RES) begin
        if(RES == 1'b1) state <= IDLE;
        else begin
            case(state)
                IDLE:state <= (INSTR_VALID == 1'b1)?FETCH:IDLE;
                FETCH:state <= EX;
                EX:state <= WB;
                WB:state <= FETCH;
            endcase
        end
    end
    
    always @(state) begin
        case(state)
            IDLE: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b1;
                BRANCH = 1'b0;
            end
            
            FETCH: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b0;
                BRANCH = 1'b0;
            end
            
            EX: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b0;
                BRANCH = 1'b0;
            end
            
            WB: begin
                REG_WRITE = INSTR[2] & INSTR[5];
                INSTR_REQ = 1'b1;
                BRANCH = INSTR[6];
            end
        endcase
    end
endmodule
