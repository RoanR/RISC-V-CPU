module memory(IR, A, B, PC, clk,
            IR_out, RD_out, A_out, PC_out);

//Port Discipline
//Input Wires
input wire [31:0] IR;
input wire [31:0] A;
input wire [31:0] B;
input wire [31:0] PC;
input wire        clk;

//Internal Signals
wire       en;
assign en   =  ((IR[6:0] == 7'b0000011 )|( IR[6:0] == 7'b0100011));

//Output Signals 
output reg [31:0] IR_out;
output reg [31:0] RD_out;
output reg [31:0] A_out;
output reg [31:0] PC_out;

//The Memory - making it byte addressable
reg [7:0] mem0 [0:65535];
reg [7:0] mem1 [0:65535];
reg [7:0] mem2 [0:65535];
reg [7:0] mem3 [0:65535];

always @ (posedge clk) begin
    if (!IR[5]) RD_out <= read(en, IR);
    else        RD_out <= 32'hZZZZZZZZ;
end

function [31:0] read(input en, input [31:0] IR); begin
    if (en) begin
        case (IR[14:12])
        0: read = {mem0[A]};                            //LB
        1: read = {mem1[A], mem0[A]};                   //LH
        2: read = {mem3[A], mem2[A], mem1[A], mem0[A]}; //LW
        4: read = {mem0[A]};                          //LBU
        5: read = {mem1[A], mem0[A]};                 //LHU
        default: read = 32'hZZZZZZZZ;
        endcase 
        end 
    end 
endfunction

always @ (posedge clk) begin
    if (en & (IR[5])) begin
        case(IR[14:12])
        0: begin mem0[A] <= B[7:0]; end 
        1: begin mem0[A] <= B[7:0]; mem1[A] <= B[15:8]; end
        2: begin mem0[A] <= B[7:0]; mem1[A] <= B[15:8]; mem2[A] <= B[23:16]; mem3[A] <= B[31:24]; end
        //default begin mem0[A] <= 8'hZZ; mem1[A] <= 8'hZZ; mem2[A] <= 8'hZZ; mem3[A] <= 8'hZZ; end
        endcase
    end
end 

always @ (posedge clk) begin
    IR_out <= IR;
    A_out  <= A;
    PC_out <= PC;
end

endmodule
