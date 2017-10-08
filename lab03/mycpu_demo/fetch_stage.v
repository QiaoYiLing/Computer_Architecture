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


module fetch_stage(
    input  wire        clk,
    input  wire        resetn,

    input  wire [31:0] nextpc,

    input  wire [31:0] inst_sram_rdata,

    output reg  [31:0] fe_pc,           //fetch_stage pc
    output wire        fe_wen,
    output wire [31:0] fe_inst,          //instr code sent from fetch_stage

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
    
assign fe_inst = inst_sram_rdata;
assign fe_wen  = pre_to_now_valid && now_allowin;

always @(posedge clk)
begin
    if (resetn) begin
        fe_pc <= 32'hbfc0_0000;
    end
    else if (pre_to_now_valid && now_allowin) begin 
        fe_pc <= nextpc;	
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

endmodule //fetch_stage
