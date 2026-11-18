`timescale 1ns/1ps

module tb_writeback_mux;

  reg [31:0] ex_result,mem_data,pc_plus4;
  reg [1:0] wb_sel;
  wire [31:0] wb_data;
  integer errors=0;

  writeback_mux dut(ex_result,mem_data,pc_plus4,wb_sel,wb_data);

  initial begin
    ex_result=20;
    mem_data=30;
    pc_plus4=104;

    // writeback from ALU
    wb_sel=0;
    #2;

    if(wb_data!==20)
      errors=errors+1;

    // writeback from memory
    wb_sel=1;
    #2;

    if(wb_data!==30)
      errors=errors+1;

    // writeback PC+4 for jumps
    wb_sel=2;
    #2;

    if(wb_data!==104)
      errors=errors+1;

    // default selection
    wb_sel=3;
    #2;

    if(wb_data!==0)
      errors=errors+1;

    if(errors==0)
      $display("PASS writeback_mux");
    else
      $display("FAIL writeback_mux %0d",errors);

    $finish;
  end

endmodule
