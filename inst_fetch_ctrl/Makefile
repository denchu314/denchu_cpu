#
# Makefile
#

SRC		= main.v mInst_fetch_ctrl.v ../arb5/mArb5.v 

TARGET 		= main

all :
	iverilog -o $(TARGET) $(SRC); 
	vvp $(TARGET)
	gtkwave $(TARGET).vcd
clean:
	rm $(TARGET) $(TARGET).vcd
