`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2025 04:28:10 PM
// Design Name: 
// Module Name: MUX_4x1_32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MUX_4x1_32(
    input [31:0] I0,
    input [31:0] I1,
    input [31:0] I2,
    input [31:0] I3,
    input [1:0] S,
    output [31:0] Y
    );
    wire x1, x2;
    assign Y= (S[1]==1'b0) ? X0 : X1;
    assign X0 = (S[0]==1'b0) ? I0 : I1;
    assign X1 = (S[0]==1'b0) ? I2 : I3;
endmodule
