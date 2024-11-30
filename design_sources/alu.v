`define ALU_ADD 8'b00000001
`define ALU_SUB 8'b00100001
`define ALU_AND 8'b00011101
`define ALU_OR 8'b00011001
`define ALU_XOR 8'b00010001
`define ALU_SLL 8'b00000101
`define ALU_SRA 8'b00110101
`define ALU_SRL 8'b00010101
`define ALU_SLT 8'b00001001
`define ALU_SLTU 8'b00001101
`define ALU_EQ 8'b00?00010
`define ALU_NE 8'b00?00110
`define ALU_LT 8'b00?10010
`define ALU_GE 8'b00?10110
`define ALU_LTU 8'b00?11010
`define ALU_GEU 8'b00?11110

// Direktwertbefehle
`define ALU_LUI 8'b10??????
`define ALU_AUIPC 8'b01??????


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
			`ALU_LUI: Q = B << 12;
			`ALU_AUIPC: Q = (B << 12) + A
			default: begin
			     Q = 32'h0;
			     CMP = 0;
			end
		endcase
	end
endmodule
