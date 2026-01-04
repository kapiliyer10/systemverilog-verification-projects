`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2025 06:34:27 PM
// Design Name: 
// Module Name: driver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


class driver;
    
    virtual fifo_inf f_inf;
    mailbox #(fifo_req) gen2drv_mb;
    fifo_req req;
 
    function new(virtual fifo_inf f_inf, mailbox #(fifo_req) gen2drv_mb);
        this.gen2drv_mb = gen2drv_mb;
        this.f_inf = f_inf;
    endfunction
    
    task forward(); 
        wait(f_inf.rst == 0);
        
        $display("DRV: started at %0t", $time);
        $display("DRV: reset deasserted at %0t", $time);
        
        forever begin
     //   #2;
        gen2drv_mb.get(req);
        
        $display("DRV: got from generator wr=%0d rd=%0d data=%0d at %0t",
                     req.wr_en, req.rd_en, req.data, $time);
        @(f_inf.drv_clk); 
        f_inf.drv_clk.wr_en <= req.wr_en;
        f_inf.drv_clk.rd_en <= req.rd_en;
        f_inf.drv_clk.din <= req.data;
        
       $display("DRV: drove wr=%0d rd=%0d data=%0d at %0t",
                     req.wr_en, req.rd_en, req.data, $time);
                         
        @(f_inf.drv_clk); 
        
        f_inf.drv_clk.wr_en <= 0;
        f_inf.drv_clk.rd_en <= 0;
        f_inf.drv_clk.din <= 0; 
        
      /*  $display("DRV: drove wr=%0d rd=%0d data=%0d at %0t",
                     req.wr_en, req.rd_en, req.data, $time);*/
        end
    endtask
endclass
