`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement a 4-bit ALU
    `define DATA_WIDTH 4
`else
    `define DATA_WIDTH 32
`endif

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);
reg [`DATA_WIDTH - 1:0] reswithsign;//�з���������Ľ��
reg sltres1;
//reg sltres2;
reg Cout;
reg [`DATA_WIDTH - 1:0] negb;
reg [`DATA_WIDTH - 2:0] negbs;
reg Overflow;
reg CarryOut;
reg Zero;
reg [`DATA_WIDTH - 1:0] Result;
always@(A or B or ALUop)
begin
case(ALUop)

3'b000: //ALUop=000,FUNCTION=And
begin
Result = A & B;//��λ��&
Zero = 0;
CarryOut = 0;
Overflow = 0;//��������������δ����
end

3'b001: //ALUop=001,FUNCTION=Or
begin
Result = A | B;//��λ��|
Zero = 0;
CarryOut = 0;
Overflow = 0;//ͬAnd
end

3'b010: //ALUop=010,FUNCTION=Add
begin
{CarryOut,Result} = A + B;//�޷������������(CarryOutֻ���޷���������������ж���)
reswithsign = A[`DATA_WIDTH - 2:0] + B[`DATA_WIDTH - 2:0];//�з������������
Overflow = reswithsign[`DATA_WIDTH - 1] ^ CarryOut;//Overflowֻ���з���������������ж���
Zero = (Result == 0);
end

3'b110: //ALUop=110,FUNCTION=Subtract
begin
negb = ~B;
negbs = ~B[`DATA_WIDTH - 2:0];
{Cout,Result} = A + negb + 1;
reswithsign = A[`DATA_WIDTH - 2:0] + negbs + 1;
Overflow = reswithsign[`DATA_WIDTH - 1] ^ Cout;
CarryOut = ~Cout;//�������λΪ0ʱ��λ
Zero = (A == B);
end

3'b111: //ALUop=111,FUNCTION=Slt
begin
negb = ~B;
negbs = ~B[`DATA_WIDTH - 2:0];
{Cout,Result} = A + negb + 1;
reswithsign = A[`DATA_WIDTH - 2:0] + negbs + 1;
Overflow = reswithsign[`DATA_WIDTH - 1] ^ Cout;
CarryOut = ~Cout;//�������λΪ0ʱ��λ //���м�������
sltres1 = Overflow ^ Result[`DATA_WIDTH - 1];//�з���slt
//sltres2 = CarryOut;//�޷���slt
//Result = {{(`DATA_WIDTH - 2){0}},sltres2,sltres1};
Result = {{(`DATA_WIDTH - 1){1'b0}},sltres1};
Zero = 0;
end

default:
begin
Overflow = 0;
CarryOut = 0;
Zero = 0;
Result = 0;
end

endcase

end

endmodule
