module fetch_tb();

//Input Registers
reg [31:0] PC_alu;
reg [31:0] PC_prev;
reg        COMP_alu;
reg        clk;

//Internal Signals
integer file_handle; 

//Output Wires
wire [31:0] PC_out;
wire [31:0] IR_out;

/*----------------------------------------------------*/
//Design under Test
fetch fetch_dut(PC_alu, PC_prev, COMP_alu, clk,
            PC_out, IR_out);
/*----------------------------------------------------*/
initial begin
    file_handle = $fopen("fetch_out.txt");
    $fdisplay(file_handle, "Outcome from fetch FSM tests\n");      
end
/*----------------------------------------------------*/
always @ (posedge clk) begin 
    $fdisplay(file_handle, "PC: %d -> IR: %b", PC_out, IR_out); 
end
/*----------------------------------------------------*/
initial begin
  PC_prev = -1; PC_alu = 0; COMP_alu = 0;
end

always @ (PC_out) PC_prev = PC_out;

initial begin
  repeat (5) @(posedge clk);
  COMP_alu <= 1;
  @(posedge clk) COMP_alu <= 0;
end
/*----------------------------------------------------*/
initial begin
  $dumpfile("fetch_results.vcd");
  $dumpvars;
end
/*----------------------------------------------------*/
initial begin
  clk = 0; 
  forever #10 clk = !clk; 
  $stop;
end

initial begin
  repeat (20) @(posedge clk);
  $finish;
end
endmodule