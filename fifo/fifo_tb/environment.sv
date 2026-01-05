`include "generator.sv"
`include "driver.sv"
`include "monitor_fifo.sv"


class environment;
    generator gen;
    driver drv;
    monitor_fifo mon;
    scoreboard scb;
    
    int DEPTH;
    int NUM_TRANSACTIONS;
    virtual fifo_inf vif;
    mailbox #(fifo_req) gen2drv_mb;
    mailbox #(fifo_rsp) mon2scb_mb;

    function new(virtual fifo_inf vif,int depth,int num_txn);
        gen2drv_mb = new();
        mon2scb_mb = new();
        this.DEPTH = depth;
        this.NUM_TRANSACTIONS = num_txn;
        scb = new(mon2scb_mb,vif);
        gen = new(gen2drv_mb,scb, DEPTH, NUM_TRANSACTIONS,vif);
        drv = new(vif, gen2drv_mb);
        mon = new(vif, mon2scb_mb);
        
    endfunction

    task execute();
        $display("ENV: starting at %0t", $time);
        fork
            gen.run();
            drv.forward();
            mon.forward();
            scb.run();
        join_none
    
    wait (gen.done == 1);
    #20;
    $display("ENV: done at %0t", $time);
    endtask
endclass
