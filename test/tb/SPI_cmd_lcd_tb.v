module SPI_cmd_tb();
    reg i_clk = 1'b1;
    reg i_rst;
    reg [7:0] i_cmd;
    reg i_we;
    reg i_need_delay = 1;
    wire o_cmd;
    wire o_cs;
    wire o_done;

    parameter PIXFMT = 8'h3A;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_cmd_tb);
    end

    SPI_cmd # (
        .DELAY (20)
    ) spi_cmd(
        .i_rst          (i_rst),
        .i_clk          (i_clk),
        .i_cmd          (i_cmd),
        .i_we           (i_we),
        .i_need_delay   (i_need_delay),
        .o_cmd          (o_cmd),
        .o_cs           (o_cs),
        .o_done         (o_done)
    );

    always #10 begin
        i_clk <= ~i_clk;
    end

    initial begin
        i_rst <= 1'b1; #30;
        i_rst <= 1'b0; #30;

        i_we <= 1;
        i_cmd <= PIXFMT; 
        #30;
        i_we <= 0; #30;

        wait (o_done == 1'b1);        

        $finish;
    end
endmodule