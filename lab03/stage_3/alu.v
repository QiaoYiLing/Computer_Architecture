module alu(
	input [31:0] A,
	input [31:0] B,
	input [3:0] ALUop,
	output reg Overflow,
	output reg CarryOut,
	output reg Zero,
	output reg [31:0] Result
	//	output reg done	//multiply and divide
);
 
reg [31:0] reswithsign;//�з���������Ľ��
reg sltres1;
reg sltres2;
reg Cout;
reg [31:0] negb;
reg [30:0] negbs;
reg signed [31:0] A_shift_signed;
reg signed [31:0] B_shift_signed;

always@(A or B or ALUop) 
begin
	case(ALUop)
	4'b0000: //ALUop=0000,FUNCTION=And
	begin
		Result = A & B;//��λ��&
		Zero = 0;
		CarryOut = 0;
		Overflow = 0;//��������������δ����
	end

	4'b0001: //ALUop=0001,FUNCTION=Or
	begin
		Result = A | B;//��λ��|
		Zero = 0;
		CarryOut = 0;
		Overflow = 0;//ͬAnd
	end

	4'b0010: //ALUop=0010,FUNCTION=Add
	begin
		{CarryOut,Result} = A + B;//�޷������������(CarryOutֻ���޷���������������ж���)
		reswithsign = A[30:0] + B[30:0];//�з������������
		Overflow = reswithsign[31] ^ CarryOut;//Overflowֻ���з���������������ж���
		Zero = (Result == 0);
	end
	
	4'b0011: //ALUop=0011,FUNCTION=Shift_Left
	begin
		Result = B << A[4:0]; //B = rt, A = shamt
		Overflow = 0; //�޶���(?)
		CarryOut = 0; //�޶���(?)
		Zero = (Result == 0); //�޶���(?)
    	end

	4'b0100: //ALUop=0100,FUNCTION=Lui
	begin
		Result = {B[15:0],16'b0}; //B = rt
		Overflow = 0; //�޶���(?)
		CarryOut = 0; //�޶���(?)
		Zero = (Result == 0); //�޶���(?)
	end

	4'b0101: //ALUop=0101,FUNCTION=Slt_unsigned
	begin
		negb = ~B;
		negbs = ~B[30:0];
		{Cout,Result} = A + negb + 1;
		reswithsign = A[30:0] + negbs + 1;
		Overflow = reswithsign[31] ^ Cout;
		CarryOut = ~Cout;//�������λΪ0ʱ��λ //���м�������
		//sltres1 = Overflow ^ Result[31];//�з���slt
		sltres2 = CarryOut;//�޷���slt
		Result = {{(31){1'b0}},sltres2};
		//Result = {{(31){1'b0}},sltres1};
		Zero = 0;
	end

	4'b0110: //ALUop=0110,FUNCTION=Subtract
	begin
		negb = ~B;
		negbs = ~B[30:0];
		{Cout,Result} = A + negb + 1;
		reswithsign = A[30:0] + negbs + 1;
		Overflow = reswithsign[31] ^ Cout;
		CarryOut = ~Cout;//�������λΪ0ʱ��λ
		Zero = (A == B);
	end

	4'b0111: //ALUop=0111,FUNCTION=Slt_signed
	begin
		negb = ~B;
		negbs = ~B[30:0];
		{Cout,Result} = A + negb + 1;
		reswithsign = A[30:0] + negbs + 1;
		Overflow = reswithsign[31] ^ Cout;
		CarryOut = ~Cout;//�������λΪ0ʱ��λ //���м�������
		sltres1 = Overflow ^ Result[31];//�з���slt
		//sltres2 = CarryOut;//�޷���slt
		//Result = {{(30){0}},sltres2,sltres1};
		Result = {{(31){1'b0}},sltres1};
		Zero = 0;
	end
    
    4'b1000: //ALUop=1000,FUNCTION=Nor
    begin
        Result = ~(A | B);//��λͬ�򣨻�ǣ�
        Zero = 0;
        CarryOut = 0;
        Overflow = 0;
    end
    
    4'b1001: //ALUop=1001,FUNCTION=Xor
    begin
        Result = A ^ B;//��λ���
        Zero = 0;
        CarryOut = 0;
        Overflow = 0;
    end
    
    4'b1010: //ALUop=1010,FUNCTION=Shift_Right_Logical
    begin
        Result = B >> A[4:0]; 
        Overflow = 0; //�޶���(?)
        CarryOut = 0; //�޶���(?)
        Zero = (Result == 0); //�޶���(?)
    end
    
    4'b1011: //ALUop=1011,FUNCTION=Shift_Right_Arithmetic
    begin
        B_shift_signed = B;
        Result = B_shift_signed >>> A[4:0];
        Overflow = 0; //�޶���(?)
        CarryOut = 0; //�޶���(?)
        Zero = (Result == 0); //�޶���(?)
    end

/*
    4'b1110: //ALUop=1110,FUNCTION=Mult_signed
    begin
    	A_shift_signed = A;
    	B_shift_signed = B;
    	{Result,Result2} = A_shift_signed * B_shift_signed;
    	Overflow = 0; //�޶���(?)
        CarryOut = 0; //�޶���(?)
        Zero = (Result == 0); //�޶���(?)
    end

    4'b1111: //ALUop=1111,FUNCTION=Mult_unsigned
    begin
    	{Result,Result2} = A * B;
    	Overflow = 0; //�޶���(?)
        CarryOut = 0; //�޶���(?)
        Zero = (Result == 0); //�޶���(?)
    end
*/
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