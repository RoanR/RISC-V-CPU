module IMM_EXTD_tb ();                  
                   
reg           [19:0] operand_A;                    
reg                  ext_op;   
reg                  unsigned_op;                        
reg                  clk;     
wire signed   [31:0] result;
wire unsigned [31:0] unsigned_result;  
assign unsigned_result = result;

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

IMM_EXTD imm_extd_dut(ext_op, unsigned_op, operand_A, result);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

integer file_handle;                     
integer tst, k;                           

reg [19:0] A_in [0:6];                    

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

initial begin
    A_in[0] = 20'h00001;  // Base Case 1
    A_in[1] = 32'h00000;  // Base Case 0
    A_in[2] = 32'hFFFFF;  // Maximum value
    A_in[3] = 32'h7F000;  // Only latter Section
    A_in[4] = 32'h007FF;  // Only first Section
    A_in[5] = 32'h8000F;  // Negative number 
    A_in[6] = 32'h7FFFF;  // Maximum Positive number 

    file_handle = $fopen("IMM_EXTD_out.txt");
    $fdisplay(file_handle, "Outcome from IMM EXTD tests\n");

  for (k = 0; k < 3; k = k + 1) begin
    case (k)
      0: ext_op = 1;
      1: begin
        ext_op = 0; unsigned_op = 0;
      end
      2: begin
        ext_op = 0; unsigned_op = 1; 
      end
    endcase
    case ({ext_op, unsigned_op})
      2'b1x: $fdisplay(file_handle, "Testing sign extend to 32_bits from 19_bit");
      2'b00: $fdisplay(file_handle, "Testing sign extend to 32_bits from 11_bit");
      2'b01: $fdisplay(file_handle, "Testing non-sign extend to 32_bits from 11_bit");
      default: $fdisplay(file_handle, "Unknown Operation");
    endcase

    for (tst = 0; tst < 7; tst = tst + 1) begin
      operand_A = A_in[tst];                
      #100                                
      $fdisplay(file_handle, "Input 1 = %b, result signed = %d, result unsigned = %d", operand_A, result, unsigned_result);   
      end

    $fdisplay(file_handle, "");       
    end

  #100;                                   
  $fclose(file_handle);                     
  $finish;                                    
end 

initial begin
  $dumpfile("IMM_EXTD_results.vcd");
  $dumpvars;
 end

initial begin
  clk = 0; 
  forever #20 clk = !clk; 
  $stop;
end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


endmodule