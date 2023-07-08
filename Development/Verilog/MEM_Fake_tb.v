module MEM_Fake_tb ();
reg  [31:0] data_in;                    
reg  [31:0] addr;                    
reg         enable;                         
reg         read;
reg         clk;     
wire [31:0] data_out;                       

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

MEM_Fake mem_fake_dut(clk, enable, read, addr, data_in, data_out);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

integer file_handle; 
integer i, k;
initial begin
    file_handle = $fopen("MEM_Fake_out.txt");
    $fdisplay(file_handle, "Outcome from Memory tests\n");      
end                                                      

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

always @ (data_out) begin
    $fdisplay(file_handle, "Address: %16d -> Data Out: %d" ,addr[15:0], data_out);   
end

initial begin
    #100
    //Populate Fake memory with data
    //Data is equal to address of location
    enable = 1;
    for (i = 0; i < 65536; i = i +1) begin
        @ (negedge clk);
        read = 0;
        addr = i;
        data_in = i;
    end

    //Series of Random data reads
    #100 $fdisplay(file_handle, "Random Memory Access tests");      
    for (i = 0; i < 20; i = i + 1) begin
        @ (negedge clk);
        read = 1;
        k = {$random} %65536;
        addr = k;
    end

    //Checking Memory Changes after Write
    #100 $fdisplay(file_handle, "\nChecking Memory Changes after Write");
    for (i = 0; i < 20; i = i + 1) begin
        @ (negedge clk);
        enable = 1; read = 0;
        k = {$random} %65536;
        addr = k; data_in = {$random};
        $fdisplay(file_handle, "Overwriting %16d -> " ,addr[15:0], data_in);   
        @ (negedge clk);
        enable = 1;
        read = 1;
    end

    //Attempting to write when enable off
    #100 $fdisplay(file_handle, "\nAttempting to write when enable off");
    for (i = 0; i < 20; i = i + 1) begin
        @ (negedge clk);
        enable = 0; read = 0;
        k = {$random} %65536;
        addr = k; data_in = 0;
        $fwrite(file_handle, "Attempting to Overwrite at ");   
        @ (negedge clk);
        enable = 1;
        read = 1;
    end

    //Attempting to read when enable off
    #100 $fdisplay(file_handle, "\nAttempting to read when enable off");
    for (i = 0; i < 20; i = i + 1) begin
        @ (negedge clk);
        enable = 0; read = 1;
        k = {$random} %65536;
        addr = k;
        @(negedge clk)
        $fdisplay(file_handle, "Attempting to read at %16d -> Data Out: %d" ,addr[15:0], data_out);  
    end

    #100;                                   
    $fclose(file_handle);  
    $finish;

end

initial begin
    clk = 0;
    forever #20 clk = !clk;
    $stop;
end

initial begin
  $dumpfile("MEM_Fake_results.vcd");
  $dumpvars;
 end
endmodule            
