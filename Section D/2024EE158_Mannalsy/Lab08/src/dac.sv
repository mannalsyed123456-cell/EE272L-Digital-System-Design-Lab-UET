module dac #(
    parameter CYCLES_PER_WINDOW = 1024
)(
    input  logic                                 clk,
    input  logic                                 rst,
    input  logic [$clog2(CYCLES_PER_WINDOW)-1:0] code,
    output logic                                 pwm,
    output logic                                 next_sample
);
    logic [$clog2(CYCLES_PER_WINDOW)-1:0] count;

    always_ff @(posedge clk) begin
        if (rst)
            count <= 0;
        else if (count == CYCLES_PER_WINDOW - 1)
            count <= 0;
        else
            count <= count + 1;
    end

    assign pwm         = (count < code);
    assign next_sample = (count == CYCLES_PER_WINDOW - 1);
endmodule
