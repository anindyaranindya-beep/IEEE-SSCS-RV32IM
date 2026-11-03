module branch_jump (
    input wire [31:0] pc,
    input wire [31:0] rs1_value,
    input wire [31:0] rs2_value,
    input wire [31:0] immediate,

    input wire [2:0] funct3,

    input wire branch,
    input wire jump,
    input wire jalr,

    output reg redirect,
    output reg [31:0] target_pc
);

    always @(*) begin
        redirect = 0;
        target_pc = 0;
    end

endmodule

