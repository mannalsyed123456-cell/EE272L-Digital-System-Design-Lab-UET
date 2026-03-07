module ripple_carry_tb;

    
    logic [2:0] a1;
    logic [2:0] b1;
    logic       c_in1;
    logic [2:0] sum1;
    logic       c_out1;

    
    ripple_carry MEA (
        .A(a1),
        .B(b1),
        .Cin(c_in1),
        .Sum(sum1),
        .Cout(c_out1)
    );

    
    initial begin
        // Test case 1
        a1 = 3'b000; b1 = 3'b000; c_in1 = 0; #10;

        // Test case 2
        a1 = 3'b001; b1 = 3'b010; c_in1 = 0; #10;

        // Test case 3
        a1 = 3'b011; b1 = 3'b001; c_in1 = 1; #10;

        // Test case 4
        a1 = 3'b101; b1 = 3'b010; c_in1 = 0; #10;

        // Test case 5
        a1 = 3'b111; b1 = 3'b111; c_in1 = 0; #10;

        // Test case 6
        a1 = 3'b111; b1 = 3'b111; c_in1 = 1; #10;

        $stop;
    end

endmodule
