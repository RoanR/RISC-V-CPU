module EX(Imm, A, B, PC, /*Wb, Ex,*/ 
        B_Imm_Alu, A_PC_Alu, B_Imm_Comp, A_PC_Comp,
        alu_func, comp_func, alu_cont,
        alu_res, comp_res, B_res);

//Port Discipline
input wire [31:0] Imm; //Immediate value
input wire [31:0] A;   //Reg A value
input wire [31:0] B;   //Reg B value
input wire [31:0] PC;  //PC value 
//input wire [31:0] Wb;  //Forwarded from Wb stage
//input wire [31:0] Ex   //Forwarded from previous Ex stage

//Control signals, for mux
input wire B_Imm_Alu, A_PC_Alu, B_Imm_Comp, A_PC_Comp;
//Control signals, for ALU and COMP
input wire [2:0] alu_func, comp_func;
input wire alu_cont;

//output wires
output wire [31:0] alu_res;  //output from alu
output wire comp_res; //output from comp
output wire [31:0] B_res;    //output from operand B

/*----------------------------------------------------*/

//Temporary as No forwarding Implemented yet
wire [31:0] forwarded_A;
wire [31:0] forwarded_B;
assign forwarded_A = A; //Replace with MUX when forwarding
assign forwarded_B = B; //Replace with MUX when forwarding
assign B_res = B;

/*----------------------------------------------------*/
//ALU Stuff
//Choosing betweeen Immediate or Reg B
wire [31:0] operand_B_Alu;
MUX_2to1 B_Or_Imm_Alu(forwarded_B, Imm, B_Imm_Alu, operand_B_Alu); 

//Choosing between PC or Reg A
wire [31:0] operand_A_Alu;
MUX_2to1 A_or_PC_Alu(forwarded_A, PC, A_PC_Alu, operand_A_Alu);

//The ALU
ALU alu(operand_A_Alu, operand_B_Alu, alu_func, alu_cont, alu_res);

/*----------------------------------------------------*/
//Comparison Stuff
//Choosing betweeen Immediate or Reg B
wire [31:0] operand_B_Comp;
MUX_2to1 B_Or_Imm_Comp(forwarded_B, Imm, B_Imm_Comp, operand_B_Comp); 

//Choosing between PC or Reg A
wire [31:0] operand_A_Comp;
MUX_2to1 A_or_PC_Comp(forwarded_A, PC, A_PC_Comp, operand_A_Comp);

//The COMP
COMP comp(operand_A_Comp, operand_B_Comp, comp_func, comp_res);


endmodule