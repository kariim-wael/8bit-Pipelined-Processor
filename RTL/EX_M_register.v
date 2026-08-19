
module EX_M_register (
  
    // Inputs
    input wire clk,
    input wire rst,        
        
    // Data Inputs from Fetch Stage
    input wire [7:0] current_pc_in,   // PC value
    input wire [7:0] pc_plus_1_in,    // PC + 1
    input wire [7:0] instruction_in,  // Fetched Instruction (IR)   
    
    // Data Inputs from Decode stage
    input wire [7:0] reg_ra_data_in,   // Data from R[ra]
    input wire [7:0] reg_rb_data_in,   // Data from R[rb]
    input wire [7:0] sp_in,            // Data from R[sp]
  
    // Data Inputs from Execute Stage
    input wire signed [7:0] alu_result_in,       // ALU Output (Result or Address)
    input wire [3:0] ccr_flags_in,        // CCR Flags (V, C, N, Z)

    // control signals in
  
    input wire mem_write_en_in,
    input wire [1:0] mem_R_addr_sel_in,
    input wire [1:0] mem_W_addr_sel_in,
    input wire [1:0] mem_W_data_sel_in,

    input wire [1:0] Sel_WriteData_in,
    input wire [1:0] Sel_WriteAddr_in,
    input wire SP_Dec_in,
    input wire wr_en_in,

    input wire out_port_en_in,

    // forwarding unit signals
    input wire Ex_MEM_regwrite_in,

    input wire MEM_WB_regwrite_in,

  
    // Data Outputs to Decode stage
    output reg [7:0] current_pc_out,   
    output reg [7:0] pc_plus_1_out,    
    output reg [7:0] instruction_out,    

    // Data Outputs to Excute stage
    output reg [7:0] reg_ra_data_out,   
    output reg [7:0] reg_rb_data_out,    
    output reg [7:0] sp_out, 

    // Data Outputs to Memory Stage
    output reg signed [7:0] alu_result_out,
    output reg [3:0] ccr_flags_out,

    // control signals out

    output reg mem_write_en_out,
    output reg [1:0] mem_R_addr_sel_out,
    output reg [1:0] mem_W_addr_sel_out,
    output reg [1:0] mem_W_data_sel_out,

    output reg [1:0] Sel_WriteData_out,
    output reg [1:0] Sel_WriteAddr_out,
    output reg SP_Dec_out,
    output reg wr_en_out,

    output reg Ex_MEM_regwrite_out,

    output reg MEM_WB_regwrite_out,

    output reg out_port_en_out



);

    // main always block
    always @(posedge clk or posedge rst) 
    begin 
        if (rst) 
        begin 
            // Asynchronous Reset
            current_pc_out      <= 8'b0;
            pc_plus_1_out       <= 8'b0;
            instruction_out     <= 8'b0;
            reg_ra_data_out     <= 8'b0;
            reg_rb_data_out     <= 8'b0;  
            sp_out              <= 8'b0;
            alu_result_out      <= 8'b0;
            ccr_flags_out       <= 4'b0;

          mem_write_en_out <= 1'b0;
          mem_R_addr_sel_out <= 2'b0;
          mem_W_addr_sel_out <= 2'b0;
          mem_W_data_sel_out <= 2'b0;

          Sel_WriteData_out <= 2'b0;
          Sel_WriteAddr_out <= 2'b0;
          SP_Dec_out <= 1'b0;
          wr_en_out <= 1'b0;

          Ex_MEM_regwrite_out <= 1'b0;
          MEM_WB_regwrite_out <= 1'b0;

          out_port_en_out <= 1'b0;

        end 
        else 
        begin 
            // transfer
            current_pc_out      <= current_pc_in;
            pc_plus_1_out       <= pc_plus_1_in;
            instruction_out     <= instruction_in;
            reg_ra_data_out     <= reg_ra_data_in;
            reg_rb_data_out     <= reg_rb_data_in;  
            sp_out              <= sp_in;
            alu_result_out      <= alu_result_in;
            ccr_flags_out       <= ccr_flags_in;

          mem_write_en_out <= mem_write_en_in;
          mem_R_addr_sel_out <= mem_R_addr_sel_in;
          mem_W_addr_sel_out <= mem_W_addr_sel_in;
          mem_W_data_sel_out <= mem_W_data_sel_in;

          Sel_WriteData_out <= Sel_WriteData_in;
          Sel_WriteAddr_out <= Sel_WriteAddr_in;
          SP_Dec_out <= SP_Dec_in;
          wr_en_out <= wr_en_in;

          Ex_MEM_regwrite_out <= Ex_MEM_regwrite_in;
          MEM_WB_regwrite_out <= MEM_WB_regwrite_in;

          out_port_en_out <= out_port_en_in; 

        end
    end

endmodule
