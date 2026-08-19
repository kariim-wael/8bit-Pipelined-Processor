
module hazard_detection_unit (

    // From ID/EX Pipeline Register
    input wire        ID_EX_memRead,        // for load instructions (LDD, LDI)
    input wire [1:0]  ID_EX_rd,             // Destination register of load in EX stage
    
    // From IF/ID Register (current instruction being decoded)
    input wire [7:0]  IF_ID_instruction,    // Current instruction in Decode stage
    
    // Outputs to Control Hazard Resolution
    output reg        stall,                // Stall signal to Fetch Stage (freeze PC)
    output reg        IF_ID_write_en,       // Enable for IF/ID register (0 = freeze)
    output reg        control_mux_sel       // 1 = Insert bubble (NOP) in ID/EX
);

    // Take ra and rb and opcode from current instruction
    wire [1:0] IF_ID_ra;
    wire [1:0] IF_ID_rb;
    wire [3:0] IF_ID_opcode;
    
    assign IF_ID_opcode = IF_ID_instruction[7:4];
    assign IF_ID_ra     = IF_ID_instruction[3:2];
    assign IF_ID_rb     = IF_ID_instruction[1:0];
    
    // current instruction uses ra or rb as source operands or not 
    reg uses_ra, uses_rb;
    
    always @(*) 
    begin
        // Default: no register usage
        uses_ra = 1'b0;
        uses_rb = 1'b0;
        
        case (IF_ID_opcode)
            // A-Format 
            4'h1: 
            begin // MOV
                uses_rb = 1'b1;
            end
            
            4'h2, 4'h3, 4'h4, 4'h5: 
            begin // ADD, SUB, AND, OR: use both ra and rb
                uses_ra = 1'b1;
                uses_rb = 1'b1;
            end
            
            4'h6: 
            begin // RLC, RRC, SETC, CLRC
                if (IF_ID_ra == 2'b00 || IF_ID_ra == 2'b01) // RLC, RRC use rb
                    uses_rb = 1'b1;
                // SETC, CLRC don't use registers
            end
            
            4'h7: 
            begin // PUSH, POP, OUT, IN
                if (IF_ID_ra == 2'b00 || IF_ID_ra == 2'b10) // PUSH, OUT use rb
                    uses_rb = 1'b1;
                // POP, IN write to rb (destination, not source)
            end
            
            4'h8: 
            begin // NOT, NEG, INC, DEC
                uses_rb = 1'b1;
            end
            
            // B-Format instructions
            4'h9: 
            begin // JZ, JN, JC, JV
                uses_rb = 1'b1;
            end
            
            4'hA: 
            begin // LOOP
                uses_ra = 1'b1;
                uses_rb = 1'b1;
            end
            
            4'hB: 
            begin // JMP, CALL, RET, RTI
                if (IF_ID_ra == 2'b00 || IF_ID_ra == 2'b01) // JMP, CALL 
                    uses_rb = 1'b1;
                // RET, RTI don't use register operands (use stack)
            end
            
            // L-Format 
            4'hC: 
            begin // LDM, LDD, STD
                if (IF_ID_ra == 2'b10) // STD 
                    uses_rb = 1'b1;
                // LDM, LDD write to rb (destination)
            end
            
            4'hD: 
            begin // LDI
                uses_ra = 1'b1;
            end
            
            4'hE: 
            begin // STI
                uses_ra = 1'b1;
                uses_rb = 1'b1;
            end
            
            default: 
            begin
                uses_ra = 1'b0;
                uses_rb = 1'b0;
            end
        endcase
    end
    
    // Hazard Detection Logic
    always @(*) 
    begin
        // Default
        stall            = 1'b0;
        IF_ID_write_en   = 1'b1;
        control_mux_sel  = 1'b0;
        
        // Detect  Hazard
        if (ID_EX_memRead) 
        begin
 
            if ((uses_ra && (ID_EX_rd == IF_ID_ra)) || 
                (uses_rb && (ID_EX_rd == IF_ID_rb))) 
                begin                
                // Stall the pipeline
                stall            = 1'b1;  // Freeze PC
                IF_ID_write_en   = 1'b0;  // Freeze IF/ID register
                control_mux_sel  = 1'b1;  // Insert bubble (NOP control signals to EX stage)
            end
        end
    end

endmodule
