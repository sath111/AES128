`include "AES128v1.v"

module AES128_tb;

    reg clk, rst_n;
    reg [127:0] key_plaintext;
    reg loadkey;
    reg loaddata;

    wire ready_new_input;
    wire [127:0] ciphertext;
    wire ctvalid_sc;

    AES128v1 dut(
        .clk(clk),
        .rst_n(rst_n),
        .key_plaintext(key_plaintext),
        .loadkey(loadkey),
        .loaddata(loaddata),
        .ready_new_input(ready_new_input),
        .ciphertext(ciphertext),
        .ctvalid_sc(ctvalid_sc)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("AES_tb.vcd");
        $dumpvars(0, AES128_tb);

        clk = 0; 
        rst_n = 0;
        key_plaintext = 0;
        loaddata = 0;
        loadkey = 0;

        #10 rst_n = 1;

        #10
        loadkey = 1;
        key_plaintext = 128'h5468617473206D79204B756E67204675;
        #10
        loadkey = 0;
        loaddata = 1;
        key_plaintext = 128'h5468617473206D79204B756E12345678;
        #10
        loaddata = 0;


        #500;
        loaddata = 1;
        key_plaintext = 128'h54776F204F6E65204E696E652054776F;
        #10
        loaddata = 0;


        #500
        loadkey = 1;
        key_plaintext = 128'h54776F204F6E65204E696E652054776F;
        #10
        loaddata = 1;
        loadkey = 0;
        key_plaintext = 128'h5468617473206D79204B756E12345678;
        #10
        loaddata = 0;

        #500


        $finish;

    end

endmodule