module Instruction_Memory (
    input  wire [7:0] addr,          // Address from PC
    
    output wire [7:0] instruction,   // Instruction at current address (IR)
    output wire [7:0] reset_vector,  // Value at M[0] (for Reset)
    output wire [7:0] intr_vector    // Value at M[1] (for Interrupts)
);

    // Define memory array: 256 bytes, 8-bit width
    reg [7:0] mem [0:255];

    // Initialize memory from binary files to load program instructions
    initial begin
        $readmemb("program.txt", mem); 
    end

    // Asynchronous read (Output updates immediately when addr changes)
    assign instruction = mem[addr];

    // Hardwired outputs for Reset and Interrupt instructions
    assign reset_vector = mem[0];
    assign intr_vector  = mem[1];

endmodule


