`define OPCODE_OP 7'h33
`define OPCODE_OPIMM 7'h13
`define OPCODE_STORE 7'h23
`define OPCODE_LOAD 7'h03
`define OPCODE_BRANCH 7'h63
`define OPCODE_JALR 7'h67
`define OPCODE_JAL 7'h6f
`define OPCODE_AUIPC 7'h17
`define OPCODE_LUI 7'h37

`define STATES 4

module ctrl(
    input [6:0] INSTR,
    input CLK, RES,
    input INSTR_VALID, DATA_VALID,
    
    output reg DATA_REQ, DATA_WRITE_ENABLE, PC_ENABLE,
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
                EX:state <= (DATA_VALID == 1 || INSTR != `OPCODE_LOAD)?WB:EX;
                WB:state <= (INSTR_VALID == 1'b1)?FETCH:WB;
            endcase
        end
    end
    
    always @(state) begin
        case(state)
            IDLE: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b1;
                BRANCH = 1'b0;
                DATA_WRITE_ENABLE = 1'b0;
                DATA_REQ = 1'b0;
                PC_ENABLE = 1'b0;
            end
            
            FETCH: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b0;
                BRANCH = 1'b0;
                DATA_WRITE_ENABLE = 1'b0;
                DATA_REQ = 1'b0;
                PC_ENABLE = 1'b0;
            end
            
            EX: begin
                REG_WRITE = 1'b0;
                INSTR_REQ = 1'b0;
                BRANCH = 1'b0;
                DATA_WRITE_ENABLE = 1'b0;
                DATA_REQ = 1'b0;
                PC_ENABLE = 1'b1;
                
                casez(INSTR)
                    `OPCODE_LOAD: DATA_REQ = 1'b1;
                    `OPCODE_BRANCH: BRANCH = 1'b1;
                endcase
            end
            
            WB: begin
                REG_WRITE = 1'b1;
                BRANCH = 1'b0;
                DATA_WRITE_ENABLE = 1'b0;
                DATA_REQ = 1'b0;
                INSTR_REQ = 1'b1;
                PC_ENABLE = 1'b0;
                
                casez(INSTR)
                    `OPCODE_STORE: begin
                        DATA_WRITE_ENABLE = 1'b1;
                        REG_WRITE = 1'b0;
                        
                    end
                    `OPCODE_JAL: BRANCH = 1'b1;
                    `OPCODE_JALR: BRANCH = 1'b1;
                endcase
            end
        endcase
    end
endmodule
