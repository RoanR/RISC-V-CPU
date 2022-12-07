module EX(IR, Imm, A, B, PC, /*Wb, Ex,*/ clk, alu_res, comp_res, B_res, PC_res, IR_res);

//Port Discipline
input wire [31:0] Imm; //Immediate value
input wire [31:0] A;   //Reg A value
input wire [31:0] B;   //Reg B value
input wire [31:0] PC;  //PC value 
//input wire [31:0] Wb;  //Forwarded from Wb stage
//input wire [31:0] Ex   //Forwarded from previous Ex stage

//Control signals, including system clock
input wire B_Imm_cont, A_PC_cont, alu_func, alu_cont, comp_func, clk;

//output wires
output wire [31:0] alu_res;  //output from alu
output wire [31:0] comp_res; //output from comp
output wire [31:0] B_res;    //output from operand B
output wire [31:0] PC_res;   //output from PC

/*----------------------------------------------------*/

//Passing PC and IR values forward
assign PC_res = PC;

/*----------------------------------------------------*/

//Temporary as No forwarding Implemented yet
wire [31:0] forwarded_A;
wire [31:0] forwarded_B;
assign forwarded_A = A; //Replace with MUX when forwarding
assign forwarded_B = B; //Replace with MUX when forwarding
assign B_res = forwarded_B;

//Choosing betweeen Immediate or Reg B
wire [31:0] operand_B;
MUX_2to1 B_Or_Imm(B, Imm, B_Imm_cont, operand_B); 

//Choosing between PC or Reg A
wire [31:0] operand_A;
MUX_2to1 A_or_PC(forwarded_A, PC, A_PC_cont, operand_A);

/*----------------------------------------------------*/

ALU alu(operand_A, operand_B, alu_func, alu_cont, alu_res);
COMP comp(operand_A, operand_B, comp_func, comp_res);


endmodule