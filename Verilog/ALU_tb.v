module ALU_tb ();                  

reg  [31:0] operand_A;                    
reg  [31:0] operand_B;                    
reg   [2:0] func;                         
reg         control;
reg         clk;     
wire [31:0] result;                       

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

ALU alu_dut(operand_A, operand_B, func, control, result);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

integer file_handle;                     
integer tst, k;                           

reg [31:0] A_in [0:8];                    
reg [31:0] B_in [0:8];

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

initial begin
    control = 0; func = 0;
    A_in[0] = 32'h00000001; B_in[0] = 32'h00000001; // Base Case
    A_in[1] = 32'h00000001; B_in[1] = 32'h00000000; // Testing Single 0 input
    A_in[2] = 32'h00000000; B_in[2] = 32'h00000000; // Testing Double 0 input
    A_in[3] = 32'hFFFFFFFF; B_in[3] = 32'hFFFFFFFF; // Testing Maximum input
    A_in[4] = 32'hAAAAAAAA; B_in[4] = 32'h55555555; // Testing Alternating input
    A_in[5] = 32'h00000002; B_in[5] = 32'h00000001; // For Shifts
    A_in[6] = 32'hFFFFFFFF; B_in[6] = 32'h00000001; // Add to Maximum/Overflow Shift
    A_in[7] = 32'h0000FF00; B_in[7] = 32'h00FF0000;
    A_in[8] = 32'h800000FF; B_in[8] = 32'h00FF0000;

    file_handle = $fopen("ALU_out.txt");
    $fdisplay(file_handle, "Outcome from ALU tests\n");

    //LUI Instrustions
    $fdisplay(file_handle, "Testing SUB function");
    for (tst = 0; tst < 9; tst = tst + 1) begin
      control = 1;
      operand_A = A_in[tst];                
      operand_B = B_in[tst];
      #100                                
      $fdisplay(file_handle, "Input 1 = %32b, Input 2 = %32b, result = %32b", operand_A, operand_B, result);   
    end
    $fdisplay(file_handle, "");
    func = 3'b101;
    $fdisplay(file_handle, "Testing SRA function");
    for (tst = 0; tst < 9; tst = tst + 1) begin
      control = 1;
      operand_A = A_in[tst];                
      operand_B = B_in[tst];
      #100                                
      $fdisplay(file_handle, "Input 1 = %32b, Input 2 = %32b, result = %32b", operand_A, operand_B, result);   
    end
      $fdisplay(file_handle, "");
      control = 0; func = 0;

  for (k = 0; k < 8; k = k + 1)
    begin

    case (func)
      0: $fdisplay(file_handle, "Testing ADD function");
      1: $fdisplay(file_handle, "Testing SLL function");
      2: $fdisplay(file_handle, "Testing SLT function");
      3: $fdisplay(file_handle, "Testing SLTU function");
      4: $fdisplay(file_handle, "Testing XOR function");
      5: $fdisplay(file_handle, "Testing SRL  function");
      6: $fdisplay(file_handle, "Testing OR function");
      7: $fdisplay(file_handle, "Testing AND function");
      default: $fdisplay(file_handle, "Unknown function");
    endcase

    for (tst = 0; tst < 9; tst = tst + 1) begin
      operand_A = A_in[tst];                
      operand_B = B_in[tst];
      #100                                
      $fdisplay(file_handle, "Input 1 = %32b, Input 2 = %32b, result = %32b", operand_A, operand_B, result);   
      end

    $fdisplay(file_handle, "");       
    func = func + 1; 
    end

  #100;                                   
  $fclose(file_handle);                     
  $finish;                                    
end 

initial begin
  $dumpfile("ALU_results.vcd");
  $dumpvars;
 end

initial begin
  clk = 0; 
  forever #20 clk = !clk; 
  $stop;
end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


endmodule