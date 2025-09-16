module SPI_read_sdc(
    input wire         i_rst,
    input wire         i_clk,
    input wire         i_we,
    input wire         i_miso,
    output wire        o_mosi,
    output wire        o_cs,
    output wire        o_done,
    output wire [23:0] o_response
);

    parameter CNT_SEN = 48;
    parameter CNT_RES = 24;
    parameter WAIT    = 2_700;
    parameter SECTOR  = 16400;

    reg [2:0]   r_state    = 0;
    reg [47:0]  r_data;
    reg         r_cs       = 1;
    reg [5:0]   r_cnt      = 0;
    reg [11:0]  r_wait     = 0;
    reg [7:0]   r_token    = 8'hFF;
    reg         r_done     = 0;
    reg [23:0] r_response;
    reg [10:0]   r_cnt_res  = 0;

    wire [7:0] sector_byte3 = (SECTOR >> 24) & 8'hFF;
    wire [7:0] sector_byte2 = (SECTOR >> 16) & 8'hFF;
    wire [7:0] sector_byte1 = (SECTOR >> 8)  & 8'hFF;
    wire [7:0] sector_byte0 = SECTOR & 8'hFF;



    assign o_mosi  = r_data[47];
    assign o_cs    = r_cs;
    assign o_done = r_done;
    assign o_response = r_response;


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_state <= 0;
            r_data  <= {8'h51, sector_byte3, sector_byte2, sector_byte1, sector_byte0, 8'hFF};
            r_cnt   <= 0;
            r_wait  <= 0;
            r_cs    <= 1;
            r_response <= 8'hFF;
            r_done  <= 0;
            r_cnt_res <= 0;
        end else begin
            r_done <= 0;
            case (r_state)
                0: begin
                    if (i_we == 1) begin
                        r_cs <= 1;
                        r_cnt  <= 0;
                        r_wait <= 0;
                        r_state <= 1;
                    end
                end
                1: begin
                    if (r_wait == WAIT-1) begin
                        r_wait  <= 0;
                        r_cs    <= 0;
                        r_state <= 2;
                    end else begin
                        r_wait <= r_wait + 1'b1;
                    end
                end
                2: begin
                    if (r_cnt == CNT_SEN-1) begin
                        r_data <= {r_data[46:0], 1'b0};
                        r_cnt <= 0;
                        r_state <= 3;
                    end else begin
                        r_cnt <= r_cnt + 1'b1;
                        r_data <= {r_data[46:0], 1'b0};
                    end
                end
                3: begin
                    r_token <= {r_token[6:0], i_miso};
                    if ({r_token[6:0], i_miso} == 8'hFE) begin
                        r_state <= 4;
                    end
                end
                4: begin 
                    if (r_cnt_res == CNT_RES - 1) begin
                        r_cnt_res <= 0;
                        r_done <= 1;
                    end else begin 
                        r_response <= {r_response[22:0], i_miso};
                        r_cnt_res <= r_cnt_res + 1'b1;
                    end
                end
            endcase
        end
    end
        
endmodule