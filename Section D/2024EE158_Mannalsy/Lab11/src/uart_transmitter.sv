module uart_transmitter # (
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200
) (
    input clk, reset,
    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,
    output serial_out
);
    localparam integer SYMBOL_EDGE_TIME = CLOCK_FREQ / BAUD_RATE;
    localparam CLOCK_COUNTER_WIDTH     = $clog2(SYMBOL_EDGE_TIME);

    reg [9:0] tx_shift_reg = 10'b1111111111;
    reg [3:0] bit_counter = 0;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter = 0;
    reg tx_running = 0;

    assign data_in_ready = !tx_running && !reset;
    assign serial_out = tx_shift_reg[bit_counter];

    wire symbol_edge = (clock_counter == SYMBOL_EDGE_TIME - 1);
    wire tx_done     = (bit_counter == 10 - 1) && symbol_edge;

    always @(posedge clk) begin
        if (reset) tx_running <= 0;
        else if (data_in_valid && data_in_ready) tx_running <= 1;
        else if (tx_done) tx_running <= 0;

        if (data_in_valid && data_in_ready) tx_shift_reg <= {1'b1, data_in, 1'b0};

        if (reset || !tx_running || symbol_edge) clock_counter <= 0;
        else clock_counter <= clock_counter + 1;

        if (reset || !tx_running || tx_done) bit_counter <= 0;
        else if (symbol_edge) bit_counter <= bit_counter + 1;
    end
endmodule
