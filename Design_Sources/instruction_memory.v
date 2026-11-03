module instruction_memory (
    input wire [31:0] address,

    output wire [31:0] instruction
);

    reg [31:0] mem [0:255];

    integer i;
    reg [1023:0] file_name;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000013;

        if ($value$plusargs("program=%s", file_name))
            $readmemh(file_name, mem);
    end

    assign instruction = (address[31:10] == 0)
                       ? mem[address[9:2]]
                       : 32'h00000013;

endmodule
