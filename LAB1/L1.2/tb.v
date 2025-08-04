`include "fourBitEqualityComparator.v"
module tb;
    reg  [3:0] a, b;
    wire       equal;

    fourBitEqualityComparator uut (
        .a(a),
        .b(b),
        .equal(equal)
    );

    initial begin
        $dumpfile("fourBitEqualityComparator.vcd");
        $dumpvars(0, tb);
        $display("a    b    | Equal");
        $monitor("%b %b |   %b", a, b, equal);

        a = 4'b0001; b = 4'b0000; #10;


        $finish;
    end
endmodule