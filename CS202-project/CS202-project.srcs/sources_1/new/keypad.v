// The keypad module reads input from a 4x4 keypad and generates corresponding key press events.
module keypad(clk, rst_n, row_in, col_out, press, keyboard_val);
// clock signal
input           clk;
// reset signal, active low
input           rst_n;
// rows input, representing 4 rows of the keypad
input      [3:0] row_in;                 
// columns output, representing 4 columns of the keypad
output reg [3:0] col_out;                 
// key press event signal
output press;
// 4-bit value corresponding to the key pressed
output reg [3:0] keyboard_val;
 
// counter for generating key clock signal
reg [19:0] cnt;                         
// key clock signal, a slower clock derived from the main clock
wire key_clk;
 
// on every clock or reset edge, update the counter
always @ (posedge clk or posedge rst_n)
  if (rst_n)
    cnt <= 0;  // reset counter
  else
    cnt <= cnt + 1'b1;  // increment counter
    
// derive key clock from counter
assign key_clk = cnt[19];  // frequency is main clock frequency divided by 2^20

// define state codes
parameter NO_KEY_PRESSED = 6'b000_001;  // no key is pressed
parameter SCAN_COL0      = 6'b000_010;  // scan column 0
parameter SCAN_COL1      = 6'b000_100;  // scan column 1
parameter SCAN_COL2      = 6'b001_000;  // scan column 2
parameter SCAN_COL3      = 6'b010_000;  // scan column 3
parameter KEY_PRESSED    = 6'b100_000;  // a key is pressed

// state variables
reg [5:0] current_state, next_state;    

// on every key clock or reset edge, update the current state
always @ (posedge key_clk or posedge rst_n)
  if (rst_n)
    begin
    current_state <= NO_KEY_PRESSED;  // reset state
    end
  else
    current_state <= next_state;  // go to next state
 
// state transition logic
always @ (*)
  case (current_state)
    NO_KEY_PRESSED :                    
      next_state = row_in != 4'hF ? SCAN_COL0 : NO_KEY_PRESSED;
    SCAN_COL0 :                         
      next_state = row_in != 4'hF ? KEY_PRESSED : SCAN_COL1;
    SCAN_COL1 :                         
      next_state = row_in != 4'hF ? KEY_PRESSED : SCAN_COL2; 
    SCAN_COL2 :                         
      next_state = row_in != 4'hF ? KEY_PRESSED : SCAN_COL3;
    SCAN_COL3 :                         
      next_state = row_in != 4'hF ? KEY_PRESSED : NO_KEY_PRESSED;
    KEY_PRESSED :                       
      next_state = row_in != 4'hF ? KEY_PRESSED : NO_KEY_PRESSED;                    
  endcase
 
// flag to indicate whether a key press event has been detected
reg       key_pressed_flag;             
// value of the scanned column and row
reg [3:0] col_val, row_val;             
 
// on every key clock or reset edge, update the column output and key press flag
always @ (posedge key_clk or posedge rst_n)
  if (rst_n)
  begin
    col_out          <= 4'h0;  // reset column output
    key_pressed_flag <=    0;  // reset key press flag
  end
  else
    case (next_state)
      NO_KEY_PRESSED :  // if no key is pressed
      begin
        col_out          <= 4'h0;  // no column is selected
        key_pressed_flag <=    0;  // no key press event       
      end
      SCAN_COL0 :  // if scanning column 0
        col_out <= 4'b1110;  // select column 0
      SCAN_COL1 :  // if scanning column 1
        col_out <= 4'b1101;  // select column 1
      SCAN_COL2 :  // if scanning column 2
        col_out <= 4'b1011;  // select column 2
      SCAN_COL3 :  // if scanning column 3
        col_out <= 4'b0111;  // select column 3
      KEY_PRESSED :  // if a key is pressed
      begin
        col_val          <= col_out;  // save the value of the pressed column
        row_val          <= row_in;  // save the value of the pressed row
        key_pressed_flag <= 1;  // generate key press event
      end
    endcase

// on every key clock or reset edge, update the keyboard value
always @ (posedge key_clk or posedge rst_n)
  if (rst_n)
    keyboard_val <= 4'h0;  // reset keyboard value
  else
    if (key_pressed_flag)  // if a key press event is generated
      // decode the pressed key based on the values of the pressed column and row
      case ({col_val, row_val})
        8'b1110_1110 : keyboard_val <= 4'h1;
        8'b1110_1101 : keyboard_val <= 4'h4;
        8'b1110_1011 : keyboard_val <= 4'h7;
        8'b1110_0111 : keyboard_val <= 4'hE;
         
        8'b1101_1110 : keyboard_val <= 4'h2;
        8'b1101_1101 : keyboard_val <= 4'h5;
        8'b1101_1011 : keyboard_val <= 4'h8;
        8'b1101_0111 : keyboard_val <= 4'h0;
         
        8'b1011_1110 : keyboard_val <= 4'h3;
        8'b1011_1101 : keyboard_val <= 4'h6;
        8'b1011_1011 : keyboard_val <= 4'h9;
        8'b1011_0111 : keyboard_val <= 4'hF;
         
        8'b0111_1110 : keyboard_val <= 4'hA; 
        8'b0111_1101 : keyboard_val <= 4'hB;
        8'b0111_1011 : keyboard_val <= 4'hC;
        8'b0111_0111 : keyboard_val <= 4'hD;      
        default: keyboard_val <= 4'h0;  // default value if the pressed key is not defined
      endcase
    else
      keyboard_val <= 4'h0;  // no key is pressed

// assign the key press event signal
assign press = key_pressed_flag;

endmodule

