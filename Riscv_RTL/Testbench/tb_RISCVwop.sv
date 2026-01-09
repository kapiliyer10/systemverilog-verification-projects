`timescale 1ns / 1ps

module tb_RISCVwop;

  
  logic clk;
  logic rst;
  int g=0;
  
  //RISCVwop dut (
  RISCV_wp dut (
    .clk   (clk),
    .rst (rst)
  );

  // Clock generator (10ns period)
  always #5 clk = ~clk;

  // Expected register file
  logic [31:0] exp_regs [0:31];

  
  task init_expected;
    integer i;
    begin
      for (i = 0; i < 32; i++) exp_regs[i] = 32'b0;
      // Example program: 
      exp_regs[1] = 32'h5;
      exp_regs[2] = 32'ha;
      exp_regs[3] = 32'hf;
    end
  endtask

  
  task check_results;
    integer i;
    begin
      $display("----- Checking Register File -----");
      for (i = 0; i < 32; i++) begin
        if (dut.regfile_u.regs[i] !== exp_regs[i]) begin
        //if (dut.regmem.regs[i] !== exp_regs[i]) begin
          $error("Mismatch at x%0d: Got %h, Expected %h", 
                 i, dut.regfile_u.regs[i], exp_regs[i]);
                 //i, dut.regmem.regs[i], exp_regs[i]);
        end
      end
      $display("All register checks complete.");
    end
  endtask

  
  assert property (@(posedge clk) disable iff (rst)
      dut.regfile_u.regs[0] == 0)
      //dut.regmem.regs[0] == 0)
    else $error("x0 register corrupted!");

  
  assert property ( @(posedge clk) disable iff (rst)
      dut.pc[1:0] == 2'b00)
    else $error("PC not word aligned!");

  
  initial begin
    
    $dumpfile("riscv.vcd");
    $dumpvars(0, tb_RISCVwop);

    
    clk   = 0;
    rst = 1;

    init_expected();
   // $display("x1 = %h x2 = %h x3 = %h",dut.regmem.regs[1],dut.regmem.regs[2],dut.regmem.regs[3]);
   // $display("aluresult = %d aluin1 = %d aluin2 = %d",dut.alu_res,dut.rd1,dut.aluin2);
    
    
  //  $display("array = %p",dut.regmem.regs);  
    
   // repeat(3) @(posedge clk)
   // begin
  
  //   $display("array = %p",dut.regmem.regs);
    // end
    #16;
    rst = 0;
    
  //  $display("x1 = %h x2 = %h x3 = %h",dut.regmem.regs[1],dut.regmem.regs[2],dut.regmem.regs[3]);
  //  $display("aluresult = %d aluin1 = %d aluin2 = %d muxin2 = %d",
  //  dut.alu_res,dut.rd1,dut.aluin2,dut.rd2);
    
    
  //  repeat(15) @(posedge clk)begin
   
   // $display("x1 = %h x2 = %h x3 = %h",dut.regmem.regs[1],dut.regmem.regs[2],dut.regmem.regs[3]);
   // $display("aluresult = %d aluin1 = %d aluin2 = %d muxin2 = %d"
   // ,dut.alu_res,dut.rd1,dut.aluin2,dut.rd2);
    
   
   
   
    // Check final register results
    #250;
    check_results();

    $display("TEST COMPLETED.");
    
    $finish;
  end
 /* always@(posedge clk)begin
   $display("reset = %d",dut.rst);
   $display("jalr = %d",dut.jalr);
   $display("rd3 = %d",dut.rd3);
   $display("pc = %d",dut.pc);
   end */
endmodule
