module uart_receiver_controller #(
    parameter int CLOCK_FREQ = 100_000_000,
    parameter int BAUD_RATE   = 115_200,
    parameter int CLOCK_COUNTER_WIDTH = $clog2(CLOCK_FREQ / BAUD_RATE)
) (
    input  logic clk,
    input  logic reset,

    input  logic serial_in,
    input  logic data_out_ready,

    input  logic [3:0] bit_counter_value,
    input  logic [CLOCK_COUNTER_WIDTH-1:0] clock_counter_value,

    output logic data_out_valid,

    output logic rx_shift_ce,
    output logic bit_counter_ce,
    output logic bit_counter_rst,
    output logic clock_counter_ce,
    output logic clock_counter_rst
);

    localparam int SYMBOL_EDGE_TIME = CLOCK_FREQ / BAUD_RATE;
    localparam int SAMPLE_TIME      = SYMBOL_EDGE_TIME / 2;

    localparam logic [1:0] IDLE = 2'd0;
    localparam logic [1:0] RECV = 2'd1;
    localparam logic [1:0] HOLD = 2'd2;

    logic [1:0] state_q, state_d;

    logic symbol_edge;
    logic sample_time;
    logic done;

    assign symbol_edge = (clock_counter_value == SYMBOL_EDGE_TIME - 1);
    assign sample_time = (clock_counter_value == SAMPLE_TIME - 1);
    assign done        = (bit_counter_value == 4'd9) & sample_time;

    always_comb begin
        state_d           = state_q;
        data_out_valid    = 1'b0;

        rx_shift_ce       = 1'b0;
        bit_counter_ce    = 1'b0;
        bit_counter_rst   = 1'b1;
        clock_counter_ce  = 1'b0;
        clock_counter_rst = 1'b1;

        case (state_q)
            IDLE: begin
                bit_counter_rst   = 1'b1;
                clock_counter_rst = 1'b1;

                if (serial_in == 1'b0) begin
                    state_d = RECV;
                end
            end

            RECV: begin
                rx_shift_ce       = sample_time;
                bit_counter_ce    = symbol_edge;
                bit_counter_rst   = done;
                clock_counter_ce  = 1'b1;
                clock_counter_rst = symbol_edge | done;

                if (done) begin
                    state_d = HOLD;
                end
            end

            HOLD: begin
                data_out_valid    = 1'b1;
                bit_counter_rst   = 1'b1;
                clock_counter_rst = 1'b1;

                if (data_out_ready) begin
                    state_d = IDLE;
                end
            end

            default: begin
                state_d           = IDLE;
                bit_counter_rst   = 1'b1;
                clock_counter_rst = 1'b1;
            end
        endcase
    end

    REGISTER_R #(
        .N(2),
        .INIT(2'd0)
    ) state_reg (
        .q(state_q),
        .d(state_d),
        .rst(reset),
        .clk(clk)
    );

endmodule
