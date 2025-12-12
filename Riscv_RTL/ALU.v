`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 12:38:05 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
input [31:0]d1,d2,
input [3:0] alu_ctrl,
output zero,
output reg [31:0]alures
    );
    
always@(*)
    begin
    case(alu_ctrl)
        4'b0000: alures=d1&d2;
        4'b0001: alures=d1|d2;
        4'b0010: alures=d1+d2;
        4'b0110: alures= d1-d2;
        4'b1100: alures=d1^d2;
        4'b0111: alures=(d1<d2)?32'h1:32'b0;
        default: alures=32'b0;
    endcase
    //$display("alu_ctrl=%0d alures = %0d d1 = %0d d2=%0d", alu_ctrl,alures,d1,d2);
    end
assign zero=(alures==0);
endmodule
