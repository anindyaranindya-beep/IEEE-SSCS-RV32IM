`timescale 1ns/1ps

module tb_immediate_generator;

  reg [31:0] instruction;
  reg [2:0] imm_sel;
  wire [31:0] immediate;
  integer errors=0;

  immediate_generator dut(instruction,imm_sel,immediate);

  initial begin
    // I-type, negative immediate
    instruction=32'hffc00093;
    imm_sel=0;
    #2;

    if(immediate!==32'hfffffffc)
      errors=errors+1;

    // S-type immediate
    instruction=32'h00302423;
    imm_sel=1;
    #2;

    if(immediate!==8)
      errors=errors+1;

    // B-type immediate
    instruction=32'h00630463;
    imm_sel=2;
    #2;

    if(immediate!==8)
      errors=errors+1;

    // U-type immediate
    instruction=32'h123451b7;
    imm_sel=3;
    #2;

    if(immediate!==32'h12345000)
      errors=errors+1;

    // J-type immediate
    instruction=32'h008000ef;
    imm_sel=4;
    #2;

    if(immediate!==8)
      errors=errors+1;

    if(errors==0)
      $display("PASS immediate_generator");
    else
      $display("FAIL immediate_generator %0d",errors);

    $finish;
  end

endmodule