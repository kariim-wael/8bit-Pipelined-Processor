
module Processor_TopLevel (
    input  wire       clk,
    input  wire       rst,				// reset signal
    input  wire       interrupt,		// a single, non-maskable interrupt
    
    // I/O Ports
    input  wire [7:0] in_port_val,		// input port
    output wire [7:0] out_port_val		// output port
);

    // ====================================================
    // 1. Interconnecting Wires
    // ====================================================

    
	wire    [7:0] W1,W2,W3,W4,W5,W6,W7,W8,W9,W10,
               W11,W12,W13,W14,W15,W16,W17,W18,
               W19,W20,W21,W22,W23,W24,W25,W26,
               W27,W28,W29,W30,W31,W32,W33,W34,W40;

    reg [7:0] W35,W36;
	
	wire    L1,L2,L3,L4,L5;
	
	wire    [3:0] M1,M2,M3,M4;

    wire    U5,U6,U7;

    wire    [1:0] J1,J2,J3,J4;
	
	
    wire    [3:0] Q1,Q2,Q3,Q4;

    wire 	[1:0] A1,A2,A3,A4,A5,A6,A7,A8;

    reg     [1:0] A9,A10;

    wire    F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12;

    wire    [1:0] G6,G7,G8,G9,G10;

    wire     U1,U2,U3,U4;

    wire    [3:0] B1;

    wire     X7,X2,X3,X4,X5,X6,X8,X9,X10,X11,X12;

    wire    [1:0] G1,G2,G3,G4,G5;

    reg     [7:0] OUT_PORT_REG;  // Internal register to hold the value    


    wire     H1,H2,H3,H4,H5,H6,H7,H8,H9,H10,H11,H12,H13,H14,H15;


    // ====================================================
    // 2. Module Instantiations
    // ====================================================

    // Stage 1: Fetch 
    FetchStage U_Fetch (
        .clk            (clk),
        .rst            (rst),
        .stall          (H1), 
        .interrupt_sig  (interrupt), 
        
        // Inputs
        .pc_src_sel     (A1),		// c decode
        .branch_target  (W8),		// (R[rb])
        .return_target  (W34),		// (M[++SP])
        
        // Outputs
        .current_pc     (W1),
        .pc_plus_1      (W2),
        .instruction    (W3)
    );






    // Pipeline Register: IF/ID 
    IF_ID_register U_IF_ID_Reg (
        .clk            (clk),
        .rst            (rst),
        .stall          (!H2),
        .flush          (L5),

        // Inputs
        .current_pc_in  (W1),
        .pc_plus_1_in   (W2),
        .instruction_in (W3),
        
        // Outputs
        .current_pc_out (W4),
        .pc_plus_1_out  (W5),
        .instruction_out(W6)	// IR
    );



    // Stage 2: Decode & Write Back >> Register File 
    decode_wb_stage U_Decode_WB (
        .clk            (clk),
        .rst            (rst),
        
        // Inputs from IF/ID
        .ra             (W6[3:2]), 
        .rb             (W6[1:0]), 
        
		
		// Control Inputs (Decode) direct
        .rb_e           (F1),
        .Sel_ReadAddr2  (F2),
		.SP_Inc         (F3),
		
		
        // Inputs from MEM/WB (Write Back Loop)
        .alu_out        (W31),
        .mem_out        (W32),
        .in_port        (in_port_val),
        .imm            (W27),		// IR
        .ra_i           (W27[3:2]), 
        .rb_i           (W27[1:0]), 

        
        // Control Inputs (Write Back)
        .Sel_WriteData  (J1),
        .Sel_WriteAddr  (J2),
        .wr_en          (U6), 
        .SP_Dec         (X8),     

        // Outputs
        .rd_data1       (W7),
        .rd_data2       (W8),
        .SP_Out         (W9),

        .DATA_OUT       (W40),

        .RTI_SP         (W33)
    );






    // Pipeline Register: ID/EX
    ID_EX_register U_ID_EX_Reg (
        .clk            (clk),
        .rst            (rst),
        .stall          (1'b0),
        .flush          (H3),

        // Data Inputs
        .IR_in          (W6),
        .reg_ra_data_in (W7),
        .reg_rb_data_in (W8),
        .sp_in          (W9),
        .pc_in          (W4),
        .pc_in_plus_1   (W5),

        // Control Inputs

        .alu_control_in (Q1),
        .FlagWriteEnable_in (F4),
        .interrupt_restore_flags_in (F5),
        .interrupt_save_flags_in (F6),
        .SetC_in (F7),
        .ClrC_in (F8),

        .mem_write_en_in (F9),
        .mem_R_addr_sel_in (A2),
        .mem_W_addr_sel_in (A3),
        .mem_W_data_sel_in (A4),

        .Sel_WriteData_in (A5),
        .Sel_WriteAddr_in (A6),
        .SP_Dec_in (F10),
        .wr_en_in (F11),

        .hazard_detection_unit_in (H5),

        .Ex_MEM_regwrite_in (H9),
        .MEM_WB_regwrite_in (H10),

        .out_port_en_in (F12),


        // Data Outputs
        .IR_out         (W10),
        .reg_ra_data_out(W11),
        .reg_rb_data_out(W12),
        .sp_out         (W13),
        .pc_out         (W14),
        .pc_out_plus_1  (W15),
        
        // Control Outputs
		
        .alu_control_out (B1),
        .FlagWriteEnable_out (X7),
        .interrupt_restore_flags_out (X2),
        .interrupt_save_flags_out (X3),
        .SetC_out (X4),
        .ClrC_out (X5),

        .mem_write_en_out (X6),
        .mem_R_addr_sel_out (G1),
        .mem_W_addr_sel_out (G2),
        .mem_W_data_sel_out (G3),

        .Sel_WriteData_out (G4),
        .Sel_WriteAddr_out (G5),
        .SP_Dec_out (X8),
        .wr_en_out (X9),

        .hazard_detection_unit_out (H6),

        .Ex_MEM_regwrite_out (H11),
        .MEM_WB_regwrite_out (H12),

        .out_port_en_out (X10)    

    );





    // Stage 3: Execute 
    ExecuteStage U_Execute (
        .clk            (clk),
        .rst            (rst),
        
        // Inputs
        .A              (W35), // forward mux output
        .B              (W36), // forward mux output
		
		// Control signals comes from ID/EX Register
        .ALUControl     (B1),
        .FlagWriteEnable(X7),
        .interrupt_restore_flags(X2),
        .interrupt_save_flags   (X3),
        .SetC           (X4),
        .ClrC           (X5),

        // Outputs
        .ALUResult      (W16),
        .Z              (L1),
        .N              (L2),
        .C              (L3),
        .V              (L4)
    );






    // Pipeline Register: EX/MEM 
    EX_M_register U_EX_MEM_Reg (
        .clk            (clk),
        .rst            (rst),


        // Data Inputs
        .current_pc_in  (W14),
        .pc_plus_1_in   (W15),
        .instruction_in (W10),
        .reg_ra_data_in (W11), 
        .reg_rb_data_in (W12), 
        .sp_in          (W13),
        .alu_result_in  (W16),
        .ccr_flags_in   ({L4,L3,L2,L1}),

        // Control Inputs

        .mem_write_en_in (X6),
        .mem_R_addr_sel_in (G1),
        .mem_W_addr_sel_in (G2),
        .mem_W_data_sel_in (G3),

        .Sel_WriteData_in (G4),
        .Sel_WriteAddr_in (G5),
        .SP_Dec_in (X8),
        .wr_en_in (X9),

        .Ex_MEM_regwrite_in (H11),
        .MEM_WB_regwrite_in (H12),

        .out_port_en_in (X10),

        // Data Outputs
        .current_pc_out (W17),
        .pc_plus_1_out  (W18),
        .instruction_out(W19),
        .reg_ra_data_out(W20),
        .reg_rb_data_out(W21),
        .sp_out         (W22),
        .alu_result_out (W23),
        .ccr_flags_out  (M1),

        // Control Outputs

        .mem_write_en_out (U1),
        .mem_R_addr_sel_out (G6),
        .mem_W_addr_sel_out (G7),
        .mem_W_data_sel_out (G8),

        .Sel_WriteData_out (G9),
        .Sel_WriteAddr_out (G10),
        .SP_Dec_out (U2),
        .wr_en_out (U3),

        .Ex_MEM_regwrite_out (H13),
        .MEM_WB_regwrite_out (H14),

        .out_port_en_out (U4) 


    );





    // Stage 4: Memory 
    MemoryStage U_Memory (
        .clk            ( clk ),
        
        // Control Inputs
        .mem_write_en   (U1),
        .mem_R_addr_sel (G6),
        .mem_W_addr_sel (G7),
        .mem_W_data_sel (G8),

        // Data Inputs comes from EX/MEM Register
        .sp             (W22),
        .ea             (W19),		// IR
        .r_ra_val       (W20),
        .r_rb_val       (W21),
        .current_pc     (W17),
        .pc_plus_1      (W18),
        .RTI_SP_IN      (W33),         // Current SP value for RTI and RET instructions

        // Output
        .m_out          (W24),
        .RTI_SP_OUT     (W34)
    );






    // Pipeline Register: MEM/WB 
    MEM_WB_Register U_MEM_WB_Reg (
        .clk            (clk),
        .rst            (rst),

        // Data Inputs
        .current_pc_in  (W17),
        .pc_plus_1_in   (W18),
        .instruction_in (W19),
        .reg_ra_data_in (W20),
        .reg_rb_data_in (W21),
        .sp_in          (W22),
        .alu_result_in  (W23),
        .ccr_flags_in   (M1),
        .m_out_in       (W24),

        // Control Inputs

        .Sel_WriteData_in (G9),
        .Sel_WriteAddr_in (G10),
        .SP_Dec_in (U2),
        .wr_en_in (U3),

        .out_port_en_in (U4),

        .MEM_WB_regwrite_in (H14),



        // Data Outputs
        .current_pc_out (W25),
        .pc_plus_1_out  (W26),
        .instruction_out(W27),
        .reg_ra_data_out(W28),
        .reg_rb_data_out(W29),
        .sp_out         (W30),
        .alu_result_out (W31),
        .ccr_flags_out  (M2),
        .m_out_out      (W32),
        
        // Control Outputs (To Decode/WB)

        .Sel_WriteData_out (J1),
        .Sel_WriteAddr_out (J2),
        .SP_Dec_out (U5),
        .wr_en_out (U6),

        .MEM_WB_regwrite_out (H15),

        .out_port_en_out (U7) 


    );


	
// Control Unit Instantiation
Control_Unit u_Control_Unit (
    // Inputs
    .clk                     (clk),
    .rst                     (rst),
    .opcode                  (W6[7:4]),    // from IF/ID stage 
    .ra                      (W6[3:2]),        
    .rb                      (W6[1:0]),        
    .interrupt_sig           (interrupt),  
    .CCR_flags               ({L4,L3,L2,L1}),      
    .R_ra                    (W7),   // from decode stage   



    // Fetch Stage Control
    .pc_src_sel              (A1),     

    // Decode Stage Control
    .rb_e                    (F1),           
    .Sel_ReadAddr2           (F2),  
    .SP_Inc                  (F3),        

    // Execute Stage Control
    .alu_control             (Q1),    
    .FlagWriteEnable         (F4),
    .interrupt_restore_flags (F5), 
    .interrupt_save_flags    (F6),    
    .SetC                    (F7),           
    .ClrC                    (F8),           

    // Memory Stage Control
    .mem_write_en            (F9),   
    .mem_R_addr_sel          (A2), 
    .mem_W_addr_sel          (A3), 
    .mem_W_data_sel          (A4), 

    // Write Back Stage Control
    .Sel_WriteData           (A5),  
    .Sel_WriteAddr           (A6),  
    .SP_Dec                  (F10),         
    .wr_en                   (F11),  

    
    .flush_f_d_reg            (L5), // Flush Fetch-Decode register signal



    .ID_EX_memRead             (H5), // for hazard detection unit

    .Ex_MEM_regwrite          (H9), // for forwarding unit

    .MEM_WB_regwrite          (H10), // for forwarding unit


    // Output port
    .out_port_en             (F12)    

);


hazard_detection_unit U_Hazard_Detection_Unit (
    // From ID/EX Pipeline Register
    .ID_EX_memRead        (H6),     // for load instructions (LDD, LDI, POP, LDM)   
    .ID_EX_rd             (W10[1:0]),             
    
    // From IF/ID Register (current instruction being decoded)
    .IF_ID_instruction    (W6),    
    
    // Outputs to Control Hazard Resolution
    .stall                (H1),                
    .IF_ID_write_en       (H2),       
    .control_mux_sel      (H3)

);


forwarding_unit U_Forwarding_Unit (

    // Inputs from ID/EX Register (Current Execute Stage)
    .ID_EX_ra           (W10[3:2]),   // Source 1 address
    .ID_EX_rb           (W10[1:0]),   // Source 2 address
    


    // Inputs from EX/MEM Register (Memory Stage)
    .EX_MEM_Dest        (A10),     // Destination address between EX and MEM stages
    .EX_MEM_regwrite    (H13),          // Does the EX instruction write back?



    // Inputs from MEM/WB Register (Write Back Stage)
    .MEM_WB_Dest        (A9),      
    .MEM_WB_regwrite    (H15),          // Does the WB instruction write back?



    // Outputs to ALU MUXes
    .forward_A          (J3),     // Select signal for ALU Operand A
    .forward_B          (J4)      // Select signal for ALU Operand B

);




    always @(posedge clk or posedge rst) 
    begin
        if (rst) begin
            // Clear the output port to 0
            OUT_PORT_REG <= 8'b0;
        end
        else if (U7) 
        begin 
            // Write Enable: Only update when the control unit says "OUT"
            OUT_PORT_REG <= W29; 
        end
        // Else: Keep the old value (maintain state)
    end

    // Assign the internal register value to the final output wire
    assign out_port_val = OUT_PORT_REG;




    // for forwading unit 
    always @(*)
    begin
        case (J2) 
            2'b00: A9 = W27[3:2]; // ra_i
            2'b01: A9 = W27[1:0]; // rb_i
            default: A9 = W27[3:2];
        endcase
    end



    // for forwading unit 
    always @(*)
    begin
        case (G10) 
            2'b00: A10 = W19[3:2]; // ra_i
            2'b01: A10 = W19[1:0]; // rb_i
            default: A10 = W19[3:2];
        endcase
    end



    // forwarding mux for ALU operand A
    always @(*)
    begin
        case (J3) 
            2'b00: W35 = W11; // from register file
            2'b10: W35 = W23; // from EX/MEM ALU result
            2'b01: W35 = W40; // from MEM/WB ALU result
            default: W35 = W11;
        endcase
    end



    // forwarding mux for ALU operand B
    always @(*)
    begin
        case (J4) 
            2'b00: W36 = W12; // from register file
            2'b10: W36 = W23; // from EX/MEM ALU result
            2'b01: W36 = W40; // from MEM/WB ALU result
            default: W36 = W12;
        endcase
    end

	

endmodule

