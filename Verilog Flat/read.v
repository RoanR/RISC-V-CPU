`include "definitions.v"

module read(IR, WB_data, WB_address, PC, clk,
            IR_out, A_out, B_out, PC_out, I_out,
            v_wb, v_in, v_out, r_in, r_out, stall);

//Port Discipline 
//Input Wires
input wire [31:0] IR;
input wire [31:0] WB_data;
input wire [31:0] PC;
input wire [4:0]  WB_address;
input wire        clk;


//Internal Wires
wire [7:0] op;

//The registers 
reg  [31:0] registers [0:31];

//Stall Controls
input wire  v_wb; 
input wire  v_in;
input wire  r_in;
input wire  stall;
output reg  v_out;
output reg  r_out;

//Output Signals
output reg [31:0] IR_out;
output reg [31:0] A_out;
output reg [31:0] B_out;
output reg [31:0] I_out;
output reg [31:0] PC_out;

function [31:0] calculate_i (input [31:0] IR); 
begin
    case (IR[6:0])
    `LUI:    calculate_i = {IR[31:12], 12'h000};
    `AUIPC:  calculate_i = {IR[31:12], 12'h000};
    `JAL:    calculate_i = $signed({IR[31], IR[19:12], IR[20], IR[30:21], {1'b0}});
    `JALR:   calculate_i = $signed(IR[31:20]); //JALR
    `BRANCH: calculate_i = $signed({IR[31], IR[7], IR[30:25], IR[11:8], {1'b0}}); //BEQ,BNE,BLT,BGE
    `LOAD:   calculate_i = $signed(IR[31:20]); //LB, LH, LW, LBU, LHU
    `STORE:  calculate_i = $signed({IR[31:25], IR[11:7]}); //SH, SW, SB
    `IM_ALU: begin
        if ((IR[14:12] == `SLL)|(IR[14:12] == `SR)) calculate_i = $unsigned(IR[24:20]); //Shifts
        else calculate_i = $signed(IR[31:20]); //SLTUI, XORI, ORI, ANDI, ADDI, SLTI,
        end
    default:    calculate_i = 32'hXXXXXXXX; 
    endcase
end
endfunction

always @ (posedge clk) begin
    registers[WB_address] = WB_data;
end

always @ (posedge clk) begin
    if (r_out & v_in) begin
        if (IR[19:15] == 0 | IR[6:0] == `LUI)   A_out <= 32'h00000000;
        else if (IR[19:15] == WB_address)       A_out <= WB_data; 
        else                                    A_out <= registers[IR[19:15]];
    end
    if (r_out & v_in) begin
        if      (IR[24:20] == 0)          B_out <= 32'h00000000;
        else if (IR[24:20] == WB_address) B_out <= WB_data; 
        else                              B_out <= registers[IR[24:20]];
    end
end

always @ (posedge clk) begin
    if (r_out & v_in) I_out <= calculate_i(IR);
    if (r_out & v_in) PC_out <= PC;
    if (r_out & v_in) IR_out <= IR;
end

initial begin 
    v_out = 0;
    r_out = 1;
end

//Driver for control signals
always @ (posedge clk) begin
    if (stall)      begin v_out <= 0; r_out <= 0; end
    else            begin v_out <= v_in; r_out <= r_in; end
end
endmodule