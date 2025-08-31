module SPI_init_sdc (
    input wire        i_rst,
    input wire        i_clk,
    input wire        i_start,
    input wire        i_miso,
    output wire       o_mosi,
    output wire       o_cs,
    output wire       o_done
);

    parameter CNT = 1_350_000;

    reg [3:0]  r_state   = 0;
    reg        r_we_cmd  = 0;
    reg [7:0]  r_cmd = 8'hff;
    reg [31:0] r_arg = 32'hffffffff;
    reg [7:0]  r_crc = 8'hff;
    reg        r_done = 0;
    reg [21:0] r_cnt = 0;

    wire       w_done_cmd;
    wire [7:0] w_response;


    SPI_cmd_sdc spi_cmd_sdc (
        .i_rst       (i_rst),
        .i_clk       (i_clk),
        .i_cmd       (r_cmd),
        .i_arg       (r_arg),
        .i_crc       (r_crc),
        .i_we        (r_we_cmd),
        .i_miso      (i_miso),
        .o_mosi      (o_mosi),
        .o_cs        (o_cs),
        .o_done      (w_done_cmd),
        .o_response  (w_response)
    );

    assign o_done = r_done;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state     <= 0;
            r_we_cmd    <= 0;
            r_cmd       <= 8'hff;
            r_arg       <= 32'hffffffff;
            r_crc       <= 8'hff;
            r_done      <= 0;
            r_cnt       <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_we_cmd <= 0;
                    r_done   <= 0;
                    r_cnt    <= 0; 
                    if (i_start) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h40;
                        r_arg    <= 32'h0;
                        r_crc    <= 8'h95;
                        r_state  <= 1;
                    end
                end
                1: begin
                    r_we_cmd <= 0;
                    if (w_done_cmd && w_response == 8'h01) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h48;
                        r_arg    <= 32'h000001AA;
                        r_crc    <= 8'h87;
                        r_state  <= 2;
                    end
                end
                2: begin
                    r_we_cmd <= 0;
                    if (w_done_cmd) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h77;
                        r_arg    <= 32'h0;
                        r_crc    <= 8'h0;
                        r_state  <= 3;
                    end
                end
                3: begin
                    r_we_cmd    <= 0;
                    if (w_done_cmd) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h69;
                        r_arg    <= 32'h40000000;
                        r_crc    <= 8'h0;
                        r_state  <= 4;
                    end
                end
                4: begin
                    r_we_cmd <= 0;
                    if (w_done_cmd && w_response == 8'h00) begin
                        r_state <= 6;
                    end else if (w_done_cmd) begin
                        r_state <= 5;
                    end
                end
                5: begin
                    r_we_cmd <= 0;
                    if (r_cnt == (CNT - 1)) begin
                        r_cnt   <= 0;
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h77;
                        r_arg    <= 32'h0;
                        r_crc    <= 8'h0;
                        r_state  <= 3;
                    end else begin
                        r_cnt <= r_cnt + 1'b1;
                    end
                end
                6: begin  // 初期化完了
                    r_state <= 0;
                    r_done <= 1;
                end
            endcase
        end
    end

endmodule