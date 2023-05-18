`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/14 12:26:51
// Design Name: 
// Module Name: dmemory32
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


module dmemory32(clock, memWrite, address, writeData, readData, upg_rst_i, upg_clk_i, upg_wen_i, upg_adr_i,  upg_dat_i, upg_done_i);
    input clock;   // Clock signal
    input memWrite;  // From controller, when 1'b1, it indicates a write operation to data-memory is needed
    input [31:0] address;   // Memory address for read or write operation, measured in bytes
    input [31:0] writeData; // The data to be written into data-memory
    output[31:0] readData;  // The data read from data-memory

    // wire clk;
    // assign clk = !clock;     // Due to the inherent delay of the Cyclone chip, the RAM address line is not ready at the rising edge of the clock,
    //                          // causing incorrect data readout at the clock rising edge. Therefore, an inverted clock is used, so that the data readout is about half a clock later than the address preparation,
    //                          // thus getting the correct address.
    input upg_rst_i; // UPG reset (Active High) 
    input upg_clk_i; // UPG ram_clk_i (10MHz)
    input upg_wen_i; // UPG write enable
    input [13:0] upg_adr_i; // UPG write address
    input [31:0] upg_dat_i; // UPG write data
    input upg_done_i; // 1 if programming is finished

    wire ram_clk = !clock;
    /* CPU work on normal mode when kickOff is 1. CPU work on Uart communicate mode when kickOff is 0.*/
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    RAM ram (
        .clka(kickoff ? ram_clk : upg_clk_i), // input wire clka
        .wea(kickoff ? memWrite : upg_wen_i), // input wire [0 : 0] wea
        .addra(kickoff ? address[15:2] : upg_wen_i), // input wire [13 : 0] addra
        .dina(kickoff ? writeData : upg_adr_i), // input wire [31 : 0] dina
        .douta(kickoff ? readData : upg_dat_i) // output wire [31 : 0] douta
    );
    
endmodule
