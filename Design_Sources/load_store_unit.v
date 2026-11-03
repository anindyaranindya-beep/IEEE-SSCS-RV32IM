module load_store_unit (
    input wire [31:0] address,
    input wire [31:0] store_data,
    input wire [31:0] mem_word,

    input wire [2:0] funct3,

    input wire mem_read,
    input wire mem_write,

    output reg [31:0] aligned_store,
    output reg [31:0] load_data,

    output reg [3:0] byte_enable,
    output reg misaligned
);

    always @(*) begin
        aligned_store = 0;
        load_data = 0;
        byte_enable = 0;
        misaligned = 0;
    end

endmodule
