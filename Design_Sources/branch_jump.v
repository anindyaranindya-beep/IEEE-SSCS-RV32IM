module branch_jump(

    input wire [31:0] pc,
    input wire [31:0] rs1_value,
    input wire [31:0] rs2_value,
    input wire [31:0] immediate,
    
    input wire[2:0] func3,
    
    input wire branch,
    input wire jump,
    input wire jalr,
    
    output reg redirect,
    output reg [31:0] target_pc
    );
    localparam BEQ = 3'b000, BNE = 3'b001, BLT = 3'b010,BGE = 3'b011, BLTU=3'b110, BGEU = 3'b111;
    always @(*) begin
        redirect = 1'b0;
        target_pc = pc + 32'd4;
        if (branch && !jump) begin
          case (func3) 
           BEQ:
           begin
                if (rs1_value == rs2_value) begin
                    target_pc = pc + immediate;
                    redirect = 1'b1;
                end
            end 
            BNE:
            begin
                if (rs1_value != rs2_value) begin
                    target_pc = pc + immediate;
                    redirect = 1'b1;
                end
            end 
            BLT:
            begin
                if (rs1_value < rs2_value) begin
                    target_pc = pc + immediate;
                    redirect = 1'b1;
                end
            end 
            BGE:
            begin
                if($signed(rs1_value) >= $signed(rs2_value)) begin
                    target_pc = pc + immediate;
                    redirect = 1'b1;
                    end
            end
            BLTU:
            begin
                if(rs1_value<rs2_value) begin
                target_pc = pc + immediate;
                redirect = 1'b1;
                end
            end
            BGEU:
            begin
            if(rs1_value>= rs2_value) begin
                target_pc = pc + immediate;
                redirect = 1'b1;
                end
            end
        endcase
        end
        if(jump && !branch) begin
            //jal
            if(jalr == 0) begin
                target_pc = pc+immediate;
                redirect = 1'b1;
            end
            
            //jalr
            if (jalr == 1) begin
                target_pc = (rs1_value + immediate) & 32'hFFFFFFFE;
                redirect = 1'b1;
                end
            
        end
    end
endmodule
