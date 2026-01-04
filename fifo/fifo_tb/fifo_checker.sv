`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2026 12:00:36 PM
// Design Name: 
// Module Name: fifo_checker
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


module fifo_checker #(
  parameter DEPTH = 16
)(
  input  logic clk,
  input  logic rst,

  input  logic wr_en,
  input  logic rd_en,
  input  logic full,
  input  logic empty,

  input  logic [7:0] din,
  input  logic [7:0] dout
);

  integer cnt;

  always @(posedge clk or posedge rst) begin
    if (rst) cnt <= 0;
    else begin
      if (wr_en && !full)  cnt = cnt + 1;
      if (rd_en && !empty) cnt = cnt - 1;
      $display("Count %0d at %0t",cnt,$time );
    end
    $display("Full = %0d Empty = %0d wr_en = %0d rd_en = %0d at %0t",
             full,empty,wr_en,rd_en,$time);
 end
 
 property no_write_when_full;
   @(posedge clk) disable iff(rst)
   full |->!wr_en;
 endproperty
 assert property(no_write_when_full)
 else $error("SVA: WRITE attempted when FIFO is FULL");
 
 property no_read_when_empty;
   @(posedge clk) disable iff(rst)
   empty |->!rd_en;
 endproperty
 assert property(no_read_when_empty)
 else $error("SVA: READ attempted when FIFO is EMPTY");   

 property count_in_range;
   @(posedge clk) disable iff(rst)
   (cnt inside {[0:DEPTH]});
 endproperty
 assert property(count_in_range)
 else $error("SVA: FIFO count %0d out of range",cnt); 
 
 property no_simult_rw;
   @(posedge clk) disable iff(rst)
   !(wr_en && rd_en && (full || empty));
 endproperty
 assert property(no_simult_rw)
 else $error("SVA: FIFO simultaneous R/W detected");
 
 always @(posedge clk) begin
  $display("CHK @%0t  empty=%0b rd_en=%0b wr_en=%0b", 
            $time, empty, rd_en, wr_en);
end
    
endmodule
