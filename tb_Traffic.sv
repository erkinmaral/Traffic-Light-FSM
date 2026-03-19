// ============================================================
// Testbench for Traffic Light Controller FSM - ELE432 HW1
// File: tb_Traffic.sv
// ============================================================

`timescale 1ns/1ps

module tb_Traffic;

    // DUT inputs
    logic clk;
    logic reset;
    logic TAORB;

    // DUT outputs
    logic [1:0] LA;
    logic [1:0] LB;

    // Light encoding for readability
    localparam RED    = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN  = 2'b10;

    // Instantiate DUT
    Traffic dut (
        .clk   (clk),
        .reset (reset),
        .TAORB (TAORB),
        .LA    (LA),
        .LB    (LB)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Helper task to print light states
    task print_state;
        $write("t=%0t | TAORB=%b | LA=", $time, TAORB);
        case (LA)
            GREEN:  $write("GREEN ");
            YELLOW: $write("YELLOW");
            RED:    $write("RED   ");
        endcase
        $write(" | LB=");
        case (LB)
            GREEN:  $write("GREEN ");
            YELLOW: $write("YELLOW");
            RED:    $write("RED   ");
        endcase
        $display("");
    endtask

    // Stimulus
    initial begin
        $display("=== Traffic Light FSM Simulation ===");

        // Apply reset
        reset = 1;
        TAORB = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        $display("--- S0: LA=Green, LB=Red (TAORB=1, stay) ---");
        repeat(3) begin
            @(posedge clk); #1;
            print_state;
        end

        // Trigger S0 -> S1 transition
        $display("--- Transition to S1: TAORB -> 0 ---");
        TAORB = 0;
        repeat(8) begin
            @(posedge clk); #1;
            print_state;
        end

        // Now in S2 (after 5 cycles in S1)
        $display("--- S2: LA=Red, LB=Green (TAORB=0, stay) ---");
        repeat(3) begin
            @(posedge clk); #1;
            print_state;
        end

        // Trigger S2 -> S3 transition
        $display("--- Transition to S3: TAORB -> 1 ---");
        TAORB = 1;
        repeat(8) begin
            @(posedge clk); #1;
            print_state;
        end

        // Back to S0
        $display("--- Back to S0: LA=Green, LB=Red ---");
        repeat(3) begin
            @(posedge clk); #1;
            print_state;
        end

        $display("=== Simulation Complete ===");
        $stop;
    end

endmodule
