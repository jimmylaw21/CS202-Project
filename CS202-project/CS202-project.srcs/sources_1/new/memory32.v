`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 09:40:03
// Design Name: 
// Module Name: memory32
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


module memory32(
    input clock, // ‘Clock’ signal
    /* used to determine to write the memory unit or not,
    in the left screenshot its name is ‘WE’ */
    input memWrite,
    // the ‘Address’ of memory unit which is to be read/writen
    input[31:0] address,
    // data tobe wirten to the memory unit
    input[31:0] writeData,
    /*data to be read from the memory unit, in the left
    screenshot its name is ‘MemData’ */
    output[31:0] readData,
    input m_strobe,
    output m_ready,
    // UART Programmer Pinouts
    input upg_rst_i, // UPG reset (Active High)
    input upg_clk_i, // UPG ram_clk_i (10MHz)
    input upg_wen_i, // UPG write enable
    input [13:0] upg_adr_i, // UPG write address
    input [31:0] upg_dat_i, // UPG write data
    input upg_done_i // 1 if programming is finished
    );
    // Part of dmemory32 module
    //Create a instance of RAM(IP core), binding the ports
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    RAM ram (
    .clka(kickOff ? clk : upg_clk_i), // input wire clka
    .wea(kickOff ? memWrite && m_strobe : upg_wen_i), // input wire [0 : 0] wea
    .addra(kickOff ? address[15:2] : upg_adr_i), // input wire [13 : 0] addra
    .dina(kickOff ? writeData : upg_dat_i), // input wire [31 : 0] dina
    .douta(readData) // output wire [31 : 0] douta
    );
    /*The ‘clock’ is from CPU-TOP, suppose its one edge has been used at the upstream module of data memory, such as IFetch, Why Data-Memroy DO NOT use the same edge as other module ? */
    assign clk = !clock;
    assign m_ready = ~memWrite;
endmodule
