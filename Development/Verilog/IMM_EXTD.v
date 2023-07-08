module IMM_EXTD (func, imm_in, imm_out);

//Port Discipline
input wire [2:0]  func;
input wire [19:0] imm_in;
output reg [31:0] imm_out;

always @ (*) begin
    case(func)
    3'b000: imm_out = {{20{imm_in[11]}}, imm_in[11:0]};    // sign extend to 32bits from bit11
    3'b001: imm_out = {{19{imm_in[12]}}, imm_in[12:0]};    // sign extend to 32bits from bit12
    3'b010: imm_out = {{12{imm_in[19]}}, imm_in[19:0]};    // sign extend to 32bits from bit19
    3'b101: imm_out = {{19'h00000}, {imm_in[11:0]}};       // unsigned extend to 32bits from bit12
    endcase
end

endmodule