`timescale 1ns/1ns
`include "myxor.v"
module tb;
    reg a;
    reg b;
    wire y;

    // Instantiate the myxor module
    myxor dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $dumpfile("myxor.vcd"); // Create a VCD file for waveform viewing
        $dumpvars(0, tb); // Dump all variables in the testbench
        // Test cases
        a = 0; b = 0; #10; // Test case 1: 0 XOR 0
        // $display("a=%b, b=%b, y=%b", a, b, y);
        a = 0; b = 1; #10; // Test case 2: 0 XOR 1
        // $display("a=%b, b=%b, y=%b", a, b, y);
        a = 1; b = 0; #10; // Test case 3: 1 XOR 0
        // $display("a=%b, b=%b, y=%b", a, b, y);
        a = 1; b = 1; #10; // Test case 4: 1 XOR 1
        // $display("a=%b, b=%b, y=%b", a, b, y);
        // End of test cases
        $display("Test completed.");    

        $finish; // End the simulation
    end
endmodule