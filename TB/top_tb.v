
`timescale 1ns / 1ps

module Processor_TB;



    // 1. Inputs
    reg clk;
    reg rst;
    reg interrupt;
    reg [7:0] in_port_val;

    // 2. Outputs
    wire [7:0] out_port_val;

    // 3. Instantiate Processor
    Processor_TopLevel UUT (
        .clk(clk), 
        .rst(rst), 
        .interrupt(interrupt), 
        .in_port_val(in_port_val), 
        .out_port_val(out_port_val)
    );

    // 4. Clock Generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 5. Test Sequence
    initial 
    begin

        // Step 1: System Initialization 
        rst = 1;          // Assert Reset
        interrupt = 0;
        in_port_val = 0;

        // Wait for global reset
        #100;

        // Step 2: Start Processor
        rst = 0;          // Release Reset (PC starts at M[0])

        #40;
        in_port_val = 'sd10;  
        
        #10;
        in_port_val = 'sd13;  
        

        #10;
        in_port_val = 'sd27;  
        

        #300; 

        // End Simulation
        $stop;
    end

endmodule