class monitor_fifo;
    virtual fifo_inf fr_inf;
    mailbox #(fifo_rsp) mon2scb_mb;
    fifo_rsp rsp;
    int fifo_depth_cnt = 0;
    

    covergroup fifo_cg @(fr_inf.mon_clk);
        coverpoint {fr_inf.mon_clk.wr_en, fr_inf.mon_clk.rd_en} {
            bins write_only = {2'b10};
            bins read_only = {2'b01};
            bins idle = {2'b00};
            bins both = {2'b11};
            }
    endgroup
    
    covergroup fifo_state_cg@(fr_inf.mon_clk);
        cp_count : coverpoint fifo_depth_cnt {
        bins empty_bin = {0};
        bins mid_bin   = {[1:fr_inf.DEPTH-1]};
        bins full_bin  = {fr_inf.DEPTH};
        }
        
        cp_flags : coverpoint{fr_inf.mon_clk.full,fr_inf.mon_clk.empty} {
        bins EMPTY = {2'b01};
        bins FULL  = {2'b10};
        bins VALID = {2'b00};
    }
    cross cp_count, cp_flags;
    endgroup
    
    function new(virtual fifo_inf fr_inf, mailbox #(fifo_rsp) mon2scb_mb);
        this.mon2scb_mb = mon2scb_mb;
        this.fr_inf = fr_inf;
        fifo_cg = new();
        fifo_state_cg = new();
    endfunction
    
    task forward();
        rsp = new();
        wait(fr_inf.rst == 0); 
        forever begin
          
            @(fr_inf.mon_clk);
            fifo_cg.sample();
            fifo_state_cg.sample();
        //    fifo_cg.print();
            rsp.rd_en = fr_inf.mon_clk.rd_en;
            rsp.wr_en = fr_inf.mon_clk.wr_en;
          //  rsp.data  = fr_inf.mon_clk.dout;
            $display("MON: READ data=%0d rd_en = %0d wr_en = %0d at %0t", rsp.data,rsp.rd_en,rsp.wr_en, $time);
            if (fr_inf.mon_clk.rd_en && !fr_inf.mon_clk.empty) begin
                @(fr_inf.mon_clk);
                rsp.data  = fr_inf.mon_clk.dout;
                fifo_depth_cnt++;
                mon2scb_mb.put(rsp);
            end
            if (fr_inf.mon_clk.rd_en && !fr_inf.mon_clk.empty)
                fifo_depth_cnt--;
         //       $display("MON: READ data=%0d rd_en = %0d wr_en = %0d at %0t", rsp.data,rsp.rd_en,rsp.wr_en, $time);
           
        end
    endtask
    
        
    
endclass
