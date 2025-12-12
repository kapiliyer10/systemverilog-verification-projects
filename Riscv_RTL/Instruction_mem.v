`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 11:04:17 PM
// Design Name: 
// Module Name: Instruction_mem
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


module Instruction_mem(

input [31:0] addr,
output [31:0] instr
    );

reg [31:0] instr_mem [0:255];
integer i;
integer j;
initial begin
   $readmemh("C:\\Vivado practice\\SRAM_Project\\SRAM_Project.srcs\\sources_1\\new\\code.hex",instr_mem); 
   //for(i=0;i<255;i=i+1)begin
   //$display("Intructions: %0h",instr_mem[i]);
   //if (instr_mem[i]==32'hxxxxxxxx)
     //instr_mem[i]=32'h00000000;
   //end
   //for(j=0;j<15;j=j+1)begin
    // $display("Intructions: %0h",instr_mem[j]);
   //end
end
assign instr = instr_mem[addr[9:2]];
    
endmodule
