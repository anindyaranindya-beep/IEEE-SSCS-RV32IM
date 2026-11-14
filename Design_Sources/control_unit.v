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

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
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
        
        case (opcode)

            7'b0110011: begin
                 if (funct7 == 7'b0000001) begin
                     is_m = 1;
                     
                     
                     case (funct3)
                        3'b000: begin // MUL
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                
                        3'b001: begin // MULH
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                
                        3'b010: begin // MULHSU
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                
                        3'b011: begin // MULHU
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                
                        3'b100: begin // DIV
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                
                        3'b101: begin // DIVU
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                
                        3'b110: begin // REM
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                
                        3'b111: begin // REMU
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                        end
                     endcase
                 end else begin
                    case (funct3)

                        3'b000: begin // ADD / SUB
                            if (funct7 == 7'b0000000 || funct7 == 7'b0100000) begin
                                valid_instruction = 1;
                                reg_write = 1;
                                wb_sel = 2'd0;
                            end
                        end
                    
                        3'b001: begin // SLL
                            if (funct7 == 7'b0000000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end 
                     end
                    
                        3'b010: begin // SLT
                            if (funct7 == 7'b0000000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end 
                     end
                    
                        3'b011: begin // SLTU
                            if (funct7 == 7'b0000000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end
                     end
                    
                        3'b100: begin // XOR 
                            if (funct7 == 7'b0000000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end
                    end
                    
                        3'b101: begin // SRL / SRA
                             if (funct7 == 7'b0000000 || funct7 == 7'b0100000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end
                    end
                    
                        3'b110: begin // OR
                            if (funct7 == 7'b0000000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                            end 
                        end
                    
                        3'b111: begin // AND
                            if (funct7 == 7'b0000000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end
                     end
                    
                    endcase
                end
            end 
           7'b0010011: begin
                alu_src = 1;
                imm_sel = 3'd0;
            
                case (funct3)
                    3'b000: begin // ADDI
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                    end
                    3'b010: begin // SLTI
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                    end
                    3'b011: begin // SLTIU
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                    end
                    3'b100: begin // XORI
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                    end
                    3'b110: begin // ORI
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                    end
                    3'b111: begin // ANDI
                        valid_instruction = 1;
                        reg_write = 1;
                        wb_sel = 2'd0;
                    end
                    3'b001: begin // SLLI
                        if (funct7 == 7'b0000000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end
                    end
                    3'b101: begin // SRLI / SRAI
                        if (funct7 == 7'b0000000 || funct7 == 7'b0100000) begin
                            valid_instruction = 1;
                            reg_write = 1;
                            wb_sel = 2'd0;
                        end
                    end
                endcase
            end
           7'b0000011: begin
                alu_src = 1;
                imm_sel = 3'd0;
            
                case (funct3)
                    3'b000: begin // LB
                        valid_instruction = 1;
                        reg_write = 1;
                        mem_read = 1;
                        wb_sel = 2'd1;
                    end 
                    3'b001: begin // LH
                        valid_instruction = 1;
                        reg_write = 1;
                        mem_read = 1;
                        wb_sel = 2'd1;
                    end
                    3'b010: begin // LW
                        valid_instruction = 1;
                        reg_write = 1;
                        mem_read = 1;
                        wb_sel = 2'd1;
                    end 
                    3'b100: begin // LBU
                        valid_instruction = 1;
                        reg_write = 1;
                        mem_read = 1;
                        wb_sel = 2'd1;
                    end
                    3'b101: begin // LHU
                        valid_instruction = 1;
                        reg_write = 1;
                        mem_read = 1;
                        wb_sel = 2'd1;
                    end 
                endcase
            end
        7'b0100011: begin
            alu_src = 1;
            imm_sel = 3'd1;

            case (funct3)
                3'b000: begin // SB
                    valid_instruction = 1;
                    mem_write = 1;
                end 
                3'b001: begin // SH
                    valid_instruction = 1;
                    mem_write = 1;
                end
                3'b010: begin // SW
                    valid_instruction = 1;
                    mem_write = 1;
                end     
            endcase
        end
        7'b1100011: begin
            
            imm_sel = 3'd2;
        
            case (funct3)
                3'b000: begin // BEQ
                    valid_instruction = 1;
                    branch = 1;
                end 
                3'b001: begin // BNE
                    valid_instruction = 1;
                    branch = 1;
                end
                3'b100: begin // BLT
                    valid_instruction = 1;
                    branch = 1;
                end
                3'b101: begin // BGE
                    valid_instruction = 1;
                    branch = 1;
                end
                3'b110: begin // BLTU
                    valid_instruction = 1;
                    branch = 1;
                end
                3'b111: begin // BGEU
                    valid_instruction = 1;
                    branch = 1;
                end
            
                endcase 
            end
        7'b1101111: begin
        valid_instruction = 1;
        reg_write = 1;
        jump = 1;
        wb_sel = 2'd2;
        imm_sel = 3'd4;
    end
        7'b1100111: begin
            if (funct3 == 3'b000) begin
                valid_instruction = 1;
                reg_write = 1;
                jump = 1;
                jalr = 1;
                alu_src = 1;
                wb_sel = 2'd2;
                imm_sel = 3'd0;
            end
        end
        7'b0110111: begin
        valid_instruction = 1;
        reg_write = 1;
        wb_sel = 2'd0;
        imm_sel = 3'd3;
        alu_src = 1;
    end
        7'b0010111: begin
        valid_instruction = 1;
        reg_write = 1;
        alu_src = 1;
        alu_a_pc = 1;
        wb_sel = 2'd0;
        imm_sel = 3'd3;
    end
        endcase
    end

endmodule
