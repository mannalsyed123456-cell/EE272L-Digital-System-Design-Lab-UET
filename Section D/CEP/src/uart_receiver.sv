module uart_receiver #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE   = 115_200
) (
    input  logic       clk,
    input  logic       reset,

    output logic [7:0] data_out,
    output logic       data_out_valid,
    input  logic       data_out_ready,

    input  logic       serial_in
);

    localparam int CLOCK_COUNTER_WIDTH = $clog2(CLOCK_FREQ / BAUD_RATE);

    logic [3:0] bit_counter_value;
    logic [CLOCK_COUNTER_WIDTH-1:0] clock_counter_value;

    logic rx_shift_ce;
    logic bit_counter_ce;
    logic bit_counter_rst;
    logic clock_counter_ce;
    logic clock_counter_rst;

    uart_receiver_controller #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_ctrl (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .data_out_ready(data_out_ready),
        .bit_counter_value(bit_counter_value),
        .clock_counter_value(clock_counter_value),
        .data_out_valid(data_out_valid),
        .rx_shift_ce(rx_shift_ce),
        .bit_counter_ce(bit_counter_ce),
        .bit_counter_rst(bit_counter_rst),
        .clock_counter_ce(clock_counter_ce),
        .clock_counter_rst(clock_counter_rst)
    );

    uart_receiver_datapath #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_dp (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .rx_shift_ce(rx_shift_ce),
        .bit_counter_ce(bit_counter_ce),
        .bit_counter_rst(bit_counter_rst),
        .clock_counter_ce(clock_counter_ce),
        .clock_counter_rst(clock_counter_rst),
        .bit_counter_value(bit_counter_value),
        .clock_counter_value(clock_counter_value),
        .data_out(data_out)
    );

endmodule
