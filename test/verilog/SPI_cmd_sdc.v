module SPI_cmd_sdc(
    input wire        i_rst,
    input wire        i_clk,
    input wire [7:0]  i_cmd,
    input wire [31:0] i_arg,
    input wire [7:0]  i_crc,
    input wire        i_we,
    input wire        i_miso,
    output wire       o_mosi,
    output wire       o_cs,
    output wire       o_done,
    output wire [7:0] o_response
);

    parameter CNT  = 48;
    parameter WAIT = 10;

    reg [2:0]   r_state    = 0;
    reg [47:0]  r_data     = 0;
    reg         r_cs       = 1;
    reg [5:0]   r_cnt      = 0;
    reg [18:0]  r_wait     = 0;
    reg [7:0]   r_response = 8'hFF;
    reg         r_done     = 0;
    reg [7:0] tmp_response;



    assign o_mosi  = r_data[47];
    assign o_cs    = r_cs;
    assign o_done = r_done;
    assign o_response = r_response;


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_state <= 0;
            r_data  <= 0;
            r_cnt   <= 0;
            r_wait  <= 0;
            r_cs    <= 1;
            r_response <= 8'hFF;
            r_done  <= 0;
        end else begin
            r_done <= 0;
            case (r_state)
                0: begin
                    if (i_we == 1) begin
                        r_cs <= 0;
                        r_data <= {i_cmd, i_arg, i_crc};
                        r_cnt  <= 0;
                        r_wait <= 0;
                        r_state <= 1;
                    end
                end
                1: begin
                    if (r_cnt == CNT-1) begin
                        r_data <= {r_data[46:0], 1'b0};
                        r_cnt <= 0;
                        r_state <= 2;
                    end else begin
                        r_cnt <= r_cnt + 1'b1;
                        r_data <= {r_data[46:0], 1'b0};
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
                    tmp_response <= {r_response[6:0], i_miso};
                    r_response <= tmp_response;
                    if (tmp_response[7] == 1'b0) begin
                        r_cs <= 1;
                        r_done <= 1;
                        r_state <= 0;
                    end
                end
            endcase
        end
    end
        
endmodule