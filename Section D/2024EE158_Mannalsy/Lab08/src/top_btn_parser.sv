module top_btn_parser (
    input  logic clk,
    input  logic rst,
    input  logic async_signal,
    output logic edge_detect_pulse,
    output logic sig_in,
    output logic mod_clk,
    output logic async_sig_out,
    output logic pwm_out
);

    logic sync_out;
    logic sample_pulse;
    logic switch_out;
    logic edge_pulse;
    logic sound_enable;
    logic next_sample;
    logic [9:0] code;
    logic pwm;
    logic dac_rst;

    // 1. Synchronizer
    synchronizer u_sync (
        .clk(clk),
        .async_signal(async_signal),
        .sync_signal(sync_out)
    );

    // 2. FAST sample pulse (was 50000)
    sample_pulse_gen #(
        .SAMPLE_COUNT_MAX (20)
    ) u_spg (
        .clk(clk),
        .sample_pulse(sample_pulse)
    );

    // 3. FAST debouncer (was 10)
    debouncer #(
        .PULSE_COUNT_MAX (3)
    ) u_deb (
        .clk(clk),
        .sample_pulse(sample_pulse),
        .sync_out(sync_out),
        .switch_out(switch_out)
    );

    // 4. Edge detector
    edge_detector u_edge (
        .clk(clk),
        .switch_out(switch_out),
        .edge_pulse(edge_pulse)
    );

    // 5. Toggle FF
    always_ff @(posedge clk) begin
        if (rst)
            sound_enable <= 0;
        else if (edge_pulse)
            sound_enable <= ~sound_enable;
    end

    assign dac_rst = rst | ~sound_enable;

    // 6. FAST square wave (was 1024 & 111)
    sq_wave_gen #(
        .CYCLES_PER_WINDOW (8),
        .SAMPLES_PER_HALF  (4)
    ) u_sqwav (
        .clk(clk),
        .rst(dac_rst),
        .next_sample(next_sample),
        .code(code)
    );

    // 7. FAST DAC (was 1024)
    dac #(
        .CYCLES_PER_WINDOW (8)
    ) u_dac (
        .clk(clk),
        .rst(dac_rst),
        .code(code),
        .pwm(pwm),
        .next_sample(next_sample)
    );

    assign pwm_out = sound_enable ? pwm : 0;

    // Probes
    assign edge_detect_pulse = edge_pulse;
    assign sig_in            = sync_out;
    assign mod_clk           = sample_pulse;
    assign async_sig_out     = async_signal;

endmodule
