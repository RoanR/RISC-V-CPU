// 32-bit register used in RISC design

module REG32(input wire CLK,
			 input wire CE,
			 input wire [31:0] in,
			 output reg [31:0] out);

// Simple 32-bit register. On rising edge of clock the value of out is updated to the value of in

always @(posedge CLK)
if (CE == 1) in <= out;       
endmodule