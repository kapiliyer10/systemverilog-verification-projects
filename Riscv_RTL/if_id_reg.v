`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 09:50:13 PM
// Design Name: 
// Module Name: if_id_reg
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


module if_id_reg(
   input  wire clk,
    input  wire rst,
    input  wire stall,    // hold IF/ID when stall
    input  wire flush,    // clear IF/ID (on branch taken)
    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out
    );
    
     always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out    <= 32'b0;
            instr_out <= 32'h00000013; // NOP (ADDI x0,x0,0)
        end else if (flush) begin
            pc_out    <= 32'b0;
            instr_out <= 32'h00000013; // NOP
        end else if (!stall) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
        // if stall: hold previous values
    end
endmodule
