module REG32_S(clk, enable, data_in, data_out);

//Port Discipline 
input wire  clk;      //system clock
input wire  enable;   //allows data to be overwritten
input wire  data_in;  //data to write to register on clk edge and enable
output reg  data_out; //data contained within the register

// Simple 32-bit register. On rising edge of clock the value of out is updated to the value of in
always @(posedge clk)
	if (enable == 1) begin
		data_out = data_in;
	end    
endmodule