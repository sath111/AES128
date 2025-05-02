`include "ShiftRows.v"
`include "MixColumns_AddRoundKey.v"
//`include "Mux2.v"
`include "Registerfile_Data.v"
`include "PCore_Controller_Pipelinev1.v"

module ProcessingCore_Pipelinev1(
    input clk, rst_n,
    input datard,
    input [127:0] InputBlk,

    output [3:0] addr_key,
    input [127:0] key,

    output ctvalid1, ctvalid2,
    output ready_new_input,
    output ready_new_key,

    output [127:0] sbox_in,
    input [127:0] sbox_out,

    output [127:0] ciphertext
);

wire [127:0] b_in;
ShiftRows ShiftRows_inst(
    .b_in(b_in),
    .b_out(sbox_in)
);

wire [127:0] out_MA;
MixColumns_AddRoundKey MixColumns_AddRoundKey_inst(
    .clk(clk),
    .rst_n(rst_n),
    .din(sbox_out),
    .key(key),
    .dout(out_MA)
);

AddRoundKey AddRoundKey_inst(
    .din(sbox_out),
    .key(key),
    .dout(ciphertext)
);

wire wen;
wire waddr, raddr;
wire [127:0] dout_rf;
Registerfile_Data Registerfile_Data_inst(
    .clk(clk),
    .rst_n(rst_n),
    .wen(wen),
    .waddr(waddr),
    .raddr(raddr),
    .din(InputBlk),
    .dout(dout_rf)
);

wire src_input;
Mux2 Mux2_inst(
    .a(out_MA),
    .b(dout_rf),
    .select(src_input),
    .c(b_in)
);

//wire ctvalid1, ctvalid2;
PCore_Controller_Pipelinev1 PCore_Controller_Pipelinev1_inst(
    .clk(clk),
    .rst_n(rst_n),
    .datard(datard),
    .wen(wen),
    .waddr(waddr),
    .raddr(raddr),
    .addr_key(addr_key),
    .ctvalid1(ctvalid1),
    .ctvalid2(ctvalid2),
    .ready_new_input(ready_new_input),
    .ready_new_key(ready_new_key),
    .src_input(src_input)
);

//assign done = ctvalid1 | ctvalid2;


endmodule