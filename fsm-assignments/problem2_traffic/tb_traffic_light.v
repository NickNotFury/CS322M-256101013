`timescale 1ns/1ps
`include "traffic_light.v"

// Testbench for traffic_light module
module tb_traffic_light;

    // 1. Testbench Signals
    reg clk;
    reg rst;
    reg tick;

    wire ns_g, ns_y, ns_r;
    wire ew_g, ew_y, ew_r;

    // 2. Instantiate the Device Under Test (DUT)
    traffic_light dut (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
    );

    // 3. Clock Generator (e.g., 100MHz clock -> 10ns period)
    parameter CLK_PERIOD = 10;
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 4. Tick Generator (produces a 1-cycle pulse every 10 clock cycles)
    // This simulates the 1Hz tick in an efficient way.
    integer tick_gen_counter = 0;
    always @(posedge clk) begin
        if (rst) begin
            tick <= 0;
            tick_gen_counter <= 0;
        end else begin
            if (tick_gen_counter == 9) begin
                tick <= 1;
                tick_gen_counter <= 0;
            end else begin
                tick <= 0;
                tick_gen_counter <= tick_gen_counter + 1;
            end
        end
    end

    // 5. Simulation Control and Stimulus
    initial begin
        // For waveform viewing
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        // Apply reset
        rst = 1;
        tick = 0;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        // Run simulation for a few full cycles and then stop
        #2000; // Run for 2000 time units
        $finish;
    end

endmodule