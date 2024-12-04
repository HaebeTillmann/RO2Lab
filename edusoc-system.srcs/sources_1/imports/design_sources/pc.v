module pc(
	input [31:0] D,
	input MODE,
	input ENABLE,
	input RES,
	input CLK,
	output reg [31:0] PC_OUT
	);
	
	initial PC_OUT = 32'h1A000000;
	
	always @(posedge CLK) begin
	   if (RES) begin
			PC_OUT = 32'h1A000000;
		end
		else begin
            if (ENABLE) begin
                if (MODE) begin
                    PC_OUT = PC_OUT + D;
                end
                else begin
                    PC_OUT = PC_OUT + 4;
                end
            end
		end
	end
endmodule
