module tb_immgen;
  reg [31:0] instr;
  reg [2:0] imm_sel;
  wire [31:0] imm;

immgen uut (
  .instr(instr),
  .imm_sel(imm_sel),
  .imm(imm)
);

initial begin
  
  $monitor("imm_sel = %b, instr = %h, imm = %h",imm_sel, instr, imm);
  
  //Immediate (I) (addi x5, x6, 5)
  imm_sel = 0; instr = 32'h00530293;
  #1;
  //Store(S) (sw x5,8(x6))
  imm_sel = 1; instr = 32'h00532423;
  #1;
  
  //Branch(B) (beq x5,x6,+8)
  imm_sel = 2; instr = 32'h00628463;
  #1;
  
  //Immediate(U) (lui x5, 0x12345)
  imm_sel = 3; instr = 32'h123452b7;
  #1;
  
  //Jump(J) (jal x1,+8)
  imm_sel = 4; instr = 32'h008000ef;
  #1;
  
  $finish;
  
end
endmodule
