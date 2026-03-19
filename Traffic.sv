// ============================================================
// Traffic Light Controller FSM - ELE432 HW1
// File: Traffic.sv
// Description: 4-state FSM with 5-cycle yellow light delay
// Inputs:  clk, reset, TAORB
// Outputs: LA (Street A light), LB (Street B light)
//          2-bit encoding: 00=Red, 01=Yellow, 10=Green
// ============================================================

module Traffic (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,
    output logic [1:0] LA,   // Street A: 10=Green, 01=Yellow, 00=Red
    output logic [1:0] LB    // Street B: 10=Green, 01=Yellow, 00=Red
);

    // Light encoding
    localparam RED    = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN  = 2'b10;

    // State encoding
    localparam S0 = 2'b00;  // LA=Green,  LB=Red
    localparam S1 = 2'b01;  // LA=Yellow, LB=Red    (5-cycle hold)
    localparam S2 = 2'b10;  // LA=Red,    LB=Green
    localparam S3 = 2'b11;  // LA=Red,    LB=Yellow (5-cycle hold)

    logic [1:0] state, next_state;
    logic [2:0] timer;          // counts 0..5

    // --------------------------------------------------------
    // Block 1: State Register (sequential)
    // --------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 3'd0;
        end else begin
            state <= next_state;
            // Timer: increment in S1/S3, reset when leaving
            if (state == S1 || state == S3) begin
                if (next_state == state)
                    timer <= timer + 1;
                else
                    timer <= 3'd0;
            end else begin
                timer <= 3'd0;
            end
        end
    end

    // --------------------------------------------------------
    // Block 2: Next-State Logic (combinational)
    // --------------------------------------------------------
    always_comb begin
        next_state = state; // default: stay
        case (state)
            S0: begin
                if (!TAORB)
                    next_state = S1;
            end
            S1: begin
                if (timer == 3'd5)
                    next_state = S2;
            end
            S2: begin
                if (TAORB)
                    next_state = S3;
            end
            S3: begin
                if (timer == 3'd5)
                    next_state = S0;
            end
            default: next_state = S0;
        endcase
    end

    // --------------------------------------------------------
    // Block 3: Output Logic (combinational)
    // --------------------------------------------------------
    always_comb begin
        case (state)
            S0: begin LA = GREEN;  LB = RED;    end
            S1: begin LA = YELLOW; LB = RED;    end
            S2: begin LA = RED;    LB = GREEN;  end
            S3: begin LA = RED;    LB = YELLOW; end
            default: begin LA = RED; LB = RED;  end
        endcase
    end

endmodule
