interface fifo_inf #(parameter int WIDTH = 8, parameter int DEPTH = 16) (input clk);
    logic rd_en,wr_en,full,empty,rst;
    logic [WIDTH-1:0] din,dout;

    clocking drv_clk @(posedge clk);
        default input #2 output #2;
        output wr_en,rd_en,din;
        input dout,full,empty;
    endclocking
    
    clocking mon_clk @(posedge clk);
        default input #0 output #0;
        input wr_en,rd_en,dout,full,empty,din;
    endclocking
    
    assign wr_en = (rst) ? 0 : wr_en;
    assign rd_en = (rst) ? 0 : rd_en;
    modport DRV(clocking drv_clk,input clk);
    modport MON(clocking mon_clk,input clk);
   // always@(*) $display("wr_en=%0d rd_en=%0d at %t",drv_clk.wr_en,drv_clk.rd_en,$time);
endinterface
