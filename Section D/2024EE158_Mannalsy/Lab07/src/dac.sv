module dac #(
    parameter CYCLES_PER_WINDOW = 1024,
    parameter CODE_WIDTH = $clog2(CYCLES_PER_WINDOW)
)(
    input clk,
    input [CODE_WIDTH-1:0] code,
    output reg next_sample,
    output reg pwm
);

    reg [CODE_WIDTH-1:0] counter = 0;

    always @(posedge clk) begin
        if (counter == CYCLES_PER_WINDOW-1) begin
            counter <= 0;
            next_sample <= 1;
        end else begin
            counter <= counter + 1;
            next_sample <= 0;
        end

        pwm <= (counter < code);
    end

endmodule
