`timescale 1ns/1ps

module tb_operand_select;

  reg [31:0] rs1_value,rs2_value;
  reg [31:0] pc,immediate;
  reg alu_src,alu_a_pc;

  wire [31:0] a,b,store_data;
  integer errors=0;

  operand_select dut(rs1_value,rs2_value,pc,immediate,
    alu_src,alu_a_pc,a,b,store_data);

  initial begin
    rs1_value=10;
    rs2_value=20;
    pc=100;
    immediate=8;

    // both operands from registers
    alu_src=0;
    alu_a_pc=0;
    #2;

    if(a!==10 || b!==20 || store_data!==20)
      errors=errors+1;

    // using immediate as the second operand
    alu_src=1;
    #2;

    if(a!==10 || b!==8 || store_data!==20)
      errors=errors+1;

    // using PC as the first operand
    alu_a_pc=1;
    #2;

    if(a!==100 || b!==8 || store_data!==20)
      errors=errors+1;

    if(errors==0)
      $display("PASS operand_select");
    else
      $display("FAIL operand_select %0d",errors);

    $finish;
  end

endmodule