`include "definitions.v"

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
reg         flush; //When Branch is taken and pipeline needs to be flushed


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
    //If Load then data hasnt been loaded yet so can't forward
    //If Store or Branch then no data to be forwarded
    if ((IR[6:0] == `STORE)|(IR[6:0] == `LOAD)|(IR[6:0] == `BRANCH)) forward = 4'b0000;
    else forward = IR[11:7]; 
end
endfunction

//ALU
function [31:0] alu (input [31:0] rs1, rs2, A, B, I, PC, IR, input [2:0] func); begin
    if (IR[6:0] == `BRANCH)      func = 3'b000; //Branches should be signed additions
    else if (IR[6:0] == `LOAD)  func = 3'b000;  //Loads should be signed additions
    else if (IR[6:0] == `STORE) func = 3'b000;  //Stores should be signed additions
    else if (IR[6:0] == `LUI)   func = 3'b000;  //LUI should be adds with x0 
    else func = IR[14:12];

    //Select Inputs by considering Forwarding, Immediates, PC, and Registers fetched in previous stage
    rs1 = select_rs1(PC, A, IR, FA, FM, FW, AA, AM, AW); //Select Input 1
    rs2 = select_rs2(I,  B, IR, FA, FM, FW, AA, AM, AW); //Select Input 2
    
    case (func)
    `ADD: begin 
        if (IR[30] & (IR[6:0] == `REG_ALU)) alu = rs1 - rs2; //SUB (signed subtraction)
        else alu = rs1 + rs2; //JALR, all Branches, Loads, Stores, ADDI, ADD (signed addition)
        end
    `SLL: alu = rs1<<rs2; //Shift Left
    `SLT: alu = ($signed(rs1) < $signed(rs2));//Explicit Signed
    `SLTU: alu = (rs1 < $unsigned(rs2)); //Cast to Unsigned
    `XOR: alu = (rs1 ^ rs2); 
    `SR: begin 
        if (IR[30]) alu = $signed(rs1)>>>rs2; //SRAI,  SRA
        else        alu = ($unsigned(rs1)>>rs2);//SRLI, SRL
        end
    `OR:  alu = (rs1 | rs2); 
    `AND: alu = (rs1 & rs2); 
    endcase
end
endfunction

//Comparison Unit
function comp (input signed [31:0] A_in, B_in, input unsigned  [31:0] A_un, B_un, IR); begin
    //Select Inputs, Considering Forwarded Values and Registers fetchted in previous stage
    A_in = select_A(A, FA, FM, FW, IR[19:15], AA, AM, AW);
    B_in = select_B(B, FA, FM, FW, IR[24:20], AA, AM, AW);

    //Unsigned cast
    A_un = A_in;
    B_un = B_in;

    
    if (IR[6:0] == `BRANCH) begin //IF Branch, then test condition
        case(IR[14:12])
        `BEQ:  comp = (A_in == B_in);
        `BNE:  comp = (A_in != B_in);
        `BLT:  comp = (A_in < B_in);
        `BGE:  comp = (A_in >= B_in);
        `BLTU: comp = (A_un < B_un);
        `BGEU: comp = (A_un >= B_un);
        default: comp = 1'b0;
        endcase
        end
    else if (IR[6:0] == `JAL | IR[6:0] == `JALR) begin //Always take as unconditional Branch
        comp = 1;
        end
    else comp = 1'b0; //Dont take if not branch
end
endfunction

//Decide Input 1 to ALU
function [31:0] select_rs1(input [31:0] PC, A, IR, FA, FM, FW, input [4:0] AA, AM, AW); begin
    if (IR[6:0] == `BRANCH | IR[6:0] == `JAL) select_rs1 = PC; //Only Instructions where PC is changed
    else begin //Decide if more recent version is available from forwarding
        if      ((IR[19:15] == AA)&(AA != 0)) select_rs1 = FA;
        else if ((IR[19:15] == AM)&(AM != 0)) select_rs1 = FM;
        else if ((IR[19:15] == AW)&(AW != 0)) select_rs1 = FW;
        else                                  select_rs1 = A; 
    end 
    end                     
endfunction

//Decide Input 2 to ALU
function [31:0] select_rs2(input [31:0] I, B, IR, FA, FM, FW, input [4:0] AA, AM, AW); begin
    if (IR[6:0] == `REG_ALU) begin //Only reg is its a register operation, decide on forwarding
        if      ((IR[24:20] == AA)&(AA != 0)) select_rs2 = FA;
        else if ((IR[24:20] == AM)&(AM != 0)) select_rs2 = FM;
        else if ((IR[24:20] == AW)&(AW != 0)) select_rs2 = FW;
        else                      select_rs2 = B; 
        end
    else                          select_rs2 = I; //Usually Immediate
end
endfunction

//Function to decide forwarding in A
function [31:0] select_A (input [31:0] A, FA, FM, FW, input [4:0] addr, AA, AM, AW); begin
    //Always register, so just decide on if forwarding is needed
    if      ((addr == AA)&(AA!=0)) select_A = FA;
    else if ((addr == AM)&(AM!=0)) select_A = FM;
    else if ((addr == AW)&(AW!=0)) select_A = FW;
    else                           select_A = A; 
    end
endfunction

//Function to decide forwarding in B
function [31:0] select_B (input [31:0] B, FA, FM, FW, input [4:0] addr, AA, AM, AW); begin
    //Always register, so just decide on if forwarding is needed
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
    if (stall)                  begin v_out <= 0; r_out <= 0; end //Synchronous Stall
    else if (COMP_out & !flush) begin v_out <= 0; r_out <= 1; flush <= 1; end //Flush has to happen for 2 clk-cycles
    else if (flush)             begin v_out <= 0; r_out <= 1; flush <= 0; end //Still invalid, second clk-cycle
    else                        begin v_out <= v_in; r_out <= r_in; end //Normal operation
end
endmodule
