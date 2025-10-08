`timescale 1ns/1ps
`default_nettype none

module tb_counter;
    parameter WIDTH=4; // number of bits

    logic clk=0, rst_n=0, en=0, up=1;
    logic [WIDTH-1:0] q;

    counter #( .WIDTH(WIDTH) ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .up(up),
        .q(q)
    );

    //100MHz-ish clock
    always #5 clk = ~clk; // 10 time units clock period

    task step(input int n=1);
        repeat (n) @(posedge clk);
    endtask

    initial begin
        $dumpfile("tb_counter.vcd");
        $dumpvars(0, tb_counter);

        //release reset
        step(1);
        rst_n = 1; // release reset
        step(1);
        rst_n = 0; // assert reset
        // step(1);

        //count up 3 stages
        en=1; up=1; step(3);
        assert(q == 3) else $fatal(1, "Up count failed q=%0d", q);

        //count down 2 stages 
        up=0; step(2);
        assert(q == 1) else $fatal(1, "Down Count failed q=%0d", q);

        //hold
        en=0; step(3); #1
        assert(q == 1) else $fatal(1, "Hold failed");

        $display("[COUNTER] All tests completed");
        $finish;
    end
endmodule

`default_nettype wire