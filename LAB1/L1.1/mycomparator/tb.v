`include "mycomparator.v"
module tb;
    reg a,b;
    wire o1, o2, o3;

    mycomparator uut (
        .a(a),
        .b(b),
        .o1(o1),
        .o2(o2),
        .o3(o3)
    );

    initial begin
        $dumpfile("mycomparator.vcd");
        $dumpvars(0, tb);
        $display("a b | o1 o2 o3");
        $monitor("%b %b |  %b  %b  %b", a, b, o1, o2, o3);

        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish;
    end
endmodule
    