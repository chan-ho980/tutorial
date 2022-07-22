module mux(y,i0,i1,sel);
    input i0,i1,sel;
    output y;

    assign a0 = i0 & ~sel;
    assign a1 = i1 & sel;

    assign y = a0 | a1;

endmodule