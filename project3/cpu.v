`timescale 1ns/1ps

//MIPS_top-module
module cpu_MIPS (
    output [15:0] current_instr,
    output [12:0] pc,
    output [15:0] rf0, rf1, rf2, rf3, rf4, rf7,
    input clk,rst
);
    wire Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,jr_out,zero,and_out;
    wire [15:0] sel_signed, sel_data, sel_w_data, r_data1, r_data2, w_data,sign_ex_out,out1,datamem_strm, rf0, rf1, rf2, rf3, rf4, rf7;
    wire [12:0] pc_p2,mux1_out,mux2_out,pc_in,adderout,jump_address;
    wire [6:0] sign_extend_out;
    wire [3:0] funct;
    wire [2:0] sel_w_reg,op_code,rs,rt,rd,opcode,r_register1, r_register2, w_register,alu_ctrl_out;
    wire [1:0] RegDst, MemtoReg, ALUOp;

    pc pc1(pc, pc_in, clk, rst);
    adder #(12,12,0) a1(pc_p2, pc, 1'b1);
    adder #(12,12,15) a2(adderout,pc_p2,sign_ex_out);
    instruction_Memory inst_mem1(.op_code(op_code), .rs(rs), .rt(rt), .rd(rd), .funct(funct), .sign_extend_out(sign_extend_out), .jump_address(jump_address), .in1(pc), .clk(clk), .rst(rst));
    control_unit ctrl1(.RegDst(RegDst), .Jump(Jump), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .opcode(op_code));
    mux_3to1 #(2,2,2,2) m1(.out1(sel_w_reg),.in1(rt),.in2(rd),.in3(3'b111),.sel(RegDst));
    register reg1(.r_data1(r_data1), .r_data2(r_data2), .rf0(rf0), .rf1(rf1), .rf2(rf2), .rf3(rf3), .rf4(rf4), .rf7(rf7), .regWrite(RegWrite), .r_register1(rs), .r_register2(rt), .w_register(sel_w_reg), .w_data(sel_data), .clk(clk), .rst(rst));
    sign_extend sign_ext1(.sign_ex_out(sign_ex_out), .instruction(sign_extend_out));
    mux_2to1 #(15,15,15) m2(.out1(sel_signed),.in1(r_data2),.in2(sign_ex_out),.sel(ALUSrc));
    alu_ctrl alu_c1(.alu_ctrl_out(alu_ctrl_out), .instruction(funct), .aluop(ALUOp));
    jr_ctrl jr_c1(.jr_out(jr_out), .instruction(funct), .aluop(ALUOp));
    alu alu1(.out1(out1), .zero(zero), .in1(r_data1), .in2(sel_signed), .control(alu_ctrl_out));
    data_Memory data1(.datamem_strm(datamem_strm), .datamem_data(r_data2), .datamem_addr(out1), .clk(clk), .rst(rst), .we(MemWrite), .re(MemRead));
    mux_3to1 #(15,15,15,12) m3(.out1(sel_data),.in1(out1),.in2(datamem_strm),.in3(pc_p2),.sel(MemtoReg));
    my_and #(0,0,0) ad1(.out1(and_out),.in1(Branch),.in2(zero));
    mux_2to1 #(12,12,12) m5(.out1(mux1_out),.in1(pc_p2),.in2(adderout),.sel(and_out));
    mux_2to1 #(12,12,12) m6(.out1(mux2_out),.in1(mux1_out),.in2(jump_address),.sel(Jump));
    mux_2to1 #(12,12,15) m7(.out1(pc_in),.in1(mux2_out),.in2(r_data1),.sel(jr_out));

endmodule

//register file
module register(r_data1, r_data2, rf0, rf1, rf2, rf3, rf4, rf7, regWrite, r_register1, r_register2, w_register, w_data, clk, rst);
    output [15:0] r_data1, r_data2;
    output [15:0] rf0, rf1, rf2, rf3, rf4, rf7;
    input [2:0] r_register1, r_register2, w_register;
    input [15:0] w_data;
    input regWrite, clk, rst;

    reg [15:0] internal_data [7:0];
    integer i;

    initial begin
        for(i = 0; i < 8; i = i + 1) internal_data[i] = 0;
    end

    always @(posedge clk) begin
        if(~rst) begin
            for(i = 0; i < 8; i = i + 1) begin
                internal_data[i] <= 16'b0;
            end
        end
        else if(regWrite) begin
            internal_data[w_register] <= w_data;
        end
        internal_data[0] <= 0;
    end

    assign r_data1 = internal_data[r_register1];
    assign r_data2 = internal_data[r_register2];
    assign rf0 = internal_data[0];
    assign rf1 = internal_data[1];
    assign rf2 = internal_data[2];
    assign rf3 = internal_data[3];
    assign rf4 = internal_data[4];
    assign rf7 = internal_data[7];

endmodule

// 2 input 1 output  MIPS_ALU
module alu(out1, zero, in1, in2, control);
    input [15:0] in1,in2;
    input [2:0] control;
    output reg zero;
    output reg [15:0] out1;

    always @(*) begin
        case(control)
            3'b000 : out1 = in1 + in2;                      // 000 : add
            3'b001 : out1 = in1 - in2;                      // 001 : sub
            3'b010 : out1 = in1 & in2;                      // 010 : and
            3'b011 : out1 = in1 | in2;                      // 011 : or
            3'b100 : out1 = (in1 < in2) ? 1'b1 : 1'b0;      // 100 : slt
            3'b101 : out1 = in1 * in2;                      // 101 : mul
            3'b110 : out1 = in1 / in2;                      // 110 : div
        endcase
        zero = (out1 == 0) ? 1'b1 : 1'b0;
    end    
endmodule

//data memoty
module data_Memory(datamem_strm, datamem_data, datamem_addr, clk, rst, we, re);
    input [15:0] datamem_data, datamem_addr;
    input clk,rst,we,re;
    output [15:0] datamem_strm;

    integer i;
    reg [15:0] internal_mem[23:0];

    initial begin    
        #2
        internal_mem[0] = 16'b0000_0000_0000_0000;
        internal_mem[1] = 16'b0000_0000_0010_0011;
        internal_mem[2] = 16'b0000_0000_0000_1001;
        internal_mem[3] = 16'b0000_0000_0011_0001;
        internal_mem[4] = 16'b0000_0000_1100_1001;
        internal_mem[5] = 16'b0000_0000_0011_1100;
        internal_mem[6] = 16'b0000_0000_1101_1011;
        internal_mem[7] = 16'b0000_0000_0000_0111;
        internal_mem[8] = 16'b1110_0001_0010_1000;
        internal_mem[9] = 16'b0101_0011_1100_0101;
        internal_mem[10] = 16'b1001_0111_1000_1001;
        internal_mem[11] = 16'b1101_0011_1101_1111;
        internal_mem[12] = 16'b1011_1001_1001_0001;
        internal_mem[13] = 16'b0000_0100_0110_0101;
        internal_mem[14] = 16'b0001_1100_0101_0110;
        internal_mem[15] = 16'b0001_0010_1110_0100;
        internal_mem[16] = 16'b0110_1000_0011_1001;
        internal_mem[17] = 16'b1111_1000_0010_1011;
        internal_mem[18] = 16'b0011_1101_0111_1001;
        internal_mem[19] = 16'b1011_0000_0111_0001;
        internal_mem[20] = 16'b0010_0001_1110_0110;
        internal_mem[21] = 16'b1101_0000_1100_1010;
        internal_mem[22] = 16'b0111_0111_0000_1110;
        internal_mem[23] = 16'b1111_1101_1011_1001;
    end

    always @(posedge clk) begin
        if(~rst) begin
            for(i = 0; i < 24; i = i + 1) begin
                internal_mem[i] <= 16'b0;
            end
        end
        else if(we) begin
            internal_mem[datamem_addr] <= datamem_data;
        end
    end

    assign datamem_strm = (re) ? internal_mem[datamem_addr] : 16'b0;

endmodule

//instruction memory
module instruction_Memory (op_code, rs, rt, rd, funct,sign_extend_out, jump_address, in1, clk, rst);
    input [12:0] in1;
    input clk, rst;
    output [2:0] op_code,rs,rt,rd;
    output [3:0] funct;
    output [6:0] sign_extend_out;
    output [12:0] jump_address;

    integer i;
    reg [15:0] internal_mem [23:0];
    wire [15:0] instmem_strm;

    
    initial begin    
        #2
        internal_mem[0] <= 16'b1001_1001_0000_0001;
        internal_mem[1] <= 16'b1001_1001_1000_0010;
        internal_mem[2] <= 16'b0000_1001_1100_0000;
        internal_mem[3] <= 16'b0000_1001_1001_0100;
        internal_mem[4] <= 16'b1100_0100_0000_0010;
        internal_mem[5] <= 16'b0000_1001_1100_0010;
        internal_mem[6] <= 16'b0100_0000_0000_1000;
        internal_mem[7] <= 16'b0000_1001_1100_0001;
        internal_mem[8] <= 16'b0000_1001_1100_0011;
        internal_mem[9] <= 16'b0110_0000_0000_1101;
        internal_mem[10] <= 16'b1111_0010_0000_0010;
        internal_mem[11] <= 16'b1011_1010_0000_0011;
        internal_mem[12] <= 16'b0100_0000_0000_1111;
        internal_mem[13] <= 16'b000_010_011_100_0110;
        internal_mem[14] <= 16'b0001_1100_0000_1000;
        internal_mem[15] <= 16'b0000_0000_0000_0000;
        internal_mem[16] <= 16'b0000_0000_0000_0000;
        internal_mem[17] <= 16'b0000_0000_0000_0000;
        internal_mem[18] <= 16'b0000_0000_0000_0000;
        internal_mem[19] <= 16'b0000_0000_0000_0000;
        internal_mem[20] <= 16'b0000_0000_0000_0000;
        internal_mem[21] <= 16'b0000_0000_0000_0000;
        internal_mem[22] <= 16'b0000_0000_0000_0000;
        internal_mem[23] <= 16'b0000_0000_0000_0000;
    end

    always @(posedge clk) begin
        if(~rst) begin
            for(i = 0; i < 24; i = i + 1)begin
                internal_mem[i] <= 16'b0;
            end
        end
    end
        assign instmem_strm = internal_mem[in1];
        assign op_code = instmem_strm[15:13];
        assign rs = instmem_strm[12:10];
        assign rt = instmem_strm[9:7];
        assign rd = instmem_strm[6:4];
        assign funct = instmem_strm[3:0];
        assign sign_extend_out = instmem_strm[6:0];
        assign jump_address = instmem_strm[12:0];    
endmodule

//mux 2 to 1
module mux_2to1 #(parameter count_out1 = 0, count_in1 = 0, count_in2 = 0) (out1,in1,in2,sel);
    input [count_in1 : 0] in1;
    input [count_in2 : 0] in2;
    input sel;
    output reg [count_out1 : 0] out1;

    always @(*) begin
        case(sel)
            0 : out1 = in1;
            1 : out1 = in2;
        endcase
    end
endmodule

//mux 3 to 1
module mux_3to1 #(parameter count_out1 = 0, count_in1 = 0, count_in2 = 0, count_in3 = 0) (out1,in1,in2,in3,sel);
    input [count_in1 : 0] in1;
    input [count_in2 : 0] in2;
    input [count_in3 : 0] in3;
    input [1:0] sel;
    output reg [count_out1 : 0] out1;

    always @(*) begin
        case(sel)
            2'b00 : out1 = in1;
            2'b01 : out1 = in2;
            2'b10 : out1 = in3;
        endcase
    end
endmodule

//my_and #(1,1) ad1(and_out,Branch,zero);
module my_and (out1,in1,in2);
    output reg out1;
    input in1;
    input in2;

    always @(*) begin
        out1 = in1 & in2;
    end

endmodule


//control unit design
module control_unit (
    output reg Jump,Branch,MemRead,
    output reg [1:0] RegDst, ALUOp, MemtoReg,
    output reg MemWrite,ALUSrc,RegWrite,
    input [2:0] opcode
    );

    always @(*) begin
        case(opcode)
        3'b000 : begin                      // 0 : mode R
            RegDst = 2'b01;                     //register data store
            Jump = 0;
            Branch = 0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b00;
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 1'b1;
        end
        3'b001 : begin                          // 1 : slti (mode I)
            RegDst = 0;
            Jump = 0;
            Branch =0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b10;
            MemWrite = 0;
            ALUSrc = 1;
            RegWrite = 1'b1;
        end
        3'b010 : begin                          // 2 : j
            RegDst = 0;
            Jump = 1;
            Branch = 0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b00;
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 1'b0;
        end
        3'b011 : begin                          // 3 : jal
            RegDst = 2'b10;
            Jump = 1;
            Branch = 0;
            MemRead = 0;
            MemtoReg = 2'b10;
            ALUOp = 2'b00;
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 1'b1;
        end
        3'b100 : begin                          // 4 : load word
            RegDst = 0;
            Jump = 0;
            Branch = 0;
            MemRead = 1;
            MemtoReg = 1;
            ALUOp = 2'b11;
            MemWrite = 0;
            ALUSrc = 1;
            RegWrite = 1'b1;
        end
        3'b101 : begin                          // 5 : store word
            RegDst = 0;
            Jump = 0;
            Branch = 0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b11;
            MemWrite = 1;
            ALUSrc = 1;
            RegWrite = 1'b0;
        end
        3'b110 : begin                          // 6 : beq
            RegDst = 0;
            Jump = 0;
            Branch = 1;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b01;
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 1'b0;
        end
        3'b111 : begin                         // 7 : addi (mode I)
            RegDst = 0;
            Jump = 0;
            Branch = 0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b11;
            MemWrite = 0;
            ALUSrc = 1;
            RegWrite = 1'b1;
        end
        endcase
    end

endmodule

module jr_ctrl (jr_out,instruction,aluop);
    output jr_out;
    input [3:0] instruction;
    input [1:0] aluop;

    assign jr_out = ({aluop,instruction} == 6'b001000) ? 1'b1:1'b0;
    
endmodule

module alu_ctrl (alu_ctrl_out, instruction, aluop);
    output reg [2:0] alu_ctrl_out;
    input [3:0] instruction;
    input [1:0] aluop;

    always @(*) begin
        if(aluop == 2'b11) alu_ctrl_out = 3'b000;       //addi, lw, sw
        else if(aluop == 2'b01) alu_ctrl_out = 3'b001;  //beq
        else if(aluop == 2'b10) alu_ctrl_out = 3'b100;  //slt
        else begin
            case (instruction)
                0 : alu_ctrl_out = 3'b000;              //add
                1 : alu_ctrl_out = 3'b001;              //sub
                2 : alu_ctrl_out = 3'b010;              //and
                3 : alu_ctrl_out = 3'b011;              //or
                4 : alu_ctrl_out = 3'b100;              //alt
                5 : alu_ctrl_out = 3'b101;              //mul
                6 : alu_ctrl_out = 3'b110;              //div
            endcase
        end
    end    
endmodule

module sign_extend(sign_ex_out, instruction);
    output [15:0] sign_ex_out;
    input [6:0] instruction;

    assign sign_ex_out = {6'b0, instruction};

endmodule

module pc (pc_out,pc_in,clk,rst);
    output reg [12:0] pc_out;
    input [12:0] pc_in;
    input clk,rst;

    always @(posedge clk or negedge rst) begin
        if(~rst) pc_out = 13'b0;
        else pc_out = pc_in;
    end

endmodule

//adder module with parmarters
module adder #(parameter count_out1 = 0, count_in1 = 0, count_in2 = 0) (out1,in1,in2);
    input [count_in1 : 0] in1;
    input [count_in2 : 0] in2;
    output reg [count_out1 : 0] out1;

    always @(*) begin
        out1 = in1 + in2;
    end 
endmodule