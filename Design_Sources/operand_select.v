module operand_select (
    input wire [31:0] rs1_value,
    input wire [31:0] rs2_value,

    input wire [31:0] pc,
    input wire [31:0] immediate,

    input wire alu_src,
    input wire alu_a_pc,

    output wire [31:0] a,
    output wire [31:0] b,
    output wire [31:0] store_data
);

    assign a = 0;
    assign b = 0;
    assign store_data = 0;

endmodule
