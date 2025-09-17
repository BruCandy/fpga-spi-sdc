module SDC_cmd(
    input wire        i_rst,
    input wire        i_clk,
    input wire [7:0]  i_cmd,
    input wire [31:0] i_arg,
    input wire [7:0]  i_crc,
    input wire        i_we,
    output wire       o_mosi,
    output wire       o_cs,
    output wire       o_done,
    output wire       o_sck_state
);

    parameter WAIT  = 8;
    parameter CNT   = 6;

    reg [2:0]   r_state = 0;
    reg [47:0]  r_data  = 0;
    reg         r_cs    = 1;
    reg [3:0]   r_wait  = 0;
    reg [3:0]   r_cnt   = 0;
    reg [7:0]   r_res   = 8'hFF;
    reg [2:0]   r_rcnt  = 0;
    reg         r_done  = 0;
    reg         r_sck_state = 0;



    assign o_mosi       = r_data[47];
    assign o_cs         = r_cs;
    assign o_done       = r_done;
    assign o_sck_state  = r_sck_state;


    always @(negedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_state <= 0;
            r_wait   <= 0;
            r_rcnt  <= 0;
            r_cs    <= 1;
            r_res   <= 8'hFF;
            r_done  <= 0;
            r_sck_state <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_done <= 0;
                    r_data <= 0;
                    r_sck_state <= 0;
                    if (i_we == 1) begin
                        r_cs    <= 0;
                        r_data  <= {i_cmd, i_arg, i_crc};
                        r_wait   <= 0;
                        r_state <= 1;
                        r_sck_state <= 1;
                    end
                end
                1: begin
                    r_data <= {r_data[46:0], 1'b0};
                    r_wait <= r_wait + 1'b1;
                    if (r_wait == WAIT-1) begin
                        r_wait   <= 0;
                        r_rcnt  <= 0;
                        r_res   <= 8'hFF;
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
                    r_done <= 1;
                    r_state <= 0;
                end
            endcase
        end
    end
endmodule