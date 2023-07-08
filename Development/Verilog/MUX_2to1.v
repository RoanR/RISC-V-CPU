module MUX_2to1     (input wire [31:0] mux_in_a,
			        input wire [31:0] mux_in_b,
			        input wire        control,
			        output reg [31:0] mux_out);

// when control = 0: out = a, control = 1: out = b
						
always @ (*)       
 if(control == 1)         
  mux_out = mux_in_b;
 else
  mux_out = mux_in_a;
  
endmodule