`include "mul3.v"

module MixColumns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    // Tách từng byte
    wire [7:0] s0  = state_in[127:120];
    wire [7:0] s1  = state_in[119:112];
    wire [7:0] s2  = state_in[111:104];
    wire [7:0] s3  = state_in[103:96];
    wire [7:0] s4  = state_in[95:88];
    wire [7:0] s5  = state_in[87:80];
    wire [7:0] s6  = state_in[79:72];
    wire [7:0] s7  = state_in[71:64];
    wire [7:0] s8  = state_in[63:56];
    wire [7:0] s9  = state_in[55:48];
    wire [7:0] s10 = state_in[47:40];
    wire [7:0] s11 = state_in[39:32];
    wire [7:0] s12 = state_in[31:24];
    wire [7:0] s13 = state_in[23:16];
    wire [7:0] s14 = state_in[15:8];
    wire [7:0] s15 = state_in[7:0];

    // Tạo module mul2, mul3 cho từng byte
    wire [7:0] s0_2, s1_2, s2_2, s3_2, s4_2, s5_2, s6_2, s7_2;
    wire [7:0] s8_2, s9_2, s10_2, s11_2, s12_2, s13_2, s14_2, s15_2;

    wire [7:0] s0_3, s1_3, s2_3, s3_3, s4_3, s5_3, s6_3, s7_3;
    wire [7:0] s8_3, s9_3, s10_3, s11_3, s12_3, s13_3, s14_3, s15_3;

    // Nhân 2
    mul2 u0_mul2 (.a(s0), .result(s0_2));
    mul2 u1_mul2 (.a(s1), .result(s1_2));
    mul2 u2_mul2 (.a(s2), .result(s2_2));
    mul2 u3_mul2 (.a(s3), .result(s3_2));
    mul2 u4_mul2 (.a(s4), .result(s4_2));
    mul2 u5_mul2 (.a(s5), .result(s5_2));
    mul2 u6_mul2 (.a(s6), .result(s6_2));
    mul2 u7_mul2 (.a(s7), .result(s7_2));
    mul2 u8_mul2 (.a(s8), .result(s8_2));
    mul2 u9_mul2 (.a(s9), .result(s9_2));
    mul2 u10_mul2 (.a(s10), .result(s10_2));
    mul2 u11_mul2 (.a(s11), .result(s11_2));
    mul2 u12_mul2 (.a(s12), .result(s12_2));
    mul2 u13_mul2 (.a(s13), .result(s13_2));
    mul2 u14_mul2 (.a(s14), .result(s14_2));
    mul2 u15_mul2 (.a(s15), .result(s15_2));

    // Nhân 3
    mul3 u0_mul3 (.a(s0), .result(s0_3));
    mul3 u1_mul3 (.a(s1), .result(s1_3));
    mul3 u2_mul3 (.a(s2), .result(s2_3));
    mul3 u3_mul3 (.a(s3), .result(s3_3));
    mul3 u4_mul3 (.a(s4), .result(s4_3));
    mul3 u5_mul3 (.a(s5), .result(s5_3));
    mul3 u6_mul3 (.a(s6), .result(s6_3));
    mul3 u7_mul3 (.a(s7), .result(s7_3));
    mul3 u8_mul3 (.a(s8), .result(s8_3));
    mul3 u9_mul3 (.a(s9), .result(s9_3));
    mul3 u10_mul3 (.a(s10), .result(s10_3));
    mul3 u11_mul3 (.a(s11), .result(s11_3));
    mul3 u12_mul3 (.a(s12), .result(s12_3));
    mul3 u13_mul3 (.a(s13), .result(s13_3));
    mul3 u14_mul3 (.a(s14), .result(s14_3));
    mul3 u15_mul3 (.a(s15), .result(s15_3));

    // Tính toán theo ma trận MixColumns
    wire [7:0] m0 = s0_2 ^ s1_3 ^ s2   ^ s3;
    wire [7:0] m1 = s0   ^ s1_2 ^ s2_3 ^ s3;
    wire [7:0] m2 = s0   ^ s1   ^ s2_2 ^ s3_3;
    wire [7:0] m3 = s0_3 ^ s1   ^ s2   ^ s3_2;

    wire [7:0] m4 = s4_2 ^ s5_3 ^ s6   ^ s7;
    wire [7:0] m5 = s4   ^ s5_2 ^ s6_3 ^ s7;
    wire [7:0] m6 = s4   ^ s5   ^ s6_2 ^ s7_3;
    wire [7:0] m7 = s4_3 ^ s5   ^ s6   ^ s7_2;

    wire [7:0] m8 = s8_2 ^ s9_3 ^ s10  ^ s11;
    wire [7:0] m9 = s8   ^ s9_2 ^ s10_3^ s11;
    wire [7:0] m10= s8   ^ s9   ^ s10_2^ s11_3;
    wire [7:0] m11= s8_3 ^ s9   ^ s10  ^ s11_2;

    wire [7:0] m12= s12_2^ s13_3^ s14  ^ s15;
    wire [7:0] m13= s12  ^ s13_2^ s14_3^ s15;
    wire [7:0] m14= s12  ^ s13  ^ s14_2^ s15_3;
    wire [7:0] m15= s12_3^ s13  ^ s14  ^ s15_2;

    // Gộp lại output
    assign state_out = {m0, m1, m2, m3, m4, m5, m6, m7,
                        m8, m9, m10, m11, m12, m13, m14, m15};

endmodule
