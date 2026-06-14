module uart_transmitter_controller (
    input  logic clk,
    input  logic reset,

    input  logic data_in_valid,
    input  logic frame_done,

    output logic data_in_ready,
    output logic load_frame
);

    localparam logic IDLE = 1'b0;
    localparam logic SEND = 1'b1;

    logic state_q, state_d;

    always_comb begin
        // defaults
        state_d       = state_q;
        data_in_ready  = 1'b0;
        load_frame     = 1'b0;

        case (state_q)
            IDLE: begin
                data_in_ready = 1'b1;
                if (data_in_valid) begin
                    load_frame = 1'b1;
                    state_d    = SEND;               // state_d = next state, since in D-Q ff D is next , when clk arrives Q<=D 
                end
            end

            SEND: begin
                if (frame_done) begin
                    state_d = IDLE;
                end
            end

            default: begin
                state_d      = IDLE;
                data_in_ready = 1'b1;
            end
        endcase
    end

    REGISTER_R #(
        .N(1),
        .INIT(1'b0)
    ) state_reg (
        .q(state_q),
        .d(state_d),
        .rst(reset),
        .clk(clk)
    );

endmodule
