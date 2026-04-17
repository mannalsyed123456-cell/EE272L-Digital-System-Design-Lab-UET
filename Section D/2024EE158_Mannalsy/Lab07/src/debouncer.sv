module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output reg [WIDTH-1:0] debounced_signal
);

    reg [WRAPPING_CNT_WIDTH-1:0] sample_cnt = 0;
    reg [SAT_CNT_WIDTH-1:0] sat_cnt [WIDTH-1:0];

    integer i;

    wire sample_tick = (sample_cnt == SAMPLE_CNT_MAX-1);

    // wrapping counter
    always @(posedge clk) begin
        if (sample_tick)
            sample_cnt <= 0;
        else
            sample_cnt <= sample_cnt + 1;
    end

    // saturating counters
    always @(posedge clk) begin
        if (sample_tick) begin
            for (i = 0; i < WIDTH; i = i + 1) begin
                if (glitchy_signal[i]) begin
                    if (sat_cnt[i] < PULSE_CNT_MAX)
                        sat_cnt[i] <= sat_cnt[i] + 1;
                end else begin
                    if (sat_cnt[i] > 0)
                        sat_cnt[i] <= sat_cnt[i] - 1;
                end

                // output logic
                if (sat_cnt[i] == PULSE_CNT_MAX)
                    debounced_signal[i] <= 1;
                else if (sat_cnt[i] == 0)
                    debounced_signal[i] <= 0;
            end
        end
    end

endmodule
