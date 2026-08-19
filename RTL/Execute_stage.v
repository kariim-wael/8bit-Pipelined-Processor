
module ExecuteStage (

	input wire clk,
	input wire rst,
	
    input  wire signed [7:0] A,
    input  wire signed [7:0] B,
    input  [3:0] ALUControl,
    input        FlagWriteEnable,
	input 		 interrupt_restore_flags,
	input 		 interrupt_save_flags,
    input        SetC,
    input        ClrC,
	
    output wire signed [7:0] ALUResult,
    output wire      Z,
    output wire      N,
    output wire      C,
    output wire      V
);

    wire [7:0] alu_result;
    wire Z_out, N_out, C_out, V_out;

    // ALU
    ALU alu_unit (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .CarryIn(C),          
        .Result(alu_result),
		
        .Z_out(Z_out),
        .N_out(N_out),
        .C_out(C_out),
        .V_out(V_out)
    );

    // Combinational CCR
    CCR ccr_unit (
        .Z_in(Z_out),
        .N_in(N_out),
        .C_in(C_out),
        .V_in(V_out),
        .FlagWriteEnable(FlagWriteEnable),
		.interrupt_save_flags(interrupt_save_flags),
		.interrupt_restore_flags(interrupt_restore_flags),
        .SetC(SetC),
        .ClrC(ClrC),
		.clk(clk),
		.rst(rst),
		
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );

    assign ALUResult = alu_result;

endmodule
