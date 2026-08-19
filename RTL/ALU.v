
module ALU (

    input  wire signed    [7:0] A,
    input  wire signed    [7:0] B,
    input                 [3:0] ALUControl,
    input            CarryIn,
	
    output reg signed [7:0] Result,
    output reg       Z_out,
    output reg       N_out,
    output reg       C_out,
    output reg       V_out
);

    always @(*) begin
        // Default values
        Result = 8'd0;
        C_out  = 1'b0;
        V_out  = 1'b0;

        case (ALUControl)

            4'b0000: Result = B;                // PASS B

            4'b0001: begin                      // ADD
                {C_out, Result} = A + B;
                V_out = (~(A[7] ^ B[7])) & (Result[7] ^ A[7]);
            end

            4'b0010: begin                      // SUB
                {C_out, Result} = A - B;
                V_out = (A[7] ^ B[7]) & (Result[7] ^ A[7]);
            end

            4'b0011: begin                      // INC
                {C_out, Result} = B + 1;
                V_out = (~B[7]) & Result[7];
            end

            4'b0100: begin                      // DEC
                {C_out, Result} = B - 1;
                V_out = B[7] & (~Result[7]);
            end

            4'b0101: Result = A & B;             // AND
            4'b0110: Result = A | B;             // OR
            4'b0111: Result = ~B;                // NOT

            4'b1000: begin                       // NEG
                {C_out, Result} = (~B) + 1;
                V_out = (B == 8'b10000000);
            end

            4'b1001: begin                       // RLC
                Result = {B[6:0], CarryIn};
                C_out  = B[7];
            end

            4'b1010: begin                       // RRC
                Result = {CarryIn, B[7:1]};
                C_out  = B[0];
            end
			
			4'b1011: begin
                {C_out, Result} = A - 1;		 // Loop instruction
                V_out = A[7] & (~Result[7]);				
			end
            default: Result = 0;
        endcase

        Z_out = (Result == 8'd0);
        N_out = Result[7];
    end

endmodule


