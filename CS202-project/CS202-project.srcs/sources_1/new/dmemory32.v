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


module dmemory32(clock, memWrite, address, writeData, readData);
    input clock;   // Clock signal
    input memWrite;  // From controller, when 1'b1, it indicates a write operation to data-memory is needed
    input [31:0] address;   // Memory address for read or write operation, measured in bytes
    input [31:0] writeData; // The data to be written into data-memory
    output[31:0] readData;  // The data read from data-memory

    // wire clk;
    // assign clk = !clock;     // Due to the inherent delay of the Cyclone chip, the RAM address line is not ready at the rising edge of the clock,
    //                          // causing incorrect data readout at the clock rising edge. Therefore, an inverted clock is used, so that the data readout is about half a clock later than the address preparation,
    //                          // thus getting the correct address.
    
    
    RAM ram (
        .clka(clk), // input wire clka
        .wea(memWrite), // input wire [0 : 0] wea
        .addra(address[15:2]), // input wire [13 : 0] addra
        .dina(writeData), // input wire [31 : 0] dina
        .douta(readData) // output wire [31 : 0] douta
    );
    
endmodule
