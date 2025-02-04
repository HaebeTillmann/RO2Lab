module instr_cache#(parameter SIZE=128)(
	input clk,
	input res,

	// Schnittstelle zwischen Prozessor und Cache
	input cached_instr_req,
	input [31:0] cached_instr_adr,
	output reg cached_instr_valid,
	output reg [31:0] cached_instr_read,

	// Schnittstellen zwischen Cache und Hauptspeicher
	output reg instr_req,
	output [31:0] instr_adr,
	input instr_valid,
	input [31:0] instr_read
);

reg [31:0] lines [SIZE-1:0];
reg [31-$clog2(SIZE):0] tags [SIZE-1:0];
reg [SIZE-1:0] valids;
wire hit;
wire [$clog2(SIZE)-1:0] index;

assign index = cached_instr_adr[$clog2(SIZE)-1:0];
assign hit = (cached_instr_adr[31:$clog2(SIZE)] == tags[index]) && valids[index];
assign instr_adr = cached_instr_adr;

always @(posedge clk) begin 
	if(res == 1'b1) valids <= {SIZE{1'b0}};
	else if (hit == 1'b0 && instr_valid) begin
		lines[index] <= instr_read;
		tags[index] <= cached_instr_adr[31:$clog2(SIZE)];
		valids[index] <= 1;
	end
end

always @(*) begin
    instr_req = 1'b0;
    cached_instr_read = 32'b0;
    cached_instr_valid <= 1'b0;
    if (hit == 1'b1) begin
        instr_req = 1'b0;
        cached_instr_read = lines[index];
        cached_instr_valid <= 1'b1;
    end
    else if (hit == 1'b0) begin
        instr_req = 1'b1;
        cached_instr_read = instr_read;
        cached_instr_valid = instr_valid;
    end
end
endmodule
