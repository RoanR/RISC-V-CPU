module MEM_FSM(IR, A, B, PC, clk,
            IR_out, RD_out, A_out, PC_out);

//Port Discipline
//Input Signals
input wire [31:0] IR;
input wire [31:0] A;
input wire [31:0] B;
input wire [31:0] PC;
input wire        clk;

//Internal Signals
reg enable;
reg read;
wire [31:0] RD;
wire [2:0]  func;

//Output Signals
output wire [31:0] IR_out;
output wire [31:0] RD_out;
output wire [31:0] A_out;
output wire [31:0] PC_out;

/*----------------------------------------------------*/
assign func = IR[14:12];
/*----------------------------------------------------*/
//The Fake memory model
MEM_Fake mem(enable, read, A, func, B, RD);
/*----------------------------------------------------*/
//The control for the enable and read/write
always @ (IR) begin
    if (IR[6:0] == 7'b0000011) begin 
        read = 1;
        enable = 1;
        end
    else if (IR[6:0] == 7'b0100011) begin
        read = 0;
        enable = 1;
        end
    else enable = 0;
end
/*----------------------------------------------------*/
//Writing to Registers
REG32_S IR_reg_mem(clk, 1'b1, IR, IR_out);
REG32_S RD_reg_mem(clk, 1'b1, RD, RD_out);
REG32_S PC_reg_mem(clk, 1'b1, PC, PC_out);
REG32_S A_reg_mem(clk, 1'b1, A, A_out);
/*----------------------------------------------------*/

endmodule