// public.v

`timescale 1ns / 1ps

`define Enable 1'b1
`define Disable 1'b0

// Minisys Parameters
`define ZeroByte 8'h00
`define ZeroHalfWord 16'h0000 
`define ZeroWord 32'h00000000 // 0x0字
`define RegCount 32 // 寄存器数
`define RegCountLog2 5 // 寄存器数Log2
`define RegRange 31:0 // 寄存器数范围
`define RegRangeLog2 4:0 // 寄存器数Log2范围（地址）
`define WordLength 32 // 字长
`define WordRange 31:0 // 字长范围
`define OpRange 31:26 // 指令字中op的范围
`define RsRange 25:21 // 指令字中rs的范围
`define RtRange 20:16 // 指令字中rt的范围
`define RdRange 15:11 // 指令字中rd的范围
`define ShamtRange 10:6 // 指令字中shamt的范围
`define FuncRange 5:0 // 指令字中func的范围
`define ImmedRange 15:0 // 指令字中immediate的范围
`define OffsetRange 15:0 // 指令字中offset的范围
`define AddressRange 25:0 // 指令字中address的范围

// Minisys Instruction Set
// R Type Instructions
`define OP_RTYPE 6'b000000
`define FUNC_ADD 6'b100000
`define FUNC_ADDU 6'b100001
`define FUNC_SUB 6'b100010
`define FUNC_SUBU 6'b100011
`define FUNC_AND 6'b100100
`define FUNC_OR 6'b100101
`define FUNC_XOR 6'b100110
`define FUNC_NOR 6'b100111
`define FUNC_SLT 6'b101010
`define FUNC_SLTU 6'b101011
`define FUNC_SLL 6'b000000
`define FUNC_SRL 6'b000010
`define FUNC_SRA 6'b000011
`define FUNC_SLLV 6'b000100
`define FUNC_SRLV 6'b000110
`define FUNC_SRAV 6'b000111
`define FUNC_JR 6'b001000
// I Type Instructions
`define OP_ADDI 6'b001000
`define OP_ADDIU 6'b001001
`define OP_ANDI 6'b001100
`define OP_ORI 6'b001101
`define OP_XORI 6'b001110
`define OP_LUI 6'b001111
`define OP_LW 6'b100011
`define OP_SW 6'b101011
`define OP_BEQ 6'b000100
`define OP_BNE 6'b000101
`define OP_SLTI 6'b001010
`define OP_SLTIU 6'b001011
// J Type Instructions
`define OP_J 6'b000010
`define OP_JAL 6'b000011
// NOP
`define OP_NOP 6'b000000

//IO
`define IO_ADDR 22'h3FFFFF
`define SPECIAL_LED 32'hffff_fc58
`define LOW8_LED 32'hffff_fc60
`define HIGH8_LED 32'hffff_fc62
`define SEG 32'hffff_fc66
`define TESTCASE 32'hffff_fc68
`define A 32'hffff_fc70
`define B 32'hffff_fc72
`define CONFIRM 32'hffff_fc74

//decoder
`define IO_BEGIN 32'hFFFFF000
`define SP_BEGIN 32'h00010000
`define ZERO_DECO 5'b00000
`define RA_DECO 5'b11111

//keypad
`define NO_KEY_PRESSED 6'b000_001
`define SCAN_COL0  6'b000_010
`define SCAN_COL1 6'b000_100
`define SCAN_COL2 6'b001_000
`define SCAN_COL3 6'b010_000
`define KEY_PRESSED 6'b100_000
