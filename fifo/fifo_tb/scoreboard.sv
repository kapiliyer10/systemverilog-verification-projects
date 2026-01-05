`include "fifo_rsp.sv"

class scoreboard #(parameter int WIDTH = 8);
    virtual fifo_inf fra_inf;
    mailbox #(fifo_rsp) mon2scb_mb;
    logic [WIDTH-1:0] ref_q[$];
    int num_matches = 0;
    int num_errors  = 0;
    fifo_rsp rsp;
    
    function new(mailbox #(fifo_rsp) mon2scb_mb,virtual fifo_inf fra_inf);
        this.mon2scb_mb = mon2scb_mb;
        this.fra_inf=fra_inf;
        rsp=new();
    endfunction
    
    function void push_expected(logic [WIDTH-1:0] data);
        ref_q.push_back(data);
    endfunction
    
   task run();
    fifo_rsp rsp;
    logic [WIDTH-1:0] exp;

    forever begin
        
       mon2scb_mb.get(rsp);
        
      $display("SCB: get data = %0d rd = %0d wr = %0d at %0t",rsp.data,rsp.rd_en,rsp.wr_en,$time);
        if (rsp.rd_en) begin
            
            if (ref_q.size() == 0) begin
                $error("SCB: Read when queue empty!");
                num_errors++;
            end 
            else begin
                exp = ref_q.pop_front();
                if (exp !== rsp.data)begin
                    $error("SCB: MISMATCH exp=%0d got=%0d at %0t",
                           exp, rsp.data, $time);
           //         $display("Queue = %p",ref_q);
                    num_errors++;
                end
                else begin
                    $display("SCB: PASS exp=%0d got=%0d at %0t",
                              exp, rsp.data, $time);
                    num_matches++;
                end
            end
        end

        else if (rsp.wr_en) begin
            
            ref_q.push_back(rsp.data);
            $display("SCB: PUSH %0d  queue=%p at time %0t", rsp.data, ref_q,$time);
        end
    end
    
endtask

endclass
