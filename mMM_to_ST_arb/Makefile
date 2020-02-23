#
# Makefile
#

SRC		= main.v mMM_to_ST_arb.v 

TARGET 		= main

all :
	iverilog -o $(TARGET) $(SRC); 
	vvp $(TARGET)
	gtkwave $(TARGET).vcd
clean:
	rm $(TARGET) $(TARGET).vcd
