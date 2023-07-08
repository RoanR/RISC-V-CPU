module READ_FSM(IR, WB_data, WB_address, PC, clk,
            IR_out, A_out, B_out, PC_out, I_out);

//Port Discipline 
//Input Wires
input wire [31:0] IR;
input wire [31:0] WB_data;
input wire [31:0] PC;
input wire [4:0]  WB_address;
input wire        clk;

//Internal Signals
reg  [4:0]  A_address;
reg  [4:0]  B_address;
wire        rst;
wire        write_en;
reg  [2:0]  I_func;
reg  [19:0] Imm;
wire [31:0] A_int;
wire [31:0] B_int;
wire [31:0] I_int;

//Output Signals
output wire [31:0] IR_out;
output wire [31:0] A_out;
output wire [31:0] B_out;
output wire [31:0] I_out;
output wire [31:0] PC_out;

assign write_en = 1'b1;
/*----------------------------------------------------*/
REG32_Bank registers(clk, rst, write_en, WB_address, WB_data, 
                A_address, A_int, B_address, B_int);
/*----------------------------------------------------*/
IMM_EXTD I_extender(I_func, Imm, 
                I_int);
/*----------------------------------------------------*/
always @ (IR) begin
    A_address = IR[19:15];
    B_address = IR[24:20];
end

always @ (IR) begin
    if (IR[6:0] == 7'b1100011) begin //BEQ
        Imm = {IR[31], IR[7], IR[30:25], IR[11:8]};
        if (IR[13] == 1'b1) I_func = 3'b101;
        else I_func = 3'b001;  
        end
    else if (IR[6:0] == 7'b0000011) begin //LB
        Imm = {IR[31:20]};
        if (IR[14] == 1'b1) I_func = 3'b101;
        else I_func = 3'b001;  
        end
    else if ((IR[6:0] == 7'b0110111)|(IR[6:0] == 7'b0010111)) begin //LUI
        Imm = {IR[31:12]};
        I_func = 3'b101;
        end
    else if (IR[6:0] == 7'b1101111) begin //JAL
        Imm = {IR[31], IR[19:12], IR[20], IR[30:21]};
        I_func = 3'b001;
        end
    else if (IR[6:0] == 7'b1100111) begin //JALR
        Imm = {IR[31:20]};
        I_func = 3'b001;
        end
    else if (IR[6:0] == 7'b0100011) begin //SB
        Imm = {IR[31:25], IR[11:7]};
        I_func = 3'b101;
        end
    else if (IR[6:0] == 7'b0010011) begin //ADDI
        Imm = {IR[31:25], IR[11:7]};
        if (IR[14:12] == 3'b011) I_func = 3'b101;
        else I_func = 3'b101;
        end
end
/*----------------------------------------------------*/
REG32_S IR_reg_mem(clk, 1'b1, IR, IR_out);
REG32_S PC_reg_mem(clk, 1'b1, PC, PC_out);
REG32_S A_reg_mem(clk, 1'b1, A_int, A_out);
REG32_S B_reg_mem(clk, 1'b1, B_int, B_out);
REG32_S I_reg_mem(clk, 1'b1, I_int, I_out);
/*----------------------------------------------------*/
endmodule