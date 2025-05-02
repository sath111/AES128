module Registerfile_Data(
    input clk, rst_n,
    input wen, 
    input waddr, raddr,
    input [127:0] din,
    output [127:0] dout
);

reg [127:0] mem [0:1];
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        mem[0] <= 0;
        mem[1] <= 0;
    end
    else begin
        if(wen) begin
            mem[waddr] <= din;
        end
    end
end

assign dout = mem[raddr];

endmodule