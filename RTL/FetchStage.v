
module FetchStage (
    input  wire       clk,
    input  wire       rst,
    input  wire       stall,             // From Hazard Unit to freeze PC
    input  wire       interrupt_sig,     // Interrupt signal from Control Unit
    
    // PC MUX Selector comes from Control Unit directly flowing back from the Decode Stage
    // 00: PC + 1 (Normal)
    // 01: Branch/Jump Target (from Register File)
    // 10: Return Address (from Stack)
    input  wire [1:0] pc_src_sel,       
    
    input  wire [7:0] branch_target,     // Address from Register (for JMP, CALL) comes from register file (R[rb]), directly from the register file in the Decode Stage
    input  wire [7:0] return_target,     // Address from Stack (for RET, RTI) comes from data memory (M[++SP]), and from the Memory output directly in the Memory Stage
    

    // Outputs that will store in IF/ID Pipeline Register
    output wire [7:0] current_pc,        // Needed for Pipeline Register (IF/ID)
    output wire [7:0] pc_plus_1,         // Needed for Pipeline Register (IF/ID)
    output wire [7:0] instruction        // The fetched instruction (IR)
);

    // Internal Wires
    wire [7:0] pc_out_wire;
    wire [7:0] reset_vector_wire;
    wire [7:0] intr_vector_wire;
    reg  [7:0] next_pc_mux_out;

    //  Instantiate Instruction Memory
    Instruction_Memory instr_mem (
        .addr(pc_out_wire),

        .instruction(instruction),
        .reset_vector(reset_vector_wire),
        .intr_vector(intr_vector_wire)
    );

    //  Instantiate Program Counter
    Program_Counter pc (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .next_pc(next_pc_mux_out),
        .reset_vector(reset_vector_wire),
        .intr_vector(intr_vector_wire),
        .interrupt_sig(interrupt_sig),  

        .pc_out(pc_out_wire)
    );


    //  Adder Logic (+1 incrementer)
    assign pc_plus_1 = pc_out_wire + 8'd1;

    // Output assignment
    assign current_pc = pc_out_wire;

    // PC Source Multiplexer Logic
    // This decides what the NEXT PC value will be
    always @(*) 
    begin
        case (pc_src_sel)
            2'b00: next_pc_mux_out = pc_out_wire + 8'd1;       // Normal Flow
            2'b01: next_pc_mux_out = branch_target;            // Jump / Branch comes from register file (R[rb])
            2'b10: next_pc_mux_out = return_target;            // Return from Stack from data memory  (M[++SP])
            default: next_pc_mux_out = pc_out_wire + 8'd1;     // Default to Normal Flow and to avoid latches
        endcase
    end


endmodule


