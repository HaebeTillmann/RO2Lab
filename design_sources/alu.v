`define ALU_ADD 7'b0000001
`define ALU_SUB 7'b0100001
`define ALU_AND 7'b0011101
`define ALU_OR 7'b0011001
`define ALU_XOR 7'b0010001
`define ALU_SLL 7'b0000101
`define ALU_SRA 7'b0110101
`define ALU_SRL 7'b0010101
`define ALU_SLT 7'b0001001
`define ALU_SLTU 7'b0001101
`define ALU_EQ 7'b0?00010
`define ALU_NE 7'b0?00110
`define ALU_LT 7'b0?10010
`define ALU_GE 7'b0?10110
`define ALU_LTU 7'b0?11010
`define ALU_GEU 7'b0?11110
`define ALU_DVI 7'b1??????


module alu(
	input [6:0] S,
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
			`ALU_DVI: Q = (B << 12) + A;
			default: begin
			     Q = 32'h0;
			     CMP = 0;
			end
		endcase
	end
endmodule
