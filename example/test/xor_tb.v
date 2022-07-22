`timescale 1ns/1ns

module testb();
    reg a,b,c,d;
    wire x,y,z;

    xorgate u1(z,x,y);
    andgate u2(x,a,b);
    orgate u3(y,c,d);

    initial begin
        a = 0; b= 0; c = 0; d = 0;
        #20 $finish;
    end

    always #4 a = ~a;
    always #5 b = ~b;
    always #6 c = ~c;
    always #7 d = ~d;

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0);
    end
endmodule