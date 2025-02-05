module dualCoreMemBus(
    input CLK, RES,

    // From cores
    // Instruction memory
    input               INSTR_REQ_1, INSTR_REQ_2,
    output reg          INSTR_VALID_1, INSTR_VALID_2,
    input  [31:0]       INSTR_ADDR_1, INSTR_ADDR_2,
    output [31:0]   INSTR_RDATA_1, INSTR_RDATA_2,

    // Data memory 
    input               DATA_REQ_1, DATA_REQ_2,
    output reg          DATA_VALID_1, DATA_VALID_2,
    input               DATA_WE_1, DATA_WE_2,
    input  [31:0]       DATA_ADDR_1, DATA_ADDR_2,
    input  [31:0]       DATA_WDATA_1, DATA_WDATA_2,
    output [31:0]       DATA_RDATA_1, DATA_RDATA_2,
    input  [2:0]        S_1, S_2,
    
    // To memory
    // Instruction memory 
    output reg        INSTR_REQ,
    input             INSTR_VALID,
    output reg [31:0] INSTR_ADDR,
    input      [31:0] INSTR_RDATA,

    // Data memory 
    output reg          DATA_REQ,
    input               DATA_VALID,
    output reg          DATA_WE,
    output reg [31:0]   DATA_ADDR,
    output reg [31:0]   DATA_WDATA,
    input      [31:0]   DATA_RDATA,
    output reg [2:0]    S
    );
    
    reg [2:0] state_instr, next_state_instr; 
    reg [2:0] state_dat, next_state_dat; 
    
    parameter Z0 = 3'b001;
    parameter Z1 = 3'b010;
    parameter Z2 = 3'b100;
    
    assign DATA_RDATA_1 = DATA_RDATA;
    assign DATA_RDATA_2 = DATA_RDATA;
    
    assign INSTR_RDATA_1 = INSTR_RDATA;
    assign INSTR_RDATA_2 = INSTR_RDATA;
    
    always @(posedge CLK, posedge RES) begin
        if (RES == 1'b1) begin
            state_instr <= Z0;
            state_dat <= Z0;
        end
        else begin
            state_instr <= next_state_instr;
            state_dat <= next_state_dat;
        end
    end
    
    
    // State Machine for Instruction Memory
    always @(*) begin
        next_state_instr <= Z0;
        
        INSTR_REQ = 0;
        INSTR_VALID_1 = 0;
        INSTR_ADDR = 0;
        INSTR_VALID_2 = 0;
        
        case(state_instr)
            Z0: begin
               if (INSTR_REQ_1) next_state_instr <= Z1;
               else if (INSTR_REQ_2) next_state_instr <= Z2;
               else next_state_instr <= Z0;
            end
            Z1: begin
                INSTR_REQ = INSTR_REQ_1;
                INSTR_VALID_1 = INSTR_VALID;
                INSTR_ADDR = INSTR_ADDR_1;
                
                if (INSTR_VALID) next_state_instr <= Z0;
                else next_state_instr <= Z1;
            end
            Z2: begin
                INSTR_REQ = INSTR_REQ_2;
                INSTR_VALID_2 = INSTR_VALID;
                INSTR_ADDR = INSTR_ADDR_2;
                
                if (INSTR_VALID) next_state_instr <= Z0;
                else next_state_instr <= Z2;
            end
        endcase
    end
    
    
    // State Machine for Data Memory
    always @(*) begin
        next_state_dat <= Z0;
      
        DATA_REQ = 0;
        DATA_VALID_1 = 0;
        DATA_VALID_2 = 0;
        DATA_WE = 0;
        DATA_ADDR = 0;
        DATA_WDATA = 0;
        S = 0;
        
        case(state_dat)
            Z0: begin
               if (DATA_REQ_1) next_state_dat <= Z1;
               else if (DATA_REQ_2) next_state_dat <= Z2;
               else next_state_dat = Z0;
            end
            Z1: begin
                DATA_REQ = DATA_REQ_1;
                DATA_VALID_1 = DATA_VALID;
                DATA_WE = DATA_WE_1;
                DATA_ADDR = DATA_ADDR_1;
                DATA_WDATA = DATA_WDATA_1;
                S = S_1;
                
                if (!DATA_REQ_1) next_state_dat <= Z0;
                else next_state_dat <= Z1;
            end
            Z2: begin
                DATA_REQ = DATA_REQ_2;
                DATA_VALID_2 = DATA_VALID;
                DATA_WE = DATA_WE_2;
                DATA_ADDR = DATA_ADDR_2;
                DATA_WDATA = DATA_WDATA_2;
                S = S_2;
                
                if (!DATA_REQ_2) next_state_dat <= Z0;
                else next_state_dat <= Z2;
            end
        endcase
    end
endmodule
