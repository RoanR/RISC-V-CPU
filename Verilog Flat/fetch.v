module fetch(PC_alu, PC_prev, COMP_alu, clk,
            PC_out, IR_out,
            v_in, v_out, r_in, /*r_out*/, stall);

//Port Discipline
//Input Wires
input wire [31:0] PC_alu;  //From Ex stage
input wire [31:0] PC_prev; //For stalls
input wire        COMP_alu;   
input wire        clk;

//Internal Signals
wire [31:0] PC_curr; 
assign PC_curr = (COMP_alu & v_in) ? PC_alu : (PC_prev + 4);

//Stall Controls
input wire  v_in;
input wire  r_in;
input wire  stall;
output reg  v_out;

//Output Signals
output reg [31:0] PC_out;
output reg [31:0] IR_out;

//Instruction memory - only using bottom 16
reg [31:0] instructions [0:65535]; 

always @ (posedge clk) begin
    if (r_in) PC_out <= PC_curr;
    if (r_in) IR_out <= instructions[PC_curr[31:2]];
end

initial begin
    $readmemh("/home/p32065rr/Documents/RISC-V-CPU/Verilog Flat/instr.mem", instructions);
    PC_out = -4;
end

initial begin 
    v_out = 0;
end

always @ (posedge clk) begin
    //v_out control 
    
    if (stall)  v_out <= 0;
    else        v_out <= 1;
end
endmodule