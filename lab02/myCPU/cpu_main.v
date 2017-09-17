`timescale 1ns / 1ps
module mycpu_top(
//Clock and Reset
input                clk,
input                resetn,

//Instruction Fetch WR
output               inst_sram_en,
output      [3 :0]   inst_sram_wen,
output      [31:0]   inst_sram_addr,
output      [31:0]   inst_sram_wdata,
input       [31:0]   inst_sram_rdata,

//Data WR
output               data_sram_en,
output      [3 :0]   data_sram_wen,
output      [31:0]   data_sram_addr,
output      [31:0]   data_sram_wdata,
input       [31:0]   data_sram_rdata,

//Debug Signals
output reg  [31:0]   debug_wb_pc,
output      [3 :0]   debug_wb_rf_wen,
output      [4 :0]   debug_wb_rf_wnum,
output      [31:0]   debug_wb_rf_wdata
);

//Macro Def
`define addiu   6'b001001
`define addu    6'b100001
`define nop     6'b000000
`define lw      6'b100011
`define sw      6'b101011
`define bne     6'b000101
`define beq     6'b000100
`define j       6'b000010
`define jal     6'b000011
`define jr      6'b001000
`define lui     6'b001111
`define or      6'b100101
`define sll     6'b000000
`define slt     6'b101010
`define slti    6'b001010   
`define sltiu   6'b001011

//CPU Def
reg  [3 :0] State;
reg  [31:0] Address, MDR, TempofIns, A, B, ALUOut;
wire        PCWriteCond, PCWrite, MemtoReg, IRWrite, RegDst, RegWrite, ALUSrcA, Zero, PCW, CarryOut;
wire [1 :0] ALUSrcB, ALUOp, PCSource;
wire [2 :0] ALUop;
wire [3 :0] Next_State;
wire [4 :0] waddr,sa;
wire [5 :0] Op, func;
wire [31:0] sign_extend, sign_ext_2ls, CPU_A, CPU_B, rdata1, rdata2, wdata, Result, Next_PC, imm, Tempofsa, TempofPC, Next_PC_J;

//Wire Connection
assign PCWriteCond      =           (State==4'd8);
assign PCWrite          =           (State==4'd0||(State==4'd9&&func==`jr)||State==4'd11);
assign MemtoReg         =           (State==4'd4);
assign IRWrite          =           (State==4'd0);
assign RegDst           =           (State==4'd10);
assign RegWrite         =           (State==4'd4||State==4'd7||State==4'd10||State==4'd11&&Op==`jal||State==4'd12||State==4'd14);
assign ALUSrcA          =           (State==4'd2||State==4'd6||State==4'd8||State==4'd9||State==4'd13); 
assign PCW              =           (
                                        (Op==`bne)?(PCWriteCond&&(!Zero)||PCWrite):
                                        (Op==`j||Op==`jal||(Op==`nop&&func==`jr))?PCWrite:
                                        ((PCWriteCond&&Zero)||PCWrite)
                                    );
assign ALUSrcB[1]       =           (
                                        (State==4'd1)||
                                        (State==4'd2)||
                                        (State==4'd6)||
                                        (State==4'd13)
                                    );
assign ALUSrcB[0]       =           (State==4'd0||State==4'd1);
assign ALUOp[1]         =           (State==4'd6||State==4'd9);
assign ALUOp[0]         =           (State==4'd8||State==4'd9);
assign PCSource[1]      =           (State==4'd11);
assign PCSource[0]      =           (State==4'd8);
assign ALUop            =           (
                                        (State==4'd13)?3'b111:
                                        (ALUOp==2'd1)?3'b110:
                                        (ALUOp==2'd0||ALUOp==2'd2)?3'b010:
                                        (func==`addu)?3'b010:
                                        (func==`or)?3'b001:
                                        3'b111
                                    );
assign Next_State[0]    =           (
                                        (State==4'd0)||
                                        (State==4'd2&&(Op==`lw||Op==`sw))||
                                        (State==4'd6)||
                                        (State==4'd1&&(Op==`j||Op==`jal||Op==`slti||Op==`sltiu||Op==`nop))
                                     );
assign Next_State[1]    =           (
                                        (State==4'd1&&(Op==`lw||Op==`sw||Op==`addiu||Op==`j||Op==`jal))||
                                        (State==4'd2&&Op==`lw)||
                                        (State==4'd6)||
                                        (State==4'd9&&func!=`jr)||
                                        (State==4'd13)
                                    );
assign Next_State[2]    =           (
                                        (State==4'd1&&(Op==`addiu||Op==`lui||Op==`slti||Op==`sltiu))||
                                        (State==4'd2&&Op==`sw)||
                                        (State==4'd3)||
                                        (State==4'd6)||
                                        (State==4'd13)
                                    );
assign Next_State[3]    =           (
                                        (State==4'd1&&(Op==`bne||Op==`beq||Op==`nop||Op==`j||Op==`jal||Op==`lui||Op==`slti||Op==`sltiu))||
                                        (State==4'd9)||
                                        (State==4'd13)
                                    );
assign sa               =           TempofIns[10:6];
assign Tempofsa         =           B << sa;
assign imm              =           {TempofIns[15:0],16'd0};
assign TempofPC         =           debug_wb_pc + 4;
assign Next_PC_J        =           {debug_wb_pc[31:28],TempofIns[25:0],2'b0};
assign func             =           TempofIns [5:0];
assign waddr            =           (
                                        (Op==`jal&&State==4'd11)?5'd31:
                                        (RegDst)?TempofIns[15:11]:
                                        TempofIns[20:16]
                                    );
assign Op               =           TempofIns [31:26];
assign sign_extend      =           {{16{TempofIns[15]}},TempofIns[15:0]};
assign sign_ext_2ls     =           {sign_extend[29:0],2'd0};
assign CPU_A            =           (ALUSrcA)?A:debug_wb_pc;
assign CPU_B            =           (
                                        (ALUSrcB==2'd0)?B:
                                        (ALUSrcB==2'd1)?32'd4:
                                        (ALUSrcB==2'd2)?sign_extend:
                                        sign_ext_2ls
                                    );
assign MemRead = (State==4'd0||State==4'd3);
assign MemWrite = (State==4'd5);
assign MemtoReg = (State==4'd4);
assign wdata = (Op==`lui&&State==4'd12)?imm:((Op==`jal&&State==4'd11)?TempofPC:((MemtoReg)?MDR:ALUOut));
assign Next_PC = (PCSource==2'd0)?Result:((PCSource==2'd1)?ALUOut:Next_PC_J);

//TEST Assign
assign inst_sram_wen = 4'd0;
assign inst_sram_wdata = 32'd0;
assign inst_sram_en = (State==4'd0);



//Connection with ALU and REG
alu aluforcpu(
.A          (CPU_A      ),
.B          (CPU_B      ),
.ALUop      (ALUop      ),
.Zero       (Zero       ),
.Result     (Result     ),
.CarryOut   (CarryOut   )
);

reg_file regforcpu(
.clk        (clk                ),
.rst        (resetn             ),
.wen        (RegWrite           ),
.raddr1     (TempofIns[25:21]   ),
.raddr2     (TempofIns[20:16]   ),
.waddr      (waddr              ),
.wdata      (wdata              ),
.rdata1     (rdata1             ),
.rdata2     (debug_wb_rf_wdata  )
);



endmodule