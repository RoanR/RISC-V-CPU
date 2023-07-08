module execute_tb ();                  

//Input registers
reg [31:0] A;                    
reg [31:0] B;                    
reg [31:0] IR;
reg [31:0] Imm;
reg [31:0] PC;
reg [31:0] FA;
reg [31:0] FM;
reg [4 :0] AA;
reg [4 :0] AM;
reg        clk; 
reg        v_in;
reg        r_in;
reg        stall;    

//Output registers                    
wire  [31:0] IR_res;
wire  [31:0] ALU_res;
wire  COMP_res;
wire  [31:0] PC_res;
wire  [31:0] B_res; 
wire         v_out;
wire         r_out;

//Internal registers
integer file_handle;                     
integer a, b;
reg [2:0] func; 


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

execute fsm_dut(IR, Imm, A, B, PC, FA, FM, AA, AM, clk,
            IR_res, ALU_res, COMP_res, PC_res, B_res,
            v_in, v_out, r_in, r_out, stall);


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

task test_COMP; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing Comparison Unit");
          
  for (a=0; a<8; a=a+1) begin
    func = a; IR = {17'bxxxxxxxxxxxxxxxxx, func, 5'bxxxxx, 7'b1100011};
    //Random tests
    for (b=0; b<4; b=b+1) begin
        A = $random; B = $random; Imm = $random;
        @(negedge clk)
        if ((a == 7) | (a == 6)) $fdisplay(file_handle, "funct = %d, A =  %d, B =  %d, Out = %d", a, $unsigned(A), $unsigned(B), COMP_res);
        else $fdisplay(file_handle, "funct = %d, A = %d, B = %d, Out = %d", a, $signed(A), $signed(B), COMP_res);
    end
    A = $random; B = A;
    @(negedge clk)
    if ((a == 7) | (a == 6)) $fdisplay(file_handle, "funct = %d, A =  %d, B =  %d, Out = %d", a, $unsigned(A), $unsigned(B), COMP_res);
    else $fdisplay(file_handle, "funct = %d, A = %d, B = %d, Out = %d", a, $signed(A), $signed(B), COMP_res);
  end
  end
endtask

task test_ADD; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing ADD operation");
  IR = 32'bxxxxxxxxxxxxxxxxx000xxxxx0010011; //ADDI
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    Imm = $random; A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "ADDI,   A + Imm = Out, %d + %d = %d", $signed(A),$signed(Imm),$signed(ALU_res));
  end
  IR = 32'bxxxxxxxxxxxxxxxxx111xxxxx1100011; //Branch
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    Imm = $random; A = $random; B = $random; PC = $random;
    @(negedge clk);
    $fdisplay(file_handle, "Branc, PC + Imm = Out, %d + %d = %d", $signed(A),$signed(Imm),$signed(ALU_res)); 
  end
  IR = 32'bxxxxxxxxxxxxxxxxx111xxxxx0000011; //Loads
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    Imm = $random; A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "Load,   A + Imm = Out, %d + %d = %d", $signed(A),$signed(Imm),$signed(ALU_res));
  end
  IR = 32'bxxxxxxxxxxxxxxxxx111xxxxx0100011; //Stores
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    Imm = $random; A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "Store,  A + Imm = Out, %d + %d = %d", $signed(A),$signed(Imm),$signed(ALU_res));
  end
  IR = 32'bx1xxxxxxxxxxxxxxx000xxxxx0110011; //SUB
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    Imm = $random; A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "SUB,    A - B   = Out, %d - %d = %d", $signed(A),$signed(B),$signed(ALU_res));
  end
end
endtask

task test_Shift_Left; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing Shift Left Logical operation");
  IR = 32'bxxxxxxxxxxxxxxxxx001xxxxx0110011; //SLL
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; B = {$random}%10;
    @(negedge clk);
    $fdisplay(file_handle, "SLL,  A << B   = Out, %b << %d = %b", A, B, ALU_res);
  end

  IR = 32'bxxxxxxxxxxxxxxxxx001xxxxx0010011; //SLL
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = {$random}%10;
    @(negedge clk);
    $fdisplay(file_handle, "SLLI, A << Imm = Out, %b << %d = %b", A, Imm, ALU_res);
  end
end
endtask

task test_Set_Less; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing Set Less Than operation");
  IR = 32'bxxxxxxxxxxxxxxxxx010xxxxx0110011; //SLT
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "SLT,   A < B   = Out, %d < %d = %d", $signed(A), $signed(B), ALU_res);
  end

  IR = 32'bxxxxxxxxxxxxxxxxx010xxxxx0010011; //SLTI
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = $random;
    @(negedge clk);
    $fdisplay(file_handle, "SLTI,  A < Imm = Out, %d < %d = %d", $signed(A), $signed(Imm), ALU_res);
  end
end
endtask

task test_Set_Less_Un; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing Set Less Than Unsigned operation");
  IR = 32'bxxxxxxxxxxxxxxxxx011xxxxx0110011; //SLTU
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "SLTU,   A < B   = Out, %d < %d = %d", $unsigned(A), $unsigned(B), ALU_res);
  end

  IR = 32'bxxxxxxxxxxxxxxxxx011xxxxx0010011; //SLTIU
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = $random;
    @(negedge clk);
    $fdisplay(file_handle, "SLTIU,  A < Imm = Out, %d < %d = %d", $unsigned(A), $unsigned(Imm), ALU_res);
  end
end
endtask

task test_XOR; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing XOR operation");
  IR = 32'bxxxxxxxxxxxxxxxxx100xxxxx0110011; //XOR
  for (a=0; a<2; a=a+1) begin
    @(posedge clk);
    A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "%b", A);
    $fdisplay(file_handle, "%b XOR", B);
    $fdisplay(file_handle, "--------------------------------");
    $fdisplay(file_handle, "%b\n", ALU_res);
  end

  IR = 32'bxxxxxxxxxxxxxxxxx100xxxxx0010011; //XOTI
  for (a=0; a<2; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = $random;
    @(negedge clk);
        $fdisplay(file_handle, "%b", A);
    $fdisplay(file_handle, "%b XORI", Imm);
    $fdisplay(file_handle, "--------------------------------");
    $fdisplay(file_handle, "%b\n", ALU_res);
  end
end
endtask

task test_Shift_Right_Art; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing Shift Right Arithmetic operation");
  IR = 32'bx1xxxxxxxxxxxxxxx101xxxxx0110011; //SRA
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; B = {$random}%10;
    @(negedge clk);
    $fdisplay(file_handle, "SRA,  A << B   = Out, %b << %d = %b", A, B, ALU_res);
  end

  IR = 32'bx1xxxxxxxxxxxxxxx101xxxxx0010011; //SRAI
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = {$random}%10;
    @(negedge clk);
    $fdisplay(file_handle, "SRAI, A << Imm = Out, %b << %d = %b", A, Imm, ALU_res);
  end
end
endtask

task test_Shift_Right_Log; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing Shift Right Logical operation");
  IR = 32'bx0xxxxxxxxxxxxxxx101xxxxx0110011; //SRA
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; B = {$random}%10;
    @(negedge clk);
    $fdisplay(file_handle, "SRL,  A << B   = Out, %b << %d = %b", A, B, ALU_res);
  end

  IR = 32'bx0xxxxxxxxxxxxxxx101xxxxx0010011; //SRAI
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = {$random}%10;
    @(negedge clk);
    $fdisplay(file_handle, "SRLI, A << Imm = Out, %b << %d = %b", A, Imm, ALU_res);
  end
end
endtask

task test_OR; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing OR operation");
  IR = 32'bxxxxxxxxxxxxxxxxx110xxxxx0110011; //OR
  for (a=0; a<2; a=a+1) begin
    @(posedge clk);
    A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "%b", A);
    $fdisplay(file_handle, "%b OR", B);
    $fdisplay(file_handle, "--------------------------------");
    $fdisplay(file_handle, "%b\n", ALU_res);
  end

  IR = 32'bxxxxxxxxxxxxxxxxx110xxxxx0010011; //ORI
  for (a=0; a<2; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = $random;
    @(negedge clk);
    $fdisplay(file_handle, "%b", A);
    $fdisplay(file_handle, "%b ORI", Imm);
    $fdisplay(file_handle, "--------------------------------");
    $fdisplay(file_handle, "%b\n", ALU_res);
  end
end
endtask

task test_AND; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing AND operation");
  IR = 32'bxxxxxxxxxxxxxxxxx111xxxxx0110011; //AND
  for (a=0; a<2; a=a+1) begin
    @(posedge clk);
    A = $random; B = $random;
    @(negedge clk);
    $fdisplay(file_handle, "%b", A);
    $fdisplay(file_handle, "%b AND", B);
    $fdisplay(file_handle, "--------------------------------");
    $fdisplay(file_handle, "%b\n", ALU_res);
  end

  IR = 32'bxxxxxxxxxxxxxxxxx111xxxxx0010011; //ANDI
  for (a=0; a<2; a=a+1) begin
    @(posedge clk);
    A = $random; Imm = $random;
    @(negedge clk);
    $fdisplay(file_handle, "%b", A);
    $fdisplay(file_handle, "%b ANDI", Imm);
    $fdisplay(file_handle, "--------------------------------");
    $fdisplay(file_handle, "%b\n", ALU_res);
  end
end
endtask

task test_FA; begin
  $fdisplay(file_handle, "\n/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/");
  $fdisplay(file_handle, "Testing Forward from EX");

  IR = 32'bxxxxxxxxxxxx00001000xxxxx0110011; //ADD
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; B = $random; FA = $random; AA = 5'b00001;
    @(negedge clk);
    $fdisplay(file_handle, "ADD, A (from FA) + B = Out, (incorrect A: %d) %d + %d = %d", $signed(A), $signed(FA), $signed(B), $signed(ALU_res)); 
  end

  IR = 32'bxxxxxxx0000100000000xxxxx0110011; //ADD
  for (a=0; a<5; a=a+1) begin
    @(posedge clk);
    A = $random; B = $random; FA = $random; AA = 5'b00001;
    @(negedge clk);
    $fdisplay(file_handle, "ADD, A + B (from FA) = Out, (incorrect B: %d) %d + %d = %d", $signed(B), $signed(A), $signed(FA), $signed(ALU_res)); 
  end
end
endtask

initial begin
    file_handle = $fopen("execute_out.txt");
    $fdisplay(file_handle, "Outcome from Execute FSM tests\n");
    AA = 5'bZZZZZ;
    FA = 32'hZZZZZZZZ;
    test_COMP;
    test_ADD;
    test_Shift_Left;
    test_Set_Less;
    test_Set_Less_Un;
    test_XOR;
    test_Shift_Right_Art;
    test_Shift_Right_Log;
    test_OR;
    test_AND;
    test_FA;
    #100 $finish;
end

initial begin
  $dumpfile("execute_results.vcd");
  $dumpvars;
 end

initial begin
  clk = 0; 
  forever #10 clk = !clk; 
  $stop;
end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


endmodule