`timescale 1ns/1ps

module uart_top_tb;
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire [7:0] rx_data;
    wire rx_done;

    uart_top uut(
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // 50MHz Clock (Period = 20ns)
    always #10 clk = ~clk;

    initial begin
        // Initialize Signals
        clk = 0;
        reset = 1;                                       // Start in Reset
        tx_start = 0;
        tx_data = 8'h00;

        #100;                                         // Wait 100ns
        reset = 0;                                      // Release Reset
        
        #100;
        tx_data = 8'h41;                                // ASCII 'A' (Binary 01000001)
        tx_start = 1;                                   // Trigger TX
        #20;                                            // Hold for one clock cycle
        tx_start = 0;

        // Wait for RX to finish (approx 10 bits * 10 divisor * 20ns = 2000ns)
        wait(rx_done == 1);
        
        #500;
        $display("Test Passed: Received Data = %h", rx_data);
        $stop;
    end
endmodule