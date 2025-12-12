`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 10:37:04 PM
// Design Name: 
// Module Name: Control_unit
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


module Control_unit(
input [6:0] opcode,
output reg branch,mem_read,mem_write,mem_to_reg, reg_write, jal,jalr,
output reg [1:0]alu_op,
output reg alu_src
//output reg uses_rr2
    );

always@(*)
begin
    branch=0;mem_read=0;mem_write=0;mem_to_reg=0;reg_write=0;jal=0;jalr=0;//uses_rr2=0;
    alu_op=2'b00;
    alu_src=0;
     
    case(opcode)
    7'b0110011:begin //R Type
    reg_write=1;
    alu_op=2'b10;
    //uses_rr2=1;
    end

    7'b0010011:begin // I Type
    alu_src=1;
    reg_write=1;
    alu_op=2'b10;
    end

    7'b0000011:begin //LW
    mem_read=1;
    mem_to_reg=1;
    alu_op=2'b00;
    reg_write=1;
    alu_src=1;
    end

    7'b0100011:begin //SW
    mem_write=1;
    alu_op=2'b00;
    alu_src=1;
    //uses_rr2=1;
    end
    
    7'b1100011:begin //Branch
    branch=1;
    alu_op=2'b01;
    //uses_rr2=1;
    end

    7'b1101111:begin //JAL
    jal=1;
    reg_write=1;
    end
    
    7'b1100111:begin //JALR
    jalr=1;
    reg_write=1;
    end
    
    default: begin
    branch=0;
    mem_read=0;
    mem_write=0;
    mem_to_reg=0;
    reg_write=0;
    jal=0;
    jalr=0;
    alu_op=2'b00;
    alu_src=0;
    //uses_rr2=0;
    end
    endcase
  //  $display("alu_src = %0d",alu_src);
end
endmodule
