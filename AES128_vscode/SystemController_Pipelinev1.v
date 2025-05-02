module SystemController_Pipelinev1(
    input clk, rst_n,

    input done_kl,

    input ready_new_input_pc, 
    input ready_new_key_pc,
    input ctvalid1,
    input ctvalid2,

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

localparam IDLE1 = 0,
           KEY_EX_START = 1,
           KEY_EX_COM = 2,
           PCORE_START = 3,
           LOAD_DATA1 = 4,
           PCORE_COM1 = 5,
           DONE1 = 6;

localparam IDLE2 = 0,
           LOAD_DATA2 = 1,
           PCORE_COM2 = 2,
           DONE2 = 3;

reg [3:0] state1, next_state1;
reg [3:0] state2, next_state2;

reg [1:0] cnt_data;
reg [3:0] addr_key1, addr_key2;

always @(*) begin
    case(state1) 
        IDLE1: begin
            if(keynewinput_if && keyrd_if) begin
                next_state1 = KEY_EX_START;
            end
            else if(datard_if) begin
                next_state1 = LOAD_DATA1;
            end
            else if(cnt_data != 0) begin
                next_state1 = LOAD_DATA1;
            end
            else begin
                next_state1 = IDLE1;
            end
        end
        KEY_EX_START: begin
            next_state1 = KEY_EX_COM;
        end
        KEY_EX_COM: begin
            next_state1 = (done_kl) ? PCORE_START : KEY_EX_COM;
        end
        PCORE_START: begin
            next_state1 = (cnt_data != 0) ? LOAD_DATA1 : IDLE1;
        end
        LOAD_DATA1: begin
            next_state1 = PCORE_COM1;
        end
        PCORE_COM1: begin
            next_state1 = (ctvalid1) ? DONE1 : PCORE_COM1;
        end
        DONE1: begin
            if(state2 == DONE2) begin
                next_state1 = IDLE1;
            end
            else if(datard_if) begin
                next_state1 = LOAD_DATA1;
            end
            else begin
                next_state1 = DONE1;
            end
        end
    endcase
end

always @(*) begin
    case(state2)
        IDLE2: begin
            if(state1 == LOAD_DATA1 && cnt_data == 2) begin
                next_state2 = LOAD_DATA2;
            end
            else if(state1 == LOAD_DATA1 && datard_if) begin
                next_state2 = LOAD_DATA2;
            end
            else if(state1 == PCORE_COM1 && datard_if) begin
                next_state2 = LOAD_DATA2;
            end
            else begin
                next_state2 = IDLE2;
            end
        end
        LOAD_DATA2: begin
            next_state2 = PCORE_COM2;
        end
        PCORE_COM2: begin
            next_state2 = (ctvalid2) ? DONE2 : PCORE_COM2;
        end
        DONE2: begin
            if(state1 == DONE1) begin
                next_state2 = IDLE2;
            end
            else if(datard_if) begin
                next_state2 = LOAD_DATA2;
            end
            else begin
                next_state2 = DONE2;
            end
        end
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
        cnt_data <= 0;
    end
    else begin
        if(datard_if && cnt_data != 2) begin
            cnt_data <= cnt_data + 1;
        end
        else if(addr_data == cnt_data) begin
            cnt_data <= 0;
        end

    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        addr_data <= 0;
    end
    else begin
        if(state1 == LOAD_DATA1 || state2 == LOAD_DATA2) begin
            addr_data <= addr_data + 1;
        end
        if(addr_data == cnt_data) begin
            addr_data <= 0;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        src_sbox <= 0;
    end
    else begin
        if(state1 == KEY_EX_START || state1 == KEY_EX_COM) begin
            src_sbox <= 0;
        end
        else if(state1 == PCORE_START || state1 == LOAD_DATA1 || state1 == PCORE_COM1 || state2 == IDLE2 || state2 == LOAD_DATA2 || state2 == PCORE_COM2) begin
            src_sbox <= 1;
        end
        else begin
            src_sbox <= src_sbox;
        end
    end
end

always @(*) begin
    readdata = 0;
    readkey = 0;
//    addr_data = 0;
//    src_sbox = 0;
    Key_rd_kl = 0;
    data_rd_pc = 0;

    if(state1 == KEY_EX_START) begin
        readkey = 1;
//        src_sbox = 0;
        Key_rd_kl = 1;
    end
    else if(state1 == LOAD_DATA1) begin
        readdata = 1;
//        addr_data = 0;
        data_rd_pc = 1;
    end
    else if(state2 == LOAD_DATA2) begin
        readdata = 1;
//        addr_data = 1;
        data_rd_pc = 1;
    end
    
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        ready_new_key <= 1;
    end
    else begin
        if(state1 == IDLE1 || (state1 == DONE1 && state2 == IDLE2) || (state2 == DONE2 && state1 == DONE1) ) begin
            ready_new_key <= 1;
        end
        else begin
            ready_new_key <= 0;
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        ready_new_input <= 1;
    end
    else begin
        if((state1 == IDLE1 && state2 == IDLE2) || (state1 == IDLE1 && state2 != IDLE2) || (state1 != IDLE1  && state2 == IDLE2 && cnt_data != 2) || (state1 == DONE1 && state2 == DONE2) || (state1 != DONE1 && state2 == DONE2) || (state1 == DONE1 && state2 != DONE2)) begin
            ready_new_input <= 1;
        end
        else begin
            ready_new_input <= 0;
        end
    end
end

assign ctvalid = ctvalid1 | ctvalid2;

endmodule