module ex_mem_reg #(
    parameter W = 32
)(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire valid_in,

    input wire [W-1:0] d,

    output reg [W-1:0] q,
    output reg valid_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 0;
            valid_out <= 0;
        end

        else if (flush) begin
            q <= 0;
            valid_out <= 0;
        end

        else if (!stall) begin
            q <= d;
            valid_out <= valid_in;
        end
    end

endmodule
