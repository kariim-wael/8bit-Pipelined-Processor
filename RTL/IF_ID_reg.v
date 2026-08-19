module IF_ID_register (
  
    // Inputs
    input wire clk,
    input wire rst,             
    
    // Control Inputs 
    input wire stall,       // 1 = Keep values (Freeze), 0 = Update
    input wire flush,       // 1 = Clear Instruction (Insert NOP), used during Branching
    
    // Data Inputs from Fetch Stage
    input wire [7:0] current_pc_in,   // PC value
    input wire [7:0] pc_plus_1_in,    // PC + 1
    input wire [7:0] instruction_in,  // Fetched Instruction (IR)
    
      
    // Data Outputs to Decode Stage
    output reg [7:0] current_pc_out,
    output reg [7:0] pc_plus_1_out,
    output reg [7:0] instruction_out        // IR
);

    // main always block
    always @(posedge clk or posedge rst) 
    begin 
        if (rst) 
        begin 
            // Asynchronous Reset
            current_pc_out  <= 8'b0;
            pc_plus_1_out   <= 8'b0;
            instruction_out <= 8'b0; 
        end 
        else if (flush) 
        begin
            // Flush: Clear the instruction (make it NOP -> usually 0 or specific opcode)
            // We keep PC values or clear them depending on architecture, usually clear IR is enough
            instruction_out <= 8'b0; // Assuming 0 is NOP
            current_pc_out  <= 8'b0; 
            pc_plus_1_out   <= 8'b0;
        end
        else if (!stall) 
        begin 
            // Normal Operation: Update only if NOT stalled
            current_pc_out  <= current_pc_in;
            pc_plus_1_out   <= pc_plus_1_in;
            instruction_out <= instruction_in;
        end
        // If stall == 1, registers keep their old value (Implied latch)
    end

endmodule