`timescale 1ns/1ps
`include "MixColumns.v"
module tb_MixColumns;

    reg  [127:0] state_in;
    wire [127:0] state_out;

    // Instantiate MixColumns
    MixColumns uut (
        .state_in(state_in),
        .state_out(state_out)
    );

    initial begin
        // Initialize input
        state_in = 128'h632fafa2eb93c7209f92abcba0c0302b; // Ví dụ từ tài liệu chuẩn

        // Đợi 10ns để module xử lý
        #10;
        
        // Hiển thị kết quả
        $display("Input state_in  = %h", state_in);
        $display("Output state_out = %h", state_out);

        // Kết thúc mô phỏng
        #10;
        $finish;
    end

endmodule
