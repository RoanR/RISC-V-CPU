//Instruction Opcode Defintions
`define LUI     7'b0110111 //Load Immediate
`define AUIPC   7'b0010111 //Add immediate to PC
`define JAL     7'b1101111 //Jump and Link 
`define JALR    7'b1100111 //Jump and Link register
`define BRANCH  7'b1100011 //Branch operation
`define LOAD    7'b0000011 //Load operation
`define STORE   7'b0100011 //Store operation
`define IM_ALU  7'b0010011 //Immediate ALU operation
`define REG_ALU 7'b0110011 //Register ALU operation

//Branch function Definitions
`define BEQ     3'b000 //if equal
`define BNE     3'b001 //if not equal
`define BLT     3'b100 //if less than
`define BGE     3'b101 //if greater than or equal 
`define BLTU    3'b110 //BLT unsigned
`define BGEU    3'b111 //BGE unsigned 

//Load function Definitions
`define LB      3'b000 //Load Byte
`define LH      3'b001 //Load Half-Word
`define LW      3'b010 //Load Word
`define LBU     3'b100 //Load Byte Unsigned
`define LHU     3'b101 //Load Half-Word Unsigned

//Store function Defintions
`define SB      3'b000 //Store Byte
`define SH      3'b001 //Store Half-Word
`define SW      3'b010 //Store Word

//ALU Defintions
`define ADD     3'b000 //Add 
`define SLT     3'b010 //Set less than
`define SLTU    3'b011 //Set less than unsigned
`define XOR     3'b100 //bitwise XOR
`define OR      3'b110 //bitwise OR
`define AND     3'b111 //bitwise AND
`define SLL     3'b001 //Shift Left Logical
`define SR      3'b101 //Shift Right 