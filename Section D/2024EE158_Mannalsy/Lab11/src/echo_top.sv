module echo_top # (
    parameter CLOCK_FREQ = 100_000_000, 
    parameter BAUD_RATE  = 115_200
) (
    input clk,
    input reset,
    input serial_in,
    output serial_out
);
    // Internal Wires
    wire [7:0] rx_data;
    wire rx_valid;
    wire tx_ready;
    
    wire [7:0] fifo_dout;
    wire fifo_empty;
    wire fifo_full;

    // FIFO Control Signals
    // wr_en tab hoga jab RX poora byte receive kar le
    wire fifo_wr_en = rx_valid && !fifo_full;
    
    // rd_en tab hoga jab transmitter free ho AUR FIFO khali na ho
    // Image 2 jaisi timing ke liye rd_en sirf tab high hoga jab tx_ready ho
    wire fifo_rd_en = tx_ready && !fifo_empty;

    // 1. UART Receiver
    uart_receiver #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk(clk),
        .reset(reset),
        .data_out(rx_data),
        .data_out_valid(rx_valid),
        .data_out_ready(!fifo_full), 
        .serial_in(serial_in)
    );

    // 2. FIFO Buffer
    fifo #(
        .WIDTH(8),
        .DEPTH(16)
    ) data_buffer (
        .clk(clk),
        .rst(reset),
        .din(rx_data),
        .wr_en(fifo_wr_en),
        .full(fifo_full),
        .dout(fifo_dout),
        .rd_en(fifo_rd_en),
        .empty(fifo_empty)
    );

    // 3. UART Transmitter
    uart_transmitter #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk(clk),
        .reset(reset),
        .data_in(fifo_dout),
        // data_in_valid ko rd_en ke saath sync kiya taake timing gap nazar aaye
        .data_in_valid(!fifo_empty),
        .data_in_ready(tx_ready),
        .serial_out(serial_out)
    );

endmodule
