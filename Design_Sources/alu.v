module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] operation,

    output reg [31:0] result,
    output wire zero
);

    always @(*) begin
        result = 0;
    end

    assign zero = 0;

endmodule
