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
    input	[1:0]	ledaddr,	// 2'b00 means updata the low 16bits of ledout, 2'b10 means updata the high 8 bits of ledout
    input	[15:0]	ledwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output  [7:0]   enables,
    output	reg [7:0] 	segout,		// the data writen to the leds  of the board
    output          digitPoint
    );
    reg[7:0] lights;
    assign enables = lights;
    always @ (posedge seg_clk or posedge segrst) begin
        if (segrst) begin
            lights <= 7'b000_0000;
        end    
        else if (segcs && segwrite) begin
            if (lights == 7'b000_0000 | lights == 7'b100_0000) begin
                lights <= 7'b000_0001; 
            end 
            else begin
                lights <= lights << 1;
            end        
        end        
    end    
    always @ (posedge seg_clk or posedge segrst) begin
        if (segrst) begin
            segout <= 7'b000_0000;
        end    
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/*		else if (segcs && segwrite) begin
			if (ledaddr == 2'b00)
				ledout[23:0] <= { ledout[23:16], ledwdata[15:0] };
			else if (ledaddr == 2'b10 )
				ledout[23:0] <= { ledwdata[7:0], ledout[15:0] };
			else
				ledout <= ledout;
        end else begin
            ledout <= ledout;
        end*/
    end
endmodule
