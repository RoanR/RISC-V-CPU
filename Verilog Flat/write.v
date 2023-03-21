module write(IR, RD, A, PC, clk, 
            data, address,
            v_in, v_out, r_out, stall);

//Port Discipline
//Input Wires
input wire [31:0] IR;
input wire [31:0] RD;
input wire [31:0] PC;
input wire [31:0] A;
input wire        clk;

//Stall Controls
input wire  v_in;
input wire  stall;
output reg  v_out;
output reg  r_out;

//Output Registers
output reg [31:0] data;
output reg [4:0]  address;

//Driver for address
always @ (posedge clk) begin
    if (r_out & v_in) begin
        if      (IR[6:0] == 7'b0100011) address <= 4'b0000; //Store
        else if (IR[6:0] == 7'b1100011) address <= 4'b0000; //Branch
        else                            address <= IR[11:7];
    end
end

function [31:0] read(input [31:0] IR, RD); begin
    if ((IR[14:12] == 0)|(IR[14:12] == 1)|(IR[14:12] == 2)) read = $signed(RD);
    else if ((IR[14:12] == 4)|(IR[14:12] == 5))             read = $unsigned(RD);
    end 
endfunction

//Driver for Data
always @ (posedge clk) begin
    if (r_out & v_in) begin
        case(IR[6:0])
        7'b1101111: data <= PC + 4;        //JAL
        7'b1100111: data <= PC + 4;        //JALR
        7'b0000011: data <= read(IR, RD);  //Load
        default:    data <= A;
        endcase
    end
end


//Stall controls 
initial begin 
    v_out = 0;
    r_out = 1;
end

//Driver for control signals
always @ (posedge clk) begin
    if (stall) begin v_out <= 0; r_out <= 0; end
    else begin v_out <= v_in;    r_out <= 1; end
end

endmodule