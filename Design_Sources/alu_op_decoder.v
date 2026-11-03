module alu_op_decoder (
    input wire [31:0] instruction,

    output reg [3:0] operation,
    output reg valid
);

    always @(*) begin
        operation = 0;
        valid = 0;
    end

endmodule
