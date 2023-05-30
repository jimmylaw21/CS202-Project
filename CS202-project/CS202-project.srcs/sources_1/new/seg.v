`include "public.v"
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


module seg(
    input			segrst,		// reset, active high 
    input			seg_clk,	// 七段数码管扫描的时钟信号
    input           seg_clk1,   //七段数码管更新数据的时钟信号
    input           segctrl,    //是否选择七段数码管作为输出，高电平有效
    input	[15:0]	segwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output  [7:0]   enables,    //七段数码管各位的使能信号
    output	reg [6:0] 	segout,		// the data writen to the segs  of the board
    input cache_enable //用于cache测试
    );
    reg[15:0] data_to_show = `ZeroHalfWord; 
    always @(negedge seg_clk1 or posedge segrst) begin
        if (segrst) begin
          data_to_show <= `ZeroHalfWord;
        end
        else if (segctrl | cache_enable) begin
          data_to_show <= segwdata;
        end
        else begin
          data_to_show <= data_to_show;
        end
    end 
    reg[7:0] lights = 8'hff;    //当前的8位使能信号
    reg[7:0] next_lights = 8'hfe;   //下一次要更新的使能信号
    assign enables = lights;
    always @ (posedge seg_clk or posedge segrst) begin
        if (segrst) begin
            lights <= 8'hff;
        end    
        else  begin
            if (lights == 8'hff) begin
                lights <= next_lights; 
            end 
            else begin
                if (next_lights == 8'h7f) begin
                  next_lights <= (next_lights << 1);
                end
                else begin
                  next_lights <= ( next_lights << 1 | 8'h01);
                end
                lights <= 8'hff;
            end
        end                      
    end   
    wire [55:0] displays;
    binaryToHex btd(data_to_show, displays);
    always @ (*) begin
        if (segrst) begin
            segout = 7'b100_0000;
        end
        else begin
            case (lights)
                8'b1111_1110: segout = displays[6:0];
                8'b1111_1101: segout = displays[13:7];
                8'b1111_1011: segout = displays[20:14];
                8'b1111_0111: segout = displays[27:21];
                8'b1110_1111: segout = displays[34:28];
                8'b1101_1111: segout = displays[41:35];
                8'b1011_1111: segout = displays[48:42];
                8'b0111_1111: segout = displays[55:49];
                default: segout = 7'b111_1111;
            endcase
        end
    end        
endmodule
