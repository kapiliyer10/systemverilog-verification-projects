`timescale 1ns/1ps

module tb_fifo;
parameter int WIDTH = 8;
parameter int DEPTH = 16;

logic clk,rst,wr_en,rd_en;
logic [WIDTH-1:0] din,dout;
logic full,empty;

// =======================
// Functional Coverage Counters
// =======================

integer cov_write_only;
integer cov_read_only;
integer cov_simul_rw;
integer cov_empty_seen;
integer cov_full_seen;
integer cov_empty_to_nonempty;
integer cov_full_to_nonfull;

logic prev_empty;
logic prev_full;

initial begin
    cov_write_only        = 0;
    cov_read_only         = 0;
    cov_simul_rw           = 0;
    cov_empty_seen         = 0;
    cov_full_seen          = 0;
    cov_empty_to_nonempty  = 0;
    cov_full_to_nonfull    = 0;

    prev_empty = 1;
    prev_full  = 0;
end

fifo #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH))
	
	dut(.clk(clk),.rst(rst),.wr_en(wr_en),.rd_en(rd_en),
	.din(din),.dout(dout),.full(full),.empty(empty)
	);

initial clk=0;
always #10 clk = ~clk;

task reset_apply(); begin
		rst=1;
		wr_en = 0;
		rd_en = 0;
		din = '0;
		repeat(2)@ (posedge clk);
		rst = 0;	
	end
endtask

task write_fifo(input logic [WIDTH-1:0] data); begin
	@(posedge clk);
	if (!full) begin
		din = data;
		wr_en = 1;
		mem[write_idx] = data;
		write_idx++;
	end
	@(posedge clk);
		wr_en = 0;
	end
endtask

task read_fifo(); begin
	@(posedge clk);
	if(!empty)
		rd_en = 1;
	@(posedge clk);
	rd_en = 0;
end
endtask
	
int read_idx=0, write_idx=0;
logic [WIDTH-1:0] mem [0:DEPTH-1];

logic rd_en_d;
always_ff @(posedge clk) begin
    rd_en_d <= rd_en && !empty;
end

always @(posedge clk) begin
	if(!rst && rd_en_d && !empty) begin
		if(dout!=mem[read_idx]) begin
			$display("ERROR: Expected %d, Got %d at time %t", mem[read_idx],dout,$time());
			$stop;
		end
		read_idx++;
	end
end

always @(posedge clk) begin
    if (!rst) begin
        // Count overflow check
        if (dut.count > DEPTH) begin
            $error("ASSERTION FAILED: count overflow (count=%0d)", dut.count);
            $stop;
        end

        // Count underflow check
        if (dut.count < 0) begin
            $error("ASSERTION FAILED: count underflow (count=%0d)", dut.count);
            $stop;
        end
    end
end

always @(posedge clk) begin
    if (!rst) begin
        // No write when FIFO is full
        if (wr_en && full) begin
            $error("ASSERTION FAILED: Write when FIFO is full at time %0t", $time);
            $stop;
        end

        // No read when FIFO is empty
        if (rd_en && empty) begin
            $error("ASSERTION FAILED: Read when FIFO is empty at time %0t", $time);
            $stop;
        end
    end
end


initial begin
	$dumpfile("fifo.vcd");
	$dumpvars(0,tb_fifo);

	reset_apply();
	for (int i=0;i<5;i++) begin
		
		write_fifo(i + 8'd10);
	//	mem[write_idx] = i+ 8'd10;
	//        write_idx++;
	end

//	for (int j=0;j<5;j++) begin
//		read_fifo();
//	end
        report_coverage();
	#200;
	$display("All Tests Passed");
	$finish;
end

always @(posedge clk) begin
    if (!rst) begin
        // Write only
        if (wr_en && !rd_en &&!full)
            cov_write_only++;

        // Read only
        if (rd_en && !wr_en && !empty)
            cov_read_only++;

        // Simultaneous read & write
        if (wr_en && rd_en)
            cov_simul_rw++;

        // Empty / full observation
        if (empty)
            cov_empty_seen++;

        if (full)
            cov_full_seen++;

        // Transitions
        if (prev_empty && !empty)
            cov_empty_to_nonempty++;

        if (prev_full && !full)
            cov_full_to_nonfull++;

        prev_empty <= empty;
        prev_full  <= full;
    end
end

task report_coverage;
    begin
        $display("\n========== FIFO FUNCTIONAL COVERAGE ==========");
        $display("Write only operations      : %0d", cov_write_only);
        $display("Read only operations       : %0d", cov_read_only);
        $display("Simultaneous read/write    : %0d", cov_simul_rw);
        $display("Empty observed cycles      : %0d", cov_empty_seen);
        $display("Full observed cycles       : %0d", cov_full_seen);
        $display("Empty -> Non-empty         : %0d", cov_empty_to_nonempty);
        $display("Full -> Non-full           : %0d", cov_full_to_nonfull);
        $display("==============================================\n");
    end
endtask

endmodule








	

	

