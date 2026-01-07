module Data_mem(
input clk,readmem,writemem,
input [31:0] addr,
input [31:0] write_data,
output reg [31:0] read_data
    );
    
reg [31:0] data [0:1023];

integer i;
initial begin

  for (i=0;i<1024;i=i+1)begin
    data[i]=32'b0;
  end
 
end
always@(posedge clk)
begin
    if(writemem)
    data[addr[11:2]]<= write_data;
    $display("memory value = %p",data);
end

always@(*)
begin
    if(readmem)
    read_data = data[addr[11:2]];
    else
    read_data = 32'b0;
end

endmodule
