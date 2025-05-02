`timescale 1ns/1ps
`include "verification_KeyLogic.v"

module verification_KeyLogic_tb;

    reg clk, rst_n;
    reg Key_rd;
    reg [3:0] addr_key;
    reg [127:0] InputBlk;

    wire done;
    wire mode; // 0: expansion, 1: 
    wire [127:0] Key_data;

    // Instantiate DUT
    verification_KeyLogic dut (
        .clk(clk),
        .rst_n(rst_n),
        .Key_rd(Key_rd),
        .addr_key(addr_key),
        .InputBlk(InputBlk),
        .done(done),
        .Key_data(Key_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        Key_rd = 0;
        addr_key = 0;
        InputBlk = 128'h0;  // AES sample key

        $dumpfile("verification_KeyLogic_tb.vcd");
        $dumpvars(0, verification_KeyLogic_tb);
        // Apply reset
        #10;
        rst_n = 1;
        Key_rd = 1;
        InputBlk = 128'h5468617473206D79204B756E67204675;
        
        #10
        Key_rd = 0;
        // Wait a bit then start key generation
        #20;
        Key_rd = 0;
        InputBlk = 128'h0;

        // Wait for done signal
        wait(done);
        #10 addr_key = 0;
        #10 addr_key = 1;
        #10 addr_key = 2;

        // You can also add `$finish` to end simulation
        #10;
        $finish;
    end

endmodule
