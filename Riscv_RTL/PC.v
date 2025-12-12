`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 10:01:36 PM
// Design Name: 
// Module Name: PC
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


module PC(
input clk,rst,
input [31:0] pc_next,
output reg [31:0] pc
    );


always@(posedge clk)
begin
    if (rst)
        pc<=32'h0000_0000;
    else
        pc<=pc_next;
   //$display("pc = %0h",pc);
end
endmodule