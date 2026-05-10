module edge_detector (
    input  logic clk,
    input  logic switch_out,
    output logic edge_pulse
);
    logic sig_out;

    always_ff @(posedge clk) begin
        sig_out    <= switch_out;
        edge_pulse <= switch_out & ~sig_out;
    end
endmodule
