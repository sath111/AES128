module InputInterface(
    input clk, rst_n,
    input [127:0] key_plaintext,
    input loadkey,
    input loaddata,
    input readkey, 
    input readdata,
    output reg keyrd,
    output reg datard,
    output reg [127:0] InputBlk,
    output reg keynewinput
);

reg [127:0] key, data;

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        key <= 0;
        data <= 0;
    end
    else begin
        if(loadkey) begin
            if(key != key_plaintext) begin
                keyrd <= 1;
                key <= key_plaintext;
                keynewinput <= 1;
                datard <= 0;
            end
        end
        else if(loaddata) begin
            data <= key_plaintext ^ key;
            datard <= 1;
            keyrd <= 0;
        end
        else begin
            keyrd <= 0;
            datard <= 0;
            keynewinput <= 0;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        InputBlk <= 0;
    end
    else begin
        if(readkey) begin
            InputBlk <= key;
        end
        else if(readdata) begin
            InputBlk <= data;
        end
    end
end

endmodule
