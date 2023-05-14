module Executs32(Read_data_1, Read_data_2, Sign_extend, 
Function_opcode, Exe_opcode, ALUOp, Shamt, ALUSrc, I_format, Zero,
Jr, Sftmd, ALU_Result, Addr_Result, PC_plus_4);
// from Decoder
input[31:0] Read_data_1; //the source of Ainput
input[31:0] Read_data_2; //one of the sources of Binput
input[31:0] Sign_extend; //one of the sources of Binput
// from IFetch
input[5:0] Function_opcode; //instructions[5:0]
input[5:0] Exe_opcode; //instruction[31:26]
input[4:0] Shamt; //instruction[10:6], the amount of shift bits
input[31:0] PC_plus_4; //pc+4
// from Controller
input[1:0] ALUOp; //{ (R_format || I_format) , (Branch || nBranch) }
input ALUSrc; // 1 means the 2nd operand is an immediate (except beq,bne）
input I_format; // 1 means I-Type instruction except beq, bne, LW, SW
input Jr;   // from the control unit, indicating a JR instruction
input Sftmd; // 1 means this is a shift instruction

output reg[31:0] ALU_Result; // the ALU calculation result
output Zero; // 1 means the ALU_reslut is zero, 0 otherwise
output[31:0] Addr_Result; // the calculated instruction address

wire[31:0] Ainput,Binput; // two operands for calculation
wire signed [31:0] Ainput_signed, Binput_signed; // two operands for calculation
wire[5:0] Exe_code; // use to generate ALU_ctrl. (I_format==0) ? Function_opcode : { 3'b000 , Exe_opcode[2:0] };
wire[2:0] ALU_ctl; // the control signals which affact operation in ALU directely
wire[2:0] Sftm; // identify the types of shift instruction, equals to Function_opcode[2:0]
reg[31:0] Shift_Result; // the result of shift operation
reg[31:0] ALU_output_mux; // the result of arithmetic or logic calculation
wire[32:0] Branch_Addr; // the calculated address of the instruction, Addr_Result is Branch_Addr[31:0]

// generate Ainput,Binput
assign Ainput = Read_data_1;
assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];

// generate Ainput_signed, Binput_signed
assign Ainput_signed = Ainput;
assign Binput_signed = Binput;

// generate Exe_code
assign Exe_code = (I_format == 0) ? Function_opcode : { 3'b000 , Exe_opcode[2:0] };

// generate ALU_ctl
assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];
assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];

// generate Sftm
assign Sftm = Function_opcode[2:0];

always @* begin // six types of shift instructions
    if(Sftmd)
        case(Sftm[2:0])
          3'b000: begin 
            Shift_Result = Binput << Shamt; //Sll rd,rt,shamt 00000
          end
          3'b010: begin
            Shift_Result = Binput >> Shamt; //Srl rd,rt,shamt 00010
          end
          3'b100: begin
            Shift_Result = Binput << Ainput; //Sllv rd,rt,rs 00100
          end
          3'b110: begin
            Shift_Result = Binput >> Ainput; //Srlv rd,rt,rs 00110
          end
          3'b011: begin
            Shift_Result = Binput_signed >>> Shamt; // Sra rd,rt,shamt 00011
          end
          3'b111: begin
            Shift_Result = Binput_signed >>> Ainput_signed; // Srav rd,rt,rs 00111
          end
          default: begin
            Shift_Result = Binput;
          end
        endcase
    else
        Shift_Result = Binput;
end

// generate ALU_output_mux
always @(ALU_ctl or Ainput or Binput)
begin 
    case(ALU_ctl[2:0])
      //and, andi
      3'b000:ALU_output_mux = Ainput & Binput;
      //or, ori
      3'b001:ALU_output_mux = Ainput | Binput;
      //add, addi, lw, sw
      3'b010:ALU_output_mux = Ainput_signed + Binput_signed;
      //addu, addiu
      3'b011:ALU_output_mux = Ainput + Binput;
      //xor, xori
      3'b100:ALU_output_mux = Ainput ^ Binput;
      //nor, lui
      3'b101:ALU_output_mux = ~(Ainput | Binput);
      //sub, slti, beq, bne
      3'b110:ALU_output_mux = Ainput_signed - Binput_signed;
      //subu, sltiu, slt, sltu
      3'b111:ALU_output_mux = Ainput - Binput;
      default:ALU_output_mux = 0;
    endcase
end

// generate ALU_Result
always @* begin
    //set type operation (slt, slti, sltu, sltiu)
    if ( ((ALU_ctl == 3'b111) && (Exe_code[3] == 1)) || ((ALU_ctl[2:1] == 2'b11) && (I_format == 1)) )
        ALU_Result = { 31'd0, ALU_output_mux[31] };
    //lui operation
    else if((ALU_ctl==3'b101) && (I_format==1))
        ALU_Result[31:0] = {Binput[15:0], 16'd0};
    //shift operation
    else if(Sftmd==1)
        ALU_Result = Shift_Result ;
    //other types of operation in ALU (arithmatic or logic calculation)
    else
        ALU_Result = ALU_output_mux[31:0];
end

// generate Branch_Addr
assign Branch_Addr = PC_plus_4 + (Sign_extend << 2);

// generate Addr_Result
assign Addr_Result = Branch_Addr[31:0];

// generate Zero
assign Zero = (ALU_output_mux[31:0] == 0) ? 1 : 0;


endmodule