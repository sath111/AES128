module Mux2(
    input [127:0] a, b,
    input select,
    output [127:0] c
);

assign c = (select) ? b : a;

endmodule