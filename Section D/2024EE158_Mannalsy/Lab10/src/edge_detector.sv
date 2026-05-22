timescale 1ns/1ns

module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input rst, 
    input [WIDTH-1:0] signal_in,
    output reg [WIDTH-1:0] edge_detect_pulse = 0 // Initialized
);
    reg [WIDTH-1:0] prev = 0; // Initialized to prevent 'x'

    always @(posedge clk) begin
        if (rst) begin
            prev <= 0;
            edge_detect_pulse <= 0;
        end else begin
            // Rising edge logic: current is high AND previous was low
            edge_detect_pulse <= signal_in & ~prev;
            prev <= signal_in;
        end
    end
endmodule
