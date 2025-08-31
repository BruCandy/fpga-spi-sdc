module SPI_init (
    input wire i_rst,
    input wire i_clk,
    input wire i_start,
    output wire o_mosi,
    output wire o_dc,
    output wire o_cs,
    output wire o_done
);

    parameter SWREST     = 8'h01;
    parameter SLPOUT     = 8'h11;
    parameter DISPLAY_ON = 8'h29;
    parameter MADCTL     = 8'h36;
    parameter PIXFMT     = 8'h3A;
    parameter PWCTR1     = 8'hC0;
    parameter PWCTR2     = 8'hC1;
    parameter VMCTR1     = 8'hC5;
    parameter VMCTR2     = 8'hC7;

    reg [3:0]  r_state   = 0;
    reg        r_we_cmd  = 0;
    reg        r_we_data = 0;
    reg [7:0]  r_cmd;
    reg [15:0] r_data;
    reg        r_dc = 0;
    reg        r_done = 0;
    reg        r_need_delay = 0;

    wire w_done_cmd;
    wire w_done_data;
    wire o_cmd;
    wire o_data;
    wire o_cs_cmd;
    wire o_cs_data;

    parameter DELAY = 2_700_000; 


    SPI_cmd # (
        .DELAY (DELAY)
    ) spi_cmd (
        .i_rst          (i_rst       ),
        .i_clk          (i_clk       ),
        .i_cmd          (r_cmd       ),
        .i_we           (r_we_cmd    ),
        .i_need_delay   (r_need_delay),
        .o_cmd          (o_cmd       ),
        .o_cs           (o_cs_cmd    ),
        .o_done         (w_done_cmd  )
    );

    SPI_data spi_data (
        .i_rst          (i_rst      ),
        .i_clk          (i_clk      ),
        .i_data         (r_data     ),
        .i_we           (r_we_data  ),
        .o_data         (o_data     ),
        .o_cs           (o_cs_data  ),
        .o_done         (w_done_data)
    );

    assign o_dc = r_dc;
    assign o_done = r_done;
    assign o_mosi = r_dc ? o_data : o_cmd;
    assign o_cs   = r_dc ? o_cs_data : o_cs_cmd;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state   <= 0;
            r_done    <= 0;
            r_we_cmd  <= 0;
            r_we_data <= 0;
            r_need_delay <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_we_cmd     <= 0;
                    r_we_data    <= 0;
                    r_need_delay <= 0;
                    r_done       <= 0;
                    if (i_start) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 1;
                        r_cmd        <= SWREST;
                        r_state      <= 1;
                    end
                end
                1: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 0;
                        r_cmd        <= PWCTR1;
                        r_state      <= 2;
                    end
                end
                2: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc        <= 1;
                        r_we_cmd    <= 0;
                        r_we_data   <= 1;
                        r_data      <= {8'b0, 8'h23};
                        r_state     <= 3;
                    end
                end
                3: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_data) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 0;
                        r_cmd        <= PWCTR2;
                        r_state      <= 4;
                    end
                end
                4: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc        <= 1;
                        r_we_cmd    <= 0;
                        r_we_data   <= 1;
                        r_data      <= {8'b0, 8'h10};
                        r_state     <= 5;
                    end
                end
                5: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_data) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 0;
                        r_cmd        <= VMCTR1;
                        r_state      <= 6;
                    end
                end
                6: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc        <= 1;    
                        r_we_cmd    <= 0;
                        r_we_data   <= 1;
                        r_data      <= {8'h3E, 8'h28};
                        r_state     <= 7;
                    end
                end
                7: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_data) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 0;
                        r_cmd        <= VMCTR2;
                        r_state      <= 8;
                    end
                end
                8: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc        <= 1;
                        r_we_cmd    <= 0;
                        r_we_data   <= 1;
                        r_data      <= {8'b0, 8'h86};
                        r_state     <= 9;
                    end
                end 
                9: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_data) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 0;
                        r_cmd        <= MADCTL;
                        r_state      <= 10;
                    end
                end
                10: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc        <= 1;
                        r_we_cmd    <= 0;
                        r_we_data   <= 1;
                        r_data      <= {8'b0, 8'h88};
                        r_state     <= 11;
                    end
                end
                11: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_data) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 0;
                        r_cmd        <= PIXFMT;
                        r_state      <= 12;
                    end
                end
                12: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc        <= 1;
                        r_we_cmd    <= 0;
                        r_we_data   <= 1;
                        r_data      <= {8'b0, 8'h55};
                        r_state     <= 13;
                    end
                end
                13: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_data) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 1;
                        r_cmd        <= SLPOUT;
                        r_state      <= 14;
                    end
                end
                14:  begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_dc         <= 0;
                        r_we_cmd     <= 1;
                        r_we_data    <= 0;
                        r_need_delay <= 1;
                        r_cmd        <= DISPLAY_ON;
                        r_state      <= 15;
                    end
                end
                15: begin
                    r_we_cmd    <= 0;
                    r_we_data   <= 0;
                    if (w_done_cmd) begin
                        r_done  <= 1;
                        r_state <= 0;
                    end
                end
            endcase
        end
    end

endmodule