module decoder_display_select(
    input logic [2:0] sel,   // 3-bit selector (0-7)
    output logic [7:0] an    // 8 anodes (active low)
);
    // Rename for clarity
    logic S2, S1, S0;
    assign S2 = sel[2];
    assign S1 = sel[1];
    assign S0 = sel[0];
    
    // AN0: Active when sel = 000 (active low, so invert)
    assign an[0] = ~(~S2 & ~S1 & ~S0);
    
    // AN1: Active when sel = 001
    assign an[1] = ~(~S2 & ~S1 &  S0);
    
    // AN2: Active when sel = 010
    assign an[2] = ~(~S2 &  S1 & ~S0);
    
    // AN3: Active when sel = 011
    assign an[3] = ~(~S2 &  S1 &  S0);
    
    // AN4: Active when sel = 100
    assign an[4] = ~( S2 & ~S1 & ~S0);
    
    // AN5: Active when sel = 101
    assign an[5] = ~( S2 & ~S1 &  S0);
    
    // AN6: Active when sel = 110
    assign an[6] = ~( S2 &  S1 & ~S0);
    
    // AN7: Active when sel = 111
    assign an[7] = ~( S2 &  S1 &  S0);
    
endmodule
