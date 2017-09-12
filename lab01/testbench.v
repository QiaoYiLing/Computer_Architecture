`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/11 17:48:03
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench();
    reg           clka, clkb;
    reg  [3 :0]   wea, web;
    reg  [7 :0]   addra, addrb;
    reg  [31:0]   dina, dinb;
    wire [31:0]   douta, doutb;
    reg  [7 :0]   i;
    
    data_ram test_ram(
        .clka(clka), .wea(wea), .addra(addra), .dina(dina), .douta(douta),
        .clkb(clkb), .web(web), .addrb(addrb), .dinb(dinb), .doutb(doutb)
    );
    
    initial begin
        i = 0;
        wea = 0;
        web = 0;
        dina = 0;
        dinb = 0;
        #2;
        repeat(200) begin
            #8;
            i = i + 1;
            addra = i;
            addrb = i+1;
        end
        
        i = 0;
        repeat(200) begin
            #8;
            i = i + 1;
            addra = i;
            addrb = i;
            wea = 0;
            dina = i;
            #8 wea = 4'b1111;
        end
    end
    
    always begin
        clka = 0;
        #4 clka = 1;
        #4;
    end
    
     always begin
        #2 clkb = 0;
        #4 clkb = 1;
        #2;
    end 
    
   
    
endmodule
