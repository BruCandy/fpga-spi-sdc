module SDC_clk(
    input       i_rst,
    input       i_clk_27_MHz,
    output      o_clk_100_KHz
);

    parameter CNT_100K = 135;

    reg [9:0]  r_cnt_100k = 0;
    reg        r_clk_100k = 0;

    assign o_clk_100_KHz = r_clk_100k;

    always@(posedge i_clk_27_MHz or posedge i_rst) begin
        if (i_rst) begin
            r_cnt_100k <= 0;
            r_clk_100k <= 0;
        end else begin
            if (r_cnt_100k == (CNT_100K - 1)) begin 
                r_cnt_100k <= 0;
                r_clk_100k <= ~r_clk_100k;
            end else begin
                r_cnt_100k <= r_cnt_100k + 1'b1;
            end
        end
    end
endmodule
