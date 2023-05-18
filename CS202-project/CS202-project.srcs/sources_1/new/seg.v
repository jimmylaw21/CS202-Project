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
    input			segrst,		// reset, active high (��λ�ź�,�ߵ�ƽ��Ч)
    input			seg_clk,	// clk for led (ʱ���ź�)
    input			segwrite,	// led write enable, active high (д�ź�,�ߵ�ƽ��Ч)
    input			segcs,		// 1 means the leds are selected as output (��memorio���ģ��ɵ�����λ�γɵ�LEDƬѡ�ź�)
    input	[15:0]	segwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output  [7:0]   enables,
    output	reg [6:0] 	segout		// the data writen to the leds  of the board
    );
    reg[7:0] lights;
    assign enables = lights;
    always @ (posedge seg_clk or posedge segrst) begin
        if (segrst) begin
            lights <= 8'h00;
        end    
        else if (segcs & segwrite) begin
            if (lights == 8'h00 | lights == 8'h7f) begin
                lights <= 8'hfe; 
            end 
            else begin
                lights <= ( lights << 1 | 8'h01);
            end
        end    
        else lights <= 8'h00;                     
    end   
    wire [55:0] displays;
    binaryToDecimal btd(segwdata, displays);
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
                default: segout = 7'b100_0000;
            endcase
        end
    end        
endmodule
