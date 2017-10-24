module divider
(	input wire clk,
	input wire resetn,
	input wire div_en,
	input wire sign_en,

	input wire [31:0] nume, //numerator
	input wire [31:0] deno, //denominator

	output wire [31:0] quot, //quotient
	output wire [31:0] rema, //remainder
	output wire 	   calc, //calculating
	output wire 	   done
);

	wire nume_sign = nume[31] & sign_en;
	wire deno_sign = deno[31] & sign_en;

	wire [31:0] nume_0; //absolute
	wire [31:0] deno_0; //absolute

	assign nume_0 = (({32{nume_sign}}^nume) + nume_sign);
	assign deno_0 = (({32{deno_sign}}^deno) + deno_sign);

	wire quot_sign = (nume[31]^deno[31]) & sign_en;
	wire rema_sign = nume[31] & sign_en;

	reg [31:0] count;

	reg [63:0] nume_div;
	reg [31:0] deno_div;

	reg quot_sign_tmp;
	reg rema_sign_tmp;

	reg start;

	assign calc = |count;
	always @(posedge clk)
	begin
		if(!resetn) begin
		/*
			nume_div <= {64'b0};
			deno_div <= {32'b0};
			start    <= 0;
			count    <= 32'b0;
		*/
		end
		else
			if(div_en) begin		
				nume_div 	  <= {32'b0,nume_0};
				deno_div 	  <= deno_0;
				quot_sign_tmp <= quot_sign;
				rema_sign_tmp <= rema_sign;
				start	 	  <= ~calc;
			end
			else begin
				start 		  <= 0;
			end
	end


	/*
	for (i=0;i<32;i++)
	{
		printf("\twire [32:0] div_tmp%d;\n",i);
	}
	*/
	wire [32:0] div_tmp0;
	wire [32:0] div_tmp1;
	wire [32:0] div_tmp2;
	wire [32:0] div_tmp3;
	wire [32:0] div_tmp4;
	wire [32:0] div_tmp5;
	wire [32:0] div_tmp6;
	wire [32:0] div_tmp7;
	wire [32:0] div_tmp8;
	wire [32:0] div_tmp9;
	wire [32:0] div_tmp10;
	wire [32:0] div_tmp11;
	wire [32:0] div_tmp12;
	wire [32:0] div_tmp13;
	wire [32:0] div_tmp14;
	wire [32:0] div_tmp15;
	wire [32:0] div_tmp16;
	wire [32:0] div_tmp17;
	wire [32:0] div_tmp18;
	wire [32:0] div_tmp19;
	wire [32:0] div_tmp20;
	wire [32:0] div_tmp21;
	wire [32:0] div_tmp22;
	wire [32:0] div_tmp23;
	wire [32:0] div_tmp24;
	wire [32:0] div_tmp25;
	wire [32:0] div_tmp26;
	wire [32:0] div_tmp27;
	wire [32:0] div_tmp28;
	wire [32:0] div_tmp29;
	wire [32:0] div_tmp30;
	wire [32:0] div_tmp31;

	wire [32:0] deno_expend;

	assign deno_expend = {1'b0,deno_div};
	
	/*
	for (i=0;i<32;i++)
	{
		printf("\tassign div_tmp%d = nume_tmp%d[%2d:%2d] - deno_expend;\n",i,i-1,63-i,31-i);
	}
	*/
	assign div_tmp0  = nume_div  [63:31] - deno_expend;
	assign div_tmp1  = nume_tmp0 [62:30] - deno_expend;
	assign div_tmp2  = nume_tmp1 [61:29] - deno_expend;
	assign div_tmp3  = nume_tmp2 [60:28] - deno_expend;
	assign div_tmp4  = nume_tmp3 [59:27] - deno_expend;
	assign div_tmp5  = nume_tmp4 [58:26] - deno_expend;
	assign div_tmp6  = nume_tmp5 [57:25] - deno_expend;
	assign div_tmp7  = nume_tmp6 [56:24] - deno_expend;
	assign div_tmp8  = nume_tmp7 [55:23] - deno_expend;
	assign div_tmp9  = nume_tmp8 [54:22] - deno_expend;
	assign div_tmp10 = nume_tmp9 [53:21] - deno_expend;
	assign div_tmp11 = nume_tmp10[52:20] - deno_expend;
	assign div_tmp12 = nume_tmp11[51:19] - deno_expend;
	assign div_tmp13 = nume_tmp12[50:18] - deno_expend;
	assign div_tmp14 = nume_tmp13[49:17] - deno_expend;
	assign div_tmp15 = nume_tmp14[48:16] - deno_expend;
	assign div_tmp16 = nume_tmp15[47:15] - deno_expend;
	assign div_tmp17 = nume_tmp16[46:14] - deno_expend;
	assign div_tmp18 = nume_tmp17[45:13] - deno_expend;
	assign div_tmp19 = nume_tmp18[44:12] - deno_expend;
	assign div_tmp20 = nume_tmp19[43:11] - deno_expend;
	assign div_tmp21 = nume_tmp20[42:10] - deno_expend;
	assign div_tmp22 = nume_tmp21[41: 9] - deno_expend;
	assign div_tmp23 = nume_tmp22[40: 8] - deno_expend;
	assign div_tmp24 = nume_tmp23[39: 7] - deno_expend;
	assign div_tmp25 = nume_tmp24[38: 6] - deno_expend;
	assign div_tmp26 = nume_tmp25[37: 5] - deno_expend;
	assign div_tmp27 = nume_tmp26[36: 4] - deno_expend;
	assign div_tmp28 = nume_tmp27[35: 3] - deno_expend;
	assign div_tmp29 = nume_tmp28[34: 2] - deno_expend;
	assign div_tmp30 = nume_tmp29[33: 1] - deno_expend;
	assign div_tmp31 = nume_tmp30[32: 0] - deno_expend;

	reg [31:0] quot_0;

	/*
	for (i=0;i<32;i++)
	{
		printf("\treg [63:0] nume_tmp%d;\n",i);
	}
	*/
	reg [63:0] nume_tmp0;
	reg [63:0] nume_tmp1;
	reg [63:0] nume_tmp2;
	reg [63:0] nume_tmp3;
	reg [63:0] nume_tmp4;
	reg [63:0] nume_tmp5;
	reg [63:0] nume_tmp6;
	reg [63:0] nume_tmp7;
	reg [63:0] nume_tmp8;
	reg [63:0] nume_tmp9;
	reg [63:0] nume_tmp10;
	reg [63:0] nume_tmp11;
	reg [63:0] nume_tmp12;
	reg [63:0] nume_tmp13;
	reg [63:0] nume_tmp14;
	reg [63:0] nume_tmp15;
	reg [63:0] nume_tmp16;
	reg [63:0] nume_tmp17;
	reg [63:0] nume_tmp18;
	reg [63:0] nume_tmp19;
	reg [63:0] nume_tmp20;
	reg [63:0] nume_tmp21;
	reg [63:0] nume_tmp22;
	reg [63:0] nume_tmp23;
	reg [63:0] nume_tmp24;
	reg [63:0] nume_tmp25;
	reg [63:0] nume_tmp26;
	reg [63:0] nume_tmp27;
	reg [63:0] nume_tmp28;
	reg [63:0] nume_tmp29;
	reg [63:0] nume_tmp30;
	reg [63:0] nume_tmp31;

	/*
	for (i=0;i<32;i++)
	{
		printf("\talways @(posedge clk)\n");
		printf("\tbegin\n");
		printf("\t\tquot_0[%2d]\t<= !div_tmp%d[32];\n",31-i,i);
		printf("\t\tnume_tmp%d\t<= div_tmp%d[32] ? nume_tmp%d : {div_tmp%d,nume_tmp%d[30:0]};\n",i,i,i-1,i,i-1);
		printf("\t\tcount[%2d]\t<= count[%2d];\n",i,i-1);
		printf("\tend\n\n");
	}
	*/

	always @(posedge clk)
	begin
		quot_0[31]			<= !div_tmp0[32];
		nume_tmp0[63:31]	<= div_tmp0[32] ? nume_div[63:31] : div_tmp0;
		nume_tmp0[30: 0]	<= nume_div[30: 0];
		count[ 0]			<= start;
	end

	always @(posedge clk)
	begin
		quot_0[30]			<= !div_tmp1[32];
		nume_tmp1[62:30]	<= div_tmp1[32] ? nume_tmp0[62:30] : div_tmp1;
		nume_tmp1[29: 0]	<= nume_tmp0[29: 0];
		count[ 1]			<= count[ 0];
	end

	always @(posedge clk)
	begin
		quot_0[29]			<= !div_tmp2[32];
		nume_tmp2[61:29]	<= div_tmp2[32] ? nume_tmp1[61:29] : div_tmp2;
		nume_tmp2[28: 0]	<= nume_tmp1[28: 0];
		count[ 2]			<= count[ 1];
	end

	always @(posedge clk)
	begin
		quot_0[28]			<= !div_tmp3[32];
		nume_tmp3[60:28]	<= div_tmp3[32] ? nume_tmp2[60:28] : div_tmp3;
		nume_tmp3[27: 0]	<= nume_tmp2[27: 0];
		count[ 3]			<= count[ 2];
	end

	always @(posedge clk)
	begin
		quot_0[27]			<= !div_tmp4[32];
		nume_tmp4[59:27]	<= div_tmp4[32] ? nume_tmp3[59:27] : div_tmp4;
		nume_tmp4[26: 0]	<= nume_tmp3[26: 0];
		count[ 4]			<= count[ 3];
	end

	always @(posedge clk)
	begin
		quot_0[26]			<= !div_tmp5[32];
		nume_tmp5[58:26]	<= div_tmp5[32] ? nume_tmp4[58:26] : div_tmp5;
		nume_tmp5[25: 0]	<= nume_tmp4[25: 0];
		count[ 5]			<= count[ 4];
	end

	always @(posedge clk)
	begin
		quot_0[25]			<= !div_tmp6[32];
		nume_tmp6[57:25]	<= div_tmp6[32] ? nume_tmp5[57:25] : div_tmp6;
		nume_tmp6[24: 0]	<= nume_tmp5[24: 0];
		count[ 6]			<= count[ 5];
	end

	always @(posedge clk)
	begin
		quot_0[24]			<= !div_tmp7[32];
		nume_tmp7[56:24]	<= div_tmp7[32] ? nume_tmp6[56:24] : div_tmp7;
		nume_tmp7[23: 0]	<= nume_tmp6[23: 0];
		count[ 7]			<= count[ 6];
	end

	always @(posedge clk)
	begin
		quot_0[23]			<= !div_tmp8[32];
		nume_tmp8[55:23]	<= div_tmp8[32] ? nume_tmp7[55:23] : div_tmp8;
		nume_tmp8[22: 0]	<= nume_tmp7[22: 0];
		count[ 8]			<= count[ 7];
	end

	always @(posedge clk)
	begin
		quot_0[22]			<= !div_tmp9[32];
		nume_tmp9[54:22]	<= div_tmp9[32] ? nume_tmp8[54:22] : div_tmp9;
		nume_tmp9[21: 0]	<= nume_tmp8[21: 0];
		count[ 9]			<= count[ 8];
	end

	always @(posedge clk)
	begin
		quot_0[21]			<= !div_tmp10[32];
		nume_tmp10[53:21]	<= div_tmp10[32] ? nume_tmp9[53:21] : div_tmp10;
		nume_tmp10[20: 0]	<= nume_tmp9[20: 0];
		count[10]			<= count[ 9];
	end

	always @(posedge clk)
	begin
		quot_0[20]			<= !div_tmp11[32];
		nume_tmp11[52:20]	<= div_tmp11[32] ? nume_tmp10[52:20] : div_tmp11;
		nume_tmp11[19: 0]	<= nume_tmp10[19: 0];
		count[11]			<= count[10];
	end

	always @(posedge clk)
	begin
		quot_0[19]			<= !div_tmp12[32];
		nume_tmp12[51:19]	<= div_tmp12[32] ? nume_tmp11[51:19] : div_tmp12;
		nume_tmp12[18: 0]	<= nume_tmp11[18: 0];
		count[12]			<= count[11];
	end

	always @(posedge clk)
	begin
		quot_0[18]			<= !div_tmp13[32];
		nume_tmp13[50:18]	<= div_tmp13[32] ? nume_tmp12[50:18] : div_tmp13;
		nume_tmp13[17: 0]	<= nume_tmp12[17: 0];
		count[13]			<= count[12];
	end

	always @(posedge clk)
	begin
		quot_0[17]			<= !div_tmp14[32];
		nume_tmp14[49:17]	<= div_tmp14[32] ? nume_tmp13[49:17] : div_tmp14;
		nume_tmp14[16: 0]	<= nume_tmp13[16: 0];
		count[14]			<= count[13];
	end

	always @(posedge clk)
	begin
		quot_0[16]			<= !div_tmp15[32];
		nume_tmp15[48:16]	<= div_tmp15[32] ? nume_tmp14[48:16] : div_tmp15;
		nume_tmp15[15: 0]	<= nume_tmp14[15: 0];
		count[15]			<= count[14];
	end

	always @(posedge clk)
	begin
		quot_0[15]			<= !div_tmp16[32];
		nume_tmp16[47:15]	<= div_tmp16[32] ? nume_tmp15[47:15] : div_tmp16;
		nume_tmp16[14: 0]	<= nume_tmp15[14: 0];
		count[16]			<= count[15];
	end

	always @(posedge clk)
	begin
		quot_0[14]			<= !div_tmp17[32];
		nume_tmp17[46:14]	<= div_tmp17[32] ? nume_tmp16[46:14] : div_tmp17;
		nume_tmp17[13: 0]	<= nume_tmp16[13: 0];
		count[17]			<= count[16];
	end

	always @(posedge clk)
	begin
		quot_0[13]			<= !div_tmp18[32];
		nume_tmp18[45:13]	<= div_tmp18[32] ? nume_tmp17[45:13] : div_tmp18;
		nume_tmp18[12: 0]	<= nume_tmp17[12: 0];
		count[18]			<= count[17];
	end

	always @(posedge clk)
	begin
		quot_0[12]			<= !div_tmp19[32];
		nume_tmp19[44:12]	<= div_tmp19[32] ? nume_tmp18[44:12] : div_tmp19;
		nume_tmp19[11: 0]	<= nume_tmp18[11: 0];
		count[19]			<= count[18];
	end

	always @(posedge clk)
	begin
		quot_0[11]			<= !div_tmp20[32];
		nume_tmp20[43:11]	<= div_tmp20[32] ? nume_tmp19[43:11] : div_tmp20;
		nume_tmp20[10: 0]	<= nume_tmp19[10: 0];
		count[20]			<= count[19];
	end

	always @(posedge clk)
	begin
		quot_0[10]			<= !div_tmp21[32];
		nume_tmp21[42:10]	<= div_tmp21[32] ? nume_tmp20[42:10] : div_tmp21;
		nume_tmp21[ 9: 0]	<= nume_tmp20[ 9: 0];
		count[21]			<= count[20];
	end

	always @(posedge clk)
	begin
		quot_0[ 9]			<= !div_tmp22[32];
		nume_tmp22[41: 9]	<= div_tmp22[32] ? nume_tmp21[41: 9] : div_tmp22;
		nume_tmp22[ 8: 0]	<= nume_tmp21[ 8: 0];
		count[22]			<= count[21];
	end

	always @(posedge clk)
	begin
		quot_0[ 8]			<= !div_tmp23[32];
		nume_tmp23[40: 8]	<= div_tmp23[32] ? nume_tmp22[40: 8] : div_tmp23;
		nume_tmp23[ 7: 0]	<= nume_tmp22[ 7: 0];
		count[23]			<= count[22];
	end

	always @(posedge clk)
	begin
		quot_0[ 7]			<= !div_tmp24[32];
		nume_tmp24[39: 7]	<= div_tmp24[32] ? nume_tmp23[39: 7] : div_tmp24;
		nume_tmp24[ 6: 0]	<= nume_tmp23[ 6: 0];
		count[24]			<= count[23];
	end

	always @(posedge clk)
	begin
		quot_0[ 6]			<= !div_tmp25[32];
		nume_tmp25[38: 6]	<= div_tmp25[32] ? nume_tmp24[38: 6] : div_tmp25;
		nume_tmp25[ 5: 0]	<= nume_tmp24[ 5: 0];
		count[25]			<= count[24];
	end

	always @(posedge clk)
	begin
		quot_0[ 5]			<= !div_tmp26[32];
		nume_tmp26[37: 5]	<= div_tmp26[32] ? nume_tmp25[37: 5] : div_tmp26;
		nume_tmp26[ 4: 0]	<= nume_tmp25[ 4: 0];
		count[26]			<= count[25];
	end

	always @(posedge clk)
	begin
		quot_0[ 4]			<= !div_tmp27[32];
		nume_tmp27[36: 4]	<= div_tmp27[32] ? nume_tmp26[36: 4] : div_tmp27;
		nume_tmp27[ 3: 0]	<= nume_tmp26[ 3: 0];
		count[27]			<= count[26];
	end

	always @(posedge clk)
	begin
		quot_0[ 3]			<= !div_tmp28[32];
		nume_tmp28[35: 3]	<= div_tmp28[32] ? nume_tmp27[35: 3] : div_tmp28;
		nume_tmp28[ 2: 0]	<= nume_tmp27[ 2: 0];
		count[28]			<= count[27];
	end

	always @(posedge clk)
	begin
		quot_0[ 2]			<= !div_tmp29[32];
		nume_tmp29[34: 2]	<= div_tmp29[32] ? nume_tmp28[34: 2] : div_tmp29;
		nume_tmp29[ 1: 0]	<= nume_tmp28[ 1: 0];
		count[29]			<= count[28];
	end

	always @(posedge clk)
	begin
		quot_0[ 1]			<= !div_tmp30[32];
		nume_tmp30[33: 1]	<= div_tmp30[32] ? nume_tmp29[33: 1] : div_tmp30;
		nume_tmp30[0]		<= nume_tmp29[0];
		count[30]			<= count[29];
	end

	always @(posedge clk)
	begin
		quot_0[ 0]			<= !div_tmp31[32];
		nume_tmp31[32: 0]	<= div_tmp31[32] ? nume_tmp30[32: 0] : div_tmp31;
		count[31]			<= count[30];
	end


	
	assign quot = ({32{quot_sign_tmp}}^quot_0) + {30'd0,quot_sign_tmp}; 
	assign rema = ({32{rema_sign_tmp}}^nume_tmp31[31:0]) + rema_sign_tmp;
	assign done = count[31];

endmodule

