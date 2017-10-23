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

`define SIMU_DEBUG

module mycpu_top(
    input  wire        clk,
    input  wire        resetn,            //low active

    output wire        inst_sram_en,
    output wire [ 3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata,
    
    output wire        data_sram_en,
    output wire [ 3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input  wire [31:0] data_sram_rdata 

  `ifdef SIMU_DEBUG
   ,output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_wen,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
  `endif
);

wire [31:0] nextpc;
wire [31:0] fe_pc;
wire [31:0] fe_inst;
wire        fe_wen;
wire [ 4:0] de_rf_raddr1;
wire [ 4:0] de_rf_raddr2;
wire        de_br_taken;    
wire        de_br_is_br;    
wire        de_br_is_j;     
wire        de_br_is_jr;    
wire [15:0] de_br_offset;   
wire [25:0] de_br_index;    
wire [31:0] de_br_target;   
wire [39:0] de_out_op;      
wire [ 4:0] de_dest;         
wire [31:0] de_vsrc1;        
wire [31:0] de_vsrc2;        
wire [31:0] de_st_value;
wire [39:0] exe_out_op;
wire [ 4:0] exe_dest;
wire [31:0] exe_value;
wire [39:0] mem_out_op;
wire [ 4:0] mem_dest;
wire [31:0] mem_value;
wire        wb_rf_wen;
wire [ 4:0] wb_rf_waddr;
wire [31:0] wb_rf_wdata;
wire [31:0] de_rf_rdata1;
wire [31:0] de_rf_rdata2;


`ifdef SIMU_DEBUG
wire [31:0] de_pc;
wire [31:0] de_inst;
wire [31:0] exe_pc;
wire [31:0] exe_inst;
wire [31:0] mem_pc;
wire [31:0] mem_inst;
wire [31:0] wb_pc;
`endif
//pipe_line
wire        fe_allowin;
wire        de_allowin;
wire        exe_allowin;
wire        mem_allowin;
wire        wb_allowin;
wire        fe_to_de_valid;
wire        de_to_exe_valid;
wire        exe_to_mem_valid;
wire        mem_to_wb_valid;
wire        fe_valid;
wire        de_valid;
wire        mem_valid;
wire        exe_valid;
wire        wb_valid;
wire        fe_ready_go;
wire        de_ready_go;
wire        exe_ready_go;
wire        mem_ready_go;
wire        wb_ready_go;
assign      fe_ready_go = 1;
assign      de_ready_go = !(exe_valid&&exe_out_op[10]&&exe_out_op[0]&&(|exe_dest)&&(de_rf_raddr2==exe_dest||de_rf_raddr1==exe_dest)) ; //lw的数据相关需要阻塞一拍
assign      exe_ready_go = 1;
assign      mem_ready_go = 1;
assign      wb_ready_go = 1;



// we only need an inst ROM now
assign inst_sram_wen   = 4'b0;
assign inst_sram_wdata = 32'b0;


nextpc_gen nextpc_gen
    (
    .resetn         (~resetn         ), //I, 1

    .fe_pc          (fe_pc          ), //I, 32
    .fe_wen         (fe_wen         ), //I, 1

    .de_br_taken    (de_br_taken    ), //I, 1 
    .de_br_is_br    (de_br_is_br    ), //I, 1
    .de_br_is_j     (de_br_is_j     ), //I, 1
    .de_br_is_jr    (de_br_is_jr    ), //I, 1
    .de_br_offset   (de_br_offset   ), //I, 16
    .de_br_index    (de_br_index    ), //I, 26
    .de_br_target   (de_br_target   ), //I, 32

    .inst_sram_en   (inst_sram_en   ), //O, 1
    .inst_sram_addr (inst_sram_addr ), //O, 32

    .nextpc         (nextpc         )  //O, 32
    );


fetch_stage fe_stage
    (
    .clk            (clk            ), //I, 1
    .resetn         (~resetn         ), //I, 1
                                    
    .nextpc         (nextpc         ), //I, 32
                                    
    .inst_sram_rdata(inst_sram_rdata), //I, 32
                                    
    .fe_pc          (fe_pc          ), //O, 32  
    .fe_inst        (fe_inst        ), //O, 32
    .fe_wen         (fe_wen         ), //O, 1
    
    .now_allowin    (fe_allowin     ), //O, 1
    .next_allowin   (de_allowin     ),  //I, 1
    .pre_to_now_valid (1             ), //I, 1
    .now_to_next_valid(fe_to_de_valid),  //O, 1
    .now_valid        (fe_valid),       //O, 1
    .now_ready_go      (fe_ready_go)       //I, 1
    );


decode_stage de_stage
    (
    .clk            (clk            ), //I, 1
    .resetn         (~resetn         ), //I, 1
                                    
    .fe_inst        (fe_inst        ), //I, 32
    .fe_pc          (fe_pc          ), //I, 32
                                    
    .de_rf_raddr1   (de_rf_raddr1   ), //O, 5
    .de_rf_rdata1   (de_rf_rdata1   ), //I, 32
    .de_rf_raddr2   (de_rf_raddr2   ), //O, 5
    .de_rf_rdata2   (de_rf_rdata2   ), //I, 32
                                    
    .de_br_taken    (de_br_taken    ), //O, 1
    .de_br_is_br    (de_br_is_br    ), //O, 1
    .de_br_is_j     (de_br_is_j     ), //O, 1
    .de_br_is_jr    (de_br_is_jr    ), //O, 1
    .de_br_offset   (de_br_offset   ), //O, 16
    .de_br_index    (de_br_index    ), //O, 26
    .de_br_target   (de_br_target   ), //O, 32
                                    
    .de_out_op      (de_out_op      ), //O, ??
    .de_dest        (de_dest        ), //O, 5 
    .de_vsrc1       (de_vsrc1       ), //O, 32
    .de_vsrc2       (de_vsrc2       ), //O, 32
    .de_st_value    (de_st_value    ),  //O, 32
    //forward
    .exe_dest       (exe_dest       ),//I,  5
    .mem_dest       (mem_dest       ),//I,  5
    .wb_dest        (wb_rf_waddr    ),//I,  5
    .exe_RegWrite   (exe_out_op[0]  ),//I,  1
    .mem_RegWrite   (mem_out_op[0]  ),//I,  1
    .wb_RegWrite    (wb_rf_wen      ),//I,  1
    .exe_value      (exe_value      ),//I,  32,
    .mem_value      (mem_value      ),//I,  32,
    .wb_value       (wb_rf_wdata    ),//I,  32,
    .exe_valid      (exe_valid      ),//I   1
    .mem_valid      (mem_valid      ),//I   1
    .wb_valid       (wb_valid       ),//I   1

//  `ifdef SIMU_DEBUG
    .de_pc          (de_pc          ), //O, 32
    .de_inst        (de_inst        ),  //O, 32 
 // `endif
    
    .now_allowin    (de_allowin     ), //O, 1
    .next_allowin   (exe_allowin    ),  //I, 1
    .pre_to_now_valid (fe_to_de_valid), //I, 1
    .now_to_next_valid(de_to_exe_valid),  //O, 1
    .now_valid        (de_valid),       //O, 1
    .now_ready_go      (de_ready_go)       //I, 1
    );


execute_stage exe_stage
    (
    .clk            (clk            ), //I, 1
    .resetn         (~resetn         ), //I, 1
                                    
    .de_out_op      (de_out_op      ), //I, ??
    .de_dest        (de_dest        ), //I, 5 
    .de_vsrc1       (de_vsrc1       ), //I, 32
    .de_vsrc2       (de_vsrc2       ), //I, 32
    .de_st_value    (de_st_value    ), //I, 32
                                    
    .exe_out_op     (exe_out_op     ), //O, ??
    .exe_dest       (exe_dest       ), //O, 5
    .exe_value      (exe_value      ), //O, 32

    .data_sram_en   (data_sram_en   ), //O, 1
    .data_sram_wen  (data_sram_wen  ), //O, 4
    .data_sram_addr (data_sram_addr), //O, 32
    .data_sram_wdata(data_sram_wdata),  //O, 32

 // `ifdef SIMU_DEBUG
    .de_pc          (de_pc          ), //I, 32
    .de_inst        (de_inst        ), //I, 32
    .exe_pc         (exe_pc         ), //O, 32
    .exe_inst       (exe_inst       ),  //O, 32
 // `endif
    
    .now_allowin    (exe_allowin    ), //O, 1
    .next_allowin   (mem_allowin    ),  //I, 1
    .pre_to_now_valid (de_to_exe_valid), //I, 1
    .now_to_next_valid(exe_to_mem_valid),  //O, 1
    .now_valid        (exe_valid),       //O, 1
    .now_ready_go      (exe_ready_go)       //I, 1
    );


memory_stage mem_stage
    (
    .clk            (clk            ), //I, 1
    .resetn         (~resetn         ), //I, 1
                                    
    .exe_out_op     (exe_out_op     ), //I, ??
    .exe_dest       (exe_dest       ), //I, 5
    .exe_value      (exe_value      ), //I, 32
                                    
    .data_sram_rdata(data_sram_rdata), //I, 32
                                    
    .mem_out_op     (mem_out_op     ), //O, ??
    .mem_dest       (mem_dest       ), //O, 5
    .mem_value      (mem_value      ),  //O, 32

//  `ifdef SIMU_DEBUG
    .exe_pc         (exe_pc         ), //I, 32
    .exe_inst       (exe_inst       ), //I, 32
    .mem_pc         (mem_pc         ), //O, 32
    .mem_inst       (mem_inst       ),  //O, 1
//  `endif
  
    .next_allowin   (wb_allowin     ),  //I, 1
    .now_allowin    (mem_allowin    ), //O, 1
    .pre_to_now_valid (exe_to_mem_valid), //I, 1
    .now_to_next_valid(mem_to_wb_valid),  //O, 1
    .now_valid        (mem_valid),       //O, 1
    .now_ready_go     (mem_ready_go)     //I, 1
    );


writeback_stage wb_stage
    (
    .clk            (clk            ), //I, 1
    .resetn         (~resetn         ), //I, 1
                                    
    .mem_out_op     (mem_out_op     ), //I, ??
    .mem_dest       (mem_dest       ), //I, 5
    .mem_value      (mem_value      ), //I, 32
                                    
    .wb_rf_wen      (wb_rf_wen      ), //O, 1
    .wb_rf_waddr    (wb_rf_waddr    ), //O, 5
    .wb_rf_wdata    (wb_rf_wdata    ),  //O, 32

 // `ifdef SIMU_DEBUG
    .mem_pc         (mem_pc         ), //I, 32
    .mem_inst       (mem_inst       ), //I, 32
    .wb_pc          (wb_pc          ),  //O, 32
//  `endif
    
    .now_allowin    (wb_allowin     ), //O, 1
    .next_allowin   (1'b1           ), //I, 1
    .pre_to_now_valid (mem_to_wb_valid),  //O, 1
    .now_valid        (wb_valid),       //O, 1
    .now_ready_go      (fe_ready_go)       //I, 1
    );


regfile_2r1w regfile
    (
    .clk    (clk            ), //I, 1
    .resetn (~resetn        ), //I, 1

    .ra1    (de_rf_raddr1   ), //I, 5
    .rd1    (de_rf_rdata1   ), //O, 32

    .ra2    (de_rf_raddr2   ), //I, 5
    .rd2    (de_rf_rdata2   ), //O, 32

    .we1    (wb_rf_wen      ), //I, 1
    .wa1    (wb_rf_waddr    ), //I, 5
    .wd1    (wb_rf_wdata    )  //O, 32
    );


`ifdef SIMU_DEBUG
assign debug_wb_pc       = wb_pc;
assign debug_wb_rf_wen   = {4{wb_rf_wen}};
assign debug_wb_rf_wnum  = wb_rf_waddr;
assign debug_wb_rf_wdata = wb_rf_wdata;
`endif

endmodule //mycpu_top