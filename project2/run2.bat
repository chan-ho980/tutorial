del output*
iverilog -o output.vvp converter.v converter_part2_tb.v
vvp output.vvp
gtkwave output.vcd