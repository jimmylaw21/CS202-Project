`timescale 1ns / 1ps
`include "public.v"

module keypad_combined (
    input wire clk, rst_n,

    input wire [3:0] row_in,
    output reg [3:0] col_out,

    output reg press,
    output reg [3:0] keyboard_val
    );
    
    localparam  SCAN_COL_1    = 2'b00,
                SCAN_COL_2    = 2'b01,
                SCAN_COL_3    = 2'b10,
                SCAN_COL_4    = 2'b11,
                DISABLE_COL_1 = 4'b0111,
                DISABLE_COL_2 = 4'b1011,
                DISABLE_COL_3 = 4'b1101,
                DISABLE_COL_4 = 4'b1110;

    localparam  TRAVERSE_PERIOD = 10, // time given for the signal to travel to the keypad
                COLUMN_PERIOD   = `KEYPAD_DELAY_PERIOD / 4;
    
    reg [1:0]  state;
    reg [20:0] delay_duration;
    reg [3:0]  row_pre [3:0];
    reg [3:0]  row_old [3:0];
    reg [7:0]  key_coord;
    reg        key_pressed_flag;
    
    integer i;
    always @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            {
                delay_duration,
                key_coord
            }       = 0;

            state   = SCAN_COL_1;
            col_out = DISABLE_COL_1;
            press = 0;

            for (i = 0; i < 4; i = i + 1) begin
                row_pre[i] = 4'hf;
                row_old[i] = 4'hf;
            end
        end else case ({delay_duration == TRAVERSE_PERIOD, // check for changes by the scanning signal
                        delay_duration == COLUMN_PERIOD})  // let out the next signal for scanning
            2'b10  : begin
                delay_duration = delay_duration + 1;

                if (row_in         != 4'hf &  // currently key is being pressed
                    row_old[state] == 4'hf &  // two periods ago no key is pressed
                    row_pre[state] == row_in) begin  // one preiod ago the same key is pressed

                    key_coord  = {row_in, col_out};
                    key_pressed_flag = 1;
                    end
                else begin
                    key_coord  = 0;
                    key_pressed_flag = 0;
                end
                
                row_old[state] = row_pre[state];
                row_pre[state] = row_in;
                state          = state + 1;
            end
            2'b01  : begin
                delay_duration = 0;

                case (state)
                    SCAN_COL_1: col_out = DISABLE_COL_1;
                    SCAN_COL_2: col_out = DISABLE_COL_2;
                    SCAN_COL_3: col_out = DISABLE_COL_3;
                    default   : col_out = DISABLE_COL_4; // SCAN_COL_4
                endcase
            end
            default: begin
                delay_duration = delay_duration + 1;
                key_coord      = 0;
                key_pressed_flag = 0;
            end
        endcase
    end

    always @(posedge clk or posedge rst_n)
        if (rst_n)
            keyboard_val <= 4'h0;
        else
            if (key_pressed_flag)
                case (key_coord)
                    8'b0110_1110 : keyboard_val <= 4'h1;
                    8'b0110_1101 : keyboard_val <= 4'h4;
                    8'b0110_1011 : keyboard_val <= 4'h7;
                    8'b0110_0111 : keyboard_val <= 4'hE;

                    8'b1010_1110 : keyboard_val <= 4'h2;
                    8'b1010_1101 : keyboard_val <= 4'h5;
                    8'b1010_1011 : keyboard_val <= 4'h8;
                    8'b1010_0111 : keyboard_val <= 4'h0;

                    8'b1100_1110 : keyboard_val <= 4'h3;
                    8'b1100_1101 : keyboard_val <= 4'h6;
                    8'b1100_1011 : keyboard_val <= 4'h9;
                    8'b1100_0111 : keyboard_val <= 4'hF;

                    8'b1110_1110 : keyboard_val <= 4'hA;
                    8'b1110_1101 : keyboard_val <= 4'hB;
                    8'b1110_1011 : keyboard_val <= 4'hC;
                    8'b1110_0111 : keyboard_val <= 4'hD;
                    default      : keyboard_val <= 4'h0;
                endcase
            else
                keyboard_val <= 4'h0;

    assign press = key_pressed_flag;

endmodule

