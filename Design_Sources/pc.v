module pc (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire redirect,

    input wire [31:0] target,

    output reg [31:0] current_pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_pc <= 0;

        else if (redirect)
            current_pc <= target;

        else if (!stall)
            current_pc <= current_pc + 4;
    end

endmodule
