`include "public.v"

module top(
    // input pclk1,
    input  reset,               // ???Reset????????
    input  pclk,               // ????100MHz????
    input [13:0] sw,    // ????????
    input confirm,
    output signal,
    output [15:0] leds,        // led?????Nexys4
    output [6:0] segs,          //??????????
    output [7:0] seg_enables,   //?????????
    input  [3:0] row_in,
    output [3:0] col_out,
    output hsync,
    output vsync,
    output [`VGA_BIT_DEPTH - 1:0] vga_signal

//     ,output  [31:0] instruction1,
//     output  [31:0] branch_base_addr1,
//     output  [31:0] opcplus41,
//     output clock1,
//   output mWrite1, rWrite1, ioWrite1,
//   output mRead1, ioRead1,
//   output [31:0] address1,
//   output [31:0] readdata1,
//   // ????????...
//   output jr1, jal1, jmp1, beq1, bnq1,
//   output regdst1,
//   output alusrc1,
//   output sftmd1,
//   output i_format1,
//   output [1:0] aluop1,
//   output [31:0] aluresult1,
//   output MemorIOtoReg1,
//   output [31:0] read_data_11, read_data_21,
//   output [31:0] memio_data1,
//   output [31:0] sign_extend1,
//   // ????????...
//   output [31:0] addr_result1,
//   output zero1,
//   output [15:0] ioread_data1,

//   // ????????...
//   output [31:0] write_data1,
//   output [2:0] ledctrl1,
//   output [3:0] switchctrl1,
//   output segctrl1,
//   output[7:0] a,
//   output [7:0]b,
//   output seg_clk1
    );


    wire clock,seg_clk,led_clk;
    wire mWrite,rWrite,ioWrite;
    wire mRead,ioRead;
    wire [31:0] address;
    wire [31:0] readdata;
     wire [31:0] instruction;
    wire jr,jal,jmp,beq,bnq;
    wire regdst;
    wire alusrc;
    wire sftmd;
    wire i_format;
    wire [1:0] aluop;
    wire [31:0] aluresult;
    wire MemorIOtoReg;
    wire [31:0] read_data_1,read_data_2;
    wire [31:0] memio_data;
    wire [31:0] sign_extend;
     wire [31:0] opcplus4;
     wire [31:0] branch_base_addr;
    wire [31:0] addr_result;
    wire zero;
     wire [15:0] ioread_data;
     wire [7:0] input_data;
     reg [7:0] keypadread_data;
    wire [31:0] write_data;
    wire [2:0]ledctrl;
    wire segctrl;
    wire [3:0] switchctrl;
    wire vgactrl;

//         assign mWrite1 = mWrite;
// assign rWrite1 = rWrite;
// assign ioWrite1 = ioWrite;
// assign mRead1 = mRead;
// assign ioRead1 = ioRead;
// assign address1 = address;
// assign readdata1 = readdata;
// // ????assign??...
// assign jr1 = jr;
// assign jal1 = jal;
// assign jmp1 = jmp;
// assign beq1 = beq;
// assign bnq1 = bnq;
// assign regdst1 = regdst;
// assign alusrc1 = alusrc;
// assign sftmd1 = sftmd;
// assign i_format1 = i_format;
// assign aluop1 = aluop;
// assign aluresult1 = aluresult;
// assign MemorIOtoReg1 = MemorIOtoReg;
// assign read_data_11 = read_data_1;
// assign read_data_21 = read_data_2;
// assign memio_data1 = memio_data;
// assign sign_extend1 = sign_extend;
// assign opcplus41 = opcplus4;
// assign branch_base_addr1 = branch_base_addr;
// // ????assign??...
// assign addr_result1 = addr_result;
// assign zero1 = zero;
// // ????assign??...
// assign write_data1 = write_data;
// assign ledctrl1 = ledctrl;
// assign switchctrl1 = switchctrl;
// assign ioread_data1 = ioread_data;
// assign segctrl1 = segctrl;
// assign instruction1 = instruction;
// assign seg_clk1 = seg_clk;

    cpuclk cpuclk1(
    .clk_in1(pclk),
    .clk_out1(clock)    
    );

    ToBoardClock #(10000) tbc_seg(
    .clk(pclk),
    .rst(reset),
    .new_clk(seg_clk)    
    );


    ToBoardClock #(100000) tbc_led(
     .clk(pclk),
     .rst(reset),
     .new_clk(led_clk)    
     );

    controller32 ctl(
    .Opcode(instruction[31:26]),
    .Function_opcode(instruction[5:0]),
    .Jr(jr),
    .Jal(jal),
    .Jmp(jmp),
    .Branch(beq),
    .nBranch(bnq),
    .RegDST(regdst),
    .RegWrite(rWrite),
    .MemWrite(mWrite),
    .ALUSrc(alusrc),
    .Sftmd(sftmd),
    .I_format(i_format),
    .ALUOp(aluop),
    .Alu_resultHigh(aluresult[31:10]),
    .MemorIOtoReg(MemorIOtoReg),
    .MemRead(mRead),
    .IORead(ioRead),
    .IOWrite(ioWrite)    
    );

    decoder32 deco(
    .read_data_1(read_data_1),  // ????1?rs??
    .read_data_2(read_data_2),  // ????2?rt??
    .Instruction(instruction), // ??????
    .memIO_data(memio_data),   // ??memorio????DATA RAM or I/O port??????
    .ALU_result(aluresult),  // ??ALU????????????32??
    .Jal(jal),              // ??controller??????JAL
    .RegWrite(rWrite),         // ??controller????????
    .MemIOtoReg(MemorIOtoReg),     //??controller?? ???????MEM
    .RegDst(regdst),           // ??controller??1????????rd????rt
    .Sign_extend(sign_extend),  // ????????
    .clock(clock),              //23Mhz
    .reset(reset),              //????
    .opcplus4(opcplus4)         // The JAL instruction is used to write the return address to the $ra register, what we have got here is PC + 4
    );

    IFetch32 IF(
        .Instruction(instruction),  //????32????
        .branch_base_addr(branch_base_addr), //???ALU?branch????PC+4
        .Addr_result(addr_result),   //??ALU?branch????????
        .Read_data_1(read_data_1),  //??decoder?jr????PC??????
        .Branch(beq),           //??controller????beg??
        .nBranch(bnq),         //??controller????bnq??
        .Jmp(jmp),                 //??controller????jump??
        .Jal(jal),                 //??controller????jal??
        .Jr(jr),                    //??controller????jr??
        .Zero(zero),              //??controller???alu_result??0
        .clock(clock),            //??cpuclk
        .reset(reset),            //????
        .link_addr(opcplus4)    //???decoder???jal????PC+4
    );

    excutes32 exc(
    .Read_data_1(read_data_1),		// ??decoder, r-form rs ??????Read_data_1??
    .Read_data_2(read_data_2),		// ??decoder?r-form rt ??????Read_data_2??
    .Sign_extend(sign_extend),		// ??decoder?i-form ??????????????
    .Function_opcode(instruction[5:0]),  // ???????r-form instructions[5..0] ??????R??Func
    .Opcode(instruction[31:26]),  		// ???????opcode ????????Op
    .ALUOp(aluop),            // ??????ALUOp????????LW/SW 00?BEQ/BNE 01?R/I 10??
    .Shamt(instruction[10:6]),            // ??????????
    .Sftmd(sftmd),            // ??????????????
    .ALUSrc(alusrc),           // ????????????????????beq?bne????
    .I_format(i_format),         // ??????beq?bne?lw?sw?????I????
    .Zero(zero),             // Zero Flag
    .ALU_Result(aluresult),       // ????????????
    .Addr_Result(addr_result),		// ????????       
    .PC_plus_4(branch_base_addr)         // ???????PC+4    
    );

    wire cache_ready;
    wire [31:0] cache_addr;
    wire [31:0] cache_readdata;
    wire [31:0] cache_writedata;
    wire cache_strobe;
    wire cache_rw;
    wire m_ready;

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
        .m_ready(m_ready)
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
    
//70A,72B,60led low8,62 high8,64 16?,66seg,68????,74???58??
    memorio memorio1(
    .mRead(mRead),    //????????????
    .mWrite(mWrite),   //????????????
    .ioRead(ioRead),     //???????io??????
    .ioWrite(ioWrite),   //???????io??????
    .addr_in(aluresult),         //??alu?alu????
    .addr_out(address),           //??????????
    .m_rdata(readdata),            //??????????  
    .io_rdata(ioread_data),           //??IOread????   
    .r_wdata(memio_data),            //???decoder????  
    .r_rdata(read_data_2),            //???decoder????
    .write_data(write_data),         //??????????
    .LEDCtrl(ledctrl),            //??????
    .SwitchCtrl(switchctrl),          //??????????
    .SegCtrl(segctrl),
    .VgaCtrl(vgactrl)
    );

    leds led16(
    .ledrst(reset),
    .led_clk(led_clk),
    .ledwrite(ioWrite),
    .high_low(ledctrl[1:0]),
    .extra(ledctrl[2:2]),
    .ledwdata(write_data[15:0]),
    .signal(signal),
    .ledout(leds) 
    );
    
    switchs swi(
    .reset(reset),
    .ior(ioRead),
    .switchctrl(switchctrl),
    .testcase(sw[10:8]),
    .ioread_data_switch(input_data),
    .ioread_data(ioread_data),
    .aorb(sw[11:11]),
    .sw_clock(clock),
    .confirm(confirm)
    );

    seg seg7(
    .segrst(reset),
    .seg_clk(seg_clk),
    .seg_clk1(clock),
    .segctrl(segctrl),
    .segwdata(write_data[15:0]),
    .enables(seg_enables),
    .segout(segs)
    );

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
    
    /////////// 分频
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


    // wire vga_clk;
    // ToVgaClock toVgaClock(
    //     .clk                    (clock),
    //     .rst_n                  (reset),
    //     .clk_vga                (vga_clk)
    // );

    // wire [`COORDINATE_WIDTH - 1:0] vga_unit_x, vga_unit_y;
    // wire vga_unit_display_en;


    // vga vga(
    //     .clk_vga                (vga_clk),
    //     .rst_n                  (reset),
    //     .hsync                  (hsync),
    //     .vsync                  (vsync),
    //     .display_en             (vga_unit_display_en),
    //     .x                      (vga_unit_x),
    //     .y                      (vga_unit_y)
    // );

    // vga_output vga_output(
    //     .clk                    (pclk),
    //     .rst_n                  (reset),
    //     .display_en             (vga_unit_display_en),
    //     .x                      (vga_unit_x),
    //     .y                      (vga_unit_y),
    //     .vga_write_enable       (vgactrl),
    //     .vga_store_data         (write_data),
    //     .issue_type             (3'b000),
    //     .switch_enable          (1'b0),
    //     .vga_rgb                (vga_signal)
    // );

    // vga1 vga(
    //     .clk(pclk),
    //     .rst_n(reset),
    //     .state(1),
    //     .hsync(hsync),
    //     .vsync(vsync),
    //     .vga_rgb(vga_signal)
    //     );

endmodule
