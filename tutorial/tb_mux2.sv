`timescale 1ns/1ps    // 1ns= time unit, 1ps=time precision
`default_nettype none

module tb_mux2;
    logic a,b,sel,y;
    mux2 dut(.a(a),.b(b),.sel(sel),.y(y));
initial begin
    $dumpfile("tb_mux2.vcd");
    $dumpvars(0,tb_mux2);

    a=0;b=1;sel=0; #1;
    assert(y==a) else $fatal(1, "sel=0 expected y=a");

    sel=1; #1;
    assert(y==b) else $fatal(1, "sel=1 expected y=b");

    repeat (8) begin
        {a,b,sel} = $urandom_range(0,1); #1;
        assert(y == (sel ? b : a)) else     // assert= useful for self-checking testbenches
            $fatal(1, "Mismatch rand");
    end
    $display("[MUX2] All tests passed");
    $finish;
end 
endmodule

`default_nettype wire   //nettype back to default