
module MEM_WB_Register (


    input  wire       clk,
    input  wire       rst,
    
    // From FETCH Stage (via pipeline registers)
    input  wire [7:0] current_pc_in,     // PC value (for CALL/RET)
    input  wire [7:0] pc_plus_1_in,      // PC+1 (for CALL/RET)  
    
    // From DECODE Stage  
    input  wire [7:0] instruction_in,    // Instruction (for opcode analysis)
    input  wire [7:0] reg_ra_data_in,    // R[ra] value
    input  wire [7:0] reg_rb_data_in,    // R[rb] value  
    input  wire [7:0] sp_in,             // Stack Pointer (R3)
    
    // From EXECUTE Stage
    input  wire signed [7:0] alu_result_in,     // ALU result (address or computation)
    input  wire [3:0] ccr_flags_in,      // CCR flags (Z,N,C,V)
    
    // From MEMORY Stage
    input  wire [7:0] m_out_in,          // Memory read data (LDD/LDI/POP)


    // control signals in

    input wire [1:0] Sel_WriteData_in,
    input wire [1:0] Sel_WriteAddr_in,
    input wire SP_Dec_in,
    input wire wr_en_in,

    input wire out_port_en_in,


    input wire MEM_WB_regwrite_in,


    
    // COMPLETE Outputs to Writeback Stage (ALL signals forwarded)
    output reg [7:0] current_pc_out,
    output reg [7:0] pc_plus_1_out, 
    output reg [7:0] instruction_out,
    output reg [7:0] reg_ra_data_out,
    output reg [7:0] reg_rb_data_out,
    output reg [7:0] sp_out,
    output reg signed [7:0] alu_result_out,
    output reg [3:0] ccr_flags_out,
    output reg [7:0] m_out_out,

    // control signals out

    output reg [1:0] Sel_WriteData_out,
    output reg [1:0] Sel_WriteAddr_out,
    output reg SP_Dec_out,
    output reg wr_en_out,


    output reg MEM_WB_regwrite_out,

    output reg out_port_en_out
    
);

    // Main pipeline register - transfers ALL previous stage outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset ALL outputs to 0 
            current_pc_out     <= 8'b0;
            pc_plus_1_out      <= 8'b0;
            instruction_out    <= 8'b0;
            reg_ra_data_out    <= 8'b0;
            reg_rb_data_out    <= 8'b0;
            sp_out             <= 8'b0;
            alu_result_out     <= 8'b0;
            ccr_flags_out      <= 4'b0;
            m_out_out          <= 8'b0;

          Sel_WriteData_out <= 2'b0;
          Sel_WriteAddr_out <= 2'b0;
          SP_Dec_out <= 1'b0;
          wr_en_out <= 1'b0;

          MEM_WB_regwrite_out <= 1'b0;

          out_port_en_out <= 1'b0;



        end 
        else begin 
            // Transfer EVERYTHING from MEM stage to WB stage
            current_pc_out     <= current_pc_in;
            pc_plus_1_out      <= pc_plus_1_in;
            instruction_out    <= instruction_in;
            reg_ra_data_out    <= reg_ra_data_in;
            reg_rb_data_out    <= reg_rb_data_in;
            sp_out             <= sp_in;
            alu_result_out     <= alu_result_in;
            ccr_flags_out      <= ccr_flags_in;
            m_out_out          <= m_out_in;

          Sel_WriteData_out <= Sel_WriteData_in;
          Sel_WriteAddr_out <= Sel_WriteAddr_in;
          SP_Dec_out <= SP_Dec_in;
          wr_en_out <= wr_en_in;


          MEM_WB_regwrite_out <= MEM_WB_regwrite_in;

          out_port_en_out <= out_port_en_in; 

        end
    end

endmodule
