module SPI_data_tb();
    reg i_clk = 1'b1;
    reg i_rst;
    reg [15:0] i_data;
    reg i_we;
    wire o_data;
    wire o_cs;
    wire o_done;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_data_tb);
    end

    SPI_data spi_data(
        .i_rst          (i_rst),
        .i_clk          (i_clk),
        .i_data         (i_data),
        .i_we           (i_we),
        .o_data         (o_data),
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
        i_data <= {8'h3E, 8'h28}; 
        #30;
        i_we <= 0; #30;

        wait (o_done == 1'b1);        

        $finish;
    end
endmodule