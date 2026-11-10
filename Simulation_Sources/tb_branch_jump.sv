`timescale 1ns/1ps

module tb_branch_jump;

  reg [31:0] pc,rs1_value,rs2_value,immediate;
  reg [2:0] funct3;
  reg branch,jump,jalr;

  wire redirect;
  wire [31:0] target_pc;
  integer errors=0;

  branch_jump dut(pc,rs1_value,rs2_value,immediate,
    funct3,branch,jump,jalr,redirect,target_pc);

  initial begin
    pc=100;
    rs1_value=5;
    rs2_value=5;
    immediate=12;

    branch=1;
    jump=0;
    jalr=0;

    // BEQ, equal values
    funct3=0;
    #2;

    if(!redirect || target_pc!==112)
      errors=errors+1;

    // BEQ, different values
    rs2_value=6;
    #2;

    if(redirect)
      errors=errors+1;

    // BNE
    funct3=1;
    #2;

    if(!redirect)
      errors=errors+1;

    // signed BLT
    rs1_value=32'hffffffff;
    rs2_value=1;
    funct3=4;
    #2;

    if(!redirect)
      errors=errors+1;

    // unsigned BLTU
    funct3=6;
    #2;

    if(redirect)
      errors=errors+1;

    // signed BGE
    funct3=5;
    #2;

    if(redirect)
      errors=errors+1;

    // unsigned BGEU
    funct3=7;
    #2;

    if(!redirect)
      errors=errors+1;

    // JAL always redirects
    branch=0;
    jump=1;
    #2;

    if(!redirect || target_pc!==112)
      errors=errors+1;

    // JALR clears bit 0 of the target
    jump=0;
    jalr=1;
    rs1_value=100;
    immediate=5;
    #2;

    if(!redirect || target_pc!==104)
      errors=errors+1;

    // normal execution, no redirect
    jalr=0;
    #2;

    if(redirect)
      errors=errors+1;

    if(errors==0)
      $display("PASS branch_jump");
    else
      $display("FAIL branch_jump %0d",errors);

    $finish;
  end

endmodule