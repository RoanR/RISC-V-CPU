module execute(IR, I, A, B, PC, FA, AA, clk,
            IR_out, ALU_out, COMP_out, PC_out, B_out);

//Input Wires 
input wire [31:0] IR;  //Instruction Reg value
input wire [31:0] I;   //Immediate value
input wire [31:0] A;   //Reg A value
input wire [31:0] B;   //Reg B value
input wire [31:0] PC;  //PC value 
input wire [31:0] FA;  //Forwarded value from previous ALU
input wire [4 :0] AA;  //Address that FA relates to
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

function [31:0] alu (input [31:0] rs1, rs2, A, B, I, FA, PC, input [6:0] op, input [2:0] func, input [31:0] IR, input [4:0] AA); begin
    if (op == 7'b1100011) func = 3'b000; //Branches should be signed additions
    else if (op == 7'b0000011) func = 3'b000; //Loads should be signed additions
    else if (op == 7'b0100011) func = 3'b000; //Stores should be signed additions
    else func = IR[14:12];

    rs1 = select_rs1(PC, A, FA, IR, AA);
    rs2 = select_rs2(I, B, FA, IR, AA);
    
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

function [31:0] select_rs1(input [31:0] PC, A, FA, IR, input [4:0] AA); begin
    if (IR[6:0] == 7'b1100011) select_rs1 = PC; 
    else if  (IR[19:15] == AA) select_rs1 = FA;
    else                       select_rs1 = A;  
end
endfunction

function [31:0] select_rs2(input [31:0] I, B, FA, IR, input [4:0] AA); begin
    if (IR[6:0] == 7'b0110011) select_rs2 = select_B(B, FA, IR, AA);
    else                       select_rs2 = I;    
end
endfunction

function [31:0] select_B(input [31:0] B, FA, IR, input [4:0] AA); begin
    if (IR[24:20] == AA) select_B = FA;
    else                 select_B = B; 
end
endfunction

always @ (posedge clk) begin
    COMP_out <= comp(A, B, A_un, B_un, IR[14:12], op);
    ALU_out  <= alu(rs1, rs2, A, B, I, FA, PC, op, func, IR, AA);
    IR_out   <= IR;
    PC_out   <= PC;
    B_out    <= B;
end
endmodule
