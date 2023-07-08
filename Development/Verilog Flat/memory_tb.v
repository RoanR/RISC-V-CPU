module memory_tb();

//Input Registers
reg [31:0] IR;
reg [31:0] PC;
reg [31:0] A;
reg [31:0] B;
reg        clk;

//Internal Signals
integer file_handle; 
integer i, k;

//Output Wires
wire [31:0] IR_out;
wire [31:0] RD_out;
wire [31:0] PC_out;
wire [31:0] A_out;
/*----------------------------------------------------*/
//Design under Test
memory mem_dut(IR, A, B, PC, clk, IR_out, RD_out, A_out, PC_out);
/*----------------------------------------------------*/
initial begin
    file_handle = $fopen("memory_out.txt");
    $fdisplay(file_handle, "Outcome from Memory FSM tests\n");      
end
/*----------------------------------------------------*/ 

    //IR_in[10] = 32'bxxxxxxxxxxxxxxxxx000xxxxx0000011; //LB
    //IR_in[11] = 32'bxxxxxxxxxxxxxxxxx001xxxxx0000011; //LH
    //IR_in[12] = 32'bxxxxxxxxxxxxxxxxx010xxxxx0000011; //LW
    //IR_in[13] = 32'bxxxxxxxxxxxxxxxxx100xxxxx0000011; //LBU
    //IR_in[14] = 32'bxxxxxxxxxxxxxxxxx101xxxxx0000011; //LHU
    //IR_in[15] = 32'bxxxxxxxxxxxxxxxxx000xxxxx0100011; //SB
    //IR_in[16] = 32'bxxxxxxxxxxxxxxxxx001xxxxx0100011; //SH
    //IR_in[17] = 32'bxxxxxxxxxxxxxxxxx010xxxxx0100011; //SW
initial begin
    PC = 0;
    //Checking Read Word after Write Word
    $fdisplay(file_handle, "\nChecking Read Word + Write Word to Random Addresses");
    for (i = 0; i < 10; i = i + 1) begin
        PC = PC + 1;
        IR = 32'bxxxxxxxxxxxxxxxxx010xxxxx0100011;
        A = {$random} %65536; //Address
        B = {$random};        //Data In
        $fdisplay(file_handle, "Writing To:    %d -> With: %d", A, B);
        #20 PC = PC + 1; IR = 32'bxxxxxxxxxxxxxxxxx010xxxxx0000011;
        #20 $fdisplay(file_handle, "Reading From:  %d -> Data: %d", A, RD_out);   
    end
    
    $fdisplay(file_handle, "\nChecking Read HalfWord + Write HalfWord to Random Addresses");
    @(posedge clk)
    for (i = 0; i < 10; i = i + 1) begin        
        A = {$random} %65536; B[15:0] = {$random};        
        @(posedge clk) PC = PC + 1; IR = 32'bxxxxxxxxxxxxxxxxx001xxxxx0100011;
        @(negedge clk) $fdisplay(file_handle, "Writing To:    %d -> With: %d", A, $signed(B[15:0]));
        @(posedge clk) PC = PC + 1; IR = 32'bxxxxxxxxxxxxxxxxx001xxxxx0000011;
        @(negedge clk) $fdisplay(file_handle, "Reading From:  %d -> Data: %d" ,A, $signed(RD_out)); 
        @(posedge clk) PC = PC + 1; IR = 32'bxxxxxxxxxxxxxxxxx101xxxxx0000011;
        @(negedge clk) $fdisplay(file_handle, "Unsigned From: %d -> Data: %d", A, $unsigned(RD_out)); 
    end

    $fdisplay(file_handle, "\nChecking Read Byte + Write Byte to Random Addresses");
    for (i = 0; i < 10; i = i + 1) begin
        A = {$random} %65536; B[7:0] = {$random};
        @(posedge clk) PC = PC + 1; IR = 32'bxxxxxxxxxxxxxxxxx000xxxxx0100011;
        @(negedge clk) $fdisplay(file_handle, "Writing To:    %d -> With: %d", A, $signed(B[7:0]));
        @(posedge clk) PC = PC + 1; IR = 32'bxxxxxxxxxxxxxxxxx000xxxxx0000011;
        @(negedge clk) $fdisplay(file_handle, "Reading From:  %d -> Data: %d" , A, $signed(RD_out));
        @(posedge clk)PC = PC + 1; IR = 32'bxxxxxxxxxxxxxxxxx100xxxxx0000011;
        @(negedge clk) $fdisplay(file_handle, "Unsigned From: %d -> Data: %d", A, $unsigned(RD_out)); 
    end
    $finish;
end
/*----------------------------------------------------*/
initial begin
  $dumpfile("memory_results.vcd");
  $dumpvars;
end
/*----------------------------------------------------*/
initial begin
  clk = 0; 
  forever #10 clk = !clk; 
  $stop;
end

endmodule