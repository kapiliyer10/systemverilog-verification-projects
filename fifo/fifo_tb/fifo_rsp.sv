`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2025 12:04:43 PM
// Design Name: 
// Module Name: fifo_rsp
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


class fifo_rsp #(parameter WIDTH = 8);

    logic [WIDTH-1:0] data;
    bit rd_en;
    bit wr_en;
    
endclass
