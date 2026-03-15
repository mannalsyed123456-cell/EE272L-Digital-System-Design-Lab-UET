module const_multiplier(
    input  logic [3:0] X,
    output logic [4:0] P
);

// Multiply by 2 using shift
logic [3:0] X2;

log_shifter LS (
    .X(X),
    .S(2'b01),     
    .Y(X2)
);

// Add X + 2*X = 3*X
ripple_carry_adder RCA (
    .a(X),
    .b(X2),
    .cin(1'b0),
    .sum(P[3:0]),
    .cout(P[4])
);

endmodule
