module z1top #(
    parameter B_SAMPLE_CNT_MAX  = 5,
    parameter B_PULSE_CNT_MAX   = 5,
    parameter CLOCK_FREQ        = 100_000_000,
    parameter BAUD_RATE         = 115_200,
    parameter CYCLES_PER_SECOND = CLOCK_FREQ
) (
    input  logic        CLK_125MHZ_FPGA,
    input  logic [3:0]  BUTTONS,
    input  logic [1:0]  SWITCHES,
    output logic [5:0]  LEDS,
    output logic        AUD_PWM,
    input  logic        FPGA_SERIAL_RX,
    output logic        FPGA_SERIAL_TX
);

    logic clk;
    logic rst;

    assign clk = CLK_125MHZ_FPGA;
    assign rst = BUTTONS[0];

    // Parsed button pulses for the other buttons
    logic btn1_pulse;
    logic btn2_pulse;
    logic btn3_pulse;

    button_parser_top u_btn1 (
        .clk(clk),
        .reset(rst),
        .async_sig(BUTTONS[1]),
        .btn_out(btn1_pulse)
    );

    button_parser_top u_btn2 (
        .clk(clk),
        .reset(rst),
        .async_sig(BUTTONS[2]),
        .btn_out(btn2_pulse)
    );

    button_parser_top u_btn3 (
        .clk(clk),
        .reset(rst),
        .async_sig(BUTTONS[3]),
        .btn_out(btn3_pulse)
    );

    // UART <-> FIFO wires
    logic [7:0] uart_rx_data_out;
    logic       uart_rx_data_out_valid;
    logic       uart_rx_data_out_ready;

    logic [7:0] uart_tx_data_in;
    logic       uart_tx_data_in_valid;
    logic       uart_tx_data_in_ready;

    // RX FIFO wires
    logic       rx_fifo_full;
    logic       rx_fifo_empty;
    logic       rx_fifo_wr_en;
    logic       rx_fifo_rd_en;
    logic [7:0] rx_fifo_din;
    logic [7:0] rx_fifo_dout;

    // TX FIFO wires
    logic       tx_fifo_full;
    logic       tx_fifo_empty;
    logic       tx_fifo_wr_en;
    logic       tx_fifo_rd_en;
    logic [7:0] tx_fifo_din;
    logic [7:0] tx_fifo_dout;

    logic [5:0] mem_state_leds;

    uart #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart (
        .clk(clk),
        .reset(rst),

        .data_in(uart_tx_data_in),
        .data_in_valid(uart_tx_data_in_valid),
        .data_in_ready(uart_tx_data_in_ready),

        .data_out(uart_rx_data_out),
        .data_out_valid(uart_rx_data_out_valid),
        .data_out_ready(uart_rx_data_out_ready),

        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    fifo #(
        .WIDTH(8),
        .DEPTH(8)
    ) rx_fifo (
        .clk(clk),
        .rst(rst),

        .wr_en(rx_fifo_wr_en),
        .din(rx_fifo_din),
        .full(rx_fifo_full),

        .rd_en(rx_fifo_rd_en),
        .dout(rx_fifo_dout),
        .empty(rx_fifo_empty)
    );

    fifo #(
        .WIDTH(8),
        .DEPTH(8)
    ) tx_fifo (
        .clk(clk),
        .rst(rst),

        .wr_en(tx_fifo_wr_en),
        .din(tx_fifo_din),
        .full(tx_fifo_full),

        .rd_en(tx_fifo_rd_en),
        .dout(tx_fifo_dout),
        .empty(tx_fifo_empty)
    );

    uart_rx_fifo_bridge #(
        .WIDTH(8)
    ) u_rx_bridge (
        .clk(clk),
        .rst(rst),

        .uart_data_out(uart_rx_data_out),
        .uart_data_out_valid(uart_rx_data_out_valid),
        .uart_data_out_ready(uart_rx_data_out_ready),

        .fifo_wr_en(rx_fifo_wr_en),
        .fifo_din(rx_fifo_din),
        .fifo_full(rx_fifo_full)
    );

    mem_controller #(
        .FIFO_WIDTH(8)
    ) mem_ctrl (
        .clk(clk),
        .rst(rst),

        .rx_fifo_empty(rx_fifo_empty),
        .tx_fifo_full(tx_fifo_full),
        .din(rx_fifo_dout),

        .rx_fifo_rd_en(rx_fifo_rd_en),
        .tx_fifo_wr_en(tx_fifo_wr_en),
        .dout(tx_fifo_din),
        .state_leds(mem_state_leds)
    );

    fifo_to_uart_bridge #(
        .WIDTH(8)
    ) u_tx_bridge (
        .clk(clk),
        .rst(rst),

        .fifo_empty(tx_fifo_empty),
        .fifo_dout(tx_fifo_dout),
        .fifo_rd_en(tx_fifo_rd_en),

        .uart_data_in(uart_tx_data_in),
        .uart_data_in_valid(uart_tx_data_in_valid),
        .uart_data_in_ready(uart_tx_data_in_ready)
    );

    // Debug view:
    // upper 3 LEDs show button pulses
    // lower 3 LEDs show mem_controller state bits
    assign LEDS   = {btn3_pulse, btn2_pulse, btn1_pulse, mem_state_leds[2:0]};
    assign AUD_PWM = 1'b0;

endmodule
