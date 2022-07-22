`timescale 1ns/1ns

module mux_tb ();
    reg[3:0] a,b;
    reg[12:0] c,d;
    wire[3:0] out1;
    wire[12:0] out2;
    reg sel;
   
    mux #(3) u1(a,b,sel,out1);
    mux #(12) u2(c,d,sel,out2);
   // top_module u1(a,b,c,d,out1,out2,sel);

    initial begin
        sel = 0;
        a = 4'b0;
        b = 4'b1111;
        c = 13'b0;
        d = 13'b1111_1111_11111;
        #10 $finish;
    end

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0);
    end
endmodule