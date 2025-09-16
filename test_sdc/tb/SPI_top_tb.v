module SPI_top_tb();
    reg i_clk = 1'b1;
    reg i_rst = 0;
    wire o_mosi;
    wire i_miso;
    wire o_cs;
    wire o_clk;
    wire o_led;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_top_tb);
    end

    SPI_top # () 
    spi_top (
        .i_clk  (i_clk  ),
        .i_rst  (i_rst  ),
        .i_miso (i_miso ),
        .o_mosi (o_mosi ),
        .o_cs   (o_cs   ),
        .o_clk  (o_clk  ),
        .o_led  (o_led  )
    );

    always #10 begin
        i_clk <= ~i_clk;
    end

    initial begin
        #10000;
        i_rst <= 1'b0; #100;
        i_rst <= 1'b1; #10;
         
        #2000000;
        i_rst <= 1'b0; #1000;
        i_rst <= 1'b1; #10;
         
        #2000000;

        $finish;
    end
endmodule