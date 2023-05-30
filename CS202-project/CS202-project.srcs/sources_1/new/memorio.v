`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 10:27:26
// Design Name: 
// Module Name: memorio
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


module memorio(
    input mRead, // read memory, from Controller
    input mWrite, // write memory, from Controller
    input ioRead, // read IO, from Controller
    input ioWrite, // write IO, from Controller
    input[31:0] addr_in, // from alu_result in ALU
    output[31:0] addr_out, // address to Data-Memory
    input[31:0] m_rdata, // data read from Data-Memory
    input[15:0] io_rdata, // data read from IO,16 bits
    output reg [31:0] r_wdata, // data to Decoder(register file)
    input[31:0] r_rdata, // data read from Decoder(register file)
    output reg[31:0] write_data, // data to memory or I/O（m_wdata, io_wdata）
    output [2:0] LEDCtrl, // 表明当前led的输出数据是那种类型
    output [3:0] SwitchCtrl, // 表明当前拨码开关的输入数据是那种类型
    output SegCtrl      //选择七段数码管作为输出
    );
    assign addr_out= addr_in;
    // The data wirte to register file may be from memory or io. // While the data is from io, it should be the lower 16bit of r_wdata. 
    always @(*) begin
        if (mRead) begin
          r_wdata = m_rdata;
        end
        else if (ioRead) begin
          r_wdata = {`ZeroHalfWord,io_rdata};
        end
        else begin
          r_wdata = 0;  
        end
    end
    // Chip select signal of Led and Switch are all active high;
    //不同的地址对应输入和输出，70A,72B,60led low8,62led high8,,66seg,68测试样例,74确认，58特殊情况的小灯
    assign LEDCtrl[0] = ioWrite && (addr_in == `LOW8_LED);
    assign LEDCtrl[1] = ioWrite && (addr_in == `HIGH8_LED);
    assign LEDCtrl[2] = ioWrite && (addr_in == `SPECIAL_LED);
    assign SegCtrl = ioWrite && (addr_in == `SEG);
    assign SwitchCtrl[0] = ioRead && (addr_in == `A);
    assign SwitchCtrl[1] = ioRead && (addr_in == `B);
    assign SwitchCtrl[2] = ioRead && (addr_in == `TESTCASE);
    assign SwitchCtrl[3] = ioRead && (addr_in == `CONFIRM);
    always @* begin
    if((mWrite==1)||(ioWrite==1))
    //wirte_data could go to either memory or IO. where is it from?
    write_data = ((mWrite == 1'b1) ? r_rdata : {`ZeroHalfWord,r_rdata[15:0]});
    else
    write_data = 32'hZZZZZZZZ;
    end
    endmodule
