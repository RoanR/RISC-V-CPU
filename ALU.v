
module ALU(alu_in_A, alu_in_B, func, control, alu_out, clk);

//Port Discipline
input signed  [31:0] alu_in_A; // rs1 or PC
input signed  [31:0] alu_in_B; // rs2 or Imm
input wire    [2:0]  func;	   // ALU function
input wire           control;  // extra control wire	
input wire           clk;      // ALU is clock driven
output reg signed [31:0] alu_out;  // output wire


wire unsigned [31:0] in_A_unsigned;
assign in_A_unsigned = alu_in_A;
wire unsigned [31:0] in_B_unsigned;
assign in_B_unsigned = alu_in_B;

always @ (posedge clk) begin 
	case(func)
		3'b000: begin 
			if (control) alu_out = alu_in_A; //For LUI Instructions
			else alu_out = alu_in_A + alu_in_B; end //ADD or ADDI
		3'b001: alu_out = alu_in_A << alu_in_B; //Left Shift Logical
		3'b010: alu_out = alu_in_A < alu_in_B; //Set less than
		3'b011: alu_out = in_A_unsigned < in_B_unsigned; //Set less than unsigned
		3'b100: alu_out = alu_in_A ^ alu_in_B; //XOR 
		3'b101: begin 
			if (control) alu_out = alu_in_A >>> alu_in_B; //Right Shift arithmetic
			else alu_out = alu_in_A >> alu_in_B; end //Right Shift Logical
		3'b110: alu_out = alu_in_A | alu_in_B; //OR
		3'b111: alu_out = alu_in_A & alu_in_B; //AND
		default: alu_out = alu_in_A;
    endcase
end
endmodule

