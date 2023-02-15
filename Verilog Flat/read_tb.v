module read_tb ();

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
//Different Immediate Sizes
reg [19:0] imm_20;
reg [11:0] imm_12;

//Outputs from DUT
wire [31:0] IR_out;
wire [31:0] A_out;
wire [31:0] B_out;
wire [31:0] I_out;
wire [31:0] PC_out;
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
read fsm_dut(IR, WB_data, WB_address, PC, clk,
            IR_out, A_out, B_out, PC_out, I_out);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task reset; begin
    IR = 32'hXXXXXXXX;
    PC = 0;
    for (r=0; r<32; r=r+1) begin
        @ (negedge clk);
        PC = PC + 1;
        WB_address = r;
        WB_data    = r;
    end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
initial begin
  file_handle = $fopen("read_out.txt");
  $fdisplay(file_handle, "Outcome from Read FSM tests\n");
  reset;
  b = 1; 

  //Checking all registers work ok
  $fdisplay(file_handle, "Register checks");
  for (a=0; a<32; a=a+2) begin
    rs1 = a; rs2 = b; rd = 5'b00000;
    IR = {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011}; //ADD instruction
    @(negedge clk) $fdisplay(file_handle, "Reg A = %d, Reg B = %d, Imm = %d", A_out, B_out, I_out);
    b = b + 2; 
  end

  test_LUI;
  test_AUIPC;
  test_JAL;
  test_JALR;
  test_BU;
  test_B;
  test_LD;
  test_ST;
  test_ADDI;
  test_XORI; 
  #20 $finish;
end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_LUI; begin
  $fdisplay(file_handle, "\nTesting LUI");
  for (a=0; a<4; a=a+1) begin
    imm_20 = $random;
    IR = {imm_20, 5'b00000, 7'b0110111};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_20), imm_20, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_AUIPC; begin
  $fdisplay(file_handle, "\nTesting AUIPC");
  for (a=0; a<4; a=a+1) begin
    imm_20 = $random;
    IR = {imm_20, 5'b00000, 7'b0010111};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_20), imm_20, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_JALR; begin
  $fdisplay(file_handle, "\nTesting JALR");
  for (a=0; a<4; a=a+1) begin
    imm_12 = $random;
    rs1 = $urandom;
    IR = {imm_12, rs1, 3'b000, 5'b00000, 7'b1100111};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_12), imm_12, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_JAL; begin
  $fdisplay(file_handle, "\nTesting JAL");
  for (a=0; a<4; a=a+1) begin
    imm_20 = $random;
    IR = {imm_20[19], imm_20[9:0], imm_20[10], imm_20[18:11], 5'b00000, 7'b1101111};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_20), imm_20, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_BU; begin
  $fdisplay(file_handle, "\nTesting BGEU, BLTU");
  for (a=0; a<4; a=a+1) begin
    imm_12 = $random;
    IR = {imm_12[11], imm_12[9:4], rs2, rs1, 3'b110, imm_12[3:0], imm_12[10], 7'b1100011};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $unsigned(imm_12), imm_12, $unsigned(I_out), I_out);
  end
  end
endtask

task test_B; begin
  $fdisplay(file_handle, "\nTesting BGE, BLT, BEQ");
  for (a=0; a<4; a=a+1) begin
    imm_12 = $random;
    IR = {imm_12[11], imm_12[9:4], rs2, rs1, 3'b000, imm_12[3:0], imm_12[10], 7'b1100011};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_12), imm_12, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_LD; begin
  $fdisplay(file_handle, "\nTesting Loads");
  for (a=0; a<4; a=a+1) begin
    imm_12 = $random;
    IR = {imm_12[11:0], rs1, 3'b000, rd, 7'b0000011};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_12), imm_12, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_ST; begin
  $fdisplay(file_handle, "\nTesting Stores");
  for (a=0; a<4; a=a+1) begin
    imm_12 = $random;
    IR = {imm_12[11:5], rs2, rs1, 3'b000, imm_12[4:0], 7'b0100011};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_12), imm_12, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_ADDI; begin
  $fdisplay(file_handle, "\nTesting ADDI, SLTI");
  for (a=0; a<4; a=a+1) begin
    imm_12 = $random;
    IR = {imm_12[11:0], rs1, 3'b010, rd, 7'b0010011};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $signed(imm_12), imm_12, $signed(I_out), I_out);
  end
  end
endtask
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
task test_XORI; begin
  $fdisplay(file_handle, "\nTesting SLTUI, XORI, ORI, ANDI, SLLI, SRLI, SRAI");
  for (a=0; a<4; a=a+1) begin
    imm_12 = $random;
    IR = {imm_12[11:0], rs1, 3'b111, rd, 7'b0010011};
    @(negedge clk) $fdisplay(file_handle, "Immediate In = %d, or %b, Immediate Out = %d, Immediate Out = %b", $unsigned(imm_12), imm_12, $unsigned(I_out), I_out);
  end
  end
endtask


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
initial begin
  $dumpfile("read_results.vcd");
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