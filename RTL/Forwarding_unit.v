module forwarding_unit(

    // Inputs from ID/EX Register (Current Execute Stage)
    input wire [1:0] ID_EX_ra,   // Source 1 address
    input wire [1:0] ID_EX_rb,   // Source 2 address
    

    // Inputs from EX/MEM Register (Memory Stage)
    input wire [1:0] EX_MEM_Dest,     // Destination address between EX and MEM stages
    input wire       EX_MEM_regwrite, // Does the EX instruction write back?


    // Inputs from MEM/WB Register (Write Back Stage)
    input wire [1:0] MEM_WB_Dest,      // Destination address between MEM and WB stage
    input wire       MEM_WB_regwrite,  // Does the WB instruction write back?


    // Outputs to ALU MUXes
    output reg [1:0] forward_A,     // Select signal for ALU Operand A
    output reg [1:0] forward_B      // Select signal for ALU Operand B 
  );
  
    always @(*) 
    begin
      // Default: no forwarding
      forward_A = 2'b00;
      forward_B = 2'b00;
      // EX hazard (highest priority)
      if (EX_MEM_regwrite && (EX_MEM_Dest == ID_EX_ra)) 
      begin
           forward_A = 2'b10;
      end
      if (EX_MEM_regwrite && (EX_MEM_Dest == ID_EX_rb)) 
      begin
           forward_B = 2'b10;
      end
      // MEM hazard (lower priority)
      if (MEM_WB_regwrite && !(EX_MEM_regwrite && (EX_MEM_Dest == ID_EX_ra)) &&
         (MEM_WB_Dest == ID_EX_ra)) 
         begin
           forward_A = 2'b01;
      end
      if (MEM_WB_regwrite && !(EX_MEM_regwrite && (EX_MEM_Dest == ID_EX_rb)) &&
         (MEM_WB_Dest == ID_EX_rb)) 
         begin
           forward_B = 2'b01;
      end
end

endmodule

