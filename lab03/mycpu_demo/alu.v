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
	output reg Overflow,
	output reg CarryOut,
	output reg Zero,
	output reg [`DATA_WIDTH - 1:0] Result
);
 
reg [`DATA_WIDTH - 1:0] reswithsign;//�з���������Ľ��
reg sltres1;
reg sltres2;
reg Cout;
reg [`DATA_WIDTH - 1:0] negb;
reg [`DATA_WIDTH - 2:0] negbs;

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
	
	3'b011: //ALUop=011,FUNCTION=Sll
	begin
		Result = B << A[4:0]; //B = rt, A = shamt
		Overflow = 0; //�޶���(?)
		CarryOut = 0; //�޶���(?)
		Zero = (Result == 0); //�޶���(?)
    	end

	3'b100: //ALUop=100,FUNCTION=Lui
	begin
		Result = {B[15:0],16'b0}; //B = rt
		Overflow = 0; //�޶���(?)
		CarryOut = 0; //�޶���(?)
		Zero = (Result == 0); //�޶���(?)
	end

	3'b101: //ALUop=101,FUNCTION=Slt_unsigned
	begin
		negb = ~B;
		negbs = ~B[`DATA_WIDTH - 2:0];
		{Cout,Result} = A + negb + 1;
		reswithsign = A[`DATA_WIDTH - 2:0] + negbs + 1;
		Overflow = reswithsign[`DATA_WIDTH - 1] ^ Cout;
		CarryOut = ~Cout;//�������λΪ0ʱ��λ //���м�������
		//sltres1 = Overflow ^ Result[`DATA_WIDTH - 1];//�з���slt
		sltres2 = CarryOut;//�޷���slt
		Result = {{(`DATA_WIDTH - 1){1'b0}},sltres2};
		//Result = {{(`DATA_WIDTH - 1){1'b0}},sltres1};
		Zero = 0;
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

	3'b111: //ALUop=111,FUNCTION=Slt_signed
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