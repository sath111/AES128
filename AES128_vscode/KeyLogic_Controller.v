module KeyLogic_Controller (
    input clk, rst_n,
    input Key_rd,
    input [3:0] addr_key,

    output reg done,
    output reg mode,
    output reg [3:0] round,
    output reg [3:0] raddr,
    output reg [3:0] waddr,
    output reg wen,
    output reg src_rf
);

reg [2:0] state, next_state;
localparam IDLE = 0,
           LOAD_KEY = 1,
           ROTWORD_SUBWORD = 2,
           XORR_WRITE_RF = 3,
           DONE = 4;

// State transition
always @(*) begin
    case(state)
        IDLE: begin
            next_state = (Key_rd) ? ROTWORD_SUBWORD : IDLE;
        end
        LOAD_KEY: begin
            next_state = ROTWORD_SUBWORD;
        end
        ROTWORD_SUBWORD: begin
            next_state = XORR_WRITE_RF;
        end
        XORR_WRITE_RF: begin
            next_state = (waddr == 10) ? DONE : ROTWORD_SUBWORD;
        end
        DONE: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

// State register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

// Output logic

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        done <= 0;
        mode <= 0;
        wen <= 0;
        src_rf <= 0;
        round <= 0;
        raddr <= 0;
        waddr <= 0;
    end else begin
        // default values
        done <= 0;
        mode <= 0;
        wen <= 0;
        src_rf <= 0;

        case (state)
            IDLE: begin
                raddr <= addr_key;
                src_rf <= (Key_rd) ? 1 : 0;
                wen <= (Key_rd) ? 1 : 0;
                waddr <= 0;
                round <= 0;
            end

            LOAD_KEY: begin
                waddr <= 0;
                round <= 0;
                raddr <= 0;
//                wen <= 1;
//                src_rf <= 1;
            end

            ROTWORD_SUBWORD: begin
                raddr <= waddr;
            end

            XORR_WRITE_RF: begin
                wen <= 1;
                waddr <= waddr + 1;
                round <= round + 1;
            end

            DONE: begin
                done <= 1;
            end

            default: begin
                // giữ các giá trị
            end
        endcase
    end
end


endmodule