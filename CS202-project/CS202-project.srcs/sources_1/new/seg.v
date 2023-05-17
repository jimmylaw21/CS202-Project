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
    wire [3:0] groups [0:3];
    assign groups[0] = segwdata [3:0];
    assign groups[1] = segwdata [7:4];
    assign groups[2] = segwdata [11:8];
    assign groups[3] = segwdata [15:12];
    wire [6:0] displays [0:3];
    binaryToHex bth0(groups[0], displays[0]);
    binaryToHex bth1(groups[1], displays[1]);
    binaryToHex bth2(groups[2], displays[2]);
    binaryToHex bth3(groups[3], displays[3]);
    always @ (*) begin
        if (segrst) begin
            segout = 7'b100_0000;
        end
        else begin
            case (lights)
                8'b1111_1110: segout = displays[0];
                8'b1111_1101: segout = displays[1];
                8'b1111_1011: segout = displays[2];
                8'b1111_0111: segout = displays[3];
                default: segout = 7'b100_0000;
            endcase
        end
    end        
endmodule
