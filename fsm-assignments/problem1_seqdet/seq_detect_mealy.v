module seq_detect_mealy(
    input  wire clk,
    input  wire rst,  // synchronous, active-high
    input  wire din,  // serial input bit per clock
    output wire y     // 1-cycle pulse when pattern ...1101 seen
);
    // State encoding
    parameter init = 2'b00; // no match
    parameter one   = 2'b01; // seen '1'
    parameter two  = 2'b10; // seen '11'
    parameter three = 2'b11; // seen '110'

    reg [1:0] state_present, state_next;

    // State register (sync reset)
    always @(posedge clk) begin
        if (rst) state_present <= init;
        else     state_present <= state_next;
    end

    // Next state logic
    always @(*) begin
        case (state_present)
            init:   if (din) state_next = one;   else state_next = init;
            one:   if (din) state_next = two;  else state_next = init;
            two:  if (din) state_next = two;  else state_next = three;
            three: if (din) state_next = one;   else state_next = init;
            default: state_next = init;
        endcase
    end

    // Mealy output logic (pulse when in three and din==1)
    assign y = (state_present == three && din);

endmodule