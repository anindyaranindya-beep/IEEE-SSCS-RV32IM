module instruction_decoder (
    input wire [31:0] instruction,

    output wire [6:0] opcode,
    output wire [2:0] funct3,
    output wire [6:0] funct7,

    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd
);

    assign opcode = 0;
    assign funct3 = 0;
    assign funct7 = 0;

    assign rs1 = 0;
    assign rs2 = 0;
    assign rd = 0;

endmodule
