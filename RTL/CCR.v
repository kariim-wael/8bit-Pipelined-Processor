module CCR (
    input  wire clk, rst,

    // ALU Inputs
    input  wire Z_in, N_in, C_in, V_in,

    // Controls
    input  wire FlagWriteEnable,
    input  wire SetC, ClrC,
    
    // Interrupt Controls 
    input  wire interrupt_save_flags,
    input  wire interrupt_restore_flags,

    // Outputs 
    output reg  Z, N, C, V
);

    reg [3:0] temp_flags; // Buffer for interrupt context

  
    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            Z <= 1'b0; N <= 1'b0; C <= 1'b0; V <= 1'b0;
            temp_flags <= 4'b0;
        end
        else 
        begin
            // Save Context
            if (interrupt_save_flags)
                temp_flags <= {V, C, N, Z};

            // Update Flags
            // Priority: Restore > Set/Clr > ALU Update
            
            if (interrupt_restore_flags) 
            begin
                // Restore saved values
                {V, C, N, Z} <= temp_flags;
            end
            else 
            begin
                // Normal Operation
                
                // Update Z, N, V
                if (FlagWriteEnable) begin
                    Z <= Z_in;
                    N <= N_in;
                    V <= V_in;
                end

                // Update C (Carry Priority: Set > Clear > ALU)
                if (SetC)
                    C <= 1'b1;
                else if (ClrC)
                    C <= 1'b0;
                else if (FlagWriteEnable)
                    C <= C_in;
            end
        end
    end

endmodule


