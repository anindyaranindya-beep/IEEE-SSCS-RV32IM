module writeback_mux (
    input wire [31:0] ex_result,
    input wire [31:0] mem_data,
    input wire [31:0] pc_plus4,

    input wire [1:0] wb_sel,

    output reg [31:0] wb_data
);

    always @(*) begin
        wb_data = 0;
    end

endmodule
