module master_fsm(
    input  wire clk,
    input  wire rst,   // sync active-high
    input  wire ack,
    output reg  req,
    output reg  [7:0] data,
    output reg  done
);
    localparam [2:0]
        IDLE        = 3'd0,
        SEND        = 3'd1,
        WAIT_ACK    = 3'd2,
        WAIT_ACK_LO = 3'd3,
        DONE        = 3'd4;

    reg [2:0] state, next_state;
    reg [1:0] byte_idx, next_idx;
    reg [7:0] next_data;
    reg next_req, next_done;

    // fixed data sequence A0..A3
    function [7:0] byte_val(input [1:0] idx);
        case (idx)
            2'd0: byte_val = 8'hA0;
            2'd1: byte_val = 8'hA1;
            2'd2: byte_val = 8'hA2;
            2'd3: byte_val = 8'hA3;
        endcase
    endfunction

    always @* begin
        next_state = state;
        next_idx   = byte_idx;
        next_data  = data;
        next_req   = req;
        next_done  = 1'b0;

        case (state)
            IDLE: begin
                next_idx   = 0;
                next_data  = byte_val(0);
                next_req   = 1'b1;
                next_state = SEND;
            end
            SEND: begin
                next_state = WAIT_ACK;
            end
            WAIT_ACK: begin
                if (ack) begin
                    next_req   = 1'b0; // drop req
                    next_state = WAIT_ACK_LO;
                end
            end
            WAIT_ACK_LO: begin
                if (!ack) begin
                    if (byte_idx == 2'd3) begin
                        next_done  = 1'b1;
                        next_state = DONE;
                    end else begin
                        next_idx   = byte_idx + 1;
                        next_data  = byte_val(byte_idx + 1);
                        next_req   = 1'b1;
                        next_state = SEND;
                    end
                end
            end
            DONE: begin
                next_state = DONE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            byte_idx <= 0;
            data     <= 8'h00;
            req      <= 1'b0;
            done     <= 1'b0;
        end else begin
            state    <= next_state;
            byte_idx <= next_idx;
            data     <= next_data;
            req      <= next_req;
            done     <= next_done;
        end
    end
endmodule