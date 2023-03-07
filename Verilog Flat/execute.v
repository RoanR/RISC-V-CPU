module execute(IR, I, A, B, PC, FA, FM, FW, AA, AM, AW, clk,
            IR_out, ALU_out, COMP_out, PC_out, B_out,
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
reg         full;
reg   [4:0] waitlist [0:2]; 

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

//Initialising control signals
initial begin 
    full = 0;
    v_out = 0;
    r_out = 1;
    waitlist[0] = 1'bx;
    waitlist[1] = 1'bx;
end

//Driver for control signals
always @ (posedge clk) begin
    //v_out control 
    if (full) v_out = 1;
    else      v_out = 0;
    
    //r_out control
    if (!full) r_out = 1;
    else       r_out = r_in; 

    //Stall Condition
    if (stall) begin v_out = 0; r_out = 0; end
    
    if ((AM == waitlist[0])) waitlist[0] = 1'bx;
    if ((AM == waitlist[1])) waitlist[1] = 1'bx;

    //Stall if waiting for inputs
    if (!((IR[6:0] == 7'b1101111)||(IR[6:0] == 7'b0010111)||(IR[6:0] == 7'b0110111))) begin
        //Stall if waiting for input from rs1
        if ((waitlist[0] == IR[19:15]) || (waitlist[1] == IR[19:15])) begin
            r_out = 0; v_out = 0;  
        end 

        //Stall if waiting for input for rs2
        if ((IR[6:0] == 7'b1100011)||(IR[6:0] == 7'b0100011)||(IR[6:0] == 7'b0110011)) begin
            if ((waitlist[0] == IR[24:20]) || (waitlist[1] == IR[24:20])) begin
                r_out = 0; v_out = 0;  
            end 
        end
    end

    //full control
    if (v_out && r_in) full = 0;
    if (v_in && r_out) full = 1;
    if ((IR[6:0] != 7'b1100011) & (IR[6:0] != 7'b0100011)) begin
        if      (r_out & v_in & (waitlist[0] == 1'bx)) waitlist[0] = IR[11:7];
        else if (r_out & v_in & (waitlist[1] == 1'bx)) waitlist[1] = IR[11:7];
    end
end

//Main Driver for output
always @ (posedge clk) begin
    if (r_out & v_in) COMP_out <= comp(A_in, B_in, A_un, B_un, IR);
    if (r_out & v_in) ALU_out  <= alu(rs1, rs2, A, B, I, PC, IR, func);
    if (r_out & v_in) IR_out   <= IR;
    if (r_out & v_in) PC_out   <= PC;
    if (r_out & v_in) B_out    <= B;
end

//ALU
function [31:0] alu (input [31:0] rs1, rs2, A, B, I, PC, IR, input [2:0] func); begin
    if (IR[6:0] == 7'b1100011)      func = 3'b000; //Branches should be signed additions
    else if (IR[6:0] == 7'b0000011) func = 3'b000; //Loads should be signed additions
    else if (IR[6:0] == 7'b0100011) func = 3'b000; //Stores should be signed additions
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
        if (IR[30]) alu =($signed(rs1)>>>$signed(rs2)); //SRAI,  SRA
        else alu = ($unsigned(rs1) >> $unsigned(rs2));//SRLI, SRL
        end
    3'b110: alu = (rs1 | rs2); //ORI, OR
    3'b111: alu = (rs1 & rs2); //ANDI, AND
    endcase
end
endfunction

//Comparison Unit
function comp (input [31:0] A_in, B_in, A_un, B_un, IR); begin
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
    else comp = 1'b0; 
end
endfunction

//Decide Input 1 to ALU
function [31:0] select_rs1(input [31:0] PC, A, IR, FA, FM, FW, input [4:0] AA, AM, AW); begin
    if (IR[6:0] == 7'b1100011) select_rs1 = PC; 
    else begin
        if ((IR[19:15] == AA)&(AA != 0)) select_rs1 = FA;
        if ((IR[19:15] == AM)&(AM != 0)) select_rs1 = FM;
        if ((IR[19:15] == AW)&(AW != 0)) select_rs1 = FW;
        else                 select_rs1 = A; 
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

endmodule
