`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 19:41:33
// Design Name: 
// Module Name: ioRead
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


module ioread (
    input			reset,				// reset, active high 复位信号 (高电平有�?)
	input			ior,				// from Controller, 1 means read from input device(从控制器来的I/O�?)
    input			switchctrl,			// means the switch is selected as input device (从memorio经过地址高端线获得的拨码�?关模块片�?)
    input	[15:0]	ioread_data_switch,	// the data from switch(从外设来的读数据，此处来自拨码开�?)
    output	reg [15:0]	ioread_data 		// the data to memorio (将外设来的数据�?�给memorio)
);
    
    
    always @* begin
        if (reset)
            ioread_data = 16'h0;
        else if (ior == 1) begin
            if (switchctrl == 1)
                ioread_data = ioread_data_switch;
            else
				ioread_data = ioread_data;
        end
    end
	
endmodule
