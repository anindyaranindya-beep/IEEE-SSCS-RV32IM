`timescale 1ns/1ps

module tb_instruction_decoder;

  reg [31:0] instruction;
  wire [6:0] opcode,funct7;
  wire [2:0] funct3;
  wire [4:0] rs1,rs2,rd;
  integer errors=0;

  instruction_decoder dut(instruction,opcode,funct3,funct7,rs1,rs2,rd);

  initial begin
    // checking an ADD instruction
    instruction={7'b0000000,5'd2,5'd1,3'b000,5'd3,7'b0110011};
    #2;

    if(opcode!==7'h33 || rs1!==1 || rs2!==2 || rd!==3 ||
       funct3!==0 || funct7!==0)
      errors=errors+1;

    // checking a SUB instruction
    instruction={7'b0100000,5'd8,5'd7,3'b000,5'd9,7'b0110011};
    #2;

    if(opcode!==7'h33 || rs1!==7 || rs2!==8 || rd!==9 ||
       funct7!==7'h20)
      errors=errors+1;

    if(errors==0)
      $display("PASS instruction_decoder");
    else
      $display("FAIL instruction_decoder %0d",errors);

    $finish;
  end

endmodule
