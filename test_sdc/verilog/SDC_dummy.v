module SDC_dummy(
    input wire        i_rst,
    input wire        i_clk,
    input wire        i_we,
    output wire       o_mosi,
    output wire       o_cs,
    output wire       o_done,
    output wire       o_sck_state
);

    parameter WAIT = 8;
    parameter CNT  = 10;

    reg [2:0]   r_state = 0;
    reg [3:0]   r_wait = 0;
    reg [3:0]   r_cnt   = 0;
    reg         r_done  = 0;
    reg         r_sck_state = 0;



    assign o_mosi   = 1'b1;
    assign o_cs     = (r_state == 0) ? 1'b1 :
                      (r_state == 1) ? 1'b1 : 
                      (r_state == 2) ? 1'b1 :
                      (r_state == 3) ? 1'b1 : 1'b0;
    assign o_done   = r_done;
    assign o_sck_state = r_sck_state;


    always @(negedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_state <= 0;
            r_wait  <= 0;
            r_cnt   <= 0;
            r_done  <= 0;
            r_sck_state <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_done <= 0;
                    r_sck_state <= 0;
                    if (i_we == 1) begin
                        r_state <= 1;
                        r_sck_state <= 1;
                    end
                end
                1: begin
                    r_wait <= r_wait + 1'b1;
                    if (r_wait == WAIT - 1) begin
                        r_wait   <= 0;
                        r_state <= 2; 
                        r_sck_state <= 0; 
                    end 
                end
                2: begin
                    r_state <= 3;
                end
                3: begin
                    if (r_cnt == CNT - 1) begin
                        r_state <= 4;
                        r_cnt   <= 0;
                        r_sck_state <= 0;
                    end else begin
                        r_state <= 1;
                        r_cnt   <= r_cnt + 1'b1;
                        r_sck_state <= 1;
                    end
                end
                4: begin
                    // r_done <= 1;
                    r_state <= 5;
                end
                5: begin 
                    r_state <= 6;
                end
                6: begin
                    r_state <= 0;
                    r_done <= 1;
                end
            endcase
        end
    end
endmodule