module sample_pulse_gen #(
    parameter SAMPLE_COUNT_MAX = 50000
)(
    input  logic clk,
    output logic sample_pulse
);
    logic [$clog2(SAMPLE_COUNT_MAX)-1:0] count = 0;

    always_ff @(posedge clk) begin
        if (count == SAMPLE_COUNT_MAX - 1) begin
            count        <= 0;
            sample_pulse <= 1'b1;
        end else begin
            count        <= count + 1;
            sample_pulse <= 1'b0;
        end
    end
endmodule
