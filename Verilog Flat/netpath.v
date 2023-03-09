module netpath(s_fe, s_dc, s_ex, s_me, s_wb, clk);
    //Internal Wires
    wire [31:0] PC_fe, IR_fe;                   //Fetch
    wire [31:0] PC_dc, IR_dc, A_dc, B_dc, I_dc; //Decode
    wire [31:0] PC_ex, IR_ex, ALU_ex, B_ex;     //Execute
    wire        CP_ex;                          //Execute
    wire [31:0] PC_me, IR_me, RE_me, A_me;      //Memory
    wire [31:0] RD_wb;                          //Writeback
    wire [4: 0] AD_wb;                          //Writeback

    //Control/Stall Signals
    wire v_fe; //r_fe//Fetch
    wire v_dc, r_dc; //Decode
    wire v_ex, r_ex; //Execute
    wire v_me, r_me; //Memory
    wire v_wb, r_wb; //Writeback
    //wire flush;      //Flush after branch 

    //External Controls
    input wire s_fe;
    input wire s_dc;
    input wire s_ex;
    input wire s_me;
    input wire s_wb;
    input wire clk;

    fetch stage_fe(ALU_ex, PC_fe, CP_ex, clk,
        PC_fe, IR_fe,
        v_ex, v_fe, r_dc, /*r_fe*/, s_fe);      //flush dc and ex from branches


    read stage_dc(IR_fe, RD_wb, AD_wb, PC_fe, clk,
        IR_dc, A_dc, B_dc, PC_dc, I_dc,
        v_wb, v_fe, v_dc, r_ex, r_dc, s_dc);
    
    execute stage_ex(IR_dc, I_dc, A_dc, B_dc, PC_dc, ALU_ex, A_me, RD_wb, IR_ex[11:7], IR_me[11:7], AD_wb, clk,
        IR_ex, ALU_ex, CP_ex, PC_ex, B_ex,
        v_dc, v_ex, r_me, r_ex, s_ex);

    memory stage_me(IR_ex, ALU_ex, B_ex, PC_ex, clk,
        IR_me, RE_me, A_me, PC_me,
        v_ex, v_me, r_wb, r_me, s_me);

    write stage_wb(IR_me, RE_me, A_me, PC_me, clk, 
        RD_wb, AD_wb,
        v_me, v_wb, r_wb, s_wb);

endmodule