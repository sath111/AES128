`include "sbox.v"

module Sbox_wrapper(
    input         clk,
    input         rst_n,
    input  [127:0] state_in,
    output reg [127:0] state_out
);

    wire [7:0] sbox_out[15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : SBOX_LOOP
            sbox sbox_inst (
                .a(state_in[8*i +: 8]), // đổi lại thứ tự đúng
                .c(sbox_out[i])
            );
        end
    endgenerate

    // Đăng ký output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_out <= 128'd0;
        else
            state_out <= {
                            sbox_out[15], sbox_out[14], sbox_out[13], sbox_out[12],
                            sbox_out[11], sbox_out[10], sbox_out[9],  sbox_out[8],
                            sbox_out[7],  sbox_out[6],  sbox_out[5],  sbox_out[4],
                            sbox_out[3],  sbox_out[2],  sbox_out[1],  sbox_out[0]
};

    end

endmodule
