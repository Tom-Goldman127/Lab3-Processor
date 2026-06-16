module proc (
    input  logic [8:0] DIN,
    input  logic       Resetn,
    input  logic       Clock,
    input  logic       Run,
    output logic       Done,
    output logic [8:0] BusWires // לבדוק איפה מוסיפים סימן
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
    logic DINout, Gout, IRin, Ain, Gin;
    logic [1:0] AddSub; // signal to determine whether the ALU should perform addition or subtraction or other operations
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
                else if (I == 3'b010 || I == 3'b011)
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
                        addSub = 2'b00; // commit to addition in the ALU (though ALU is not used in this instruction, we set it to a known state)
                        // לעשות את הaddSub בכל קייס
                    end
                    3'b001: begin // mvi
                        DINout = 1'b1; 
                        Rin = Xreg; 
                        Done = 1'b1;
                    end
                    3'b010, 3'b011, 3'b100, 3'b101: begin // add, sub, ones, specialMult //להפריד כל אחד לקייסים
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
    regn #(.n(9)) reg_1 (.R(BusWires), .Rin(Rin[1]), .Clock(Clock), .Resetn(Resetn), .Q(R1));
    regn #(.n(9)) reg_2 (.R(BusWires), .Rin(Rin[2]), .Clock(Clock), .Resetn(Resetn), .Q(R2));
    regn #(.n(9)) reg_3 (.R(BusWires), .Rin(Rin[3]), .Clock(Clock), .Resetn(Resetn), .Q(R3));
    regn #(.n(9)) reg_4 (.R(BusWires), .Rin(Rin[4]), .Clock(Clock), .Resetn(Resetn), .Q(R4));
    regn #(.n(9)) reg_5 (.R(BusWires), .Rin(Rin[5]), .Clock(Clock), .Resetn(Resetn), .Q(R5));
    regn #(.n(9)) reg_6 (.R(BusWires), .Rin(Rin[6]), .Clock(Clock), .Resetn(Resetn), .Q(R6));
    regn #(.n(9)) reg_7 (.R(BusWires), .Rin(Rin[7]), .Clock(Clock), .Resetn(Resetn), .Q(R7));
    // registers for A, G and IR
    regn #(.n(9)) reg_A  (.R(BusWires), .Rin(Ain), .Clock(Clock), .Resetn(Resetn), .Q(A));
    regn #(.n(9)) reg_G  (.R(ALU_Result), .Rin(Gin), .Clock(Clock), .Resetn(Resetn), .Q(G));
    regn #(.n(9)) reg_IR (.R(DIN), .Rin(IRin), .Clock(Clock), .Resetn(Resetn), .Q(IR)); // IR is loaded directly from DIN

    always_comb begin 
        // BusWires is determined by the control signals. Only one of these signals should be active at a time.
        if (DINout) BusWires = DIN;
        else if (Gout) BusWires = G;
        else if (Rout[0]) BusWires = R0;
        else if (Rout[1]) BusWires = R1;
        else if (Rout[2]) BusWires = R2;
        else if (Rout[3]) BusWires = R3;
        else if (Rout[4]) BusWires = R4;
        else if (Rout[5]) BusWires = R5;
        else if (Rout[6]) BusWires = R6;
        else if (Rout[7]) BusWires = R7;
        else BusWires = 9'b0; // default value when no output is selected
    end

    always_comb begin
        case (I)
            addSub = 2'b0 : ALU_Result = A + BusWires; // if I is add, ALU_Result is the sum of A and the value on the bus
            // לעשות כמו שורה למעלה לכל קייס
            3'b011:  ALU_Result = A - BusWires; // if I is sub, ALU_Result is the difference of A and the value on the bus
            3'b100: begin // Ones command
                ALU_Result = 9'b0;
                for (int i = 0; i < 9; i = i + 1) begin
                    ALU_Result = ALU_Result + A[i];
                end
            end
            3'b101: begin // specialMult command
                // Math: X * 3.5 = X * 2 + X + X/2
                // In hardware, multiplication by 2 is a left shift, and division by 2 is a right shift
                ALU_Result = (A <<< 1) + A + (A >>> 1);
            end
            default: ALU_Result = 9'b0; // default value when the instruction does not involve the ALU
        endcase
    end
    // ==========================================
endmodule

