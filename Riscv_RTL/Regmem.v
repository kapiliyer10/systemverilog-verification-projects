`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2025 11:14:32 PM
// Design Name: 
// Module Name: Regmem
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


module Regmem(
input clk,we,
input [4:0] rr1,
input [4:0] rr2,
input [4:0] wr,
input [31:0] wd,
output [31:0] rd1,
output [31:0] rd2    
    );
//assign rd2=32'b0;
reg [31:0] regs [0:31];

integer i;
initial begin

  for (i=0;i<32;i=i+1)begin
    regs[i]=32'b0;
  end
 
end
//always@(rr1) rd1<=(rr1!=5'd0)?regs[rr1]:32'h0000_0000;
//always@(rr2) rd2<=(rr2!=5'd0)?regs[rr2]:32'h0000_0000;
assign rd1=(rr1!=5'd0)?regs[rr1]:32'h0000_0000;
assign rd2=(rr2!=5'd0)?regs[rr2]:32'h0000_0000;
//assign rd2=regs[rr2];
always @(posedge clk)
    begin
    $display("data array = %p",regs);
        if (we&&(wr!=5'd0))
            regs[wr]<=wd;
            //$display("rd1 = %0d rd2=%0d rr1=%0d rr2=%0d wd = %0d wr = %0d, we = %0d", rd1,rd2,rr1,rr2,wd,wr,we);
            //$display("regmem %0p",regs);
    end
    
endmodule
