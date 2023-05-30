`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 11:59:33
// Design Name: 
// Module Name: leds
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

module leds (
    input			ledrst,		// reset, active high 
    input			led_clk,	// clk for led 显示更新
    input			led_clk1,	// clk for led 即将显示数据的更新
    input			ledwrite,	// led write enable, active high 
    input   [1:0]        high_low,  //更新高位为1更新高8为，低位为1更新低8为
    input     extra,            //溢出等特殊情况的的输入，高电平有效
    input	[15:0]	ledwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output  reg signal,         //显示是否为溢出等特殊情况
    output	reg [15:0]	ledout		// the data writen to the leds  of the board
    );  
    reg [7:0] low; //led灯低8位的数据
    reg [7:0] high;//led灯高8位的数据
    always @(negedge led_clk) begin
        ledout <= {high, low};
    end
    initial begin
        high = `ZeroByte;
        low = `ZeroByte;
    end
    always @ (negedge led_clk1 or posedge ledrst) begin
        if (ledrst) begin
            high <= `ZeroByte;
            low <= `ZeroByte;
        end
		else if (ledwrite & high_low != 2'b00) begin
              case (high_low)
                2'b10:  begin
                    high <= ledwdata[7:0];
                    low <= low;
                end
                2'b01:  begin
                    high <= high;
                    low <= ledwdata[7:0];
                end
                default: begin
                    high <= high;
                    low <= low;
                end
              endcase
        end
        else begin
            high <= high;
            low <= low;
        end
    end
    initial begin
        signal = 1'b0;
    end
    always @ (negedge led_clk or posedge ledrst) begin
        if (ledrst)
          signal <= 1'b0;
		    else if (extra) begin
          signal <= ledwdata[0:0];
        end
        else begin
          signal <= 1'b0;
        end
    end

	
endmodule
