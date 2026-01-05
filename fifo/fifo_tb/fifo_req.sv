class fifo_req #(parameter WIDTH = 8,parameter DEPTH=16);

    rand bit wr_en;
    rand bit rd_en;
    rand logic [WIDTH-1:0] data;
 
      
    bit fifo_empty;
    bit fifo_full;

constraint state_rules {

  if (fifo_empty) {
    wr_en == 1 && rd_en == 0;
  }

  else if (fifo_full) {
    wr_en == 0 && rd_en == 1;
  }
}
    function fifo_req copy();
    copy = new();
    copy.wr_en=this.wr_en;
    copy.rd_en=this.rd_en;
    copy.data=this.data;
    endfunction
endclass
