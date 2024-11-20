`define ALU_ADD 6'b000001
`define ALU_SUB 6'b100001
`define ALU_AND 6'b011101
`define ALU_OR 6'b011001
`define ALU_XOR 6'b010001
`define ALU_SLL 6'b000101
`define ALU_SRA 6'b110101
`define ALU_SRL 6'b010101
`define ALU_SLT 6'b001001
`define ALU_SLTU 6'b001101
`define ALU_EQ 6'b?00010
`define ALU_NE 6'b?00110
`define ALU_LT 6'b?10010
`define ALU_GE 6'b?10110
`define ALU_LTU 6'b?11010
`define ALU_GEU 6'b?11110


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
