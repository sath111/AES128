module InputInterface_Pipeline(
    input clk, rst_n,
    input [127:0] key_plaintext,
    input loadkey,
    input loaddata,
    input readkey, 
    input readdata,
    input [1:0] addr_data,
    output reg keyrd,
    output reg datard,
    output [127:0] InputBlk,
    output reg keynewinput
);

reg [127:0] key;
reg [127:0] data [0:1];

reg [1:0] cnt;
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        key <= 0;
        data[0] <= 0;
        data[1] <= 0;
//        cnt <= 0;
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
        /*
        else if(loaddata) begin
            if(cnt == 2) begin
                cnt <= 0;
            end
            else begin
                data[cnt] <= key_plaintext ^ key;
                datard <= 1;
                keyrd <= 0;
                cnt <= cnt + 1;
            end
        end
        */
        
        else if(loaddata) begin
            data[cnt] <= key_plaintext ^ key;
            datard <= 1;
            keyrd <= 0;
//            cnt <= cnt + 1;
        end
        
        else begin
            /*
            if(cnt == 2) begin
                cnt <= 0;
            end
            */
            keyrd <= 0;
            datard <= 0;
            keynewinput <= 0;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        cnt <= 0;
    end
    else begin
        if(loaddata) begin
            cnt <= cnt + 1;
        end
        if(readdata) begin
            cnt <= cnt - 1;
        end
    end
end
/*
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        InputBlk <= 0;
    end
    else begin
        if(readkey) begin
            InputBlk <= key;
        end
        else if(readdata) begin
            InputBlk <= data[addr_data];
        end
    end
end
*/
/*
always @(*) begin
    if(readkey) begin
        InputBlk = key;
    end
    else if(readdata) begin
        InputBlk = data[addr_data];
    end
end
*/
reg [127:0] InputBlk_reg;
assign InputBlk = (readkey)   ? key :
                  (readdata) ? data[addr_data] :
                  InputBlk_reg; // giữ giá trị cũ nếu không có điều kiện

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        InputBlk_reg <= 0;
    else
        InputBlk_reg <= InputBlk; // update giá trị mới nếu có thay đổi
end

endmodule
