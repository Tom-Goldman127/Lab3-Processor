`timescale 1ns / 1ps

module proc_tb;

    // ==========================================
    // Wires and variables for DUT connections
    // ==========================================
    logic [8:0] DIN;
    logic       Resetn;
    logic       Clock;
    logic       Run;
    logic       Done;
    logic [8:0] BusWires;

    // ==========================================
    // Instantiate the Device Under Test (DUT)
    // ==========================================
    proc DUT (
        .DIN(DIN),
        .Resetn(Resetn),
        .Clock(Clock),
        .Run(Run),
        .Done(Done),
        .BusWires(BusWires)
    );

    // ==========================================
    // Clock generation: 20ns period (toggle every 10ns)
    // ==========================================
    always #10 Clock = ~Clock;

    initial begin
        // ==========================================
        // Step 1: System Initialization (Reset)
        // ==========================================
        Clock = 0;
        Run = 0;
        DIN = 9'b0;
        Resetn = 0; // Assert reset (active low)
        #40;        // Wait 2 clock cycles to ensure full reset
        Resetn = 1; // De-assert reset
        Run = 1;    // Enable FSM to run indefinitely

        // ==========================================
        // Step 2: mvi R1, #15
        // ==========================================
        DIN = 9'b001_001_000; // Opcode: mvi R1
        #20;                  // Wait for T0 (Load IR)
        DIN = 9'd15;          // Immediate data: 15
        #20;                  // Wait for T1 (Load R1)

        // ==========================================
        // Step 3: mvi R2, #5
        // ==========================================
        DIN = 9'b001_010_000; // Opcode: mvi R2
        #20;
        DIN = 9'd5;           // Immediate data: 5
        #20;

        // ==========================================
        // Step 4: mv R4, R1
        // ==========================================
        DIN = 9'b000_100_001; // Opcode: mv R4, R1
        #40;                  // Wait 2 clock cycles (T0 to read, T1 to execute)

        // ==========================================
        // Step 5: add R1, R2
        // ==========================================
        DIN = 9'b010_001_010; // Opcode: add R1, R2
        #80;                  // Wait 4 clock cycles (T0, T1, T2, T3)

        // ==========================================
        // Step 6: sub R1, R2
        // ==========================================
        DIN = 9'b011_001_010; // Opcode: sub R1, R2
        #80;                  // Wait 4 clock cycles (T0, T1, T2, T3)

        // ==========================================
        // Steps 7 & 8: Pre-condition and specialMult
        // ==========================================
        // Pre-condition: Load 4 into R0
        DIN = 9'b001_000_000; // Opcode: mvi R0
        #20;
        DIN = 9'd4;           // Immediate data: 4
        #20;

        // Execute Bonus 1: specialMult (R0 * 3.5 -> R5)
        DIN = 9'b101_000_101; // Opcode: specialMult R0, R5
        #80;                  // Wait for T3 to complete. Result in R5 should be 14.

        // ==========================================
        // Step 9: Bonus 2 - ones bit counting
        // ==========================================
        // Note: R1 currently holds 15 (000001111) from the previous 'sub' operation.
        // Counting active bits should yield exactly 4.
        DIN = 9'b100_001_110; // Opcode: ones R1, R6
        #80;                  // Result in R6 should be 4.

        // ==========================================
        // Step 10: Pre-condition for Overflow
        // ==========================================
        // Load Max Positive (255) to R1, and 1 to R2
        DIN = 9'b001_001_000; // Opcode: mvi R1
        #20;
        DIN = 9'b011_111_111; // Data: +255
        #20;
        
        DIN = 9'b001_010_000; // Opcode: mvi R2
        #20;
        DIN = 9'b000_000_001;           // Data: +1
        #20;

        // ==========================================
        // Step 11: Execute Overflow (255 + 1)
        // ==========================================
        DIN = 9'b010_001_010; // Opcode: add R1, R2
        #80;                  // Result flips to -256 (100_000_000) in R1

        // ==========================================
        // Step 12: Pre-condition for Underflow
        // ==========================================
        // Load Min Negative (-256) to R1, and 1 to R2
        DIN = 9'b001_001_000; // Opcode: mvi R1
        #20;
        DIN = 9'b100_000_000; // Data: -256
        #20;
        
        DIN = 9'b001_010_000; // Opcode: mvi R2
        #20;
        DIN = 9'b000_000_001;           // Data: +1
        #20;

        // ==========================================
        // Step 13: Execute Underflow (-256 - 1)
        // ==========================================
        DIN = 9'b011_001_010; // Opcode: sub R1, R2
        #80;                  // Result flips to +255 (011_111_111) in R1

        // ==========================================
        // End of Simulation
        // ==========================================
        #40;
        $stop; // Suspend simulation
    end

endmodule