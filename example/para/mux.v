/*
module top_module (a,b,c,d,out1,out2,sel);
    input sel;
    input [3:0] a,b;
    output [3:0] out1;
    input [12:0] c,d;
    output [12:0] out2;

    mux #(3) u1(a,b,sel,out1);
    mux #(12) u2(c,d,sel,out2);
endmodule
*/
module mux #(
    parameter msb = 9
) (
    input [msb : 0] a,b,
    input sel,
    output [msb : 0] out1
);

    assign out1 = (sel) ? a : b;
    
endmodule