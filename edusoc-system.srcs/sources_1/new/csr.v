module csr(
    input CLK, RES, RDINSTRET_EN,
    input [11:0] CSR_ADR,
    output reg [31:0] CSR_READ
    );
    
    reg [63:0] RDCYCLE, RDTIME, RDINSTRET;
    reg [15:0] MSCOUNT;
    reg [31:0] MHARTID;
    
    always @(posedge CLK) begin
        if (RES) begin
            RDCYCLE = 64'b0;
            RDTIME = 64'b0;
            RDINSTRET = 64'b0;
            MSCOUNT = 1'b0;
        end
        
        RDCYCLE = RDCYCLE + 1'b1;
        MSCOUNT = MSCOUNT + 1'b1;
        if (MSCOUNT == 25000) begin
            RDTIME = RDTIME + 1;
            MSCOUNT = 1'b0;
        end
        
        case(CSR_ADR)
            'hC00: CSR_READ = RDCYCLE[31:0];
            'hC80: CSR_READ = RDCYCLE[63:32];
            'hC01: CSR_READ = RDTIME[31:0];
            'hC81: CSR_READ = RDTIME[63:32];
            'hC02: CSR_READ = RDINSTRET[31:0];
            'hC82: CSR_READ = RDINSTRET[63:32];
            'hF14: CSR_READ = 32'b0;
            default: CSR_READ = 32'b0;
        endcase
    end
   
  always @(posedge RDINSTRET_EN) RDINSTRET = RDINSTRET + 1;
endmodule
