module netpath();
    //Internal Wires
    wire [31:0] PC_fe, IR_fe;                   //Fetch
    wire [31:0] PC_dc, IR_dc, A_dc, B_dc, I_dc; //Decode
    wire [31:0] PC_ex, IR_ex, ALU_ex, B_ex;     //Execute
    wire        CP_ex;                          //Execute
    wire [31:0] PC_me, IR_me, RE_me, A_me;      //Memory
    wire [31:0] RD_wb;                          //Writeback
    wire [4: 0] AD_wb;                          //Writeback

    fetch stage_fe(ALU_ex, PC_fe, CP_ex, clk,
        PC_fe, IR_fe);

    read stage_dc(IR_fe, RD_wb, AD_wb, PC_fe, clk,
        IR_dc, A_dc, B_dc, PC_dc, I_dc);
    
    execute stage_ex(IR_dc, I_dc, A_dc, B_dc, PC_dc, ALU_ex, IR_ex[11:7], clk,
        IR_ex, ALU_ex, CP_ex, PC_ex, B_ex);

    memory stage_me(IR_ex, ALU_ex, B_ex, PC_ex, clk,
        IR_me, RE_me, A_me, PC_me);

    write stage_wb(IR_me, RE_me, A_me, PC_me, clk, 
        RD_wb, AD_wb);

endmodule