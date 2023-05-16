`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 19:41:55
// Design Name: 
// Module Name: ioWrite
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


module binaryToHex(
    input [3:0] number,
    output reg [6:0] hexNumber
    );
    always @(*) begin
        case (number) 
            4'h0: hexNumber = 7'b100_0000;
            4'h1: hexNumber = 7'b111_1001;
            4'h2: hexNumber = 7'b010_0100;
            4'h3: hexNumber = 7'b011_0000;
            4'h4: hexNumber = 7'b001_1001;
            4'h5: hexNumber = 7'b001_0010;
            4'h6: hexNumber = 7'b000_0010;
            4'h7: hexNumber = 7'b111_1000;
            4'h8: hexNumber = 7'b000_0000;
            4'h9: hexNumber = 7'b001_0000;
            4'ha: hexNumber = 7'b000_1000;
            4'hb: hexNumber = 7'b000_0011;
            4'hc: hexNumber = 7'b010_0111;
            4'hd: hexNumber = 7'b010_0001;
            4'he: hexNumber = 7'b000_0110;
            4'hf: hexNumber = 7'b000_1110;            
        endcase
    end    
endmodule
