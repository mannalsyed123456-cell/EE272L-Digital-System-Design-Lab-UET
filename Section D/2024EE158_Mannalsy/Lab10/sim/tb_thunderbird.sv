module tb_thunderbird();
    logic clk, reset, left, right;
    logic [2:0] left_lights, right_lights;

    thunderbird_fsm dut (.*, .lc_lb_la(left_lights), .ra_rb_rc(right_lights));

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; left = 0; right = 0;
        #20 reset = 0;
        
        // Test Left turn
        #20 left = 1;
        #100 left = 0;
        
        // Test Right turn
        #40 right = 1;
        #100 right = 0;
        
        #100 $finish;
    end
endmodule
