`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2025 09:19:56 PM
// Design Name: 
// Module Name: ALU_Control
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


module ALU_Control(
input [1:0]alu_op,
input [2:0]func3,
input [6:0]func7,
output reg[3:0] alu_ctrl
    );
    
    always @(*) begin
        // default map - extend as needed
        alu_ctrl = 4'b0010; // add
        if (alu_op==2'b10) begin // R-type
            case (func3)
                3'b000: alu_ctrl = (func7 == 7'b0100000) ? 4'b0110 : 4'b0010; // sub/add
                3'b111: alu_ctrl = 4'b0000; // and
                3'b110: alu_ctrl = 4'b0001; // or
                3'b100: alu_ctrl = 4'b1100; // xor
                3'b010: alu_ctrl = 4'b0111; // slt
                default: alu_ctrl = 4'b0010;
            endcase
        end 
        else if (alu_op==2'b01) begin
            case (func3)
            3'b000,3'b001: alu_ctrl = 4'b0110; // compare (sub)
            3'b100: alu_ctrl = 4'b0111;
            3'b101: alu_ctrl = 4'b0111;
            default:alu_ctrl = 4'b0110;
         endcase   
        end
       // $display("aluctrl = %d",alu_ctrl);
    end

endmodule
