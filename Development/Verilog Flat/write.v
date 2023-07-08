`include "definitions.v"

module write(IR, RD, A, PC, clk, 
            data, address,
            v_in, v_out, r_out, stall);

//Port Discipline
//Input Wires
input wire [31:0] IR; //Instrcution to be executed
input wire [31:0] RD; //Data if instrcution was a Load
input wire [31:0] PC; //PC for current Instruction
input wire [31:0] A;  //Data from Execute, if not Load
input wire        clk;

//Stall Controls
input wire  v_in;
input wire  stall;
output reg  v_out;
output reg  r_out;

//Output Registers
output reg [31:0] data;    //Data to written back to registers
output reg [4:0]  address; //Which register to write the data back to

//Driver for address
always @ (posedge clk) begin
    if (r_out & v_in) begin
        if      (IR[6:0] == `STORE)  address <= 4'b0000; //Store
        else if (IR[6:0] == `BRANCH) address <= 4'b0000; //Branch
        else                         address <= IR[11:7];
    end
end

//Extending Value for Load Operation
function [31:0] read(input [31:0] IR, RD); begin   
    if ((IR[14:12] == `LB)|(IR[14:12] == `LH)|(IR[14:12] == `LW)) read = $signed(RD);  //Signed Load
    else if ((IR[14:12] == `LBU)|(IR[14:12] == `LHU))             read = $unsigned(RD);//Unsigned Load
    end 
endfunction

//Driver for Data
always @ (posedge clk) begin
    if (r_out & v_in) begin
        case(IR[6:0])
        `JAL:  data <= PC + 4;        //JAL
        `JALR: data <= PC + 4;        //JALR
        `LOAD: data <= read(IR, RD);  //Load
        default:    data <= A;
        endcase
    end
end

//Stall controls 
initial begin 
    v_out = 0;
    r_out = 1;
end

//Driver for control signals
always @ (posedge clk) begin
    if (stall) begin v_out <= 0; r_out <= 0; end //Synchronous Stall
    else begin v_out <= v_in;    r_out <= 1; end //Normal Operation
end

endmodule