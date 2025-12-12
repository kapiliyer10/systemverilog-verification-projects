`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 05:36:42 PM
// Design Name: 
// Module Name: id_ex_reg
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

module id_ex_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,     // when inserting bubble, we set control fields to 0
    input  wire        flush,
    // inputs
    input  wire [31:0] pc_in,
    input  wire [31:0] rs1_data_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] imm_in,
    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,
    input  wire [4:0]  rd_in,
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        mem_to_reg_in,
    input  wire [1:0]  alu_op_in,
    input  wire        alu_src_in,
    input  wire        branch_in,
    input  wire        jal_in,
    input  wire        jalr_in,
    input  wire [2:0]  funct3_in,
    input  wire [6:0]  funct7_in,
    // outputs
    output reg  [31:0] pc_out,
    output reg  [31:0] rs1_data_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] imm_out,
    output reg  [4:0]  rs1_out,
    output reg  [4:0]  rs2_out,
    output reg  [4:0]  rd_out,
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         mem_to_reg_out,
    output reg  [1:0]  alu_op_out,
    output reg         alu_src_out,
    output reg         branch_out,
    output reg         jal_out,
    output reg         jalr_out,
    output reg  [2:0]  funct3_out,
    output reg  [6:0]  funct7_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out         <= 32'b0;
            rs1_data_out   <= 32'b0;
            rs2_data_out   <= 32'b0;
            imm_out        <= 32'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            rd_out         <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_op_out     <= 2'b0;
            alu_src_out    <= 1'b0;
            branch_out     <= 1'b0;
            jal_out        <= 1'b0;
            jalr_out       <= 1'b0;
            funct3_out     <= 3'b0;
            funct7_out     <= 7'b0;
        end else if (flush) begin
            // convert to bubble on flush: clear control signals, keep others safe
            pc_out         <= 32'b0;
            rs1_data_out   <= 32'b0;
            rs2_data_out   <= 32'b0;
            imm_out        <= 32'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            rd_out         <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_op_out     <= 2'b0;
            alu_src_out    <= 1'b0;
            branch_out     <= 1'b0;
            jal_out        <= 1'b0;
            jalr_out       <= 1'b0;
            funct3_out     <= 3'b0;
            funct7_out     <= 7'b0;
        end else if (stall) begin
            // on stall, convert this stage to bubble by clearing control signals,
            // but hold current outputs (so previous ID stage isn't consumed).
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_op_out     <= 2'b0;
            alu_src_out    <= 1'b0;
            branch_out     <= 1'b0;
            jal_out        <= 1'b0;
            jalr_out       <= 1'b0;
            // retain data outputs as they were (or set to zero); typical approach is to insert bubble with zero controls.
            rs1_data_out   <= rs1_data_in;
            rs2_data_out   <= rs2_data_in;
            imm_out        <= imm_in;
            rs1_out        <= rs1_in;
            rs2_out        <= rs2_in;
            rd_out         <= rd_in;
            funct3_out     <= funct3_in;
            funct7_out     <= funct7_in;
            pc_out         <= pc_in;
        end else begin
            // normal pass-through
            pc_out         <= pc_in;
            rs1_data_out   <= rs1_data_in;
            rs2_data_out   <= rs2_data_in;
            imm_out        <= imm_in;
            rs1_out        <= rs1_in;
            rs2_out        <= rs2_in;
            rd_out         <= rd_in;
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_op_out     <= alu_op_in;
            alu_src_out    <= alu_src_in;
            branch_out     <= branch_in;
            jal_out        <= jal_in;
            jalr_out       <= jalr_in;
            funct3_out     <= funct3_in;
            funct7_out     <= funct7_in;
        end
  //      $display("funct3_in = %d,funct3_out = %d, funct7_in = %d, funct7_out = %d",funct3_in,funct3_out,funct7_in,funct7_out);
    end
endmodule

