module MemoryStage (
    input  wire       clk,
    
    // Control Signals from Control Unit (from EX/MEM pipeline reg)
    input  wire       mem_write_en,      // Write Memory Enable (WM_E)
    
    // Selectors from Control Unit (from EX/MEM pipeline reg)
    input  wire [1:0] mem_R_addr_sel,       // Selects Read Address (00:SP, 01:ea, 10:R[ra])
    input  wire [1:0] mem_W_addr_sel,       // Selects Write Address (00:SP, 01:ea, 10:R[ra])
    input  wire [1:0] mem_W_data_sel,       // Selects Write Data (00:pc, 01:PC+1, 10:R[rb])

    // Data Inputs
    input  wire [7:0] sp,                // Stack Pointer (R3) (from EX/MEM pipeline reg)
    input  wire [7:0] ea,                // Effective Address or the instruction (IR)
    input  wire [7:0] r_ra_val,          // Value of Register RA (Indirect Addr)
    input  wire [7:0] r_rb_val,          // Value of Register RB (Data to Store)
    
    // PC Input for Call and Interrupt
    input  wire [7:0] current_pc,        // Current PC value
    input  wire [7:0] pc_plus_1,   

    input wire [7:0] RTI_SP_IN,         // Current SP value for RTI and RET instructions     
    
	
    // Outputs will go to MEM/WB pipeline Register 
    output wire [7:0] m_out,              // Data read from Memory

    output wire [7:0] RTI_SP_OUT         // Output current SP value for RTI and RET instructions
);

    // Define 256 bytes of memory
    reg [7:0] mem [0:255];

    // Internal wires for Mux outputs
    wire [7:0] mem_R_addr;        // Memory Read Address
    wire [7:0] mem_W_addr;        // Memory Write Address
    wire [7:0] mem_W_data;        // Memory Write Data


    // Logic for Mux (Memory Read Address)
    // 00: SP (Stack), 01: ea (IR), 10: R[ra] 
    assign mem_R_addr = (mem_R_addr_sel == 2'b00) ? sp :
						(mem_R_addr_sel == 2'b01) ? ea :
						(mem_R_addr_sel == 2'b10) ? r_ra_val : 8'b0;

    // Logic for Mux (Memory Write Address)
    // 00: SP (Stack), 01: ea (IR), 10: R[ra] 

    assign mem_W_addr = (mem_W_addr_sel == 2'b00) ? sp :
						(mem_W_addr_sel == 2'b01) ? ea :
						(mem_W_addr_sel == 2'b10) ? r_ra_val : 8'b0;


    // Logic for S6 Mux (Memory Write Data)
    // 00: pc , 01: PC+1 (Call/Int Save) 10: R[rb]

    assign mem_W_data = (mem_W_data_sel == 2'b00) ? current_pc :
						(mem_W_data_sel == 2'b01) ? pc_plus_1 :
						(mem_W_data_sel == 2'b10) ? r_rb_val  : 8'b0;

    // Memory Read Operation (Asynchronous)
    assign m_out = mem[mem_R_addr] ;

    // Output current SP value for RTI and RET instructions
    assign RTI_SP_OUT = mem[RTI_SP_IN]; // MEM[SP++]

    // Memory Write Operation (Synchronous)
    always @(posedge clk) 
	begin
        if (mem_write_en) 
		begin
            mem[mem_W_addr] <= mem_W_data;
        end
    end

endmodule
