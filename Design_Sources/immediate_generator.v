module immediate_generator (
    input wire [31:0] instruction,
    input wire [2:0] imm_sel,

    output reg [31:0] immediate
);

    always @(*) begin
        immediate = 0;
    end

endmodule
