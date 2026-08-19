
module Register_File (
    input  wire       clk, rst,
    
    // Write Port (WRITE BACK STAGE SIGNALS)
    input  wire       wr_en,
    input  wire [1:0] wr_addr,
    input  wire signed [7:0] wr_data,
    
    // Read Ports
    input  wire [1:0] rd_addr1, rd_addr2,
    output wire signed [7:0] rd_data1, rd_data2,
    
    // SP Control
    input  wire       SP_Inc,   // from decode stage
    input  wire       SP_Dec,   //from write back stage
    output wire [7:0] SP,
    output wire [7:0] RTI_SP     // Output current SP value for RTI and RET instructions

);

    reg signed [7:0] registers [0:3];
    reg [7:0] sp_next_value;

    // Async Read & Output
    assign rd_data1 = registers[rd_addr1];
    assign rd_data2 = registers[rd_addr2];
    assign SP       = sp_next_value ; 


    assign RTI_SP = sp_next_value; // Output current SP++ value for RTI and RET instructions



    // Combinational: Calculate Next SP Value
    always @(*) begin
        if (SP_Inc)      sp_next_value = registers[3] + 8'd1;   // decode pop
        else if (SP_Dec) sp_next_value = registers[3] - 8'd1;   // write back push
        else             sp_next_value = registers[3];
    end

    // Synchronous: Write & Update
    always @(posedge clk or posedge rst) begin
        if (rst) 
        begin
            registers[0] <= 8'h00;
            registers[1] <= 8'h00;
            registers[2] <= 8'h00;
            registers[3] <= 8'hFF; // Initial SP (255)
        end
        else begin
            // Normal Write
            if (wr_en && wr_addr != 2'b11) 
                registers[wr_addr] <= wr_data;
            
            // SP Update (Overrides standard write to R3)
            if (SP_Inc || SP_Dec) 
                registers[3] <= sp_next_value;
        end
    end

endmodule


