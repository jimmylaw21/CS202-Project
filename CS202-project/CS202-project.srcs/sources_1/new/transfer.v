`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 21:05:56
// Design Name: 
// Module Name: 7seg
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


module transfer(
    input [3:0] bi,   //对应的16以内的数
    output reg [6:0] displays //数码管显示的形状
    );
    always @(*) begin
      case (bi) 
            4'd0:displays = 7'b100_0000;
            4'd1:displays = 7'b111_1001;
            4'd2:displays = 7'b010_0100;
            4'd3:displays = 7'b011_0000;
            4'd4:displays = 7'b001_1001;
            4'd5:displays = 7'b001_0010;
            4'd6:displays = 7'b000_0010;
            4'd7:displays = 7'b111_1000;
            4'd8:displays = 7'b000_0000;
            4'd9:displays = 7'b001_0000;
            4'd10:displays = 7'b000_1000;
            4'd11:displays = 7'b000_0011;
            4'd12:displays = 7'b010_0111;
            4'd13:displays = 7'b010_0001;
            4'd14:displays = 7'b000_0110;
            4'd15:displays = 7'b000_1110;
      endcase
    end 

endmodule
