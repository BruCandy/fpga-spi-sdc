module SDC_top(
    input  wire i_clk,
    input  wire i_rst,
    input  wire i_miso,
    output wire o_mosi,
    output wire o_cs,
    output wire o_clk,
    output wire o_res
);

    reg [2:0]  r_state = 0;
    reg        r_init_sdc_start = 0;

    wire w_init_sdc_done;
    wire w_init_sdc_mosi;
    wire w_init_sdc_cs;
    wire w_sck_state;

    wire w_clk_100_KHz;

    assign w_rst = ~i_rst;
    assign o_clk = w_sck_state ? w_clk_100_KHz : 1'b0;

    assign o_mosi   =  w_sck_state ? w_init_sdc_mosi : 1'b0;
    assign o_cs     =  w_init_sdc_cs;

    SDC_clk sdc_clk(
        .i_rst            (w_rst            ),
        .i_clk_27_MHz     (i_clk            ),
        .o_clk_100_KHz    (w_clk_100_KHz    )
    );

    SDC_init sdc_init(
        .i_rst      (w_rst              ),
        .i_clk      (w_clk_100_KHz      ),
        .i_start    (r_init_sdc_start   ), 
        .i_miso     (i_miso             ),  
        .o_mosi     (w_init_sdc_mosi    ),
        .o_cs       (w_init_sdc_cs      ),
        .o_done     (w_init_sdc_done    ),
        .o_sck_state (w_sck_state       ),
        .o_res (o_res)
    );

    always @(posedge w_clk_100_KHz or posedge w_rst) begin
        if (w_rst) begin
            r_state <= 0;
            r_init_sdc_start <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_init_sdc_start <= 1;
                    r_state <= 1;
                end
                1: begin
                    r_init_sdc_start <= 0;
                    if (w_init_sdc_done) begin
                        r_state <= 2;
                    end
                end
            endcase
        end
    end

endmodule