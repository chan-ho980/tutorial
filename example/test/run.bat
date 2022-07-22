del output*
iverilog -o output.vvp xor.v xor_tb.v
vvp output.vvp
gtkwave output.vcd