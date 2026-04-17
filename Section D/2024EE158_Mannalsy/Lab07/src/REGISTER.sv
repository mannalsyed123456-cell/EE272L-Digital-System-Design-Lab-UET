odule REGISTER #(parameter WIDTH = 1)(
    output reg [WIDTH-1:0] q,
    input [WIDTH-1:0] d,
    input clk
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule
