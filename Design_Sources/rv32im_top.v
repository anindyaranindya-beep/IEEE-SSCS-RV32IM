module rv32im_top (
    input wire clk,
    input wire reset,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_wb_data,
    output wire [4:0] debug_wb_rd,

    output wire debug_wb_valid,
    output wire debug_illegal,
    output wire debug_mem_error
);

    wire [31:0] pc_if;
    wire [31:0] inst_if;

    wire [31:0] if_pc;
    wire [31:0] if_inst;
    wire if_valid;

    wire redirect_ex;
    wire [31:0] target_ex;

    wire load_stall;
    wire div_hold;

    pc u_pc (
        .clk(clk),
        .reset(reset),
        .stall(load_stall | div_hold),
        .redirect(redirect_ex),
        .target(target_ex),
        .current_pc(pc_if)
    );

    instruction_memory u_imem (
        .address(pc_if),
        .instruction(inst_if)
    );

    if_id_reg u_ifid (
        .clk(clk),
        .reset(reset),
        .stall(load_stall | div_hold),
        .flush(redirect_ex),
        .valid_in(1'b1),

        .pc_in(pc_if),
        .inst_in(inst_if),

        .valid_out(if_valid),
        .pc_out(if_pc),
        .inst_out(if_inst)
    );

    assign debug_pc = pc_if;

    wire [6:0] id_opcode;
    wire [6:0] id_f7;
    wire [2:0] id_f3;

    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [4:0] id_rd;

    instruction_decoder u_decoder (
        .instruction(if_inst),

        .opcode(id_opcode),
        .funct3(id_f3),
        .funct7(id_f7),

        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd)
    );

    wire id_rw;
    wire id_mr;
    wire id_mw;
    wire id_as;
    wire id_apc;

    wire id_br;
    wire id_j;
    wire id_jr;
    wire id_m;
    wire id_supported;

    wire [1:0] id_wbsel;
    wire [2:0] id_immsel;

    control_unit u_control (
        .instruction(if_inst),

        .reg_write(id_rw),
        .mem_read(id_mr),
        .mem_write(id_mw),

        .alu_src(id_as),
        .alu_a_pc(id_apc),

        .branch(id_br),
        .jump(id_j),
        .jalr(id_jr),
        .is_m(id_m),

        .wb_sel(id_wbsel),
        .imm_sel(id_immsel),
        .valid_instruction(id_supported)
    );

    wire [31:0] id_imm;
    wire [31:0] id_r1;
    wire [31:0] id_r2;

    immediate_generator u_imm (
        .instruction(if_inst),
        .imm_sel(id_immsel),
        .immediate(id_imm)
    );

    wire [3:0] id_aluop;
    wire id_aluvalid;

    alu_op_decoder u_alu_decoder (
        .instruction(if_inst),
        .operation(id_aluop),
        .valid(id_aluvalid)
    );

    wire [31:0] wb_data;
    wire [4:0] wb_rd;

    wire wb_valid;
    wire wb_rw;

    register_file u_regfile (
        .clk(clk),
        .reset(reset),
        .write_enable(wb_valid && wb_rw),

        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(wb_rd),

        .write_data(wb_data),
        .read_data1(id_r1),
        .read_data2(id_r2)
    );

    wire id_uses_a =
        (id_opcode == 7'h33 ||
         id_opcode == 7'h13 ||
         id_opcode == 7'h03 ||
         id_opcode == 7'h23 ||
         id_opcode == 7'h63 ||
         id_opcode == 7'h67);

    wire id_uses_b =
        (id_opcode == 7'h33 ||
         id_opcode == 7'h23 ||
         id_opcode == 7'h63);

    localparam IDW = 207;

    wire [IDW-1:0] idex_q;

    wire [IDW-1:0] idex_d = {
        if_pc,
        if_pc + 32'd4,

        id_r1,
        id_r2,
        id_imm,

        id_rs1,
        id_rs2,
        id_rd,

        id_f3,
        id_opcode,
        id_f7,

        id_rw,
        id_mr,
        id_mw,

        id_as,
        id_apc,

        id_br,
        id_j,
        id_jr,

        id_wbsel,
        id_m,
        id_aluop
    };

    wire ex_valid;

    id_ex_reg #(
        .W(IDW)
    ) u_idex (
        .clk(clk),
        .reset(reset),
        .stall(div_hold),
        .flush(load_stall | redirect_ex),

        .valid_in(
            if_valid &&
            id_supported &&
            (!(
                (id_opcode == 7'h33 ||
                 id_opcode == 7'h13) &&
                !id_m &&
                !id_aluvalid
            ))
        ),

        .d(idex_d),
        .q(idex_q),
        .valid_out(ex_valid)
    );

    wire [31:0] ex_pc;
    wire [31:0] ex_pc4;

    wire [31:0] ex_r1;
    wire [31:0] ex_r2;
    wire [31:0] ex_imm;

    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [4:0] ex_rd;

    wire [2:0] ex_f3;

    wire [6:0] ex_opcode;
    wire [6:0] ex_f7;

    wire ex_rw;
    wire ex_mr;
    wire ex_mw;

    wire ex_as;
    wire ex_apc;

    wire ex_br;
    wire ex_j;
    wire ex_jr;
    wire ex_m;

    wire [1:0] ex_wbsel;
    wire [3:0] ex_aluop;

    assign {
        ex_pc,
        ex_pc4,

        ex_r1,
        ex_r2,
        ex_imm,

        ex_rs1,
        ex_rs2,
        ex_rd,

        ex_f3,
        ex_opcode,
        ex_f7,

        ex_rw,
        ex_mr,
        ex_mw,

        ex_as,
        ex_apc,

        ex_br,
        ex_j,
        ex_jr,

        ex_wbsel,
        ex_m,
        ex_aluop
    } = idex_q;

    assign debug_illegal = if_valid && !id_supported;

    hazard_detection_unit u_hazard (
        .ex_valid(ex_valid),
        .ex_is_load(ex_mr),

        .ex_rd(ex_rd),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),

        .id_uses_rs1(id_uses_a),
        .id_uses_rs2(id_uses_b),

        .load_use_stall(load_stall)
    );

    localparam EMW = 109;

    wire [EMW-1:0] exmem_q;
    wire mem_valid;

    wire [31:0] mem_pc4;
    wire [31:0] mem_result;
    wire [31:0] mem_store;

    wire [4:0] mem_rd;
    wire [2:0] mem_f3;

    wire mem_rw;
    wire mem_mr;
    wire mem_mw;

    wire [1:0] mem_wbsel;

    assign {
        mem_pc4,
        mem_result,
        mem_store,

        mem_rd,
        mem_f3,

        mem_rw,
        mem_mr,
        mem_mw,
        mem_wbsel
    } = exmem_q;

    wire [1:0] fa;
    wire [1:0] fb;

    forwarding_unit u_forward (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),

        .mem_rd(mem_rd),
        .wb_rd(wb_rd),

        .mem_valid(mem_valid),
        .mem_reg_write(mem_rw),
        .mem_is_load(mem_mr),

        .wb_valid(wb_valid),
        .wb_reg_write(wb_rw),

        .fwd_a(fa),
        .fwd_b(fb)
    );

    wire [31:0] fwd_r1 =
        (fa == 2) ? mem_result :
        (fa == 1) ? wb_data : ex_r1;

    wire [31:0] fwd_r2 =
        (fb == 2) ? mem_result :
        (fb == 1) ? wb_data : ex_r2;

    wire [31:0] alu_a;
    wire [31:0] alu_b;

    wire [31:0] store_ex;
    wire [31:0] alu_result;

    wire alu_zero;

    operand_select u_operand (
        .rs1_value(fwd_r1),
        .rs2_value(fwd_r2),

        .pc(ex_pc),
        .immediate(ex_imm),

        .alu_src(ex_as),
        .alu_a_pc(ex_apc),

        .a(alu_a),
        .b(alu_b),
        .store_data(store_ex)
    );

    alu u_alu (
        .a(alu_a),
        .b(alu_b),
        .operation(ex_aluop),

        .result(alu_result),
        .zero(alu_zero)
    );

    wire br_redirect;
    wire [31:0] br_target;

    branch_jump u_branch (
        .pc(ex_pc),

        .rs1_value(fwd_r1),
        .rs2_value(fwd_r2),

        .immediate(ex_imm),
        .funct3(ex_f3),

        .branch(ex_br),
        .jump(ex_j),
        .jalr(ex_jr),

        .redirect(br_redirect),
        .target_pc(br_target)
    );

    assign redirect_ex =
        ex_valid && !div_hold && br_redirect;

    assign target_ex = br_target;

    wire is_div = ex_m && ex_f3[2];

    wire [31:0] mul_result;
    wire [31:0] div_result;

    wire div_busy;
    wire div_done;

    wire div_start =
        ex_valid && is_div && !div_busy && !div_done;

    divider u_div (
        .clk(clk),
        .reset(reset),
        .start(div_start),

        .a(fwd_r1),
        .b(fwd_r2),
        .funct3(ex_f3),

        .busy(div_busy),
        .done(div_done),
        .result(div_result)
    );

    multiplier u_mul (
        .a(fwd_r1),
        .b(fwd_r2),
        .funct3(ex_f3),
        .result(mul_result)
    );

    assign div_hold =
        ex_valid && is_div && !div_done;

    wire [31:0] ex_result =
        ex_m ? (is_div ? div_result : mul_result) :
               alu_result;

    wire [EMW-1:0] exmem_d = {
        ex_pc4,
        ex_result,
        store_ex,

        ex_rd,
        ex_f3,

        ex_rw,
        ex_mr,
        ex_mw,
        ex_wbsel
    };

    ex_mem_reg #(
        .W(EMW)
    ) u_exmem (
        .clk(clk),
        .reset(reset),

        .stall(1'b0),
        .flush(1'b0),

        .valid_in(ex_valid && !div_hold),

        .d(exmem_d),
        .q(exmem_q),
        .valid_out(mem_valid)
    );

    wire [31:0] mem_word;
    wire [31:0] mem_aligned_store;
    wire [31:0] mem_load;

    wire [3:0] mem_be;
    wire mem_error;

    load_store_unit u_lsu (
        .address(mem_result),
        .store_data(mem_store),
        .mem_word(mem_word),

        .funct3(mem_f3),

        .mem_read(mem_valid && mem_mr),
        .mem_write(mem_valid && mem_mw),

        .aligned_store(mem_aligned_store),
        .load_data(mem_load),

        .byte_enable(mem_be),
        .misaligned(mem_error)
    );

    data_memory u_dmem (
        .clk(clk),

        .address(mem_result),
        .write_data(mem_aligned_store),

        .write_enable(
            mem_valid && mem_mw && !mem_error
        ),

        .byte_enable(mem_be),
        .read_word(mem_word)
    );

    assign debug_mem_error = mem_error;

    localparam MW = 104;

    wire [MW-1:0] memwb_q;

    wire [MW-1:0] memwb_d = {
        mem_pc4,
        mem_result,
        mem_load,

        mem_rd,
        mem_rw,
        mem_wbsel
    };

    mem_wb_reg #(
        .W(MW)
    ) u_memwb (
        .clk(clk),
        .reset(reset),

        .stall(1'b0),
        .flush(1'b0),

        .valid_in(mem_valid && !mem_error),

        .d(memwb_d),
        .q(memwb_q),
        .valid_out(wb_valid)
    );

    wire [31:0] wb_pc4;
    wire [31:0] wb_exresult;
    wire [31:0] wb_load;

    wire [1:0] wb_wbsel;

    assign {
        wb_pc4,
        wb_exresult,
        wb_load,

        wb_rd,
        wb_rw,
        wb_wbsel
    } = memwb_q;

    writeback_mux u_wb_mux (
        .ex_result(wb_exresult),
        .mem_data(wb_load),
        .pc_plus4(wb_pc4),

        .wb_sel(wb_wbsel),
        .wb_data(wb_data)
    );

    assign debug_wb_valid =
        wb_valid && wb_rw && wb_rd != 0;

    assign debug_wb_rd = wb_rd;
    assign debug_wb_data = wb_data;

endmodule
