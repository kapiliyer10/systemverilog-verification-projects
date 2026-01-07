module PC(
input clk,rst,
input [31:0] pc_next,
output reg [31:0] pc
    );


always@(posedge clk)
begin
    if (rst)
        pc<=32'h0000_0000;
    else
        pc<=pc_next;
   //$display("pc = %0h",pc);
end
endmodule
