module debouncer #(
    parameter PULSE_COUNT_MAX = 10
)(
    input  logic clk,
    input  logic sample_pulse,
    input  logic sync_out,
    output logic switch_out
);
    logic reset;
    assign reset  = ~sync_out;

    logic enable;
    assign enable = sample_pulse & sync_out;

    logic [$clog2(PULSE_COUNT_MAX+1)-1:0] count = 0;

    always_ff @(posedge clk) begin
        if (reset) begin
            count      <= 0;
            switch_out <= 1'b0;
        end else if (enable && (count < PULSE_COUNT_MAX)) begin
            count      <= count + 1;
        end else if (count == PULSE_COUNT_MAX) begin
            switch_out <= 1'b1;
        end
    end
endmodule
