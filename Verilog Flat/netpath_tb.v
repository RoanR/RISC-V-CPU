module netpath_tb();
reg clk;
reg s_fe;
reg s_dc;
reg s_ex;
reg s_me;
reg s_wb;

integer file_handle; 

//Design under Test
netpath net_dut(s_fe, s_dc, s_ex, s_me, s_wb, clk);

initial begin
    file_handle = $fopen("netpath_out.txt");
    $fdisplay(file_handle, "Outcome from Netpath tests\n");      
end

initial begin 
    #10000 $finish;
end

initial begin
  $dumpfile("netpath_results.vcd");
  $dumpvars;
end

initial begin
  clk = 0; 
  forever #10 clk = !clk; 
  $stop;
end
endmodule