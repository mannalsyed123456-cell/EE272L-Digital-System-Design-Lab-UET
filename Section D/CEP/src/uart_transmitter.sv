module uart_transmitter #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE   = 115_200
) (
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);

    logic load_frame;
    logic frame_done;

    uart_transmitter_controller u_ctrl (
        .clk(clk),
        .reset(reset),
        .data_in_valid(data_in_valid),
        .frame_done(frame_done),
        .data_in_ready(data_in_ready),
        .load_frame(load_frame)
    );

    uart_transmitter_datapath #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_dp (
        .clk(clk),
        .reset(reset),
        .load_frame(load_frame),
        .data_in(data_in),
        .serial_out(serial_out),
        .frame_done(frame_done)
    );

endmodule
