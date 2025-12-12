`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 05:09:15 PM
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit (
    input  wire ex_mem_regwrite,
    input  wire [4:0] ex_mem_rd,
    input  wire mem_wb_regwrite,
    input  wire [4:0] mem_wb_rd,
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    output reg  [1:0] forwardA, // 00: from ID/EX rs1, 01: from MEM/WB, 10: from EX/MEM
    output reg  [1:0] forwardB
);
    always @(*) begin
        // defaults
        forwardA = 2'b00;
        forwardB = 2'b00;

        // EX hazard (highest priority)
        if (ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1))
            forwardA = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs1))
            forwardA = 2'b01;
        else
            forwardA = 2'b00;
        if (ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2))
            forwardB = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs2))
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end
endmodule