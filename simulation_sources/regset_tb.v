module regset_tb ();
	reg [31:0] D;
	reg [4:0] A_D, A_Q0, A_Q1;
	reg write_enable, RES, CLK;
	wire [31:0] Q0, Q1;
	reg [31:0] soll;

	integer i;

	regset dut(.D(D), .A_D(A_D), .A_Q0(A_Q0), .A_Q1(A_Q1), .write_enable(write_enable), .RES(RES), .CLK(CLK), .Q0(Q0), .Q1(Q1));

	initial begin
	   // reset
		D = 0; A_D = 12; A_Q0 = 12; A_Q1 = 0; write_enable = 1; RES = 1; CLK = 0; soll = 103; #10;
		CLK = 1; #10;
		CLK = 0;
		soll = 0;
		for (i = 0; i < 32; i=i+1) begin
			A_Q0 = i;
			if (Q0 != soll) begin
				$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q0, soll);
				$finish;
			end
		end
		
		// wert setzen und wieder lesen 
		D = 103; A_D = 12; A_Q0 = 12; A_Q1 = 0; write_enable = 1; RES = 0; CLK = 0; soll = 103; #10;
		CLK = 1; #10;
		if (Q0 != soll) begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q0, soll);
			$finish;
		end

		// wert setzen  mit we=0 
		D = 69; A_D = 12; A_Q0 = 12; A_Q1 = 0; write_enable = 0; RES = 0; CLK = 0; soll = 103; #10;
		CLK = 1; #10;
		if (Q0 != soll) begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q0, soll);
			$finish;
		end

		// asynchron lesen
		D = 0; A_D = 0; A_Q0 = 0; A_Q1 = 0; write_enable = 0; RES = 0; CLK = 0; soll = 0; #10;
		if (Q0 != soll) begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q0, soll);
			$finish;
		end
		$display("Test abgeschlossen");
		
		// wert setzen und wieder lesen mit reset = 1
		D = 103; A_D = 12; A_Q0 = 12; A_Q1 = 0; write_enable = 1; RES = 1; CLK = 0; soll = 0; #10;
		CLK = 1; #10;
		if (Q0 != soll) begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q0, soll);
			$finish;
		end
	end
endmodule
