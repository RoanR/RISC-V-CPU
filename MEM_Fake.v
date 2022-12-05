module MEM_Fake(clk, enable, read, addr, data_in, data_out);

//Port Discipline
input wire clk;
input wire enable;
input wire read;
input wire [31:0] addr;
input wire [31:0] data_in;
output reg [31:0] data_out;    

//internal RAM used for memory initially
reg [31:0] memory [0:65535];

always @ (posedge clk) begin
    if (enable) begin
        if (read) data_out = memory[addr[15:0]];
        else memory[addr[15:0]] = data_in;
    end
end

endmodule
