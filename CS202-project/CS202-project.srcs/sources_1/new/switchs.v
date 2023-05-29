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


module switchs(
    input			reset,				// reset, active high 复位信号 (高电平有�?)
	  input			ior,				// from Controller, 1 means read from input device(从控制器来的I/O�?)
    input	[3:0]       switchctrl,			// 10读a，01读b
    input	[7:0]	ioread_data_switch,	// the data from switch(从外设来的读数据，此处来自拨码开�?) 
    input   [2:0]        testcase,
    input   confirm,
    input    sw_clock,         
    input           aorb,               // 0 for a, 1 for b,拨码开关      
    output	 reg [15:0]	ioread_data 		// the data to memorio (将外设来的数据�?�给memorio)
    // , output reg[7:0] a,
    // output reg[7:0] b
    );
     reg[7:0] a;
     reg[7:0] b;
    always @(posedge sw_clock) begin
        if (reset) begin
            a <= 8'h00;
            b <= 8'h00;
        end
        else if (ior) begin
            if (switchctrl[1:0] != 2'b00) begin
              if (aorb & switchctrl[1]) begin
                b <= ioread_data_switch;
                a <= a;
              end
              else if (~aorb & switchctrl[0]) begin
                a <= ioread_data_switch;
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
    // assign aa = a;
    // assign bb = b;
    // assign showAorB[1] = (testcase == 3'b111);
endmodule