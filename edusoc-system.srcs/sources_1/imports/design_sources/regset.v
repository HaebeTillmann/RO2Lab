module regset(
	input [31:0] D,
	input [4:0] A_D, A_Q0, A_Q1,
	input write_enable, RES, CLK,
	output [31:0] Q0, Q1
	);

    integer i;
	reg [31:0] dat [31:0];
	
	assign Q0 = dat[A_Q0];
	assign Q1 = dat[A_Q1];

	always @(posedge CLK) begin
	   if (RES) begin
			for (i = 0; i < 32; i=i+1) begin
				dat[i] = 32'h0000;
			end
		end
		else begin
            if (write_enable) begin
              if (A_D != 0) begin
               dat[A_D] = D;
              end
            end
        end
	end
endmodule
