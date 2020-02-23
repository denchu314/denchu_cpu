#
# Makefile
#

SRC		= main.v mRegister.v 

TARGET 		= main

all :
	iverilog -o $(TARGET) $(SRC); 
	vvp $(TARGET)
	gtkwave $(TARGET).vcd
clean:
	rm $(TARGET) $(TARGET).vcd
