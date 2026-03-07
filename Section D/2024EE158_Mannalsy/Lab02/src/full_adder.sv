module full_adder(
    input logic A,
    input logic B,
    input logic Cin,
    output logic Sum,
    output logic Cout
);

    // Sum = A XOR B XOR Cin
    assign Sum = A ^ B ^ Cin;

    // Carry-out = AB + ACin + BCin
    assign Cout = (A & B) | (A & Cin) | (B & Cin);

endmodule
