module Registerfile (
    input              clk,
    input              rst_n,

    // Write port
    input              wen,
    input  [3:0]       waddr,   // 4-bit để truy cập 11 thanh ghi
    input  [127:0]     din,

    // Read port
    input  [3:0]       raddr,
    output [127:0] dout
);

    // 11 thanh ghi 128-bit
    reg [127:0] regs [0:10];

    integer i;

    // Write logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 11; i = i + 1) begin
                regs[i] <= 128'd0;
            end
        end 
        else begin
            if (wen) begin
                regs[waddr] <= din;
            end
        end
    end

    assign dout = regs[raddr];

endmodule
