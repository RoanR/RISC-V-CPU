module fetch(PC_alu, PC_prev, COMP_alu, clk,
            PC_out, IR_out);

//Port Discipline
//Input Wires
input wire [31:0] PC_alu;  //From Ex stage
input wire [31:0] PC_prev; //For stalls
input wire        COMP_alu;   
input wire        clk;

//Internal Signals
wire [31:0] PC_curr; 
assign PC_curr = (COMP_alu) ? PC_alu : (PC_prev + 1);

//Output Signals
output reg [31:0] PC_out;
output reg [31:0] IR_out;

//Instruction memory - only using bottom 16
reg [31:0] instructions [0:31]; 

always @ (posedge clk) begin
    PC_out <= PC_curr;
    IR_out <= instructions[PC_curr];
end

initial begin
    $readmemb("/home/p32065rr/Documents/RISC-V-CPU/Verilog Flat/instruction_memory.list", instructions);
    PC_out = 0;
end
endmodule