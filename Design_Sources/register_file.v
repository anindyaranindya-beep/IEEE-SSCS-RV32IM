//SSCS Team 2 Register File
module regfile (
  input wire clk,
  input wire reg_write,
  
  input wire [4:0] rs1,
  input wire [4:0] rs2,
  input wire [4:0] rd,
  
  input wire [31:0] wdata,
  output wire [31:0] rdata1,
  output wire [31:0] rdata2
);
  
  reg[31:0] regs [0:31]; //32x32 registers
  
  //write operation
  always @(posedge clk) begin 
    if (reg_write && rd != 0) begin
      regs[rd] <= wdata;
    end
  end
  
  //read operations
  assign rdata1 = (rs1 == 0) ? 32'b0 : regs[rs1];
  assign rdata2 = (rs2 == 0) ? 32'b0 : regs[rs2];
  
endmodule
