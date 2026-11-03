module divider (
    input wire clk,
    input wire reset,
    input wire start,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] funct3,

    output reg busy,
    output reg done,
    output reg [31:0] result
);

    reg [31:0] q;
    reg [31:0] divisor;
    reg [32:0] rem;
    reg [5:0] count;

    reg qneg;
    reg rneg;
    reg choose_rem;

    reg [32:0] tmprem;
    reg [31:0] tmpq;

    reg [31:0] abs_a;
    reg [31:0] abs_b;
    reg signmode;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            busy <= 0;
            done <= 0;
            result <= 0;

            q <= 0;
            divisor <= 0;
            rem <= 0;
            count <= 0;

            qneg <= 0;
            rneg <= 0;
            choose_rem <= 0;
        end

        else begin
            done <= 0;

            if (start && !busy) begin
                choose_rem <= (funct3 == 3'b110 ||
                               funct3 == 3'b111);

                signmode = (funct3 == 3'b100 ||
                            funct3 == 3'b110);

                abs_a = (signmode && a[31])
                      ? (~a + 1) : a;

                abs_b = (signmode && b[31])
                      ? (~b + 1) : b;

                if (b == 0) begin
                    result = (funct3 == 3'b110 ||
                              funct3 == 3'b111)
                           ? a : 32'hffffffff;

                    done <= 1;
                    busy <= 0;
                end

                else if (signmode &&
                         a == 32'h80000000 &&
                         b == 32'hffffffff) begin

                    result = (funct3 == 3'b110)
                           ? 0 : 32'h80000000;

                    done <= 1;
                    busy <= 0;
                end

                else begin
                    q <= abs_a;
                    divisor <= abs_b;
                    rem <= 0;
                    count <= 32;

                    qneg <= signmode && (a[31] ^ b[31]);
                    rneg <= signmode && a[31];
                    busy <= 1;
                end
            end

            else if (busy) begin
                tmprem = {rem[31:0], q[31]};

                if (tmprem >= {1'b0, divisor}) begin
                    tmprem = tmprem - {1'b0, divisor};
                    tmpq = {q[30:0], 1'b1};
                end

                else begin
                    tmpq = {q[30:0], 1'b0};
                end

                rem <= tmprem;
                q <= tmpq;
                count <= count - 1;

                if (count == 1) begin
                    busy <= 0;
                    done <= 1;

                    if (choose_rem)
                        result = rneg
                               ? (~tmprem[31:0] + 1)
                               : tmprem[31:0];

                    else
                        result = qneg
                               ? (~tmpq + 1)
                               : tmpq;
                end
            end
        end
    end

endmodule
