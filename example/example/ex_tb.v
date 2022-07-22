`timescale 1ps/1ps

module ex_tb ();
    wire[3:0] a,b,c;
    
    ex u1(a,b,c);

    initial begin
        a = $random;
        b = $random;
        #10 $finish;
    end

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0);
    end
    
endmodule