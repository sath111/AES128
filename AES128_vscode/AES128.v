`include "InputInterface.v"
`include "KeyLogic.v"
`include "ProcessingCore.v"
`include "Mux2.v"
`include "Sbox_wrapper.v"
`include "SystemController.v"

module AES128(
    input clk, rst_n,
    input [127:0] key_plaintext,
    input loadkey,
    input loaddata,

    output ready_new_input,
    output [127:0] ciphertext,
    output ctvalid_sc
);


wire keyrd_if, datard_if, keynewinput_if;
wire [127:0] InputBlk;
wire readkey, readdata;
InputInterface InputInterface_inst(
    .clk(clk),
    .rst_n(rst_n),
    .key_plaintext(key_plaintext),
    .loadkey(loadkey),
    .loaddata(loaddata),
    .readkey(readkey),
    .readdata(readdata),
    .keyrd(keyrd_if),
    .datard(datard_if),
    .InputBlk(InputBlk),
    .keynewinput(keynewinput_if)
);


wire Key_rd_kl;
wire [3:0] addr_key_kl;
wire done_kl;
wire [127:0] Key_data;
wire [31:0] sub_in, rot_out;
KeyLogic KeyLogic_inst(
    .clk(clk),
    .rst_n(rst_n),
    .Key_rd(Key_rd_kl),
    .addr_key(addr_key_kl),
    .InputBlk(InputBlk),
    .done(done_kl),
    .Key_data(Key_data),
    .sub_in(sub_in),
    .rot_out(rot_out)
);

wire data_rd_pc;
wire ctvalid_pc;
wire [127:0] ciphertext;
wire ready_new_input;
wire [127:0] sbox_in, sbox_out;
ProcessingCore ProcessingCore_inst(
    .clk(clk),
    .rst_n(rst_n),
    .datard(data_rd_pc),
    .text(InputBlk),
    .key(Key_data),
    .addr_key(addr_key_kl),
    .ctvalid(ctvalid_pc),
    .ciphertext(ciphertext),
    .ready_new_input(ready_new_input),
    .sbox_out(sbox_out),
    .sbox_in(sbox_in)
);

wire [127:0] rot_out_tmp;
assign rot_out_tmp = {96'b0, rot_out};
wire [127:0] state_in, state_out;
wire src_sbox;
Mux2 Mux2_inst(
    .a(rot_out_tmp),
    .b(sbox_in),
    .select(src_sbox),
    .c(state_in)
);

Sbox_wrapper Sbox_wrapper_inst(
    .clk(clk),
    .rst_n(rst_n),
    .state_in(state_in),
    .state_out(state_out)
);

assign sub_in = state_out[31:0];
assign sbox_out = state_out;

wire ctvalid_sc;
SystemController SystemController_inst(
    .clk(clk),
    .rst_n(rst_n),
    .done_kl(done_kl),
    .ready_new_input_pc(ready_new_input),
    .ctvalid_pc(ctvalid_pc),
    .keynewinput(keynewinput_if),
    .keyrd_if(keyrd_if),
    .datard_if(datard_if),
    .src_sbox(src_sbox),
    .Key_rd_kl(Key_rd_kl),
    .data_rd_pc(data_rd_pc),
    .readdata(readdata),
    .readkey(readkey),
    .ready_new_input(ready_new_input),
    .ctvalid(ctvalid_sc),
    .done(done)
);




endmodule