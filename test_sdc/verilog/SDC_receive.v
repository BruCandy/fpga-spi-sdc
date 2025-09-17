module SDC_receive(
    input wire        i_rst,
    input wire        i_clk,
    input wire        i_we,
    input wire        i_miso,
    output wire       o_done,
    output wire       o_sck_state,
    output wire [7:0] o_res
);

    parameter CNT = 8;

    reg [2:0]   r_state = 0;
    reg [3:0]   r_cnt   = 0;
    reg [7:0]   r_res   = 8'hFF;
    reg         r_done  = 0;
    reg         r_sck_state = 0;

    assign o_done       = r_done;
    assign o_res        = r_res;
    assign o_sck_state  = r_sck_state;

    always @(negedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_state <= 0;
            r_cnt  <= 0;
            r_res   <= 8'hFF;
            r_done  <= 0;
            r_sck_state <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_done <= 0;
                    r_res  <= 8'hFF;
                    r_sck_state <= 0;
                    if (i_we == 1) begin
                        r_cnt <= 0;
                        r_res   <= 8'hFF;
                        r_sck_state <= 1;
                        r_state <= 1;
                    end
                end
                1: begin
                    r_res <= {r_res[6:0], i_miso};
                    r_cnt <= r_cnt + 1'b1;
                    if (r_cnt == CNT-1) begin
                        r_cnt   <= 0;
                        r_sck_state <= 0;
                        r_state <= 2;  
                    end
                end
                2: begin
                    r_done <= 1;
                    r_state <= 0;
                end
            endcase
        end
    end
endmodule