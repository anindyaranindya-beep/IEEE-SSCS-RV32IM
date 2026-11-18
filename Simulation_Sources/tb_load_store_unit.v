// =============================================================================
// Testbench: tb_load_store_unit
// Project:   IEEE SSCS RV32IM CPU - Team 6 Load/Store & Data Memory
// Authors:   Omar & Ramin
//
// Tests load_store_unit + data_memory, wired exactly as in rv32im_top.v:
//   - data_memory.write_enable = mem_write && !misaligned
//   - data_memory.byte_enable  = load_store_unit.byte_enable
//   - load_store_unit.mem_word = data_memory.read_word
//
// Part A replays the four memory instructions from tb_rv32im_top.v with the
// same addresses, data and expected results:
//     sw  x3, 0(x0)   x3 = 26      -> mem[0] = 0x0000001A
//     lw  x5, 0(x0)                -> x5 = 26           ("x5 load")
//     sb  x2, 1(x0)   x2 = 6       -> mem[0] = 0x0000061A ("store/byte lane")
//     lbu x11, 1(x0)               -> x11 = 6           ("x11 lbu")
//
// Parts B-F cover every load/store type, byte lanes, sign extension,
// misaligned accesses, and the 1 KiB address range.
//
// Output lines use the same "OK label = value" / "FAIL" style as
// tb_rv32im_top.v.
//
// Run (Icarus Verilog):
//   iverilog -g2012 -o tb_load_store_unit load_store_unit.v data_memory.v tb_load_store_unit.v
//   vvp tb_load_store_unit
// Run (Vivado): add the two design files as Design Sources and this file as a
//   Simulation Source, set tb_load_store_unit as the simulation top, run Behavioral
//   Simulation.
// =============================================================================

`timescale 1ns/1ps

module tb_load_store_unit;

    localparam [2:0] F3_B  = 3'b000;
    localparam [2:0] F3_H  = 3'b001;
    localparam [2:0] F3_W  = 3'b010;
    localparam [2:0] F3_BU = 3'b100;
    localparam [2:0] F3_HU = 3'b101;

    reg clk = 0;
    always #5 clk = ~clk;

    // Signals driven like the EX/MEM pipeline register would drive them.
    reg  [31:0] address    = 0;
    reg  [31:0] store_data = 0;
    reg  [2:0]  funct3     = 0;
    reg         mem_read   = 0;
    reg         mem_write  = 0;

    wire [31:0] mem_word;
    wire [31:0] aligned_store;
    wire [31:0] load_data;
    wire [3:0]  byte_enable;
    wire        misaligned;

    // Same connections as rv32im_top.v
    load_store_unit u_lsu (
        .address(address),
        .store_data(store_data),
        .mem_word(mem_word),
        .funct3(funct3),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .aligned_store(aligned_store),
        .load_data(load_data),
        .byte_enable(byte_enable),
        .misaligned(misaligned)
    );

    data_memory u_dmem (
        .clk(clk),
        .address(address),
        .write_data(aligned_store),
        .write_enable(mem_write && !misaligned),
        .byte_enable(byte_enable),
        .read_word(mem_word)
    );

    integer errors = 0;
    integer checks = 0;

    task check;
        input [31:0] got;
        input [31:0] want;
        input [255:0] label;
        begin
            checks = checks + 1;
            if (got !== want) begin
                $display("FAIL %0s got=%h expected=%h", label, got, want);
                errors = errors + 1;
            end else begin
                $display("OK %0s = %h", label, got);
            end
        end
    endtask

    // One store: inputs change on the falling edge, write on the rising edge.
    task do_store;
        input [2:0]  f3;
        input [31:0] a;
        input [31:0] d;
        begin
            @(negedge clk);
            funct3 = f3; address = a; store_data = d;
            mem_write = 1; mem_read = 0;
            @(negedge clk);
            mem_write = 0;
        end
    endtask

    // One load: combinational read, result sampled before the next edge.
    task do_load;
        input  [2:0]  f3;
        input  [31:0] a;
        output [31:0] result;
        begin
            @(negedge clk);
            funct3 = f3; address = a; mem_read = 1; mem_write = 0;
            #1;
            result = load_data;
            @(negedge clk);
            mem_read = 0;
        end
    endtask

    reg [31:0] r;
    reg [31:0] saved;

    initial begin
        $dumpfile("tb_load_store_unit.vcd");
        $dumpvars(0, tb_load_store_unit);

        repeat (2) @(negedge clk);

        // -------------------------------------------------------------------
        $display("--- A. Memory instructions from tb_rv32im_top.v ---");
        do_store(F3_W, 32'd0, 32'd26);                 // sw  x3, 0(x0)
        check(u_dmem.mem[0], 32'h0000001a, "sw x3,0(x0) word");
        do_load (F3_W, 32'd0, r);                      // lw  x5, 0(x0)
        check(r, 32'd26, "x5 load");
        do_store(F3_B, 32'd1, 32'd6);                  // sb  x2, 1(x0)
        do_load (F3_BU, 32'd1, r);                     // lbu x11, 1(x0)
        check(r, 32'd6, "x11 lbu");
        check(u_dmem.mem[0], 32'h0000061a, "store/byte lane");

        // -------------------------------------------------------------------
        $display("--- B. SW, then every load type at every legal offset ---");
        do_store(F3_W, 32'h40, 32'hDEADBEEF);
        do_load(F3_W,  32'h40, r); check(r, 32'hDEADBEEF, "LW  0x40");
        do_load(F3_B,  32'h40, r); check(r, 32'hFFFFFFEF, "LB  0x40");
        do_load(F3_B,  32'h41, r); check(r, 32'hFFFFFFBE, "LB  0x41");
        do_load(F3_B,  32'h42, r); check(r, 32'hFFFFFFAD, "LB  0x42");
        do_load(F3_B,  32'h43, r); check(r, 32'hFFFFFFDE, "LB  0x43");
        do_load(F3_BU, 32'h40, r); check(r, 32'h000000EF, "LBU 0x40");
        do_load(F3_BU, 32'h41, r); check(r, 32'h000000BE, "LBU 0x41");
        do_load(F3_BU, 32'h42, r); check(r, 32'h000000AD, "LBU 0x42");
        do_load(F3_BU, 32'h43, r); check(r, 32'h000000DE, "LBU 0x43");
        do_load(F3_H,  32'h40, r); check(r, 32'hFFFFBEEF, "LH  0x40");
        do_load(F3_H,  32'h42, r); check(r, 32'hFFFFDEAD, "LH  0x42");
        do_load(F3_HU, 32'h40, r); check(r, 32'h0000BEEF, "LHU 0x40");
        do_load(F3_HU, 32'h42, r); check(r, 32'h0000DEAD, "LHU 0x42");

        // -------------------------------------------------------------------
        $display("--- C. Positive values: sign extension adds zeros ---");
        do_store(F3_W, 32'h50, 32'h12345678);
        do_load(F3_B, 32'h50, r); check(r, 32'h00000078, "LB  positive");
        do_load(F3_H, 32'h52, r); check(r, 32'h00001234, "LH  positive");

        // -------------------------------------------------------------------
        $display("--- D. SB to each lane / SH to each half (others unchanged) ---");
        do_store(F3_W, 32'h60, 32'h44332211);
        do_store(F3_B, 32'h60, 32'hFFFFFFAA); check(u_dmem.mem[8'h18], 32'h443322AA, "SB lane 0");
        do_store(F3_B, 32'h61, 32'hFFFFFFBB); check(u_dmem.mem[8'h18], 32'h4433BBAA, "SB lane 1");
        do_store(F3_B, 32'h62, 32'hFFFFFFCC); check(u_dmem.mem[8'h18], 32'h44CCBBAA, "SB lane 2");
        do_store(F3_B, 32'h63, 32'hFFFFFFDD); check(u_dmem.mem[8'h18], 32'hDDCCBBAA, "SB lane 3");
        do_store(F3_H, 32'h60, 32'hFFFF1357); check(u_dmem.mem[8'h18], 32'hDDCC1357, "SH lower half");
        do_store(F3_H, 32'h62, 32'hFFFF2468); check(u_dmem.mem[8'h18], 32'h24681357, "SH upper half");

        // -------------------------------------------------------------------
        $display("--- E. Misaligned accesses: flagged, memory unchanged ---");
        saved = u_dmem.mem[8'h10];   // word at 0x40 = DEADBEEF
        @(negedge clk); funct3 = F3_W; address = 32'h41; store_data = 32'hFFFFFFFF; mem_write = 1; #1;
        check({31'b0, misaligned}, 32'd1, "SW 0x41 misaligned flag");
        check({28'b0, byte_enable}, 32'd0, "SW 0x41 byte_enable=0");
        @(negedge clk); address = 32'h42; #1;
        check({31'b0, misaligned}, 32'd1, "SW 0x42 misaligned flag");
        @(negedge clk); funct3 = F3_H; address = 32'h41; #1;
        check({31'b0, misaligned}, 32'd1, "SH 0x41 misaligned flag");
        @(negedge clk); address = 32'h43; #1;
        check({31'b0, misaligned}, 32'd1, "SH 0x43 misaligned flag");
        @(negedge clk); mem_write = 0;
        check(u_dmem.mem[8'h10], saved, "mem unchanged after misaligned");
        @(negedge clk); funct3 = F3_W;  address = 32'h42; mem_read = 1; #1;
        check({31'b0, misaligned}, 32'd1, "LW 0x42 misaligned flag");
        @(negedge clk); funct3 = F3_HU; address = 32'h43; #1;
        check({31'b0, misaligned}, 32'd1, "LHU 0x43 misaligned flag");
        @(negedge clk); mem_read = 0;

        // tb_rv32im_top.v counts an error whenever misaligned is high, so it
        // must stay 0 when no load/store is in the MEM stage.
        @(negedge clk); funct3 = F3_W; address = 32'h3; mem_read = 0; mem_write = 0; #1;
        check({31'b0, misaligned}, 32'd0, "no flag without a memory access");

        // -------------------------------------------------------------------
        $display("--- F. 1 KiB range ---");
        do_store(F3_W, 32'h3FC, 32'hCAFEF00D);
        do_load(F3_W, 32'h3FC, r); check(r, 32'hCAFEF00D, "LW last word 0x3FC");
        do_store(F3_W, 32'h400, 32'h11111111);   // outside 1 KiB: must not wrap
        check(u_dmem.mem[0], 32'h0000061a, "write at 0x400 ignored (no wrap)");
        do_load(F3_W, 32'h400, r); check(r, 32'h0, "read at 0x400 returns 0");

        // -------------------------------------------------------------------
        $display("checks=%0d errors=%0d", checks, errors);
        if (errors == 0)
            $display("ALL TEAM 6 TESTS PASSED");
        else
            $display("TEAM 6 TEST FAILED: %0d errors", errors);
        $finish;
    end

endmodule
