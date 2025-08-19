module vending_mealy(
    input  wire clk,
    input  wire rst,      // synchronous, active-high
    input  wire [1:0] coin, // 01=5, 10=10, 00=idle (ignore 11)
    output wire dispense, // 1-cycle pulse when total >=20
    output wire chg5      // 1-cycle pulse when total==25
);
    // State encoding
    localparam [1:0]
        S0  = 2'b00,
        S5  = 2'b01,
        S10 = 2'b10,
        S15 = 2'b11;

    reg [1:0] state, next_state;
    reg dispense_c, chg5_c;

    // Next-state & Mealy outputs
    always @* begin
        next_state = state;
        dispense_c = 1'b0;
        chg5_c = 1'b0;
        case (state)
            S0: begin
                if (coin == 2'b01) next_state = S5;
                else if (coin == 2'b10) next_state = S10;
            end
            S5: begin
                if (coin == 2'b01) next_state = S10;
                else if (coin == 2'b10) next_state = S15;
            end
            S10: begin
                if (coin == 2'b01) next_state = S15;
                else if (coin == 2'b10) begin
                    dispense_c = 1'b1; // total=20
                    next_state = S0;
                end
            end
            S15: begin
                if (coin == 2'b01) begin
                    dispense_c = 1'b1; // total=20
                    next_state = S0;
                end else if (coin == 2'b10) begin
                    dispense_c = 1'b1; // total=25
                    chg5_c = 1'b1;
                    next_state = S0;
                end
            end
        endcase
    end

    // State register with synchronous reset
    always @(posedge clk) begin
        if (rst) state <= S0;
        else state <= next_state;
    end

    assign dispense = dispense_c;
    assign chg5 = chg5_c;
endmodule