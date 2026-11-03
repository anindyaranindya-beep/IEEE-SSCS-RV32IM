module data_memory (
    input wire clk,

    input wire [31:0] address,
    input wire [31:0] write_data,

    input wire write_enable,
    input wire [3:0] byte_enable,

    output wire [31:0] read_word
);

    assign read_word = 0;

endmodule
