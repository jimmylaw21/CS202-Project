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


module binaryToDecimal (
  input [15:0] binary,
  output [55:0] segouts 
);
  reg [31:0] bcd;
  reg [15:0] quotient;
  reg [3:0] remainder;
  integer i;

  always @(*) begin
    quotient = binary;
    
    for (i = 0; i < 8; i = i + 1) begin
      remainder = quotient % 10;
      quotient = quotient / 10;
      bcd[4*i +: 4] = remainder;
    end
  end
  transfer tr0(bcd[3:0],segouts[6:0]);
  transfer tr1(bcd[7:4],segouts[13:7]);
  transfer tr2(bcd[11:8],segouts[20:14]);
  transfer tr3(bcd[15:12],segouts[27:21]);
  transfer tr4(bcd[19:16],segouts[34:28]);
  transfer tr5(bcd[23:20],segouts[41:35]);
  transfer tr6(bcd[27:24],segouts[48:42]);
  transfer tr7(bcd[31:28],segouts[55:49]);
endmodule

