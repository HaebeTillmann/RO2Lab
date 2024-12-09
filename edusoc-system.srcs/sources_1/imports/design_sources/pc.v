module pc(
	input [31:0] D,
	input MODE,
	input ENABLE,
	input RES,
	input CLK,
	input IRQ,
	input [31:0] IRQ_J_ADR,
	input mret,
	output reg [31:0] PC_OUT,
	output reg IRQ_ACK
	);
	reg [31:0] adr_store;
	
	initial PC_OUT = 32'h1A000000;
	
	always @(posedge CLK) begin
	   if (mret) begin
	       PC_OUT = adr_store;
	       IRQ_ACK =1'b0;
	   end
	   
	   if (RES) begin
			PC_OUT = 32'h1A000000;
		end
		else if (IRQ & ~IRQ_ACK) begin
            adr_store = PC_OUT;
            PC_OUT = IRQ_J_ADR;
            IRQ_ACK = 1'b1;
		end
		else begin
            if (ENABLE) begin
                if (MODE) begin
                    PC_OUT = D;
                end
                else begin
                    PC_OUT = PC_OUT + 4;
                end
            end
		end
	end
endmodule
