module COMP_tb ();                  

reg  [31:0] operand_A;                    
reg  [31:0] operand_B;                    
reg   [2:0] func;                         
reg         clk;     
wire        result;                       

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

COMP comp_dut(operand_A, operand_B, func, result);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

integer file_handle;                     
integer tst, k;                           

reg [31:0] A_in [0:8];                    
reg [31:0] B_in [0:8];

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

initial begin
    func = 0;
    A_in[0] = 32'h00000001; B_in[0] = 32'h00000001; // Base Case Equal
    A_in[1] = 32'h00000001; B_in[1] = 32'h00000000; // Base Left Bigger
    A_in[2] = 32'h00000000; B_in[2] = 32'h00000001; // Base Right Bigger
    A_in[3] = 32'hFFFFFFFF; B_in[3] = 32'h00000000; // Testing Maximum Left input
    A_in[4] = 32'h00000000; B_in[4] = 32'hFFFFFFFF; // Testing Maximum Right input
    A_in[5] = 32'h800000FF; B_in[5] = 32'h000001FF; // For Signed left input
    A_in[6] = 32'h000001FF; B_in[6] = 32'h800000FF; // For Signed right input
    A_in[7] = 32'h00000000; B_in[7] = 32'h00000000; // Both Zero input
    A_in[8] = 32'hFFFFFFFF; B_in[8] = 32'hFFFFFFFF; // Both Maximum

    file_handle = $fopen("COMP_out.txt");
    $fdisplay(file_handle, "Outcome from COMP tests\n");

  for (k = 0; k < 6; k = k + 1) begin
    if (func == 2) func = 4;
    case (func)
      0: $fdisplay(file_handle, "Testing BEQ function");
      1: $fdisplay(file_handle, "Testing BNE function");
      4: $fdisplay(file_handle, "Testing BLT function");
      5: $fdisplay(file_handle, "Testing BGE  function");
      6: $fdisplay(file_handle, "Testing BLTU function");
      7: $fdisplay(file_handle, "Testing BGEU function");
      default: $fdisplay(file_handle, "Unknown function");
    endcase

    for (tst = 0; tst < 9; tst = tst + 1) begin
      operand_A = A_in[tst];                
      operand_B = B_in[tst];
      #100                                
      $fdisplay(file_handle, "Input 1 = %d, Input 2 = %d, result = %d", operand_A, operand_B, result);   
      end

    $fdisplay(file_handle, "");       
    func = func + 1; 
    end

  #100;                                   
  $fclose(file_handle);                     
  $finish;                                    
end 

initial begin
  $dumpfile("COMP_results.vcd");
  $dumpvars;
 end

initial begin
  clk = 0; 
  forever #20 clk = !clk; 
  $stop;
end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


endmodule