module sq_wave_gen (
    input clk,
    input next_sample,
    output reg [9:0] code
);

    always @(posedge clk) begin
        if (next_sample)
            code <= code + 10'd1;  // ramp waveform
    end

endmodule
