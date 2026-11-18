// =============================================================================
// Module:   load_store_unit
// Project:  IEEE SSCS RV32IM CPU - Team 6 Load/Store & Data Memory
// Authors:  Omar & Ramin
//
// Function:
//   Combinational MEM-stage logic for every RV32I load and store. It combines
//   three jobs:
//     1. Alignment check : flag halfword/word accesses that are not aligned.
//     2. Store alignment : shift store data into the correct byte lanes and
//                          generate a 4-bit byte-enable mask.
//     3. Load extraction : select the requested byte/halfword from the memory
//                          word and sign- or zero-extend it to 32 bits.
//
//   Memory is little-endian with four 8-bit lanes per 32-bit word:
//        lane:     3          2          1          0
//        bits:  [31:24]    [23:16]    [15:8]     [7:0]
//        addr:   +3         +2         +1         +0
//   address[1:0] selects the byte lane inside the word.
//
// Inputs:
//   address[31:0]    : Byte address computed in EX (rs1 + immediate).
//   store_data[31:0] : Value to store (rs2). SB uses [7:0], SH uses [15:0].
//   mem_word[31:0]   : Full 32-bit word read from data_memory.
//   funct3[2:0]      : Access size/sign: 000 B, 001 H, 010 W, 100 BU, 101 HU.
//   mem_read         : 1 for a valid load in the MEM stage.
//   mem_write        : 1 for a valid store in the MEM stage.
//
// Outputs:
//   aligned_store[31:0] : Store data shifted into its byte lane(s).
//   load_data[31:0]     : Sign/zero-extended load result for writeback.
//   byte_enable[3:0]    : Bit i = 1 writes byte lane i (0000 = write nothing).
//   misaligned          : 1 when a load/store address is misaligned.
// =============================================================================

module load_store_unit (
    input wire [31:0] address,
    input wire [31:0] store_data,
    input wire [31:0] mem_word,

    input wire [2:0] funct3,

    input wire mem_read,
    input wire mem_write,

    output reg [31:0] aligned_store,
    output reg [31:0] load_data,

    output reg [3:0] byte_enable,
    output reg misaligned
);

    // funct3 encodings (shared table in the project README)
    localparam [2:0] F3_B  = 3'b000;  // LB  / SB
    localparam [2:0] F3_H  = 3'b001;  // LH  / SH
    localparam [2:0] F3_W  = 3'b010;  // LW  / SW
    localparam [2:0] F3_BU = 3'b100;  // LBU
    localparam [2:0] F3_HU = 3'b101;  // LHU

    // The lowest two address bits select the byte lane inside a word.
    wire [1:0] byte_offset = address[1:0];

    // Intermediate values used for load extraction.
    reg [7:0]  selected_byte;
    reg [15:0] selected_halfword;

    always @(*) begin
        // Default values on every path prevent unintended latches.
        aligned_store     = 32'b0;
        load_data         = 32'b0;
        byte_enable       = 4'b0000;
        misaligned        = 1'b0;
        selected_byte     = 8'b0;
        selected_halfword = 16'b0;

        // ---------------------------------------------------------------------
        // 1. Alignment check (only for real memory accesses).
        //    Bytes may use any address. Halfwords need an even address
        //    (address[0] = 0). Words need an address divisible by four
        //    (address[1:0] = 00).
        // ---------------------------------------------------------------------
        if (mem_read || mem_write) begin
            case (funct3)
                F3_H, F3_HU: misaligned = address[0];
                F3_W:        misaligned = (address[1:0] != 2'b00);
                default:     misaligned = 1'b0;
            endcase
        end

        // ---------------------------------------------------------------------
        // 2. Store alignment.
        //    Shift the store data into the byte lane(s) chosen by the address
        //    and enable only those lanes. Prevent memory writes when this is
        //    not a store or when the address is misaligned.
        // ---------------------------------------------------------------------
        if (mem_write && !misaligned) begin
            case (funct3)
                // SB: move the low byte into lane byte_offset (shift by 8 * offset).
                F3_B: begin
                    aligned_store = {24'b0, store_data[7:0]} << {byte_offset, 3'b000};
                    byte_enable   = 4'b0001 << byte_offset;
                end

                // SH: address[1] picks the lower (lanes 0-1) or upper (lanes 2-3) half.
                F3_H: begin
                    aligned_store = {16'b0, store_data[15:0]} << {byte_offset[1], 4'b0000};
                    byte_enable   = 4'b0011 << {byte_offset[1], 1'b0};
                end

                // SW: the word already fills all four lanes.
                F3_W: begin
                    aligned_store = store_data;
                    byte_enable   = 4'b1111;
                end

                // Any other funct3 is not a valid store: write nothing.
                default: begin
                    aligned_store = 32'b0;
                    byte_enable   = 4'b0000;
                end
            endcase
        end

        // ---------------------------------------------------------------------
        // 3. Load extraction.
        //    Select the byte requested by the memory address. In little-endian
        //    order, offset zero selects the lowest eight bits.
        // ---------------------------------------------------------------------
        case (byte_offset)
            2'b00: selected_byte = mem_word[7:0];
            2'b01: selected_byte = mem_word[15:8];
            2'b10: selected_byte = mem_word[23:16];
            2'b11: selected_byte = mem_word[31:24];
        endcase

        // Aligned halfwords start at offset 0 or 2; address[1] picks the half.
        selected_halfword = byte_offset[1] ? mem_word[31:16] : mem_word[15:0];

        if (mem_read) begin
            case (funct3)
                // LB: sign-extend an 8-bit signed value to 32 bits.
                F3_B:  load_data = {{24{selected_byte[7]}}, selected_byte};
                // LH: sign-extend a 16-bit signed value to 32 bits.
                F3_H:  load_data = {{16{selected_halfword[15]}}, selected_halfword};
                // LW: the whole word is already 32 bits wide.
                F3_W:  load_data = mem_word;
                // LBU: zero-extend the byte.
                F3_BU: load_data = {24'b0, selected_byte};
                // LHU: zero-extend the halfword.
                F3_HU: load_data = {16'b0, selected_halfword};
                // Unknown funct3: deterministic zero result.
                default: load_data = 32'b0;
            endcase
        end
    end

endmodule
