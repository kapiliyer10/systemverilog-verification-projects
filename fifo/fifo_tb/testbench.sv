`timescale 1ns / 1ps
`include "environment.sv"

module testbench;
    parameter int WIDTH = 8;
    parameter int DEPTH = 16;
    parameter NUM_TRANSACTIONS = 40;
    bit clk;
    bit rst; 
    
    fifo_inf #(WIDTH) fif_if(clk);
    environment env;
    
    fifo dut (.din(fif_if.din),.dout(fif_if.dout),.rd_en(fif_if.rd_en),.wr_en(fif_if.wr_en),
              .empty(fif_if.empty),.full(fif_if.full),.rst(fif_if.rst),.clk(clk));
    
    fifo_checker #(.DEPTH(16)) chk (
  .clk     (fif_if.clk),
  .rst     (fif_if.rst),

  .wr_en   (fif_if.wr_en),
  .rd_en   (fif_if.rd_en),
  .full    (fif_if.full),
  .empty   (fif_if.empty),

  .din     (fif_if.din),
  .dout    (fif_if.dout)
);
    initial
        clk = 0;
    
    always #5 clk = ~clk;
    
    initial begin
        fif_if.rst = 1;
        repeat (3) @(posedge clk);
        fif_if.rst = 0;
    end
    initial begin
        env = new(fif_if, DEPTH, NUM_TRANSACTIONS);
        env.execute();
        #20;
        if ((env.scb.num_matches>0)&& (env.scb.num_errors==0)) begin
            $display("TEST PASSED");
            $display("Passed cases = %d",env.scb.num_matches);
            $display("Failed cases = %d",env.scb.num_errors);
            end
        else begin
            $display("TEST FAILED");
            $display("Passed cases = %d",env.scb.num_matches);
            $display("Failed cases = %d",env.scb.num_errors);
        end
        $display("FIFO R/W Coverage = %0.2f %%", env.mon.fifo_cg.get_coverage());
        $display("FIFO State Coverage = %0.2f %%", env.mon.fifo_state_cg.get_coverage());
    //    env.mon.report();
    //    $display(env.gen.DEPTH);
        $finish;
    end
    
endmodule
