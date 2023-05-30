`include "public.v"
//分频器
module ToBoardClock #(parameter PARAM = 100000)(clk, new_clk,rst);
    input clk;
    input rst;
    output reg new_clk;
    reg [31 : 0] cnt = `ZeroWord; 
    always @(posedge clk or posedge rst)
        begin  
            if (rst) begin
              cnt <=`ZeroWord;
              new_clk <=0;
            end
            else if (cnt==PARAM)
                begin
                    cnt<=`ZeroWord;
                    new_clk<=~new_clk;
                end
           else cnt<=cnt+1'b1;
        end
endmodule
