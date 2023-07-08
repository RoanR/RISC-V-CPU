module READ_FSM_tb ();

//Inputs to DUT
reg [31:0] IR;
reg [31:0] WB_data;
reg [31:0] PC;
reg [4:0]  WB_address;
reg        clk;
//Internal Signals
integer file_handle;
integer r, a, b;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;

//Outputs from DUT
wire [31:0] IR_out;
wire [31:0] A_out;
wire [31:0] B_out;
wire [31:0] I_out;
wire [31:0] PC_out;
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
READ_FSM fsm_dut(IR, WB_data, WB_address, PC, clk,
            IR_out, A_out, B_out, PC_out, I_out);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task reset; begin
    IR = 32'hXXXXXXXX;
    PC = 0;
    for (r=0; r<32; r=r+1) begin
        PC = PC + 1;
        WB_address = r;
        WB_data    = r;
        @ (posedge clk);
    end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
initial begin
  file_handle = $fopen("READ_FSM_out.txt");
  $fdisplay(file_handle, "Outcome from Read FSM tests\n");
  reset;
  b = 1; 
  for (a=0; a<32; a=a+2) begin
    rs1 = a; rs2 = b; rd = 5'b00000;
    IR = {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011}; //ADD instruction
    @(posedge clk) $fdisplay(file_handle, "Reg A = %d, Reg B = %d, Imm = %d", A_out, B_out, I_out);
    b = b + 2; 
  end
  #20 $finish;
end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
initial begin
  $dumpfile("READ_FSM_results.vcd");
  $dumpvars;
end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
initial begin
  clk = 0; 
  forever #10 clk = !clk; 
  $stop;
end
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
endmodule