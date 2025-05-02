`include "InputInterface_Pipeline.v"
`include "KeyLogic.v"
`include "ProcessingCore_Pipelinev1.v"
`include "Mux2.v"
`include "Sbox_wrapper.v"
`include "SystemController_Pipelinev1.v"

module AES128_Pipelinev1(
    input clk, rst_n,
    input [127:0] key_plaintext,
    input loadkey,
    input loaddata,

    output ready_new_input,   // output từ SystemController
    output ready_new_key,
    output [127:0] ciphertext,
    output ctvalid_sc
);

// Declare wire signals
wire keyrd_if, datard_if, keynewinput_if;
wire [127:0] InputBlk;
wire readkey, readdata;
wire [1:0] addr_data;
// InputInterface instance
InputInterface_Pipeline InputInterface_Pipeline_inst(
    .clk(clk),
    .rst_n(rst_n),
    .key_plaintext(key_plaintext),
    .loadkey(loadkey),
    .loaddata(loaddata),
    .readkey(readkey),
    .readdata(readdata),
    .addr_data(addr_data),
    .keyrd(keyrd_if),
    .datard(datard_if),
    .InputBlk(InputBlk),
    .keynewinput(keynewinput_if)
);

// KeyLogic instance
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

// ProcessingCore instance
wire data_rd_pc;
wire ctvalid1, ctvalid2;
wire [127:0] sbox_in, sbox_out;
wire ready_new_input_pc;  // output từ ProcessingCore (tách riêng)
wire ready_new_key_pc;
ProcessingCore_Pipelinev1 ProcessingCore_Pipelinev1_inst(
    .clk(clk),
    .rst_n(rst_n),
    .datard(data_rd_pc),
    .InputBlk(InputBlk),
    .key(Key_data),
    .addr_key(addr_key_kl),
    .ctvalid1(ctvalid1),
    .ctvalid2(ctvalid2),
    .ciphertext(ciphertext),
    .ready_new_input(ready_new_input_pc),
    .ready_new_key(ready_new_key_pc),

    .sbox_out(sbox_out),
    .sbox_in(sbox_in)
);

// Mux2 instance
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

// Sbox_wrapper instance
Sbox_wrapper Sbox_wrapper_inst(
    .clk(clk),
    .rst_n(rst_n),
    .state_in(state_in),
    .state_out(state_out)
);

// Assign Sbox outputs
assign sub_in = state_out[31:0];
assign sbox_out = state_out;

// SystemController instance
wire ready_new_input_sc; // output từ SystemController (tách riêng)
wire done;

SystemController_Pipelinev1 SystemController_Pipelinev1_inst(
    .clk(clk),
    .rst_n(rst_n),
    .done_kl(done_kl),
    .ready_new_input_pc(ready_new_input_pc),
    .ready_new_key_pc(ready_new_key_pc),
    .ctvalid1(ctvalid1),
    .ctvalid2(ctvalid2),
    .keynewinput_if(keynewinput_if),
    .keyrd_if(keyrd_if),
    .datard_if(datard_if),
    .readdata(readdata),
    .readkey(readkey),
    .addr_data(addr_data),
    .ready_new_input(ready_new_input_sc),
    .ready_new_key(ready_new_key),
    .ctvalid(ctvalid_sc),
    .src_sbox(src_sbox),
    .Key_rd_kl(Key_rd_kl),
    .data_rd_pc(data_rd_pc)
);

// Assign outputs
assign ready_new_input = ready_new_input_sc;

endmodule
