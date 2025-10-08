module mux2(
    input logic a,b,sel,
    output logic y 
);

always_comb begin // combinational logic, no need to assign y in multiple places, with blocking assignment
    y=sel ? b : a;
end

endmodule