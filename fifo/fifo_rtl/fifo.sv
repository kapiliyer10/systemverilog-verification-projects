module fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16)
    (
    input logic [WIDTH-1:0] din,
    input logic clk,rst,wr_en,rd_en,
    output logic full,empty,
    output logic [WIDTH-1:0] dout
    );
    
    localparam int ADDR_WIDTH = $clog2(DEPTH);
    localparam int COUNT_WIDTH = $clog2(DEPTH+1);

    logic [ADDR_WIDTH-1:0] rd_ptr,wr_ptr;
    logic [COUNT_WIDTH-1:0] count;
    logic [WIDTH-1:0] buffer [0:DEPTH-1];
    
    assign full = (count==DEPTH);
    assign empty = (count==0);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(int i=0;i<DEPTH;i++)
                buffer[i]<= '0;
            wr_ptr <= '0;
        end
        else if (wr_en && !full) begin
            buffer[wr_ptr]<=din;
            wr_ptr <= wr_ptr + 1;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            dout <= '0;
            rd_ptr <= 0;            
        end
        else if (rd_en && !empty) begin
            dout<=buffer[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            count <= 0;            
        end
        else begin
            case ({rd_en && !empty ,wr_en && !full})
                2'b01: count<= count + 1;
                2'b10: count<= count - 1;
                default: count<=count;
            endcase
        end
    end
            
    always@(posedge clk) $display("%0p at %0t",buffer,$time);
endmodule
