//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 08:06:31 PM
// Design Name: 
// Module Name: RISCV_wp
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


`timescale 1ns/1ps
module RISCV_wp (
    input  wire clk,
    input  wire rst
);
    // IF stage wires
    wire [31:0] pc, pc_next, pc_plus4;
    wire [31:0] instr_if;

    // instantiate PC and IMEM (from your existing modules) - see RISCV.docx. :contentReference[oaicite:1]{index=1}
    PC pc_u (.clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc));
    Instruction_mem imem_u (.addr(pc), .instr(instr_if));

    assign pc_plus4 = pc + 4;

    // IF/ID pipeline regs
    wire [31:0] if_id_pc, if_id_instr;
    wire        if_id_stall;
    wire         if_id_flush;
    if_id_reg u_if_id (.clk(clk), .rst(rst), .stall(if_id_stall), .flush(if_id_flush),
                       .pc_in(pc), .instr_in(instr_if),
                       .pc_out(if_id_pc), .instr_out(if_id_instr));

    // ID stage decode fields
    wire [6:0]  id_opcode = if_id_instr[6:0];
    wire [4:0]  id_rd     = if_id_instr[11:7];
    wire [2:0]  id_funct3 = if_id_instr[14:12];
    wire [4:0]  id_rs1    = if_id_instr[19:15];
    wire [4:0]  id_rs2    = if_id_instr[24:20];
    wire [6:0]  id_funct7 = if_id_instr[31:25];

    // ID: control unit and imm gen (your modules)
    wire branch_id, mem_read_id, mem_write_id, mem_to_reg_id, reg_write_id, jal_id, jalr_id, alu_src_id;
    wire [1:0] alu_op_id;
    Control_unit ctrl_u(.opcode(id_opcode), .branch(branch_id), .mem_read(mem_read_id), .mem_write(mem_write_id),
                        .mem_to_reg(mem_to_reg_id), .reg_write(reg_write_id), .jal(jal_id), .jalr(jalr_id),
                        .alu_src(alu_src_id), .alu_op(alu_op_id)); // from file. :contentReference[oaicite:2]{index=2}

    wire [31:0] imm_id;
    Imm_gen imm_u(.instr(if_id_instr), .imm(imm_id)); // from file. :contentReference[oaicite:3]{index=3}

    // Register file read (your Regmem supports asynchronous reads)
    wire [31:0] reg_rd1, reg_rd2;
    // We'll write to regfile in WB stage using Regmem's write interface.
    // Create temporary signals for writeback
    wire        wb_reg_write;
    wire [4:0]  wb_rd;
    wire [31:0] wb_wd;

    Regmem regfile_u(.clk(clk), .we(wb_reg_write), .rr1(id_rs1), .rr2(id_rs2), .wr(wb_rd), .wd(wb_wd),
                     .rd1(reg_rd1), .rd2(reg_rd2)); // from file. :contentReference[oaicite:4]{index=4}

    // ID/EX pipeline regs
    wire [31:0] id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    wire [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire        id_ex_reg_write, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg;
    wire [1:0]  id_ex_alu_op;
    wire        id_ex_alu_src, id_ex_branch, id_ex_jal, id_ex_jalr;
    wire [2:0]  id_ex_funct3;
    wire [6:0]  id_ex_funct7;

    // stall/flush control from hazard unit and branch decision
    wire hazard_stall;
    wire pc_write;
   // wire ifid_flush_w = 1'b0; // will be set on branch taken when in EX

    hazard_unit hz_u (.id_ex_memread(id_ex_mem_read), .id_ex_rd(id_ex_rd),
                      .if_id_rs1(id_rs1), .if_id_rs2(id_rs2),
                      .stall(hazard_stall), .pc_write(pc_write));

    // connect stall/flush to IF/ID and ID/EX
    assign if_id_stall = hazard_stall;
    // ID/EX will be given stall/flush signals below
    wire [31:0] rd1_final, rd2_final; 
    id_ex_reg u_id_ex (.clk(clk), .rst(rst), .stall(if_id_stall), .flush(if_id_flush),
                       .pc_in(if_id_pc), .rs1_data_in(rd1_final), .rs2_data_in(rd2_final),
                       .imm_in(imm_id), .rs1_in(id_rs1), .rs2_in(id_rs2), .rd_in(id_rd),
                       .reg_write_in(reg_write_id), .mem_read_in(mem_read_id),
                       .mem_write_in(mem_write_id), .mem_to_reg_in(mem_to_reg_id),
                       .alu_op_in(alu_op_id), .alu_src_in(alu_src_id),
                       .branch_in(branch_id), .jal_in(jal_id), .jalr_in(jalr_id),
                       .funct3_in(id_funct3), .funct7_in(id_funct7),
                       .pc_out(id_ex_pc), .rs1_data_out(id_ex_rs1_data), .rs2_data_out(id_ex_rs2_data),
                       .imm_out(id_ex_imm), .rs1_out(id_ex_rs1), .rs2_out(id_ex_rs2), .rd_out(id_ex_rd),
                       .reg_write_out(id_ex_reg_write), .mem_read_out(id_ex_mem_read),
                       .mem_write_out(id_ex_mem_write), .mem_to_reg_out(id_ex_mem_to_reg),
                       .alu_op_out(id_ex_alu_op), .alu_src_out(id_ex_alu_src),
                       .branch_out(id_ex_branch), .jal_out(id_ex_jal), .jalr_out(id_ex_jalr),
                       .funct3_out(id_ex_funct3), .funct7_out(id_ex_funct7));

    // EX stage: ALU control (use your ALU_Control)
    wire [3:0] alu_ctrl_ex;
    ALU_Control aluctrl_ex(.alu_op(id_ex_alu_op), .func3(id_ex_funct3), .func7(id_ex_funct7), .alu_ctrl(alu_ctrl_ex)); // from file. :contentReference[oaicite:5]{index=5}

    // Forwarding signals
    wire [1:0] forwardA, forwardB;
    // need ex_mem and mem_wb stage regwrite and rd wires - declare below when ex_mem/mem_wb created
    // For now declare nets to be connected later:
    wire exmem_regwrite_wire, memwb_regwrite_wire;
    wire [4:0] exmem_rd_wire, memwb_rd_wire;

    forwarding_unit fwd_u (.ex_mem_regwrite(exmem_regwrite_wire), .ex_mem_rd(exmem_rd_wire),
                           .mem_wb_regwrite(memwb_regwrite_wire), .mem_wb_rd(memwb_rd_wire),
                           .id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2),
                           .forwardA(forwardA), .forwardB(forwardB));

    // EX-stage operand selection with forwarding
    reg [31:0] alu_in1, alu_in2;
    // We'll need values from EX/MEM and MEM/WB:
    wire [31:0] exmem_alu_result, exmem_mem_data_forw;
    wire [31:0] id_ex_rs2_final_sw;
   // wire memwb_mem_to_reg_out;
    always @(*) begin
        
        // operand A (rs1)
        case (forwardA)
            2'b00: alu_in1 = id_ex_rs1_data;                // from ID/EX
            2'b10: alu_in1 = exmem_alu_result;              // from EX/MEM
            2'b01: alu_in1 = wb_wd; // from MEM/WB (decide mem or alu)
            default: alu_in1 = id_ex_rs1_data;
        endcase

        // operand B (rs2 or imm)
        case (forwardB)
            2'b00: alu_in2 = id_ex_alu_src ? id_ex_imm : id_ex_rs2_data;
            2'b10: alu_in2 = id_ex_mem_write?id_ex_imm:exmem_alu_result;
            2'b01: alu_in2 = id_ex_mem_write?id_ex_imm:wb_wd;
            default: alu_in2 = id_ex_alu_src ? id_ex_imm : id_ex_rs2_data;
        endcase
    end

//wire [31:0] id_ex_rs2_final_sw;
assign id_ex_rs2_final_sw = (~id_ex_mem_write)?id_ex_rs2_data:(forwardB==2'b01)?
                            wb_wd:
                            exmem_alu_result;
   
    // ALU instance (your ALU)
    wire [31:0] alu_result_ex;
    wire        zero_ex;
    ALU alu_ex(.d1(alu_in1), .d2(alu_in2), .alu_ctrl(alu_ctrl_ex), .zero(zero_ex), .alures(alu_result_ex)); // from file. :contentReference[oaicite:6]{index=6}


    // Prepare inputs to EX/MEM register
   // wire [31:0] ex_mem_pc_in = id_ex_pc;
   // wire [31:0] ex_mem_rs2_data_in = id_ex_rs2_data;
   // wire [4:0]  ex_mem_rd_in = id_ex_rd;
 
  /*  wire        ex_mem_reg_write_in = id_ex_reg_write;
    wire        ex_mem_mem_read_in  = id_ex_mem_read;
    wire        ex_mem_mem_write_in = id_ex_mem_write;
    wire        ex_mem_mem_to_reg_in = id_ex_mem_to_reg; */

    // EX/MEM pipeline register wires
    wire [31:0] ex_mem_pc,ex_mem_alu_result_in, ex_mem_alu_result, ex_mem_rs2_data;
    wire [4:0]  ex_mem_rd;
    wire        ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg;
    ex_mem_reg u_ex_mem (.clk(clk), .rst(rst),
                         //.pc_in(ex_mem_pc_in), .alu_result_in(ex_mem_alu_result_in),
                         .pc_in(id_ex_pc), .alu_result_in(ex_mem_alu_result_in),
                         //.rs2_data_in(ex_mem_rs2_data_in), .rd_in(ex_mem_rd_in),
                         .rs2_data_in(id_ex_rs2_final_sw), .rd_in(id_ex_rd),
                         //.reg_write_in(ex_mem_reg_write_in), .mem_read_in(ex_mem_mem_read_in),
                         .reg_write_in(id_ex_reg_write), .mem_read_in(id_ex_mem_read),
                         //.mem_write_in(ex_mem_mem_write_in), .mem_to_reg_in(ex_mem_mem_to_reg_in),
                         .mem_write_in(id_ex_mem_write), .mem_to_reg_in(id_ex_mem_to_reg),
                         .pc_out(ex_mem_pc), .alu_result_out(ex_mem_alu_result),
                         .rs2_data_out(ex_mem_rs2_data), .rd_out(ex_mem_rd),
                         .reg_write_out(ex_mem_reg_write), .mem_read_out(ex_mem_mem_read),
                         .mem_write_out(ex_mem_mem_write), .mem_to_reg_out(ex_mem_mem_to_reg));

    // connect forwarding inputs (now that ex_mem regs exist)
    assign exmem_regwrite_wire = ex_mem_reg_write;
    assign exmem_rd_wire       = ex_mem_rd;

    // MEM stage: data memory access (your Data_mem)
    wire [31:0] mem_dmem_read;
    Data_mem dmem_u(.clk(clk), .readmem(ex_mem_mem_read), .writemem(ex_mem_mem_write),
                    .addr(ex_mem_alu_result), .write_data(ex_mem_rs2_data), .read_data(mem_dmem_read)); // from file. :contentReference[oaicite:7]{index=7}

    // EX/MEM outputs used for forwarding
    assign exmem_alu_result = ex_mem_alu_result;
    assign exmem_mem_data_forw = mem_dmem_read;

    // MEM/WB register inputs
/*    wire [31:0] mem_wb_alu_result_in = ex_mem_alu_result;
    wire [31:0] mem_wb_mem_data_in   = mem_dmem_read;
    wire [4:0]  mem_wb_rd_in         = ex_mem_rd;
    wire        mem_wb_reg_write_in  = ex_mem_reg_write;
    wire        mem_wb_mem_to_reg_in = ex_mem_mem_to_reg;*/

    // MEM/WB regs
    wire [31:0] mem_wb_alu_result, mem_wb_mem_data;
    wire [4:0]  mem_wb_rd;
    wire        mem_wb_reg_write, mem_wb_mem_to_reg_out;

    mem_wb_reg u_mem_wb (.clk(clk), .rst(rst),
                       //.alu_result_in(mem_wb_alu_result_in), .mem_data_in(mem_wb_mem_data_in),
                        .alu_result_in(ex_mem_alu_result), .mem_data_in(mem_dmem_read),
                       //.rd_in(mem_wb_rd_in), .reg_write_in(mem_wb_reg_write_in),
                        .rd_in(ex_mem_rd), .reg_write_in(ex_mem_reg_write),
                       //.mem_to_reg_in(mem_wb_mem_to_reg_in),
                        .mem_to_reg_in(ex_mem_mem_to_reg),
                        .alu_result_out(mem_wb_alu_result), .mem_data_out(mem_wb_mem_data),
                        .rd_out(mem_wb_rd), .reg_write_out(mem_wb_reg_write),
                        .mem_to_reg_out(mem_wb_mem_to_reg_out));

    // connect forwarding MEM/WB inputs
    assign memwb_regwrite_wire = mem_wb_reg_write;
    assign memwb_rd_wire       = mem_wb_rd;
  //  assign mem_wb_mem_to_reg_out = memwb_mem_to_reg_out;

    // WB stage: choose writeback data (mem or alu)
    assign wb_reg_write = mem_wb_reg_write;
    assign wb_rd        = mem_wb_rd;
    assign wb_wd        = mem_wb_mem_to_reg_out ? mem_wb_mem_data : mem_wb_alu_result;

    // expose memwb signals used in forwarding case expressions
    // create helper signals for forwarding selection:
    // memwb_mem_to_reg_out already exists as a wire from mem_wb_reg instance

    // For forwarding selection above we used memwb_mem_to_reg_out, memwb_alu_result, memwb_mem_data
    // connect aliases:
    // memwb_alu_result and memwb_mem_data defined above; memwb_mem_to_reg_out defined as
    // mem_wb_reg instance output mem_to_reg_out


   
// Default next PC
wire [31:0] branch_target,jal_target, jalr_target;
assign branch_target= id_ex_pc + id_ex_imm;
assign jal_target    = id_ex_pc + id_ex_imm;
assign jalr_target   = (alu_in1 + id_ex_imm) & 32'hFFFFFFFE; // rs1 + imm, aligned

wire branch_taken;
assign branch_taken = (id_ex_branch&(id_ex_funct3==3'b000|id_ex_funct3==3'b101) & zero_ex)|
(id_ex_branch&(id_ex_funct3==3'b001|id_ex_funct3==3'b100)&~zero_ex);

// Select final PC source
assign pc_next = (id_ex_jalr) ? jalr_target :
                 (id_ex_jal)  ? jal_target  :
                 (branch_taken) ? branch_target :
                 (pc_write)?pc_plus4:pc;
                 

// flush pipeline on any control transfer
wire [31:0] ex_result;
wire jump_taken;
assign jump_taken= id_ex_jal | id_ex_jalr;
wire control_flush;
assign control_flush = branch_taken | jump_taken;
assign ex_result =(id_ex_jal | id_ex_jalr) ? (id_ex_pc + 4) : alu_result_ex;
assign ex_mem_alu_result_in = ex_result;

 // Branch handling: when branch_taken, flush IF/ID and ID/EX and set PC to branch target
    // branch target = id_ex_pc + imm (we passed id_ex_pc and imm to EX)
 /*   reg flush_ifid; //flush_idex;
    always @(*) begin
        if (control_flush) begin
            flush_ifid = 1'b1;
           // flush_idex = 1'b1;
        end else begin
            flush_ifid = 1'b0;
           // flush_idex = 1'b0;
        end
    end
    
     // assign IF/ID flush to be driven
    // to avoid multiple drivers we drive if_id_flush via a reg earlier; here update via procedural block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            if_id_flush <= 1'b0;
        end else begin
            if_id_flush <= flush_ifid;
        end
    end */
  assign if_id_flush = (control_flush)?1'b1:1'b0;

  assign rd1_final = ((mem_wb_rd != 0)&&(id_rs1!=0)&&(mem_wb_rd==id_rs1))?wb_wd:reg_rd1;
  assign rd2_final = ((mem_wb_rd != 0)&&(id_rs2!=0)&&(mem_wb_rd==id_rs2))?wb_wd:reg_rd2;

integer i=1;
always @(posedge clk or posedge rst) begin
$display("------------------------------------------");
$display("Cycle = %d",i);
//$display("branch_target = %d branch_taken=%d",branch_target,branch_taken);
//$display("pc_next = %d",pc_next);
//$display("pc = %d",pc);
$display("branch_taken = %0d",branch_taken);
$display("id_ex_funct3 = %0d",id_ex_funct3);
//$display("control_flush = %0d",control_flush);
i=i+1;
end
endmodule