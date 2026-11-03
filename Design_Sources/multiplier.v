module multiplier (
    input wire [31:0] a,
    input wire [31:0] b,

    input wire [2:0] funct3,

    output reg [31:0] result
);

    wire signed [63:0] ss =
        $signed(a) * $signed(b);

    wire [63:0] uu =
        {32'b0, a} * {32'b0, b};

    wire signed [64:0] su =
        $signed({a[31], a}) * $signed({1'b0, b});

    always @(*) begin
        case (funct3)
            3'd0: result = ss[31:0];
            3'd1: result = ss[63:32];
            3'd2: result = su[63:32];
            3'd3: result = uu[63:32];

            default: result = 0;
        endcase
    end

endmodule
