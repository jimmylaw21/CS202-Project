`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/26 20:29:16
// Design Name: 
// Module Name: programrom
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


module programrom(
    input rom_clk_i, // ROM clock
    input[13:0] rom_adr_i, // From IFetch
    output [31:0] Instruction_o, // To IFetch
    // UART Programmer Pinouts
    input upg_rst_i, // UPG reset (Active High)
    input upg_clk_i, // UPG clock (10MHz)
    input upg_wen_i, // UPG write enable
    input[13:0] upg_adr_i, // UPG write address
    input[31:0] upg_dat_i, // UPG write data
    input upg_done_i // 1 if program finished
    );
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i );
    prgrom instmem (
    .clka (kickOff ? rom_clk_i : upg_clk_i ),
    .wea (kickOff ? 1'b0 : upg_wen_i ),
    .addra (kickOff ? rom_adr_i : upg_adr_i ),
    .dina (kickOff ? `ZeroWord : upg_dat_i ),
    .douta (Instruction_o)
    );
endmodule
