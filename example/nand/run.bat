del output*
iverilog -o output.vvp nand.v nand_tb.v
vvp output.vvp
gtkwave output.vcd