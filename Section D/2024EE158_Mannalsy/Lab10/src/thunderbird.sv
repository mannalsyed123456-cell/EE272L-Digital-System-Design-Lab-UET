module thunderbird_fsm (
    input  logic clk,
    input  logic reset,
    input  logic left,
    input  logic right,
    output logic [2:0] lc_lb_la, // Left lights
    output logic [2:0] ra_rb_rc  // Right lights
);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        L1   = 3'b001, L2 = 3'b010, L3 = 3'b011,
        R1   = 3'b100, R2 = 3'b101, R3 = 3'b110
    } state_t;

    state_t curr_state, next_state;

    // State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) curr_state <= IDLE;
        else       curr_state <= next_state;
    end

    // Next State Logic
    always_comb begin
        case (curr_state)
            IDLE: begin
                if (left)       next_state = L1;
                else if (right) next_state = R1;
                else            next_state = IDLE;
            end
            // Left Sequence
            L1: next_state = L2;
            L2: next_state = L3;
            L3: next_state = IDLE;
            // Right Sequence
            R1: next_state = R2;
            R2: next_state = R3;
            R3: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output Logic
    always_comb begin
        lc_lb_la = 3'b000;
        ra_rb_rc = 3'b000;
        case (curr_state)
            L1: lc_lb_la = 3'b001;      // LA on
            L2: lc_lb_la = 3'b011;      // LA, LB on
            L3: lc_lb_la = 3'b111;      // LA, LB, LC on
            R1: ra_rb_rc = 3'b100;      // RA on
            R2: ra_rb_rc = 3'b110;      // RA, RB on
            R3: ra_rb_rc = 3'b111;      // RA, RB, RC on
            default: ; // All off
        endcase
    end
endmodule
