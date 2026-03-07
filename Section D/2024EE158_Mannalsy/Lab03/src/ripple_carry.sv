module ripple_carry(
    input  logic [2:0] A,
    input  logic [2:0] B,
    input  logic       Cin,
    output logic [2:0] Sum,
    output logic       Cout
);

    logic c1, c2;

    full_adder FA0(.A(A[0]), .B(B[0]), .Cin(Cin), .Sum(Sum[0]), .Cout(c1));
    full_adder FA1(.A(A[1]), .B(B[1]), .Cin(c1), .Sum(Sum[1]), .Cout(c2));
    full_adder FA2(.A(A[2]), .B(B[2]), .Cin(c2), .Sum(Sum[2]), .Cout(Cout));

endmodule
