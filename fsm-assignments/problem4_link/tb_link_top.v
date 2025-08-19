`timescale 1ns/1ps
`include "link_top.v"

module tb_link_top;
    reg clk = 0;
    reg rst = 1;
    wire done;

    link_top dut(.clk(clk), .rst(rst), .done(done));

    // clock
    always #5 clk = ~clk;

    // reset
    initial begin
        repeat (3) @(posedge clk);
        rst <= 0;
    end

    // sim control
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_link_top);
        wait(done);
        repeat (5) @(posedge clk);
        $finish;
    end

    // monitor handshake
    initial begin
        $display(" time | req ack data done");
        $display("---------------------------");
        $monitor("%6t |  %0b   %0b  %02h   %0b",
                 $time,
                 dut.u_master.req,
                 dut.u_slave.ack,
                 dut.u_master.data,
                 done);
    end
endmodule