module ToBoardClock(clk, new_clk);
    input clk;
    output reg new_clk;
    reg [31 : 0] cnt = 0; 
    always @(posedge clk)
        begin  
            if (cnt==100000)
                begin
                    cnt<=0;
                    new_clk<=~new_clk;
                end
           else cnt<=cnt+1'b1;
        end
endmodule
