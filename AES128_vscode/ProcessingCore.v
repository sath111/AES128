`include "MixColumns_AddRoundKey.v"
`include "ShiftRows.v"
//`include "Mux2.v"
`include "ProcessingCore_Controller.v"

module ProcessingCore(
    input clk, rst_n,
    input datard,
    input [127:0] text,
    input [127:0] key,

    output [3:0] addr_key,
    output ctvalid,
    output [127:0] ciphertext,
    output ready_new_input,

    //signal Sbox
    input [127:0] sbox_out,
    output [127:0] sbox_in
);

wire [127:0] b_in; // input shift_rows


wire [127:0] dout_MA;
wire src_input;
Mux2 Mux2_inst(
    .a(dout_MA),
    .b(text),
    .select(src_input),
    .c(b_in)
);

ShiftRows ShiftRows_inst(
    .b_in(b_in),
    .b_out(sbox_in)
);

MixColumns_AddRoundKey MixColumns_AddRoundKey_inst(
    .clk(clk),
    .rst_n(rst_n),
    .din(sbox_out),
    .key(key),
    .dout(dout_MA)
);

AddRoundKey AddRoundKey_inst(
    .din(sbox_out),
    .key(key),
    .dout(ciphertext)
);

ProcessingCore_Controller ProcessingCore_Controller_inst(
    .clk(clk),
    .rst_n(rst_n),
    .datard(datard),
    .addr_key(addr_key),
    .ctvalid(ctvalid),
    .ready_new_input(ready_new_input),
    .src_input(src_input)
);



endmodule