module forwarding_unit (
    input wire [4:0] ex_rs1,
    input wire [4:0] ex_rs2,
    input wire [4:0] mem_rd,
    input wire [4:0] wb_rd,

    input wire mem_valid,
    input wire mem_reg_write,
    input wire mem_is_load,

    input wire wb_valid,
    input wire wb_reg_write,

    output reg [1:0] fwd_a,
    output reg [1:0] fwd_b
);

    always @(*) begin
        fwd_a = 0;
        fwd_b = 0;

        if (mem_valid && mem_reg_write &&
            !mem_is_load && mem_rd != 0 &&
            mem_rd == ex_rs1)
            fwd_a = 2;

        else if (wb_valid && wb_reg_write &&
                 wb_rd != 0 && wb_rd == ex_rs1)
            fwd_a = 1;

        if (mem_valid && mem_reg_write &&
            !mem_is_load && mem_rd != 0 &&
            mem_rd == ex_rs2)
            fwd_b = 2;

        else if (wb_valid && wb_reg_write &&
                 wb_rd != 0 && wb_rd == ex_rs2)
            fwd_b = 1;
    end

endmodule
