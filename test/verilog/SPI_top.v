module SPI_top(
    input  wire i_clk,
    input  wire i_rst,
    input  wire i_miso,
    output wire o_mosi,
    output wire o_cs_lcd,
    output wire o_cs_sdc,
    output wire o_dc,
    output wire o_rst,
    output wire o_clk
);

    parameter DELAY  = 2_700_000; 
    parameter WIDTH  = 240;
    parameter HEIGHT = 320;
    parameter X1     = 70;
    parameter X2     = 170;
    parameter Y1     = 110;
    parameter Y2     = 210;

    reg [2:0]  r_state = 0;
    reg        r_init_sdc_start;
    reg        r_read_sdc_start = 0;
    reg        r_init_start = 0;
    reg        r_clear_start = 0;
    reg        r_square_start = 0;
    reg [15:0] r_color = 16'hFFFF;
    reg [1:0]  r_state_clk = 2;

    wire w_init_sdc_done;
    wire w_init_sdc_mosi;
    wire w_init_sdc_cs;
    wire w_read_sdc_done;
    wire w_read_sdc_mosi;
    wire w_read_sdc_cs;
    wire [23:0] w_response;
    wire w_init_done;
    wire w_init_mosi;
    wire w_init_dc;
    wire w_init_cs;
    wire w_clear_done;
    wire w_clear_mosi;
    wire w_clear_dc;
    wire w_clear_cs;
    wire w_square_done;
    wire w_square_mosi;
    wire w_square_dc;
    wire w_square_cs;
    wire w_clk;

    assign w_rst = ~i_rst;
    assign o_rst = i_rst;
    assign o_clk = w_clk;

    assign o_mosi =     (r_state == 0) ? w_init_sdc_mosi :
                        (r_state == 1) ? w_read_sdc_mosi :
                        (r_state == 2) ? w_init_mosi : 
                        (r_state == 3) ? w_clear_mosi : 
                        (r_state == 4) ? w_square_mosi :1; 
    assign o_dc =       (r_state == 2) ? w_init_dc :
                        (r_state == 3) ? w_clear_dc :
                        (r_state == 4) ? w_square_dc : 0; 
    assign o_cs_sdc =   (r_state == 0) ? w_init_sdc_cs :
                        (r_state == 1) ? w_read_sdc_cs : 1;
    assign o_cs_lcd =   (r_state == 2) ? w_init_cs :
                        (r_state == 3) ? w_clear_cs :
                        (r_state == 4) ? w_square_cs : 1;

    SPI_clk spi_clk(
        .i_rst           (w_rst      ),
        .i_clk_27_MHz    (i_clk      ),
        .i_state         (r_state_clk),
        .o_clk           (w_clk      )
    ); 

    SPI_init_sdc spi_init_sdc(
        .i_rst      (w_rst              ),
        .i_clk      (w_clk              ),
        .i_start    (r_init_sdc_start   ),
        .i_miso     (i_miso             ),    
        .o_mosi     (w_init_sdc_mosi    ),
        .o_cs       (w_init_sdc_cs      ),
        .o_done     (w_init_sdc_done    )
    );

    SPI_read_sdc spi_read_sdc(
        .i_rst      (w_rst              ),
        .i_clk      (w_clk              ),
        .i_we       (r_read_sdc_start   ),
        .i_miso     (i_miso             ),
        .o_mosi     (w_read_sdc_mosi    ),
        .o_cs       (w_read_sdc_cs      ),
        .o_done     (w_read_sdc_done    ),
        .o_response (w_response         )
    );

    SPI_init # (
        .DELAY (DELAY)
    )spi_init(
        .i_rst      (w_rst),
        .i_clk      (w_clk),
        .i_start    (r_init_start),
        .o_mosi     (w_init_mosi),
        .o_dc       (w_init_dc),
        .o_cs       (w_init_cs),
        .o_done     (w_init_done)
    );

    SPI_clear # (
        .DELAY  (DELAY),
        .WIDTH  (WIDTH),
        .HEIGHT (HEIGHT)
    ) spi_clear(
        .i_rst      (w_rst),
        .i_clk      (w_clk),
        .i_start    (r_clear_start),
        .o_mosi     (w_clear_mosi),
        .o_dc       (w_clear_dc),
        .o_cs       (w_clear_cs),
        .o_done     (w_clear_done)
    );

    SPI_square # (
        .DELAY (DELAY),
        .X1    (X1   ),
        .X2    (X2   ),
        .Y1    (Y1   ),
        .Y2    (Y2   ) 
    ) spi_square (
        .i_rst      (w_rst),
        .i_clk      (w_clk),
        .i_start    (r_square_start),
        .i_color    (r_color),
        .o_mosi     (w_square_mosi),
        .o_dc       (w_square_dc),
        .o_cs       (w_square_cs),
        .o_done     (w_square_done)
    );

    always @(posedge i_clk or posedge w_rst) begin
        if (w_rst) begin
            r_state <= 0;
            r_state_clk <= 2;
            r_init_sdc_start <= 1;
        end else begin
            case (r_state)
                0: begin
                    r_init_sdc_start <= 0;
                    r_state_clk <= 2;
                    if (w_init_sdc_done) begin
                        r_state <= 1;
                        r_read_sdc_start <= 1;
                    end
                end
                1: begin
                    r_read_sdc_start <= 0;
                    r_state_clk <= 1;
                    if (w_read_sdc_done) begin
                        r_state <= 2;
                        r_init_start <= 1;
                        r_color <= {w_response[23:19], w_response[15:10], w_response[7:3]};
                    end
                end
                2: begin
                    r_init_start <= 0;
                    r_state_clk <= 1;
                    if (w_init_done) begin
                        r_state <= 3;
                        r_clear_start <= 1;
                    end
                end
                3: begin 
                    r_clear_start <= 0;
                    if (w_clear_done) begin
                        r_state <= 4;
                        r_square_start <= 1;
                    end 
                end
                4: begin
                    r_square_start <= 0;
                    if (w_square_done) begin
                        r_state <= 5;
                    end 
                end
                5: begin
                    // もう一度実行する場合はリセットボタンを押す
                end
            endcase
        end
    end

endmodule