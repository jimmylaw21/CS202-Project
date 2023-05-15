`include "public.v"


module control32(Opcode, Function_opcode, Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp);

    input[5:0]  Opcode;              // 来自IFetch模块的指令高6bit
    input[5:0]  Function_opcode;  	 // 来自IFetch模块的指令低6bit，用于区分r-类型中的指令

    output reg      Jr;         	 // 为1表明当前指令是jr，为0表示当前指令不是jr
    output reg      RegDST;          // 为1表明目的寄存器是rd，为0时表示目的寄存器是rt
    output reg      ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）来自立即数（beq，bne除外），为0时表示第二个操作数来自寄存器
    output reg      MemtoReg;        // 为1表明从存储器或I/O读取数据写到寄存器，为0时表示将ALU模块输出数据写到寄存器
    output reg      RegWrite;   	 // 为1表明该指令需要写寄存器，为0时表示不需要写寄存器
    output reg      MemWrite;        // 为1表明该指令需要写存储器，为0时表示不需要写储存器
    output reg      Branch;          // 为1表明是beq指令，为0时表示不是beq指令
    output reg      nBranch;         // 为1表明是bne指令，为0时表示不是bne指令
    output reg      Jmp;             // 为1表明是j指令，为0时表示不是j指令
    output reg      Jal;             // 为1表明是jal指令，为0时表示不是jal指令
    output reg      I_format;        // 为1表明该指令是除beq，bne，lw，sw之外的I-类型指令，其余情况为
    output reg      Sftmd;           // 为1表明是移位指令，为0表明不是移位指令
    output reg[1:0] ALUOp;           // 当指令为R-type或I_format为1时，ALUOp的高比特位为1，否则高比特位为0; 当指令为beq或bne时，ALUOp的低比特位为1，否则低比特位为0


  reg R_format;

  always @(*) begin

    // 处理R-Type 的jr、R-Format 和 RegDST
    if(Opcode == `OP_RTYPE) begin
        Jr <= Function_opcode == `FUNC_JR;
        R_format <= `Enable;
        RegDST <= 1; //表示目的寄存器是rd


    end
    else begin
        Jr <= 0;
        R_format <= `Disable;
        RegDST <= 0; //表示目的寄存器是rt
    end

    // 处理I_format （不是J也不是R）(为1表明该指令是除beq，bne，lw，sw之外的I-类型指令)
    // I_format <=  Opcode[5:1] != 5'b00001 && Opcode != `OP_RTYPE;
    I_format = Opcode[5:3] == 3'b001;

    // 处理RegWrite (I-Type的一部分；R-type除了jr的所有；lw和jar）
    RegWrite <= Opcode[5:3] == 3'b001 || (Opcode == `OP_RTYPE && Function_opcode != `FUNC_JR) || Opcode[3:0] == 4'b0011;

    // 处理Branch
    Branch <= Opcode == `OP_BEQ;

    // 处理ALUSrc(所有I-Type，除了bne和beq)
    ALUSrc <= I_format && Opcode[5:2] != 4'b0001 || Opcode == `OP_SW || Opcode == `OP_LW;

    // 处理MemtoReg
    MemtoReg <= Opcode == `OP_LW;

    // 处理MemWrite
    MemWrite <= Opcode == `OP_SW;

    // 处理nBranch
    nBranch <= Opcode == `OP_BNE;

    // 处理Jmp
    Jmp <= Opcode == `OP_J;

    // 处理Jal
    Jal <= Opcode == `OP_JAL;

    // 处理Sftmd
    Sftmd <= Opcode == `OP_RTYPE && Function_opcode[5:3] == 3'b000;

    // 处理ALUOp
    if(Opcode == `OP_RTYPE || I_format == 1'b1)begin
        ALUOp[1:1] = 1'b1;
    end else begin
        ALUOp[1:1] = 1'b0;
    end

    if(Opcode == `OP_BEQ || Opcode == `OP_BNE)begin
        ALUOp[0:0] = 1'b1;
    end else begin
        ALUOp[0:0] = 1'b0;
    end

  end



endmodule