module counter #(
    parameter WIDTH=8  // number of bits
)(
    input logic clk, 
    input logic rst_n, // async active low reset
    input logic en,
    input logic up, // 1: count up, 0: count down
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or posedge rst_n) begin // sequential logic with unblocking assignment
        if (rst_n)
            q <= '0;   // reset to 0
        else if (en)
            q <= up ? (q+1'b1) : (q-1'b1);  //combinational logic
    end
endmodule