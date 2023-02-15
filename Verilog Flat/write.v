module write(IR, RD, A, PC, clk, 
            data, address);

//Port Discipline
//Input Wires
input wire [31:0] IR;
input wire [31:0] RD;
input wire [31:0] PC;
input wire [31:0] A;
input wire        clk;

//Output Registers
output reg [31:0] data;
output reg [4:0]  address;

always @ (posedge clk) begin
    if (IR[6:0] == 7'b0100011)      address <= 4'b0000; //Store
    else if (IR[6:0] == 7'b1100011) address <= 4'b0000; //Branch
    else address <= IR[10:7];
end

always @ (posedge clk) begin
    case(IR[6:0])
    7'b1101111: data <= PC + 1; //JAL
    7'b1100111: data <= PC + 1; //JALR
    7'b0000011: data <= RD;     //Load
    default:    data <= A;
    endcase
end
endmodule