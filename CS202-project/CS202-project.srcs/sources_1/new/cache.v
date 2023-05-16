// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company:
// // Engineer:
// //
// // Create Date: 2023/05/13 10:41:35
// // Design Name:
// // Module Name: cache
// // Project Name:
// // Target Devices:
// // Tool Versions:
// // Description:
// //
// // Dependencies:
// //
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// //
// //////////////////////////////////////////////////////////////////////////////////


module cache #(parameter A_WIDTH = 32,
               parameter C_INDEX = 10,
               parameter D_WIDTH = 32)
              (clk,
               resetn,
               p_a,
               p_dout,
               p_din,
               p_strobe,
               p_rw,
               p_ready,
               m_a,
               m_dout,
               m_din,
               m_strobe,
               m_rw,
               m_ready);
    input clk, resetn;
    input [A_WIDTH-1:0] p_a; //address of memory to be accessed
    input [D_WIDTH-1:0] p_dout; //the data from cpu
    output [D_WIDTH-1:0] p_din; //the data to cpu
    input p_strobe; // 1 means to do the reading or writing
    input p_rw; // 0:read, 1:write
    output p_ready; // tell cpu, outside of cpu is ready
    output [A_WIDTH-1:0] m_a; //address of memory to be accessed
    input [D_WIDTH-1:0] m_dout; //the data from memory
    output [D_WIDTH-1:0] m_din; //the data to memory
    output m_strobe; //1 means to do the reading or writing
    output m_rw; //0:read, 1:write
    input m_ready; //memory is read
    
    // d_valid is a piece of memory stored the valid info for every block
    reg d_valid [0 : (1 << C_INDEX) - 1];
    // T_WIDTH is the width of ‘Tag�???
    localparam T_WIDTH = A_WIDTH - C_INDEX - 2;
    //d_tags is a piece of memory stored the tag info for every block
    reg [T_WIDTH-1: 0] d_tags [0 : (1 << C_INDEX) - 1];
    //d_data is a piece of memory stored the data for every block
    reg [D_WIDTH-1:0] d_data [0 : (1 << C_INDEX) - 1];
    
    wire [C_INDEX-1:0] index  = p_a[C_INDEX+1:2];
    wire [T_WIDTH-1:0] tag    = p_a[A_WIDTH-1:C_INDEX+2];
    wire valid                = d_valid[index];
    wire [T_WIDTH-1:0] tagout = d_tags[index];
    wire [D_WIDTH-1:0] c_dout = d_data[index];
    
    //cache control
    wire cache_hit  = valid & (tag == tagout);
    wire cache_miss = ~cache_hit;
    
    //Cache write
    wire c_write = p_rw | cache_miss & m_ready ;
    always @ (posedge clk, negedge resetn)
        if (resetn == 1'b0)
        begin
            integer i;
            for (i = 0; i < (1 << C_INDEX); i = i + 1)
                d_valid[i] = 1'b0;  // use blocking assignment here for immediate effect
        end
        else if (c_write == 1'b1)
            d_valid[index] <= 1'b1;
    
    always @ (posedge clk)
        if (c_write == 1'b1) d_tags[index] = tag;
    
    wire sel_in              = p_rw;
    wire [D_WIDTH-1:0] c_din = sel_in ? p_dout : m_din;
    always @ (posedge clk)
        if (c_write == 1'b1) d_data[index] = c_din;
    
    // Memory write (write_through)
    assign m_a      = p_a;
    assign m_din    = p_dout;
    assign m_strobe = p_strobe & (p_rw | cache_miss);
    assign m_rw     = p_strobe & p_rw;
    
    // Read data to CPU
    wire sel_out   = cache_hit;
    assign p_din   = sel_out ? c_dout : m_dout;
    assign p_ready = ~p_rw & cache_hit | (cache_miss | p_rw) & m_ready;
endmodule
