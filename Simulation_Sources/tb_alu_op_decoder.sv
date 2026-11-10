`timescale 1ns/1ps

module tb_alu_op_decoder;

  reg [31:0] instruction;
  wire [3:0] operation;
  wire valid;
  integer errors=0;

  alu_op_decoder dut(instruction,operation,valid);

  task check;
    input [31:0] inst;
    input [3:0] want;

    begin
      instruction=inst;
      #2;

      if(operation!==want || !valid) begin
        $display("FAIL alu_op_decoder inst=%h op=%d",
          inst,operation);
        errors=errors+1;
      end
    end
  endtask

  initial begin
    // arithmetic operations
    check(32'h002081b3,0);  // ADD
    check(32'h402081b3,1);  // SUB

    // bitwise operations
    check(32'h0020f1b3,2);  // AND
    check(32'h0020e1b3,3);  // OR
    check(32'h0020c1b3,4);  // XOR

    // LUI, pass immediate
    check(32'h123451b7,5);

    // shift operations
    check(32'h002091b3,6);  // SLL
    check(32'h0020d1b3,7);  // SRL
    check(32'h4020d1b3,8);  // SRA

    // comparison operations
    check(32'h0020a1b3,9);  // SLT
    check(32'h0020b1b3,10); // SLTU

    // immediate instructions
    check(32'h00508193,0);  // ADDI
    check(32'h4030d193,8);  // SRAI

    // MUL uses the separate multiplier
    check(32'h022081b3,0);

    // unsupported R-type encoding
    instruction=32'h7e2091b3;
    #2;

    if(valid!==0)
      errors=errors+1;

    if(errors==0)
      $display("PASS alu_op_decoder");
    else
      $display("FAIL alu_op_decoder %0d",errors);

    $finish;
  end

endmodule