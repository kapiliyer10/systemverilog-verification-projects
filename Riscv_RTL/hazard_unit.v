module hazard_unit (
    input  wire id_ex_memread,
    input  wire [4:0] id_ex_rd,
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    output wire stall,
    output wire pc_write      // PC enable (if stall -> 0)
);
    // load-use hazard: if ID/EX is load and destination matches IF/ID rs1/rs2 then stall
    assign stall = id_ex_memread && ((id_ex_rd != 0) && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)));
    assign pc_write = ~stall;
endmodule
