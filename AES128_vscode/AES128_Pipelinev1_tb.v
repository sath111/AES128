`include "AES128_Pipelinev1.v"

module AES128_Pipelinev1_tb;

    reg clk, rst_n;
    reg [127:0] key_plaintext;
    reg loadkey;
    reg loaddata;

    wire ready_new_input;   // output từ SystemController
    wire ready_new_key;
    wire [127:0] ciphertext;
    wire ctvalid_sc;

    AES128_Pipelinev1 dut(
        .clk(clk),
        .rst_n(rst_n),
        .key_plaintext(key_plaintext),
        .loadkey(loadkey),
        .loaddata(loaddata),
        .ready_new_input(ready_new_input),
        .ready_new_key(ready_new_key),
        .ciphertext(ciphertext),
        .ctvalid_sc(ctvalid_sc)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("AES128_Pipelinev1_tb.vcd");
        $dumpvars(0, AES128_Pipelinev1_tb);

        clk = 0;
        rst_n = 0;
        key_plaintext = 0;
        loaddata = 0;
        loadkey = 0;

        #10
        rst_n = 1;
        loadkey = 1;
        key_plaintext = 128'h5468617473206D79204B756E67204675;

        #10
        loadkey = 0;
        loaddata = 1;
        key_plaintext = 128'h54776F204F6E65204E696E652054776F;
        
        
        #10
        loaddata = 0;

        #350
        loaddata = 1;
        key_plaintext = 128'h5468617473206D79204B756E12345678;
        #10
        loaddata = 0;

        #130
        loaddata = 1;
        key_plaintext = 128'h123456784F6E65204E696E652054776F;
        
        #10
        loaddata = 0;

        #130
        loaddata = 1;
        key_plaintext = 128'h123456784F6E65204E696E6512345678;
        
        #10
        loaddata = 0;

        #300;

//        #10 rst_n = 0;
//        #10 rst_n = 1;
        #10
        loadkey = 1;
        key_plaintext = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        #10
        loadkey = 0;
        loaddata = 1;
        key_plaintext = 128'h3243f6a8885a308d313198a2e0370734;
        #10 
        loaddata = 0;

        #10
        loaddata = 1;
        key_plaintext = 128'h12345678885a308d3131981234567891;
        #10
        loaddata = 0;

        #1000
        $finish;

    end



endmodule