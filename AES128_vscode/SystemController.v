module SystemController(
    input clk, rst_n,

    input done_kl,

    input ready_new_input_pc,
    input ctvalid_pc,

    input keynewinput,
    input keyrd_if,
    input datard_if,

    output reg src_sbox,
    output reg Key_rd_kl,
    output reg data_rd_pc,
    output reg readdata,
    output reg readkey,
    output reg ready_new_input,
    output ctvalid,
    output reg done
);

reg [2:0] state, next_state;
localparam IDLE = 0,
           KEY_EX_START = 1,
           KEY_EX_COM = 2,
           PCORE_START = 3,
           PCORE_COM = 4,
           DONE = 5;

//state --> next_state
reg datard_if_reg;
always @(*) begin
    case(state)
        IDLE: begin
            if(keynewinput && keyrd_if) begin
                next_state = KEY_EX_START;
            end
            else if(datard_if) begin
                next_state = PCORE_START;
                datard_if_reg = 1;
            end
            else begin
                next_state = IDLE;
            end
        end
        KEY_EX_START: begin
            next_state = KEY_EX_COM;
        end
        KEY_EX_COM: begin
            next_state = (done_kl) ? PCORE_START : KEY_EX_COM;
        end
        PCORE_START: begin
            next_state = (datard_if_reg) ? PCORE_COM : IDLE;
        end
        PCORE_COM: begin
            next_state = (ctvalid_pc) ? DONE : PCORE_COM;
        end
        DONE: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        state <= IDLE;
        datard_if_reg <= 0;
    end
    else begin
        state <= next_state;
        if(datard_if) begin
            datard_if_reg <= 1;
        end
        else if(state == DONE) begin
            datard_if_reg <= 0;
        end
    end
end

always @(*) begin
//    src_sbox = 0;
    Key_rd_kl = 0;
    data_rd_pc = 0;
    readdata = 0;
    readkey = 0;
//    ctvalid = 0;
    ready_new_input = 0;
    done = 0;

    case(state) 
        IDLE: begin
            src_sbox = 0;
            Key_rd_kl = 0;
            data_rd_pc = 0;
            readdata = 0;
            readkey = 0;
//            ctvalid = 0;
            ready_new_input = 1;
            done = 0;
        end
        KEY_EX_START: begin
            src_sbox = 0;
            Key_rd_kl = 1;
            readkey = 1;
        end
        PCORE_START: begin
            if(datard_if_reg) begin
                src_sbox = 1;
                data_rd_pc = 1;
                readdata = 1;
            end
        end
        DONE: begin
            done = 1;
        end

    endcase
end

assign ctvalid = ctvalid_pc;

endmodule