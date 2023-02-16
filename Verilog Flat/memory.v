module memory(IR, A, B, PC, clk,
            IR_out, RD_out, A_out, PC_out);

//Port Discipline
//Input Wires
input wire [31:0] IR;
input wire [31:0] A;
input wire [31:0] B;
input wire [31:0] PC;
input wire        clk;

//Internal Signals
wire       en;
assign en   =  ((IR[6:0] == 7'b0000011 )|( IR[6:0] == 7'b0100011));

//Output Signals 
output reg [31:0] IR_out;
output reg [31:0] RD_out;
output reg [31:0] A_out;
output reg [31:0] PC_out;

//The Memory - making it byte addressable
reg [7:0] mem0 [0:65535];
reg [7:0] mem1 [0:65535];
reg [7:0] mem2 [0:65535];
reg [7:0] mem3 [0:65535];

always @ (posedge clk) begin
    if (!IR[5]) RD_out <= read(en, IR);
    else        RD_out <= 32'hZZZZZZZZ;
end

function [31:0] read(input en, input [31:0] IR); begin
    if (en) begin
        case (IR[14:12])
        0, 4: read = lb(A); //LB
        1, 5: read = lh(A); //LH
        2: read = lw(A); //LW
        default: read = 32'hZZZZZZZZ;
        endcase 
        end 
    end 
endfunction

function [7:0] lb (input [31:0] A); begin 
    case (A[1:0])
    0: lb = mem0[A[31:2]];
    1: lb = mem1[A[31:2]];
    2: lb = mem2[A[31:2]];
    3: lb = mem3[A[31:2]];
    endcase
end
endfunction

function [15:0] lh (input [31:0] A); begin 
    case (A[1:0])
    0: lh = {mem1[A[31:2]],   mem0[A[31:2]]};
    1: lh = {mem2[A[31:2]],   mem1[A[31:2]]};
    2: lh = {mem3[A[31:2]],   mem2[A[31:2]]};
    3: lh = {mem0[A[31:2]+1], mem3[A[31:2]]};
    endcase
end
endfunction

function [31:0] lw (input [31:0] A); begin 
    case (A[1:0])
    0: lw = {mem3[A[31:2]],   mem2[A[31:2]],   mem1[A[31:2]],   mem0[A[31:2]]};
    1: lw = {mem0[A[31:2]+1], mem3[A[31:2]],   mem2[A[31:2]],   mem1[A[31:2]]};
    2: lw = {mem1[A[31:2]+1], mem0[A[31:2]+1], mem3[A[31:2]],   mem2[A[31:2]]};
    3: lw = {mem2[A[31:2]+1], mem1[A[31:2]+1], mem0[A[31:2]+1], mem3[A[31:2]]};
    endcase
end
endfunction

always @ (posedge clk) begin
    if (en & (IR[5])) begin
        case(IR[14:12])
        0: sb;
        1: sh;
        2: sw;
        endcase
    end
end 

task sb; begin
    case(A[1:0])
    0: mem0[A[31:2]] <= B[7:0];
    1: mem1[A[31:2]] <= B[7:0];
    2: mem2[A[31:2]] <= B[7:0];
    3: mem3[A[31:2]] <= B[7:0];
    endcase
end
endtask

task sh; begin
    case (A[1:0])
    0: begin mem0[A[31:2]] <= B[7:0]; mem1[A[31:2]]     <= B[15:8]; end
    1: begin mem1[A[31:2]] <= B[7:0]; mem2[A[31:2]]     <= B[15:8]; end
    2: begin mem2[A[31:2]] <= B[7:0]; mem3[A[31:2]]     <= B[15:8]; end
    3: begin mem3[A[31:2]] <= B[7:0]; mem0[A[31:2] + 1] <= B[15:8]; end
    endcase
end 
endtask

task sw; begin
    case (A[1:0])
    0: begin mem0[A[31:2]] <= B[7:0]; mem1[A[31:2]] <= B[15:8];   mem2[A[31:2]] <= B[23:16];   mem3[A[31:2]]   <= B[31:24]; end
    1: begin mem1[A[31:2]] <= B[7:0]; mem2[A[31:2]] <= B[15:8];   mem3[A[31:2]] <= B[23:16];   mem0[A[31:2]+1] <= B[31:24]; end
    2: begin mem2[A[31:2]] <= B[7:0]; mem3[A[31:2]] <= B[15:8];   mem0[A[31:2]+1] <= B[23:16]; mem1[A[31:2]+1] <= B[31:24]; end
    3: begin mem3[A[31:2]] <= B[7:0]; mem0[A[31:2]+1] <= B[15:8]; mem1[A[31:2]+1] <= B[23:16]; mem2[A[31:2]+1] <= B[31:24]; end
    endcase
end
endtask

always @ (posedge clk) begin
    IR_out <= IR;
    A_out  <= A;
    PC_out <= PC;
end

endmodule
