module if_id_reg (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,

    input wire [31:0] pc_in,
    input wire [31:0] inst_in,
    input wire valid_in,

    output reg [31:0] pc_out,
    output reg [31:0] inst_out,
    output reg valid_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 0;
            inst_out <= 0;
            valid_out <= 0;
        end

        else if (flush) begin
            pc_out <= 0;
            inst_out <= 0;
            valid_out <= 0;
        end

        else if (!stall) begin
            pc_out <= pc_in;
            inst_out <= inst_in;
            valid_out <= valid_in;
        end
    end

endmodule
