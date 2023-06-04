## 计组 Project报告

**廖辰益12111719 罗皓予12112517 李昱纬12112513**

[TOC]



### 分工与占比

| 姓名   | 占比  | 分工                                                 |
| ------ | ----- | ---------------------------------------------------- |
| 李昱纬 | 33.3% | 顶层模块；iFetch，controller模块；汇编代码与上板测试 |
| 廖辰益 | 33.3% | IO模块，拨码开关，灯，数码管，uart通信               |
| 罗皓予 | 33.3% | ALU，decoder，memory，cache，矩阵键盘                |

### 版本修改记录

github截图（ 版 本 号 、 时 间 、 更 新 点 描 述）

### CPU架构设计说明

#### CPU特性 ：

##### ISA

- （ 含 所 有 指 令 （ 指 令 名 、 对 应 编 码 、 使 用 方 式 ） ， 参 考 的 I S A ， 基 于 参 考 I S A 本 次 作 业 所 做 的 更 新 或 优 化 ； 寄 存 器 （ 位 宽 和数 目 ） 等 信 息 ）  
    Minisys32 (即简化版的MIPS指令集架构)。参考lab9课件的指令集，没有进行更新和优化。一共使用32个寄存器，其中\$31是寄存器 ，\$29是sp寄存器,\$0恒为0

- 对 于 异 常 处 理 的 支 持 情 况
    不支持异常处理。

##### 寻 址 空 间 设 计 ：

-  属 于 冯 . 诺 依 曼 结 构 还 是 哈 佛 结 构 ；
    CPU采用了哈佛结构，将指令的储存和数据的储存分成两个单元来实现，避免取指和取数的冲突问题，提高CPU的执行效率。
-  寻 址 单 位 ， 指 令 空 间 、 数 据 空 间 的 大 小 。

   CPU的寻址单位为1字节，指令储存空间的大小为64KB，数据储存空间的大小为64KB.


##### 对 外 设 I O 的 支 持 

-  采 用 单 独 的 访 问 外 设 的 指 令 （ 以 及 相 应 的 指 令 ） 还 是 M M I O （ 以 及 相 关 外 设 对 应 的 地 址 ）

    使用MMIO的方式来访问外设，不同的外设对应着不同的地址，从而对应不同类型的输入和输出。
    | 地址 | 对应的外设 | 类型 |
    | -------- | -------- |-------- |
    | 0xfffffc58| GLD0     |输出|
    | 0xfffffc60| YLD0-YLD7     |输出|
    | 0xfffffc62| RLD0-RLD7     |输出|
    | 0xfffffc66| 七段数码管     |输出|
    | 0xfffffc68| sw8-sw10     |输入|
    | 0xfffffc70| sw0-sw7,sw11(切换)     |输入|
    | 0xfffffc72| sw0-sw7,sw11(切换)     |输入|
    | 0xfffffc74| sw12     |输入|
    
-  采 用 轮 询 还 是 中 断 的 方 式 访 问 I O 。
    
    采用轮询的方式访问IO，在汇编代码中不断循环来实现。
    
#####  C P U 的 C P I

- 属 于 单 周 期 还 是 多 周 期 C P U 
    该CPU属于单周期CPU，CPI为1。

- 是 否 支 持 p i p e l i n e （ 如 支 持 ， 是 几 级 流 水 ， 采 用 什 么 方 式 解 决 的 流 水 线 冲 突 问 题 ）

    不支持pipeline.

#### C P U 接 口 ： 

时 钟 、 复 位 、 u a r t 接 口 （ 可 选 ） 、 其 他 常 用 I O 接 口 使 用 说 明 。

```verilog
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
    input  [3:0] row_in,        //小键盘行信号
    output [3:0] col_out        //小键盘列信号
    );

```

```
#uart相关
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y19} [get_ports rx]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN V18} [get_ports tx]
set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS33 } [get_ports start_pg]

#时钟和复位
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports fpga_clk]
set_property -dict { PACKAGE_PIN P4 IOSTANDARD LVCMOS33 } [get_ports reset]

#拨码开关
set_property -dict { PACKAGE_PIN W4 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN R4 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN T4 IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN T5 IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
set_property -dict { PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
set_property -dict { PACKAGE_PIN U6 IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]
set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {sw[8]}]
set_property -dict { PACKAGE_PIN R6 IOSTANDARD LVCMOS33 } [get_ports {sw[9]}]
set_property -dict { PACKAGE_PIN T6 IOSTANDARD LVCMOS33 } [get_ports {sw[10]}]
set_property -dict { PACKAGE_PIN Y6 IOSTANDARD LVCMOS33 } [get_ports {sw[11]}]
set_property -dict { PACKAGE_PIN AA6 IOSTANDARD LVCMOS33 } [get_ports {sw[12]}]
set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports {sw[13]}]
set_property -dict { PACKAGE_PIN AB6 IOSTANDARD LVCMOS33 } [get_ports {sw[14]}]
set_property -dict { PACKAGE_PIN AB7 IOSTANDARD LVCMOS33 } [get_ports {confirm}]

#led灯
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {leds[0]}]
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports {leds[1]}]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 } [get_ports {leds[2]}]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {leds[3]}]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {leds[4]}]
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports {leds[5]}]
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports {leds[6]}]
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports {leds[7]}]
set_property -dict { PACKAGE_PIN N19 IOSTANDARD LVCMOS33 } [get_ports {leds[8]}]
set_property -dict { PACKAGE_PIN N20 IOSTANDARD LVCMOS33 } [get_ports {leds[9]}]
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports {leds[10]}]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {leds[11]}]
set_property -dict { PACKAGE_PIN K14 IOSTANDARD LVCMOS33 } [get_ports {leds[12]}]
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports {leds[13]}]
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports {leds[14]}]
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports {leds[15]}]
set_property -dict { PACKAGE_PIN A21 IOSTANDARD LVCMOS33 } [get_ports {signal}]

#七段数码管
set_property -dict { PACKAGE_PIN C19 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[0]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[1]}]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[2]}]
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[3]}]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[4]}]
set_property -dict { PACKAGE_PIN B20 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[5]}]
set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[6]}]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports {seg_enables[7]}]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports {segs[0]}]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports {segs[1]}]
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports {segs[2]}]
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports {segs[3]}]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 } [get_ports {segs[4]}]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports {segs[5]}]
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVCMOS33 } [get_ports {segs[6]}]
```

输入端口：

- reset：开发板上的复位信号，高电平有效。
- fpga_clk：开发板的时钟信号，频率为100MHz。
- sw：输入的拨码开关信号，用于选择输入a或b，以及选择相应的测试样例和输入数据。其中，sw[11:11]选择输入a或b，sw[10:8]选择测试样例，低八位为输入的数据。
- confirm：确定信号，在部分测试场景中需要高电平来显示输出数据。
- start_pg：用于切换成UART通信模式的信号。
- rx：UART接收输入信号。

输出端口：

- tx：UART发送输出信号。
- signal：用于判断溢出等特殊情况的信号，高电平表示该情况发生。
- leds：输出到LED灯的数据，为一个16位信号。
- segs：七段数码管显示的数字，为一个7位信号。
- seg_enables：七段数码管的使能信号，为一个8位信号。
- col_out：小键盘列信号，为一个4位信号。

该顶层模块用于实现一个具备拨码开关输入、UART通信、LED灯、七段数码管、小键盘等功能的开发板。

##### uart模块

```verilog
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
```
输入端口：

- upg_clk_i：UART模块的时钟信号，频率为10MHz。
- upg_rst_i：UART模块的复位信号，高电平有效。
- upg_rx_i：UART模块的接收输入信号。

输出端口：

- upg_clk_o：输出给指令内存和数据内存的UART时钟信号。
- upg_wen_o：UART的写使能信号，用于指示是否允许写入内存。
- upg_adr_o：UART写入内存的地址信号。
- upg_dat_o：UART写入内存的数据信号。
- upg_done_o：表明数据传输是否完成的信号。
- upg_tx_o：UART的发送输出信号。

##### 时钟ip核

```verilog
    cpuclk cpuclk1(
    .clk_in1(fpga_clk),     //开发板的顶层时钟
    .clk_out1(cpu_clk),     //各模块工作模式下的时钟
    .clk_out2(upg_clk)      //各模块通信交流模式下的时钟
    );
```

##### 矩阵键盘接口

```
# Keyboard
set_property PACKAGE_PIN L5 [get_ports {col_out[0]}]
set_property PACKAGE_PIN J6 [get_ports {col_out[1]}]
set_property PACKAGE_PIN K6 [get_ports {col_out[2]}]
set_property PACKAGE_PIN M2 [get_ports {col_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {col_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {col_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {col_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {col_out[3]}]

set_property PACKAGE_PIN K3 [get_ports {row_in[0]}]
set_property PACKAGE_PIN L3 [get_ports {row_in[1]}]
set_property PACKAGE_PIN J4 [get_ports {row_in[2]}]
set_property PACKAGE_PIN K4 [get_ports {row_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {row_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {row_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {row_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {row_in[3]}]
```

板子上的矩阵键盘中的[0-9]按键直接对应16进制的[0-9]的输入，[A,B,C,D]按键直接对应16进制的[10-13]的输入，[*,#]按键被设置为对应16进制的[14-15]的输入。

在输入时，点击按键即可输入数据，每次输入4个bit，代表一个16进制的[0-15]。根据项目要求，输入的数据应该是8bit的，因此一次合格的输入应当点击两次按键，输入的两个值会进行合并操作，比如先点击4，再点击9，会获得0x94。当输入位数已经有8bit时，再次点击按钮会从低bit位开始刷新输入，比如先点击4，再点击9，最后点击6，会获得0x96。

拨码开关sw[12:12]用于控制由矩阵键盘或者拨码开关[7:0]来输入数据，1为矩阵键盘，0为拨码开关。

拨码开关sw[13:13]用于控制矩阵键盘的清空，1为矩阵键盘置零，0为未控制矩阵键盘。

#### C P U 内 部 结 构

#####  C P U 内 部 各 子 模 块 的 接 口 连 接 关 系 图





##### C P U 内 部 子 模 块 的 设 计 说 明 （ 模 块 功 能 、 子 模 块 端 口 规 格 及 功 能 说 明 ）

##### ToBoardClock模块

```verilog
module ToBoardClock #(parameter PARAM = 100000)(clk, new_clk,rst);
    input clk;
    input rst;
    output reg new_clk;

```
参数：

- PARAM：参数值，设定为100000。
输入端口：

- clk：时钟信号。
- rst：复位信号。

输出端口：

- new_clk：寄存器类型的新时钟信号。

该模块为较低频率的分频器，用于seg模块和led模块的分频。

##### Decoder模块

```verilog
module decoder32(read_data_1,read_data_2,Instruction,memIO_data,ALU_result,
                 Jal,RegWrite,MemIOtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    output[31:0] read_data_1;               // 输出的第一操作数
    output[31:0] read_data_2;               // 输出的第二操作数
    input[31:0]  Instruction;               // The instruction fetched 
    input[31:0]  memIO_data;   				// DATA taken from the DATA RAM or I/O port for writing data to a specified register
    input[31:0]  ALU_result;   				// The result of an operation from the Arithmetic logic unit ALU used to write data to a specified register
    input        Jal;                       // From the control unit Controller, when the value is 1, it indicates that it is a JAL instruction
    input        RegWrite;                  // From the control unit Controller, when the value is 1, do register write; When the value is 0, no write is performed
    input        MemIOtoReg;                  // From the control unit Controller, indicating that DATA is written to a register after it is removed from the DATA RAM
    input        RegDst;                    //Control write to which specified register in instructions. when RegDst is 1, write to the target register, such as R type Rd; Is 0, writes the second register, such as I type is Rt
    output[31:0] Sign_extend;               // 扩展后的32位立即数
    input		 clock;                     //Clock signal
    input 		 reset;                     //Reset signal, active high level and clear all registers. Writing is not allowed here.
    input[31:0]  opcplus4;                  // The JAL instruction is used to write the return address to the $ra register, what we have got here is PC + 4

```

decoder模块是cpu中的一个重要组成部分，它负责对从内存中取出的指令进行解码，以确定要执行的操作和操作数。decoder模块的输入包括以下信号：

- Instruction：从内存中取出的32位指令。
- memIO_data：从数据内存或I/O端口取出的数据，用于写入指定的寄存器。
- ALU_result：来自算术逻辑单元（ALU）的运算结果，用于写入指定的寄存器。
- Jal：来自控制单元（Controller）的信号，当值为1时，表示是JAL指令。
- RegWrite：来自控制单元的信号，当值为1时，表示要进行寄存器写操作；当值为0时，表示不进行写操作。
- MemIOtoReg：来自控制单元的信号，表示是否要将从数据内存取出的数据写入寄存器。
- RegDst：来自控制单元的信号，表示要写入哪个指定的寄存器。当RegDst为1时，表示写入目标寄存器（如R型指令中的Rd）；当RegDst为0时，表示写入第二寄存器（如I型指令中的Rt）。
- clock：时钟信号。
- reset：复位信号，高电平有效，清除所有寄存器。此时不允许写操作。
- opcplus4：用于JAL指令，将当前PC+4作为返回地址写入$ra寄存器。

decoder模块的输出包括以下信号：

- read_data_1：输出到ALU的第一操作数。
- read_data_2：输出到ALU的第二操作数。
- Sign_extend：扩展后的32位立即数。

decoder模块的子部分主要有以下几个：

- register：一个数组，用于储存32个32位寄存器。这些寄存器用于储存数据或指令地址。
- write_register_address：一个寄存器，用于储存最终要写入的寄存器地址。这个地址由Jal、RegDst和Instruction决定。
- write_data：一个寄存器，用于储存最终要写入的数据。这个数据由Jal、MemIOtoReg、opcplus4、memIO_data和ALU_result决定。
- read_register_1_address：一个寄存器，用于储存Instruction中的rs字段，表示第一操作数所在的寄存器地址。
- read_register_2_address：一个寄存器，用于储存Instruction中的rt字段，表示第二操作数所在的寄存器地址或要写入的寄存器地址（I型指令）。
- write_register_address_1：一个寄存器，用于储存Instruction中的rd字段，表示要写入的目标寄存器地址（R型指令）。
- write_register_address_0：一个寄存器，用于储存Instruction中的rt字段，表示要写入的第二寄存器地址（I型指令）。
- Instruction_immediate_value：一个寄存器，用于储存Instruction中的立即数字段（16位）。
- opcode：一个寄存器，用于储存Instruction中的操作码字段（6位）。
- sign：一个寄存器，用于储存Instruction_immediate_value中最高位（符号位）。

decoder模块主要完成以下功能：

- 根据Instruction中的rs和rt字段，从register数组中读取相应的寄存器值，输出到read_data_1和read_data_2信号。
- 根据opcode和sign，对Instruction_immediate_value进行符号扩展，输出到Sign_extend信号。如果是无符号操作（如ANDI、ORI、XORI、SLTIU），则高16位补0；如果是有符号操作（如ADDI、SLTI等），则高16位补sign。
- 根据Jal、RegDst和Instruction中的rd或rt字段，确定要写入的寄存器地址，输出到write_register_address信号。如果是Jal指令，写入$ra（31号）寄存器；如果是R型指令，写入rd寄存器；如果是I型指令，写入rt寄存器。
- 根据Jal、MemIOtoReg、opcplus4、memIO_data和ALU_result，确定要写入的数据，输出到write_data信号。如果是Jal指令，写入opcplus4作为返回地址；如果是MemIOtoReg为1的指令（如LW、LB等），写入memIO_data作为从内存取出的数据；否则写入ALU_result作为运算结果。
- 根据clock和reset信号，控制register数组中的寄存器是否进行写操作。如果reset为1，清除所有寄存器；如果RegWrite为1，根据write_register_address和write_data信号，将数据写入相应的寄存器。

##### ALU模块

```verilog
module excutes32(
    input[31:0] Read_data_1, //the source of Ainput
    input[31:0] Read_data_2, //one of the sources of Binput
    input[31:0] Sign_extend, //one of the sources of Binput
    // from IFetch
    input[5:0] Opcode, //instruction[31:26]
    input[5:0] Function_opcode, //instructions[5:0]
    input[4:0] Shamt, //instruction[10:6], the amount of shift bits
    input[31:0] PC_plus_4, //pc+4
    // from Controller
    input[1:0] ALUOp, //{ (R_format || I_format) , (Branch || nBranch) }
    input ALUSrc, // 1 means the 2nd operand is an immediate (except beq,bne）
    input I_format, // 1 means I-Type instruction except beq, bne, LW, SW
    input Sftmd, // 1 means this is a shift instruction

    output reg [31:0] ALU_Result, // the ALU calculation result
    output Zero, // 1 means the ALU_reslut is zero, 0 otherwise
    output[31:0] Addr_Result // the calculated instruction address
);
```

ALU模块是cpu中的一个重要组成部分，它负责执行算术和逻辑运算。alu模块的输入包括两个操作数（Ainput和Binput），一个操作码（Opcode），一个功能码（Function_opcode），一个移位量（Shamt），一个pc+4的值（PC_plus_4），以及一些控制信号（ALUOp，ALUSrc，I_format，Sftmd）。alu模块的输出包括运算结果（ALU_Result），零标志（Zero），以及跳转地址（Addr_Result）。

alu模块的子部分主要有以下几个：

- Ainput和Binput生成器：根据输入的数据和控制信号，生成alu运算所需的两个操作数。Ainput直接来自Read_data_1，Binput根据ALUSrc的值来自Read_data_2或Sign_extend。
- Ainput_signed和Binput_signed生成器：根据输入的数据，生成有符号的操作数，用于有符号运算。
- Exe_code生成器：根据输入的操作码和功能码，以及I_format信号，生成用于控制alu运算类型的Exe_code。Exe_code是一个6位的信号，如果是R型指令，则等于功能码；如果是I型指令，则等于{ 3’b000 , Opcode[2:0] }。
- ALU_ctl生成器：根据输入的Exe_code和ALUOp信号，生成用于控制alu内部逻辑电路的ALU_ctl。ALU_ctl是一个3位的信号，根据不同的组合，可以实现不同的算术或逻辑运算。
- Sftm生成器：根据输入的功能码和Sftmd信号，生成用于控制移位类型的Sftm。Sftm是一个3位的信号，等于功能码的低三位。
- Shift_Result生成器：根据输入的Binput，Shamt，Ainput和Sftm信号，生成移位运算的结果。Shift_Result是一个32位的信号，可以实现六种不同类型的移位运算。
- ALU_output_mux生成器：根据输入的Ainput，Binput，Ainput_signed，Binput_signed和ALU_ctl信号，生成算术或逻辑运算的结果。ALU_output_mux是一个32位的信号，可以实现八种不同类型的算术或逻辑运算。
- ALU_Result生成器：根据输入的ALU_output_mux，Exe_code，I_format和Sftmd信号，生成最终的运算结果。ALU_Result是一个32位的信号，可以实现设置类型运算（slt, slti, sltu, sltiu），lui运算和移位运算等。
- Branch_Addr生成器：根据输入的PC_plus_4和Sign_extend信号，生成跳转指令所需的地址。Branch_Addr是一个33位的信号，等于PC_plus_4[31:2]加上Sign_extend[31:0]。
- Addr_Result生成器：根据输入的Branch_Addr信号，生成最终的跳转地址。Addr_Result是一个32位的信号，等于Branch_Addr[31:0]左移两位。
- Zero生成器：根据输入的ALU_output_mux信号，生成零标志。Zero是一个1位的信号，如果ALU_output_mux[31:0]等于零，则为1；否则为0。

##### Memory模块

```verilog
module memory32(
    input clock, // ‘Clock’ signal
    /* used to determine to write the memory unit or not,
    in the left screenshot its name is ‘WE’ */
    input memWrite,
    // the ‘Address’ of memory unit which is to be read/writen
    input[31:0] address,
    // data tobe wirten to the memory unit
    input[31:0] writeData,
    /*data to be read from the memory unit, in the left
    screenshot its name is ‘MemData’ */
    output[31:0] readData,
    input m_strobe,
    output m_ready,
    // UART Programmer Pinouts
    input upg_rst_i, // UPG reset (Active High)
    input upg_clk_i, // UPG ram_clk_i (10MHz)
    input upg_wen_i, // UPG write enable
    input [13:0] upg_adr_i, // UPG write address
    input [31:0] upg_dat_i, // UPG write data
    input upg_done_i // 1 if programming is finished
    );
```

memory模块是cpu中的一个重要组成部分，它负责与数据内存或I/O端口进行通信，以读取或写入数据。memory模块的输入包括以下信号：

- clock：时钟信号。
- memWrite：来自控制单元（Controller）的信号，当值为1时，表示要进行内存写操作；当值为0时，表示要进行内存读操作。
- address：要访问的内存地址（32位）。
- writeData：要写入的数据（32位）。
- m_strobe：来自decoder模块的信号，1表示要进行读或写操作。
- upg_rst_i：UART 编程器的复位信号，当为高电平时进行复位操作。
- upg_clk_i：UART 编程器的时钟信号，频率为 10MHz。
- upg_wen_i：UART 编程器的写使能信号，用于确定是否进行写操作。
- upg_adr_i：UART 编程器的写地址，为一个14位的输入信号。
- upg_dat_i：UART 编程器的写数据，为一个32位的输入信号。
- upg_done_i：UART编程是否完成的信号，当为1时表示编程完成。

memory模块的输出包括以下信号：

- readData：从内存中读取的数据（32位）。
- m_ready：输出到decoder模块的信号，表示内存是否准备好。

memory模块的子模块主要有以下一个：

- RAM：一个IP核，用于实现256个地址×16位的随机存取存储器（RAM）。这个IP核有以下端口：
  - clka：输入时钟信号。
  - wea：输入写使能信号，工作模式下由memWrite和m_strobe决定，通信模式下由upg_wen_i决定。
  - addra：输入地址信号，工作模式下由address[15:2]决定，通信模式下由upg_adr_i决定。
  - dina：输入数据信号，工作模式下由writeData决定，通信模式下由upg_dat_i决定。
  - douta：输出数据信号，输出到readData。

memory模块主要完成以下功能：

- 根据memWrite和m_strobe信号，确定是否要对RAM进行写操作。如果两者都为1，则进行写操作；否则进行读操作。
- 根据address[15:2]信号，确定要访问的RAM地址。由于RAM只有256个地址，所以只需要address的低14位。高18位被忽略。
- 根据writeData信号，确定要写入的RAM数据。如果进行写操作，则将writeData写入RAM中相应的地址。
- 根据readData信号，确定从RAM中读取的数据。如果进行读操作，则将RAM中相应地址的数据读出到readData。
- 根据memWrite信号，确定m_ready信号的值。如果memWrite为1，则m_ready为0；否则m_ready为1。

##### Ifetch32模块

```verilog
module IFetch32(
    output[31:0] Instruction_o, // the instruction fetched from this module to Decoder and Controller
    output reg [31:0] branch_base_addr, // (pc+4) to ALU which is used by branch type instruction
    output reg [31:0] link_addr, // (pc+4) to Decoder which is used by jal instruction
    output [13:0] rom_adr_o,
    //from CPU TOP
    input clock, reset, // Clock and reset
    // from ALU
    input[31:0] Addr_result, // the calculated address from ALU
    input Zero, // while Zero is 1, it means the ALUresult is zero
    // from Decoder
    input[31:0] Read_data_1, // the address of instruction used by jr instruction
    // from Controller
    input Branch, // while Branch is 1,it means current instruction is beq
    input nBranch, // while nBranch is 1,it means current instruction is bnq
    input Jmp, // while Jmp 1, it means current instruction is jump
    input Jal, // while Jal is 1, it means current instruction is jal
    input Jr, // while Jr is 1, it means current instruction is jr
    input [31:0] Instruction //从指令memory传入的值
    );

```



IFetch32模块是一个用于从内存中取指令的模块，它根据不同类型的跳转指令（如beq, bnq, jump, jal, jr等）来更新程序计数器（PC）的值，并将取出的指令发送给译码器和控制器。IFetch32模块有以下几个主要的输入输出信号：

- **Instruction_o**：输出信号，表示从内存中取出的指令。
- **branch_base_addr**：输出信号给ALU，表示当前PC加4的值，用于分支指令的计算。
- **link_addr**：输出信号给Decoder，表示当前PC加4的值，用于jal指令的链接地址。
- **rom_adr_o**：输出信号，下一次从指令memory获取指令得地址。
- **clock**：输入信号，表示时钟信号。
- **reset**：输入信号，表示复位信号。
- **Addr_result**：输入信号，表示从ALU计算出的分支目标地址。
- **Zero**：输入信号，表示ALU计算结果是否为零。
- **Read_data_1**：输入信号，表示从寄存器文件中读出的第一个数据，用于jr指令的跳转地址。
- **Branch**：输入信号，表示当前指令是否为beq指令。
- **nBranch**：输入信号，表示当前指令是否为bnq指令。
- **Jmp**：输入信号，表示当前指令是否为jump指令。
- **Jal**：输入信号，表示当前指令是否为jal指令。
- **Jr**：输入信号，表示当前指令是否为jr指令。
- **Instruction**：输入信号，表示从programrom中传出的指令。
其中，PC和next_PC的更新逻辑如下：

PC用于存储当前正在执行的指令的地址。PC的值在每个时钟周期都会更新，以便从内存中取出下一条指令。

next_PC用于存储下一个时钟周期要更新到PC的值。next_PC的值根据不同类型的指令而变化，有以下几种情况：

- 如果当前指令是普通的非跳转指令，那么next_PC的值就是PC加4，即顺序执行下一条指令。
- 如果当前指令是分支指令（beq或bnq），并且分支条件成立（Zero为1或0），那么next_PC的值就是从ALU计算出的分支目标地址（Addr_result）。
- 如果当前指令是跳转指令（jump或jal），那么next_PC的值就是从指令中提取出的跳转目标地址（Instruction[25:0]），并且将PC加4保存到link_addr中，作为返回地址。
- 如果当前指令是寄存器跳转指令（jr），那么next_PC的值就是从寄存器文件中读出的跳转目标地址（Read_data_1）。

##### programrom模块

```verilog
module programrom(
    input rom_clk_i, // ROM clock
    input[13:0] rom_adr_i, // From IFetch
    output [31:0] Instruction_o, // To IFetch
    // UART Programmer Pinouts
    input upg_rst_i, // UPG reset (Active High)
    input upg_clk_i, // UPG clock (10MHz)
    input upg_wen_i, // UPG write enable
    input[13:0] upg_adr_i, // UPG write address
    input[31:0] upg_dat_i, // UPG write data
    input upg_done_i // 1 if program finished
    );

```
输入端口：

- rom_clk_i：ROM的时钟信号。
- rom_adr_i：来自指令提取（IFetch）模块的地址输入。
- upg_rst_i：UART编程器的复位信号，当为高电平时进行复位操作。
- upg_clk_i：UART编程器的时钟信号，频率为10MHz。
- upg_wen_i：UART编程器的写使能信号，用于确定是否进行写操作。
- upg_adr_i：UART编程器的写地址，为一个14位的输入信号。
- upg_dat_i：UART编程器的写数据，为一个32位的输入信号。
- upg_done_i：编程是否完成的信号，当为1时表示编程完成。

输出端口：

- Instruction_o：向指令提取（IFetch）模块输出的指令数据，为一个32位的输出信号。

programrom模块的子模块主要有以下一个：

- RAM：一个IP核，用于实现256个地址×16位的随机存取存储器（RAM）。这个IP核有以下端口：
  - clka：输入时钟信号。
  - wea：输入写使能信号，工作模式下为低电平，通信模式下由upg_wen_i决定。
  - addra：输入地址信号，工作模式下由rom_adr_i决定，通信模式下由upg_adr_i决定。
  - dina：输入数据信号，工作模式下为低电平，通信模式下由upg_dat_i决定。
  - douta：输出数据信号，输出到readData。

##### controller模块

```verilog
module controller32(
    input[5:0] Opcode, // instruction[31:26], opcode
    input[5:0] Function_opcode, // instructions[5:0], funct
    output Jr , // 1 indicates the instruction is "jr", otherwise it's not "jr" output Jmp; // 1 indicate the instruction is "j", otherwise it's not
    output Jal, // 1 indicate the instruction is "jal", otherwise it's not
    output Jmp,
    output Branch, // 1 indicate the instruction is "beq" , otherwise it's not
    output nBranch, // 1 indicate the instruction is "bne", otherwise it's not
    output RegDST, // 1 indicate destination register is "rd"(R),otherwise it's "rt"(I)
    output RegWrite, // 1 indicate write register(R,I(lw)), otherwise it's not
    output MemWrite, // 1 indicate write data memory, otherwise it's not
    output ALUSrc, // 1 indicate the 2nd data is immidiate (except "beq","bne")
    output Sftmd, // 1 indicate the instruction is shift instruction
    output I_format, // I_format is 1 bit width port
    /* 1 indicate the instruction is I-type but isn't “beq","bne","LW" or "SW" */
    output[1:0] ALUOp, // ALUOp is multi bit width port
    /* if the instruction is R-type or I_format, ALUOp is 2'b10;
if the instruction is“beq” or “bne“, ALUOp is 2'b01；
if the instruction is“lw” or “sw“, ALUOp is 2'b00；*/

    input[21:0] Alu_resultHigh,
    output MemorIOtoReg, //1 indicates that read date from memory or I/O to write to the register
    output MemRead, // 1 indicates that reading from the memory to get data
    output IORead, // 1 indicates I/O read
    output IOWrite // 1 indicates I/O write

);
```

controller32模块是一个用于根据指令的操作码（Opcode）和功能码（Function_opcode）来生成控制信号的模块，这些控制信号用于控制其他模块的行为，如寄存器文件（regfile），执行单元（ALU），存储单元（mem_store）等。controller32模块有以下几个主要的输入输出信号：

- **Opcode**：输入信号，表示指令的操作码，即指令[31:26]位。
- **Function_opcode**：输入信号，表示指令的功能码，即指令[5:0]位。
- **Jr**：输出信号，表示当前指令是否为jr指令。
- **Jmp**：输出信号，表示当前指令是否为jump指令。
- **Jal**：输出信号，表示当前指令是否为jal指令。
- **Branch**：输出信号，表示当前指令是否为beq指令。
- **nBranch**：输出信号，表示当前指令是否为bnq指令。
- **RegDST**：输出信号，表示目标寄存器是rd（R类型指令）还是rt（I类型指令）。
- **RegWrite**：输出信号，表示是否写入寄存器（R类型或I类型的lw指令）。
- **MemWrite**：输出信号，表示是否写入数据内存。
- **ALUSrc**：输出信号，表示第二个操作数是立即数（除了beq和bnq之外的I类型指令）还是寄存器值。
- **Sftmd**：输出信号，表示当前指令是否为移位指令。
- **I_format**：输出信号，表示当前指令是否为I类型但不是beq, bnq, lw或sw指令。
- **ALUOp**：输出信号，表示ALU的操作类型。如果当前指令是R类型或I_format，ALUOp是2’b10；如果当前指令是beq或bnq，ALUOp是2’b01；如果当前指令是lw或sw，ALUOp是2’b00。
- **Alu_resultHigh**：输入信号，表示ALU计算结果的高22位。
- **MemorIOtoReg**：输出信号，表示是否从内存或I/O读取数据写入寄存器。
- **MemRead**：输出信号，表示是否从内存中读取数据。
- **IORead**：输出信号，表示是否从I/O中读取数据。
- **IOWrite**：输出信号，表示是否向I/O中写入数据

controller模块的基本功能是根据指令，对各种信号进行连接。具体逻辑如下：

- 如果当前指令是R类型指令，那么controller32模块会设置RegDST为1，表示目标寄存器是rd；设置RegWrite为1，表示要写入寄存器；设置ALUSrc为0，表示第二个操作数是寄存器值；设置ALUOp为2’b10，表示ALU的操作类型由功能码决定。
- 如果当前指令是I类型指令，那么controller32模块会设置RegDST为0，表示目标寄存器是rt；设置RegWrite为1，表示要写入寄存器；设置ALUSrc为1，表示第二个操作数是立即数；设置ALUOp为2’b10，表示ALU的操作类型由操作码决定；设置I_format为1，表示要进行立即数扩展。
- 如果当前指令是jump指令，那么controller32模块会设置Jmp为1，表示要进行无条件跳转；设置RegWrite为0，表示不写入寄存器。
- 如果当前指令是jal指令，那么controller32模块会设置Jal为1，表示要进行链接跳转；设置RegWrite为1，表示要写入寄存器；设置MemorIOtoReg为0，表示写入寄存器的数据来源于PC加4。
- 如果当前指令是jr指令，那么controller32模块会设置Jr为1，表示要进行寄存器跳转；设置RegWrite为0，表示不写入寄存器。
- 如果当前指令是beq或bnq指令，那么controller32模块会分别设置Branch或nBranch为1，表示要进行有条件跳转；设置ALUSrc为0，表示第二个操作数是寄存器值；设置ALUOp为2’b01，表示ALU要进行减法运算。
- 如果当前指令是lw或sw指令，那么controller32模块会分别设置MemRead或MemWrite为1，表示要从内存中读取或写入数据；设置ALUSrc为1，表示第二个操作数是立即数；设置ALUOp为2’b00，表示ALU要进行加法运算。
- 如果当前指令是移位指令，那么controller32模块会设置Sftmd为1，表示要进行移位运算

##### memorio模块

```verilog
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
```
输入端口：

- mRead：来自控制器的读取存储器的信号。
- mWrite：来自控制器的写入存储器的信号。
- ioRead：来自控制器的读取I/O的信号。
- ioWrite：来自控制器的写入I/O的信号。
- addr_in：来自ALU的结果，用作数据存储器的地址输入。
- m_rdata：从数据存储器读取的数据。
- io_rdata：从I/O读取的数据（16位）。
- r_rdata：从解码器（寄存器文件）读取的数据。

输出端口：

- addr_out：作为数据存储器的地址输出。
- r_wdata：用于解码器（寄存器文件）的数据输入。
- write_data：用于写入存储器或I/O的数据。
- LEDCtrl：用于指示当前LED输出数据的类型的控制信号（3位）。
- SwitchCtrl：用于指示当前拨码开关输入数据的类型的控制信号（4位）。
- SegCtrl：选择七段数码管作为输出的控制信号。

在这个模块中，会判断输出和输入的类型，然后接收相应外设的信号或给相应的外设传输信号。

##### ioRead模块

```verilog
module ioRead(
    input			reset,				// reset, active high 复位信号 (高电平有效)
	  input			ior,				// from Controller, 1 means read from input device(从控制来的I/O使能)
    input	[3:0]       switchctrl,			// 0001读a，0010读b，0100读testcase,1000读确定信号
    input	[7:0]	input_data,	// the data from switch(从外设来的读数据) 
    input   [2:0]        testcase,  //表明当前是哪个测试样例
    input   confirm,                //某些测试样例需要用到的确定信号
    input    ioread_clock,              //更新a,b的时钟
    input           a_or_b,               // 0 for a, 1 for b,拨码开关      
    output	 reg [15:0]	ioread_data 		// the data to memorio (将外设来的数据传给memorio)
    );
```
输入端口：

- reset：复位信号，高电平有效。
- ior：来自控制器的I/O使能信号，当为1时表示从输入设备读取数据。
- switchctrl：拨码开关控制信号，用于确定读取哪个输入设备的数据，具体规则如下：
- 0001：读取输入设备a的数据。
- 0010：读取输入设备b的数据。
- 0100：读取测试用例的数据。
- 1000：读取确定信号的数据。
- input_data：从拨码开关输入的数据。
- testcase：当前的测试样例。
- confirm：某些测试样例需要用到的确定信号。
- ioread_clock：更新输入设备a和b的时钟信号。
- a_or_b：用于选择读取输入设备a或b的信号，0表示读取a，1表示读取b。

输出端口：

- ioread_data：传递给memorio模块的输入设备数据，为一个16位的寄存器输出信号。

该模块用于控制从输入设备读取数据并将其传递给memorio模块。根据switchctrl的配置，可以选择读取输入设备a、b、测试用例或确定信号，并将读取到的数据输出给memorio模块进行处理。

##### led模块

```verilog
module ioRead(
    input			reset,				// reset, active high 复位信号 (高电平有效)
	  input			ior,				// from Controller, 1 means read from input device(从控制来的I/O使能)
    input	[3:0]       switchctrl,			// 0001读a，0010读b，0100读testcase,1000读确定信号
    input	[7:0]	input_data,	// the data from switch(从外设来的读数据) 
    input   [2:0]        testcase,  //表明当前是哪个测试样例
    input   confirm,                //某些测试样例需要用到的确定信号
    input    ioread_clock,              //更新a,b的时钟
    input           a_or_b,               // 0 for a, 1 for b,拨码开关      
    output	 reg [15:0]	ioread_data 		// the data to memorio (将外设来的数据传给memorio)
    );
```
输入端口：

- ledrst：复位信号，高电平有效。
- led_clk：用于LED显示更新的时钟信号。
- led_clk1：用于即将显示的LED数据的更新的时钟信号。
- ledwrite：LED写使能信号，高电平有效。
- high_low：选择更新高位或低位的控制信号。
- extra：溢出等特殊情况的输入信号，高电平有效。
- ledwdata：从寄存器或memorio模块读取的待写入LED显示板的数据。

输出端口：

- signal：显示是否为溢出等特殊情况的信号。
- ledout：写入LED显示板的数据。

该模块用于控制LED的显示。根据时钟信号和写使能信号，将待写入的LED数据根据控制信号进行更新和选择，然后将更新后的数据写入LED显示板。同时，根据特殊情况的输入信号（如溢出等），可能会更新显示信号。

##### seg模块

```verilog
module seg(
    input			segrst,		// reset, active high 
    input			seg_clk,	// 七段数码管扫描的时钟信号
    input           seg_clk1,   //七段数码管更新数据的时钟信号
    input           segctrl,    //是否选择七段数码管作为输出，高电平有效
    input	[15:0]	segwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output  [7:0]   enables,    //七段数码管各位的使能信号
    output	reg [6:0] 	segout,		// the data writen to the segs  of the board
    input cache_enable //用于cache测试
    );

module binaryToHex (
  input [15:0] binary, //输入的二进制数
  output [55:0] segouts //七段数码管每位对应的形状
);

module transfer(
    input [3:0] bi,   //对应的16以内的数
    output reg [6:0] displays //数码管显示的形状
    );
```

输入端口：
- segrst：复位信号，高电平有效。
- seg_clk：七段数码管扫描的时钟信号。
- seg_clk1：七段数码管更新数据的时钟信号。
- segctrl：是否选择七段数码管作为输出的控制信号，高电平有效。
- segwdata：从寄存器或memorio模块读取的待写入七段数码管显示板的数据。
- cache_enable：用于缓存测试的信号。

输出端口：

- enables：七段数码管各位的使能信号，为一个8位信号。
- segout：写入七段数码管显示板的数据，为一个7位寄存器类型信号。

该模块用于控制七段数码管的显示。根据时钟信号和控制信号，将待写入的七段数码管数据根据使能信号进行更新，然后将更新后的数据写入七段数码管显示板。binaryToHex为seg的子模块和transfer为binaryToHex的子模块，这两个模块的作用为让数据正确转换为数码管的显示。

### 测试说明

 以 表 格 的 方 式 罗 列 出 测 试 方 法 （ 仿 真 、 上 板 ） 、 测 试 类 型 （ 单 元 、 集 成 ） 、 测 试 用 例 描 述 、 测 试 结 果 （ 通 过 、 不 通 过 ） ； 以 及最 终 的 测 试 结 论 

#### 测试场景一

| 测试编号 | 测试方法 | 测试类型 | 测试用例表述 | 测试结果 |
| -------- | -------- | -------- | ------------ | -------- |
| 000      | 上板     | 集成     | 8’h01, 8'h03  | 通过     |
| 001      | 上板     | 集成     | 8'h07, 8'h06  | 通过     |
| 010      | 上板     | 集成     | 8'ha2, 8'h24  | 通过     |
| 011      | 上板     | 集成     | 8'ha2, 8'h24  | 通过     |
| 100      | 上板     | 集成     | 8'ha2, 8'h24  | 通过     |
| 101      | 上板     | 集成     | 8'ha2, 8'h24  | 通过     |
| 110      | 上板     | 集成     | 8'ha2, 8'h24  | 通过     |
| 111      | 上板     | 集成     | 8'ha2, 8'h24  | 通过     |

#### 测试场景二

| 测试编号 | 测试方法 | 测试类型 | 测试用例表述 | 测试结果 |
| -------- | -------- | -------- | ------------ | -------- |
| 000      | 上板     | 集成     | 8'h05, 8'hff             | 通过     |
| 001      | 上板     | 集成     | 8'h06             | 通过     |
| 010      | 上板     | 集成     | 8'h06             | 通过     |
| 011      | 上板     | 集成     | 8'h06             | 通过     |
| 100      | 上板     | 集成     | ①8'hff, 8'h07 ②8'hff, 8'h10            | 通过     |
| 101      | 上板     | 集成     | ①8'hff, 8'h07 ②8'h00, 8'h10             | 通过     |
| 110      | 上板     | 集成     | ①8'hfe, 8'h07 ②8'hfe, 8'hfa             | 通过     |
| 111      | 上板     | 集成     | ①8'h0e, 8'h04 ②8'hf5, 8'h02             | 通过     |

#### 测试结论

基本测试场景的测试样例全部通过，CPU的指令集、各模块之间的数据传输均已圆满实现


### bonus 对应功能点的设计说明

#### 设计思路及与周边模块的关系

##### cache模块与周边模块

```verilog
wire cache_ready;
wire [31:0] cache_addr;
wire [31:0] cache_readdata;
wire [31:0] cache_writedata;
wire cache_strobe;
wire cache_rw;
wire m_ready;

reg[15:0] hitcnt;
cache cache(
    .clk(clock),
    .resetn(reset),
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
    .clock(clock),
    .memWrite(cache_rw),
    .address(cache_addr),
    .writeData(cache_writedata),
    .readData(cache_readdata),
    .m_strobe(cache_strobe),
    .m_ready(m_ready)
);
```

- cache大小为32位地址空间的1/4（2^10个块），每个块大小为32位（一个字）。
- cache采用直接映射方式，即内存地址的低10位作为索引（index），高20位作为标记（tag）。
- cache采用写直达法，即每次修改cache中的数据时，同时写入内存。

与周边模块的关系如下：

- cache模块与处理器（CPU）之间通过p_a, p_dout, p_din, p_strobe, p_rw, p_ready等信号进行通信。其中p_a表示处理器要访问的内存地址，p_dout表示处理器要写入的数据，p_din表示处理器要读取的数据，p_strobe表示处理器是否要进行读或写操作，p_rw表示处理器要进行的操作类型（0为读，1为写），p_ready表示cache是否准备好响应处理器的请求。
- cache模块与内存（memory）之间通过m_a, m_dout, m_din, m_strobe, m_rw, m_ready等信号进行通信。其中m_a表示cache要访问的内存地址，m_dout表示内存返回给cache的数据，m_din表示cache要写入内存的数据，m_strobe表示cache是否要进行读或写操作，m_rw表示cache要进行的操作类型（0为读，1为写），m_ready表示内存是否准备好响应cache的请求。

##### 矩阵键盘与周边模块

```verilog
wire press;
wire [3:0] keyboard_val;

keypad keypad(
    .clk(clock),
    .rst_n(reset),
    .row_in(row_in),
    .col_out(col_out),
    .press(press),
    .keyboard_val(keyboard_val)
);

reg[1:0] counter = 2'b00;
wire inputChoose = sw[12:12];
wire keypadClear = sw[13:13];
reg [24:0] cnt;      
wire k_clk;

// 分频
always @ (posedge pclk or posedge reset)
    if (reset)
        cnt <= 0;
else
    cnt <= cnt + 1'b1;

assign k_clk = cnt[24]; 

always @(posedge k_clk or posedge reset or posedge keypadClear) begin
    if(reset) begin
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
```

在top模块里，矩阵键盘获取输入值并传给MemorIO模块的代码部分主要完成以下功能：

- 实例化一个keypad模块，并将其clk、rst_n、row_in和col_out端口分别连接到clock、reset、row_in和col_out信号。将其press和keyboard_val端口分别连接到press和keyboard_val信号。
- 定义一个2位的计数器counter，用于记录按键的个数。
- 定义一个信号inputChoose，用于选择输入数据的来源。如果inputChoose为1，则选择矩阵键盘的输入；如果inputChoose为0，则选择开关的输入。
- 定义一个信号keypadClear，用于清除矩阵键盘的输入。
- 定义一个25位的计数器cnt，用于产生一个较慢的时钟信号k_clk。k_clk的频率是pclk（像素时钟）频率除以2^25。
- 根据k_clk或reset或keypadClear信号，更新keypadread_data和counter信号。如果reset为1，则复位keypadread_data和counter；如果keypadClear为1，则清除keypadread_data和counter；如果press为1，则根据counter的值，将keyboard_val的4位值存入keypadread_data的相应位置，并将counter加1；如果counter大于10，则将counter复位为0。
- 根据inputChoose信号，确定input_data[7:0]的值。如果inputChoose为1，则将input_data[7:0]设为keypadread_data[7:0]；如果inputChoose为0，则将input_data[7:0]设为sw[7:0]。

#### 核心代码及必要说明

##### Cache模块

```verilog
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
```

cache模块是cpu中的一个重要组成部分，它负责缓存主存中的数据和指令，以减少cpu访问主存的平均时间。[1](https://zh.wikipedia.org/zh-tw/CPU缓存) cache模块的输入包括以下信号：

- p_a：来自cpu的内存地址，用于访问缓存或主存中的数据或指令。
- p_dout：来自cpu的数据，用于写入缓存或主存。
- p_strobe：来自cpu的控制信号，1表示要进行读或写操作。
- p_rw：来自cpu的控制信号，0表示读操作，1表示写操作。
- m_dout：来自主存的数据，用于读取或写入缓存。
- m_ready：来自主存的控制信号，表示主存是否准备好。

cache模块的输出包括以下信号：

- p_din：输出到cpu的数据，用于返回缓存或主存中的数据或指令。
- p_ready：输出到cpu的控制信号，表示缓存是否准备好。
- m_a：输出到主存的内存地址，用于访问主存中的数据或指令。
- m_din：输出到主存的数据，用于写入主存。
- m_strobe：输出到主存的控制信号，1表示要进行读或写操作。
- m_rw：输出到主存的控制信号，0表示读操作，1表示写操作。
- hitcnt：输出到外部的计数器，记录缓存命中的次数。

cache模块的子部分主要有以下几个：

- d_valid：一个数组，用于储存每个缓存块（cache block）是否有效（valid）的信息。有效表示该缓存块中储存了主存中对应地址的数据或指令。无效表示该缓存块中没有储存任何数据或指令。
- d_tags：一个数组，用于储存每个缓存块对应的标签（tag）信息。标签是内存地址中除了索引（index）和偏移（offset）之外的高位部分。标签用于判断缓存中储存的数据或指令是否与内存地址匹配。
- d_data：一个数组，用于储存每个缓存块中实际储存的数据或指令。每个缓存块可以储存多个字（word）或双字（dword）等单位的数据或指令。
- index：一个线路，用于从p_a信号中提取索引信息。索引是内存地址中除了标签和偏移之外的低位部分。索引用于定位缓存中对应的缓存块位置。
- tag：一个线路，用于从p_a信号中提取标签信息。标签用于与d_tags数组中储存的标签进行比较，判断是否命中（hit）或未命中（miss）。
- valid：一个线路，用于从d_valid数组中根据index提取对应缓存块是否有效的信息。有效表示该缓存块可以被访问或替换。无效表示该缓存块可以被分配或忽略。
- tagout：一个线路，用于从d_tags数组中根据index提取对应缓存块储存的标签信息。tagout与tag进行比较，判断是否命中或未命中。
- c_dout：一个线路，用于从d_data数组中根据index提取对应缓存块储存的数据或指令。c_dout可以输出到p_din信号，返回给cpu。
- cache_hit：一个线路，用于表示缓存是否命中。命中表示缓存中储存了cpu请求的数据或指令，可以直接返回给cpu。未命中表示缓存中没有储存cpu请求的数据或指令，需要从主存中读取或写入。
- cache_miss：一个线路，用于表示缓存是否未命中。未命中表示缓存中没有储存cpu请求的数据或指令，需要从主存中读取或写入。命中表示缓存中储存了cpu请求的数据或指令，可以直接返回给cpu。
- c_write：一个线路，用于表示是否要对缓存进行写操作。写操作包括两种情况：一是cpu要求写入数据或指令到缓存；二是缓存未命中且主存准备好时，要从主存读取数据或指令到缓存。
- Branch_Addr：一个线路，用于计算跳转指令所需的地址。Branch_Addr等于PC_plus_4信号加上Sign_extend信号。
- Addr_Result：一个线路，用于输出最终的跳转地址。Addr_Result等于Branch_Addr左移两位。
- Zero：一个线路，用于表示缓存输出的数据或指令是否为零。Zero为1表示c_dout为零；Zero为0表示c_dout不为零。

##### 矩阵键盘模块

```verilog
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
```

keypad模块是cpu中的一个重要组成部分，它负责从一个4x4的矩阵键盘中读取输入，并产生相应的按键事件。keypad模块的输入包括以下信号：

- clk：时钟信号。
- rst_n：复位信号，低电平有效。
- row_in：行输入，表示键盘的4个行信号。
- col_out：列输出，表示键盘的4个列信号。
- press：按键事件信号，表示是否有按键被按下。
- keyboard_val：按键值信号，表示被按下的按键对应的4位值。

keypad模块的输出包括以下信号：

- press：按键事件信号，表示是否有按键被按下。
- keyboard_val：按键值信号，表示被按下的按键对应的4位值。

keypad模块的子模块主要有以下几个：

- cnt：一个计数器，用于产生一个较慢的时钟信号key_clk，该时钟信号用于控制键盘扫描的速度。key_clk的频率是主时钟频率除以2^20。
- key_clk：一个较慢的时钟信号，由cnt产生。
- current_state和next_state：两个状态变量，用于储存和更新状态机的当前状态和下一个状态。状态机有6个状态，分别是NO_KEY_PRESSED（无按键被按下）、SCAN_COL0（扫描第0列）、SCAN_COL1（扫描第1列）、SCAN_COL2（扫描第2列）、SCAN_COL3（扫描第3列）和KEY_PRESSED（有按键被按下）。
- key_pressed_flag：一个标志位，用于指示是否检测到了按键事件。
- col_val和row_val：两个寄存器，用于储存被扫描到的列值和行值。

keypad模块主要完成以下功能：

- 根据key_clk或rst_n信号，更新状态机的当前状态。如果rst_n为1，则复位状态机；否则根据next_state更新当前状态。
- 根据当前状态和row_in信号，确定状态机的下一个状态。如果当前状态是NO_KEY_PRESSED，则根据row_in是否为1111来判断是否有按键被按下；如果有，则转移到SCAN_COL0状态；如果没有，则保持在NO_KEY_PRESSED状态。如果当前状态是SCAN_COL0、SCAN_COL1、SCAN_COL2或SCAN_COL3，则根据row_in是否为1111来判断是否有按键被按下；如果有，则转移到KEY_PRESSED状态；如果没有，则转移到下一个扫描列的状态。如果当前状态是KEY_PRESSED，则根据row_in是否为1111来判断是否有按键被松开；如果有，则转移到NO_KEY_PRESSED状态；如果没有，则保持在KEY_PRESSED状态。
- 根据key_clk或rst_n信号，更新col_out和key_pressed_flag信号。如果rst_n为1，则复位col_out和key_pressed_flag；否则根据next_state更新它们。如果next_state是NO_KEY_PRESSED，则将col_out设为0000，表示没有列被选中；将key_pressed_flag设为0，表示没有按键事件。如果next_state是SCAN_COL0、SCAN_COL1、SCAN_COL2或SCAN_COL3，则将col_out设为相应的值，表示选中相应的列。如果next_state是KEY_PRESSED，则将col_val设为col_out的值，表示保存被扫描到的列值；将row_val设为row_in的值，表示保存被扫描到的行值；将key_pressed_flag设为1，表示产生按键事件。
- 根据key_clk或rst_n信号，更新keyboard_val信号。如果rst_n为1，则复位keyboard_val；否则根据key_pressed_flag更新它。如果key_pressed_flag为1，则根据col_val和row_val的组合，解码出被按下的按键对应的4位值，并赋给keyboard_val。如果key_pressed_flag为0，则将keyboard_val设为0000，表示没有按键被按下。
- 将press信号赋值为key_pressed_flag，表示是否有按键事件。

#### bonus测试说明：测试场景说明，测试用例，测试结果及说明。

##### cache模块

测试用硬件代码：

```verilog
initial begin
        hitcnt = 0;
    end

    always @(posedge cache_hit or negedge resetn) begin
        if (resetn == 1'b0)
            hitcnt <= 0;
        else if (cache_hit == 1'b1)
        hitcnt <= hitcnt + 1;
    end
```

测试用汇编代码：

```assembly
.data 0x0000 # data* is 4bytes, its initial value is 0
buf: .word 0x0000
.text 0x0000 # instructions

start:
lw $1,0x0000($0)
lw $2,0x0004($0)
lw $3,0x0008($0)
lw $4,0x000C($0)

lw $5,0x0000($0)
lw $7,0x0004($0)
```

测试结果：

hit次数的结果显示为2，与预期结果一致。

##### 矩阵键盘模块

使用矩阵键盘作为输入接口测试第一个测试场景的结果，详情见bonus视频。

| 测试编号 | 测试方法 | 测试类型 | 测试用例表述 | 测试结果 |
| -------- | -------- | -------- | ------------ | -------- |
| 000      | 上板     | 集成     | 8’h01, 8'h03 | 通过     |
| 001      | 上板     | 集成     | 8'h07, 8'h06 | 通过     |
| 010      | 上板     | 集成     | 8'ha2, 8'h24 | 通过     |
| 011      | 上板     | 集成     | 8'ha2, 8'h24 | 通过     |
| 100      | 上板     | 集成     | 8'ha2, 8'h24 | 通过     |
| 101      | 上板     | 集成     | 8'ha2, 8'h24 | 通过     |
| 110      | 上板     | 集成     | 8'ha2, 8'h24 | 通过     |
| 111      | 上板     | 集成     | 8'ha2, 8'h24 | 通过     |

### 问题及总结

开 发 过 程 中 遇 到 的 问 题 、 思 考 、 总 结 。

#### 遇到的问题

##### 1.ALU signed问题

在设计ALU模块时，我们遇到了部分操作需要区分有符号数和无符号数的问题，因此我们设计了两条signed wire Ainput_signed和Binput_signed，根据输入的数据，生成有符号的操作数，用于有符号运算。这样的设计，可以不用在每个需要有符号的操作的地方调用signed函数来进行转化，可以直接使用Ainput_signed和Binput_signed，简化了设计。

##### 2.seg时钟问题

在seg模块中，一开始我更新seg模块的数据和更新使能信号时的时钟用了同一个，结果出现显示数字不稳定以及“鬼影”的现象。后面我将数据更新的时钟信号更改为CPU的时钟，就解决了这个问题。

#### 思考与总结

在设计和实现的过程当中，为其他成员提供丰富且清晰的代码注释，可以提高小组合作的流程性和代码的持续可用性。
