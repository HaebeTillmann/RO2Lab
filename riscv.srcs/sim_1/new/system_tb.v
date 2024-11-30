module system_tb();
    
    wire [31:0] instr_read;
    wire instr_valid;
    reg CLK;
    reg RES;
    wire [31:0] instr_adr;
    wire instr_req;
    
    initial begin
        CLK = 0;
        RES = 0;
        #40;
        RES = 1;
        #40;
        RES = 0;
    end
    
    always begin
        CLK = !CLK;
        #20;
    end
    
    proc proc(.instr_read(instr_read), .instr_valid(instr_valid), .CLK(CLK), .RES(RES), .pc_out(instr_adr), .instr_req(instr_req));
    memory_sim msim(.clk_i(CLK), .data_read(instr_read), .data_adr(instr_adr), .data_req(instr_req), .data_rvalid(instr_valid), .data_write_enable(1'b0));
endmodule
