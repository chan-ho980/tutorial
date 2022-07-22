module ex (a,b,c);
    input [3:0] a,b;
    output reg [3:0] c;
    integer i;

    always @(*) begin
        for(i = 0; i < 4; i = i + 1)
            and(c[i],a[i],b[i]);     
    end

endmodule