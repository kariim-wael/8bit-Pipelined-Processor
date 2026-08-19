
module Control_Unit (

    input wire       clk,
    input wire       rst,
    input wire [3:0] opcode,        // IR[7:4]
    input wire [1:0] ra,            // IR[3:2]
    input wire [1:0] rb,            // IR[1:0]
    input wire       interrupt_sig,

    input wire [3:0] CCR_flags, // Current Condition Code Register flags: {V,C,N,Z}

    input wire [7:0] R_ra,   // R[ra] value








// fetch stage control signals
    output reg [1:0] pc_src_sel,    // 2-bit: PC Source Select Mux (00: PC+1, 01: Branch Target R[rb], 10: Return Target M[++SP])




// decode back stage control signals

    output reg rb_e,            // 1-bit: rb stored signal for 2 byte instructions   
    output reg Sel_ReadAddr2,   // 1-bit: 0=rb_t , 1=rb 
    output reg SP_Inc,          // 1-bit: Stack Pointer Increment (for POP, RET)




// execute stage control signals

    output reg  [3:0] alu_control,                // 4-bit: ALU Operation Control
    output reg        FlagWriteEnable,           // 1-bit: flag to write CCR flags when alu operation occurs
	output reg 		  interrupt_restore_flags,   // 1-bit: flag to restore flags after interrupt return
	output reg 		  interrupt_save_flags,      // 1-bit: flag to save flags before interrupt handling
    output reg        SetC,                      // 1-bit: Set Carry flag (SETC)
    output reg        ClrC,                      // 1-bit: Clear Carry flag (CLRC)




// memory stage control signals

    output reg        mem_write_en,      // 1-bit: Memory Write Enable (WM_E)
    output reg [1:0]  mem_R_addr_sel,    // 2-bit: Memory Read Address Select Mux (00: SP, 01: ea(IR), 10: R[ra])
    output reg [1:0]  mem_W_addr_sel,    // 2-bit: Memory Write Address Select Mux (00: SP, 01: ea(IR), 10: R[ra])
    output reg [1:0]  mem_W_data_sel,    // 2-bit: Memory Write Data Select Mux (00: pc, 01: PC+1, 10: R[rb])




// write back stage control signals

    output reg [1:0]  Sel_WriteData,    // 2-bit: Write Data Select Mux (00: ALU, 01: Mem Out, 10: IN.PORT, 11: Immediate (IR))
    output reg [1:0]  Sel_WriteAddr,    // 2-bit: Write Address Select Mux (00: ra_i, 01: rb_i, 10: rb_t)
    output reg        SP_Dec,           // 1-bit: Stack Pointer Decrement (for PUSH, CALL, INT)
    output reg        wr_en,             // 1-bit: Register File Write Enable    

    output reg        flush_f_d_reg,    // 1-bit: Flush Fetch-Decode register signal


    output reg        ID_EX_memRead,    // 1-bit: ID/EX Memory Read signal for hazard detection unit

    output wire       Ex_MEM_regwrite, // 1-bit: EX/MEM Register Write signal for forwarding unit

    output wire       MEM_WB_regwrite, // 1-bit: MEM/WB Register Write signal for forwarding unit


// output port signal
    output reg        out_port_en       // 1-bit: Output Port Enable (for OUT.PORT instruction)


);



localparam [1:0] ideal = 2'b00,
                 S2    = 2'b01;





reg [1:0] current_state, next_state; 

reg [1:0] store_ra; // stored ra for 2 byte instructions


// 1. Forwarding signal for EX stage: 
// Active if writing data from ALU (00) or Immediate/LDM (11)
assign Ex_MEM_regwrite = wr_en && (Sel_WriteData == 2'b00 || Sel_WriteData == 2'b11 );


// 2. Forwarding signal for MEM stage: 
// Active if writing data from Memory (01) or Input Port (10)
assign MEM_WB_regwrite = wr_en ;



// Sequential state update
always @ (posedge clk or posedge rst)
 begin
  if(rst)
    current_state <= ideal;
  else begin
    current_state <= next_state;
    // Save RA when transitioning from ideal to S2 (Opcode 12)
    if (current_state == ideal && opcode == 4'd12)
        store_ra <= ra;
  end
 end


// Combinational next state logic
 always @(*)
begin
    next_state = ideal; // default state
    case (current_state)
        ideal: begin
            if (opcode == 4'd12) // 2 byte instruction 
                next_state = S2;
            else 
                next_state = ideal;
        end

        S2: begin
            next_state = ideal;
        end

        default: next_state = ideal;
    endcase
end



always @(*)
begin
    // Default values for all control signals

    // Fetch Stage
    pc_src_sel               = 2'b00;

    // Decode Stage
    rb_e                     = 1'b0;
    Sel_ReadAddr2            = 1'b1;
    SP_Inc                   = 1'b0;

    // Execute Stage
    alu_control               = 4'b0000;
    FlagWriteEnable          = 1'b0;
    interrupt_restore_flags  = 1'b0;
    interrupt_save_flags     = 1'b0;
    SetC                     = 1'b0;
    ClrC                     = 1'b0;

    // Memory Stage
    mem_write_en             = 1'b0;
    mem_R_addr_sel           = 2'b00;
    mem_W_addr_sel           = 2'b00;
    mem_W_data_sel           = 2'b00;

    // Write Back Stage
    Sel_WriteData            = 2'b00;
    Sel_WriteAddr            = 2'b00;
    SP_Dec                   = 1'b0;
    wr_en                    = 1'b0;

    // Output Port
    out_port_en              = 1'b0;

    flush_f_d_reg = 1'b0; // Default no flush

    ID_EX_memRead = 1'b0; // Default 



    case (current_state)
        ideal: begin

            if (interrupt_sig) 
            begin

                // Interrupt Handling Control Signals (push PC+1 into stack)
                mem_write_en             = 1'b1;  // Enable memory write to save PC+1
                mem_W_addr_sel           = 2'b00; // Use SP as write address
                mem_W_data_sel           = 2'b00; // Write PC to memory      
                interrupt_save_flags     = 1'b1;  // Save CCR flags
                SP_Dec                   = 1'b1;  // Decrement SP for interrupt handling in write back stage
                flush_f_d_reg            = 1'b1;  // Flush Fetch-Decode register

            end else begin


            case (opcode)
                4'd0: begin // NOP
                    // No operation, all defaults
                    pc_src_sel = 2'b00;
                end


                4'd1: begin // MOV

                   alu_control = 4'b0000; // ALU performs pass-through  
                   Sel_ReadAddr2 = 1'b1;  // Read from rb
                   wr_en = 1'b1;          // Enable write back     
                   Sel_WriteData = 2'b00; // Write ALU output
                   Sel_WriteAddr = 2'b00; // Write to ra_i

                end


                4'd2: begin // ADD

                   alu_control = 4'b0001; // ALU performs addition
                   Sel_ReadAddr2 = 1'b1;  // Read from rb
                   wr_en = 1'b1;          // Enable write back     
                   Sel_WriteData = 2'b00; // Write ALU output
                   Sel_WriteAddr = 2'b00; // Write to ra_i
                   FlagWriteEnable = 1'b1; // Enable CCR flag update
                   
                 
                    
                end


                4'd3: begin // SUB

                   alu_control = 4'b0010; // ALU performs subtraction
                   Sel_ReadAddr2 = 1'b1;  // Read from rb
                   wr_en = 1'b1;          // Enable write back     
                   Sel_WriteData = 2'b00; // Write ALU output
                   Sel_WriteAddr = 2'b00; // Write to ra_i
                   FlagWriteEnable = 1'b1; // Enable CCR flag update

                end 


                4'd4: begin // AND

                   alu_control = 4'b0101; // ALU performs LOGICAL AND
                   Sel_ReadAddr2 = 1'b1;  // Read from rb
                   wr_en = 1'b1;          // Enable write back     
                   Sel_WriteData = 2'b00; // Write ALU output
                   Sel_WriteAddr = 2'b00; // Write to ra_i
                   FlagWriteEnable = 1'b1; // Enable CCR flag update


                end


                4'd5: begin // OR

                   alu_control = 4'b0110; // ALU performs LOGICAL OR
                   Sel_ReadAddr2 = 1'b1;  // Read from rb
                   wr_en = 1'b1;          // Enable write back     
                   Sel_WriteData = 2'b00; // Write ALU output
                   Sel_WriteAddr = 2'b00; // Write to ra_i
                   FlagWriteEnable = 1'b1; // Enable CCR flag update

                end


                4'd6: begin // RLC & RRC & SETC & CLRC

                   case (ra)
                       2'b00: begin // RLC
                           alu_control = 4'b1001; // ALU performs RLC
                           Sel_ReadAddr2 = 1'b1;  // Read from rb
                           wr_en = 1'b1;          // Enable write back     
                           Sel_WriteData = 2'b00; // Write ALU output
                           Sel_WriteAddr = 2'b01; // Write to rb_i
                           FlagWriteEnable = 1'b1; // Enable CCR flag update
                       end

                       2'b01: begin // RRC
                           alu_control = 4'b1010; // ALU performs RRC
                           Sel_ReadAddr2 = 1'b1;  // Read from rb
                           wr_en = 1'b1;          // Enable write back     
                           Sel_WriteData = 2'b00; // Write ALU output
                           Sel_WriteAddr = 2'b01; // Write to rb_i
                           FlagWriteEnable = 1'b1; // Enable CCR flag update
                       end

                       2'b10: begin // SETC
                           SetC = 1'b1;           // Set Carry flag
                       end

                       2'b11: begin // CLRC
                           ClrC = 1'b1;           // Clear Carry flag
                       end

                   endcase

                end


                4'd7: begin // PUSH & POP & OUT & IN 

                   case (ra)
                       2'b00: begin // PUSH
                           mem_write_en             = 1'b1;  // Enable memory write
                           mem_W_addr_sel           = 2'b00; // Use SP as write address
                           mem_W_data_sel           = 2'b10; // Write R[rb] to memory
                           SP_Dec                   = 1'b1;  // Decrement SP in write back stage
                       end

                       2'b01: begin // POP
                           mem_R_addr_sel           = 2'b00; // Use SP as read address
                           Sel_WriteData            = 2'b01; // Write Mem Out to register
                           Sel_WriteAddr            = 2'b01; // Write to rb_i
                           SP_Inc                   = 1'b1;  // Increment SP in decode stage
                           wr_en                    = 1'b1;  // Enable write back
                       end

                       2'b10: begin // OUT.PORT
                           out_port_en              = 1'b1;  // Enable output port
                       end

                       2'b11: begin // IN.PORT
                           Sel_WriteData            = 2'b10; // Write IN.PORT to register
                           Sel_WriteAddr            = 2'b01; // Write to rb_i
                           wr_en                    = 1'b1;  // Enable write back

                       end

                   endcase

                end


                4'd8: begin // NOT & NEG & INC & DEC

                   case (ra)
                       2'b00: begin // NOT
                           alu_control = 4'b0111; // ALU performs LOGICAL NOT
                           Sel_ReadAddr2 = 1'b1;  // Read from rb
                           wr_en = 1'b1;          // Enable write back     
                           Sel_WriteData = 2'b00; // Write ALU output
                           Sel_WriteAddr = 2'b01; // Write to rb_i
                           FlagWriteEnable = 1'b1; // Enable CCR flag update
                       end

                       2'b01: begin // NEG
                           alu_control = 4'b1000; // ALU performs NEGATAVE
                           Sel_ReadAddr2 = 1'b1;  // Read from rb
                           wr_en = 1'b1;          // Enable write back     
                           Sel_WriteData = 2'b00; // Write ALU output
                           Sel_WriteAddr = 2'b01; // Write to rb_i
                           FlagWriteEnable = 1'b1; // Enable CCR flag update
                       end

                       2'b10: begin // INC
                           alu_control = 4'b0011; // ALU performs INCREMENT
                           Sel_ReadAddr2 = 1'b1;  // Read from rb
                           wr_en = 1'b1;          // Enable write back     
                           Sel_WriteData = 2'b00; // Write ALU output
                           Sel_WriteAddr = 2'b01; // Write to rb_i
                           FlagWriteEnable = 1'b1; // Enable CCR flag update
                       end

                       2'b11: begin // DEC
                           alu_control = 4'b0100; // ALU performs DECREMENT
                           Sel_ReadAddr2 = 1'b1;  // Read from rb
                           wr_en = 1'b1;          // Enable write back     
                           Sel_WriteData = 2'b00; // Write ALU output
                           Sel_WriteAddr = 2'b01; // Write to rb_i
                           FlagWriteEnable = 1'b1; // Enable CCR flag update
                       end

                   endcase

                end


                4'd9: begin // JZ & JN & JC & JV

                   case (ra)
                       2'b00: begin // JZ
                           if (CCR_flags[0] == 1'b1) begin // Z flag is set
                               pc_src_sel = 2'b01;   // Branch to R[rb]
                               flush_f_d_reg            = 1'b1;  // Flush Fetch-Decode register
                           end else
                               pc_src_sel = 2'b00;   // PC + 1
                       end

                       2'b01: begin // JN
                           if (CCR_flags[1] == 1'b1) begin // N flag is set
                               pc_src_sel = 2'b01;   // Branch to R[rb]
                               flush_f_d_reg            = 1'b1;  // Flush Fetch-Decode register
                           end else
                               pc_src_sel = 2'b00;   // PC + 1
                       end

                       2'b10: begin // JC
                           if (CCR_flags[2] == 1'b1) begin // C flag is set
                               pc_src_sel = 2'b01;   // Branch to R[rb]
                               flush_f_d_reg            = 1'b1;  // Flush Fetch-Decode register
                           end else
                               pc_src_sel = 2'b00;   // PC + 1
                       end

                       2'b11: begin // JV
                           if (CCR_flags[3] == 1'b1) begin // V flag is set
                               pc_src_sel = 2'b01;   // Branch to R[rb]
                               flush_f_d_reg            = 1'b1;  // Flush Fetch-Decode register
                           end else
                               pc_src_sel = 2'b00;   // PC + 1
                       end

                   endcase

                end


                4'd10: begin // LOOP
                     alu_control = 4'b1011; // ALU performs DECREMENT
                     Sel_ReadAddr2 = 1'b1;  // Read from rb
                     wr_en = 1'b1;          // Enable write back     
                     Sel_WriteData = 2'b00; // Write ALU output
                     Sel_WriteAddr = 2'b00; // Write to ra_i
                     FlagWriteEnable = 1'b1; // Enable CCR flag update
    
                     if (CCR_flags[0] == 1'b0) // Z flag is clear
                          pc_src_sel = 2'b01;   // Branch to R[ra]
                     else
                          pc_src_sel = 2'b00;   // PC + 1
                end


                4'd11: begin // JMP & CALL & RET & RTI

                   case (ra)
                       2'b00: begin // JMP
                           pc_src_sel = 2'b01;   // Jump to R[rb]
                           flush_f_d_reg            = 1'b1;  // Flush Fetch-Decode register
                       end

                       2'b01: begin // CALL like PUSH
                           mem_write_en             = 1'b1;  // Enable memory write to save PC+1
                           mem_W_addr_sel           = 2'b00; // Use SP as write address
                           mem_W_data_sel           = 2'b01; // Write PC+1 to memory      
                           pc_src_sel               = 2'b01; // Jump to R[rb]
                           SP_Dec                   = 1'b1;  // Decrement SP in write back stage
                           SP_Inc                   = 1'b0;
                           flush_f_d_reg            = 1'b1;  // Flush Fetch-Decode register
                       end

                       2'b10: begin // RET
                           mem_R_addr_sel           = 2'b00; // Use SP as read address
                           pc_src_sel               = 2'b10; // Return to M[++SP]
                           SP_Inc                   = 1'b1;  // Increment SP in decode stage
                       end

                       2'b11: begin // RTI
                           mem_R_addr_sel           = 2'b00; // Use SP as read address
                           pc_src_sel               = 2'b10; // Return to M[++SP]
                           SP_Inc                   = 1'b1;  // Increment SP in decode stage
                           interrupt_restore_flags  = 1'b1;  // Restore CCR flags
                           wr_en                    = 1'b0;
                       end

                   endcase

                end


                4'd12: begin // 2-byte instructions (handled in S2)
                           rb_e = 1'b1; // Store rb for next byte
                end


                4'd13: begin // LDI
                           mem_R_addr_sel = 2'b10; // Read from R[ra] 
                           wr_en = 1'b1;           // Enable write back     
                           Sel_WriteData = 2'b01;  // Write Mem Out
                           Sel_WriteAddr = 2'b01;  // Write to rb_i
                           ID_EX_memRead = 1'b1;   // Indicate memory read in ID/EX for hazard detection
                end


                4'd14: begin // STI

                           mem_write_en             = 1'b1;  // Enable memory write
                           mem_W_addr_sel           = 2'b10; // Write to R[ra]
                           mem_W_data_sel           = 2'b10; // Write R[rb] to memory

                end                


                default: begin
                    // Default case for unrecognized opcodes
                end
            endcase

            end
        end


        // Handle 2-byte instructions in state S2
        S2: begin
            
                case (store_ra)
                    2'b00: begin // LDM (2nd byte)

                        wr_en = 1'b1;          // Enable write back
                        Sel_WriteData = 2'b11; // Write Immediate (IR)
                        Sel_WriteAddr = 2'b10; // Write to rb_t
                        
                    end


                    2'b01: begin // LDD (2nd byte)
                        wr_en = 1'b1;          // Enable write back
                        Sel_WriteData  = 2'b01; // Write Mem Out (M[ea])
                        Sel_WriteAddr  = 2'b10; // Write to rb_t
                        mem_R_addr_sel = 2'b01; // Read from ea (IR)
                        ID_EX_memRead  = 1'b1;   // Indicate memory read in ID/EX for hazard detection

                    end    


                    2'b10: begin // STD (2nd byte)

                           mem_write_en             = 1'b1;  // Enable memory write
                           mem_W_addr_sel           = 2'b01; // Write to ea (IR)
                           mem_W_data_sel           = 2'b10; // Write R[rb] to memory
                           Sel_ReadAddr2            = 1'b0;  // Read from rb_t

                    end                                 

                    default: begin
                        // Default case for unrecognized opcodes
                    end
                endcase
                

        end

        default: begin
            // Default case to avoid latches
        end

    endcase


end    


endmodule

