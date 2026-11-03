`timescale 1ns/1ps

module tb_rv32im_top;

    reg clk = 0;
    reg reset = 1;

    wire [31:0] debug_pc;
    wire [31:0] debug_wb_data;
    wire [4:0] debug_wb_rd;

    wire debug_wb_valid;
    wire debug_illegal;
    wire debug_mem_error;

    rv32im_top dut (
        .clk(clk),
        .reset(reset),

        .debug_pc(debug_pc),
        .debug_wb_data(debug_wb_data),
        .debug_wb_rd(debug_wb_rd),

        .debug_wb_valid(debug_wb_valid),
        .debug_illegal(debug_illegal),
        .debug_mem_error(debug_mem_error)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    integer stalls = 0;
    integer div_cycles = 0;
    integer branches = 0;
    integer k;

    task check;
        input [31:0] got;
        input [31:0] want;
        input [255:0] label;

        begin
            if (got !== want) begin
                $display(
                    "FAIL %s got=%h expected=%h",
                    label, got, want
                );

                errors = errors + 1;
            end

            else begin
                $display(
                    "OK %s = %h",
                    label, got
                );
            end
        end
    endtask

    always @(posedge clk) begin
        if (!reset) begin

            if (dut.load_stall)
                stalls = stalls + 1;

            if (dut.div_hold)
                div_cycles = div_cycles + 1;

            if (dut.redirect_ex)
                branches = branches + 1;

            if (debug_wb_valid) begin
                $display(
                    "WB x%0d = %h",
                    debug_wb_rd, debug_wb_data
                );
            end

            if (debug_mem_error) begin
                $display(
                    "MEM ACCESS ERROR pc=%h",
                    debug_pc
                );

                errors = errors + 1;
            end
        end
    end

    initial begin
        #1;

        dut.u_imem.mem[0]  = 32'h01400093;
        dut.u_imem.mem[1]  = 32'h00600113;
        dut.u_imem.mem[2]  = 32'h002081b3;
        dut.u_imem.mem[3]  = 32'h40208233;
        dut.u_imem.mem[4]  = 32'h00302023;
        dut.u_imem.mem[5]  = 32'h00002283;
        dut.u_imem.mem[6]  = 32'h00228333;
        dut.u_imem.mem[7]  = 32'h022083b3;
        dut.u_imem.mem[8]  = 32'h0220c433;
        dut.u_imem.mem[9]  = 32'h0220e4b3;
        dut.u_imem.mem[10] = 32'h00630463;
        dut.u_imem.mem[11] = 32'h06300513;
        dut.u_imem.mem[12] = 32'h00700513;
        dut.u_imem.mem[13] = 32'h002000a3;
        dut.u_imem.mem[14] = 32'h00104583;
        dut.u_imem.mem[15] = 32'h12345637;
        dut.u_imem.mem[16] = 32'h00000697;
        dut.u_imem.mem[17] = 32'h0080076f;
        dut.u_imem.mem[18] = 32'h04d00793;
        dut.u_imem.mem[19] = 32'h00900793;
        dut.u_imem.mem[20] = 32'h05800867;
        dut.u_imem.mem[21] = 32'h06300893;
        dut.u_imem.mem[22] = 32'h00500893;

        repeat (4)
            @(negedge clk);

        reset = 0;

        repeat (220)
            @(negedge clk);

        check(dut.u_regfile.regs[1],  20, "x1 addi");
        check(dut.u_regfile.regs[2],   6, "x2 addi");
        check(dut.u_regfile.regs[3],  26, "x3 add+forward");
        check(dut.u_regfile.regs[4],  14, "x4 sub");
        check(dut.u_regfile.regs[5],  26, "x5 load");
        check(dut.u_regfile.regs[6],  32, "x6 load-use");
        check(dut.u_regfile.regs[7], 120, "x7 mul");
        check(dut.u_regfile.regs[8],   3, "x8 div");
        check(dut.u_regfile.regs[9],   2, "x9 rem");

        check(dut.u_regfile.regs[10], 7, "x10 branch");
        check(dut.u_regfile.regs[11], 6, "x11 lbu");

        check(
            dut.u_regfile.regs[12],
            32'h12345000,
            "x12 lui"
        );

        check(dut.u_regfile.regs[13], 64, "x13 auipc");
        check(dut.u_regfile.regs[14], 72, "x14 jal link");
        check(dut.u_regfile.regs[15],  9, "x15 jal skip");
        check(dut.u_regfile.regs[16], 84, "x16 jalr link");
        check(dut.u_regfile.regs[17],  5, "x17 jalr skip");

        check(
            dut.u_dmem.mem[0],
            32'h0000061a,
            "store/byte lane"
        );

        if (stalls < 1) begin
            $display("FAIL no load stall observed");
            errors = errors + 1;
        end

        if (div_cycles < 60) begin
            $display("FAIL insufficient divider hold cycles");
            errors = errors + 1;
        end

        if (branches < 3) begin
            $display("FAIL no branches/jumps observed");
            errors = errors + 1;
        end

        $display(
            "load_stalls=%0d divider_wait=%0d redirects=%0d",
            stalls, div_cycles, branches
        );

        if (errors == 0) begin
            $display("ALL SMOKE TESTS PASSED");
        end

        else begin
            $display(
                "SMOKE TEST FAILED: %0d errors",
                errors
            );

            $fatal(1, "Smoke test failed");
        end

        $finish;
    end

endmodule

