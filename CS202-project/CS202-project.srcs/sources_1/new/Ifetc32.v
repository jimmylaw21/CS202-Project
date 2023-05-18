`include "public.v"


module Ifetc32 (Instruction,
                branch_base_addr,
                Addr_result,
                Read_data_1,
                Branch,
                nBranch,
                Jmp,
                Jal,
                Jr,
                Zero,
                clock,
                reset,
                link_addr,
                upg_rst_i,
                upg_clk_i,
                upg_wen_i,
                upg_adr_i,
                upg_dat_i,
                upg_done_i
                );

    output [31:0] Instruction;			// 从这个模块获取到的指令，输出到其他模块
    output reg[31:0] branch_base_addr;      // 用于beq,bne指令，(pc+4)输出到ALU
    output reg[31:0] link_addr;             // 用于jal指令，(pc+4)输出到解码器

    input[31:0]  Addr_result;           // ALU中计算出的地址
    input[31:0]  Read_data_1;           // jr指令更新PC时用的地址
    input        Branch;                // 当Branch为1时，表示当前指令是beq
    input        nBranch;               // 当nBranch为1时，表示当前指令为bnq
    input        Jmp;                   // 当Jmp为1时，表示当前指令为jump
    input        Jal;                   // 当Jal为1时，表示当前指令为jal
    input        Jr;                    // 当Jr为1时，表示当前指令为jr
    input        Zero;                  // 当Zero为1时，表示ALUresult为0
    input        clock,reset;           // 时钟与复位（同步复位信号，高电平有效，当reset=1时，PC赋值为0）
    
    input upg_rst_i; // UPG reset (Active High)
    input upg_clk_i; // UPG clock (10MHz)
    input upg_wen_i; // UPG write enable
    input[13:0] upg_adr_i; // UPG write address
    input[31:0] upg_dat_i; // UPG write data
    input upg_done_i; // 1 if program finished

    /* if kickOff is 1 means CPU work on normal mode, otherwise CPU work on Uart communication mode */
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i );
    
    reg[31:0] PC, Next_PC;
    
    prgrom instmem(
    .clka(kickoff ? clock : upg_clk_i),
    .wea(kickOff ? 1'b0 : upg_wen_i),
    .addra(kickOff ? PC[15:2] : upg_adr_i),
    .dina(kickOff ? 32'h00000000 : upg_dat_i),
    .douta(Instruction)
    );
    
    always @* begin
        if (((Branch == 1) && (Zero == 1)) || ((nBranch == 1) && (Zero == 0))) begin // beq, bne
            Next_PC = Addr_result; // the calculated new value for PC
            branch_base_addr = PC + 4;
        end else if (Jr == 1)
            Next_PC = Read_data_1; // the value of $31 register
        else 
            Next_PC = PC + 4; // PC+4
            branch_base_addr = PC + 4;
    end

    always @(negedge clock) begin
        if (reset == `Enable)
            PC <= 32'h0000_0000;
        else begin
            // 如果是跳转指令，记录返回地址，然后根据指令中的地址字面改写当前PC
            if ((Jmp == 1) || (Jal == 1)) begin
                link_addr = PC + 4;
                PC <= { 4'b0000, Instruction[`AddressRange], 2'b00 };
            end else begin
                PC <= Next_PC;
            end
        end
    end
                    
                    
            
endmodule
                    
                    
