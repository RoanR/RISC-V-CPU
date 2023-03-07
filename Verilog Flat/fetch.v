module fetch(PC_alu, PC_prev, COMP_alu, clk,
            PC_out, IR_out,
            v_in, v_out, r_in, r_out, stall);

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
output reg  r_out;
reg         full;

//Output Signals
output reg [31:0] PC_out;
output reg [31:0] IR_out;

//Instruction memory - only using bottom 16
reg [31:0] instructions [0:65535]; 

always @ (posedge clk) begin
    if (r_out) PC_out <= PC_curr;
    if (r_out) IR_out <= instructions[PC_curr[31:2]];
end

initial begin
    $readmemh("/home/p32065rr/Documents/RISC-V-CPU/Verilog Flat/instructions.mem", instructions);
    PC_out = -4;
end

initial begin 
    full = 0;
    v_out = 1;
    r_out = 1;
end

always @ (posedge clk) begin
    //v_out control 
    if (full) v_out = 1;
    else      v_out = 0;
    
    //r_out control
    if (!full) r_out = 1;
    else       r_out = r_in; 

    //Stall Condition
    if (stall) begin v_out = 0; r_out = 0; end

    //full control
    if (v_out && r_in) full = 0;
    if (r_out) full = 1;
end
endmodule