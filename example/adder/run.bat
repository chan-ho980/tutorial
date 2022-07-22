del output*
iverilog -o output.vvp adder.v adder_tb.v
vvp output.vvp
gtkwave output.vcd