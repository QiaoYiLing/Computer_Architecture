module mul(
    input  wire        mul_clk,
    input  wire        resetn,
    input  wire        mul_signed,
    
    input  wire [31:0] x,
    input  wire [31:0] y,    
    output wire [63:0] result
);

wire [63:0] exe_C;
wire [63:0] exe_S;
wire        exe_cout;
reg  [63:0] C;
reg  [63:0] S;
reg         cin;

always @(posedge mul_clk)
begin
    if (!resetn)
    begin
        C          <= 64'd0;
        S          <= 64'd0;
        cin        <= 1'b0;
    end
    else
    begin
        C          <= exe_C;
        S          <= exe_S;
        cin        <= exe_cout;
    end
end

mul_exe mul_exe(
    .x( {{34{ mul_signed&x[31]}},x}),
    .y({ {2{ mul_signed&y[31]}},y} ),
    .C(exe_C),
    .S(exe_S),
    .cout(exe_cout)
);

mul_mem mul_meml(
    .C     ( C    ),
    .S     ( S    ),
    .cin   (cin   ),
    .result(result)
);

endmodule

module mul_exe(
    input  wire [65:0] x,
    input  wire [33:0] y,
    
    output wire [63:0] C,
    output wire [63:0] S,
    output wire        cout
);
wire [1121:66]  booth_sum;                 //booth乘法得到的和                     17 * 66 = 1122
wire [1121:0]   part_sum;                  //booth_sum补齐后的部分和        
wire [1121:0]   switch_sum;                //switch转换成64个17位数
wire [16:0]     c;                         //booth算法中 "负数为原数取反加一"  的加一
wire [989:0]    tree_c;                    //华莱士树中相邻两位传递的进位信号       15 * 66 = 990
wire [66:0]     add_C;                     //华莱士树结果
wire [65:0]     add_S;
//-----------------------------step1_booth-----------------------------//
booth booth_0(
    .x    ( x             ),
    .y    ( {y[1:0],1'b0} ),
    .p    ( part_sum[65:0]),
    .c    ( c[0]          )
);
    generate
        genvar i;
        for (i = 1; i < 17; i = i + 1)
        begin:BOOTH
            booth booth_i(
                .x    ( x                   ),
                .y    ( y[i*2+1:i*2-1]      ),
                .p    ( booth_sum[66*i+:66] ),
                .c    ( c[i]                )
            );
            assign part_sum[66*i+:66] = {booth_sum[66*i+:66-2*i],{i*2{c[i]}}};
        end
    endgenerate
//-----------------------------step2_swich-----------------------------//
    generate
        genvar j,k;
        for (j = 0; j < 66; j = j + 1)
        begin:SWITCH
            for(k = 0; k < 17; k = k + 1)
            begin:SWITCH
                assign switch_sum[j*17+k] = part_sum[k*66+j];
            end
        end
    endgenerate
//-----------------------------step3_Wallace-----------------------------//
    Wallace tree_0(
        .x     (switch_sum[16:0]),
        .cin   (c[14:0]         ),
        .cout  (tree_c[14:0]    ),
        .C     (add_C[1]        ),
        .S     (add_S[0]        )
    );
    generate
        genvar l;
        for (l = 1; l < 66; l = l + 1)
        begin:plus64
            Wallace tree_i(
                .x     (switch_sum[17*l+:17]),
                .cin   (tree_c[15*(l-1)+:15]),
                .cout  (tree_c[15*l+:15]    ),
                .C     (add_C[l+1]          ),
                .S     (add_S[l]            )
            );
        end
    endgenerate
    assign add_C[0] = c[15];
    assign cout = c[16];
    assign C = add_C[63:0];
    assign S = add_S[63:0];
endmodule

module bit_plus(
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire cout,
    output wire s
);
    assign s = a^b^cin;
    assign cout = a&b | a&cin | b&cin;
endmodule


module Wallace(
    input  wire [16:0] x,
    input  wire [14:0] cin,
    
    output wire [14:0] cout,
    output wire C,
    output wire S
);
    wire [14:0]s;
    
    bit_plus p00(x[0] ,x[1] ,x[2] ,cout[0],s[0]);
    bit_plus p01(x[3] ,x[4] ,x[5] ,cout[1],s[1]);
    bit_plus p02(x[6] ,x[7] ,x[8] ,cout[2],s[2]);
    bit_plus p03(x[9] ,x[10],x[11],cout[3],s[3]);
    bit_plus p04(x[12],x[13],x[14],cout[4],s[4]);
    bit_plus p05(x[15],x[16],1'b0 ,cout[5],s[5]);
    
    bit_plus p10(s[0]  ,s[1]  ,s[2]  ,cout[6],s[6]);
    bit_plus p11(s[3]  ,s[4]  ,s[5]  ,cout[7],s[7]);
    bit_plus p12(cin[0],cin[1],cin[2],cout[8],s[8]);
    bit_plus p13(cin[3],cin[4],cin[5],cout[9],s[9]);
    
    bit_plus p20(s[6],s[7]  ,s[8]  ,cout[10],s[10]);
    bit_plus p21(s[9],cin[6],cin[7],cout[11],s[11]);
    
    bit_plus p30(s[10] ,s[11]  ,cin[8] ,cout[12],s[12]);
    bit_plus p31(cin[9],cin[10],cin[11],cout[13],s[13]);
    
    bit_plus p40(s[12],s[13],cin[12],cout[14],s[14]);
    
    bit_plus p50(s[14],cin[13],cin[14],C,S);
endmodule


module booth(
    input  wire [65:0] x,
    input  wire [ 2:0] y,
    
    output wire [65:0] p,
    output wire        c
);
    wire [65:0] x_;
    wire [65:0] x2;
    wire [65:0] x_2;
    
    assign x_ = ~x;
    assign x2 = {x[64:0],1'b0};
    assign x_2 = ~x2;
    assign {c,p} = (y==3'b000) ? 67'b0:
                   (y==3'b001) ? {1'b0,x}:
                   (y==3'b010) ? {1'b0,x}:
                   (y==3'b011) ? {1'b0,x2}:
                   (y==3'b100) ? {1'b1,x_2}:
                   (y==3'b101) ? {1'b1,x_}:
                   (y==3'b110) ? {1'b1,x_}:
                   0;
endmodule 


module mul_mem(
    input  wire [63:0] C,
    input  wire [63:0] S,
    input  wire        cin,
    output wire [63:0] result
);
    assign result = C+S+cin;
endmodule
