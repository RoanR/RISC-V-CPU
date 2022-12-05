module COMP(comp_in_A, comp_in_B, func, comp_out);

//Port Discipline
input signed  [31:0] comp_in_A; // rs1
input signed  [31:0] comp_in_B; // rs2 or Imm
input wire    [2:0]  func;	    // Branch Type
output reg           comp_out;  // branch taken (1) or branch not taken (0)

//Internal Unsigned wires
wire unsigned [31:0] in_A_unsigned;
assign in_A_unsigned = comp_in_A;
wire unsigned [31:0] in_B_unsigned;
assign in_B_unsigned = comp_in_B;

always @ (*) begin
    case (func)
    0: comp_out = (comp_in_A == comp_in_B);         // BEQ
    1: comp_out = (comp_in_A != comp_in_B);         // BNE
    4: comp_out = (comp_in_A < comp_in_B);          // BLT
    5: comp_out = (comp_in_A >= comp_in_B);         // BGE
    6: comp_out = (in_A_unsigned < in_B_unsigned);  // BLTU
    7: comp_out = (in_A_unsigned >= in_B_unsigned); // BGEU
    default: comp_out = 0;
    endcase
end

endmodule