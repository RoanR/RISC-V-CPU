`include "definitions.v"

module memory(IR, A, B, PC, clk,
            IR_out, RD_out, A_out, PC_out, AM_out,
            v_in, v_out, r_in, r_out, stall);

//Port Discipline
//Input Wires
input wire [31:0] IR;  //Instruction to be executed
input wire [31:0] A;   //Output from ALU, to be used as an address
input wire [31:0] B;   //rs2, the value to write in Store operation
input wire [31:0] PC;  //the PC of Instruction being executed
input wire        clk;

//Internal Signals
wire       en; //Write/Read enable, Allow access to data memory only on write/read op
assign en = ((IR[6:0] == 7'b0000011 )|( IR[6:0] == 7'b0100011)); 

//Output Signals 
output reg [31:0] IR_out; 
output reg [31:0] RD_out; //Output from Read if Load operation
output reg [31:0] A_out;  //Output passed from ALU (A)
output reg [31:0] PC_out;
output reg [4 :0] AM_out; //Register that A_out holds the data for (for forwarding) 

//Stall Controls
input wire  v_in;
input wire  r_in;
input wire  stall;
output reg  v_out;
output reg  r_out;

//The Memory - making it byte addressable - Bottom 2bits used to select which block
reg [7:0] mem0 [0:65536];
reg [7:0] mem1 [0:65536];
reg [7:0] mem2 [0:65536];
reg [7:0] mem3 [0:65536];

//Driver for RD and AM
always @ (posedge clk) begin
    if (r_out & v_in) begin
        AM_out <= forward(IR);
        if (!IR[5]) RD_out <= read(en, IR); //If Load, then perform the load instruction
        else        RD_out <= 32'hZZZZZZZZ; //If not a Load operation set to Z, to make obvious in waveform
    end
end

//Decide the address for forwarding
function [4:0] forward(input [31:0] IR); begin
    //If Load then data hasnt been sign extended so technically not available for forwarding yet
    //If store or Branch then no return register so set to 0
    if ((IR[6:0] == `STORE)|(IR[6:0] == `BRANCH)|(IR[6:0] == `LOAD)) forward = 4'b0000;
    else forward = IR[11:7]; 
end
endfunction

//Decide which function to use to Load
function [31:0] read(input en, input [31:0] IR); begin
    if (en) begin
        //Signed and Unsigned Loads of same length can be treated the same
        // due to sign extension happening in Writeback Stage
        case (IR[14:12])
        `LB, `LBU: read = lb(A); //LB
        `LH, `LHU: read = lh(A); //LH
        `LW:       read = lw(A); //LW
        default: read = 32'hZZZZZZZZ; //Set to Z to make error obvious in waveform
        endcase 
        end 
    end 
endfunction

//Load Byte
function [7:0] lb (input [31:0] A); begin 
    case (A[1:0]) //Depending on which block its stored in
    0: lb = mem0[A[31:2]];
    1: lb = mem1[A[31:2]];
    2: lb = mem2[A[31:2]];
    3: lb = mem3[A[31:2]];
    endcase
end
endfunction

//Load Half-Word
function [15:0] lh (input [31:0] A); begin 
    case (A[1:0]) //Depending on order the bytes are stored in
    0: lh = {mem1[A[31:2]],   mem0[A[31:2]]};
    1: lh = {mem2[A[31:2]],   mem1[A[31:2]]};
    2: lh = {mem3[A[31:2]],   mem2[A[31:2]]};
    3: lh = {mem0[A[31:2]+1], mem3[A[31:2]]};
    endcase
end
endfunction

//Load Word
function [31:0] lw (input [31:0] A); begin 
    case (A[1:0]) //Depending on the oreder the bytes are stored in
    0: lw = {mem3[A[31:2]],   mem2[A[31:2]],   mem1[A[31:2]],   mem0[A[31:2]]};
    1: lw = {mem0[A[31:2]+1], mem3[A[31:2]],   mem2[A[31:2]],   mem1[A[31:2]]};
    2: lw = {mem1[A[31:2]+1], mem0[A[31:2]+1], mem3[A[31:2]],   mem2[A[31:2]]};
    3: lw = {mem2[A[31:2]+1], mem1[A[31:2]+1], mem0[A[31:2]+1], mem3[A[31:2]]};
    endcase
end
endfunction

//Decide Which function to use to Store
always @ (posedge clk) begin
    //If enable and read and control
    if (en & (IR[5]) & v_in & r_out) begin 
        case(IR[14:12])
        `SB: sb;
        `SH: sh;
        `SW: sw;
        endcase
    end
end 

//Store Byte
task sb; begin
    case(A[1:0])
    0: mem0[A[31:2]] <= B[7:0];
    1: mem1[A[31:2]] <= B[7:0];
    2: mem2[A[31:2]] <= B[7:0];
    3: mem3[A[31:2]] <= B[7:0];
    endcase
end
endtask

//Store Half-Word
task sh; begin
    case (A[1:0])
    0: begin mem0[A[31:2]] <= B[7:0]; mem1[A[31:2]]     <= B[15:8]; end
    1: begin mem1[A[31:2]] <= B[7:0]; mem2[A[31:2]]     <= B[15:8]; end
    2: begin mem2[A[31:2]] <= B[7:0]; mem3[A[31:2]]     <= B[15:8]; end
    3: begin mem3[A[31:2]] <= B[7:0]; mem0[A[31:2] + 1] <= B[15:8]; end
    endcase
end 
endtask

//Store Word
task sw; begin
    case (A[1:0])
    0: begin mem0[A[31:2]] <= B[7:0]; mem1[A[31:2]] <= B[15:8];   mem2[A[31:2]] <= B[23:16];   mem3[A[31:2]]   <= B[31:24]; end
    1: begin mem1[A[31:2]] <= B[7:0]; mem2[A[31:2]] <= B[15:8];   mem3[A[31:2]] <= B[23:16];   mem0[A[31:2]+1] <= B[31:24]; end
    2: begin mem2[A[31:2]] <= B[7:0]; mem3[A[31:2]] <= B[15:8];   mem0[A[31:2]+1] <= B[23:16]; mem1[A[31:2]+1] <= B[31:24]; end
    3: begin mem3[A[31:2]] <= B[7:0]; mem0[A[31:2]+1] <= B[15:8]; mem1[A[31:2]+1] <= B[23:16]; mem2[A[31:2]+1] <= B[31:24]; end
    endcase
end
endtask

//Driver for IR, PC, and A
always @ (posedge clk) begin
    if (r_out & v_in) IR_out <= IR;
    if (r_out & v_in) A_out  <= A;
    if (r_out & v_in) PC_out <= PC;
end

initial begin 
    v_out = 0;
    r_out = 1;
end

//Driver for control signals
always @ (posedge clk) begin
    if (stall) begin v_out <= 0; r_out <= 0; end
    else begin v_out <= v_in; r_out <= r_in; end
end

endmodule
