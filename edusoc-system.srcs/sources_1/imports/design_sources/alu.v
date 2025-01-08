// AUIPC, LUI, IMM, MUL, ...

`define ALU_NEN 7'b00000000
`define ALU_ADD 7'b00000001
`define ALU_MUL 7'b00100001
`define ALU_SUB 7'b01000001
`define ALU_AND 7'b00011101
`define ALU_OR 7'b00011001
`define ALU_XOR 7'b00010001
`define ALU_SLL 7'b00000101
`define ALU_SRA 7'b01010101
`define ALU_SRL 7'b00010101
`define ALU_SLT 7'b00001001
`define ALU_SLTU 7'b00001101
`define ALU_EQ 7'b0?000010
`define ALU_NE 7'b0?000110
`define ALU_LT 7'b0?010010
`define ALU_GE 7'b0?010110
`define ALU_LTU 7'b0?011010
`define ALU_GEU 7'b0?011110


module alu(
	input [7:0] S,
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
			`ALU_SLL: Q = A << B[5:0];
			`ALU_SRA: Q = A >>> B[5:0];
			`ALU_SRL: Q = A >> B[5:0];
			`ALU_SLT: Q = A < B;
			`ALU_SLTU: Q = $unsigned(A) < $unsigned(B);
			`ALU_EQ: CMP = A == B;
			`ALU_NE: CMP = A != B;
			`ALU_LT: CMP = A < B;
			`ALU_GE: CMP = A >= B;
			`ALU_LTU: CMP = $unsigned(A) < $unsigned(B);
			`ALU_GEU: CMP = $unsigned(A) >= $unsigned(B);
			`ALU_NEN: Q = B;
			`ALU_MUL: Q = A * B;
			default: begin
			     Q = 32'h0;
			     CMP = 0;
			end
		endcase
	end
endmodule
