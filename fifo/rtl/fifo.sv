module fifo #(
	parameter int WIDTH = 8,
	parameter int DEPTH = 16) (
	
	input logic clk,rst,
        input logic [WIDTH-1:0] din,
        input logic wr_en,rd_en,
        output logic full, empty,
        output logic [WIDTH-1:0] dout
        );

localparam int ADDR_WIDTH = $clog2(DEPTH);
localparam int COUNT_WIDTH = $clog2(DEPTH+1);

logic [WIDTH - 1:0] mem [0:DEPTH-1];

logic [ADDR_WIDTH-1:0] read_ptr, write_ptr;
logic [COUNT_WIDTH-1:0] count;

assign full = (count==DEPTH);
assign empty = (count==0);

always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		write_ptr <= '0;
	end
	else begin
		if (wr_en && !full) begin
			mem[write_ptr] <= din;
			write_ptr <= write_ptr + 1;
		end
	end

end

always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
                read_ptr <= '0;
		dout <= '0;
        end
        else begin
                if (rd_en && !empty) begin
                        dout <= mem[read_ptr];
                        read_ptr <= read_ptr + 1;
                end
        end

end

always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
                count <= '0;
        end
        else begin
                case({wr_en && !full, rd_en && !empty})
			2'b10: count <= count + 1;
			2'b01: count <= count - 1;
			default: count <= count;
		endcase
	end

end
endmodule

