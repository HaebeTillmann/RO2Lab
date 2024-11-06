module pc_tb ();
	reg [31:0] D;
	reg MODE, ENABLE, RES, CLK;
	wire [31:0] PC_OUT;
	reg [31:0] soll;

	pc dut(.D(D), .MODE(MODE), .ENABLE(ENABLE), .RES(RES), .CLK(CLK), .PC_OUT(PC_OUT));

	initial begin
		// initialwert
		D = 0; MODE = 0; ENABLE = 0; RES = 0; CLK = 0; soll = 32'h1A000000; #10;
		if (PC_OUT != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", PC_OUT, soll);
			$finish;
		end

		// hochzählen
		D = 0; MODE = 0; ENABLE = 1; RES = 0; CLK = 0; soll = 32'h1A000004; #10;
		CLK = 1; #10;
		if (PC_OUT != soll)
		begin
			$display("Testmuster 2 Fehlgeschlagen: ist=%h soll=%h", PC_OUT, soll);
			$finish;
		end

		// reset
		D = 0; MODE = 0; ENABLE = 1; RES = 1; CLK = 0; soll = 32'h1A000000; #10;
		CLK = 1; #10;
		if (PC_OUT != soll)
		begin
			$display("Testmuster 3 Fehlgeschlagen: ist=%h soll=%h", PC_OUT, soll);
			$finish;
		end

		// enable = 0
		D = 0; MODE = 0; ENABLE = 0; RES = 0; CLK = 0; soll = 32'h1A000000; #10;
		CLK = 1; #10;
		if (PC_OUT != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", PC_OUT, soll);
			$finish;
		end

		// mode = 1
		D = 0; MODE = 1; ENABLE = 1; RES = 0; CLK = 0; soll = 0; #10;
		CLK = 1; #10;
		if (PC_OUT != soll)
		begin
			$display("Testmuster 3 Fehlgeschlagen: ist=%h soll=%h", PC_OUT, soll);
			$finish;
		end
	end
endmodule

