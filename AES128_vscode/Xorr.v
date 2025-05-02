`include "Rcon.v"


module Xorr (
    input [127:0] key_prev,
    input [31:0] sub_in,
    input [3:0] round,
    output [127:0] key_new
);

    wire [31:0] rcon;
    wire [31:0] w0, w1, w2, w3;
    wire [31:0] temp, w4, w5, w6, w7;

    // Cắt key_prev thành 4 phần w0..w3
    assign {w0, w1, w2, w3} = key_prev;

    // Tính Rcon từ round
    Rcon u_rcon (
        .round(round),
        .rcon_out(rcon)
    );

    assign temp = sub_in ^ rcon;
    assign w4 = w0 ^ temp;
    assign w5 = w1 ^ w4;
    assign w6 = w2 ^ w5;
    assign w7 = w3 ^ w6;

   assign key_new = {w4, w5, w6, w7};

endmodule
