//one-bit comparator
module mycomparator(
    input a,
    input b,
    output o1,
    output o2,
    output o3
);
    assign o1=a&~b;
    assign o2=~(a^b);
    assign o3=~a&b;
endmodule

