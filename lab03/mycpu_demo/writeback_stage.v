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


module writeback_stage(
    input  wire        clk,
    input  wire        resetn,

    input  wire [39:0] mem_out_op,      //control signals used in WB stage
    input  wire [ 4:0] mem_dest,        //reg num of dest operand
    input  wire [31:0] mem_value,       //mem_stage final result

    output wire        wb_rf_wen,
    output wire [ 4:0] wb_rf_waddr,
    output wire [31:0] wb_rf_wdata 

  `ifdef SIMU_DEBUG
   ,input  wire [31:0] mem_pc,          //pc @memory_stage
    input  wire [31:0] mem_inst,        //instr code @memory_stage
    output reg  [31:0] wb_pc,
  `endif
  
    input  wire        next_allowin,
    output wire        now_allowin,
    input  wire        pre_to_now_valid,
    output wire        now_to_next_valid,
    output reg         now_valid,
    input  wire        now_ready_go        
);

reg  [39:0] wb_op;
reg  [ 4:0] wb_dest;
reg  [31:0] wb_value;

//pipe_line
wire               now_to_next_valid;
assign now_allowin = !now_valid || now_ready_go && next_allowin;
assign now_to_next_valid = now_valid && now_ready_go;
//rf
assign wb_rf_wen = wb_out_op[0];

assign wb_rf_waddr = wb_dest; 
assign wb_rf_wdata = wb_value;

always @(posedge clk)
begin
    if (resetn) begin
        wb_op <= 0;
        wb_value <=0;
        wb_dest <=0;
    end
    else if (pre_to_now_valid && now_allowin) begin 
        wb_op <= mem_out_op;
        wb_value <= mem_value;
        wb_dest = mem_dest;
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


`ifndef SIMU_DEBU
reg  [31:0] wb_inst;      
always @(posedge clk)
begin
    if (resetn) begin
        wb_pc <= 0;
        wb_inst <= 0;
    end
    else if (pre_to_now_valid && now_allowin) begin 
	wb_pc <= mem_pc;
	wb_inst <= mem_inst;
	end
end
`endif

endmodule //writeback_stage
