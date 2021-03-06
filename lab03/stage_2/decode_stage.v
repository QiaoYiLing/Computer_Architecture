/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/


module decode_stage(
    input  wire        clk,
    input  wire        resetn,

    input  wire [31:0] fe_inst,
    input  wire [31:0] fe_pc,

    output wire [ 4:0] de_rf_raddr1,
    input  wire [31:0] de_rf_rdata1,
    output wire [ 4:0] de_rf_raddr2,
    input  wire [31:0] de_rf_rdata2,

    output wire        de_br_taken,     //1: branch taken, go to the branch target
    output wire        de_br_is_br,     //1: target is PC+offset
    output wire        de_br_is_j,      //1: target is PC||offset
    output wire        de_br_is_jr,     //1: target is GR value
    output wire [15:0] de_br_offset,    //offset for type "br"
    output wire [25:0] de_br_index,     //instr_index for type "j"
    output wire [31:0] de_br_target,    //target for type "jr"

    output wire [39:0] de_out_op,       //control signals used in EXE, MEM, WB stages
    output wire [ 4:0] de_dest,         //reg num of dest operand, zero if no dest
    output wire [31:0] de_vsrc1,        //value of source operand 1
    output wire [31:0] de_vsrc2,        //value of source operand 2
    output wire [31:0] de_st_value,      //value stored to memory

//  `ifdef SIMU_DEBUG
    output reg  [31:0] de_pc,
    output       [31:0] de_inst,         //instr code @decode stage
//  `endif
  
    input  wire        next_allowin,
    output wire        now_allowin,
    input  wire        pre_to_now_valid,
    output wire        now_to_next_valid,
    output reg         now_valid,
    input  wire        now_ready_go        
);

//pipe_line
assign now_allowin = !now_valid || now_ready_go && next_allowin;
assign now_to_next_valid = now_valid && now_ready_go;
    
   
wire [31:0 ] Instruction = fe_inst;
wire [5 :0 ] op_code = Instruction[31:26];
wire [4 :0 ] shamt = Instruction[11:6];
wire [5 :0 ] func = Instruction[5:0];  
wire [15:0 ] immediate = Instruction[15:0];
wire [31:0 ] sign_extend = {{16{immediate[15]}},immediate};
wire [31:0 ] zero_extend = {{16'b0},immediate};
assign de_rf_raddr1 = Instruction[25:21];
assign de_rf_raddr2 = Instruction[20:16];
    
wire inst_addiu = (op_code==6'b001001                   );  //addiu
wire inst_addu  = (op_code==6'b000000 && func==6'b100001);  //addu
wire inst_nop   = (op_code==6'b000000 && func==6'b000000);  //nop
wire inst_lw    = (op_code==6'b100011                   );  //lw
wire inst_sw    = (op_code==6'b101011                   );  //sw
wire inst_bne   = (op_code==6'b000101                   );  //bne
wire inst_beq   = (op_code==6'b000100                   );  //beq
wire inst_j     = (op_code==6'b000010                   );  //j
wire inst_jal   = (op_code==6'b000011                   );  //jal
wire inst_jr    = (op_code==6'b000000 && func==6'b001000);  //jr
wire inst_lui   = (op_code==6'b001111                   );  //lui
wire inst_or    = (op_code==6'b000000 && func==6'b100101);  //or, nop
wire inst_sll   = (op_code==6'b000000 && func==6'b000000);  //sll
wire inst_slt   = (op_code==6'b000000 && func==6'b101010);
wire inst_sltu  = (op_code==6'b000000 && func==6'b101011);
wire inst_slti  = (op_code==6'b001010                   );
wire inst_sltiu = (op_code==6'b001011                   );

//Stage 2 added: ADD、ADDI、SUB、SUBU、SLTU、AND、ANDI、NOR、ORI、XOR、XORI、SLLV、SRA、SRAV、SRL、SRLV
wire inst_add   = (op_code==6'b000000 && func==6'b100000);  //add
wire inst_addi  = (op_code==6'b001000                   );  //addi
wire inst_sub   = (op_code==6'd000000 && func==6'b100010);  //sub
wire inst_subu  = (op_code==6'b000000 && func==6'b100011);  //subu
//SLTU has existed
wire inst_and   = (op_code==6'b000000 && func==6'b100100);  //and
wire inst_andi  = (op_code==6'b001100                   );  //andi
wire inst_nor   = (op_code==6'b000000 && func==6'b100111);  //nor
wire inst_ori   = (op_code==6'b001101                   );  //ori
wire inst_xor   = (op_code==6'b000000 && func==6'b100110);  //xor
wire inst_xori  = (op_code==6'b001110                   );  //xori
wire inst_sllv  = (op_code==6'b000000 && func==6'b000100);  //sllv
wire inst_sra   = (op_code==6'b000000 && func==6'b000011);  //sra
wire inst_srav  = (op_code==6'b000000 && func==6'b000111);  //srav
wire inst_srl   = (op_code==6'b000000 && func==6'b000010);  //srl
wire inst_srlv  = (op_code==6'b000000 && func==6'b000110);  //srlv

//wire r_type     = inst_addu | inst_or | inst_slt | inst_sll | inst_sltu;
wire r_type     = (op_code==6'b000000 && !inst_jr       );
//judge_branch
wire         de_pc_zero;
wire [31:0 ] de_pc_slt;
assign         de_br_is_br  = (inst_bne && !de_pc_zero) || (inst_beq && de_pc_zero);
assign         de_br_is_j   = inst_j || inst_jal;
assign         de_br_is_jr  = inst_jr;
assign         de_br_taken  = de_br_is_br || de_br_is_j || de_br_is_jr;
assign         de_br_offset = Instruction[15:0];
assign         de_br_index  = Instruction[25:0];
assign         de_br_target = de_rf_rdata1;
//de
wire RegDst = r_type;//|inst_addiu|inst_sltiu|inst_lui|inst_slti|inst_lw;
wire use_sign_extend_imme = inst_addiu|inst_addi|inst_lui|inst_lw|inst_sw|inst_beq|inst_bne|inst_slti|inst_sltiu;
wire use_zero_extend_imme = inst_andi|inst_ori|inst_xori;
wire use_shamt = inst_sll|inst_srl|inst_sra;

assign de_dest = r_type ? Instruction[15:11] : 
                 inst_jal ? 31 :
                 Instruction[20:16];
assign de_vsrc1 = use_shamt? shamt : de_rf_rdata1;
assign de_vsrc2 = use_sign_extend_imme ? sign_extend :
                  use_zero_extend_imme ? zero_extend :
                  de_rf_rdata2;
assign de_st_value = inst_jal ? fe_pc+4 : de_rf_rdata2;
    
//exe
wire [3 :0 ] exe_alu_op   = (inst_addiu|inst_addu|inst_lw|inst_sw|inst_add|inst_addi)   ? 2 :   //add
                            (inst_sub|inst_subu)                                        ? 6 :   //sub
                            (inst_and|inst_andi)                                        ? 0 :   //and
                            (inst_nor)                                                  ? 8 :   //nor
                            (inst_xor|inst_xori)                                        ? 9 :   //xor
                            (inst_or|inst_ori)                                          ? 1 :   //or
                            (inst_slt|inst_slti)                                        ? 7 :   //slt_signed
                            (inst_sll|inst_sllv)                                        ? 3 :   //shift_left
                            (inst_srl|inst_srlv)                                        ? 10:   //shift_right_logical
                            (inst_sra|inst_srav)                                        ? 11:   //shift_right_arithmetic
                            (inst_sltiu|inst_sltu)                                      ? 5 :   //slt_unsigned
                            (inst_lui)                                                  ? 4 :   //lui
                            16;                                                                 //For debug
//mem
wire  mem_MemRead  = inst_lw;
wire  mem_MemWrite = inst_sw;

//wb
wire  wb_RegWrite  = inst_addiu|inst_addi|r_type|inst_lw|inst_lui|inst_sll|inst_slti|inst_sltiu|inst_jal|inst_ori|inst_andi|inst_xori;
wire  wb_MemtoReg  = inst_lw;
//pass_op
assign de_out_op[22:19] = exe_alu_op;
assign de_out_op[10] = mem_MemRead;
assign de_out_op[11] = mem_MemWrite;
assign de_out_op[12]= inst_jal;
assign de_out_op[0] = wb_RegWrite;
assign de_out_op[1] = wb_MemtoReg;



always @(posedge clk)
begin
    if (resetn) begin
        now_valid <= 0;
    end
    else if (now_allowin) begin 
        now_valid <= pre_to_now_valid;
    end
end


alu alu_pc_judge
	(
	.A       (de_rf_rdata1),
	.B       (de_rf_rdata2),
	.ALUop   (6           ),
	.Zero    (de_pc_zero  ),
	.Result  (de_pc_slt   )
    );


//`ifdef SIMU_DEBUG  
assign de_inst = fe_inst;
always @(posedge clk)
begin
    if (resetn) begin
        de_pc <= 0;
    end
    else if (pre_to_now_valid && now_allowin) begin 
	    de_pc   <= fe_pc;
	end
end
//`endif

endmodule //decode_stage
