`timescale 1ns/1ns

module mux_tb();
    reg a,b,sel;
    wire y;

    mux u1(y,a,b,sel);

    initial begin
        a = $random;
        b = $random;
        sel = $random;
        #10 $finish;
    end

    always #5 sel = ~sel;

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0);
    end

endmodule