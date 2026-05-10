`timescale 1ns/1ps

module tb_lab_complete;

    logic clk;
    logic rst;
    logic async_signal;

    logic edge_detect_pulse;
    logic sig_in;
    logic mod_clk;
    logic async_sig_out;
    logic pwm_out;

    // Clock (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT
    top_btn_parser DUT (
        .clk(clk),
        .rst(rst),
        .async_signal(async_signal),
        .edge_detect_pulse(edge_detect_pulse),
        .sig_in(sig_in),
        .mod_clk(mod_clk),
        .async_sig_out(async_sig_out),
        .pwm_out(pwm_out)
    );

    // Internal signals
    wire sync_out     = DUT.sync_out;
    wire switch_out   = DUT.switch_out;
    wire edge_pulse   = DUT.edge_pulse;
    wire sound_enable = DUT.sound_enable;
    wire [9:0] code   = DUT.code;
    wire pwm          = DUT.pwm;
    wire next_sample  = DUT.next_sample;

    initial begin
        rst = 1;
        async_signal = 0;

        #50;
        rst = 0;

        // ============================
        // BUTTON PRESS WITH BOUNCE
        // ============================
        repeat (5) begin
            #10 async_signal = ~async_signal;
        end

        async_signal = 1;
        #500;

        // RELEASE
        repeat (5) begin
            #10 async_signal = ~async_signal;
        end

        async_signal = 0;
        #500;

        // SECOND PRESS (toggle off)
        async_signal = 1;
        #500;
        async_signal = 0;

        // RUN LONGER → observe square wave
        #2000;

        $stop;
    end

    // Monitor
    initial begin
        $monitor("T=%0t | async=%b sync=%b deb=%b edge=%b en=%b next=%b code=%d pwm=%b",
            $time,
            async_signal,
            sync_out,
            switch_out,
            edge_pulse,
            sound_enable,
            next_sample,
            code,
            pwm
        );
    end

endmodule
