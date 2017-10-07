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


module memory_stage(
    input  wire        clk,
    input  wire        resetn,

    input  wire [39:0] exe_out_op,      //control signals used in MEM, WB stages
    input  wire [ 4:0] exe_dest,        //reg num of dest operand
    input  wire [31:0] exe_value,       //alu result from exe_stage or other intermediate 
                                        //value for the following stages

    input  wire [31:0] data_sram_rdata,

    output wire [39:0] mem_out_op,      //control signals used in WB stage
    output reg  [ 4:0] mem_dest,        //reg num of dest operand
    output wire [31:0] mem_value        //mem_stage final result

  `ifdef SIMU_DEBUG
   ,input  wire [31:0] exe_pc,          //pc @execute_stage
    input  wire [31:0] exe_inst,        //instr code @execute_stage
    output reg  [31:0] mem_pc,          //pc @memory_stage
    output reg  [31:0] mem_inst         //instr code @memory_stage
  `endif
  
    input  wire        next_allowin;
    output wire        now_allowin;
);
//pipe_line
wire               now_ready_go;
wire               now_to_next_valid;
assign now_ready_go = 1;
assign now_allowin = !now_valid || now_ready_go && next_allowin;
assign now_to_next_valid = now_valid && now_ready_go;

reg  [39:0] mem_op;
reg  [31:0] mem_value;
reg  [31:0] value;

assign mem_out_op = mem_op;
assign mem_value = value;

always @(posedge clk)
begin
    if (resetn) begin
        mem_op <= 0;
        value <=0;
        mem_dest <=0;
    end
    else if (now_to_next_valid && now_allowin) begin 
        mem_op <= exe_out_op;
        value <= de_out_op[1] ? data_sram_rdata : exe_value;
        mem_dest <= exe_dest;
    end
end

always @(posedge clk)
begin
    if (resetn) begin
        now_valid <= 0;
    end
    else if (now_allowin) begin 
        now_valid <= now_to_next_valid;
    end
end

endmodule //memory_stage
