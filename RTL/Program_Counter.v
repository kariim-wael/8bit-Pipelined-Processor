module Program_Counter (
    input  wire       clk,
    input  wire       rst,               // Hardware Reset
    input  wire       stall,             // 1 = Keep current PC (Freeze), 0 = Update
    input  wire [7:0] next_pc,           // The calculated Next PC (from Mux)
    input  wire [7:0] reset_vector,      // The value read from M[0]
    input  wire [7:0] intr_vector,       // The value read from M[1]
    input  wire       interrupt_sig,     // The interrupt signal (from Control Unit)

    output reg  [7:0] pc_out
);

    always @(posedge clk , posedge rst) 
    begin
        if (rst) 
        begin
            // On Reset: Load the start address from M[0]
            pc_out <= reset_vector;
        end
        else if (interrupt_sig) // the interrupt has higher priority
        begin
            // On Interrupt: Load the interrupt vector from M[1]
            pc_out <= intr_vector;
        end
        else if (!stall) 
        begin
            // Normal operation: Update PC only if not stalled
            pc_out <= next_pc;
        end
        // If stall == 1, pc_out retains its value 
    end

endmodule


