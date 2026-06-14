module edge_detector(
    input  logic clk,
    input  logic signal_in,
    output logic edge_pulse
);

    logic prev_sig ;

    always_ff @(posedge clk) begin
        prev_sig <= signal_in;
    end

    // rising edge detection
    assign edge_pulse = signal_in & ~prev_sig;

endmodule
