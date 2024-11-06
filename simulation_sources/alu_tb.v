`include "header_corrected.vh"

module alu_tb();
	reg [31:0] A, B;
	reg [5:0] S;
	wire [31:0] Q;
	wire CMP;
	reg [31:0] soll;
	
	alu dut(.A(A), .B(B), .S(S), .Q(Q), .CMP(CMP));

	initial begin
		//ADD
		A = 1; B = 1; S = `ALU_ADD; soll = 2; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 1; B = -1; S = `ALU_ADD; soll = 0; #10;
		if(Q != soll)
		begin
			$display("Testmuster 2 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 32'h7fffffff; B = 1; S = `ALU_ADD; soll = 32'h80000000; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//SUB
		A = 1; B = 1; S = `ALU_SUB; soll = 0; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 32'h80000000; B = 1; S = `ALU_SUB; soll = 32'h7fffffff; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 1; B = -1; S = `ALU_SUB; soll = 2; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//SLL
		A = -1; B = 1; S = `ALU_SLL; soll = -2; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 1; B = 2; S = `ALU_SLL; soll = 4; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//SLT
		A = 1; B = 0; S = `ALU_SLT; soll = 0; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 0; B = 1; S = `ALU_SLT; soll = 1; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 1; B = 1; S = `ALU_SLT; soll = 0; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//SLTU
		A = 32'hfffffffe; B = 32'hffffffff; S = `ALU_SLTU; soll = 1; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//XOR
		A = 12; B = 10; S = `ALU_XOR; soll = 6; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//SRL
		A = -1; B = 1; S = `ALU_SRL; soll = 32'h7fffffff; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 2; B = 2; S = `ALU_SRL; soll = 0; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//SRA
		A = -1; B = 1; S = `ALU_SRA; soll = -1; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 2; B = 2; S = `ALU_SRA; soll = 0; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//OR
		A = 12; B = 10; S = `ALU_OR; soll = 14; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//AND
		A = 12; B = 10; S = `ALU_AND; soll = 8; #10;
		if(Q != soll)
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//EQ
		A = 0; B = 0; S = `ALU_EQ; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = -1; B = 1; S = `ALU_EQ; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//NE
		A = 0; B = 0; S = `ALU_NE; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = -1; B = 1; S = `ALU_NE; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//LT		
		A = -1; B = 1; S = `ALU_LT; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 0; B = 0; S = `ALU_LT; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 1; B = -1; S = `ALU_LT; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//GE
		A = -1; B = 1; S = `ALU_GE; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 0; B = 0; S = `ALU_GE; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 1; B = -1; S = `ALU_GE; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end

		//LTU
		A = 32'hffffffff; B = 32'hfffffffe; S = `ALU_LTU; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 32'hfffffffe; B = 32'hffffffff; S = `ALU_LTU; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 32'hffffffff; B = 32'hffffffff; S = `ALU_LTU; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end


		//GEU
		A = 32'hffffffff; B = 32'hfffffffe; S = `ALU_GEU; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 32'hfffffffe; B = 32'hffffffff; S = `ALU_GEU; soll = 0; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		A = 32'hffffffff; B = 32'hffffffff; S = `ALU_GEU; soll = 1; #10;
		if(CMP != soll[0])
		begin
			$display("Testmuster 1 Fehlgeschlagen: ist=%h soll=%h", Q, soll);
			$finish;
		end
		$display("Test abgeschlossen");
	end
endmodule

