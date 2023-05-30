`include "public.v"
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


module binaryToHex (
  input [15:0] binary, //输入的二进制数
  output [55:0] segouts //七段数码管每位对应的形状
);
  wire [31:0] bi;
  assign bi = {`ZeroHalfWord,binary};
  transfer tr0(bi[3:0],segouts[6:0]);
  transfer tr1(bi[7:4],segouts[13:7]);
  transfer tr2(bi[11:8],segouts[20:14]);
  transfer tr3(bi[15:12],segouts[27:21]);
  transfer tr4(bi[19:16],segouts[34:28]);
  transfer tr5(bi[23:20],segouts[41:35]);
  transfer tr6(bi[27:24],segouts[48:42]);
  transfer tr7(bi[31:28],segouts[55:49]);
endmodule

