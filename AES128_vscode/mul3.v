`include "mul2.v"

module mul3 (
    input  wire [7:0] a,
    output wire [7:0] result
);
    wire [7:0] mul2_result;

    mul2 u_mul2 (
        .a(a),
        .result(mul2_result)
    );

    assign result = mul2_result ^ a;
endmodule
