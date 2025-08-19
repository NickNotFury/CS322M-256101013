module traffic_light(
    input  wire clk,
    input  wire rst,         // sync active-high
    input  wire tick,        // 1-cycle per-second pulse
    output wire ns_g, ns_y, ns_r,
    output wire ew_g, ew_y, ew_r
);

    // 1. Define States using parameters for readability
    parameter NS_GREEN  = 2'b00;
    parameter NS_YELLOW = 2'b01;
    parameter EW_GREEN  = 2'b10;
    parameter EW_YELLOW = 2'b11;

    // Define timing constants
    parameter GREEN_TICKS = 5;
    parameter YELLOW_TICKS = 2;

    // 2. Internal Registers
    reg [1:0] current_state, next_state;
    reg [2:0] tick_counter; // Counter needs to hold up to 5, so 3 bits is enough

    // 3. Sequential Logic: State Register and Per-Phase Counter
    always @(posedge clk) begin
        if (rst) begin
            current_state <= NS_GREEN;
            tick_counter  <= 0;
        end else begin
            // On a state change, reset the counter. Otherwise, update the state.
            if (current_state != next_state) begin
                tick_counter <= 0;
            end else if (tick) begin // Increment counter only on a tick
                tick_counter <= tick_counter + 1;
            end
            current_state <= next_state;
        end
    end

    // 4. Combinational Logic: Next State Determination
    always @(*) begin
        next_state = current_state; // Default: stay in the same state
        case (current_state)
            NS_GREEN: begin
                if (tick && (tick_counter == GREEN_TICKS - 1)) begin
                    next_state = NS_YELLOW;
                end
            end
            NS_YELLOW: begin
                if (tick && (tick_counter == YELLOW_TICKS - 1)) begin
                    next_state = EW_GREEN;
                end
            end
            EW_GREEN: begin
                if (tick && (tick_counter == GREEN_TICKS - 1)) begin
                    next_state = EW_YELLOW;
                end
            end
            EW_YELLOW: begin
                if (tick && (tick_counter == YELLOW_TICKS - 1)) begin
                    next_state = NS_GREEN;
                end
            end
            default: next_state = NS_GREEN;
        endcase
    end

    // 5. Combinational Logic: Output Determination (Moore FSM)
    // Outputs are assigned using intermediate registers to be set by the case statement.
    reg ns_g_reg, ns_y_reg, ns_r_reg;
    reg ew_g_reg, ew_y_reg, ew_r_reg;

    assign ns_g = ns_g_reg;
    assign ns_y = ns_y_reg;
    assign ns_r = ns_r_reg;
    assign ew_g = ew_g_reg;
    assign ew_y = ew_y_reg;
    assign ew_r = ew_r_reg;

    always @(*) begin
        // Default all lights to off to avoid latches
        {ns_g_reg, ns_y_reg, ns_r_reg} = 3'b000;
        {ew_g_reg, ew_y_reg, ew_r_reg} = 3'b000;

        case (current_state)
            NS_GREEN: begin
                ns_g_reg = 1'b1; // NS is Green
                ew_r_reg = 1'b1; // EW is Red
            end
            NS_YELLOW: begin
                ns_y_reg = 1'b1; // NS is Yellow
                ew_r_reg = 1'b1; // EW is Red
            end
            EW_GREEN: begin
                ew_g_reg = 1'b1; // EW is Green
                ns_r_reg = 1'b1; // NS is Red
            end
            EW_YELLOW: begin
                ew_y_reg = 1'b1; // EW is Yellow
                ns_r_reg = 1'b1; // NS is Red
            end
            default: begin // Default to a safe state (all red)
                ns_r_reg = 1'b1;
                ew_r_reg = 1'b1;
            end
        endcase
    end

endmodule