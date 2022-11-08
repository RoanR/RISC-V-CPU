`default_nettype none

module ALU( input  signed wire [31:0] alu_in_A, // rs1 or PC		
        	input  signed wire [31:0] alu_in_B, // rs2 or Imm	
		    input  wire [2:0] func,	            //ALU function
			input  wire control,	            //extra control wire	 			
		    output signed reg  [31:0] alu_out); //output wire

unsigned wire [31:0] in_A_unsigned = alu_in_A;
unsigned wire [31:0] in_B_unsigned = alu_in_B;

always @ (*) Begin 
	case (func)
		0: Begin 
			if (control) result = alu_in_A; //For LUI Instructions
			else alu_out = alu_in_A + alu_in_B; end //ADD or ADDI
		1: alu_out = alu_in_A << alu_in_B; //Left Shift Logical
		2: alu_out = alu_in_A < alu_in_B; //Set less than
		3: alu_out = in_A_unsigned < in_B_unsigned; //Set less than unsigned
		4: alu_out = alu_in_A ^ alu_in_B; //XOR 
		5: begin 
			if (control) alu_out = alu_in_A >>> alu_in_B; //Right Shift arithmetic
			else alu_out = alu_in_A >> alu_in_B; end //Right Shift Logical
		6: alu_out = alu_in_A || alu_in_B; //OR
		7: alu_out = alu_in_A && alu_in_B; //AND
		default: result = alu_in_A;
    endcase
end


