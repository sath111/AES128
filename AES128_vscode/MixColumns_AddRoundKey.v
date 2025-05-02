`include "MixColumns.v"
`include "AddRoundKey.v"

module MixColumns_AddRoundKey(
    input clk, rst_n,
    input [127:0] din,
    input [127:0] key,
    output reg [127:0] dout
);
wire [127:0] dout_tmp;
wire [127:0] state_out;
MixColumns MixColumns_inst(
    .state_in(din),
    .state_out(state_out)
);
AddRoundKey AddRoundKey_inst(
    .din(state_out),
    .key(key),
    .dout(dout_tmp)
);

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        dout <= 128'd0;
    end
    else begin
        dout <= dout_tmp;
    end
end

endmodule