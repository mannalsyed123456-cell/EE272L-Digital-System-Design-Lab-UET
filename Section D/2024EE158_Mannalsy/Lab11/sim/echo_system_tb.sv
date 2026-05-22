`timescale 1ns/1ps

module echo_system_tb();
    // Parameters - Nexys A7 ke liye 100MHz default
    localparam CLOCK_FREQ = 100_000_000; 
    localparam BAUD_RATE  = 115_200;
    localparam CLK_PERIOD = 10; // 10ns
    
    // 115200 baud par ek bit ka time taqreeban 8680ns hota hai
    localparam integer BIT_PERIOD = 1_000_000_000 / BAUD_RATE;

    // Standard I/O Signals
    reg clk = 0;
    reg reset = 0;
    reg serial_in = 1;  // Idle state of UART is High
    wire serial_out;

    // --- DEBUG WIRES (Monitoring ke liye) ---
    // Ye wires 'dut' ke andar se signals kheench kar bahar layengi
    wire [7:0] debug_fifo_din   = dut.rx_data;       // FIFO mein jane wala data
    wire [7:0] debug_fifo_dout  = dut.fifo_dout;     // FIFO se nikalne wala data
    wire debug_wr_en            = dut.fifo_wr_en;    // Write Enable signal
    wire debug_rd_en            = dut.fifo_rd_en;    // Read Enable signal
    wire debug_fifo_empty       = dut.fifo_empty;    // FIFO empty flag
    wire debug_fifo_full        = dut.fifo_full;     // FIFO full flag

    // Clock Generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Instantiate Top Module (DUT)
    echo_top #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .serial_out(serial_out)
    );

    // Task: Serial data bhejne ke liye (Simulating PC)
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start Bit (Low)
            serial_in = 0;
            #(BIT_PERIOD);
            // 8 Data Bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                serial_in = data[i];
                #(BIT_PERIOD);
            end
            // Stop Bit (High)
            serial_in = 1;
            #(BIT_PERIOD);
            $display("[Time: %t] Sent Byte: %h", $time, data);
        end
    endtask

    // Main Simulation Logic
    initial begin
        // 1. Reset the system
        reset = 1;
        #(CLK_PERIOD * 10);
        reset = 0;
        #(CLK_PERIOD * 10);

        $display("--- Starting Simulation ---");

        // 2. Send first byte 'A' (8'h41)
        send_byte(8'h41);
        
        // Byte ke darmiyan thora gap (optional)
        #(BIT_PERIOD * 2);

        // 3. Send second byte 'B' (8'h42)
        send_byte(8'h42);

        // 4. Wait for Echo to finish
        // Ek byte transfer hone mein kafi time lagta hai, isliye wait zaroori hai
        #(BIT_PERIOD * 30); 

        $display("--- Simulation Finished ---");
        $finish;
    end

endmodule
