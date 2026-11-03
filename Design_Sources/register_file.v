module register_file (
    input wire clk,
    input wire reset,
    input wire write_enable,

    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,

    input wire [31:0] write_data,

    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    assign read_data1 = 0;
    assign read_data2 = 0;

endmodule
