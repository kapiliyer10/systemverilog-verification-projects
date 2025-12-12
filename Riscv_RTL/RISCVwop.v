`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2025 06:37:47 PM
// Design Name: 
// Module Name: RISCVwop
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

/*`include "PC.v "
`include "Instruction_mem.v"
`include "Regmem.v"
`include "Imm_gen.v"
`include "Data_mem.v"
`include "ALU.v"
`include "Control_unit.v"*/

module RISCVwop(
input clk,rst
    );

//PC

wire [31:0] pc,pc_next;
PC pc1 (.clk(clk), .rst(rst), .pc(pc), .pc_next(pc_next));

//Instruction Memory

wire [31:0] instr;
Instruction_mem Imem (.addr(pc), .instr(instr));

wire [6:0] opcode = instr[6:0];
wire [4:0] wreg = instr[11:7];
wire [2:0] func3 = instr[14:12];
wire [4:0] rr1 = instr[19:15];
wire [4:0] rr2 = instr[24:20];
wire [6:0] func7 = instr[31:25];
 
//Control
wire branch,mem_read,mem_write,mem_to_reg, reg_write, jal,jalr,alu_src;
wire [1:0] alu_op;

Control_unit cu(.opcode(opcode),.branch(branch),.mem_read(mem_read),.mem_write(mem_write),
.mem_to_reg(mem_to_reg),.reg_write(reg_write),.jal(jal),.jalr(jalr),.alu_src(alu_src),
.alu_op(alu_op));

//Register Memory
wire [31:0] rd1,rd2,wd;

Regmem regmem(.clk(clk),.we(reg_write),.rr1(rr1),.rr2(rr2),.wr(wreg),.wd(wd),
.rd1(rd1),.rd2(rd2));


//Immediate Generator
wire [31:0] imm;
Imm_gen immgen(.instr(instr),.imm(imm));

// ALU i/p mux
wire [31:0]aluin2;
assign aluin2 = (alu_src==1)?imm:rd3;

//ALU
wire zero;
wire [31:0]alu_res;
wire [3:0]alu_ctrl;

ALU alu(.d1(rd1),.d2(aluin2),.alu_ctrl(alu_ctrl),.zero(zero),.alures(alu_res));

//ALU Control

ALU_Control aluctrl(.func3(func3),.func7(func7),.alu_ctrl(alu_ctrl),.alu_op(alu_op));
    
//Data Memory

wire [31:0]demem_rd;
Data_mem dmem (.clk(clk),.readmem(mem_read),.writemem(mem_write),.write_data(rd2),
.addr(alu_res),.read_data(demem_rd));

//Writeback Mux
assign wd = (mem_to_reg==1)?demem_rd:alu_res;

reg [31:0] pc_new;
//Branch Mux
always@(*)
begin
    if ((branch&zero)|jal)
    pc_new = pc+imm;
    else if(jalr)
    pc_new = rd1+imm;
    else
    pc_new = pc + 32'h4;
end

//JAL / JALR
wire [31:0]rd3;
assign rd3 = (jal|jalr)?(pc+4):rd2;
assign pc_next = pc_new;


endmodule
