module EX_FSM(IR, Imm, A, B, PC, clk,
            IR_out, ALU_out, COMP_out, PC_out, B_out);

//Port Discipline and Internal Wires
//Input Wires
input wire [31:0] IR; //Instruction Reg value
input wire [31:0] Imm; //Immediate value
input wire [31:0] A;   //Reg A value
input wire [31:0] B;   //Reg B value
input wire [31:0] PC;  //PC value 

//Control Input Wires
input wire clk;

//Internal Wires
wire [31:0] ALU_ex;     //output from alu to be latched
wire COMP_ex;    //output from comp to be latched
wire [31:0] B_ex;       //output from choice of forwarded B to be latched
wire [6:0]  Low_Instr;   //Bottom 7 bits from IR;
reg B_Imm_Alu, A_PC_Alu; 
reg B_Imm_Comp, A_PC_Comp;
reg alu_cont;

reg  [2:0] alu_func;
wire [2:0] comp_func;

//Output Wires
output wire [31:0] IR_out;
output wire COMP_out;
output wire [31:0] ALU_out;
output wire [31:0] PC_out;
output wire [31:0] B_out;
/*----------------------------------------------------*/
//Constant Assignment
assign Low_Instr = IR[6:0];
//assign alu_func =  IR[14:11];
assign comp_func = IR[14:12];
/*----------------------------------------------------*/
//Driver for ALU input control
always @ (posedge clk) begin
    case (Low_Instr)
    7'b0110111, 7'b0000011, 7'b0100011, 7'b0010011: begin
        B_Imm_Alu = 1;
        A_PC_Alu  = 0;
        alu_func  = IR[14:12];
    end         
    7'b0010111, 7'b1101111, 7'b1100111, 7'b1100011: begin
        B_Imm_Alu = 1;
        A_PC_Alu  = 1;
        alu_func  = 3'b000;
    end  
    7'b0110011: begin
        B_Imm_Alu = 0;
        A_PC_Alu  = 0;
        alu_func  = IR[14:12];
    end 
    default: begin
        B_Imm_Alu = 0;
        A_PC_Alu  = 0;
    end
    endcase
end
/*----------------------------------------------------*/
//Driver for COMP input control
always @ (posedge clk) begin
    case (Low_Instr)
    7'b0010011: begin
        B_Imm_Comp = 1;
        A_PC_Comp  = 0;
    end         
    7'b1100011: begin
        B_Imm_Comp = 1;
        A_PC_Comp  = 1;
    end  
    7'b0110011: begin
        B_Imm_Comp = 0;
        A_PC_Comp  = 0;
    end 
    default: begin
        B_Imm_Comp = 0;
        A_PC_Comp  = 0;
    end
    endcase
end
/*----------------------------------------------------*/
//Driver for alu_control
always @ (posedge clk) begin 
    if (alu_func == 3'b101) alu_cont = IR[30];
    else if ((alu_func == 3'b000) && (Low_Instr == 7'b0110011)) alu_cont = IR[30];
    else alu_cont = 0;
end
/*----------------------------------------------------*/
EX ex(Imm, A, B, PC, /*Wb, Ex,*/ 
        B_Imm_Alu, A_PC_Alu, B_Imm_Comp, A_PC_Comp,
        alu_func, comp_func, alu_cont,
        ALU_ex, COMP_out, B_ex);
/*----------------------------------------------------*/
//Latch to register
REG32_S B_reg_ex(clk, 1'b1, B_ex, B_out);
REG32_S ALU_reg_ex(clk, 1'b1, ALU_ex, ALU_out);
REG32_S PC_reg_ex(clk, 1'b1, PC, PC_out);
REG32_S IR_reg_ex(clk, 1'b1, IR, IR_out);
/*----------------------------------------------------*/

endmodule