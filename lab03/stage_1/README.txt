本次CPU采用老师上课给出的框架。


概要：
    五级流水；
    阻塞方式处理数据相关；
    支持指令：LUI、ADDU、ADDIU、BEQ、BNE、LW、OR、SLT、SLTI、SLTIU、SLL、SW、J、JAL、JR；
    上板通过。


代码组织：
mycpu_top.v

----nextpc_gen.v        #组合逻辑，为fetch_stage提供nextpc
----fetch_stage.v       #取码级，从指令存储器读取指令码

----decode_stage.v      #译码级，根据指令给出控制信号、判断跳转
--------alu.v           #用于条件判断

----execute_stage.v     #执行级，组合逻辑运算
--------alu.v
----memory_stage.v      #存储级，读写数据存储器
----writeback_stage.v   #写回级，将结果写入寄存器

----regfile_2r1w.v      #同步写异步读寄存器堆