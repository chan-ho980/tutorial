del output*
iverilog -o output.vvp mux.v mux_tb.v
vvp output.vvp
gtkwave output.vcd