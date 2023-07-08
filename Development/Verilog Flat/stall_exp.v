module stall_exp(r_in, v_in, stall, d_in, clk,
                r_out, v_out, d_out);

input wire d_in,  r_in,  v_in, stall, clk;
output reg d_out, r_out, v_out;

reg full; 
initial begin full = 0; r_out = 0; v_out = 0; end

always @ (posedge clk) begin
    //v_out control 
    if (full) v_out = 1;
    else      v_out = 0;
    
    //r_out control
    if (!full) r_out = 1;
    else       r_out = r_in; 

    //Stall Condition
    if (stall) begin v_out = 0; r_out = 0; end

    //full control
    if (v_out && r_in) full = 0;
    if (v_in && r_out) full = 1;
end

always @ (posedge clk) begin
    if (r_out) d_out <= d_in;
end

endmodule