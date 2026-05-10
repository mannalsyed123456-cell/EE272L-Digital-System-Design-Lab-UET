module synchronizer (
    input  logic clk,
    input  logic async_signal,
    output logic sync_signal
);
    logic q1;

    always_ff @(posedge clk) begin
        q1          <= async_signal;
        sync_signal <= q1;
    end
endmodule
