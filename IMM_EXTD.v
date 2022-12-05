module IMM_EXTD (ext_op, unsigned_op, imm_in, imm_out);

//Port Discipline
input wire        ext_op;
input wire        unsigned_op;
input wire [19:0] imm_in;
output reg [31:0] imm_out;

always @ (*) begin
 if(ext_op == 1) imm_out = {{12{imm_in[19]}}, imm_in[19:0]};    // sign extend to 32bits from bit19
 else begin
  if (unsigned_op) imm_out = {{20'h00000}, {imm_in[11:0]}};     // extend to 32bits from bit11
  else imm_out = {{20{imm_in[11]}}, imm_in[11:0]};              // sign extend to 32bits from bit11
 end   
end

endmodule