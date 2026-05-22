module uart_receiver # (
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200
) (
    input clk, reset,
    output [7:0] data_out,
    output data_out_valid,
    input data_out_ready,
    input serial_in
);
    localparam integer SYMBOL_EDGE_TIME = CLOCK_FREQ / BAUD_RATE;
    localparam integer SAMPLE_TIME      = SYMBOL_EDGE_TIME / 2;
    localparam CLOCK_COUNTER_WIDTH      = $clog2(SYMBOL_EDGE_TIME);

    reg [9:0] rx_shift_value = 10'b1111111111;
    reg [3:0] bit_counter_value = 0;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter_value = 0;
    reg start = 0;
    reg has_byte = 0;

    wire symbol_edge = (clock_counter_value == SYMBOL_EDGE_TIME - 1);
    wire sample_time = (clock_counter_value == SAMPLE_TIME - 1);
    wire done        = (bit_counter_value == 10 - 1) && sample_time;

    assign data_out_valid = has_byte;
    assign data_out = rx_shift_value[8:1];

    always @(posedge clk) begin
        if (reset) start <= 1'b0;
        else if (!start && (serial_in == 1'b0)) start <= 1'b1;
        else if (done) start <= 1'b0;

        if (reset || done || (!start && (serial_in == 1'b0))) clock_counter_value <= 0;
        else if (start) begin
            if (symbol_edge) clock_counter_value <= 0;
            else clock_counter_value <= clock_counter_value + 1;
        end

        if (reset || done) bit_counter_value <= 0;
        else if (start && symbol_edge) bit_counter_value <= bit_counter_value + 1;

        if (start && sample_time) rx_shift_value[bit_counter_value] <= serial_in;

        if (reset || (data_out_valid && data_out_ready)) has_byte <= 0;
        else if (done) has_byte <= 1;
    end
endmodule
