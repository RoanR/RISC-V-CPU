module stall_exp_tb();
integer file_handle; 
wire r1_out, r2_out, r3_out;
wire v1_out, v2_out, v3_out;
wire d1_out, d2_out, d3_out;
reg  s1,     s2,     s3;
reg  data_in; 
reg  clk;

stall_exp stage_one(r2_out, 1'b1, s1, data_in, clk,
                r1_out, v1_out, d1_out);

stall_exp stage_two(r3_out, v1_out, s2, d1_out, clk,
                r2_out, v2_out, d2_out);

stall_exp stage_three(1'b1, v2_out, s3, d2_out, clk,
                r3_out, v3_out, d3_out);

initial begin
    file_handle = $fopen("stall_out.txt");
    $fdisplay(file_handle, "Outcome from Stall pipeline FSM tests\n");
    #200 s1 = 1; #220 s1 = 0;
    #500 s2 = 1; #540 s2 = 0;
    #800 s3 = 1; #820 s3 = 0;
end

initial #5000 $finish;

initial begin data_in = 0; s1 = 0; s2 = 0; s3 = 0; end 

always @ (posedge clk) data_in <= ~data_in;


initial begin
  $dumpfile("stall_results.vcd");
  $dumpvars;
 end

initial begin
  clk = 0; 
  forever #10 clk = !clk; 
  $stop;
end

endmodule
