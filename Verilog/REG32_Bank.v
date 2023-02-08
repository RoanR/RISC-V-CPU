module REG32_Bank (clk, rst, write_en, write_addr, write_data, 
  read_addr_A, read_data_A, read_addr_B, read_data_B);

//Port Dispicline
input  wire        clk;         // System clock
input  wire        rst;         // Master reset
input  wire        write_en;    // Write enable
input  wire  [4:0] write_addr;  // dest
input  wire [31:0] write_data;  // Data in
input  wire  [4:0] read_addr_A; // src_A
output wire [31:0] read_data_A; // Operand A
input  wire  [4:0] read_addr_B; // src_B
output wire [31:0] read_data_B;	// Operand B


reg  [31:0] xr [0:31];				// Main register file
initial xr[0] = 32'h00000000;// x0 is always zero

// Read ports read registers but force 0000 for R0
assign read_data_A = (read_addr_A == 0) ? 32'h00000000 : xr[read_addr_A];
assign read_data_B = (read_addr_B == 0) ? 32'h00000000 : xr[read_addr_B];


// Register write is synchronised by the clock
always @ (posedge clk)
  if (write_en && (write_addr != 0))		// write if enabled and not R0
    xr[write_addr] <= write_data;
    
endmodule