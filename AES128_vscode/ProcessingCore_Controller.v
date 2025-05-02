module ProcessingCore_Controller(
    input clk, rst_n,
    input datard,
    output reg [3:0] addr_key,
    output reg ctvalid,
    output reg ready_new_input,
    output reg src_input
);

reg [2:0] state, next_state;
localparam IDLE = 0,
           LOAD_DATA = 1,
           SHIFTROWS_SUBBYTES = 2,
           MIXCOLUMNS_ADDROUNDKEY = 3,
           DONE = 4;

// state --> next_state
always @(*) begin
    case(state)
        IDLE: begin
            next_state = (datard) ? LOAD_DATA : IDLE;
        end
        LOAD_DATA: begin
            next_state = SHIFTROWS_SUBBYTES;
        end
        SHIFTROWS_SUBBYTES: begin
            next_state = MIXCOLUMNS_ADDROUNDKEY;
        end
        MIXCOLUMNS_ADDROUNDKEY: begin
            next_state = (addr_key == 10) ? DONE : SHIFTROWS_SUBBYTES; 
        end
        DONE: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

// addr_key
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        addr_key <= 4'd0;
    end
    else begin
        if(state == IDLE) begin
            addr_key <= 4'd1;
        end
        else if(state == SHIFTROWS_SUBBYTES) begin
            addr_key <= addr_key + 1;
        end
    end
end

always @(*) begin
    ctvalid = 0;
    ready_new_input = 0;
    src_input = 0;
//    addr_key = 0;
    case(state)
        IDLE: begin
            ctvalid = 0;
            ready_new_input = 1;
            src_input = 0;
//            addr_key = 0;
        end
        LOAD_DATA: begin
            src_input = 1;
        end
//        MIXCOLUMNS_ADDROUNDKEY: begin
//            addr_key = addr_key + 1;
//        end
        DONE: begin
            ctvalid = 1;
        end
        default: begin
            ctvalid = 0;
            ready_new_input = 0;
            src_input = 0;
//            addr_key = 0;
        end
    endcase
end

endmodule