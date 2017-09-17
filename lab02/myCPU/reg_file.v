`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement 4 4-bit registers
    `define DATA_WIDTH 4
	`define ADDR_WIDTH 2
`else
    `define DATA_WIDTH 32
	`define ADDR_WIDTH 5
`endif

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

reg [`DATA_WIDTH - 1:0] temp [0:2**`ADDR_WIDTH - 1];

integer i;
//write
always @(posedge clk) //�����ز���
begin
if (rst) 
begin
for (i=0;i<`DATA_WIDTH;i=i+1) temp[i] <= 0; //��λ
end
else if(wen && (waddr!= 0)) temp[waddr] <= wdata; //дʹ��+�����ַ д������
end

//read
assign rdata1 = temp[raddr1];//read����ʱ��
assign rdata2 = temp[raddr2];


endmodule
