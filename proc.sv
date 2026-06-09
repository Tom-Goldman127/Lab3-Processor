module proc (
    input  logic [8:0] DIN,
    input  logic       Resetn,
    input  logic       Clock,
    input  logic       Run,
    output logic       Done,
    output logic [8:0] BusWires
);

    parameter logic [1:0] T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11;

    // ==========================================
    // TODO: declare variables 
    // ==========================================
    logic [1:0] Tstep_D;
    logic [1:0] Tstep_Q;
    logic [7:0] Xreg, Yreg;
    logic [8:0] IR;
    logic [2:0] I;

    //signals for Mux and Regs
    logic DINout, Gout, IRin, Ain, Gin, AddSub;
    logic [7:0] Rin, Rout;

    // internal wires
    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G, ALU_Result;
    // =================================================================


    assign I = IR[8:6]; 

 
    dec3to8 decX (.W(IR[5:3]), .En(1'b1), .Y(Xreg));
    dec3to8 decY (.W(IR[2:0]), .En(1'b1), .Y(Yreg));

    // Control FSM state table
    always_comb begin
        case (Tstep_Q)
            T0: begin 
                if (!Run) Tstep_D = T0;
                else      Tstep_D = T1;
            end
            
            // ==========================================
            // TODO: Complete FSM implementation
            // ==========================================
            T1: begin
                // if I is mov or mvi we return to T0, otherwise we go to T2
                if (I == 3'b000 || I == 3'b001) 
                    Tstep_D = T0;
                else if (I == 3'010 || I == 3'011)
                    Tstep_D = T2;
                else
                    Tstep_D = T0; //preventing unknown state
            end

            T2: begin
                Tstep_D = T3;
            end

            T3: begin
                Tstep_D = T0;
            end
            // ==========================================
            default: Tstep_D = T0;
        endcase
    end

    // Control FSM outputs
    always_comb begin
        // ==========================================
        // TODO: specify initial values 
        // ==========================================
        IRin = 1'b0;
        DINout = 1'b0;
        Ain = 1'b0;
        Gin = 1'b0;
        Gout = 1'b0;
        AddSub = 1'b0;
        Rin = 8'b0;
        Rout = 8'b0;
        Done = 1'b0;
        case (Tstep_Q)
         // ==========================================
        
            T0: begin // Store DIN in IR in time step 0
                IRin = 1'b1;
            end
            
            T1: begin // Define signals in time step 1
                case (I)
                    // ==========================================
                    // TODO: Complete instruction decoding for T1

                    3'b000: begin // mv
                        Rout = Yreg; 
                        Rin = Xreg; 
                        Done = 1'b1;
                    end
                    3'b001: begin // mvi
                        DINout = 1'b1; 
                        Rin = Xreg; 
                        Done = 1'b1;
                    end
                    3'b010, 3'b011, 3'b100, 3'b101: begin // add, sub, ones, specialMult
                        Rout = Xreg; 
                        Ain = 1'b1; 
                    end
                    // ==========================================
                endcase
            end
            
            T2: begin // Define signals in time step 2
                case (I)
                    // ==========================================
                    // TODO: Complete instruction decoding for T2
                    3'b010: begin // add
                        Rout = Yreg;
                        Gin = 1'b1;
                    end
                    3'b011: begin // sub
                        Rout = Yreg;
                        Gin = 1'b1;
                        AddSub = 1'b1; // commit to subtraction in the ALU
                    end
                    3'b100, 3'b101: begin // ones, specialMult
                        Gin = 1'b1; // load Yreg to G
                    end
                    // ==========================================
                endcase
            end
            
            T3: begin // Define signals in time step 3
                case (I)
                    // ==========================================
                    // TODO: Complete instruction decoding for T3
                    3'b010, 3'b011: begin // add, sub
                        Gout = 1'b1;
                        Rin = Xreg;
                        Done = 1'b1;
                    end
                    3'b100, 3'b101: begin // ones, specialMult
                        Gout = 1'b1;
                        Rin = Yreg; 
                        Done = 1'b1;
                    end
                    // ==========================================
                endcase
            end
            default: ;
        endcase
    end

    // Control FSM flip-flops
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn) begin
            // ==========================================
            // TODO: Reset FSM FF implementation
            // ==========================================
            Tstep_Q <= T0;
            // ==========================================
        end else begin
            Tstep_Q <= Tstep_D;
        end
    end

    // Instantiations of registers
   
    regn #(.n(9)) reg_0 (.R(BusWires), .Rin(Rin[0]), .Clock(Clock), .Resetn(Resetn), .Q(R0));

    // ==========================================
    // TODO: Complete the proc implementation 
	//       based on the lab guidelines
    // ==========================================

endmodule

