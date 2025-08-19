`timescale 1ns/1ps
`include "vending_mealy.v"

// Testbench for vending_mealy module
module tb_vending_mealy;
    reg clk = 0;
    reg rst = 1;
    reg [1:0] coin = 2'b00;
    wire dispense, chg5;

    vending_mealy dut(
        .clk(clk), .rst(rst), .coin(coin),
        .dispense(dispense), .chg5(chg5)
    );

    // 100 MHz clk
    always #5 clk = ~clk;

    // Reset
    initial begin
        repeat (3) @(posedge clk);
        rst <= 0;
    end

    // Drive sequences
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_vending_mealy);

        @(negedge rst);
        @(posedge clk);

        // Test: 5+5+10=20
        coin <= 2'b01; @(posedge clk);
        coin <= 2'b00; @(posedge clk);
        coin <= 2'b01; @(posedge clk);
        coin <= 2'b00; @(posedge clk);
        coin <= 2'b10; @(posedge clk);
        coin <= 2'b00; @(posedge clk);

        // Test: 10+10=20
        coin <= 2'b10; @(posedge clk);
        coin <= 2'b00; @(posedge clk);
        coin <= 2'b10; @(posedge clk);
        coin <= 2'b00; @(posedge clk);

        // Test: 5+10+10=25 (dispense+chg5)
        coin <= 2'b01; @(posedge clk);
        coin <= 2'b00; @(posedge clk);
        coin <= 2'b10; @(posedge clk);
        coin <= 2'b00; @(posedge clk);
        coin <= 2'b10; @(posedge clk);
        coin <= 2'b00; @(posedge clk);

        repeat (5) @(posedge clk);
        $finish;
    end

    // Monitor
    initial begin
        $display(" time | coin dispense chg5");
        $display("-----------------------------");
        $monitor("%6t |  %02b      %0b      %0b",
                 $time, coin, dispense, chg5);
    end
endmodule