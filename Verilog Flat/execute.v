module execute(IR, I, A, B, PC, FA, FM, FW, AA, AM, AW, clk,
            IR_out, ALU_out, COMP_out, PC_out, B_out, AA_out,
            v_in, v_out, r_in, r_out, stall);

//Input Wires 
input wire [31:0] IR;  //Instruction Reg value
input wire [31:0] I;   //Immediate value
input wire [31:0] A;   //Reg A value
input wire [31:0] B;   //Reg B value
input wire [31:0] PC;  //PC value 
input wire [31:0] FA;  //Forwarded value from ALU
input wire [31:0] FM;  //Forwarded value from MEM
input wire [31:0] FW;  //Forwarded value from WB
input wire [4 :0] AA;  //Address that FA relates to
input wire [4 :0] AM;  //Address that FM relates to
input wire [4 :0] AW;  //Address that FW relates to
input wire        clk;

//Control Signals
input wire  v_in;
input wire  r_in;
input wire  stall;
output reg  v_out;
output reg  r_out;
reg         flush;


//Internal Signal
reg   [2:0] func;

//Inputs to ALU
reg signed   [31:0] rs1;
reg signed   [31:0] rs2;
//Inputs to Comparison Unit
reg signed   [31:0] A_in;
reg signed   [31:0] B_in;

//Unsigned Inputs to Comparison Unit
wire unsigned [31:0] A_un;
wire unsigned [31:0] B_un;

//Output Wires
output reg        COMP_out;
output reg [31:0] IR_out;
output reg [31:0] ALU_out;
output reg [31:0] PC_out;
output reg [31:0] B_out;
output reg [4 :0] AA_out; 


//Main Driver for output
always @ (posedge clk) begin
    if (r_out & v_in & !COMP_out) COMP_out <= comp(A_in, B_in, A_un, B_un, IR);
    else                          COMP_out <= 0;
    if (r_out & v_in & !COMP_out) ALU_out  <= alu(rs1, rs2, A, B, I, PC, IR, func);
    if (r_out & v_in & !COMP_out) IR_out   <= IR;
    if (r_out & v_in & !COMP_out) PC_out   <= PC;
    if (r_out & v_in & !COMP_out) B_out    <= B;
    if (r_out & v_in & !COMP_out) AA_out   <= forward(IR);
end

//Decide address out for forwarding
function [4:0] forward (input [31:0] IR); begin
    if ((IR[6:0] == 7'b0100011)|(IR[6:0] == 7'b0000011 )|(IR[6:0] == 7'b1100011)) forward = 4'b0000;
    else forward = IR[11:7]; 
end
endfunction

//ALU
function [31:0] alu (input [31:0] rs1, rs2, A, B, I, PC, IR, input [2:0] func); begin
    if (IR[6:0] == 7'b1100011)      func = 3'b000; //Branches should be signed additions
    else if (IR[6:0] == 7'b0000011) func = 3'b000; //Loads should be signed additions
    else if (IR[6:0] == 7'b0100011) func = 3'b000; //Stores should be signed additions
    else if (IR[6:0] == 7'b0110111) func = 3'b000; //LUI should be adds with x0 
    else func = IR[14:12];

    rs1 = select_rs1(PC, A, IR, FA, FM, FW, AA, AM, AW);
    rs2 = select_rs2(I,  B, IR, FA, FM, FW, AA, AM, AW);
    
    case (func)
    3'b000: begin 
        if (IR[30] & (IR[6:0] == 7'b0110011)) alu = rs1 - rs2; //SUB (signed subtraction)
        else alu = rs1 + rs2; //JALR, all Branches, Loads, Stores, ADDI, ADD (signed addition)
        end
    3'b001: alu = rs1<<rs2; //SLLI, SLL
    3'b010: alu = ($signed(rs1) < $signed(rs2)); //SLTI, SLT
    3'b011: alu = (rs1 < $unsigned(rs2)); //SLTIU, SLTU
    3'b100: alu = (rs1 ^ rs2); //XOR, XORI
    3'b101: begin 
        if (IR[30]) alu = $signed(rs1)>>>rs2; //SRAI,  SRA
        else        alu = ($unsigned(rs1)>>rs2);//SRLI, SRL
        end
    3'b110: alu = (rs1 | rs2); //ORI, OR
    3'b111: alu = (rs1 & rs2); //ANDI, AND
    endcase
end
endfunction

//Comparison Unit
function comp (input signed [31:0] A_in, B_in, input unsigned  [31:0] A_un, B_un, IR); begin
    A_in = select_A(A, FA, FM, FW, IR[19:15], AA, AM, AW);
    B_in = select_B(B, FA, FM, FW, IR[24:20], AA, AM, AW);
    A_un = A_in;
    B_un = B_in;
    if (IR[6:0] == 7'b1100011) begin
        case(IR[14:12])
        3'b000: comp = (A_in == B_in); //BEQ
        3'b001: comp = (A_in != B_in);//BNE
        3'b010: comp = 1'b0;
        3'b011: comp = 1'b0;
        3'b100: comp = (A_in < B_in);//BLT
        3'b101: comp = (A_in >= B_in);//BGE
        3'b110: comp = (A_un < B_un);//BLTU
        3'b111: comp = (A_un >= B_un);//BGEU
        endcase
    end
    else if (IR[6:0] == 7'b1101111 | IR[6:0] == 7'b1100111 ) begin // For JAL and JALR
        comp = 1;
    end
    else comp = 1'b0; 
end
endfunction

//Decide Input 1 to ALU
function [31:0] select_rs1(input [31:0] PC, A, IR, FA, FM, FW, input [4:0] AA, AM, AW); begin
    if (IR[6:0] == 7'b1100011 | IR[6:0] == 7'b1101111) select_rs1 = PC; 
    else begin
        if      ((IR[19:15] == AA)&(AA != 0)) select_rs1 = FA;
        else if ((IR[19:15] == AM)&(AM != 0)) select_rs1 = FM;
        else if ((IR[19:15] == AW)&(AW != 0)) select_rs1 = FW;
        else                                  select_rs1 = A; 
    end 
    end                     
endfunction

//Decide Input 2 to ALU
function [31:0] select_rs2(input [31:0] I, B, IR, FA, FM, FW, input [4:0] AA, AM, AW); begin
    if (IR[6:0] == 7'b0110011) begin
        if      ((IR[24:20] == AA)&(AA != 0)) select_rs2 = FA;
        else if ((IR[24:20] == AM)&(AM != 0)) select_rs2 = FM;
        else if ((IR[24:20] == AW)&(AW != 0)) select_rs2 = FW;
        else                      select_rs2 = B; 
        end
    else                          select_rs2 = I;    
end
endfunction

//Function to decide forwarding in A
function [31:0] select_A (input [31:0] A, FA, FM, FW, input [4:0] addr, AA, AM, AW); begin
    if      ((addr == AA)&(AA!=0)) select_A = FA;
    else if ((addr == AM)&(AM!=0)) select_A = FM;
    else if ((addr == AW)&(AW!=0)) select_A = FW;
    else                           select_A = A; 
    end
endfunction

//Function to decide forwarding in B
function [31:0] select_B (input [31:0] B, FA, FM, FW, input [4:0] addr, AA, AM, AW); begin
    if      ((addr == AA)&(AA!=0)) select_B = FA;
    else if ((addr == AM)&(AM!=0)) select_B = FM;
    else if ((addr == AW)&(AW!=0)) select_B = FW;
    else                           select_B = B; 
    end
endfunction

//Initialising control signals
initial begin 
    v_out = 0;
    r_out = 1;
    flush = 0;
end

//Driver for control signals
always @ (posedge clk) begin
    if (stall)                  begin v_out <= 0; r_out <= 0; end
    else if (COMP_out & !flush) begin v_out <= 0; r_out <= 1; flush <= 1; end
    else if (flush)             begin v_out <= 0; r_out <= 1; flush <= 0; end
    else                        begin v_out <= v_in; r_out <= r_in; end
end
endmodule
