`timescale 1ns/1ns

module cnvt_part1_tb ();
    reg in1;
    reg clk;
    reg [83:0] ex1;
    wire [6:0] out_7847;
    integer i;

    cvt_1to7_ASCII u1(out_7847,in1,clk);
    
    initial begin
        ex1 = 84'b1001000_1100101_1101100_1101100_1101111_1011111_1010111_1101111_1110010_1101100_1100100_0101011;
        i = 83;
        clk = 0;
        #100 $finish;
    end

    always @(clk) begin
        in1 <= ex1[i];
        i = i - 1;
        if(i%7 == 0) $display("%c", out_7847);
    end

    always #1 clk = ~clk;

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0);
    end

endmodule