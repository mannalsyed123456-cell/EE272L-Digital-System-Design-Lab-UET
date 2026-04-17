module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output reg [WIDTH-1:0] sync_signal
);

    reg [WIDTH-1:0] ff1;

    always @(posedge clk) begin
        ff1 <= async_signal;
        sync_signal <= ff1;
    end

endmodule
