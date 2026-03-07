module decoder_7seg(
    input logic [3:0] in,
    output logic [6:0] seg
);
    // Rename for clarity
    logic A, B, C, D;
    assign A = in[3];
    assign B = in[2];
    assign C = in[1];
    assign D = in[0];
    
    // Segment A
    assign seg[0] = (~A & ~B & ~C &  D) | 
                    (~A &  B & ~C & ~D) | 
                    ( A & ~B &  C &  D) | 
                    ( A &  B & ~C &  D);
    
    // Segment B
    assign seg[1] = (~A &  B & ~C &  D) | 
                    (~A &  B &  C & ~D) | 
                    ( A & ~B &  C &  D) | 
                    ( A &  B & ~C & ~D) | 
                    ( A &  B &  C & ~D) | 
                    ( A &  B &  C &  D);
    
    // Segment C
    assign seg[2] = (~A & ~B &  C & ~D) | 
                    ( A &  B & ~C & ~D) | 
                    ( A &  B &  C & ~D) | 
                    ( A &  B &  C &  D);
    
    // Segment D
    assign seg[3] = (~A & ~B & ~C &  D) | 
                    (~A &  B & ~C & ~D) | 
                    (~A &  B &  C &  D) | 
                    ( A & ~B &  C & ~D) | 
                    ( A &  B &  C &  D);
    
    // Segment E
    assign seg[4] = (~A & ~B & ~C &  D) | 
                    (~A & ~B &  C &  D) | 
                    (~A &  B & ~C & ~D) | 
                    (~A &  B & ~C &  D) | 
                    (~A &  B &  C &  D) | 
                    ( A & ~B & ~C &  D);
    
    // Segment F
    assign seg[5] = (~A & ~B & ~C &  D) | 
                    (~A & ~B &  C & ~D) | 
                    (~A & ~B &  C &  D) | 
                    (~A &  B &  C &  D) | 
                    ( A &  B & ~C &  D);
    
    // Segment G
    assign seg[6] = (~A & ~B & ~C & ~D) | 
                    (~A & ~B & ~C &  D) | 
                    (~A &  B &  C &  D) | 
                    ( A &  B & ~C & ~D);
    
endmodule
