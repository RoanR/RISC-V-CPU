// 32-bit register used in RISC design

module REG32(input wire CLK,
			 input wire CE,
			 input wire ready_in,
			 input wire valid_in,
			 input wire [31:0] data_in,
			 output wire ready_out,
			 output wire valid_out, 
			 output reg [31:0] data_out);

reg full;
assign full = 0;

always @(posedge CLK)
	if (!full) ready_out <= 1;
	if (ready_in) ready_out <= 1;

// Simple 32-bit register. On rising edge of clock the value of out is updated to the value of in
always @(posedge CLK)
	if ((CE == 1) && (valid_in)) begin
		data_out <= data_in;
		full <= 1; 
		valid_out <= 1;
		ready_out <= 0;
	end    
endmodule