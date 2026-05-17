module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    reg [WIDTH-1:0] signal_delay;

    // Delay the input signal by one clock cycle
    always @(posedge clk) begin
        signal_delay <= signal_in;
    end

    // Detect rising edge: current is high, previous was low
    assign edge_detect_pulse = signal_in & (~signal_delay);

endmodule
