module read(IR, WB_data, WB_address, PC, clk,
            IR_out, A_out, B_out, PC_out, I_out);

//Port Discipline 
//Input Wires
input wire [31:0] IR;
input wire [31:0] WB_data;
input wire [31:0] PC;
input wire [4:0]  WB_address;
input wire        clk;

//Internal Wires
wire [7:0] op;
wire wr_en; 
wire [4:0] A_address;
wire [4:0] B_address;

//The registers 
reg  [31:0] registers [0:31];

//Output Signals
output reg [31:0] IR_out;
output reg [31:0] A_out;
output reg [31:0] B_out;
output reg [31:0] I_out;
output reg [31:0] PC_out;

assign op = IR[6:0];
assign A_address = IR[19:15];
assign B_address = IR[24:20];
assign wr_en = 1; 

function [31:0] calculate_i (input [7:0] op, input [31:0] IR); 
begin
    case (op)
    7'b0110111: calculate_i = {IR[31:12], 12'h000}; //LUI
    7'b0010111: calculate_i = {IR[31:12], 12'h000}; //AUIPC
    7'b1101111: calculate_i = $signed({IR[31], IR[19:12], IR[20], IR[30:21], {1'b0}}); //JAL
    7'b1100111: calculate_i = $signed(IR[31:20]); //JALR
    7'b1100011: begin
        if ((IR[14:12] == 3'b110)|(IR[14:12] == 3'b111)) calculate_i = $unsigned({IR[31], IR[7], IR[30:25], IR[11:8], {1'b0}}); //BGEU, BLTU
        else calculate_i = $signed({IR[31], IR[7], IR[30:25], IR[11:8], {1'b0}}); //BEQ,BNE,BLT,BGE
        end
    7'b0000011: calculate_i = $signed(IR[31:20]); //LB, LH, LW, LBU, LHU
    7'b0100011: calculate_i = $signed({IR[31:25], IR[11:7]}); //SH, SW, SB
    7'b0010011: begin
        if ((IR[14:12] == 3'b000)|(IR[14:12] == 3'b010)) calculate_i = $signed(IR[31:20]); //ADDI, SLTI,
        else calculate_i = $unsigned(IR[31:20]); //SLTUI, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        end
    default:    calculate_i = 32'hXXXXXXXX; 
    endcase
end
endfunction

always @ (posedge clk) begin
    if (wr_en == 1'b1) registers[WB_address] <= WB_data;
    A_out <= (A_address == 0) ? 32'h00000000 : registers[A_address];
    B_out <= (B_address == 0) ? 32'h00000000 : registers[B_address];
end

always @ (posedge clk) begin
    I_out <= calculate_i(op, IR);
    PC_out <= PC;
    IR_out <= IR;
end
endmodule
