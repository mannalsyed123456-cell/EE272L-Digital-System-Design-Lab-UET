module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
    // Two stages of registers for synchronization
    reg [WIDTH-1:0] stage1;
    reg [WIDTH-1:0] stage2;

    always @(posedge clk) begin
        stage1 <= async_signal;
        stage2 <= stage1;
    end

    assign sync_signal = stage2;

endmodule
