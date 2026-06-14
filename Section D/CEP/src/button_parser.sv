odule button_parser_top(
    input  logic clk,
    input  logic reset,
    input  logic async_sig,
    output logic btn_out
);

    logic sync_sig;
    logic pulse;
    logic swt_out;
    logic edge_out;
    logic local_reset;

    synchronizer sync1(
        .async_sig(async_sig),
        .clk(clk),
        .sync_sig(sync_sig)
    );

    pulse_gen pg1(
        .clk(clk),
        .reset(reset),
        .pulse(pulse)
    );

    assign local_reset = ~sync_sig;

    debouncer_c db1(
        .pulse(pulse),
        .sync_sig(sync_sig),
        .clk(clk),
        .reset(local_reset),
        .swt_out(swt_out)
    );

    edge_detector ed1(
        .clk(clk),
        .signal_in(swt_out),
        .edge_pulse(edge_out)
    );

    assign btn_out = edge_out;

endmodule
