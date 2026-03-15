module log_shifter (
    input  logic [3:0] X,
    input  logic [1:0] S,
    output logic [3:0] Y
);

assign Y = X << S;

endmodule
