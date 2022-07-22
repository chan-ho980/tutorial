`timescale 1ns/1ps

module cpu_MIPS_tb ();
    reg clk,rst;
    wire [12:0] pc;
    wire [15:0] current_instr, rf0, rf1, rf2, rf3, rf4, rf7;

    cpu_MIPS cpu1(current_instr, pc, rf0, rf1, rf2, rf3, rf4, rf7, clk, rst);

    initial begin
        clk = 0;
        rst = 0;
        #2 rst = 1;
    end

    always #0.5 clk = ~clk;
    always @(negedge clk) begin
        $display( "ID : 7847, at time %15t ps, PC = %6d, RF[0, 1, 2, 3, 4, 7] is : %d, %d, %d, %d, %d, %d", $time, pc, rf0, rf1, rf2, rf3, rf4, rf7);
    end
    initial begin
        #20 $display("The final result of $s3 in memory is : %d",cpu1.reg1.internal_data[4]);
        $finish;
    end

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0);
    end

endmodule