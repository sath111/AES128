module mul2 (
    input  wire [7:0] a,
    output wire [7:0] result
);
    assign result = (a[7]) ? ((a << 1) ^ 8'h1b) : (a << 1);
endmodule
