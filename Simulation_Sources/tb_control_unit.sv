`timescale 1ns/1ps

module tb_control_unit;

  reg [31:0] instruction;
  wire reg_write,mem_read,mem_write,alu_src,alu_a_pc;
  wire branch,jump,jalr,is_m,valid_instruction;
  wire [1:0] wb_sel;
  wire [2:0] imm_sel;
  integer errors=0;

  control_unit dut(instruction,reg_write,mem_read,mem_write,
    alu_src,alu_a_pc,branch,jump,jalr,is_m,wb_sel,imm_sel,valid_instruction);

  initial begin
    // ADD instruction
    instruction=32'h002081b3;
    #2;
    if(!reg_write || is_m || mem_write || !valid_instruction)
      errors=errors+1;

    // LW instruction
    instruction=32'h00002283;
    #2;
    if(!mem_read || !reg_write || wb_sel!==1 || !alu_src ||
       imm_sel!==0)
      errors=errors+1;

    // SW instruction
    instruction=32'h00302023;
    #2;
    if(!mem_write || reg_write || imm_sel!==1)
      errors=errors+1;

    // BEQ instruction
    instruction=32'h00630463;
    #2;
    if(!branch || reg_write || imm_sel!==2)
      errors=errors+1;

    // JAL instruction
    instruction=32'h008000ef;
    #2;
    if(!jump || !reg_write || wb_sel!==2 || imm_sel!==4)
      errors=errors+1;

    // JALR instruction
    instruction=32'h000080e7;
    #2;
    if(!jalr || !reg_write || wb_sel!==2)
      errors=errors+1;

    // LUI instruction
    instruction=32'h123451b7;
    #2;
    if(!alu_src || imm_sel!==3 || !reg_write)
      errors=errors+1;

    // AUIPC instruction
    instruction=32'h12345197;
    #2;
    if(!alu_a_pc || !alu_src || !reg_write)
      errors=errors+1;

    // MUL instruction
    instruction=32'h022083b3;
    #2;
    if(!is_m || !reg_write || !valid_instruction)
      errors=errors+1;

    // invalid instruction
    instruction=32'hffffffff;
    #2;
    if(valid_instruction || reg_write || mem_write || jump)
      errors=errors+1;

    if(errors==0)
      $display("PASS control_unit");
    else
      $display("FAIL control_unit %0d",errors);

    $finish;
  end

endmodule
