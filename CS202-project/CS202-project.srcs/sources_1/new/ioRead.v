`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 11:59:51
// Design Name: 
// Module Name: switchs
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


module ioRead(
    input			reset,				// reset, active high 复位信号 (高电平有效)
	  input			ior,				// from Controller, 1 means read from input device(从控制来的I/O使能)
    input	[3:0]       switchctrl,			// 0001读a，0010读b，0100读testcase,1000读确定信号
    input	[7:0]	input_data,	// the data from switch(从外设来的读数据) 
    input   [2:0]        testcase,  //表明当前是哪个测试样例
    input   confirm,                //某些测试样例需要用到的确定信号
    input    ioread_clock,              //更新a,b的时钟
    input           a_or_b,               // 0 for a, 1 for b,拨码开关      
    output	 reg [15:0]	ioread_data 		// the data to memorio (将外设来的数据传给memorio)
    );
    reg[7:0] a; //储存输入值a
    reg[7:0] b; //储存输入值b
    always @(posedge ioread_clock) begin
        if (reset) begin
            a <= 8'h00;
            b <= 8'h00;
        end
        else if (ior) begin
            if (switchctrl[1:0] != 2'b00) begin
              if (a_or_b & switchctrl[1]) begin
                b <= input_data;
                a <= a;
              end
              else if (~a_or_b & switchctrl[0]) begin
                a <= input_data;
                b <= b;
              end
            end               
        end
        else begin
          a <= a;
          b <= b;
        end
    end

    always @(*) begin
        case (switchctrl)
        4'b1000:ioread_data = {15'h0000, confirm};
        4'b0100:ioread_data = {13'h0000, testcase};
        4'b0001:ioread_data = {8'h00, a};
        4'b0010:ioread_data = {8'h00, b};
        default: ioread_data = 16'h0000;
        endcase
    end
endmodule
