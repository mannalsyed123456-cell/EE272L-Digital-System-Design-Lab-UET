module debouncer_c #(
    parameter logic [3:0] MAX_COUNT = 4'd15
)(
    input  logic pulse,
    input  logic sync_sig,
    input  logic clk,
    input  logic reset,
    output logic swt_out
);

    logic [3:0] counter_sc;

    logic enable;
    and a1(enable, pulse, sync_sig);

    saturated_c #(.MAX_COUNT(MAX_COUNT)) sc (
        .clk     (clk),
        .reset   (reset),
        .enable  (enable),     // only update on sample pulse
        .up      (sync_sig),  // HIGH → count up, LOW → count down
        .counter (counter_sc)
    );

    // output high only when fully stable
    assign swt_out = (counter_sc == MAX_COUNT);

endmodule
