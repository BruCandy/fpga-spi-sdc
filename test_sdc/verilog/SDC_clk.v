module SPI_clk(
    input       i_rst,
    input       i_clk_27_MHz,
    output      o_clk_100_KHz
);

    parameter CNT_100K = 135;
    // parameter GAP_100K = 540;

    reg [9:0]  r_cnt_100k = 0;
    reg        r_clk_100k = 0;
    // reg [4:0]  r_edge_cnt = 0;
    // reg [9:0]  r_gap_cnt  = 0;

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
    // always@(posedge i_clk_27_MHz or posedge i_rst) begin
    //     if (i_rst) begin
    //         r_cnt_100k <= 0;
    //         r_clk_100k <= 0;
    //         r_edge_cnt <= 0;
    //     end else begin
    //         if (r_edge_cnt < 16) begin
    //             if (r_cnt_100k == (CNT_100K - 1)) begin 
    //                 r_cnt_100k <= 0;
    //                 r_clk_100k <= ~r_clk_100k;
    //                 r_edge_cnt <= r_edge_cnt + 1'b1;
    //             end else begin
    //                 r_cnt_100k <= r_cnt_100k + 1'b1;
    //             end
    //         end else begin
    //             r_clk_100k <= 0;
    //             if (r_gap_cnt == GAP_100K - 1) begin
    //                 r_gap_cnt <= 0;
    //                 r_edge_cnt <= 0;
    //             end else begin
    //                 r_gap_cnt <= r_gap_cnt + 1'b1;
    //             end
    //         end
    //     end
    // end
endmodule