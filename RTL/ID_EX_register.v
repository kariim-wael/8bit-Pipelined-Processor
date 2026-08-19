module ID_EX_register(
    // Input signals
    input wire clk,
    input wire rst,

    input wire stall,       // 1 = Keep values (Freeze), 0 = Update
    input wire flush,       // 1 = Clear Instruction (Insert NOP), used during Branching
    
    input wire [7:0] IR_in,            // Instruction or L-format(Immediate value or effective address) 
    input wire signed [7:0] reg_ra_data_in,   // Data from R[ra]
    input wire signed [7:0] reg_rb_data_in,   // Data from R[rb]
    input wire [7:0] sp_in,            // Data from R[sp]
    input wire [7:0] pc_in,            // Program Counter(PC) from Decode stage
    input wire [7:0] pc_in_plus_1,     // Program Counter(PC+1) from Decode stage

    // control signals in
    
    input wire [3:0] alu_control_in,
    input wire FlagWriteEnable_in,
    input wire interrupt_restore_flags_in,
    input wire interrupt_save_flags_in,
    input wire SetC_in,
    input wire ClrC_in,

    input wire mem_write_en_in,
    input wire [1:0] mem_R_addr_sel_in,
    input wire [1:0] mem_W_addr_sel_in,
    input wire [1:0] mem_W_data_sel_in,

    input wire [1:0] Sel_WriteData_in,
    input wire [1:0] Sel_WriteAddr_in,
    input wire SP_Dec_in,
    input wire wr_en_in,


    input wire hazard_detection_unit_in,


    // forwarding unit signals
    input wire Ex_MEM_regwrite_in,

    input wire MEM_WB_regwrite_in,


    input wire out_port_en_in,

    
    // output signals
    output reg [7:0] IR_out,
    output reg signed [7:0] reg_ra_data_out,
    output reg signed [7:0] reg_rb_data_out,
    output reg [7:0] sp_out,
    output reg [7:0] pc_out,
    output reg [7:0] pc_out_plus_1,

    // control signals out
    
    output reg [3:0] alu_control_out,
    output reg FlagWriteEnable_out,
    output reg interrupt_restore_flags_out,
    output reg interrupt_save_flags_out,
    output reg SetC_out,
    output reg ClrC_out,

    output reg mem_write_en_out,
    output reg [1:0] mem_R_addr_sel_out,
    output reg [1:0] mem_W_addr_sel_out,
    output reg [1:0] mem_W_data_sel_out,

    output reg [1:0] Sel_WriteData_out,
    output reg [1:0] Sel_WriteAddr_out,
    output reg SP_Dec_out,
    output reg wr_en_out,


    output reg hazard_detection_unit_out,

    output reg Ex_MEM_regwrite_out,
    output reg MEM_WB_regwrite_out,

    output reg out_port_en_out

    
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
          IR_out <= 8'b0;
          reg_ra_data_out <= 8'b0;
          reg_rb_data_out <= 8'b0;
          sp_out <= 8'b0;
          pc_out <= 8'b0;
          pc_out_plus_1 <= 8'b0;

          alu_control_out <= 4'b0;
          FlagWriteEnable_out <= 1'b0;
          interrupt_restore_flags_out <= 1'b0;
          interrupt_save_flags_out <= 1'b0;
          SetC_out <= 1'b0;
          ClrC_out <= 1'b0;

          mem_write_en_out <= 1'b0;
          mem_R_addr_sel_out <= 2'b0;
          mem_W_addr_sel_out <= 2'b0;
          mem_W_data_sel_out <= 2'b0;

          Sel_WriteData_out <= 2'b0;
          Sel_WriteAddr_out <= 2'b0;
          SP_Dec_out <= 1'b0;
          wr_en_out <= 1'b0;

          hazard_detection_unit_out <= 1'b0;

          Ex_MEM_regwrite_out <= 1'b0;
          MEM_WB_regwrite_out <= 1'b0;

          out_port_en_out <= 1'b0;
        end
        else if (flush) begin
          // Flush: Clear the instruction (make it NOP -> usually 0 or specific opcode)
          // We keep PC values or clear them depending on architecture, usually clear IR is enough
          IR_out               <= 8'b0; // Assuming 0 is NOP in your ISA
          reg_ra_data_out      <= 8'b0;
          reg_rb_data_out      <= 8'b0;
          sp_out               <= 8'b0;
          pc_out               <= 8'b0; 
          pc_out_plus_1        <= 8'b0;
          // Clear Control Signals (CRITICAL)
          // We force these to 0 so the Execute/Memory stages do NOTHING.
          alu_control_out             <= 4'b0; 
          FlagWriteEnable_out         <= 1'b0;
          interrupt_restore_flags_out <= 1'b0;
          interrupt_save_flags_out    <= 1'b0;
          SetC_out                    <= 1'b0;
          ClrC_out                    <= 1'b0;
          mem_write_en_out            <= 1'b0; // Ensure no memory write
          wr_en_out                   <= 1'b0; // Ensure no register write
          out_port_en_out             <= 1'b0; // Ensure no port output
          SP_Dec_out                  <= 1'b0;
          // These selectors don't strictly matter if Write Enables are 0, 
          // but clearing them is safer.
          mem_R_addr_sel_out          <= 2'b0;
          mem_W_addr_sel_out          <= 2'b0;
          mem_W_data_sel_out          <= 2'b0;
          Sel_WriteData_out           <= 2'b0;
          Sel_WriteAddr_out           <= 2'b0;

          hazard_detection_unit_out   <= 1'b0;

          Ex_MEM_regwrite_out         <= 1'b0;
          MEM_WB_regwrite_out         <= 1'b0;


        end
        else if (!stall) begin 
          // Normal Operation: Update only if NOT stalled
          IR_out <= IR_in;
          reg_ra_data_out <= reg_ra_data_in;
          reg_rb_data_out <= reg_rb_data_in;
          sp_out <= sp_in;
          pc_out <= pc_in;
          pc_out_plus_1 <= pc_in_plus_1;


          alu_control_out <= alu_control_in;
          FlagWriteEnable_out <= FlagWriteEnable_in;
          interrupt_restore_flags_out <= interrupt_restore_flags_in;
          interrupt_save_flags_out <= interrupt_save_flags_in;
          SetC_out <= SetC_in;
          ClrC_out <= ClrC_in;

          mem_write_en_out <= mem_write_en_in;
          mem_R_addr_sel_out <= mem_R_addr_sel_in;
          mem_W_addr_sel_out <= mem_W_addr_sel_in;
          mem_W_data_sel_out <= mem_W_data_sel_in;

          Sel_WriteData_out <= Sel_WriteData_in;
          Sel_WriteAddr_out <= Sel_WriteAddr_in;
          SP_Dec_out <= SP_Dec_in;
          wr_en_out <= wr_en_in;

          hazard_detection_unit_out <= hazard_detection_unit_in;

          Ex_MEM_regwrite_out <= Ex_MEM_regwrite_in;
          MEM_WB_regwrite_out <= MEM_WB_regwrite_in;

          out_port_en_out <= out_port_en_in;          
        end
          // If stall == 1, registers keep their old value (Implied latch)
    end
  
endmodule
