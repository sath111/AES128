module SystemController_Pipeline(
    input clk, rst_n,

    input done_kl,

    input ready_new_input_pc, 
    input ready_new_key_pc,
    input ctvalid_pc,

    input keynewinput_if,
    input keyrd_if,
    input datard_if,
    output reg readdata,
    output reg [1:0] addr_data,
    output reg readkey,

    output reg ready_new_input,
    output reg ready_new_key,
    output ctvalid,

    output reg src_sbox,
    output reg Key_rd_kl,
    output reg data_rd_pc
);


reg [2:0] state, next_state;
localparam IDLE = 0,
           KEY_EX_START = 1,
           KEY_EX_COM = 2,
           PCORE_START = 3,
           LOAD_DATA = 4,
           PCORE_COM = 5,
           DONE = 6;

always @(*) begin
    case(state)
        IDLE: begin
            if(keynewinput_if && keyrd_if) begin
                next_state = KEY_EX_START;
            end
            else if(cnt_data != 0)begin
                next_state = LOAD_DATA;
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
            next_state = (cnt_data != 0) ? LOAD_DATA : IDLE;
        end
        LOAD_DATA: begin
            next_state = (cnt_data == addr_data) ? PCORE_COM : LOAD_DATA;
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
    end
    else begin
        state <= next_state;
    end
end

reg [1:0] cnt_data;
always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        cnt_data <= 0;
    end
    else begin
        if(datard_if) begin
            if(cnt_data < 2) begin
                cnt_data <= cnt_data + 1;
            end
        end
        if(state == DONE) begin
            cnt_data <= 0;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        addr_data <= 0;
    end
    else begin
        if(state == LOAD_DATA) begin
            if(addr_data != cnt_data) begin
                addr_data <= addr_data + 1;
            end
        end
        if(state == IDLE) begin
            addr_data <= 0;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        src_sbox <= 0;
    end
    else begin
        if(state == KEY_EX_START || state == IDLE) begin
            src_sbox <= 0;
        end
        else if(state == PCORE_START) begin
            src_sbox <= 1;
        end
        else begin
            src_sbox <= src_sbox;
        end
    end
end

always @(*) begin
    Key_rd_kl = 0;
    readdata = 0;
    readkey = 0;
//    ctvalid = 0;
    data_rd_pc = 0;

    case(state)
        KEY_EX_START: begin
            Key_rd_kl = 1;
            readkey = 1;
//            src_sbox = 0;
        end
        LOAD_DATA: begin
//            src_sbox = 1;
            if(addr_data != cnt_data) begin
                data_rd_pc = 1;
                readdata = 1;
            end
        end
        DONE: begin
            
        end
    endcase
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        ready_new_input <= 1;
        ready_new_key <= 1;
    end
    else begin
        if(state == KEY_EX_START || state == KEY_EX_COM  || state == LOAD_DATA || state == PCORE_COM) begin
            ready_new_key <= 0;
        end
        if(state == IDLE || state == DONE) begin
            ready_new_key <= 1;
        end
        if(cnt_data == 2 || state == PCORE_START || state == LOAD_DATA || state == PCORE_COM) begin
            ready_new_input <= 0;
        end
        if((state == IDLE || state == DONE || state == KEY_EX_START || state == KEY_EX_COM) && cnt_data != 2 ) begin
            ready_new_input <= 1;
        end
    end
end

assign ctvalid = ctvalid_pc;

endmodule