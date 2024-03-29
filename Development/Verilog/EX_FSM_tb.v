module EX_FSM_tb ();                  

//Input registers
reg  [31:0] A;                    
reg  [31:0] B;                    
reg  [31:0] IR;
reg  [31:0] Imm;
reg  [31:0] PC;
reg         clk;     

//Output registers                    
wire  [31:0] IR_res;
wire  [31:0] ALU_res;
wire  COMP_res;
wire  [31:0] PC_res;
wire  [31:0] B_res; 

//Internal registers
integer file_handle;                     
integer tst, k; 
reg [31:0] A_in   [0:7];                    
reg [31:0] B_in   [0:7];
reg [31:0] Imm_in [0:7];
reg [31:0] IR_in  [0:36];

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

EX_FSM fsm_dut(IR, Imm, A, B, PC, clk,
            IR_res, ALU_res, COMP_res, PC_res, B_res);


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task printTest(input integer n); begin
    case (n)
        0: $fdisplay(file_handle, "Testing LUI function");
        1: $fdisplay(file_handle, "Testing AUIPC function");
        2: $fdisplay(file_handle, "Testing JAL function");
        3: $fdisplay(file_handle, "Testing JALR function");
        4: $fdisplay(file_handle, "Testing BEQ function");
        5: $fdisplay(file_handle, "Testing BNE function");
        6: $fdisplay(file_handle, "Testing BLT function");
        7: $fdisplay(file_handle, "Testing BGE function");
        8: $fdisplay(file_handle, "Testing BLTU function");
        9: $fdisplay(file_handle, "Testing BGEU function");
        10: $fdisplay(file_handle, "Testing LB function");
        11: $fdisplay(file_handle, "Testing LH function");
        12: $fdisplay(file_handle, "Testing LW function");
        13: $fdisplay(file_handle, "Testing LBU function");
        14: $fdisplay(file_handle, "Testing LHU function");
        15: $fdisplay(file_handle, "Testing SB function");
        16: $fdisplay(file_handle, "Testing SH function");
        17: $fdisplay(file_handle, "Testing SW function");
        18: $fdisplay(file_handle, "Testing ADDI function");
        19: $fdisplay(file_handle, "Testing SLTI function");
        20: $fdisplay(file_handle, "Testing SLTIU function");
        21: $fdisplay(file_handle, "Testing XORI function");
        22: $fdisplay(file_handle, "Testing ORI function");
        23: $fdisplay(file_handle, "Testing ANDI function");
        24: $fdisplay(file_handle, "Testing SLLI function");
        25: $fdisplay(file_handle, "Testing SRLI function");
        26: $fdisplay(file_handle, "Testing SRAI function");
        27: $fdisplay(file_handle, "Testing ADD function");
        28: $fdisplay(file_handle, "Testing SUB function");
        29: $fdisplay(file_handle, "Testing SLL function");
        30: $fdisplay(file_handle, "Testing SLT function");
        31: $fdisplay(file_handle, "Testing SLTU function");
        32: $fdisplay(file_handle, "Testing XOR function");
        33: $fdisplay(file_handle, "Testing SRL function");
        34: $fdisplay(file_handle, "Testing SRA function");
        35: $fdisplay(file_handle, "Testing OR function");
        36: $fdisplay(file_handle, "Testing AND function");
        default: $fdisplay(file_handle, "Unknown function");
    endcase
end
endtask


initial begin
    //The Instructions, Excluding CSR 
    IR_in[0] =  32'bxxxxxxxxxxxxxxxxxxxxxxxxx0110111; //LUI
    IR_in[1] =  32'bxxxxxxxxxxxxxxxxxxxxxxxxx0010111; //AUIPC
    IR_in[2] =  32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111; //JAL
    IR_in[3] =  32'bxxxxxxxxxxxxxxxxx000xxxxx1100111; //JALR
    IR_in[4] =  32'bxxxxxxxxxxxxxxxxx000xxxxx1100011; //BEQ
    IR_in[5] =  32'bxxxxxxxxxxxxxxxxx001xxxxx1100011; //BNE
    IR_in[6] =  32'bxxxxxxxxxxxxxxxxx100xxxxx1100011; //BLT
    IR_in[7] =  32'bxxxxxxxxxxxxxxxxx101xxxxx1100011; //BGE
    IR_in[8] =  32'bxxxxxxxxxxxxxxxxx110xxxxx1100011; //BLTU
    IR_in[9] =  32'bxxxxxxxxxxxxxxxxx111xxxxx1100011; //BGEU
    IR_in[10] = 32'bxxxxxxxxxxxxxxxxx000xxxxx0000011; //LB
    IR_in[11] = 32'bxxxxxxxxxxxxxxxxx001xxxxx0000011; //LH
    IR_in[12] = 32'bxxxxxxxxxxxxxxxxx010xxxxx0000011; //LW
    IR_in[13] = 32'bxxxxxxxxxxxxxxxxx100xxxxx0000011; //LBU
    IR_in[14] = 32'bxxxxxxxxxxxxxxxxx101xxxxx0000011; //LHU
    IR_in[15] = 32'bxxxxxxxxxxxxxxxxx000xxxxx0100011; //SB
    IR_in[16] = 32'bxxxxxxxxxxxxxxxxx001xxxxx0100011; //SH
    IR_in[17] = 32'bxxxxxxxxxxxxxxxxx010xxxxx0100011; //SW
    IR_in[18] = 32'bxxxxxxxxxxxxxxxxx000xxxxx0010011; //ADDI
    IR_in[19] = 32'bxxxxxxxxxxxxxxxxx010xxxxx0010011; //SLTI
    IR_in[20] = 32'bxxxxxxxxxxxxxxxxx011xxxxx0010011; //SLTUI
    IR_in[21] = 32'bxxxxxxxxxxxxxxxxx100xxxxx0010011; //XORI
    IR_in[22] = 32'bxxxxxxxxxxxxxxxxx110xxxxx0010011; //ORI
    IR_in[23] = 32'bxxxxxxxxxxxxxxxxx111xxxxx0010011; //ANDI
    IR_in[24] = 32'b0000000xxxxxxxxxx001xxxxx0010011; //SLLI
    IR_in[25] = 32'b0000000xxxxxxxxxx101xxxxx0010011; //SRLI
    IR_in[26] = 32'b0100000xxxxxxxxxx101xxxxx0010011; //SRAI
    IR_in[27] = 32'b0000000xxxxxxxxxx000xxxxx0110011; //ADD
    IR_in[28] = 32'b0100000xxxxxxxxxx000xxxxx0110011; //SUB
    IR_in[29] = 32'b0000000xxxxxxxxxx001xxxxx0110011; //SLL
    IR_in[30] = 32'b0000000xxxxxxxxxx010xxxxx0110011; //SLT
    IR_in[31] = 32'b0000000xxxxxxxxxx011xxxxx0110011; //SLTU
    IR_in[32] = 32'b0000000xxxxxxxxxx100xxxxx0110011; //XOR
    IR_in[33] = 32'b0000000xxxxxxxxxx101xxxxx0110011; //SRL
    IR_in[34] = 32'b0100000xxxxxxxxxx101xxxxx0110011; //SRA
    IR_in[35] = 32'b0000000xxxxxxxxxx110xxxxx0110011; //OR
    IR_in[36] = 32'b0000000xxxxxxxxxx111xxxxx0110011; //AND

    //Standard Operation 
    A_in[0] = 32'h00000001; B_in[0] = 32'h00000001; Imm_in[0] = 32'hxxxxxxxx; 
    A_in[1] = 32'h00000001; B_in[1] = 32'hxxxxxxxx; Imm_in[1] = 32'h00000001; 
    A_in[2] = 32'hxxxxxxxx; B_in[2] = 32'h00000001; Imm_in[2] = 32'h00000001; 
    // Testing 0 input
    A_in[3] = 32'h00000000; B_in[3] = 32'h00000000; Imm_in[3] = 32'h00000000;
    // Testing Maximum input
    A_in[4] = 32'hFFFFFFFF; B_in[4] = 32'hFFFFFFFF; Imm_in[4] = 32'hFFFFFFFF;
    // Testing Alternating input
    A_in[5] = 32'hAAAAAAAA; B_in[5] = 32'h55555555; Imm_in[5] = 32'h55555555;
    // For Shifts
    A_in[6] = 32'h00000002; B_in[6] = 32'h05793001; Imm_in[6] = 32'h00000006;
    // Add to Maximum/Overflow Shift
    A_in[7] = 32'hFFFFFFFF; B_in[7] = 32'h00000001; Imm_in[7] = 32'h00000001; 

    file_handle = $fopen("EX_FSM_out.txt");
    $fdisplay(file_handle, "Outcome from Execute FSM tests\n");

    for (k = 4; k < 37; k = k + 1) begin
        PC = k; 
        IR = IR_in[k];
        printTest(k);
        for (tst = 0; tst < 8; tst = tst + 1) begin
            A = A_in[tst];  B = B_in[tst];  Imm = Imm_in[tst];
            #20 //clock once
            if ((k == 24)|(k == 25)|(k == 26)|(k == 29)|(k == 33)|(k == 34)) $fdisplay(file_handle, "Reg A = %b, Reg B = %d, Imm = %d, Comp result = %d, ALU result = %b", A, B, Imm, COMP_res, ALU_res);   
            else $fdisplay(file_handle, "Reg A = %d, Reg B = %d, Imm = %d, Comp result = %d, ALU result = %d", A, B, Imm, COMP_res, ALU_res);   
        end
        $fdisplay(file_handle, "");       
    end
    #100;                                   
    $fclose(file_handle);                     
    $finish;                                    
end 

initial begin
  $dumpfile("EX_FSM_results.vcd");
  $dumpvars;
 end

initial begin
  clk = 0; 
  forever #10 clk = !clk; 
  $stop;
end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


endmodule