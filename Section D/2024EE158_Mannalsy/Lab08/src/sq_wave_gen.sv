module sq_wave_gen #(
    parameter CYCLES_PER_WINDOW = 1024,
    parameter SAMPLES_PER_HALF  = 111
)(
    input  logic                                 clk,
    input  logic                                 rst,
    input  logic                                 next_sample,
    output logic [$clog2(CYCLES_PER_WINDOW)-1:0] code
);
    logic [$clog2(SAMPLES_PER_HALF)-1:0] sample_count;
    logic                                sq_high;

    always_ff @(posedge clk) begin
        if (rst) begin
            sample_count <= 0;
            sq_high      <= 1'b1;
        end else if (next_sample) begin
            if (sample_count == SAMPLES_PER_HALF - 1) begin
                sample_count <= 0;
                sq_high      <= ~sq_high;
            end else begin
                sample_count <= sample_count + 1;
            end
        end
    end

    
    assign code = sq_high ? 10'd562 : 10'd462;
endmodule
