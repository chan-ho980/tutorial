`timescale 1ns/1ns

module cnvt_part2_tb ();
    reg in2;
    reg clk;
    reg [97:0] ex2;
    wire [5:0] out_7847;
    wire [6:0] print_BASE64;
    integer i;
    
    cvt_ASCII_T0_BASE64 u1(out_7847,print_BASE64, in2, clk);

    initial begin
        ex2 = 98'b1000011_1001111_1001101_1010000_0110011_0110001_0110001_1011111_1101001_1110011_1011111_1100110_1110101_1101110;
        clk = 0;
        i = 97;
        #150 $finish;
    end

    always @(clk) begin
        i <= i - 1;
        if(i % 6 == 0) $display("%c", print_BASE64);
        if (i < 0) begin
            in2 <= 0;
        end
        else in2 <= ex2[i];
    end

    always #1 clk = ~clk;

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0);
    end

endmodule