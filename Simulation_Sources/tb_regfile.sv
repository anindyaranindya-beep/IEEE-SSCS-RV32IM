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

→ Testbench code:
module tb_regfile;
  reg clk;
  reg reg_write;
  
  reg[4:0] rs1;
  reg[4:0] rs2;
  reg[4:0] rd;
  
  reg[31:0] wdata;
  
  wire[31:0] rdata1;
  wire[31:0] rdata2;
  
  //connect tb to regfile
  regfile uut (
    .clk(clk),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wdata(wdata),
    .rdata1(rdata1),
    .rdata2(rdata2)
  );
  
  always #5 clk = ~clk; //generate clock
  
  initial begin
    clk = 0;
    reg_write = 0;
    rs1 = 0;
    rs2 = 0;
    rd = 0;
    wdata = 0;
    
    $display("RegFile Test:");
    
    //Test 1 (Write 100 into reg x1)
    @(negedge clk);
    reg_write = 1;
    rd = 1;
    wdata = 10;
    @(posedge clk);
    #1;
    
    //Test 2 (Write 200 into reg x5)
    @(negedge clk);
    rd = 5;
    wdata = 20;
    @(posedge clk);
    #1;
    reg_write = 0;
    
    //Test 3 (Read x1 and x5)
    rs1 = 1;
    rs2 = 5;
    #1;
    $display("x1 = %d", rdata1);
    $display("x5 = %d", rdata2);
    
    //Test 4 (Check x0 = 0)
    rs1 = 0;
    #1;
    $display("x0 = %d", rdata1);
    
    //Test 5 (Try to write on x0)
    @(negedge clk);
    reg_write = 1;
    rd = 0;
    wdata = 451;
    @(posedge clk);
    #1;
    reg_write = 0;
    rs1 = 0;
    #1;
    $display("x0 write attempt = %d", rdata1);
    
    $display("Regfile Test Done");
    
    $finish;
    
  end
endmodule
