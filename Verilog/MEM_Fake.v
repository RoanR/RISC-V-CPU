module MEM_Fake(enable, read, addr, func, data_in, data_out);

//Port Discipline
input wire clk;
input wire enable;
input wire read;
input wire [2:0]  func;
input wire [31:0] addr;
input wire [31:0] data_in;
output reg [31:0] data_out;    

//internal RAM used for memory initially
reg [7:0] memory [0:65535];

always @ (enable, read, addr, data_in, func) begin
    if (enable) begin
        if (read) begin
            case (func)
                0: data_out = {memory[addr][7], 24'h000000, memory[addr][6:0]};
                1: data_out = {memory[addr+1][7], 16'h0000, memory[addr+1][6:0], memory[addr]};
                2: data_out = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]};
                4: data_out = {24'h000000, memory[addr]};
                5: data_out = {16'h0000, memory[addr+1], memory[addr]};
                default: data_out = 32'hZZZZZZZZ;
            endcase 
        end
        else begin
            case(func)
            0: memory[addr] = data_in[7:0];
            1: begin 
                memory[addr] = data_in[7:0];
                memory[addr+1] = data_in[15:8];
                end
            2: begin
                memory[addr] = data_in[7:0];
                memory[addr+1] = data_in[15:8];
                memory[addr+2] = data_in[23:16];
                memory[addr+3] = data_in[31:24];
            end
            default memory[addr] = 8'hZZ;
            endcase    
        end
    end
end

endmodule
