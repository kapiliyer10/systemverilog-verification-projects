`include "fifo_req.sv"
`include "scoreboard.sv"
class generator;
    fifo_req req;
    mailbox #(fifo_req) gen2drv_mb;
    int NUM_TRANSACTIONS;
    int fifo_count=0;
    int DEPTH;
    bit done=0;
    scoreboard scb;
    virtual fifo_inf frb_inf;
    
    function new(mailbox #(fifo_req) gen2drv_mb,scoreboard scb,int depth, int num_txn,virtual fifo_inf frb_inf);
        this.gen2drv_mb = gen2drv_mb;
        this.DEPTH=depth;
        this.NUM_TRANSACTIONS=num_txn;
        this.scb = scb;
        this.frb_inf=frb_inf;
        req=new();
    endfunction
    
    task run();
        wait(frb_inf.rst == 0);
        #2;
        $display("GEN: started at time %0t", $time);
        
        repeat (NUM_TRANSACTIONS) begin
            req.fifo_empty = (fifo_count == 0);
            req.fifo_full  = (fifo_count == DEPTH);
     //       $display("DBG: cnt=%0d empty=%0b full=%0b", fifo_count,
     //       (fifo_count==0), (fifo_count==DEPTH)); 
            assert(req.randomize()) else 
                $fatal("Randomization failed"); 
             
    //         req.randomize() with {wr_en ==1; rd_en == 0; };
            if (req.wr_en) begin
                scb.push_expected(req.data);
                fifo_count++;
                $display("Queue %0p at %0t",scb.ref_q,$time);
            end
            if (req.rd_en) begin
                fifo_count--;
            end
       
            $display("GEN: wr=%0d rd=%0d data=%0d fifo_count=%0d at time %0t",
                      req.wr_en, req.rd_en, req.data, fifo_count,$time);
                      
            gen2drv_mb.put(req.copy());
            #20;
            
        end
       
        done = 1;  
        $display("GEN: DONE at %0t", $time);

    endtask

/* int val[$] = '{8'h11, 8'h22, 8'h33, 8'h44};
task run();
  wait(frb_inf.rst == 0);
  foreach(val[i]) begin
    req.wr_en = 1;
    req.rd_en = 0;
    req.data  = val[i];

    $display("GEN: WRITE %0h at %0t", req.data, $time);
    gen2drv_mb.put(req.copy());

    @(frb_inf.drv_clk);
    scb.push_expected(req.data);  
  end

  // -------- READ 4 VALUES --------
  repeat(4) begin
    req.wr_en = 0;
    req.rd_en = 1;

    $display("GEN: READ at %0t", $time);
    gen2drv_mb.put(req.copy());

    @(frb_inf.drv_clk);
  end

  $display("Test-2 complete");
endtask */

/* task run();
  wait(frb_inf.rst == 0);

  

  // -------- WRITE UNTIL FULL --------
  for (int i = 0; i < DEPTH; i++) begin
    req.wr_en = 1;
    req.rd_en = 0;
    req.data  = i;  

    $display("GEN: WRITE %0d at %0t", req.data, $time);
    gen2drv_mb.put(req.copy());

    @(frb_inf.drv_clk);
    scb.push_expected(req.data);
  end
  // -------Extra Write should not be allowed--------
  req.wr_en = 1;
  req.rd_en = 0;
  req.data  = 8'hAA;

  $display("GEN: EXTRA WRITE attempt at %0t", $time);
  gen2drv_mb.put(req.copy());

  @(frb_inf.drv_clk);

  $display("Test-3 complete");
endtask */

/*task run();
  wait(frb_inf.rst == 0);

  // ---- Test-4: READ until EMPTY ----
  $display("\n--- TEST-4: READ UNTIL EMPTY ---");

  while (fifo_count > 0) begin
    @(frb_inf.drv_clk);
    req.wr_en = 0;
    req.rd_en = 1;

    fifo_count--;
    gen2drv_mb.put(req.copy());

    $display("GEN: READ issued fifo_count=%0d at %0t",
              fifo_count, $time);
  end

  $display("FIFO reached EMPTY at %0t", $time);

  // ---- Extra READ ? should trigger ASSERTION ----
  @(frb_inf.drv_clk);
  req.wr_en = 0;
  req.rd_en = 1;
  gen2drv_mb.put(req.copy());

  $display("GEN: EXTRA READ attempted at %0t", $time);
  $display("Expect: SVA underflow assertion");
endtask */

/* task run();
  wait(frb_inf.rst == 0);

  $display("\n--- TEST-5: FILL, HOLD, BURST READ ---");

  // 1) Fill FIFO completely
  while (fifo_count<DEPTH) begin
    @(frb_inf.drv_clk);
    req.wr_en = 1;
    req.rd_en = 0;
    req.randomize() with { rd_en == 0; }; ;
    scb.push_expected(req.data);
    fifo_count++;
    gen2drv_mb.put(req.copy());
  end

  $display("FIFO reached FULL at %0t", $time);

  // 2) HOLD - no operations for a few cycles
  repeat(3) begin
    @(frb_inf.drv_clk);
    req.wr_en = 0;
    req.rd_en = 0;
    gen2drv_mb.put(req.copy());
    $display("GEN: HOLD cycle at %0t", $time);
  end

  // 3) Burst READ
  while (fifo_count > 0) begin
    @(frb_inf.drv_clk);
    req.wr_en = 0;
    req.rd_en = 1;
    fifo_count--;
    gen2drv_mb.put(req.copy());
  end
  #400;
  done = 1;
  $display("Test-5 complete");
endtask */

endclass
