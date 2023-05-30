`include "public.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/20 10:39:40
// Design Name: 
// Module Name: top
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


module top(
    input  reset,               // 开发板上的Reset信号，高电平有效
    input  fpga_clk,               // 开发板的时钟信号，100MHZ
    input [14:0] sw,    // 用于输入的拨码开关，sw[11:11]为选择输入a或b，sw[10:8]为选择相应的测试样例，低八位为输入的数据。
    input confirm,       //确定信号，在部分测试场景中需要该信号的高电平来显示输出数据
    input start_pg,     //用于切换成uart通信模式的信号
    input rx,           //uart输入信号
    output tx,          //uart输出信号
    output signal,      //用于判断溢出等特殊情况的信号,高电平表示该情况发生
    output [15:0] leds,        // 输出到led灯的数据
    output [6:0] segs,          //七段数码管显示的数字
    output [7:0] seg_enables,  //七段数码管的使能信号
    input  [3:0] row_in,
    output [3:0] col_out
    );

    //各模块所需时钟
    wire cpu_clk,seg_clk,led_clk;
    //各模块些使能
    wire mWrite,rWrite,ioWrite;
    //各模块读使能
    wire mRead,ioRead;
    //连接各模块的接线
    wire [31:0] address;
    wire [31:0] readdata;
    wire [31:0] instruction, instruction_o;
    wire jr,jal,jmp,beq,bnq;
    wire regdst;
    wire alusrc;
    wire sftmd;
    wire i_format;
    wire [1:0] aluop;
    wire [31:0] aluresult;
    wire [13:0] rom_adr_o;
    wire MemorIOtoReg;
    wire [31:0] read_data_1,read_data_2;
    wire [31:0] memio_data;
    wire [31:0] sign_extend;
    wire [31:0] opcplus4;
    wire [31:0] branch_base_addr;
    wire [31:0] addr_result;
    wire zero;
    wire [15:0] ioread_data;
    wire [31:0] write_data;
    wire [7:0] input_data;

    //区分输入和输出数据的种类
    wire [2:0]ledctrl;
    wire segctrl;
    wire [3:0] switchctrl;
   
    // UART Programmer Pinouts
    wire upg_clk, upg_clk_o;
    wire upg_wen_o; //Uart write out enable
    wire upg_done_o; //Uart rx data have done
    //data to which memory unit of program_rom/dmemory32
    wire [14:0] upg_adr_o;
    //data to program_rom or dmemory32
    wire [31:0] upg_dat_o;
    wire spg_bufg;
    BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter
    // Generate UART Programmer reset signal
    reg upg_rst;
    always @ (posedge fpga_clk) begin
    if (spg_bufg) upg_rst = 1'b0;   
    if (reset) upg_rst = 1'b1;
    end
    //used for other modules which don't relate to UART，高电平有效
    wire rst;
    assign rst = reset | !upg_rst;

    
    uart_bmpg_0 ub0(
    .upg_clk_i(upg_clk),   //uart的时钟（10MHZ）
    .upg_rst_i(upg_rst),    //uart的复位信号，高电平有效
    .upg_rx_i(rx),          //uart的rx信号
    .upg_clk_o(upg_clk_o),  //uart输出到指令memory和数据memory的时钟信号
    .upg_wen_o(upg_wen_o),  //uart的写使能信号
    .upg_adr_o(upg_adr_o),  //uart写入memory的地址
    .upg_dat_o(upg_dat_o),  //uart写入memory的数据
    .upg_done_o(upg_done_o),    //表明数据是否传输完成
    .upg_tx_o(tx)           //uart的输出信号
    );

    cpuclk cpuclk1(
    .clk_in1(fpga_clk),     //开发板的顶层时钟
    .clk_out1(cpu_clk),     //各模块工作模式下的时钟
    .clk_out2(upg_clk)      //各模块通信交流模式下的时钟
    );

    ToBoardClock #(10000) tbc_seg(
    .clk(fpga_clk),     
    .rst(rst),
    .new_clk(seg_clk)    // 用于seg扫描、使能信号变更的时钟信号
    );

    ToBoardClock #(100000) tbc_led(
     .clk(fpga_clk),
     .rst(rst),
     .new_clk(led_clk)    //用于led显示的时钟信号
     );

    controller32 ctl(
    .Opcode(instruction[31:26]),    //指令高六位，判断指令类型
    .Function_opcode(instruction[5:0]), //指令低六位，用于R型指令的function_code
    .Jr(jr),    //是否为jr指令
    .Jal(jal),  //是否jal指令
    .Jmp(jmp),  //是否为jump指令
    .Branch(beq),   //是否为beq指令
    .nBranch(bnq),  //是否为bnq指令
    .RegDST(regdst),    //传给decoder32，表明目标寄存器是哪一个
    .RegWrite(rWrite),  //寄存器写使能
    .MemWrite(mWrite),  //数据memory写使能
    .ALUSrc(alusrc),    //第二个数据是否为立即数
    .Sftmd(sftmd),      //是否位移位指令
    .I_format(i_format),    //是否为I型指令
    .ALUOp(aluop),          //是否为branch指令或访存指令
    .Alu_resultHigh(aluresult[31:10]),
    .MemorIOtoReg(MemorIOtoReg), //写寄存器使能
    .MemRead(mRead),        //数据memory读使能
    .IORead(ioRead),        //io读使能
    .IOWrite(ioWrite)       //io写使能
    );

    decoder32 deco(
    .read_data_1(read_data_1),  // 从第一个寄存器读出的数据（rs）
    .read_data_2(read_data_2),  // 从第二个寄存器读出的数据（rt）
    .Instruction(instruction), // 来自取指模块
    .memIO_data(memio_data),   // 来自memorio模块，从DATA RAM or I/O port取出的数据?
    .ALU_result(aluresult),  // 来自ALU模块，需要扩展立即数为32位?
    .Jal(jal),              // 来自controller，指令是不是JAL
    .RegWrite(rWrite),         // 来自controller，寄存器写使能
    .MemIOtoReg(MemorIOtoReg),     //来自controller 数据来源是不是MEM
    .RegDst(regdst),           // 来自controller，为1说明目标寄存器是rd，否则是rt
    .Sign_extend(sign_extend),  // 立即数扩展的结果
    .clock(cpu_clk),              //23Mhz
    .reset(rst),              //工作模式复位信号
    .opcplus4(opcplus4)         // The JAL instruction is used to write the return address to the $ra register, what we have got here is PC + 4
    );

    programrom pg1(
    .rom_clk_i(cpu_clk),            //工作模式的时钟
    .rom_adr_i(rom_adr_o),          //来自IFetch32模块
    .upg_rst_i(upg_rst),            //通信模式的复位信号，高电平有效
    .upg_clk_i(upg_clk_o),          //通信模式的时钟
    .upg_wen_i(upg_wen_o & (!upg_adr_o[14])),   //通信模式往指令memory写入的使能
    .upg_adr_i(upg_adr_o[13:0]),    //通信模式时要写入的地址
    .upg_dat_i(upg_dat_o),          //通信模式时要写入的数据
    .upg_done_i(upg_done_o),        //是否完成写入
    .Instruction_o(instruction_o)   //从指令memory里获取的32位指令，传入IFetch32模块
    );

    IFetch32 IF(
    .Instruction_o(instruction),  //传给decoder的32位指令
    .branch_base_addr(branch_base_addr), //输出到ALU，branch指令时的PC+4
    .Addr_result(addr_result),   //来自ALU，branch指令需要跳转到的地址
    .Read_data_1(read_data_1),  //来自decoder，jr指令更新PC时用的地址
    .Branch(beq),           //来自controller，是否为beg指令
    .nBranch(bnq),         //来自controller，是否为bnq指令
    .Jmp(jmp),                 //来自controller，是否为jump指令
    .Jal(jal),                 //来自controller，是否为jal指令
    .Jr(jr),                    //来自controller，是否为jr指令
    .Zero(zero),              //来自controller，表明alu_result的值是否为0
    .clock(cpu_clk),            //来自cpuclk，工作模式时钟信号
    .reset(rst),            //工作模式复位信号，高电平有效
    .link_addr(opcplus4),    //输出到decoder，用于jal指令时的PC+4
    .Instruction(instruction_o), //从programrom模块传入
    .rom_adr_o(rom_adr_o)   //下一次从指令memory获取指令得地址
    );

    excutes32 exc(
    .Read_data_1(read_data_1),		// 来自decoder, r-form rs 从译码单元是Read_data_1中来
    .Read_data_2(read_data_2),		// 来自decoder，r-form rt 从译码单元是Read_data_2中来
    .Sign_extend(sign_extend),		// 来自decoder，i-form 译码单元来的扩展后的立即数?
    .Function_opcode(instruction[5:0]),  // 来自取指模块，r-form instructions[5..0] 取指单元来的R型的Func
    .Opcode(instruction[31:26]),  		// 来自取指模块，opcode 取址单元来的Op
    .ALUOp(aluop),            // 控制单元来的ALUOp，第2级控制（LW/SW 00，BEQ/BNE 01，R/I ）?
    .Shamt(instruction[10:6]),            // 来自取指模块，移位量
    .Sftmd(sftmd),            // 来自控制单元，是否是移位指令
    .ALUSrc(alusrc),           // 来自控制单元，表明第二个操作数是否为立即数（beq、bne除外）?
    .I_format(i_format),         // 该指令是除了beq、bne、lw、sw以外的其他I类型指令
    .Zero(zero),             // Zero Flag
    .ALU_Result(aluresult),       // 执行单元的最终运算结果?
    .Addr_Result(addr_result),		// 计算的地址结果       
    .PC_plus_4(branch_base_addr)         // 来自取指单元的PC+4    
    );

    memorio memorio1(
    .mRead(mRead),    //来自控制单元，读内存使能
    .mWrite(mWrite),   //来自控制单元，写内存使能
    .ioRead(ioRead),     //来自控制单元，io读输入使能
    .ioWrite(ioWrite),   //来自控制单元，io写输入使能
    .addr_in(aluresult),         //来自alu，alu的结果
    .addr_out(address),           //数据内存的地址
    .m_rdata(readdata),            //来自数据内存的数据
    .io_rdata(ioread_data),           //来自拨码开关输入的数据  
    .r_wdata(memio_data),            //要写入decoder的数据
    .r_rdata(read_data_2),            //读来自decoder的数据
    .write_data(write_data),         //输出外设要显示的数据
    .LEDCtrl(ledctrl),            //表明当前led灯是否显示且显示哪种类型的数据
    .SwitchCtrl(switchctrl),          //表明当前拨码开关输入的是哪种类型的数据
    .SegCtrl(segctrl)               //是否选择七段数码管作为输出外设
    );

    leds led16(
    .ledrst(rst),   //工作模式复位信号
    .led_clk(led_clk),  //led灯更新显示的频率
    .led_clk1(cpu_clk), //led灯更新即将显示数据的频率
    .ledwrite(ioWrite), //来自控制模块
    .high_low(ledctrl[1:0]),    //表明是否更新led灯的高8位和低8位，来自memorio模块
    .extra(ledctrl[2:2]),       //表明传入的数据是否为溢出等特殊情况时的，来自memorio模块
    .ledwdata(write_data[15:0]),//传入led的数据，来自memorio模块
    .signal(signal),            //顶层模块输出
    .ledout(leds)               //16位输出与顶层输出相连
    );
    
    ioRead ioR(
    .reset(rst),    //工作模式复位信号，高电平有效
    .ior(ioRead),   //来自controller模块
    .switchctrl(switchctrl),    //来自memorio模块，表明目前需要传输的数据的类型
    .testcase(sw[10:8]),        //顶层输入，用于表示测试样例号
    .input_data(input_data),   //顶层输入，表明输入的数据
    .ioread_data(ioread_data),      //传到memorio模块的数据
    .a_or_b(sw[11:11]),               //顶层输入，高电平表明输入的为b，否则为a
    .ioread_clock(cpu_clk),             //工作模式更新的频率  
    .confirm(confirm)               //顶层输入，确定信号
    );

    wire[15:0] hitcnt;
    seg seg7(
    .segrst(rst),  //工作模式复位信号，高电平有效
    .seg_clk(seg_clk), //扫描时钟信号
    .seg_clk1(cpu_clk), //更新数据的时钟信号
    .segctrl(segctrl),  //来自memorio模块，是否需要输出到七段数码管上
    .cache_enable(sw[14]),
    .segwdata(sw[14] ? hitcnt : write_data[15:0]),    //来自memorio模块传入seg的数据
    .enables(seg_enables),          //输出到顶层,使能信号
    .segout(segs)                   //输出到顶层,七段数码管显示
    );

    //小键盘
    wire press;
    wire [3:0] keyboard_val;

    keypad keypad(
    .clk(cpu_clk),
    .rst_n(rst),
    .row_in(row_in),    //行信号
    .col_out(col_out),  //列信号
    .press(press),      //是否按下
    .keyboard_val(keyboard_val) //小键盘按下的值
    );

    reg[1:0] counter = 2'b00;
    wire inputChoose = sw[12:12];
    wire keypadClear = sw[13:13];
    reg [24:0] cnt;      
    wire k_clk;
    reg [7:0] keypadread_data;
    
    /////////// 分频
    always @ (posedge fpga_clk or posedge rst)
    if (rst)
        cnt <= 0;
    else
        cnt <= cnt + 1'b1;
        
    assign k_clk = cnt[24]; 

    always @(posedge k_clk or posedge rst or posedge keypadClear) begin
        if(rst) begin
            keypadread_data <= 8'h00;
            counter <= 2'b00;
        end
        else if (keypadClear) begin
            keypadread_data <= 8'h00;
            counter <= 2'b00;
        end
        else if(press) begin
            if(counter <= 2'b10) begin
                counter <= counter + 1;
                keypadread_data[4 * counter - 4] <= keyboard_val[0];
                keypadread_data[4 * counter - 3] <= keyboard_val[1];
                keypadread_data[4 * counter - 2] <= keyboard_val[2];
                keypadread_data[4 * counter - 1] <= keyboard_val[3];
            end
            else begin
                counter <= 2'b00;
            end
        end
    end

    assign input_data[7:0] = inputChoose ? keypadread_data[7:0] : sw[7:0];



    //cache部分
    wire cache_ready;
    wire [31:0] cache_addr;
    wire [31:0] cache_readdata;
    wire [31:0] cache_writedata;
    wire cache_strobe;
    wire cache_rw;
    wire m_ready;

 

    //p开头的端口接memorio,m开头的端口接memory
    //_ready说明是否准备好，_rw和_strobe共同判断是否需要操作
    cache cache(
        .clk(cpu_clk),
        .resetn(rst),
        .p_a(address), 
        .p_dout(write_data),
        .p_din(readdata),
        .p_strobe(mWrite||mRead),
        .p_rw(mWrite),
        .p_ready(cache_ready),
        .m_a(cache_addr),
        .m_dout(cache_readdata),
        .m_din(cache_writedata),
        .m_strobe(cache_strobe),
        .m_rw(cache_rw),
        .m_ready(m_ready),
        .hitcnt(hitcnt)
    );

    memory32 mem(
    .clock(cpu_clk),
    .memWrite(cache_rw),
    .address(cache_addr),
    .writeData(cache_writedata),
    .readData(cache_readdata),
    .m_strobe(cache_strobe),
    .m_ready(m_ready),
    .upg_rst_i(upg_rst),       //通信模式的复位信号，高电平有效
    .upg_clk_i(upg_clk_o),      //通信模式的时钟
    .upg_wen_i(upg_wen_o & upg_adr_o[14]), //通信模式往数据memory写入的使能
    .upg_adr_i(upg_adr_o[13:0]),    //通信模式时要写入的地址
    .upg_dat_i(upg_dat_o),          //通信模式时要写入的数据
    .upg_done_i(upg_done_o)     //是否完成写入
    );

endmodule
