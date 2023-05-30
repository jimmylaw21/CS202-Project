`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 08:43:10
// Design Name: 
// Module Name: controller32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module controller32(
    input[5:0] Opcode, // instruction[31:26], opcode
    input[5:0] Function_opcode, // instructions[5:0], funct
    output Jr , // 1 indicates the instruction is "jr", otherwise it's not "jr" output Jmp; 
    output Jal, // 1 indicate the instruction is "jal", otherwise it's not
    output Jmp, // 1 indicate the instruction is "j", otherwise it's not
    output Branch, // 1 indicate the instruction is "beq" , otherwise it's not
    output nBranch, // 1 indicate the instruction is "bne", otherwise it's not
    output RegDST, // 1 indicate destination register is "rd"(R),otherwise it's "rt"(I)
    output RegWrite, // 1 indicate write register(R,I(lw)), otherwise it's not
    output MemWrite, // 1 indicate write data memory, otherwise it's not
    output ALUSrc, // 1 indicate the 2nd data is immidiate (except "beq","bne")
    output Sftmd, // 1 indicate the instruction is shift instruction
    output I_format, // I_format is 1 bit width port
    /* 1 indicate the instruction is I-type but isn't “beq","bne","LW" or "SW" */
    output[1:0] ALUOp, // ALUOp is multi bit width port
    /* if the instruction is R-type or I_format, ALUOp is 2'b10;
    if the instruction is“beq” or “bne“, ALUOp is 2'b01；
    if the instruction is“lw” or “sw“, ALUOp is 2'b00；*/

    input[21:0] Alu_resultHigh,//alu结果的高22位，用于判断是否需要进行读IO或写IO
    output MemorIOtoReg, //1 indicates that read date from memory or I/O to write to the register
    output MemRead, // 1 indicates that reading from the memory to get data
    output IORead, // 1 indicates I/O read
    output IOWrite // 1 indicates I/O write

    );
    wire R_format;        // 为1表示是R-类型指令
    wire Lw;               // 为1表示是lw指令
    wire Sw;               // 为1表示是sw指令
    assign Lw = (Opcode == `OP_LW)? 1'b1:1'b0;

    assign Sw = (Opcode == `OP_SW)?1'b1:1'b0;

    assign Jr =((Opcode == `OP_RTYPE)&&(Function_opcode == `FUNC_JR)) ? 1'b1 : 1'b0;

    assign Jal = (Opcode == `OP_JAL) ? 1'b1 : 1'b0;

    assign Jmp = (Opcode == `OP_J) ? 1'b1 : 1'b0;

    assign Branch = (Opcode == `OP_BEQ) ? 1'b1 : 1'b0;

    assign nBranch = (Opcode == `OP_BNE) ? 1'b1 : 1'b0;

    assign ALUSrc = (I_format || Lw || Sw);

    assign R_format = (Opcode == `OP_RTYPE)? 1'b1:1'b0;

    assign RegDST = R_format && (~I_format && ~Lw);

    assign I_format = (Opcode[5:3] == 3'b001) ? 1'b1 : 1'b0;

    assign ALUOp = { (R_format || I_format) , (Branch || nBranch) };

    assign Sftmd = (Opcode == `OP_RTYPE && Function_opcode[5:3] == 3'b000)? 1'b1:1'b0;

    assign RegWrite = (R_format || Lw || Jal || I_format) && !(Jr) ; // Write memory or write IO

    assign MemWrite = ((Sw) && (Alu_resultHigh != `IO_ADDR)) ? 1'b1:1'b0; // Write memory

    assign MemRead = ((Lw) && (Alu_resultHigh != `IO_ADDR)) ? 1'b1:1'b0; // Read memory

    assign IORead = ((Lw) && (Alu_resultHigh == `IO_ADDR)) ? 1'b1:1'b0; // Read input port

    assign IOWrite = ((Sw) && (Alu_resultHigh == `IO_ADDR)) ? 1'b1:1'b0; // Write output port

    // Read operations require reading data from memory or I/O to write to the register
    assign MemorIOtoReg = IORead || MemRead;    
endmodule
