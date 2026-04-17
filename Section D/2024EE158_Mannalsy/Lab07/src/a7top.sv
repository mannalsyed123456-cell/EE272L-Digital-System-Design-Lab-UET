module a7top
(
    input  logic [15:0] switch,
    input  logic [4:0]  push_button,
    input  logic        clk,
    output logic [15:0] led,
    output logic [7:0]  an,
    output logic [6:0]  abcdefg,
    output logic [7:0]  pmod_a
);

top_btn_parser i1 (.clk(clk), 
                   .rst(push_button[0]), 
                   .async_signal(push_button[1]), 
                   .edge_detect_pulse(pmod_a[0]),
                   .sig_in(pmod_a[1]),
                   .mod_clk(pmod_a[2]),
                   .async_sig_out(pmod_a[3]));

endmodule
