#
# Makefile
#

SRC		= main.v memory.v memory_onchip_memory2_0.v ../altera_mf.v

TARGET 		= main

all :
	iverilog -o $(TARGET) $(SRC); 
	vvp $(TARGET)
	gtkwave $(TARGET).vcd
clean:
	rm $(TARGET) $(TARGET).vcd
