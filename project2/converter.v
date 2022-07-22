`timescale 1ns/1ns
//top-module
module cvt_ASCII_T0_BASE64 (out_6bit, PrintBase64, in_1bit, clk);
    input in_1bit;
    input clk;
    output [5:0] out_6bit;
    output [6:0] PrintBase64;
    wire [6:0] out_7bit;
    wire [6:0] PrintOut;

    cvt_1to7_ASCII a1(out_7bit, in_1bit, clk);
    cvt_7to6_BASE64 b1(out_6bit, PrintOut, out_7bit, clk);
    print_BASE64 c1(PrintBase64, PrintOut);

endmodule

//1bit input >> 7bit output
module cvt_1to7_ASCII (out_7bit, in_1bit, clk);     //part1
    input in_1bit;
    input clk;
    output reg[6:0] out_7bit;
    reg[6:0] temp_7bit;
    integer i = -1;

    always @(clk) begin
        if(i < 7) begin
            temp_7bit = {temp_7bit, in_1bit};
            i = i + 1; 
        end
        if(i == 7) begin
            out_7bit = temp_7bit;
            i = 0;
        end        
    end

endmodule

//7bit input >> 6bit output
module cvt_7to6_BASE64 (out_6bit, PrintOut, in_7bit, clk);    //part2-1
    input [6:0] in_7bit;
    input clk;
    output reg[5:0] out_6bit;
    output [6:0] PrintOut;
    reg [12:0] temp;
    integer i = -1;
    integer j;
    integer k = 0;

    always @(clk) begin
        k = k + 1;
        if(k == 6) k = 0;
    end

    always @(k) begin
        if(i == 3'b000) begin
            temp = {out_6bit, in_7bit};
            out_6bit = temp[6:1];
        end
        else if (i == 3'b001) begin
            temp = {temp[0], in_7bit};
            out_6bit = temp[7:2];
        end
        else if (i == 3'b010) begin
            temp = {temp[1:0], in_7bit};
            out_6bit = temp[8:3];
        end
        else if (i == 3'b011) begin
            temp = {temp[2:0], in_7bit};
            out_6bit = temp[9:4];
        end
        else if (i == 3'b100) begin
            temp = {temp[3:0], in_7bit};
            out_6bit = temp[10:5];
        end
        else if (i == 3'b101) begin
            temp = {temp[4:0], in_7bit};
            out_6bit = temp[11:6];
        end
        else if (i == 3'b101) begin
            temp = {temp[5:0], in_7bit};
            out_6bit = temp[12:7];
        end
        else if (i == 3'b110) begin
            out_6bit = temp[6:0];
            i = -1;
        end
        else begin
            out_6bit = 6'b0;
        end
        i = i + 1;
    end

    assign PrintOut = {1'b0, out_6bit};

endmodule

//BASE64를 ASCII로 출력하기 위해 변환하는 모듈
module print_BASE64 (print_out, print_in);
    input [6:0]print_in;
    output reg [6:0]print_out;

    always @(*) begin
        if(print_in <= 25) begin
            print_out = print_in + 65;
        end
        else if (print_in > 25 && print_in <= 51) begin
            print_out = print_in + 71;
        end
        else if (print_in > 51 && print_in <=61) begin
            print_out = print_in - 4;
        end
        else if(print_in == 62) print_out = print_in - 19;
        else if(print_in == 63) print_out = print_in - 16;
    end
    
endmodule