module SPI_init_tb();
    reg i_clk = 1'b1;
    reg i_rst = 0;
    reg i_start = 0;
    wire i_miso;
    wire o_mosi;
    wire o_cs;
    wire o_done;
    wire o_led;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_init_tb);
    end

    SPI_init_sdc # () 
    spi_init(
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (i_start),
        .i_miso     (i_miso),
        .o_mosi     (o_mosi),
        .o_cs       (o_cs),
        .o_done     (o_done)
    );

    always #10 begin
        i_clk <= ~i_clk;
    end

    initial begin
        i_rst <= 1'b1; #10;
        i_rst <= 1'b0; #30;

        i_start <= 1; #10;
        i_start <= 0; #10;
        
        // wait (o_done == 1'b1);        
        #10000;

        $finish;
    end
endmodule
