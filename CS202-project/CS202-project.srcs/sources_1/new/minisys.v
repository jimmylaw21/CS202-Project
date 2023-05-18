`include "public.v"

module minisys(
    input wire reset,               // 板上的Reset信号，低电平复位
    input wire pclk,               // 板上�?100MHz时钟信号
    input wire[11:0] ioread_data_switch,    // 拨码�?关输�?
    input [3:0]key_col,            //小键盘列信号
    input selectInput,             //0为拨码开关，1为小键盘
    input commucation_mode,        //uart交流模式
    input working_mode,           //工作模式
    output [11:0] leds,        // led结果输出到Nexys4
    output [6:0] segs,          //七位数码管显示的数字
    output [7:0] seg_enables,      //七位数码管的使能信号
    output [3:0] key_row            //小键盘行信号
);

    wire clock, led_clk, seg_clk;              // clock: 分频后时钟供给系�?
    wire iowrite,ioread;     // I/O读写信号
    wire[31:0] write_data;   // 写RAM或IO的数�?
    wire[31:0] rdata;        // 读RAM或IO的数据写入decoder
    wire[15:0] ioread_data,ioread_data1,ioread_data2;  // 读IO的数�?
    wire[31:0] pc_plus_4;    // PC+4
    wire[31:0] read_data_1;  // decoder的输�?
    wire[31:0] read_data_2;  // decoder的输�?
    wire[31:0] sign_extend;  // 符号扩展
    wire[31:0] add_result;   // 执行单元的最终运算结�?
    wire[31:0] alu_result;   // alu的计算结�?
    wire[31:0] read_data;    // RAM中读取的数据
    wire[31:0] address;      //memory模块�?要操作的地址
    wire[31:0] branch_base_addr;  // 用于beq,bne指令，ifetch�?(pc+4)输出到ALU
    wire alusrc;            //alu的第二个操作数是否为立即�?
    wire branch,nbranch,jmp,jal,jr,i_format; //是否为各种指�?
    wire regdst;            //目标寄存器是rd还是rt，用于区分R型和I�?
    wire regwrite;          //写寄存器信号
    wire zero;              //�?
    wire memwrite;          //写内存信�?
    wire memread;           //读内存信�?
    wire memoriotoreg;      //将memory或io的数据写入寄存器的信�?  
    wire sftmd;
    wire[1:0] aluop;
    wire[31:0] instruction;
    wire[31:0] opcplus4;
    wire ledctrl,switchctrl,segctrl,keyboardctrl;
    
    cpuclk cpuclk(
    .clk_in1(pclk),    // 100MHz
    .clk_out1(clock)   // cpuclock
    );
    ToBoardClock tbc_led(
    .clk(pclk),
    .new_clk(led_clk)    
    );
    ToBoardClock tbc_seg(
    .clk(pclk),
    .new_clk(seg_clk)    
    );
    
    Ifetc32 ifetch(
        .Instruction(instruction),  //获取到的32位指�?
        .branch_base_addr(branch_base_addr), //输出到ALU，branch指令时的PC+4
        .Addr_result(add_result),   //来自ALU，branch�?要的地址�?
        .Read_data_1(read_data_1),  //来自decoder，jr指令更新PC时用的地�?
        .Branch(branch),           //来自controller，是否为beg指令
        .nBranch(nbranch),         //来自controller，是否为bnq指令
        .Jmp(jmp),                 //来自controller，是否为jump指令
        .Jal(jal),                 //来自controller，是否为jal指令
        .Jr(jr),                    //来自controller，是否为jr指令
        .Zero(zero),              //来自controller，表明alu_result�?0
        .clock(clock),            //来自cpuclk
        .reset(reset),            //待解�?
        .link_addr(opcplus4)       //输出到decoder，用于jal指令时的PC+4
    );
    
    decode32 decode(
    .read_data_1(read_data_1),  // 读数�?1（rs�?
    .read_data_2(read_data_2),  // 读数�?2（rt�?
    .Instruction(instruction), // 来自取指模块
    .mem_data(rdata),   // 来自memorio模块，从DATA RAM or I/O port取出的数�?
    .ALU_result(alu_result),  // 来自ALU模块，需要扩展立即数�?32�?
    .Jal(jal),              // 来自controller，指令是不是JAL
    .RegWrite(regwrite),         // 来自controller，寄存器写使�?
    .MemtoReg(memoriotoreg),     //来自controller�? 数据来源是不是MEM
    .RegDst(regdst),           // 来自controller，为1说明目标寄存器是rd，否则是rt
    .Sign_extend(sign_extend),  // 立即数扩展的结果
    .clock(clock),              //23Mhz
    .reset(reset),              //待解�?
    .opcplus4(opcplus4)         // The JAL instruction is used to write the return address to the $ra register, what we have got here is PC + 4
    );
    
    control32 control(
    .Opcode(instruction[31:26]),             // 来自取指单元[31..26]
    .Function_opcode(instruction[5:0]),    // 来自取指模块，R型指令的[5..0]
    .Alu_resultHigh(alu_result[31:10]), //来自ALU模块
    .Jr(jr),                     // �?1表示下一PC来源于寄存器，否则来源于PC相关运算
    .RegDST(regdst),                  // �?1说明目标寄存器是rd，否则是rt
    .ALUSrc(alusrc),                  // �?1表明第二个操作数是立即数，否则是寄存器（beq、bne除外�?
    .MemtoReg(memoriotoreg),                // 寄存器组写入数据来源�?1为Mem�?0为ALU
    .RegWrite(regwrite),                // 寄存器组写使�?
    .MemWrite(memwrite),                // DRAM写使�?
    .Branch(branch),                  // �?1表明是beq
    .nBranch(nbranch),                 // �?1表明是bne
    .Jmp(jmp),                     // �?1表明是j
    .Jal(jal),                     // �?1表明是jal
    .I_format(i_format),                // 是否为I型指�?(除beq，bne，lw，sw之外)
    .Sftmd(sftmd),                   // �?1表明是移位指�?
    .ALUOp(aluop),               // LW/SW-00, BEQ/BNE-01, R-TYPE-10, I-TYPE=10
    .MemRead(memread),           //是否读内�?
    .IORead(ioread),             //是否读IO
    .IOWrite(iowrite)           //是否写IO
    );
                      
    Executs32 execute(
    .Read_data_1(read_data_1),		// 来自decoder, r-form rs 从译码单元是Read_data_1中来
    .Read_data_2(read_data_2),		// 来自decoder，r-form rt 从译码单元是Read_data_2中来
    .Sign_extend(sign_extend),		// 来自decoder，i-form 译码单元来的扩展后的立即�?
    .Function_opcode(instruction[5:0]),  // 来自取指模块，r-form instructions[5..0] 取指单元来的R型的Func
    .Exe_opcode(instruction[31:26]),  		// 来自取指模块，opcode 取�?�单元来的Op
    .ALUOp(aluop),            // 控制单元来的ALUOp，第�?级控制（LW/SW 00，BEQ/BNE 01，R/I 10�?
    .Shamt(instruction[10:6]),            // 来自取指模块，移位量
    .Sftmd(sftmd),            // 来自控制单元，是否是移位指令
    .ALUSrc(alusrc),           // 来自控制单元，表明第二个操作数是立即数（beq、bne除外�?
    .I_format(i_format),         // 该指令是除了beq、bne、lw、sw以外的其他I类型指令
    .Zero(zero),             // Zero Flag
    .Jr(0),
    .ALU_Result(alu_result),       // 执行单元的最终运算结�?
    .Addr_Result(add_result),		// 计算的地�?结果       
    .PC_plus_4(branch_base_addr)         // 来自取指单元的PC+4
    );
    
    dmemory32 memory(
    .clock(pclk),
    .memWrite(memwrite),         // 来自控制单元
    .address(address),     // 来自memorio模块，源头是来自执行单元算出的alu_result
    .writeData(write_data),  // 来自memio模块，源头是译码单元的read_data2
    .readData(read_data)    //从中读到的数�?
    );
    //需要有一个信号去促使
    assign ioread_data = selectInput ? ioread_data2 : ioread_data1; 
    MemOrIO memio(
    .mRead(memread),    //来自控制单元，读内存使能
    .mWrite(memwrite),   //来自控制单元，写内存使能
    .ioRead(ioread),     //来自控制单元，io读输入使�?
    .ioWrite(iowrite),   //来自控制单元，io写输入使�?
    .addr_in(alu_result),         //来自alu，alu的结�?
    .addr_out(address),           //数据内存的地�?�?
    .m_rdata(read_data),            //来自数据内存的数�?  
    .io_rdata(ioread_data),           //来自IOread的数�?   
    .r_wdata(rdata),            //要写入decoder的数�?  
    .r_rdata(read_data_2),            //读来自decoder的数�?
    .write_data(write_data),         //输出�?要写的数�?
    .LEDCtrl(ledctrl),            //选择灯的外设
    .SwitchCtrl(switchctrl),          //选择拨码�?关的外设
    .SegCtrl(segctrl),             //选择7段数码管外设
    .KeyboardCtrl(keyboardctrl)        //选择小键盘外设
    );
    
    ioRead multiioread(
    .reset(reset),             //待解�?
    .ior(ioread),             //来自控制单元，io读输入使�?
    .switchctrl(switchctrl),   //来自memorio模块，是否�?�择拨码�?关输�?
    .ioread_data_switch(ioread_data_switch),//来自外设拨码�?关的数据
    .ioread_data(ioread_data1), //外设对应的数�?
    .isSelect(selectInput)     //是否选择该外设
    );

    ioReadKey irk(
    .clk(pclk),    
    .reset(reset),
    .ior(ioread),
    .keyboardctrl(keyboardctrl),
    .ioread_data_key(key_col),
    .ioread_data(ioread_data2),
    .row(key_row),
    .isSelect(selectInput)    
    );

    led led16(
    .ledrst(reset),
    .ledclk(led_clk),
    .ledwrite(iowrite),
    .ledcs(ledctrl),
    .ledaddr(2'b00),
    .ledwdata(write_data),
    .ledout(leds)
    );
 
    seg seg7(
    .segrst(reset),
    .seg_clk(seg_clk),
    .segwrite(iowrite),
    .segcs(segctrl),
    .segwdata(write_data),
    .enables(seg_enables),
    .segout(segs)
    );
 


endmodule
