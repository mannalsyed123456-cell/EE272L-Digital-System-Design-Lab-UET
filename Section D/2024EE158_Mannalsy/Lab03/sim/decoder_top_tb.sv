module decoder_top_tb;


    
    logic [2:0] a;
    logic [2:0] b;
    logic       c_in;
    logic [2:0] sel;   

    
    logic [6:0] seg;   
    logic [7:0] an;    


    decoder_top DUT (
        .a(a),
        .b(b),
        .c_in(c_in),
        .sel(sel),
        .seg(seg),
        .an(an)
    );

    
    initial begin
        // Display header
        $display("Time\ta\tb\tc_in\tResult(seg)\tan");
        sel = 3'b000;  // activate AN0

        // Test Case 1
        a = 3'b000; b = 3'b000; c_in = 0; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, c_in, seg, an);

        // Test Case 2
        a = 3'b001; b = 3'b010; c_in = 0; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, c_in, seg, an);

        // Test Case 3
        a = 3'b011; b = 3'b001; c_in = 1; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, c_in, seg, an);

        // Test Case 4
        a = 3'b101; b = 3'b010; c_in = 0; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, c_in, seg, an);

        // Test Case 5
        a = 3'b111; b = 3'b111; c_in = 0; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, c_in, seg, an);

        // Test Case 6
        a = 3'b111; b = 3'b111; c_in = 1; #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, c_in, seg, an);

        $stop;
    end

endmodule
