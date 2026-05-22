module clk_div (
    input  logic clk_in,    // 100MHz clock from Nexys A7
    input  logic reset,     // Active high reset
    output logic clk_out    // Slow clock for FSM
);

    // 100MHz clock par 24,999,999 tak count karne se 
    // clk_out taqreeban 2Hz (half second toggle) par chalay gi.
    logic [25:0] count;

    always_ff @(posedge clk_in or posedge reset) begin
        if (reset) begin
            count <= 0;
            clk_out <= 0;
        end 
        else if (count == 24_999_999) begin 
            count <= 0;
            clk_out <= ~clk_out; // Toggle slow clock
        end 
        else begin
            count <= count + 1;
        end
    end

endmodule
