`include "KeyLogic.v"
`include "Sbox_wrapper.v"

module verification_KeyLogic(
    input clk, rst_n,
    input Key_rd,
    input [3:0] addr_key,
    input [127:0] InputBlk,

    output done,
    output mode, // 0: expansion, 1: 
    output [127:0] Key_data
);

wire [31:0] sub_in, rot_out;

KeyLogic KeyLogic_inst(
    .clk(clk),
    .rst_n(rst_n),
    .Key_rd(Key_rd),
    .addr_key(addr_key),
    .InputBlk(InputBlk),
    .done(done),
    .mode(mode),
    .Key_data(Key_data),
    .sub_in(sub_in),
    .rot_out(rot_out)
);
wire [127:0] state_out;
Sbox_wrapper Sbox_wrapper_inst(
    .clk(clk),
    .rst_n(rst_n),
    .state_in({96'd0, rot_out}),
    .state_out(state_out)
);
assign sub_in = state_out[31:0];

endmodule