`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 09:57:04
// Design Name: 
// Module Name: IFetch32
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


module IFetch32(
    output[31:0] Instruction_o, // the instruction fetched from this module to Decoder and Controller
    output reg [31:0] branch_base_addr, // (pc+4) to ALU which is used by branch type instruction
    output reg [31:0] link_addr, // (pc+4) to Decoder which is used by jal instruction
    output [13:0] rom_adr_o,
    //from CPU TOP
    input clock, reset, // Clock and reset
    // from ALU
    input[31:0] Addr_result, // the calculated address from ALU
    input Zero, // while Zero is 1, it means the ALUresult is zero
    // from Decoder
    input[31:0] Read_data_1, // the address of instruction used by jr instruction
    // from Controller
    input Branch, // while Branch is 1,it means current instruction is beq
    input nBranch, // while nBranch is 1,it means current instruction is bnq
    input Jmp, // while Jmp 1, it means current instruction is jump
    input Jal, // while Jal is 1, it means current instruction is jal
    input Jr, // while Jr is 1, it means current instruction is jr
    input [31:0] Instruction //从指令memory传入的值
    );

    reg [31:0] Next_PC; //下一个PC的值
    reg [31:0] PC;
    assign Instruction_o = Instruction;
    assign rom_adr_o = PC[15:2];
    always @* begin
            if (((Branch == 1) && (Zero == 1)) || ((nBranch == 1) && (Zero == 0))) begin // beq, bne
                Next_PC = Addr_result; // the calculated new value for PC
                branch_base_addr = PC + 4;
            end else if (Jr == 1)
                Next_PC = Read_data_1; // the value of $31 register
            else 
                Next_PC = PC + 4; // PC+4
                branch_base_addr = PC + 4;
        end

        always @(negedge clock) begin
            if (reset)
                PC <= `ZeroWord;
            else begin
                // 如果是跳转指令，记录返回地址，然后根据指令中的地址字面改写当前PC
                if ((Jmp == 1) || (Jal == 1)) begin
                    link_addr = PC + 4;
                    PC <= { 4'b0000, Instruction[25:0], 2'b00 };
                end else begin
                    PC <= Next_PC;
                end
            end
        end        
            
endmodule
