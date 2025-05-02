module AddRoundKey(
    input  [127:0] din,
    input  [127:0] key,
    output [127:0] dout
);

    assign dout = din ^ key;

endmodule
