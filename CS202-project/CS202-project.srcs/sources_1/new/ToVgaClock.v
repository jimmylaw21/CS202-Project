module ToVgaClock(clk, new_clk);
  
  input clk;
  output reg new_clk;

  reg [1:0] cnt;

  always @(posedge clk) begin
    cnt <= cnt + 1'b1;
    if (cnt == 2'b11) begin
      cnt <= 2'b00;
    end
  end

  always @(posedge clk) begin
    if (cnt == 2'b10) begin
      new_clk <= ~new_clk;
    end
  end

endmodule
