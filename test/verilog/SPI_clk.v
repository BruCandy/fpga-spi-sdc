module SPI_clk(
    input       i_rst,
    input       i_clk_27_MHz,
    input [1:0] i_state,
    output      o_clk
);

    parameter CNT = 270;

    reg       r_div = 0;
    reg [9:0] r_cnt = 0;
    reg       r_sck = 0;

    wire w_clk_13_5_MHz = r_div;
    wire w_clk_100_kHz = r_sck;

    assign o_clk = (i_state == 0) ? i_clk_27_MHz :
                   (i_state == 1) ? w_clk_13_5_MHz : w_clk_100_kHz; 

    always@(posedge i_clk_27_MHz or posedge i_rst) begin
        if (i_rst)
            r_div <= 0;
        else
            r_div <= ~r_div;
    end

    always@(posedge i_clk_27_MHz or posedge i_rst) begin
        if (i_rst) begin
            r_cnt <= 0;
            r_sck <= 0;
        end else if (r_cnt == (CNT / 2 - 1)) begin 
            r_cnt <= 0;
            r_sck <= ~r_sck;
        end else begin
            r_cnt <= r_cnt + 1'b1;
        end
    end
endmodule