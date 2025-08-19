module slave_fsm(
    input  wire clk,
    input  wire rst,
    input  wire req,
    input  wire [7:0] data_in,
    output reg  ack,
    output reg  [7:0] last_byte
);
    localparam [1:0] IDLE=2'd0, ACK1=2'd1, ACK2=2'd2;

    reg [1:0] state, next_state;
    reg [7:0] next_last;
    reg next_ack;

    always @* begin
        next_state = state;
        next_ack   = ack;
        next_last  = last_byte;

        case (state)
            IDLE: begin
                if (req) begin
                    next_last  = data_in;
                    next_ack   = 1'b1;
                    next_state = ACK1;
                end
            end
            ACK1: begin
                next_state = ACK2;
            end
            ACK2: begin
                next_ack   = 1'b0;
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            ack       <= 1'b0;
            last_byte <= 8'h00;
        end else begin
            state     <= next_state;
            ack       <= next_ack;
            last_byte <= next_last;
        end
    end
endmodule