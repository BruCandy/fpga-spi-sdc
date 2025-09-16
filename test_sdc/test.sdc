create_clock -name i_clk -period 37.037 -waveform {0 18.518} [get_ports {i_clk}]
create_generated_clock -name o_clk -source [get_ports {i_clk}] [get_ports {o_clk}] -divide_by 2
