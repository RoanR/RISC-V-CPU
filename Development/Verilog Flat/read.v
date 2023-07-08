`include "definitions.v"

module read(IR, WB_data, WB_address, PC, clk,
            IR_out, A_out, B_out, PC_out, I_out,
            v_wb, v_in, v_out, r_in, r_out, stall);

//Port Discipline 
//Input Wires
input wire [31:0] IR;         //Instrcution to be processed
input wire [31:0] WB_data;    //Data from WB stage
input wire [31:0] PC;         //PC of instruction being processed
input wire [4:0]  WB_address; //Register to write data back to, if 0, then dont perform register write
input wire        clk; 

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
output reg [31:0] A_out; //Register 1
output reg [31:0] B_out; //Register 2
output reg [31:0] I_out; //Immediate with sign extension
output reg [31:0] PC_out;

//Perform Immediate concatenation and then sign Extension
function [31:0] calculate_i (input [31:0] IR); 
begin
    case (IR[6:0])
    `LUI:    calculate_i = {IR[31:12], 12'h000}; //Load Unsigned Immedate, so dont sign extend
    `AUIPC:  calculate_i = {IR[31:12], 12'h000}; //Add Unsigned Immediate to PC, so dont sign extend
    `JAL:    calculate_i = $signed({IR[31], IR[19:12], IR[20], IR[30:21], {1'b0}});
    `JALR:   calculate_i = $signed(IR[31:20]); 
    `BRANCH: calculate_i = $signed({IR[31], IR[7], IR[30:25], IR[11:8], {1'b0}}); 
    `LOAD:   calculate_i = $signed(IR[31:20]); 
    `STORE:  calculate_i = $signed({IR[31:25], IR[11:7]});
    `IM_ALU: begin
        if ((IR[14:12] == `SLL)|(IR[14:12] == `SR)) calculate_i = $unsigned(IR[24:20]); //Shifts
        else calculate_i = $signed(IR[31:20]); //All other Immediate ALU operations
        end
    default:    calculate_i = 32'hXXXXXXXX; //Shows Errors in waveform easier
    endcase
end
endfunction

//Perform Writeback
always @ (posedge clk) begin
    registers[WB_address] = WB_data;
end

//Driver for A and B - Fetch Registers
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

//Driver for other outputs
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