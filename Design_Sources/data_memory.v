// =============================================================================
// Module:   data_memory
// Project:  IEEE SSCS RV32IM CPU - Team 6 Load/Store & Data Memory
// Authors:  Omar & Ramin
//
// Function:
//   1 KiB byte-addressed, little-endian data memory, stored as 256 words of
//   32 bits (four 8-bit byte lanes per word).
//
//   - Reads are COMBINATIONAL: the whole 32-bit word containing `address`
//     appears on read_word in the same cycle. load_store_unit then selects
//     and extends the requested byte/halfword.
//   - Writes are SYNCHRONOUS: on the rising clock edge, when write_enable is
//     1, only the byte lanes whose byte_enable bit is 1 are updated. The
//     other bytes in the word keep their previous values.
//   - Addresses outside the 1 KiB range (address[31:10] != 0) read as zero
//     and are never written.
//
// Inputs:
//   clk               : Clock; writes happen on its rising edge.
//   address[31:0]     : Byte address. address[9:2] = word index,
//                       address[1:0] = byte lane (handled by load_store_unit).
//   write_data[31:0]  : Store data already shifted into lanes.
//   write_enable      : 1 for a valid, aligned store.
//   byte_enable[3:0]  : Bit i = 1 writes byte lane i.
//
// Output:
//   read_word[31:0]   : The full 32-bit word at the addressed location.
// =============================================================================

module data_memory (
    input wire clk,

    input wire [31:0] address,
    input wire [31:0] write_data,

    input wire write_enable,
    input wire [3:0] byte_enable,

    output wire [31:0] read_word
);

    // 256 words x 32 bits = 1 KiB.
    reg [31:0] mem [0:255];

    // Drop address[1:0] (byte inside the word) to get the word index.
    wire [7:0] word_index = address[9:2];

    // Only addresses 0x000-0x3FF exist in this memory.
    wire in_range = (address[31:10] == 22'b0);

    // Start simulation with every word cleared so unwritten locations
    // read as zero instead of X.
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
    end

    // Read: combinational. Return the whole word that contains `address`.
    assign read_word = in_range ? mem[word_index] : 32'b0;

    // Write: on the rising edge, update only the byte lanes selected by
    // byte_enable so unselected bytes remain unchanged.
    always @(posedge clk) begin
        if (write_enable && in_range) begin
            if (byte_enable[0]) mem[word_index][7:0]   <= write_data[7:0];   // lane 0 (addr +0)
            if (byte_enable[1]) mem[word_index][15:8]  <= write_data[15:8];  // lane 1 (addr +1)
            if (byte_enable[2]) mem[word_index][23:16] <= write_data[23:16]; // lane 2 (addr +2)
            if (byte_enable[3]) mem[word_index][31:24] <= write_data[31:24]; // lane 3 (addr +3)
        end
    end

endmodule
