module button_parser #(
    parameter WIDTH = 1
) (
    input clk,
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);
    wire [WIDTH-1:0] sync_to_deb;
    wire [WIDTH-1:0] deb_to_edge;

    synchronizer #(.WIDTH(WIDTH)) s1 (
        .clk(clk),
        .async_signal(in),
        .sync_signal(sync_to_deb)
    );

    // Fixed: Passed WIDTH parameter to debouncer
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : debounce_gen
            debouncer #(.pulse_count(500_000)) d1 (
                .clk(clk),
                .rst(1'b0),
                .sig_in(sync_to_deb[i]),
                .sig_out(deb_to_edge[i])
            );
        end
    endgenerate

    edge_detector #(.WIDTH(WIDTH)) e1 (
        .clk(clk),
        .rst(1'b0), 
        .signal_in(deb_to_edge),
        .edge_detect_pulse(out)
    );
endmodule
