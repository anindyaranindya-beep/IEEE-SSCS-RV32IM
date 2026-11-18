`timescale 1ns/1ps

module tb_alu;

  reg [31:0] a,b;
  reg [3:0] operation;
  wire [31:0] result;
  wire zero;
  integer errors=0;

  alu dut(a,b,operation,result,zero);

  task check;
    input [31:0] x,y;
    input [3:0] op;
    input [31:0] want;

    begin
      a=x;
      b=y;
      operation=op;
      #2;

      if(result!==want) begin
        $display("FAIL alu op=%0d result=%h expected=%h",
          op,result,want);
        errors=errors+1;
      end
    end
  endtask

  initial begin
    // checking the ALU arithmetic operations
    check(20,6,0,26);
    check(20,6,1,14);

    // checking AND, OR, XOR and PASS B
    check(12,10,2,8);
    check(12,10,3,14);
    check(12,10,4,6);
    check(99,12,5,12);

    // checking shift operations
    check(3,2,6,12);
    check(32'h80000000,1,7,32'h40000000);
    check(32'hfffffff8,1,8,32'hfffffffc);

    // signed and unsigned comparisons
    check(32'hffffffff,1,9,1);
    check(32'hffffffff,1,10,0);

    // checking the zero flag
    check(5,5,1,0);

    if(zero!==1)
      errors=errors+1;

    if(errors==0)
      $display("PASS alu");
    else
      $display("FAIL alu %0d",errors);

    $finish;
  end

endmodule
