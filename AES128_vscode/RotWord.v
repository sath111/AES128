module RotWord (
    input  [31:0] rot_in,   // Input word: 4 bytes (A B C D)
    output [31:0] rot_out   // Output word: rotated (B C D A)
);

assign rot_out = {rot_in[23:0], rot_in[31:24]}; // shift 8 bits to the left

endmodule
