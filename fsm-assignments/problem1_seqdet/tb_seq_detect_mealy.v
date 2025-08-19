`timescale 1ns/1ps
`include "seq_detect_mealy.v"

// Testbench for seq_detect_mealy module
module tb_seq_detect_mealy;
    reg clk = 0;
    reg rst = 1;
    reg din = 0;
    wire y;

    seq_detect_mealy dut(
        .clk(clk), .rst(rst), .din(din), .y(y)
    );

    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    // Sync reset for 3 cycles
    initial begin
        repeat (3) @(posedge clk);
        rst <= 1'b0;
    end

    // Drive a bitstream with overlaps: 11011011101
    //    Also add a few extra clocks to observe stability
    reg [0:10] vec = 11'b11011011101; // MSB-first for readability
    integer i;
    initial begin
        // VCD
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        // Wait reset deassertion boundary to align with posedge
        @(negedge rst);
        @(posedge clk);

        for (i = 0; i < 11; i = i + 1) begin
            din <= vec[i];
            @(posedge clk);
        end
        // Hold low afterwards
        din <= 1'b0;
        repeat (5) @(posedge clk);
        $finish;
    end

    // Log time, din, y, and state via hierarchical reference (for debug)
    //    Why: aids waveform-less debug and confirms overlap behavior.
    initial begin
        $display("  time  | clk rst din | y ");
        $display("--------------------------------");
        $monitor("%7t |  %0b   %0b   %0b | %0b",
                 $time, clk, rst, din, y);
    end
endmodule