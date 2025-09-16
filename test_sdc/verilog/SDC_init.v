module SPI_init_sdc (
    input wire        i_rst,
    input wire        i_clk,
    input wire        i_start,
    input wire        i_miso,
    output wire       o_mosi,
    output wire       o_cs,
    output wire       o_done,
    output wire       o_led,
    output wire       o_sck_state
);

    parameter WAIT = 7;

    reg [3:0]  r_state   = 0;
    reg        r_we_dummy = 0;
    reg        r_we_cmd  = 0;
    reg [7:0]  r_cmd = 8'hff;
    reg [31:0] r_arg = 32'hffffffff;
    reg [7:0]  r_crc = 8'hff;
    reg        r_done = 0;
    reg [21:0] r_cnt = 0;
    reg        r_led = 0;
    reg [4:0]  r_wait = 0;

    wire       w_done_dummy;
    wire       w_done_cmd;
    wire       w_mosi_dummy;
    wire       w_mosi_cmd;
    wire       w_cs_dummy;
    wire       w_cs_cmd;
    wire [7:0] w_res;
    wire       w_sck_state_dummy;
    wire       w_sck_state_cmd;

    SPI_dummy spi_dummy (
        .i_rst (i_rst),
        .i_clk (i_clk),
        .i_we  (r_we_dummy),
        .o_mosi(w_mosi_dummy),
        .o_cs  (w_cs_dummy),
        .o_done(w_done_dummy),
        .o_sck_state(w_sck_state_dummy)
    );

   SPI_cmd_sdc spi_cmd_sdc (
       .i_rst       (i_rst),
       .i_clk       (i_clk),
       .i_cmd       (r_cmd),
       .i_arg       (r_arg),
       .i_crc       (r_crc),
       .i_we        (r_we_cmd),
       .i_miso      (i_miso),
       .o_mosi      (w_mosi_cmd),
       .o_cs        (w_cs_cmd),
       .o_done      (w_done_cmd),
       .o_res       (w_res),
       .o_sck_state (w_sck_state_cmd)
   );

    assign o_done = r_done;
    assign o_led  = r_led;
    assign o_mosi = (r_state == 0) ? w_mosi_dummy :
                    (r_state == 1) ? w_mosi_dummy : 
                    (r_state == 2) ? w_mosi_dummy : w_mosi_cmd;
    assign o_cs =   (r_state == 0) ? w_cs_dummy :
                    (r_state == 1) ? w_cs_dummy : w_cs_cmd;
    assign o_sck_state = (r_state <= 2) ? w_sck_state_dummy : w_sck_state_cmd;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state     <= 0;
            r_we_cmd    <= 0;
            r_cmd       <= 8'hff;
            r_arg       <= 32'hffffffff;
            r_crc       <= 8'hff;
            r_done      <= 0;
            r_cnt       <= 0;
            r_led       <= 0;
            r_wait      <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_done   <= 0;
                    if (i_start) begin
                        r_state <= 1;
                    end
                end
                1: begin
                    r_wait <= r_wait + 1'b1;
                    if (r_wait == WAIT - 1) begin
                        r_wait <= 0;
                        r_we_dummy <= 1;
                        r_state <= 2;
                    end
                end
                2: begin
                    r_we_dummy <= 0;
                    if (w_done_dummy) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h40;
                        r_arg    <= 32'h0;
                        r_crc    <= 8'h95;
                        r_state  <= 3;
                    end
                end
                3: begin
                    r_we_cmd <= 0;
                    r_led <= 1;
                    if (w_res == 8'h01) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h48;
                        r_arg    <= 32'h000001AA;
                        r_crc    <= 8'h87;
                        r_led <= 1;
                        r_state  <= 4;
                    end
                end
                4: begin
                    r_we_cmd <= 0;
                    if (w_res == 8'h01) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h77;
                        r_arg    <= 32'h0;
                        r_crc    <= 8'h0;
                        r_state  <= 5;
                    end
                end
                5: begin
                    r_we_cmd    <= 0;
                    if (w_done_cmd == 1) begin
                        r_we_cmd <= 1;
                        r_cmd    <= 8'h69;
                        r_arg    <= 32'h40000000;
                        r_crc    <= 8'h0;
                        r_state  <= 6;
                    end
                end
                6: begin
                    r_we_cmd <= 0;
                    if (w_res == 8'h00) begin
                        r_state <= 7;
                    end else if (w_done_cmd) begin
                        r_state <= 5;
                    end
                end
                7: begin
                    r_we_cmd <= 1;
                    r_cmd    <= 8'h77;
                    r_arg    <= 32'h0;
                    r_crc    <= 8'h0;
                    r_state  <= 5;
                end
                8: begin  // 初期化完了
                    r_state <= 0;
                    r_done <= 1;
                end
            endcase
        end
    end

endmodule