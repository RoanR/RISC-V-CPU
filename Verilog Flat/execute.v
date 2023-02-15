module execute(IR, I, A, B, PC, clk,
            IR_out, ALU_out, COMP_out, PC_out, B_out);

//Input Wires 
input wire [31:0] IR; //Instruction Reg value
input wire [31:0] I; //Immediate value
input wire [31:0] A;   //Reg A value
input wire [31:0] B;   //Reg B value
input wire [31:0] PC;  //PC value 
input wire        clk;

//Internal Wires
wire  [6:0] op;
reg   [2:0] func;
assign op   = IR[6:0];

reg signed   [31:0] rs1;
reg signed   [31:0] rs2;

wire unsigned [31:0] A_un;
wire unsigned [31:0] B_un;
assign A_un = A;
assign B_un = B;

//Output Wires
output reg        COMP_out;
output reg [31:0] IR_out;
output reg [31:0] ALU_out;
output reg [31:0] PC_out;
output reg [31:0] B_out;

function [31:0] alu (input [31:0] rs1, rs2, A, B, I, PC, input [6:0] op, input [2:0] func, input [31:0] IR); begin
    if (op == 7'b1100011) func = 3'b000; //Branches should be signed additions
    else if (op == 7'b0000011) func = 3'b000; //Loads should be signed additions
    else if (op == 7'b0100011) func = 3'b000; //Stores should be signed additions
    else func = IR[14:12];

    case (op)
    7'b1100011: begin rs1 = PC; rs2 = I; end //Branch
    7'b0110011: begin rs1 = A;  rs2 = B; end //ADD to AND
    default:    begin rs1 = A;  rs2 = I; end //Else
    endcase
    
    case (func)
    3'b000: begin 
        if (IR[30] & (op == 7'b0110011)) alu = rs1 - rs2; //SUB (signed subtraction)
        else alu = rs1 + rs2; //JALR, all Branches, Loads, Stores, ADDI, ADD (signed addition)
        end
    3'b001: alu = rs1<<rs2; //SLLI, SLL
    3'b010: alu = ($signed(rs1) < $signed(rs2)); //SLTI, SLT
    3'b011: alu = (rs1 < $unsigned(rs2)); //SLTIU, SLTU
    3'b100: alu = (rs1 ^ rs2); //XOR, XORI
    3'b101: begin 
        if (IR[30]) alu =($signed(rs1)>>>$signed(rs2)); //SRAI,  SRA
        else alu = ($unsigned(rs1) >> $unsigned(rs2));//SRLI, SRL
        end
    3'b110: alu = (rs1 | rs2); //ORI, OR
    3'b111: alu = (rs1 & rs2); //ANDI, AND
    endcase
end
endfunction

function comp (input [31:0] A, B, A_un, B_un, input [2:0] func, input [6:0] op); begin
    if (op == 7'b1100011) begin
        case(func)
        3'b000: comp = (A === B); //BEQ
        3'b001: comp = (A != B);//BNE
        3'b010: comp = 1'b0;
        3'b011: comp = 1'b0;
        3'b100: comp = (A < B);//BLT
        3'b101: comp = (A >= B);//BGE
        3'b110: comp = (A_un < B_un);//BLTU
        3'b111: comp = (A_un >= B_un);//BGEU
        endcase
    end
    else comp = 1'b0; 
end
endfunction

always @ (posedge clk) begin
    COMP_out <= comp(A, B, A_un, B_un, IR[14:12], op);
    ALU_out  <= alu(rs1, rs2, A, B, I, PC, op, func, IR);
    IR_out   <= IR;
    PC_out   <= PC;
    B_out    <= B;
end
endmodule
