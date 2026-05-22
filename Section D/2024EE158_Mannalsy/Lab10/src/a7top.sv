module a7top (
    input  logic CLK100MHZ,
    input  logic CPU_RESETN, // Nexys board ka reset (active low)
    input  logic BTNL,       // Input Left Button
    input  logic BTNR,       // Input Right Button
    output logic [5:0] LED   // Output LEDs (LA, LB, LC, RA, RB, RC)
);
    logic slow_clk;
    logic reset;
    logic [1:0] clean_pulses; // Parser se nikalne wali clean pulses 
    
    assign reset = ~CPU_RESETN;

    // 1. Clock Divider (Blinking visible karne ke liye)
    clk_div divider (
        .clk_in(CLK100MHZ),
        .reset(reset),
        .clk_out(slow_clk)
    );

    // 2. Your Button Parser (Using your provided code) 
    // Hum WIDTH = 2 bhej rahe hain taake dono buttons process ho sakein 
    button_parser #(.WIDTH(2)) bp (
        .clk(CLK100MHZ),
        .in({BTNL, BTNR}),     // Dono buttons ko combine kar ke bheja 
        .out(clean_pulses)     // Yahan se clean signal niklay ga 
    );

    // 3. Thunderbird FSM
    thunderbird_fsm tbird (
        .clk(slow_clk),
        .reset(reset),
        .left(clean_pulses[1]),  // BTNL ka parsed signal
        .right(clean_pulses[0]), // BTNR ka parsed signal
        .lc_lb_la(LED[5:3]),
        .ra_rb_rc(LED[2:0])
    );
endmodule
