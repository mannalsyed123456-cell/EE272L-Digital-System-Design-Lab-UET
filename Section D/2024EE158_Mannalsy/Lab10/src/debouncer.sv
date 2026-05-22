timescale 1ns/1ns

module debouncer #(
    parameter pulse_count = 500_000,
    parameter counter_width = $clog2(pulse_count + 1)
)(
    input clk,
    input rst,
    input sig_in,
    output reg sig_out = 0
);

    reg [counter_width-1:0] count = 0;

    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            sig_out <= 0;
        end 
        // Agar input badal gaya hai lekin output purana hi hai
        else if (sig_in != sig_out) begin 
            if (count >= pulse_count) begin
                sig_out <= sig_in; // Count poora hone par output update
                count <= 0;
            end else begin
                count <= count + 1; // Stability ka intezar
            end
        end 
        // Agar input wapis purani state (sig_out) par aa jaye (glitch)
        else begin
            count <= 0;
        end
    end
endmodule
