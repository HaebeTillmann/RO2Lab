module memoryacces(
    input CLK, RES,
    
    // von CPU
    input [31:0] ADDR, 
    input [31:0] DATA_WRITE,
    input DATA_REQ,
    input [2:0] S,
    input WRITE_ENABLE,
    
    // von Speicher
    input [31:0] DATA_READ_MEM,
    input DATA_VALID_MEM,
    
    // zu CPU
    output [31:0] DATA_READ,
    output DATA_VALID,
    
    // Zu Speicher
    output [31:0]DATA_WRITE_MEM,
    output reg [31:0] DATA_ADR_MEM,
    output DATA_WE_MEM,
    output DATA_REQ_MEM,
    output reg [3:0] DATA_BE_MEM
    );
    
    parameter Z0 = 2'b01;
    parameter Z1 = 2'b10;
    
    reg [1:0] state, next_state;
    wire [31:0] read1, read2;
    
    assign DATA_VALID = DATA_VALID_MEM && state[1];
    assign DATA_WRITE_MEM = (DATA_WRITE << 8*(ADDR % 4)) | (DATA_WRITE >> (32 - 8*(ADDR % 4)));
    assign DATA_WE_MEM = WRITE_ENABLE;
    
    REG_DRE_32 read1_buffer(
        .D(DATA_READ_MEM),
        .Q(read1),
        .CLK(CLK),
        .RES(RES),
        .ENABLE(DATA_VALID_MEM && state == 2'b01)
    );
    
    REG_DRE_32 read2_buffer(
        .D(DATA_READ_MEM),
        .Q(read2),
        .CLK(CLK),
        .RES(RES),
        .ENABLE(DATA_VALID_MEM && state == 2'b10)
    );
    
    assign DATA_REQ_MEM = DATA_REQ;
    
    table5x4_sel data_load_table(
        .row(5'b00001 <<< S),
        .col(ADDR % 4),
        
        // LB
        .in_0x0({{24{read1[7]}}, read1[7:0]}),
        .in_0x1({{24{read1[15]}}, read1[15:8]}),
        .in_0x2({{24{read1[23]}}, read1[23:16]}),
        .in_0x3({{24{read1[31]}}, read1[31:24]}),
        
        // LH
        .in_1x0({{16{read1[15]}}, read1[15:0]}),
        .in_1x1({{16{read1[23]}}, read1[23:8]}),
        .in_1x2({{16{read1[31]}}, read1[31:16]}),
        .in_1x3({{16{read1[7]}}, read2[7:0], read1[31:24]}),
        
        // LW
        .in_2x0({read1[31:0]}),
        .in_2x1({read2[7:0], read1[31:8]}),
        .in_2x2({read2[15:0], read1[31:16]}),
        .in_2x3({read2[23:0], read1[31:24]}),
        
        // LBU
        .in_3x0({{24{1'b0}}, read1[7:0]}),
        .in_3x1({{24{1'b0}}, read1[15:8]}),
        .in_3x2({{24{1'b0}}, read1[23:16]}),
        .in_3x3({{24{1'b0}}, read1[31:24]}),
        
        // LHU
        .in_4x0({{16{1'b0}}, read1[15:0]}),
        .in_4x1({{16{1'b0}}, read1[23:8]}),
        .in_4x2({{16{1'b0}}, read1[31:16]}),
        .in_4x3({{16{1'b0}}, read2[7:0], read1[31:24]}),

        .selected(DATA_READ)
    );
    
    
    // Automat
    
    always @(posedge CLK, posedge RES) begin
        if (RES == 1'b1) begin
            state <= Z0;
        end
        else state <= next_state;
    end
    
    always @(*) begin
        next_state = Z0;
        DATA_ADR_MEM = 32'b0;
        DATA_BE_MEM = 4'b0000;
        
        case(state)
            2'b01: begin
               case(S)
                   3'b000:DATA_BE_MEM = 4'b0001 << (ADDR % 4); // Byte
                   3'b001:DATA_BE_MEM = 4'b0011 << (ADDR % 4); // Half word
                   3'b010:DATA_BE_MEM = 4'b1111 << (ADDR % 4); // Word
                   3'b011:DATA_BE_MEM = 4'b0001 << (ADDR % 4); // Byte unsigned
                   3'b100:DATA_BE_MEM = 4'b0011 << (ADDR % 4); // Half word unsigned
               endcase
               
               DATA_ADR_MEM = ADDR - (ADDR % 4); //Niedrigere Adresse
               
               if (DATA_VALID_MEM) begin
                    next_state <= Z1;
               end else begin
                    next_state <= Z0;
               end
            end
            2'b10: begin
                case(S)
                   3'b000:DATA_BE_MEM = 4'b0000; // Byte
                   3'b001:DATA_BE_MEM = 4'b0001 >> 3-(ADDR % 4); // Half Word
                   3'b010:DATA_BE_MEM = 4'b1111 >> 4-(ADDR % 4); // Word
                   3'b011:DATA_BE_MEM = 4'b0000; // Byte unsigned
                   3'b100:DATA_BE_MEM = 4'b0001 >> 3-(ADDR % 4); // Half word unsigned
               endcase
               
               DATA_ADR_MEM = ADDR + (4 - (ADDR % 4)); // Höhere Adresse
                
                if (DATA_VALID_MEM) begin
                    next_state <= Z0;
                end else begin
                    next_state <= Z1;
                end
            end
        endcase
    end
endmodule
