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


module execute_stage(
    input  wire        clk,
    input  wire        resetn,

    input  wire [39:0] de_out_op,       //control signals used in EXE, MEM, WB stages
    input  wire [ 4:0] de_dest,         //reg No. of dest operand, zero if no dest
    input  wire [31:0] de_vsrc1,        //value of source operand 1
    input  wire [31:0] de_vsrc2,        //value of source operand 2
    input  wire [31:0] de_st_value,     //value stored to memory

    output wire [39:0] exe_out_op,      //control signals used in MEM, WB stages
    output reg  [ 4:0] exe_dest,        //reg num of dest operand
    output wire [31:0] exe_value,       //alu result from exe_stage or other intermediate 
                                        //value for the following stages

    output wire        data_sram_en,
    output wire [ 3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata 

  `ifdef SIMU_DEBUG
   ,input  wire [31:0] de_pc,           //pc @decode_stage
    input  wire [31:0] de_inst,         //instr code @decode_stage
    output reg  [31:0] exe_pc,          //pc @execute_stage
    output reg  [31:0] exe_inst,        //instr code @execute_stage
  `endif
  
    input  wire        next_allowin,
    output wire        now_allowin,
    input  wire        pre_to_now_valid,
    output wire        now_to_next_valid,
    output reg         now_valid,
    input  wire        now_ready_go        
);

reg  [39:0] exe_op;
reg  [31:0] exe_vsrc1;
reg  [31:0] exe_vsrc2;
reg  [31:0] exe_st_value;
//pipe_line
wire               now_to_next_valid;
assign now_allowin = !now_valid || now_ready_go && next_allowin;
assign now_to_next_valid = now_valid && now_ready_go;
//exe
wire [31:0 ]  exe_alu_result;
wire [2 :0 ]  exe_alu_op = exe_op[22:20];
//mem
assign  data_sram_en  = de_out_op[10];
assign  data_sram_wen = {3{de_out_op[11]}};
assign  data_sram_addr = exe_alu_result;
assign  data_sram_wdata = de_st_value;

assign exe_out_op = exe_op;      
assign exe_value = exe_alu_result;       

always @(posedge clk)
begin
    if (resetn) begin
        exe_dest <= 0;
        exe_st_value <= 0;
        exe_vsrc1 <= 0;
        exe_vsrc2 <= 0;
        exe_op   <= 0；
    end
    else if (pre_to_now_valid && now_allowin) begin 
        exe_dest <= de_dest;
        exe_st_value <= de_st_value;
        exe_vsrc1 <= de_vsrc1;
        exe_vsrc2 <= de_vsrc2; 
        exe_op <= de_out_op；
    end
end

always @(posedge clk)
begin
    if (resetn) begin
        now_valid <= 0;
    end
    else if (now_allowin) begin 
        now_valid <= pre_to_now_valid;
    end
end


alu alu4cpu
	(
	.A       (de_vsrc1),
	.B       (de_vsrc2),
	.ALUop   (exe_alu_op   ),

	.Result  (exe_alu_result)
    );
    
endmodule //execute_stage
