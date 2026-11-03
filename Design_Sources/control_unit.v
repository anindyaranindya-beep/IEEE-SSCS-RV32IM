module control_unit (
    input wire [31:0] instruction,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,

    output reg alu_src,
    output reg alu_a_pc,

    output reg branch,
    output reg jump,
    output reg jalr,
    output reg is_m,

    output reg [1:0] wb_sel,
    output reg [2:0] imm_sel,

    output reg valid_instruction
);

    always @(*) begin
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;

        alu_src = 0;
        alu_a_pc = 0;

        branch = 0;
        jump = 0;
        jalr = 0;
        is_m = 0;

        wb_sel = 0;
        imm_sel = 0;
        valid_instruction = 0;
    end

endmodule
