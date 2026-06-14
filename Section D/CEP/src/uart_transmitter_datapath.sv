module uart_transmitter_datapath #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE   = 115_200
) (
    input  logic clk,
    input  logic reset,

    input  logic load_frame,
    input  logic [7:0] data_in,

    output logic serial_out,
    output logic frame_done
);

    localparam int SYMBOL_EDGE_TIME   = CLOCK_FREQ / BAUD_RATE;
    localparam int CLOCK_COUNTER_WIDTH = $clog2(SYMBOL_EDGE_TIME);
    localparam int FRAME_BITS          = 10; // start + 8 data + stop
    localparam int BIT_COUNTER_WIDTH   = $clog2(FRAME_BITS);

    logic                         busy_q, busy_d;
    logic [CLOCK_COUNTER_WIDTH-1:0] clk_count_q, clk_count_d;
    logic [BIT_COUNTER_WIDTH-1:0]   bit_count_q, bit_count_d;
    logic [FRAME_BITS-1:0]          frame_q, frame_d;

    logic symbol_edge;

    assign symbol_edge = busy_q && (clk_count_q == SYMBOL_EDGE_TIME - 1);

    // UART line idles high when not transmitting
    assign serial_out = busy_q ? frame_q[0] : 1'b1;

    // One-cycle pulse when the last bit of the frame has just finished
    assign frame_done = busy_q && symbol_edge && (bit_count_q == FRAME_BITS - 1);

    always_comb begin
        // defaults: hold state
        busy_d      = busy_q;
        clk_count_d = clk_count_q;
        bit_count_d = bit_count_q;
        frame_d     = frame_q;

        if (load_frame) begin
            // Frame is 10 bits:
            // [stop bit][8 data bits][start bit]
            // LSB is transmitted first.
            busy_d      = 1'b1;
            clk_count_d = '0;
            bit_count_d  = '0;
            frame_d     = {1'b1, data_in, 1'b0};
        end
        else if (busy_q) begin
            if (symbol_edge) begin
                clk_count_d = '0;

                if (bit_count_q == FRAME_BITS - 1) begin
                    // done with stop bit
                    busy_d      = 1'b0;
                    bit_count_d = '0;
                    frame_d     = {FRAME_BITS{1'b1}};
                end
                else begin
                    // move to next bit
                    bit_count_d = bit_count_q + 1'b1;
                    frame_d     = {1'b1, frame_q[FRAME_BITS-1:1]};
                end
            end
            else begin
                clk_count_d = clk_count_q + 1'b1;
            end
        end
    end

    REGISTER_R #(              // currently transmitting or not
        .N(1),
        .INIT(1'b0)
    ) busy_reg (
        .q(busy_q),
        .d(busy_d),
        .rst(reset),
        .clk(clk)
    );

    REGISTER_R #(             // 
        .N(CLOCK_COUNTER_WIDTH),
        .INIT('0)
    ) clk_count_reg (
        .q(clk_count_q),
        .d(clk_count_d),
        .rst(reset),
        .clk(clk)
    );

    REGISTER_R #(
        .N(BIT_COUNTER_WIDTH),
        .INIT('0)
    ) bit_count_reg (
        .q(bit_count_q),
        .d(bit_count_d),
        .rst(reset),
        .clk(clk)
    );

    REGISTER_R #(                            // can handle only one input at a time, means it has only one frame register
        .N(FRAME_BITS),                      // so we have to make ready as 0 after accepting one 8 bit input to first let it transmit
        .INIT({FRAME_BITS{1'b1}})            // if we dont do it and let other input enter during transmission, old one destroyed
    ) frame_reg (                            // stores current frame and next (right)shifted frame
        .q(frame_q),
        .d(frame_d),
        .rst(reset),
        .clk(clk)
    );

endmodule
