module xorgate (out1, in1, in2);
    input in1,in2;
    output out1;

    assign out1 = in1 ^ in2;

    // specify
    //     (in1 => out1) = 2;
    //     (in2 => out1) = 3;
    // endspecify
endmodule

module andgate(out1, in1, in2);
    input in1,in2;
    output out1;

    assign out1 = in1 & in2;

    // specify
    //     (in1 => out1) = 3;
    //     (in2 => out1) = 3;
    // endspecify
endmodule

module orgate (out1, in1, in2);
    input in1,in2;
    output out1;

    assign out1 = in1 | in2;

    // specify
    //     (in1 => out1) = 1;
    //     (in2 => out1) = 1;
    // endspecify
endmodule