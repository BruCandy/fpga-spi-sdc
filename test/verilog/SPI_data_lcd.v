module SPI_data(
    input wire        i_rst,
    input wire        i_clk,
    input wire [15:0] i_data,
    input wire        i_we,
    output wire o_data,
    output wire o_cs,
    output wire o_done
);

    parameter CNT  = 16;
    parameter WAIT = 10;

    reg [2:0]   r_state = 0;
    reg [15:0]  r_data  = 0;
    reg         r_cs    = 1;
    reg [3:0]   r_cnt   = 0;
    reg [18:0]  r_wait  = 0;
    reg r_done = 0;


    assign o_data  = r_data[15];
    assign o_cs    = r_cs;
    assign o_done = r_done;


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_state <= 0;
            r_data  <= 0;
            r_cnt   <= 0;
            r_wait  <= 0;
            r_cs    <= 1;
            r_done <= 0;
        end else begin
            r_done <= 0;
            case (r_state)
                0: begin
                    if (i_we == 1) begin
                        r_cs <= 0;
                        r_data <= i_data;
                        r_cnt  <= 0;
                        r_wait <= 0;
                        r_state <= 1;
                    end
                end
                1: begin
                    if (r_cnt == CNT-1) begin
                        r_data <= {r_data[14:0], 1'b0};
                        r_cnt <= 0;
                        r_cs <= 1;
                        r_state <= 2;
                    end else begin
                        r_cnt <= r_cnt + 1'b1;
                        r_data <= {r_data[14:0], 1'b0};
                    end
                end
                2: begin
                    if (r_wait == WAIT-1) begin
                        r_wait <= 0;
                        r_state <= 3;
                    end else begin
                        r_wait <= r_wait + 1'b1;
                    end
                end
                3: begin
                    r_state <= 0;
                    r_done <= 1;
                end
            endcase
        end
    end
        
endmodule