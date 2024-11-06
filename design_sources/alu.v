`include "header_corrected.vh";

module alu(
	input [5:0] S,
	input signed [31:0] A,
	input signed [31:0] B,
	output reg CMP,
	output reg [31:0] Q
	);
	always @(S, A, B)
	begin
		CMP = 0;
		Q = 32'd0;

		casez(S)
			`ALU_ADD: Q = A + B;
			`ALU_SUB: Q = A - B;
			`ALU_AND: Q = A & B;
			`ALU_OR: Q = A | B;
			`ALU_XOR: Q = A ^ B;
			`ALU_SLL: Q = A <<< B;
			`ALU_SRA: Q = A >>> B;
			`ALU_SRL: Q = A >> B;
			`ALU_SLT: Q = A < B;
			`ALU_SLTU: Q = $unsigned(A) < $unsigned(B);
			`ALU_EQ: CMP = A == B;
			`ALU_NE: CMP = A != B;
			`ALU_LT: CMP = A < B;
			`ALU_GE: CMP = A >= B;
			`ALU_LTU: CMP = $unsigned(A) < $unsigned(B);
			`ALU_GEU: CMP = $unsigned(A) >= $unsigned(B);
			default: begin
			     Q = 32'h0;
			     CMP = 0;
			end
		endcase
	end
endmodule
