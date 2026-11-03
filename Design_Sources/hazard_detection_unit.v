module hazard_detection_unit (
    input wire ex_valid,
    input wire ex_is_load,

    input wire [4:0] ex_rd,
    input wire [4:0] id_rs1,
    input wire [4:0] id_rs2,

    input wire id_uses_rs1,
    input wire id_uses_rs2,

    output wire load_use_stall
);

    assign load_use_stall =
        ex_valid &&
        ex_is_load &&
        (ex_rd != 0) &&
        (
            (id_uses_rs1 && ex_rd == id_rs1) ||
            (id_uses_rs2 && ex_rd == id_rs2)
        );

endmodule
