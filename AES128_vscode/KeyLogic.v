//`include "Mux2.v"
`include "Registerfile.v"
`include "RotWord.v"
`include "Xorr.v"
`include "KeyLogic_Controller.v"

module KeyLogic(
    input clk, rst_n,
    input Key_rd,
    input [3:0] addr_key,
    input [127:0] InputBlk,

    output done,
    output mode, // 0: expansion, 1: 
    output [127:0] Key_data,

    // from - to -sbox
    input [31:0] sub_in,
    output [31:0] rot_out
);

// signal mux2
wire [127:0] key_new;
wire src_rf;

//signal rf
wire wen;
wire [3:0] raddr, waddr;
wire [127:0] din, dout;

Mux2 Mux2_inst(
    .a(key_new),
    .b(InputBlk),
    .select(src_rf),
    .c(din)
);

Registerfile Registerfile_inst(
    .clk(clk),
    .rst_n(rst_n),
    .wen(wen),
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .dout(dout)
);
assign Key_data = dout;

RotWord RotWord_inst(
    .rot_in(dout[31:0]),
    .rot_out(rot_out)
);

//signal Xorr
wire [3:0] round;
Xorr Xorr_inst(
    .key_prev(dout),
    .round(round),
    .sub_in(sub_in),
    .key_new(key_new)
);

KeyLogic_Controller KeyLogic_Contronller_inst(
    .clk(clk),
    .rst_n(rst_n),
    .Key_rd(Key_rd),
    .addr_key(addr_key),
    .done(done),
    .mode(mode),
    .round(round),
    .raddr(raddr),
    .waddr(waddr),
    .wen(wen),
    .src_rf(src_rf)
);

endmodule
