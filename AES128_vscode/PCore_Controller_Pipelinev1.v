module PCore_Controller_Pipelinev1(
    input clk, rst_n,
    input datard,

    output reg wen,
    output reg waddr, 
    output reg raddr,

    output reg [3:0] addr_key,

    output reg ctvalid1, ctvalid2,
    output ready_new_input,
    output ready_new_key,

    output reg src_input
);

reg [2:0] state1, next_state1;
localparam IDLE1 = 0,
           LOAD_DATA1 = 1,
           SHIFTROWS_SUBBYTES1 = 2,
           MIXCOLUMNS_ADDROUNDKEY1 = 3,
           DONE1 = 4;

reg [2:0] state2, next_state2;
localparam IDLE2 = 0,
           LOAD_DATA2 = 1,
           SHIFTROWS_SUBBYTES2 = 2,
           MIXCOLUMNS_ADDROUNDKEY2 = 3,
           DONE2 = 4;


reg [1:0] cnt;
reg [3:0] addr_key1, addr_key2;

//state1 --> next_state1;
always @(*) begin
    case(state1)
        IDLE1: begin
            if(datard && ~cnt) begin
                next_state1 = LOAD_DATA1;
            end
            else begin
                next_state1 = IDLE1;
            end
        end
        LOAD_DATA1: begin
            next_state1 = (state2 == SHIFTROWS_SUBBYTES2 || state2 == IDLE2) ? SHIFTROWS_SUBBYTES1 : LOAD_DATA1;
        end
        SHIFTROWS_SUBBYTES1: begin
            next_state1 = MIXCOLUMNS_ADDROUNDKEY1;
        end
        MIXCOLUMNS_ADDROUNDKEY1: begin
            next_state1 = (addr_key1 == 10) ? DONE1 : SHIFTROWS_SUBBYTES1;
        end
        DONE1: begin
            next_state1 = IDLE1;
        end
        default: next_state1 = IDLE1;
    endcase
end

//state2 --> next_state2
always @(*) begin
    case(state2) 
        IDLE2: begin
            if(datard && cnt) begin
                next_state2 = LOAD_DATA2;
            end
            else begin
                next_state2 = IDLE2;
            end
        end
        LOAD_DATA2: begin
            next_state2 = (state1 == SHIFTROWS_SUBBYTES1) ? SHIFTROWS_SUBBYTES2 : LOAD_DATA2;
        end
        SHIFTROWS_SUBBYTES2: begin
            next_state2 = MIXCOLUMNS_ADDROUNDKEY2;
        end
        MIXCOLUMNS_ADDROUNDKEY2: begin
            next_state2 = (addr_key2 == 10) ? DONE2 : SHIFTROWS_SUBBYTES2;
        end
        DONE2: begin
            next_state2 = IDLE2;
        end
        default: next_state2 = IDLE2;
    endcase
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        state1 <= IDLE1;
    end
    else begin
        state1 <= next_state1;
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        state2 <= IDLE2;
    end
    else begin
        state2 <= next_state2;
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        cnt <= 0;
    end
    else begin
        if(datard) begin
            cnt <= cnt + 1;
        end
        if(cnt == 2 ||(state1 == DONE1 && state2 == IDLE2) || (state2 == DONE2 && state1 == IDLE1)) begin
            cnt <= 0;
        end
    end
end



always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        addr_key1 <= 1;
    end
    else begin
        if(state1 == IDLE1) begin
            addr_key1 <= 1;
        end
        else if(state1 == SHIFTROWS_SUBBYTES1) begin
            addr_key1 <= addr_key1 + 1;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        addr_key2 <= 1;
    end
    else begin
        if(state2 == IDLE2) begin
            addr_key2 <= 1;
        end
        else if(state2 == SHIFTROWS_SUBBYTES2) begin
            addr_key2 <= addr_key2 + 1;
        end
    end
end


always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        addr_key <= 1;
    end
    else begin
        if((state1 == MIXCOLUMNS_ADDROUNDKEY1) && state2 == LOAD_DATA2) begin
            addr_key <= addr_key2;
        end
        if(state1 == MIXCOLUMNS_ADDROUNDKEY1 && state2 == IDLE2 && datard && cnt == 1) begin
            addr_key <= addr_key2;
        end
        if(state2 == MIXCOLUMNS_ADDROUNDKEY2 && state1 == LOAD_DATA1) begin
            addr_key <= addr_key1;
        end
        if(state2 == MIXCOLUMNS_ADDROUNDKEY2 && state1 == IDLE1 && datard && cnt == 0) begin
            addr_key <= addr_key1;
        end
        if(state1 == SHIFTROWS_SUBBYTES1) begin
            addr_key <= addr_key1 + 1;
        end
        if(state2 == SHIFTROWS_SUBBYTES2) begin
            addr_key <= addr_key2 + 1;
        end
        if(state1 == IDLE1 && state2 == IDLE2) begin
            addr_key <= 1;
        end
    end
end

reg ready_new_input1, ready_new_input2;
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        ready_new_input1 <= 1;
        ready_new_input2 <= 1;
    end
    else begin
        if(state1 == IDLE1) begin
            if(datard && cnt == 0) begin
                ready_new_input1 <= 0;
            end
            else begin
                ready_new_input1 <= 1;
            end
        end

        if(state2 == IDLE2) begin
            if(datard && cnt == 1) begin
                ready_new_input2 <= 0;
            end
            else begin
                ready_new_input2 <= 1;
            end
        end
    end
end



always @(*) begin
    wen = 0;
    waddr = 0;
    raddr = 0;
    src_input = 0;
    ctvalid1 = 0;
    ctvalid2 = 0;

    if(state1 == IDLE1 && datard && cnt == 0) begin
        wen = 1;
        waddr = 0;   
    end
    if(state1 == LOAD_DATA1 && (state2 == IDLE2 || state2 == SHIFTROWS_SUBBYTES2)) begin 
        raddr = 0;
        src_input = 1;
    end
    if(state2 == IDLE2 && datard && cnt == 1) begin
        wen = 1;
        waddr = 1;
    end
    else if(state2 == LOAD_DATA2) begin
        if(state1 == SHIFTROWS_SUBBYTES1) begin
            raddr = 1;
            src_input = 1;
        end
    end

    else if(state1 == DONE1) begin
        ctvalid1 = 1;
    end
    else if(state2 == DONE2) begin
        ctvalid2 = 1;
    end
end

assign ready_new_input = ready_new_input1 | ready_new_input2;
assign ready_new_key = ((state1 == IDLE1) && (state2 == IDLE2)) ? 1 : 0;


endmodule