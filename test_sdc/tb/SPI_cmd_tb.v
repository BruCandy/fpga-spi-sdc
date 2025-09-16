module SPI_cmd_tb();
    reg i_clk = 1'b1;
    reg i_rst;
    reg [7:0] i_cmd;
    reg [31:0] i_arg;
    reg [7:0] i_crc;
    reg i_we;
    wire i_miso;
    wire o_mosi;
    wire o_cs;
    wire o_done;
    wire [7:0] o_res;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_cmd_tb);
    end

    SPI_cmd_sdc # () 
    spi_cmd(
        .i_rst(i_rst),
        .i_clk(i_clk),
        .i_cmd(i_cmd),
        .i_arg(i_arg),
        .i_crc(i_crc),
        .i_we(i_we),
        .i_miso(i_miso),
        .o_mosi(o_mosi),
        .o_cs(o_cs),
        .o_done(o_done),
        .o_res(o_res)
    );

    always #10 begin
        i_clk <= ~i_clk;
    end

    initial begin
        i_rst <= 1'b1; #30;
        i_rst <= 1'b0; #30;

        i_we <= 1;
        i_cmd    <= 8'h40;
        i_arg    <= 32'h0;
        i_crc    <= 8'h95;
        #30;
        i_we <= 0; #30;

        #10000;

        // wait (o_done == 1'b1);        

        $finish;
    end
endmodule