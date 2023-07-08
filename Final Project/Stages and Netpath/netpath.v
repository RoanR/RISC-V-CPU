`include "definitions.v"

module netpath(s_fe, s_dc, s_ex, s_me, s_wb, clk);

    /*Notation used for wires 
        XX_fe -> wire out from Fetch
        XX_dc -> wire out from Decode
        XX_ex -> wire out from Execute
        XX_me -> wire out from Memory
        XX_wb -> wire out from Writeback
        
        PC_xx  -> Program Counter, holds PC for the instruction in the stage
        IR_xx  -> Instruction Register, holds the being processed instruction for in the stage
        A_xx   -> The value from rs1
        B_xx   -> The value from rs2
        ALU_xx -> The value calculated by ALU
        CP_xx  -> The output from the Comparison Unit, where 1 is take branch
        RE_xx  -> The value read from memory in load instructions
        RD_xx  -> The the data to writeback to register bank
        
        AX_xx -> Which register data is associated with, for example AM_me, is the register for ALU_me

        v_xx -> Valid signal, means the output produced by that stage is valid and real
        r_xx -> Ready signal, means the stage is ready for input on the next clock edge
        */
        

    
    //Internal Wires
    //Pass Values between Pipeline stages
    wire [31:0] PC_fe, IR_fe;                   
    wire [31:0] PC_dc, IR_dc, A_dc, B_dc, I_dc; 
    wire [31:0] PC_ex, IR_ex, ALU_ex, B_ex;     
    wire        CP_ex;                          
    wire [31:0] PC_me, IR_me, RE_me, ALU_me;      
    wire [31:0] RD_wb;                          
    wire [4: 0] AD_wb;                          

    //Valid and Ready out Signals
    wire v_fe;       
    wire v_dc, r_dc;
    wire v_ex, r_ex; 
    wire v_me, r_me;
    wire v_wb, r_wb;

    //Stall and Clock external controls 
    input wire s_fe; 
    input wire s_dc;
    input wire s_ex;
    input wire s_me;
    input wire s_wb;
    input wire clk;

    //Forwarding Addresses
    wire [4:0] AA_ex; 
    wire [4:0] AM_me; 

    //Fetch Stage
    fetch stage_fe(ALU_ex, PC_fe, CP_ex, clk,
        PC_fe, IR_fe,
        v_ex, v_fe, r_dc, s_fe);      

    //Read Stage
    read stage_dc(IR_fe, RD_wb, AD_wb, PC_fe, clk,
        IR_dc, A_dc, B_dc, PC_dc, I_dc,
        v_wb, v_fe, v_dc, r_ex, r_dc, s_dc);

    //Execute Stage
    execute stage_ex(IR_dc, I_dc, A_dc, B_dc, PC_dc, ALU_ex, ALU_me, RD_wb, AA_ex, AM_me, AD_wb, clk,
        IR_ex, ALU_ex, CP_ex, PC_ex, B_ex, AA_ex,
        v_dc, v_ex, r_me, r_ex, s_ex);

    //Memory Stage
    memory stage_me(IR_ex, ALU_ex, B_ex, PC_ex, clk,
        IR_me, RE_me, ALU_me, PC_me, AM_me,
        v_ex, v_me, r_wb, r_me, s_me);

    //Writeback Stage
    write stage_wb(IR_me, RE_me, ALU_me, PC_me, clk, 
        RD_wb, AD_wb,
        v_me, v_wb, r_wb, s_wb);

endmodule