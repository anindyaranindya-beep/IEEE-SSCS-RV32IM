`timescale 1ns/1ps

module tb_register_file;

  reg clk=0,reset=1,write_enable=0;
  reg [4:0] rs1=0,rs2=0,rd=0;
  reg [31:0] write_data=0;
  wire [31:0] read_data1,read_data2;
  integer errors=0;

  register_file dut(clk,reset,write_enable,rs1,rs2,rd,
    write_data,read_data1,read_data2);

  always #5 clk=~clk;

  initial begin
    // checking the initial reset values
    #2;
    reset=0;
    rs1=5;
    rs2=0;
    #2;

    if(read_data1!==0 || read_data2!==0)
      errors=errors+1;

    // checking writeback bypass
    rd=5;
    write_data=32'h12345678;
    write_enable=1;
    #2;

    if(read_data1!==32'h12345678)
      errors=errors+1;

    // writing data into register x5
    @(posedge clk);
    #1;
    write_enable=0;

    if(read_data1!==32'h12345678)
      errors=errors+1;

    // checking that x0 cannot be overwritten
    @(negedge clk);
    rd=0;
    write_data=32'hffffffff;
    write_enable=1;

    @(posedge clk);
    #1;
    write_enable=0;
    rs1=0;
    rs2=5;
    #1;

    if(read_data1!==0 || read_data2!==32'h12345678)
      errors=errors+1;

    // checking reset again
    reset=1;
    #1;

    if(read_data2!==0)
      errors=errors+1;

    if(errors==0)
      $display("PASS register_file");
    else
      $display("FAIL register_file %0d",errors);

    $finish;
  end

endmodule
